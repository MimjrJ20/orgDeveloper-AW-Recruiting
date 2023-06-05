@isTest
public with sharing class PositionTest {

    @isTest
    static void testPositionWithoutContractActive(){
        
        Account accNew = new Account();
        accNew.Name = 'Teste Conta without contract.';
        insert accNew;

        Position__c posNew = new Position__c();
        posNew.Name = 'Teste Position without contract.';
        posNew.Account__c = accNew.Id;

        try {
            Test.startTest();
            insert posNew;
            Test.stopTest();
            
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('Essa conta não possui contrato ativo!') ? true : false;
            System.assertEquals(true, result);
            
        }
    }

    @isTest
    static void testPositionWithoutContractMonthPlus(){
        
        Account accNew = new Account();
        accNew.Name = 'Teste Conta without contract month plus.';
        insert accNew;

        Contract contrNew = new Contract();
        contrNew.AccountId = accNew.Id;
        contrNew.Status = 'New';
        contrNew.ContractTerm = 1;
        contrNew.StartDate = System.today() + 60;
        contrNew.PositionMonth__c = 1;
        insert contrNew;

        contrNew.Status = 'Activated';
        update contrNew;

        Position__c posNew = new Position__c();
        posNew.Name = 'Teste Position without contract month plus.';
        posNew.Account__c = accNew.Id;

        try {
            Test.startTest();
            insert posNew;
            Test.stopTest();
            
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('Essa conta não possui contrato ativo para este mês!') ? true : false;
            System.assertEquals(true, result);
            
        }
    }

    @isTest
    static void testPositionWithoutContractMonth(){
        
        Account accNew = new Account();
        accNew.Name = 'Teste Conta without contract month.';
        insert accNew;

        Contract contrNew = new Contract();
        contrNew.AccountId = accNew.Id;
        contrNew.Status = 'New';
        contrNew.ContractTerm = 1;
        contrNew.StartDate = System.today() - 60;
        contrNew.PositionMonth__c = 1;
        insert contrNew;

        contrNew.Status = 'Activated';
        update contrNew;

        Position__c posNew = new Position__c();
        posNew.Name = 'Teste Position without contract month.';
        posNew.Account__c = accNew.Id;

        try {
            Test.startTest();
            insert posNew;
            Test.stopTest();
            
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('Essa conta não possui contrato ativo para este mês!') ? true : false;
            System.assertEquals(true, result);
            
        }
    }

    @isTest
    static void testPositionWithoutPositionInContract(){
        
        Account accNew = new Account();
        accNew.Name = 'Teste Conta without position in contract.';
        insert accNew;

        Contract contrNew = new Contract();
        contrNew.AccountId = accNew.Id;
        contrNew.Status = 'New';
        contrNew.ContractTerm = 1;
        contrNew.StartDate = System.today();
        contrNew.PositionMonth__c = 0;
        insert contrNew;

        contrNew.Status = 'Activated';
        update contrNew;

        Position__c posNew = new Position__c();
        posNew.Name = 'Teste Position without position in contract.';
        posNew.Account__c = accNew.Id;

        try {
            Test.startTest();
            insert posNew;
            Test.stopTest();
            
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('Essa conta não possui vagas disponíves em contrato!') ? true : false;
            System.assertEquals(true, result);
            
        }
    }

    @isTest
    static void testBatchPositionCanceled(){

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

        for (Account acc : accList) {

            Contract contrNew = new Contract();
            contrNew.AccountId = acc.Id;
            contrNew.Status = 'New';
            contrNew.ContractTerm = 1;
            contrNew.StartDate = System.today();
            contrNew.PositionMonth__c = 1;
            
            contractList.add(contrNew);
        }

        insert contractList;

        List<Contract> contractListUpActive = new List<Contract>();

        for(Contract contrUpActive : contractList){
            
            contrUpActive.Status = 'Activated';
            contractListUpActive.add(contrUpActive);
        }

        update contractListUpActive;
        //System.debug('Lista contratos ativos: ' + contractListUp.size());

        List<Position__c> posList = new List<Position__c>();

        for(Account acc : accList){
            
            Position__c posNew = new Position__c();          
            posNew.Name = 'Teste position canceled.';
            posNew.Status__c = 'New';
            posNew.Account__c = acc.Id;
            posList.add(posNew);
        }
        insert posList;

        List<Contract> contractListUpClosed = new List<Contract>();

        for(Contract contrUpClosed : contractListUpActive){
            
            contrUpClosed.Status = 'Closed';
            contractListUpClosed.add(contrUpClosed);
        }

        update contractListUpClosed;

        Test.startTest();

        //executa o agendador
        PositionSchedulerHandler positionScheduler = new PositionSchedulerHandler();

        //null pois será simulado a execução do agendador sem fornecer um contexto real de agendamento. 
        //o objetivo principal é verificar o comportamento e os resultados do agendador
        positionScheduler.execute(null);

        Test.stopTest();

        //verifica se os contratos foram atualizados corretamente
        List<Position__c> posListUpdate = [SELECT Id, Status__c FROM Position__c WHERE Status__c = 'Canceled'];

        System.assertEquals(200, posListUpdate.size());


    }


}