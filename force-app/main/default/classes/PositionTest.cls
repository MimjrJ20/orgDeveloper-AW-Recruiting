@isTest
public with sharing class PositionTest {
    
    //criação de registros 
    @TestSetup
    static void createTestData() {
        Account acc = AccountTestDataFactory.createAccountSample(true);
        Contract contract = ContractTestDataFactory.createContract(true, acc.Id, 1, Date.today()+60,'New');
    }

    //
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

    //
    @isTest
    static void testPositionWithoutContractMonthPlus(){
        
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Contract contract = [SELECT Id FROM Contract WHERE AccountId = :accId LIMIT 1];
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

    //
    @isTest
    static void testPositionWithoutContractMonth(){
        
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Contract contract = [SELECT Id FROM Contract WHERE AccountId = :accId LIMIT 1];
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

    //
    @isTest
    static void testPositionWithoutPositionInContract(){
        
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Contract contract = [SELECT Id FROM Contract WHERE AccountId = :accId LIMIT 1];
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

    //
    @isTest
    static void testBatchPositionCanceled(){

        List<Account> lstAcc = AccountTestDataFactory.createAccountSampleList(true, 200);
        List<Contract> lstContracts = ContractTestDataFactory.createContractList(true, lstAcc, 1, Date.today(), 'New');
        List<Contract> lstContractsActived = ContractTestDataFactory.updateContractListStatus(false, true, lstContracts, 'Activated');
        List<Position__c> lstPosition = PositionTestDataFactory.createPositionList(true, lstAcc, 'New', 'Approved');
        List<Contract> lstContractsClosed = ContractTestDataFactory.updateContractListStatus(false, true, lstContractsActived, 'Closed');

        Test.startTest();
        PositionSchedulerHandler positionScheduler = new PositionSchedulerHandler();
        positionScheduler.execute(null);//null pois será simulado a execução do agendador sem fornecer um contexto real de agendamento ---> o objetivo principal é verificar o comportamento e os resultados do agendador
        Test.stopTest();

        List<Position__c> lstPositionUpdated = [SELECT Id, Status__c FROM Position__c WHERE Status__c = 'Canceled'];
        Assert.areEqual(200, lstPositionUpdated.size());
    }

    @isTest
    static void testPositionUpdate(){

        List<Account> lstAcc = AccountTestDataFactory.createAccountSampleList(true, 10);
        List<Contract> lstContracts = ContractTestDataFactory.createContractList(true, lstAcc, 1, Date.today(), 'New');
        List<Contract> lstContractsActived = ContractTestDataFactory.updateContractListStatus(false, true, lstContracts, 'Activated');
        List<Position__c> lstPosition = PositionTestDataFactory.createPositionList(true, lstAcc, 'New', 'Approved');

        User user = UserTestDataFactory.createUser();

        List<Id> lstIds = new List<Id>();
        for (Position__c position : lstPosition) {
            lstIds.add(position.Id);
        }

        Test.startTest();
        PositionController.updatePosition(lstIds, 'Approved', 'Open', user.Id, user.Id);
        Test.stopTest();

        List<Position__c> lstPositionUpdated = [SELECT Id FROM Position__c WHERE OwnerId = :user.Id];

        Assert.areEqual(lstPosition.size(), lstPositionUpdated.size());
    }

    @isTest
    static void testPositionDAO(){

        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        Contract contract = ContractTestDataFactory.createContract(true, accId, 1, Date.today(),'New');
        Contract contractUpdatedStatus = ContractTestDataFactory.updateContractStatus(false, true, contract, 'Activated');
        Position__c position = PositionTestDataFactory.createPosition(true,accId,'New','Pending');

        Test.startTest();
        Position__c positionGetId = PositionDAO.getPositionById(position.Id);
        List<Position__c> lstPosition = PositionDAO.getPositionsAvailableNotFilter();
        List<Position__c> lstPositionAvailable = PositionDAO.getPositionsAvailable('Test', 'New', null, true, null);
        List<Position__c> lstPositionAvailableEmpty = PositionDAO.getPositionsAvailable('Test', 'New', 'selectedOwner', true, 'idUser');
        List<Position__c> lstPositionAvailableProfile = PositionDAO.getPositionsAvailable('Test', 'New', 'selectedOwner', false, 'idUser');
        List<Position__c> lstPositionAvailableEmptyProfile = PositionDAO.getPositionsAvailable('Test', 'New', null, false, null);
        List<String> lstPicklistValues = PositionDAO.getPicklistValuesPosition('Status__c');
        Test.stopTest();

        Assert.areEqual(position.Id, positionGetId.Id);
        Assert.areEqual(true, lstPosition.size()>0);
        Assert.areEqual(true, lstPositionAvailable.size()>0);
        Assert.areEqual(true, lstPositionAvailableEmpty.size()==0);
        Assert.areEqual(true, lstPositionAvailableProfile.size()==0);
        Assert.areEqual(true, lstPositionAvailableEmptyProfile.size()==0);
        Assert.areEqual(true, lstPicklistValues.contains(position.Status__c));


    }
}