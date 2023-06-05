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
            System.debug(error.getMessage());
            System.assertEquals(true, result);
            
        }
    }


}