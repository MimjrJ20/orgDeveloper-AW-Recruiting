@isTest
public with sharing class OpportunityTest {

    //criação de registros 
    @TestSetup
    static void createTestData() {
        Account acc = AccountTestDataFactory.createAccountSample(true);
        Opportunity oppContract = OpportunityTestDataFactory.createOpportunitySample(true, 'Contract', Date.today() + 30, acc.Id, 'Prospecting');
        Opportunity oppPosition = OpportunityTestDataFactory.createOpportunitySample(true, 'Position', Date.today() + 30, acc.Id, 'Prospecting');
        Opportunity oppContractDate = OpportunityTestDataFactory.createOpportunitySampleContract(true, Date.today() + 30, Date.today(), acc.Id, 'Prospecting');
    }

    @isTest
    static void testOppInfoWithout(){

        Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];

        try {
            Test.startTest();
            Opportunity oppUpdate = OpportunityTestDataFactory.updateOpportunityStatus(true, opp, 'Closed Won');
            Test.stopTest();
            
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('You cannot close the opportunity with the Contract Term and/or Start Date fields blank!') ? true : false;
            Assert.areEqual(true, result);
        }
    }

    @isTest
    static void testOppNewDate(){
        
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;

        try {
            Test.startTest();
            Opportunity opp = OpportunityTestDataFactory.createOpportunitySampleContract(true, Date.today() + 30, Date.today() -1, accId, 'Prospecting');
            Test.stopTest();
            
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('You cannot save the opportunity if the Contract Start Date is in the past!') ? true : false;
            Assert.areEqual(true, result);
        }
    }

    @isTest
    static void testOppUpdateDate(){
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE StartDate__c != null LIMIT 1];

        try {
            Test.startTest();
            Opportunity oppUpdate = OpportunityTestDataFactory.updateOpportunityDate(true, opp, Date.today() -1);
            Test.stopTest();
            
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('You cannot save the opportunity if the Contract Start Date is in the past!') ? true : false;
            Assert.areEqual(true, result);
        }
    }

    @isTest
    static void testOppEditWin(){

        Opportunity opp = [SELECT Id FROM Opportunity WHERE RecordType.Name = 'Position' LIMIT 1];
        Opportunity oppWon = OpportunityTestDataFactory.updateOpportunityStatus(true, opp, 'Closed Won');

        try {
            Test.startTest();
            Opportunity oppUpdate = OpportunityTestDataFactory.updateOpportunityStatus(true, oppWon, 'Qualification');
            Test.stopTest();
            
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('You cannot modify the opportunity after it has been closed!') ? true : false;
            Assert.areEqual(true, result);
        }
    }

    @isTest
    static void testOppEditLost(){
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE RecordType.Name = 'Position' LIMIT 1];
        Opportunity oppLost = OpportunityTestDataFactory.updateOpportunityStatus(true, opp, 'Closed Lost');

        try {
            Test.startTest();
            Opportunity oppUpdate = OpportunityTestDataFactory.updateOpportunityStatus(true, oppLost, 'Qualification');
            Test.stopTest();
            
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('You cannot modify the opportunity after it has been closed!') ? true : false;
            Assert.areEqual(true, result);
        }
    }

    @isTest
    static void testOppCreatePosition(){
        
        Opportunity opp = [SELECT Id, Name, StageName, AccountId, RecordTypeId FROM Opportunity WHERE RecordType.Name = 'Position' LIMIT 1];

        Test.startTest();
        Opportunity oppUpdate = OpportunityTestDataFactory.updateOpportunityStatus(true, opp, 'Closed Won');
        Test.stopTest();

        Position__c[] posCreated = [SELECT Id, OwnerId FROM Position__c WHERE Name = :oppUpdate.Name];
        Boolean result = posCreated != null;
        Assert.areEqual(true, result);
        Assert.areEqual(1, posCreated.size());
    }

    @isTest
    static void testOppCreateContract(){
        
        Opportunity opp = [SELECT Id, ContractId, Name, StageName, AccountId, RecordTypeId FROM Opportunity WHERE RecordType.Name = 'Contract' LIMIT 1];

        Test.startTest();
        Opportunity oppUpdate = OpportunityTestDataFactory.updateOpportunityContract(true, opp, 'Closed Won', Date.today()+30, 1,3);
        Test.stopTest();

        Opportunity oppAfterUpdate = [SELECT Id, ContractId FROM Opportunity WHERE Id = :oppUpdate.Id];

        Contract[] contractCreated = [
            SELECT Id
            FROM Contract  
            WHERE Id = :oppAfterUpdate.ContractId
        ];
       
        Boolean result = contractCreated != null;
        Assert.areEqual(true, result);
        Assert.areEqual(1, contractCreated.size());
    }
}