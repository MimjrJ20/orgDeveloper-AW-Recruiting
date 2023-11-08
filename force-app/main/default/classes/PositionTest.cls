@isTest
public with sharing class PositionTest {

    @TestSetup
    static void createTestData() {
        Account acc = AccountTestDataFactory.createAccountSample(true);
        Contract contract = ContractTestDataFactory.createContract(true, acc.Id, 1, Date.today()+60,'New');
    }

    @isTest
    static void testPositionWithoutContractActive(){

        Id accId = [SELECT Id FROM Account LIMIT 1].Id;

        try {
            Test.startTest();
            Position__c position = PositionTestDataFactory.createPosition(true,accId,'New','Pending');
            Test.stopTest();
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('This account does not have an active contract!') ? true : false;
            Assert.areEqual(true, result);
        }
    }

    @isTest
    static void testPositionWithoutContractMonthPlus(){
        
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Contract contract = [SELECT Id FROM Contract LIMIT 1];
        Contract contractUpdated = ContractTestDataFactory.updateContractStatusFull(false, true, contract, 'Activated',1);

        try {
            Test.startTest();
            Position__c position = PositionTestDataFactory.createPosition(true,accId,'New','Pending');
            Test.stopTest();
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('This account does not have an active contract for this month!') ? true : false;
            System.assertEquals(true, result);
        }
    }

    @isTest
    static void testPositionWithoutContractMonth(){
        
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Contract contract = [SELECT Id FROM Contract LIMIT 1];
        Contract contractUpdatedDate = ContractTestDataFactory.updateContractStartDate(false, true, contract, Date.today()-60);
        Contract contractUpdatedStatus = ContractTestDataFactory.updateContractStatusFull(false, true, contractUpdatedDate, 'Activated',1);

        try {
            Test.startTest();
            Position__c position = PositionTestDataFactory.createPosition(true,accId,'New','Pending');
            Test.stopTest();
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('This account does not have an active contract for this month!') ? true : false;
            Assert.areEqual(true, result);
        }
    }

    @isTest
    static void testPositionWithoutPositionInContract(){
        
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Contract contract = [SELECT Id FROM Contract LIMIT 1];
        Contract contractUpdatedDate = ContractTestDataFactory.updateContractStartDate(false, true, contract, Date.today());
        Contract contractUpdatedStatus = ContractTestDataFactory.updateContractStatusFull(false, true, contractUpdatedDate, 'Activated',0);

        try {
            Test.startTest();
            Position__c position = PositionTestDataFactory.createPosition(true,accId,'New','Pending');
            Test.stopTest();
            
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('This account does not have available positions in the contract! Used position(s): ') ? true : false;
            Assert.areEqual(true, result);
        }
    }

    @isTest
    static void testBatchPositionCanceled(){

        List<Account> lstAcc = AccountTestDataFactory.createAccountSampleList(true, 200);
        List<Contract> lstContracts = ContractTestDataFactory.createContractList(true, lstAcc, 1, Date.today(), 'New');
        List<Contract> lstContractsActived = ContractTestDataFactory.updateContractListStatus(false, true, lstContracts, 'Activated');
        List<Position__c> posList = PositionTestDataFactory.createPositionList(true, lstAcc, 'New', 'Approved');
        List<Contract> lstContractsClosed = ContractTestDataFactory.updateContractListStatus(false, true, lstContractsActived, 'Closed');

        Test.startTest();
        PositionSchedulerHandler positionScheduler = new PositionSchedulerHandler();
        positionScheduler.execute(null);//null pois será simulado a execução do agendador sem fornecer um contexto real de agendamento ---> o objetivo principal é verificar o comportamento e os resultados do agendador
        Test.stopTest();

        List<Position__c> lstPositionUpdated = [SELECT Id, Status__c FROM Position__c WHERE Status__c = 'Canceled'];
        Assert.areEqual(200, lstPositionUpdated.size());
    }
}