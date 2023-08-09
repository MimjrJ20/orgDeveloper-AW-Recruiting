@RestResource(urlMapping='/Candidate/*')
global with sharing class CandidateRestResource {

    //método para obter o Candidato
    //
    //Para listar os candidatos, deve ser possível mostrar todos ou filtrar por um desses campos:
    //Email, Candidate Number, Currently Employed ou City (troquei Currently Employed por Current_Employer__c e adicionei por CPF)
    @HttpGet
    global static List<Candidate__c> doGet() {
          
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String candidateInfo = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
  
        //se for passado um dos parametros na url retorna UM registo
        if (!String.isEmpty(candidateInfo)) {

            List<Candidate__c> candidate = 
            [SELECT Id, Name, City__c, Country__c, Current_Employer__c, Currently_Employed__c,
                    Education__c, Email__c, First_Name__c, Last_Name__c, Legacy_Candidate_Number__c,
                    Mobile__c, Phone__c, State_Province__c, Street_Address_1__c, Street_Address_2__c,
                    Years_of_Experience__c, Zip_Postal_Code__c, CPF__c, Country_List__c,
                    Street_Address_3__c, Should_Redirect__c 
                FROM Candidate__c 
                WHERE 
                    (Id = :candidateInfo) OR 
                    (Email__c = :candidateInfo) OR 
                    (Name = :candidateInfo) OR 
                    (Current_Employer__c = :candidateInfo) OR 
                    (City__c = :candidateInfo) OR 
                    (CPF__c = :candidateInfo)
            ];

            return candidate;

        //se NÂO passar parametors retorn uma LISTA   
        } else {

            List<Candidate__c> listCandidate = 
            [SELECT Id, Name, City__c, Country__c, Current_Employer__c, Currently_Employed__c,
                    Education__c, Email__c, First_Name__c, Last_Name__c, Legacy_Candidate_Number__c,
                    Mobile__c, Phone__c, State_Province__c, Street_Address_1__c, Street_Address_2__c,
                    Years_of_Experience__c, Zip_Postal_Code__c, CPF__c, Country_List__c,
                    Street_Address_3__c, Should_Redirect__c 
                FROM Candidate__c
            ];
            return listCandidate;
        }
          
    }

    //método para inserir um candidato
    @HttpPost
    global static String doPost(String firstName, String lastName, String email, String mobile, String education,
                                String currentEmployer, Integer yearsOfExperience, String streetAddress1, 
                                String streetAddress2, String streetAddress3, String city, String stateProvince,
                                String zipPostalCode, String cpf, String country) {

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
        candidate.CPF__c = cpf;
        candidate.Country_List__c = country;
        candidate.Street_Address_3__c = streetAddress3;

        candidate.Should_Redirect__c = false;
        candidate.Currently_Employed__c = false;

        insert candidate;

        return candidate.Id;
    }

    //método para atualizar um candidato
    @HttpPut
    global static String doPut(String candidateId, String firstName, String lastName, String email, String mobile, String education,
                               String currentEmployer, Integer yearsOfExperience, String streetAddress1, String streetAddress2, String streetAddress3,
                               String city, String stateProvince, String zipPostalCode, String country, String cpf) {

                                
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
        candidate.CPF__c = cpf;
        candidate.Country_List__c = country;
        candidate.Street_Address_3__c = streetAddress3;

        candidate.Should_Redirect__c = false;
        candidate.Currently_Employed__c = false;
        
        upsert candidate;

        return candidate.Id;
    }

    //método para excluir um candidato
    @HttpDelete
    global static String doDelete() {

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String candidateInfo = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);

        Candidate__c candidate = [SELECT Id, Name FROM Candidate__c WHERE (Id = :candidateInfo) OR (Name = :candidateInfo) OR (CPF__c = :candidateInfo) LIMIT 1];
        String msg = 'Candidate '+ candidate.Name + ' deleted.';

        //Candidate__c candidate = new Candidate__c();
        //candidate.Id = candidateId;
        delete candidate;

        return msg;
    }
}