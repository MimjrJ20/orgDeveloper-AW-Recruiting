@isTest
public with sharing class CandidateTest {

    //testar novo candidato e o CPF se não for numérico
    @isTest
    static void testNewCandNumberCPF(){

        Candidate__c candNew = new Candidate__c();
        candNew.First_Name__c = 'Teste';
        candNew.CPF__c = 'teste';

        try{
            Test.startTest();
            insert candNew;
            Test.stopTest();

        } catch (Exception error){
            Boolean result = error.getMessage().contains('O CPF só pode haver números. Sem letras, pontos e traços!') ? true : false;
            System.assertEquals(true, result);
        }
    }

    //testar candidato atualizado e o CPF se não for numérico
    @isTest
    static void testUpCandNumberCPF(){
        
        Candidate__c candNew = new Candidate__c();
        candNew.First_Name__c = 'Teste';
        candNew.CPF__c = '12345678909';

        insert candNew;

        candNew.CPF__c = 'teste';

        try{
            Test.startTest();
            update candNew;
            Test.stopTest();

        } catch (Exception error){
            Boolean result = error.getMessage().contains('O CPF só pode haver números. Sem letras, pontos e traços!') ? true : false;
            System.assertEquals(true, result);
        }
    }

    //testar novo candidato e CPF se for menor que 11
    @isTest
    static void testNewCandMinCPF(){

        Candidate__c candNew = new Candidate__c();
        candNew.First_Name__c = 'Teste';
        candNew.CPF__c = '12345';

        try{
            Test.startTest();
            insert candNew;
            Test.stopTest();

        } catch (Exception error){
            Boolean result = error.getMessage().contains('O CPF precisa ter 11 números!') ? true : false;
            System.assertEquals(true, result);
        }
    }

    //testar candidato atualizado e CPF se for menor que 11
    @isTest
    static void testUpCandMinCPF(){

        Candidate__c candNew = new Candidate__c();
        candNew.First_Name__c = 'Teste';
        candNew.CPF__c = '22344123156';

        insert candNew;

        candNew.CPF__c = '12345';

        try{
            Test.startTest();
            update candNew;
            Test.stopTest();

        } catch (Exception error){
            Boolean result = error.getMessage().contains('O CPF precisa ter 11 números!') ? true : false;
            System.assertEquals(true, result);
        }
    }


    //testar novo candidato com o CPF inválido
    @isTest
    static void testNewCandValidCPF(){

        Candidate__c candNew = new Candidate__c();
        candNew.First_Name__c = 'Teste';
        candNew.CPF__c = '12345678999';

        try{
            Test.startTest();
            insert candNew;
            Test.stopTest();

        } catch (Exception error){
            Boolean result = error.getMessage().contains('Este CPF não é válido!') ? true : false;
            System.assertEquals(true, result);
        }
    }

    //testar atualizar o candidato com o CPF inválido
    @isTest
    static void testUpCandValidCPF(){
        
        Candidate__c candNew = new Candidate__c();
        candNew.First_Name__c = 'Teste';
        candNew.CPF__c = '29588469970';

        insert candNew;

        candNew.CPF__c = '12345678999';

        try{
            Test.startTest();
            update candNew;
            Test.stopTest();

        } catch(Exception error) {
            Boolean result = error.getMessage().contains('Este CPF não é válido!') ? true : false;
            System.assertEquals(true, result);
        }
    }

    //testar novo candidato com CPF com único número
    @isTest
    static void testNewCandOnlyCPF(){

        Candidate__c candNew = new Candidate__c();
        candNew.First_Name__c = 'Teste';
        candNew.CPF__c = '11111111111';

        try {
            Test.startTest();
            insert candNew;
            Test.stopTest();

        } catch (Exception error) {
            Boolean result = error.getMessage().contains('O CPF não pode ser composto por UM único número!') ? true : false;
            System.assertEquals(true, result);
        }
        
    }

    //testar atualizar candidato com CPF com único número
    @isTest
    static void testUpCandOnlyCPF(){

        Candidate__c candNew = new Candidate__c();
        candNew.First_Name__c = 'Teste';
        candNew.CPF__c = '12345678909';

        insert candNew;

        candNew.CPF__c = '11111111111';     

        try {
            Test.startTest();
            update candNew;
            Test.stopTest();

        } catch (Exception error) {
            Boolean result = error.getMessage().contains('O CPF não pode ser composto por UM único número!') ? true : false;
            System.assertEquals(true, result);
        }
        
    }

    //testar novo candidato com cep menor que 8
    @isTest
    static void testNewNumCEP(){

        Candidate__c candNew = new Candidate__c();
        candNew.First_Name__c = 'Teste';
        candNew.Country_List__c = 'BR - Brazil';
        candNew.Zip_Postal_Code__c = '1234567';

        try {
            Test.startTest();
            insert candNew;
            Test.stopTest();

        } catch (Exception error) {
            Boolean result = error.getMessage().contains('O CEP para o país Brasil deve conter 8 dígitos!') ? true : false;
            System.assertEquals(true, result);
        }
    }

    //testar atualizar o candidato com cep menor que 8
    @isTest
    static void testUpNumCEP(){

        Candidate__c candNew = new Candidate__c();
        candNew.First_Name__c = 'Teste';
        candNew.Zip_Postal_Code__c = '04821010';

        insert candNew;

        candNew.Country_List__c = 'BR - Brazil';
        candNew.Zip_Postal_Code__c = '1234567';

        try {
            Test.startTest();
            update candNew;
            Test.stopTest();

        } catch (Exception error) {
            Boolean result = error.getMessage().contains('O CEP para o país Brasil deve conter 8 dígitos!') ? true : false;
            System.assertEquals(true, result);
            
        }
    }

    //testar novo candidato com o cep com letras
    @isTest
    static void testNewLetterCEP(){

        Candidate__c candNew = new Candidate__c();
        candNew.First_Name__c = 'Teste';
        candNew.Zip_Postal_Code__c = 'aaaaaaa1';

        try {
            Test.startTest();
            insert candNew;
            Test.stopTest();

        } catch (Exception error) {
            Boolean result = error.getMessage().contains('No CEP não pode ser inserido letra ou ponto!') ? true : false;
            System.assertEquals(true, result);
        }
    }

    //testar atualizar novo candidato com cep com letras
    @isTest
    static void testUpLetterCEP(){

        Candidate__c candNew = new Candidate__c();
        candNew.First_Name__c = 'Teste';
        candNew.Zip_Postal_Code__c = '04821010';

        insert candNew;

        candNew.Zip_Postal_Code__c = 'aaaaaaa1';

        try {
            Test.startTest();
            update candNew;
            Test.stopTest();

        } catch (Exception error) {
            Boolean result = error.getMessage().contains('No CEP não pode ser inserido letra ou ponto!') ? true : false;
            System.assertEquals(true, result);
        }
    }

    //testar a chamada da Integração do viaCEP com cep definido
    @isTest
    static void testSetAddresViaCepOldNotEqualsNew(){

        //instanciar objeto para registro novo e antigo
        Candidate__c candNew = new Candidate__c();
        Candidate__c candOld = new Candidate__c();

        candNew.First_Name__c = 'Teste';
        candNew.Country_List__c = 'BR - Brazil';
        candNew.Zip_Postal_Code__c = '04821010';

        //inicio ao teste
        Test.startTest();

        IntegrationViaCEPCallout.ViaCEP viaCEP = new IntegrationViaCEPCallout.ViaCEP();

        //configura um mock para substitui a chamada do http real
        Test.setMock(HttpCalloutMock.class, new IntegrationViaCEPCalloutMock(viaCEP));

        insert candNew;

        candOld.Zip_Postal_Code__c = '04821390';

        Map<Id, Candidate__c> candidateListNew = new Map<Id, Candidate__c>{candNew.Id => candNew};
        Map<Id, Candidate__c> candidateListOld = new Map<Id, Candidate__c>{candNew.Id => candOld};//associa o ID do objeto candNew ao objeto candOld
        
        CandidateTriggerHandler handler = new CandidateTriggerHandler();

        handler.setAddressViaCEP(candidateListOld, candidateListNew);

        Test.stopTest();
        //fim do teste
        
        System.assertNotEquals(candOld.Zip_Postal_Code__c, candNew.Zip_Postal_Code__c);   
    }

    //testar a chamada da Integração do viaCEP com cep iguais
    @isTest
    static void testSetAddresViaCepOldEqualsNew(){

        //instanciar objeto para registro novo e antigo
        Candidate__c candNew = new Candidate__c();
        Candidate__c candOld = new Candidate__c();

        candNew.First_Name__c = 'Teste';
        candNew.Country_List__c = 'BR - Brazil';
        candNew.Zip_Postal_Code__c = '04821010';

        //inicio ao teste
        Test.startTest();

        IntegrationViaCEPCallout.ViaCEP viaCEP = new IntegrationViaCEPCallout.ViaCEP();

        //configura um mock para substitui a chamada do http real
        Test.setMock(HttpCalloutMock.class, new IntegrationViaCEPCalloutMock(viaCEP));

        insert candNew;

        candOld.Zip_Postal_Code__c = '04821010';

        Map<Id, Candidate__c> candidateListNew = new Map<Id, Candidate__c>{candNew.Id => candNew};
        Map<Id, Candidate__c> candidateListOld = new Map<Id, Candidate__c>{candNew.Id => candOld};//associa o ID do objeto candNew ao objeto candOld
        
        CandidateTriggerHandler handler = new CandidateTriggerHandler();

        handler.setAddressViaCEP(candidateListOld, candidateListNew);

        Test.stopTest();
        //fim do teste
        
        System.assertEquals(candOld.Zip_Postal_Code__c, candNew.Zip_Postal_Code__c);   
    }
    
    //testar a chamada da Integração do viaCEP com cep vazio
    @isTest
    static void testSetAddresViaCepOldNull(){

        //instanciar objeto para registro novo e antigo
        Candidate__c candNew = new Candidate__c();
        Candidate__c candOld = new Candidate__c();

        candNew.First_Name__c = 'Teste';
        candNew.Country_List__c = 'BR - Brazil';
        candNew.Zip_Postal_Code__c = '04821010';

        //inicio ao teste
        Test.startTest();

        IntegrationViaCEPCallout.ViaCEP viaCEP = new IntegrationViaCEPCallout.ViaCEP();

        //configura um mock para substitui a chamada do http real
        Test.setMock(HttpCalloutMock.class, new IntegrationViaCEPCalloutMock(viaCEP));

        insert candNew;

        candOld.Zip_Postal_Code__c = null;

        Map<Id, Candidate__c> candidateListNew = new Map<Id, Candidate__c>{candNew.Id => candNew};
        Map<Id, Candidate__c> candidateListOld = new Map<Id, Candidate__c>{candNew.Id => candOld};//associa o ID do objeto candNew ao objeto candOld
        
        CandidateTriggerHandler handler = new CandidateTriggerHandler();

        handler.setAddressViaCEP(candidateListOld, candidateListNew);

        Test.stopTest();
        //fim do teste
        
        System.assertEquals(candOld.Zip_Postal_Code__c, null);   
    }

    //testar a chamada da Integração do viaCEP com cep vazio e Address 1 definido
    @isTest
    static void testSetAddresViaCepNullOne(){

        Candidate__c candNew = new Candidate__c();
        candNew.First_Name__c = 'Teste';
        candNew.Zip_Postal_Code__c = null;
        candNew.Street_Address_1__c = 'Teste address 1';

        try {
            Test.startTest();
            insert candNew;
            Test.stopTest();

        } catch (Exception error) {
            Boolean result = error.getMessage().contains('Só digite o \'Addres 1\' se houver CEP!') ? true : false;
            System.assertEquals(true, result);
        }
    }

    //testar a chamada da Integração do viaCEP com cep vazio e Address 2 definido
    @isTest
    static void testSetAddresViaCepNullTwo(){

        Candidate__c candNew = new Candidate__c();
        candNew.First_Name__c = 'Teste';
        candNew.Zip_Postal_Code__c = null;
        candNew.Street_Address_2__c = 'Teste address 2';

        try {
            Test.startTest();
            insert candNew;
            Test.stopTest();

        } catch (Exception error) {
            Boolean result = error.getMessage().contains('Só digite o \'Addres 2\' se houver CEP!') ? true : false;
            System.assertEquals(true, result);
        }
    }

    //testar a chamada da Integração do viaCEP com cep vazio e Address 2 definido
    @isTest
    static void testSetAddresViaCepNullThree(){

        Candidate__c candNew = new Candidate__c();
        candNew.First_Name__c = 'Teste';
        candNew.Zip_Postal_Code__c = null;
        candNew.Street_Address_3__c = 'Teste address 3';

        try {
            Test.startTest();
            insert candNew;
            Test.stopTest();

        } catch (Exception error) {
            Boolean result = error.getMessage().contains('Só digite o \'Addres 3\' se houver CEP!') ? true : false;
            System.assertEquals(true, result);
        }
    }
    
}