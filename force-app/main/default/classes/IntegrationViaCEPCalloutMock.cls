global with sharing class IntegrationViaCEPCalloutMock implements HttpCalloutMock{

    //mock da chamada
    //Essa classe de mock é usada para testar como o código se comporta quando ocorre um erro na chamada de integração com o serviço ViaCEP
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