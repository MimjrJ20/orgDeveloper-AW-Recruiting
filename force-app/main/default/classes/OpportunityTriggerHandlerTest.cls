@isTest
public with sharing class OpportunityTriggerHandlerTest {

    @isTest
    static void testOppInfoWitohut(){
        
        RecordType recordTypeContract = [SELECT Id FROM RecordType WHERE Name = 'Contract' LIMIT 1];

        Account accNew = new Account();
        accNew.Name = 'Teste Conta Opp Contract Without';
        insert accNew;

        Opportunity oppNew = new Opportunity();
        oppNew.RecordTypeId = recordTypeContract.Id;
        oppNew.Name = 'Teste Opp Contract Without';
        oppNew.CloseDate = System.today() + 30 ;
        oppNew.AccountId = accNew.Id;
        oppNew.StageName = 'Prospecting';
        insert oppNew;

        oppNew.StageName = 'Closed Won';

        try {
            Test.startTest();
            update oppNew;
            Test.stopTest();
            
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('Não é possível fechar a oportunidade com os campos: Prazo de Contrato e/ou Início do Contrato em branco!') ? true : false;
            System.assertEquals(true, result);
        }
    }


    @isTest
    static void testOppNewDate(){
        
        RecordType recordTypeContract = [SELECT Id FROM RecordType WHERE Name = 'Contract' LIMIT 1];

        Account accNew = new Account();
        accNew.Name = 'Teste Conta Opp New Date Past';
        insert accNew;

        Opportunity oppNew = new Opportunity();
        oppNew.RecordTypeId = recordTypeContract.Id;
        oppNew.Name = 'Teste Opp New Date Past';
        oppNew.CloseDate = System.today() + 30 ;
        oppNew.StartDate__c = System.today() - 1 ;
        oppNew.AccountId = accNew.Id;
        oppNew.StageName = 'Prospecting';

        try {
            Test.startTest();
            insert oppNew;
            Test.stopTest();
            
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('Não é possível salvar a oportunidade se a data de Início do Contrato estiver no passado!') ? true : false;
            System.assertEquals(true, result);
        }
    }

    @isTest
    static void testOppUpDate(){
        
        RecordType recordTypePosition = [SELECT Id FROM RecordType WHERE Name = 'Contract' LIMIT 1];

        Account accNew = new Account();
        accNew.Name = 'Teste Conta Opp Up Date Past';
        insert accNew;

        Opportunity oppNew = new Opportunity();
        oppNew.RecordTypeId = recordTypePosition.Id;
        oppNew.Name = 'Teste Opp Up Date Past';
        oppNew.CloseDate = System.today() + 30 ;
        oppNew.StartDate__c = System.today() + 1;
        oppNew.AccountId = accNew.Id;
        oppNew.StageName = 'Prospecting';
        insert oppNew;

        oppNew.StartDate__c = System.today() - 1;
        
        try {
            Test.startTest();
            update oppNew;
            Test.stopTest();
            
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('Não é possível salvar a oportunidade se a data de Início do Contrato estiver no passado!') ? true : false;
            System.assertEquals(true, result);
        }
    }

    @isTest
    static void testOppEditWin(){
        
        RecordType recordTypePosition = [SELECT Id FROM RecordType WHERE Name = 'Position' LIMIT 1];

        Account accNew = new Account();
        accNew.Name = 'Teste Conta Opp Edit Win';
        insert accNew;

        Opportunity oppNew = new Opportunity();
        oppNew.RecordTypeId = recordTypePosition.Id;
        oppNew.Name = 'Teste Opp Opp Edit Win';
        oppNew.CloseDate = System.today() + 30 ;
        oppNew.AccountId = accNew.Id;
        oppNew.StageName = 'Prospecting';
        insert oppNew;

        oppNew.StageName = 'Closed Won';
        update oppNew;

        oppNew.StageName = 'Qualification';

        try {
            Test.startTest();
            update oppNew;
            Test.stopTest();
            
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('Não pode alterar a oportunidade depois de fechada!') ? true : false;
            System.assertEquals(true, result);
        }
    }

    @isTest
    static void testOppEditLost(){
        
        RecordType recordTypePosition = [SELECT Id FROM RecordType WHERE Name = 'Position' LIMIT 1];

        Account accNew = new Account();
        accNew.Name = 'Teste Conta Opp Edit Lost';
        insert accNew;

        Opportunity oppNew = new Opportunity();
        oppNew.RecordTypeId = recordTypePosition.Id;
        oppNew.Name = 'Teste Opp Opp Edit Lost';
        oppNew.CloseDate = System.today() + 30 ;
        oppNew.AccountId = accNew.Id;
        oppNew.StageName = 'Prospecting';
        insert oppNew;

        oppNew.StageName = 'Closed Lost';
        update oppNew;

        oppNew.StageName = 'Qualification';

        try {
            Test.startTest();
            update oppNew;
            Test.stopTest();
            
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('Não pode alterar a oportunidade depois de fechada!') ? true : false;
            System.assertEquals(true, result);
        }
    }

    @isTest
    static void testOppEditWinMore(){
        
        RecordType recordTypePosition = [SELECT Id FROM RecordType WHERE Name = 'Position' LIMIT 1];

        Account accNew = new Account();
        accNew.Name = 'Teste Conta Opp Edit Win';
        insert accNew;

        Opportunity oppNew = new Opportunity();
        oppNew.RecordTypeId = recordTypePosition.Id;
        oppNew.Name = 'Teste Opp Opp Edit Win';
        oppNew.CloseDate = System.today() + 30 ;
        oppNew.AccountId = accNew.Id;
        oppNew.StageName = 'Prospecting';
        insert oppNew;

        oppNew.StageName = 'Closed Won';
        update oppNew;

        oppNew.StageName = 'Qualification';
        oppNew.Description = 'Teste descrição';

        try {
            Test.startTest();
            update oppNew;
            Test.stopTest();
            
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('Não pode alterar a oportunidade depois de fechada!') ? true : false;
            System.assertEquals(true, result);
        }
    }

    @isTest
    static void testOppEditLostMore(){
        
        RecordType recordTypePosition = [SELECT Id FROM RecordType WHERE Name = 'Position' LIMIT 1];

        Account accNew = new Account();
        accNew.Name = 'Teste Conta Opp Edit Lost';
        insert accNew;

        Opportunity oppNew = new Opportunity();
        oppNew.RecordTypeId = recordTypePosition.Id;
        oppNew.Name = 'Teste Opp Opp Edit Lost';
        oppNew.CloseDate = System.today() + 30 ;
        oppNew.AccountId = accNew.Id;
        oppNew.StageName = 'Prospecting';
        insert oppNew;

        oppNew.StageName = 'Closed Lost';
        update oppNew;

        oppNew.StageName = 'Qualification';
        oppNew.Description = 'Teste descrição';

        try {
            Test.startTest();
            update oppNew;
            Test.stopTest();
            
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('Não pode alterar a oportunidade depois de fechada!') ? true : false;
            System.assertEquals(true, result);
        }
    }
}