@isTest
public with sharing class ContractTest {

    //
    @isTest
    static void contractDuplicateMonthActual(){

        Account accNew = new Account();
        accNew.Name = 'Teste Conta Opp Contract Without';
        insert accNew;

        Contract contrNew1 = new Contract();
        contrNew1.AccountId = accNew.Id;
        contrNew1.Status = 'New';
        contrNew1.ContractTerm = 1;
        contrNew1.StartDate = System.today();
        insert contrNew1;

        Contract contrNew2 = new Contract();
        contrNew2.AccountId = accNew.Id;
        contrNew2.Status = 'New';
        contrNew2.ContractTerm = 1;
        contrNew2.StartDate = System.today();

        try {
            Test.startTest();
            insert contrNew2;
            Test.stopTest();
            
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('Já existe um contrato com a mesma Conta e com datas conflitantes!');
            System.assertEquals(true, result);
        }
    }

    //
    @isTest
    static void contractDuplicateMonthRange(){

        Account accNew = new Account();
        accNew.Name = 'Teste Conta Opp Contract Without';
        insert accNew;

        Contract contrNew1 = new Contract();
        contrNew1.AccountId = accNew.Id;
        contrNew1.Status = 'New';
        contrNew1.ContractTerm = 2;
        contrNew1.StartDate = System.today();
        insert contrNew1;

        Contract contrNew2 = new Contract();
        contrNew2.AccountId = accNew.Id;
        contrNew2.Status = 'New';
        contrNew2.ContractTerm = 1;
        contrNew2.StartDate = System.today().addMonths(1);

        try {
            Test.startTest();
            insert contrNew2;
            Test.stopTest();
            
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('Já existe um contrato com a mesma Conta e com datas conflitantes!');
            System.assertEquals(true, result);
        }
    }

    //
    @isTest
    static void testBatchContractActive(){

        //criação de contas de teste
        List<Account> accList = new List<Account>();
            
        for(Integer i = 0; i<200; i++){
            
            Account accNew = new Account();
            accNew.Name = 'Teste conta ' + i;
            accList.add(accNew);
        }
        
        insert accList;

        //criação de contratos para cada conta
        List<Contract> contractList = new List<Contract>();

        for(Account acc : accList) {

            Contract contrNew = new Contract();
            contrNew.AccountId = acc.Id;
            contrNew.Status = 'New';
            contrNew.ContractTerm = 1;
            contrNew.StartDate = System.today();
            contrNew.PositionMonth__c = 1;
            
            contractList.add(contrNew);
        }

        insert contractList;

        Test.startTest();

        //executa o agendador
        ContractSchedulerHandler contractScheduler = new ContractSchedulerHandler();

        //null pois será simulado a execução do agendador sem fornecer um contexto real de agendamento. 
        //o objetivo principal é verificar o comportamento e os resultados do agendador
        contractScheduler.execute(null);
        
        Test.stopTest();

        //verifica se os contratos foram atualizados corretamente
        List<Contract> contractListUpdate = [SELECT Id, Status, Description__c, StartDate FROM Contract WHERE Status = 'Activated'];
        System.assertEquals(200, contractListUpdate.size());

        for(Contract contract : contractListUpdate) {
            Boolean result = contract.Description__c.contains('Contrato ativado através de schedule.') ? true : false;
            System.assertEquals(true, result);
        }
    }

    //
    @isTest
    static void testBatchContractClosed(){

        //criação de contas de teste
        List<Account> accList = new List<Account>();
            
        for(Integer i = 0; i<200; i++){
            
            Account accNew = new Account();
            accNew.Name = 'Teste conta ' + i;
            accList.add(accNew);
        }
        
        insert accList;

        //criação de contratos para cada conta
        List<Contract> contractList = new List<Contract>();

        for(Account acc : accList) {

            Contract contrNew = new Contract();
            contrNew.AccountId = acc.Id;
            contrNew.Status = 'New';
            contrNew.ContractTerm = 1;
            contrNew.StartDate = System.today() - 60;
            contrNew.PositionMonth__c = 1;
            
            contractList.add(contrNew);
        }

        insert contractList;

        List<Contract> contractListUp = new List<Contract>();

        for(Contract contrUp : contractList){
            
            contrUp.Status = 'Activated';
            contractListUp.add(contrUp);
        }

        update contractListUp;

        Test.startTest();

        //executa o agendador
        ContractSchedulerHandler contractScheduler = new ContractSchedulerHandler();

        //null pois será simulado a execução do agendador sem fornecer um contexto real de agendamento. 
        //o objetivo principal é verificar o comportamento e os resultados do agendador
        contractScheduler.execute(null);

        Test.stopTest();

        //verifica se os contratos foram atualizados corretamente
        List<Contract> contractListUpdate = [SELECT Id, Status, Description__c, EndDate FROM Contract WHERE Status = 'Closed'];
        System.assertEquals(200, contractListUpdate.size());

        for(Contract contract : contractListUpdate) {
            Boolean result = contract.Description__c.contains('Contrato fechado através de schedule.') ? true : false;
            System.assertEquals(true, result);
        }
    }
}