global with sharing class IntegrationViaCEPCallout {
   
    //Construtor vaizo
    public IntegrationViaCEPCallout() {

    }

    //cria lista e adiciona o valor retornado - apagado pois passamos um cep
    /*public static List<ViaCEP> getCEP(List<String> cepList){
    List<ViaCEP> returnValue = new List<ViaCEP>();
    returnValue.add(sendRequest(cepList.get(0)));

    return returnValue;
    }*/


    @future(callout = true)
    public static void getCEP(String endCEP, Id id){

        ViaCEP returnValue = sendRequest(endCEP);

        Candidate__c cand = new Candidate__c();
        cand.Id = id;
        cand.Street_Address_1__c = returnValue.logradouro;
        cand.Street_Address_2__c = returnValue.bairro;
        cand.State_Province__c = returnValue.uf;
        cand.City__c = returnValue.localidade;
        cand.Country__c = 'Brazil';
        update cand;        
    } 

    //Método http
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

    global class ViaCEP {
    
        //Atributos
        public String cep;
        public String logradouro;
        public String complemento;
        public String bairro;
        public String localidade;
        public String uf;
    }
}