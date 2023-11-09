@isTest
public with sharing class JobApplicationTest {

    //criação de registros 
    @TestSetup
    static void createTestData() {
        Account acc = AccountTestDataFactory.createAccountSample(true);
        Contract contract = ContractTestDataFactory.createContract(true, acc.Id, 1, Date.today(),'New');
        Candidate__c candidate = CandidateTestDataFactory.createCandidateSample(true);
    }

    //
    @isTest
    static void testJobPostNew(){

        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Contract contract = [SELECT Id FROM Contract LIMIT 1];
        Contract contractUpdated = ContractTestDataFactory.updateContractStatusFull(true, true, contract, 'Activated',1);
        Candidate__c candidate = [SELECT Id FROM Candidate__c LIMIT 1];
        Position__c position = PositionTestDataFactory.createPosition(true,accId,'New','Pending');

        Test.startTest();
        Job_Application__c job = JobApplicationTestDataFactory.createJobApplication(true,candidate.Id,position.Id,'Open','New');
        new JobApplicationTriggerHandler().postChatterJob(new Map<Id, Job_Application__c>(), new Map<Id, Job_Application__c>{job.Id => job});
        Test.stopTest();

        List<FeedItem> chatterPostsTest = [SELECT Id, Body FROM FeedItem LIMIT 1 ];
        Boolean result = chatterPostsTest[0].Body.contains('Nova Aplicação a vaga') ? true : false;
        Assert.areEqual(true, result);    
    }

    //
    @isTest
    static void testJobPostUpdate(){

        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Contract contract = [SELECT Id FROM Contract LIMIT 1];
        Contract contractUpdated = ContractTestDataFactory.updateContractStatusFull(true, true, contract, 'Activated',1);
        Candidate__c candidate = [SELECT Id FROM Candidate__c LIMIT 1];
        Position__c position = PositionTestDataFactory.createPosition(true,accId,'New','Pending');
        Job_Application__c job = JobApplicationTestDataFactory.createJobApplication(true,candidate.Id,position.Id,'Open','New');

        Test.startTest();
        Job_Application__c jobUpdated = JobApplicationTestDataFactory.updateJobApplication(true,job,'Hold','Offer Extended');
        new JobApplicationTriggerHandler().postChatterJob(new Map<Id, Job_Application__c>{jobUpdated.Id => jobUpdated}, new Map<Id, Job_Application__c>{jobUpdated.Id => jobUpdated});
        Test.stopTest();

        List<FeedItem> chatterPostsTest = [SELECT Id, Body, CreatedDate FROM FeedItem];
        Boolean result = chatterPostsTest[1].Body.contains('Atualização da vaga aplicada') ? true : false;
        Assert.areEqual(true, result);    
    }

    //
    @isTest
    static void testJobStartDate(){

        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Contract contract = [SELECT Id FROM Contract LIMIT 1];
        Contract contractUpdated = ContractTestDataFactory.updateContractStatusFull(true, true, contract, 'Activated',1);
        Candidate__c candidate = [SELECT Id FROM Candidate__c LIMIT 1];
        Position__c position = PositionTestDataFactory.createPosition(true,accId,'New','Pending');
        Job_Application__c job = JobApplicationTestDataFactory.createJobApplication(true,candidate.Id,position.Id,'Open','New');

        try {
            Test.startTest();
            Job_Application__c jobUpdated = JobApplicationTestDataFactory.updateJobApplicationDate(true,job,Date.today() + 20);
            Test.stopTest();  
        } catch (Exception error){
            Boolean result = error.getMessage().contains('Due to the hiring process, the start date must be MORE than 30 days from today! Inserted difference:') ? true : false;
            Assert.areEqual(true, result);
        }
    }

    //
    @isTest
    static void testJobDelete(){

        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Contract contract = [SELECT Id FROM Contract LIMIT 1];
        Contract contractUpdated = ContractTestDataFactory.updateContractStatusFull(true, true, contract, 'Activated',1);
        Candidate__c candidate = [SELECT Id FROM Candidate__c LIMIT 1];
        Position__c position = PositionTestDataFactory.createPosition(true,accId,'New','Pending');
        Job_Application__c job = JobApplicationTestDataFactory.createJobApplication(true,candidate.Id,position.Id,'Open','New');

        try {
            Test.startTest();
            JobApplicationTestDataFactory.deleteJobApplication(true, job);
            Test.stopTest();
        } catch (Exception error){
            Boolean result = error.getMessage().contains('For compliance reasons, once the vacancy has been applied under these conditions, the record cannot be deleted!') ? true : false;
            Assert.areEqual(true, result);
        }
    }

    @isTest
    static void testJobDAO(){

        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Contract contract = [SELECT Id FROM Contract WHERE AccountId = :accId  LIMIT 1];
        Contract contractUpdated = ContractTestDataFactory.updateContractStatusFull(true, true, contract, 'Activated',1);
        Candidate__c candidate = [SELECT Id, Name FROM Candidate__c LIMIT 1];
        Position__c position = PositionTestDataFactory.createPosition(true,accId,'New','Pending');
        Job_Application__c job = JobApplicationTestDataFactory.createJobApplication(true,candidate.Id,position.Id,'Open','New');

        Test.startTest();
        Job_Application__c jobGetId = JobApplicationDAO.searchJobById(job.Id);
        Job_Application__c jobGetIdDetails = JobApplicationDAO.searchJobByIdDetails(job.Id);
        List<Job_Application__c> lstJobCandidateId = JobApplicationDAO.searchJobByIdCandidate(candidate.Id);
        List<Job_Application__c> lstJobCandidateName = JobApplicationDAO.searchJobByNameCandidate(candidate.Name);
        Job_Application__c jobUpdated = JobApplicationTestDataFactory.updateJobApplication(true, job, 'Open', 'Interviews Completed');
        List<Job_Application__c> lstJobCandidateIdInterview = JobApplicationDAO.searchJobByIdCandidateAndInterview(candidate.Id);
        Test.stopTest();  

        Boolean jobFoundId = false;
        for (Job_Application__c jobs : lstJobCandidateId) {
            if (jobs.Id == job.Id) {
                jobFoundId = true;
                break;
            }
        }

        Boolean jobFoundName = false;
        for (Job_Application__c jobs : lstJobCandidateName) {
            if (jobs.Id == job.Id) {
                jobFoundName = true;
                break;
            }
        }

        Boolean jobFoundNameInterview = false;
        for (Job_Application__c jobs : lstJobCandidateIdInterview) {
            if (jobs.Id == jobUpdated.Id) {
                jobFoundNameInterview = true;
                break;
            }
        }

        Assert.areEqual(job.Id, jobGetId.Id);
        Assert.areEqual(job.Id, jobGetIdDetails.Id);
        Assert.areEqual(true, jobFoundId);
        Assert.areEqual(true, jobFoundName);
        Assert.areEqual(true, jobFoundNameInterview);
    }  
    
    @isTest
    static void testJobUpdateProposal(){

        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Contract contract = [SELECT Id FROM Contract WHERE AccountId = :accId  LIMIT 1];
        Contract contractUpdated = ContractTestDataFactory.updateContractStatusFull(true, true, contract, 'Activated',1);
        Candidate__c candidate = CandidateTestDataFactory.createCandidateSample(true);
        Position__c position = PositionTestDataFactory.createPosition(true,accId,'New','Pending');

        Job_Application__c job = JobApplicationTestDataFactory.createJobApplication(true, candidate.Id, position.Id, 'Pending', 'Application');

        Test.startTest();
        Map<String, String> result = JobApplicationController.updateJobApplicationProposal(job.Id);
        Test.stopTest();

        job = [SELECT Id, Status__c, Stage__c FROM Job_Application__c WHERE Id = :job.Id];
        Assert.areEqual('Proposal', job.Status__c);
        Assert.areEqual('Generate Proposal', job.Stage__c);
    }

    @isTest
    public static void testSetDefaultValue() {

        String result1 = JobApplicationController.setDefaultValue('Test');
        Assert.areEqual('Test', result1);

        String result2 = JobApplicationController.setDefaultValue('');
        Assert.areEqual('TBD', result2);
    }

    @isTest
    public static void testFormatDate() {

        Date inputDate1 = Date.newInstance(2023, 11, 10);
        String result1 = JobApplicationController.formatDate(inputDate1);
        Assert.areEqual('10/11/2023', result1);

        Date inputDate2 = null;
        String result2 = JobApplicationController.formatDate(inputDate2);
        Assert.areEqual('TBD', result2);

        Date inputDate3 = Date.newInstance(2023, 1, 2);
        String result3 = JobApplicationController.formatDate(inputDate3);
        Assert.areEqual('02/01/2023', result3);
    }
}