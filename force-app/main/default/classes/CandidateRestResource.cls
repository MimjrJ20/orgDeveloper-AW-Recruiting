@RestResource(urlMapping='/Candidate/*')
global with sharing class CandidateRestResource {

    //método para obter o Candidato
    //https://hr-mjr-dev-ed.develop.my.salesforce.com/services/data/v58.0/services/apexrest/Candidate/
    @HttpGet
    global static List<Candidate__c> doGet() {
          
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String candidateId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
  
        if (!String.isEmpty(candidateId)) {

            List<Candidate__c> candidate = [SELECT Id, Name, City__c, Country__c, Current_Employer__c, Currently_Employed__c,
                                      Education__c, Email__c, First_Name__c, Last_Name__c, Legacy_Candidate_Number__c,
                                      Mobile__c, Phone__c, State_Province__c, Street_Address_1__c, Street_Address_2__c,
                                      Years_of_Experience__c, Zip_Postal_Code__c, CPF__c, Country_List__c,
                                      Street_Address_3__c, Should_Redirect__c 
                                      FROM Candidate__c 
                                      WHERE Id = :candidateId];

            return candidate;
        } else {

            List<Candidate__c> candidates = [SELECT Id, Name, City__c, Country__c, Current_Employer__c, Currently_Employed__c,
                                             Education__c, Email__c, First_Name__c, Last_Name__c, Legacy_Candidate_Number__c,
                                             Mobile__c, Phone__c, State_Province__c, Street_Address_1__c, Street_Address_2__c,
                                             Years_of_Experience__c, Zip_Postal_Code__c, CPF__c, Country_List__c,
                                             Street_Address_3__c, Should_Redirect__c 
                                             FROM Candidate__c];
            return candidates;
        }
          
    }

    //método para inserir um candidato
    @HttpPost
    global static String doPost(String firstName, String lastName, String email, String mobile, String education,
                                String currentEmployer, Integer yearsOfExperience, String streetAddress1, 
                                String streetAddress2, String city, String stateProvince,
                                String zipPostalCode, String country, String cpf, String countryList,
                                String streetAddress3) {

        Candidate__c candidate = new Candidate__c();

        candidate.First_Name__c = firstName;
        candidate.Last_Name__c = lastName;
        candidate.Email__c = email;
        candidate.Mobile__c = mobile;
        candidate.Education__c = education;
        candidate.Current_Employer__c = currentEmployer;
        candidate.Years_of_Experience__c = yearsOfExperience;
        candidate.Street_Address_1__c = streetAddress1;
        candidate.Street_Address_2__c = streetAddress2;
        candidate.City__c = city;
        candidate.State_Province__c = stateProvince;
        candidate.Zip_Postal_Code__c = zipPostalCode;
        candidate.Country__c = country;
        candidate.CPF__c = cpf;
        candidate.Country_List__c = countryList;
        candidate.Street_Address_3__c = streetAddress3;

        candidate.Should_Redirect__c = false;
        candidate.Currently_Employed__c = false;

        insert candidate;
        return candidate.Id;
    }

    //método para atualizar um candidato
    @HttpPut
    global static String doPut(String candidateId, String firstName, String lastName, String email, String mobile, String education,
                               String currentEmployer, Integer yearsOfExperience, String streetAddress1, String streetAddress2, 
                               String city, String stateProvince, String zipPostalCode, String country, String cpf, String countryList,
                               String streetAddress3) {

                                
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        candidateId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Candidate__c candidate = new Candidate__c();

        candidate.Id = candidateId;
        candidate.First_Name__c = firstName;
        candidate.Last_Name__c = lastName;
        candidate.Email__c = email;
        candidate.Mobile__c = mobile;
        candidate.Education__c = education;
        candidate.Current_Employer__c = currentEmployer;
        candidate.Years_of_Experience__c = yearsOfExperience;
        candidate.Street_Address_1__c = streetAddress1;
        candidate.Street_Address_2__c = streetAddress2;
        candidate.City__c = city;
        candidate.State_Province__c = stateProvince;
        candidate.Zip_Postal_Code__c = zipPostalCode;
        candidate.Country__c = country;
        candidate.CPF__c = cpf;
        candidate.Country_List__c = countryList;
        candidate.Street_Address_3__c = streetAddress3;

        candidate.Should_Redirect__c = false;
        candidate.Currently_Employed__c = false;
        
        update candidate;
        return candidate.Id;
    }

    //método para excluir um candidato
    @HttpDelete
    global static String doDelete() {

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String candidateId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Candidate__c candidate = new Candidate__c();
        candidate.Id = candidateId;
        
        delete candidate;
        return 'Candidate deleted.';
    }
}