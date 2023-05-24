@isTest
public with sharing class IntegrationViaCEPCalloutTest {

    @isTest
    static void testGetCEP(){

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

        System.equals('Rua Teste', upCand.Street_Address_1__c);
        System.equals('Bairro Teste', upCand.Street_Address_3__c);
        System.equals('Estado Teste', upCand.State_Province__c);
        System.equals('Cidade Teste', upCand.City__c);
        
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
        System.equals(viaCEP, result);
    }

    //mock da chamada
    private class IntegrationViaCEPCalloutMock implements HttpCalloutMock{

        private IntegrationViaCEPCallout.ViaCEP viaCEP;

        public IntegrationViaCEPCalloutMock(IntegrationViaCEPCallout.ViaCEP viaCEP){
            this.viaCEP = viaCEP;
        }

        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(JSON.serialize(this.viaCEP));

            return res;
        }
    }


}