@isTest
public with sharing class CandidatePDFControllerTest {

    //
    @TestSetup
    static void createTestData(){
        Account acc = AccountTestDataFactory.createAccountSample(true);
        Contract contract = ContractTestDataFactory.createContract(true, acc.Id, 1, Date.today(),'New');
        Contract contractUpdated = ContractTestDataFactory.updateContractStatusFull(true, true, contract, 'Activated',1);
        Position__c position = PositionTestDataFactory.createPosition(true,acc.Id,'New','Pending');
        List<Candidate__c> lstCandidates = CandidateTestDataFactory.createCandidateList(true,10);
        List<Job_Application__c> lstJobs = JobApplicationTestDataFactory.createJobApplicationList(true, lstCandidates, position.Id, 'Open', 'New');
    }

    //
    @isTest
    static void testSavePDFCandidate() {

        Candidate__c candidate = [SELECT Id FROM Candidate__c LIMIT 1];
        Job_Application__c job = [SELECT Id, Name FROM Job_Application__c WHERE Candidate__c =:candidate.Id LIMIT 1];

        String idCandidate = candidate.Id;
        String pdfBody = 'SGVsbG8gV29ybGQ';
        String jobName = job.Name;

        Test.startTest();
        CandidatePDFController.savePDFCandidate(idCandidate, pdfBody, jobName);
        Test.stopTest();

        ContentVersion cv = [SELECT Id FROM ContentVersion WHERE Title = :jobName + ' - Generated Proposal.pdf' LIMIT 1];
        Assert.areNotEqual(null, cv, 'ContentVersion should be inserted');

        ContentDocumentLink cdl = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :idCandidate LIMIT 1];
        Assert.areNotEqual(null, cdl, 'ContentDocumentLink should be inserted');
    }

    //
    @isTest
    static void testGeneratePDFContent() {

        Candidate__c candidate = [SELECT Id FROM Candidate__c LIMIT 1];
        Job_Application__c job = [SELECT Id, Name, Position__r.Account__r.Name FROM Job_Application__c WHERE Candidate__c =:candidate.Id LIMIT 1];

        String idCandidate = candidate.Id;
        String city = 'Test City';
        String state = 'Test State';
        String country = 'Test Country';
        String candidateNumber = 'Test Number';
        String candidateName = 'Test Candidate';
        String positionName = job.Name;
        String accountName = job.Position__r.Account__r.Name;
        String description = 'Test Description';
        String skills = 'Test Skills';
        String department = 'Test Department';
        String salary = 'Test Salary';
        String manager = 'Test Manager';
        String startDate = 'Test Start Date';
        String deadline = 'Test Deadline';
        String userName = 'Test User';

        System.debug('aqui:');
        Test.startTest();
        String pdfContent = CandidatePDFController.generatePDFContent(
            idCandidate, city, state, country, candidateNumber, candidateName, positionName, accountName, description, skills, 
            department, salary, manager, startDate, deadline, userName
        );
        Test.stopTest();

        Assert.areNotEqual(null, pdfContent, 'Generated PDF Content should not be null');
        Assert.areNotEqual(0, pdfContent.length(), 'Generated PDF Content should have a valid length');
    }
}