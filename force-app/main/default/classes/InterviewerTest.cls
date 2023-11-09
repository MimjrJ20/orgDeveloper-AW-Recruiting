@isTest
public with sharing class InterviewerTest {

    //criação de registros
    @TestSetup
    static void createTestData() {
        Account acc = AccountTestDataFactory.createAccountSample(true);
        Contract contract = ContractTestDataFactory.createContract(true, acc.Id, 1, Date.today(),'New');
        Contract contractUpdated = ContractTestDataFactory.updateContractStatusFull(true, true, contract, 'Activated',1);
        Position__c position = PositionTestDataFactory.createPosition(true,acc.Id,'New','Pending');
        List<Candidate__c> lstCandidates = CandidateTestDataFactory.createCandidateList(true,10);
        List<Job_Application__c> lstJobs = JobApplicationTestDataFactory.createJobApplicationList(true, lstCandidates, position.Id, 'Open', 'New');
        List<Interviewer__c> lstInterviewers = InterviewerTestDataFactory.createInterviewerList(true,lstJobs, Datetime.now());
    }

    //
    @isTest
    static void testInterviewerUpdateCandidate() {

        List<Job_Application__c> lstJobs = [SELECT Id FROM Job_Application__c];

        Test.startTest();
        List<Interviewer__c> lstInterviewers = InterviewerTestDataFactory.createInterviewerList(true,lstJobs, Datetime.now()+10);
        Test.stopTest();

        List<Interviewer__c> lstInterviewersUpdated = [SELECT Id, Candidate__c FROM Interviewer__c WHERE Id IN :lstInterviewers];

        for (Interviewer__c interviewer : lstInterviewersUpdated) {
            Assert.areNotEqual(null, interviewer.Candidate__c);
        }
    }

    //
    @isTest
    static void testInterviewerVerifyDate() {

        List<Interviewer__c> lstInterviewers = [SELECT Id, Status__c,  Date_Time_Interview__c FROM Interviewer__c];
        List<Interviewer__c> lstInterviewersUpdated = new List<Interviewer__c>();

        try {
            Test.startTest();
            lstInterviewersUpdated = InterviewerTestDataFactory.updateInterviewerDate(true,lstInterviewers,Datetime.now()-1);
            Test.stopTest();  
        } catch (Exception error){
            Boolean result = error.getMessage().contains('The interview date and time must be greater than the current moment. Now:') ? true : false;
            Assert.areEqual(true, result);
        }
    }

    //
    @isTest
    static void testInterviewerUpdateJob() {

        List<Interviewer__c> lstInterviewers = [SELECT Id, Status__c,  Date_Time_Interview__c FROM Interviewer__c];
        List<Interviewer__c> lstInterviewersToUpdate = new List<Interviewer__c>();

        Test.startTest();
        lstInterviewersToUpdate = InterviewerTestDataFactory.updateInterviewerStatus(true,lstInterviewers,'Completed');
        Test.stopTest();

        List<Interviewer__c> lstInterviewersUpdated = [SELECT Id, Status__c, Job_Application__c, Job_Application__r.Status__c, Job_Application__r.Stage__c FROM Interviewer__c WHERE Id IN :lstInterviewersToUpdate];

        for (Interviewer__c interviewer : lstInterviewersUpdated) {
            Assert.areEqual('Open', interviewer.Job_Application__r.Status__c);
            Assert.areEqual('Interviews Completed', interviewer.Job_Application__r.Stage__c);
        }
    }

    //
    @isTest
    static void testInterviewerUpdateEquals() {

        List<Job_Application__c> lstJobs = [SELECT Id FROM Job_Application__c];

        try {
            Test.startTest();
            List<Interviewer__c> lstInterviewersNews = InterviewerTestDataFactory.createInterviewerList(true,lstJobs, Datetime.now());
            Test.stopTest();  
        } catch (Exception error){
            Boolean result = error.getMessage().contains('There is already an interview with the same Date and Time for this candidate') ? true : false;
            Assert.areEqual(true, result);
        }
    }
}