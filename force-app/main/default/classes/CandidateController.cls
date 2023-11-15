public with sharing class CandidateController {
  //
  @AuraEnabled
  public static Candidate__c createCandidate(
    String cpf,
    String firstName,
    String lastName,
    String email,
    String country,
    String cep
  ) {
    Candidate__c candidate = new Candidate__c();
    candidate.CPF__c = cpf;
    candidate.First_Name__c = firstName;
    candidate.Last_Name__c = lastName;
    candidate.Email__c = email;
    candidate.Country_List__c = country;
    candidate.Zip_Postal_Code__c = cep;

    insert candidate;

    return candidate;
  }
}
