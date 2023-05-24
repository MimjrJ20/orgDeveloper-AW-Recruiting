public with sharing class IntegrationViaCEPCalloutExceptionMock implements HttpCalloutMock {
    
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(500); 
        return res;
    }
}