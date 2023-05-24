public with sharing class IntegrationViaCEPCalloutExceptionMock implements HttpCalloutMock {
    
    // simula uma chamada de HTTP resultando em um erro de código
    //Essa classe de mock é usada para testar como o código se comporta quando ocorre um erro na chamada de integração com o serviço ViaCEP
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(500); 
        return res;
    }
}