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
}