global with sharing class IntegrationViaCEPCalloutMock implements HttpCalloutMock{

    //mock da chamada
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

