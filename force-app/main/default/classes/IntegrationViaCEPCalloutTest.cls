@isTest
public with sharing class IntegrationViaCEPCalloutTest {

    @isTest
    static void testGetCEPNotError(){

        //inserir candidato com CEP
        Candidate__c cand = new Candidate__c();
        cand.First_Name__c = 'Teste Callout';
        cand.Zip_Postal_Code__c = '00000001';

        insert cand;
        
        //chama o método getCEP
        Test.startTest();
        IntegrationViaCEPCallout.getCEP(cand.Zip_Postal_Code__c, cand.Id);
        Test.stopTest();

        //verifica se o endereço foi carregado corretamente
        Candidate__c upCand = [SELECT Id, Street_Address_1__c, Street_Address_3__c, State_Province__c, City__c
                                FROM Candidate__c 
                                WHERE Id = :cand.Id];

        System.assertEquals('Rua Teste', upCand.Street_Address_1__c);
        System.assertEquals('Bairro Teste', upCand.Street_Address_3__c);
        System.assertEquals('Estado Teste', upCand.State_Province__c);
        System.assertEquals('Cidade Teste', upCand.City__c);   
    }

    @isTest
    static void testGetCEPError(){

        //inserir candidato com CEP
        Candidate__c cand = new Candidate__c();
        cand.First_Name__c = 'Teste Callout';
        cand.Zip_Postal_Code__c = '00000000';

        insert cand;
        
        //chama o método getCEP
        Test.startTest();

        IntegrationViaCEPCallout.ViaCEP errorViaCEP = new IntegrationViaCEPCallout.ViaCEP();
        errorViaCEP.error = 'true';

        Test.setMock(HttpCalloutMock.class, new IntegrationViaCEPCalloutMock(errorViaCEP));
        IntegrationViaCEPCallout.getCEP(cand.Zip_Postal_Code__c, cand.Id);


        Test.stopTest();

        //verifica se o endereço foi carregado corretamente
        Candidate__c upCand = [SELECT Id, Street_Address_1__c, Street_Address_3__c, State_Province__c, City__c
                                FROM Candidate__c 
                                WHERE Id = :cand.Id];

        System.assertEquals('', upCand.Street_Address_1__c);
        System.assertEquals('', upCand.Street_Address_3__c);
        System.assertEquals('', upCand.State_Province__c);
        System.assertEquals('', upCand.City__c);   
    }

    @isTest
    static void testSendRequest(){

        //instaniando um objeto do tipo viaCEP
        IntegrationViaCEPCallout.ViaCEP viaCEP = new IntegrationViaCEPCallout.ViaCEP();

        viaCEP.cep = '00000001';
        viaCEP.logradouro = 'Rua Teste';
        viaCEP.bairro = 'Bairro Teste';
        viaCEP.uf = 'Estado Teste';
        viaCEP.localidade = 'Cidade Teste';
        viaCEP.error = 'false';

        //mock da chamada
        Test.setMock(HttpCalloutMock.class, new IntegrationViaCEPCalloutMock(viaCEP));


        //chama o método
        IntegrationViaCEPCallout.ViaCEP result = IntegrationViaCEPCallout.sendRequest('00000001');


        //verifica se o resultado é o mesmo
        System.assertEquals(viaCEP, result);
    }

    @isTest
    static void testSendRequestException(){

        // Chama o método sendRequest com um CEP inválido
        Test.startTest();
        IntegrationViaCEPCallout.ViaCEP result = IntegrationViaCEPCallout.sendRequest('');
        Test.stopTest();

        // Verifica se o resultado é nulo
        System.assertEquals(null, result);
    }

    @isTest
    static void testSendRequestNullException(){

        // Configuração do mock para simular uma exceção durante a chamada HTTP
        Test.setMock(HttpCalloutMock.class, new IntegrationViaCEPCalloutExceptionMock());

        // Chama o método sendRequest com um CEP inválido
        Test.startTest();
        IntegrationViaCEPCallout.ViaCEP result = IntegrationViaCEPCallout.sendRequest('');
        Test.stopTest();

        // Verifica se o resultado é nulo
        System.assertEquals(null, result);
    }


}