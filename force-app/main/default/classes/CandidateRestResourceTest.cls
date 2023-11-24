@IsTest
private class CandidateRestResourceTest {

    //
    @TestSetup
    static void createTestData(){
        CandidateTestDataFactory.createCandidateList(true, 10);
    }

    //
    @IsTest
    static void testDoGetWithId() {
        Candidate__c candidate = [SELECT Id FROM Candidate__c LIMIT 1];
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Candidate/'+candidate.Id;
        RestContext.request = req;
        RestContext.response = res;
        List<Candidate__c> lstCandidates = CandidateRestResource.doGet();
        Assert.areNotEqual(0, lstCandidates.size(), 'Should retrieve candidate');
        Assert.isTrue(lstCandidates.size() == 1, 'Should retrieve candidate with the given ID');
        Test.stopTest();
    }

    //
    @IsTest
    static void testDoGetWithNoParameters() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Candidate/';
        RestContext.request = req;
        RestContext.response = res;
        List<Candidate__c> lstCandidates = CandidateRestResource.doGet();
        Assert.areNotEqual(0, lstCandidates.size(), 'Should retrieve candidates');
        Assert.isTrue(lstCandidates.size() == 10, 'Should retrieve all candidates');
        Test.stopTest();
    }

    //
    @IsTest
    static void testDoPost() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Candidate/';
        RestContext.request = req;
        RestContext.response = res;
        String candidate = CandidateRestResource.doPost('John', 'Doe', 'john@example.com', '53824205', 'Graduate', 'ABC Corp', 5, '123 Street', 'Apt 45', '', 'Los Angeles', 'California', '90001', '53824205050', 'US - United States', true);
        Assert.areNotEqual(null, candidate, 'Candidate insertion should return a valid message');
        Assert.areEqual(true, candidate.contains('Candidate inserted'));
        Test.stopTest();
    }

    //
    @IsTest
    static void testDoPut() {
        Candidate__c candidate = [SELECT Id FROM Candidate__c LIMIT 1];
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Candidate/'+candidate.Id;
        RestContext.request = req;
        RestContext.response = res;
        String candidateToUpdate = CandidateRestResource.doPut(candidate.Id, 'John', 'Doe', 'john@example.com', '1111111', 'Test', 'Test', '10', 'Test', 'Test', 'Test', 'Test', 'Test', '11111', 'US - United States', '23698186039');
        Candidate__c candidateUpdated = [SELECT Id, First_Name__c FROM Candidate__c WHERE Id = :candidate.Id LIMIT 1 ];
        Assert.areNotEqual(null, candidateToUpdate, 'Candidate update should return a valid message');
        Assert.areEqual(true, candidateToUpdate.contains('Candidate updated'));
        Assert.areEqual('John', candidateUpdated.First_Name__c);
        Test.stopTest();
    }

    //
    @IsTest
    static void testDoDelete() {
        Candidate__c candidate = [SELECT Id FROM Candidate__c LIMIT 1];
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Candidate/'+candidate.Id;
        RestContext.request = req;
        RestContext.response = res;
        String candidateToDelete = CandidateRestResource.doDelete();
        Assert.areNotEqual(null, candidateToDelete, 'Candidate deletion should return a valid message');
        Assert.areEqual(true, candidateToDelete.contains('deleted'));
        Test.stopTest();
    }
}