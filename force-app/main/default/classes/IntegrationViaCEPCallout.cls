global with sharing class IntegrationViaCEPCallout {

    //Método que retorna o endereço do cep e armazena
    @AuraEnabled
    @future(callout = true)
    public static void getCEP(String endCEP, Id id){

        ViaCEP returnValue = sendRequest(endCEP);
        List<Candidate__c> candList = [SELECT Id, Zip_Postal_Code__c FROM Candidate__c WHERE Id = :id];
        List<Candidate__c> candToUpdate = new List<Candidate__c>();
        List<Candidate__c> candToUpdateEmpty = new List<Candidate__c>();
        
        //se retornar o endereço
        if (returnValue != null) {
            
            for(Candidate__c cand : candList) {
                cand.Street_Address_1__c = returnValue.logradouro;
                cand.Street_Address_3__c = returnValue.bairro;
                cand.State_Province__c = returnValue.uf;
                cand.City__c = returnValue.localidade;
                candToUpdate.add(cand);
            }
            update candToUpdate;

            //se não retornar nenhum endereço
            if(returnValue.error == 'true'){

                for(Candidate__c candEmpty : candList) {
                    candEmpty.Street_Address_1__c = '';
                    candEmpty.Street_Address_2__c = '';
                    candEmpty.Street_Address_3__c = '';
                    candEmpty.State_Province__c = '';
                    candEmpty.City__c = '';
                    candToUpdateEmpty.add(candEmpty);
                }
                update candToUpdateEmpty;
            }
        } 
    } 

    //método http
    public static ViaCEP sendRequest(String cep){

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://viacep.com.br/ws/' + cep + '/json/');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);

        try {
            Http http = new Http();
            HttpResponse httpRes = http.send(req);
            if(httpRes.getStatusCode() == 200){
                return (ViaCEP) JSON.deserialize(httpRes.getBody(), ViaCEP.class);
            }
        } catch (Exception errorInteg) {
            return null;
        }
        return null;
    }

    //
    global class ViaCEP {
    
        //atributos
        public String cep;
        public String logradouro;
        public String complemento;
        public String bairro;
        public String localidade;
        public String uf;
        public String error;
    }
}