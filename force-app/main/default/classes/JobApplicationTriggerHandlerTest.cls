@isTest
public with sharing class JobApplicationTriggerHandlerTest {

    @isTest
    static void testNewJob(){
        
        Candidate__c candNew = new Candidate__c();
        candNew.First_Name__c = 'Teste Candidate';
        insert candNew;

        Position__c posNew = new Position__c();
        posNew.Name = 'Teste Position';
        posNew.Approval_Status__c = 'Pending';
        posNew.Status__c = 'New';
        insert posNew;

        Job_Application__c jobNew = new Job_Application__c();
        jobNew.Candidate__c = candNew.Id;
        jobNew.Position__c = posNew.Id;
        jobNew.Status__c = 'Open';
        jobNew.Stage__c = 'New';


 /*        try {
            Test.startTest();
            insert jobNew;
            Test.stopTest();
            
        } catch (Exception error) {
            Boolean result = true;
            System.assertEquals(expected, actual);
            
        } */
    }

}