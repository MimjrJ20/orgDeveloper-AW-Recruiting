@isTest
public with sharing class ContractTest {

    //criação de registros 
    @TestSetup
    static void createTestData() {
        List<Account> lstAcc = AccountTestDataFactory.createAccountSampleList(true,10);
        List<Contract> lstContract = ContractTestDataFactory.createContractList(true,lstAcc,3,Date.today(),'New');
    }

    //teste para método contractDuplicate mesmo mês
    @isTest
    static void testContractDuplicateSameMonth(){

        Id accId = [SELECT Id FROM Account LIMIT 1].Id;

        try {
            Test.startTest();
            Contract contract = ContractTestDataFactory.createContract(true,accId,3,Date.today(),'New');
            Test.stopTest();
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('There is already a contract with the same Account and conflicting dates!');
            Assert.areEqual(true, result);
        }
    }

    //teste para método contractDuplicate por intervalo
    @isTest
    static void testContractDuplicateRangeFirst(){

        Id accId = [SELECT Id FROM Account LIMIT 1].Id;

        try {
            Test.startTest();
            Contract contract = ContractTestDataFactory.createContract(true,accId,1,Date.today().addDays(1), 'New');
            Test.stopTest();
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('There is already a contract with the same Account and conflicting dates!');
            Assert.areEqual(true, result);
        }

    }

    //teste para método contractDuplicate por intervalo 
    @isTest
    static void testContractDuplicateRangeSecond(){

        Id accId = [SELECT Id FROM Account LIMIT 1].Id;

        try {
            Test.startTest();
            Contract contract = ContractTestDataFactory.createContract(true,accId,1,Date.today().addMonths(1), 'New');
            Test.stopTest();
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('There is already a contract with the same Account and conflicting dates!');
            Assert.areEqual(true, result);
        }
    }
    
    //teste para alterar o Status
    @isTest
    static void testContractChangeStatusFirst(){

        Contract contract = [SELECT Id, Status FROM Contract LIMIT 1];
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Human Resources' LIMIT 1].Id;
        User user = UserTestDataFactory.userByProfileId(profileId);

        try {
            Test.startTest();
            System.runAs(user) {
                Contract contractUpdate = ContractTestDataFactory.updateContractStatus(true, true, contract, 'Review');
            }            
            Test.stopTest();
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('You do not have the required profile to change the contract status, only from New to Draft or oposite.');
            Assert.areEqual(true, result);
        }
    }

    //teste para enviar o registro para aprovação
    @isTest
    static void testContractSubmitApprovals(){

        Contract contract = [SELECT Id, Status FROM Contract LIMIT 1];
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Human Resources' LIMIT 1].Id;
        User user = UserTestDataFactory.userByProfileId(profileId);

        try {
            Test.startTest();
            System.runAs(user) {
                contract = ContractTestDataFactory.updateContractStatusFull(false, true, contract, 'Draft');
            }            
            Test.stopTest();
        } catch (Exception error) {
            String result = error.getMessage();
            System.debug('Error testContractSubmitApprovals: ' + result);
        }

        Contract contractSubmited = [SELECT Id, Status FROM Contract WHERE Id = :contract.Id];
        Assert.areEqual('In Approval Process', contractSubmited.Status);
    }

    //teste para StartDate inferior
    @isTest
    static void testContractStartDate(){

        Contract contract = [SELECT Id, Status FROM Contract LIMIT 1];

        try {
            Test.startTest();
            Contract contractUpdate = ContractTestDataFactory.updateContractStartDate(true, true, contract, Date.today().addDays(-1));
            Test.stopTest();
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('The contract start date cannot be earlier than today. Difference:');
            Assert.areEqual(true, result);
        }
    }

    //teste para ContractUpdateBatchJob Activated
    @isTest
    static void testBatchContractActive(){

        List<Contract>lstContracts = [SELECT Id, Description__c FROM Contract LIMIT 200];
        List<Contract>lstContractsToUpdateDate = ContractTestDataFactory.updateContractListStartDate(false, true, lstContracts, Date.today().addDays(-1));
        List<Contract>lstContractsToUpdateStatus = ContractTestDataFactory.updateContractListStatus(false, true, lstContractsToUpdateDate, 'Approved');

        try {
            Test.startTest();
            ContractSchedulerHandler contractScheduler = new ContractSchedulerHandler();
            contractScheduler.execute(null);//null pois será simulado a execução do agendador sem fornecer um contexto real de agendamento. ----> objetivo principal é verificar o comportamento e os resultados do agendador
            Test.stopTest();
        } catch (Exception error) {
            String result = error.getMessage();
            System.debug('Error testBatchContractActive: ' + result);
        }
       
        List<Contract> lstContractsUpdated = [SELECT Id, Description__c, Status FROM Contract WHERE Status = 'Activated'];
        Assert.areEqual(10, lstContractsUpdated.size());

        if (!lstContractsUpdated.isEmpty()) {
            for(Contract contract : lstContractsUpdated) {
                Boolean result = contract.Description__c.contains('Contract activated through a schedule.');
                Assert.areEqual(true, result);
            }
        }

    }

    // teste para ContractUpdateBatchJob Closed
    @isTest
    static void testBatchContractClosed(){

        List<Contract>lstContracts = [SELECT Id, Description__c, Status, StartDate FROM Contract LIMIT 200];
        List<Contract>lstContractsToUpdateDate = ContractTestDataFactory.updateContractListStartDate(false, true, lstContracts, Date.today().addMonths(-3));
        List<Contract>lstContractsToUpdateStatus = ContractTestDataFactory.updateContractListStatus(false, true, lstContractsToUpdateDate, 'Activated');

        try {
            Test.startTest();
            ContractSchedulerHandler contractScheduler = new ContractSchedulerHandler();
            contractScheduler.execute(null);//null pois será simulado a execução do agendador sem fornecer um contexto real de agendamento. ----> objetivo principal é verificar o comportamento e os resultados do agendador
            Test.stopTest();
        } catch (Exception error) {
            String result = error.getMessage();
            System.debug('Error testBatchContractClosed: ' + result);
        }
       
        List<Contract> lstContractsUpdated = [SELECT Id, Description__c, Status, StartDate FROM Contract WHERE Status = 'Closed'];
        Assert.areEqual(10, lstContractsUpdated.size());

        if (!lstContractsUpdated.isEmpty()) {
            for(Contract contract : lstContractsUpdated) {
                Boolean result = contract.Description__c.contains('Contract closed through a schedule.');
                Assert.areEqual(true, result);
            }
        }
    }


}