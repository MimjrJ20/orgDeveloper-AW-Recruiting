@isTest
public with sharing class ContractTest {

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
            system.assertEquals(true, result);
        }
    }

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
            system.assertEquals(true, result);
        }
    }
}