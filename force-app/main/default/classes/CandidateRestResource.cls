@RestResource(urlMapping='/Candidate/*')
global with sharing class CandidateRestResource {

    //método para obter o Candidato
    //Para listar os candidatos, deve ser possível mostrar todos ou filtrar por um desses campos:
    //Email, Candidate Number, Currently Employed ou City (troquei Currently Employed por Current_Employer__c e adicionei por CPF)
    @HttpGet
    global static List<Candidate__c> doGet() {
          
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String candidateInfo = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);

        List<Candidate__c> candidateList = new List<Candidate__c>();

        if (!String.isEmpty(candidateInfo)) {

            candidateList = [
                SELECT Id, Name, City__c, Country__c, Current_Employer__c, Currently_Employed__c,
                    Education__c, Email__c, First_Name__c, Last_Name__c, Legacy_Candidate_Number__c,
                    Mobile__c, Phone__c, State_Province__c, Street_Address_1__c, Street_Address_2__c,
                    Years_of_Experience__c, Zip_Postal_Code__c, CPF__c, Country_List__c,
                    Street_Address_3__c, Should_Redirect__c 
                FROM Candidate__c 
                WHERE 
                    (Id = :candidateInfo) OR 
                    (Email__c = :candidateInfo) OR 
                    (CPF__c = :candidateInfo) OR
                    (Current_Employer__c = :candidateInfo) OR
                    (Name = :candidateInfo) OR 
                    (City__c = :candidateInfo)

            ];

            // if (candidateList.isEmpty()) {
                
            //     String searchParam = '\'%' + candidateInfo.replace(' ', '%') + '%\'';

            //     candidateList = [
            //         SELECT Id, Name, City__c, Country__c, Current_Employer__c, Currently_Employed__c,
            //             Education__c, Email__c, First_Name__c, Last_Name__c, Legacy_Candidate_Number__c,
            //             Mobile__c, Phone__c, State_Province__c, Street_Address_1__c, Street_Address_2__c,
            //             Years_of_Experience__c, Zip_Postal_Code__c, CPF__c, Country_List__c,
            //             Street_Address_3__c, Should_Redirect__c 
            //         FROM Candidate__c 
            //         WHERE (City__c LIKE :searchParam)
            //     ];
            // }

        } else {
            
            // Retorna todos os registros se não houver parâmetros de busca
            candidateList = [
                SELECT Id, Name, City__c, Country__c, Current_Employer__c, Currently_Employed__c,
                    Education__c, Email__c, First_Name__c, Last_Name__c, Legacy_Candidate_Number__c,
                    Mobile__c, Phone__c, State_Province__c, Street_Address_1__c, Street_Address_2__c,
                    Years_of_Experience__c, Zip_Postal_Code__c, CPF__c, Country_List__c,
                    Street_Address_3__c, Should_Redirect__c 
                FROM Candidate__c
            ];
        }

        return candidateList;
          
    }

    //método para inserir um candidato
    @HttpPost
    global static String doPost(String firstName, String lastName, String email, String mobile, String education,
                                String currentEmployer, Integer yearsExperience, String streetAddress1, 
                                String streetAddress2, String streetAddress3, String city, String stateProvince,
                                String zipPostalCode, String cpf, String country, Boolean currentlyEmployed) {

        Candidate__c candidate = new Candidate__c();

        String msg;

        candidate.First_Name__c = firstName;
        candidate.Last_Name__c = lastName;
        candidate.Email__c = email;
        candidate.Mobile__c = mobile;
        candidate.Education__c = education;
        candidate.Current_Employer__c = currentEmployer;
        candidate.Years_of_Experience__c = yearsExperience;
        candidate.Street_Address_1__c = streetAddress1;
        candidate.Street_Address_2__c = streetAddress2;
        candidate.Street_Address_3__c = streetAddress3;
        candidate.City__c = city;
        candidate.State_Province__c = stateProvince;
        candidate.Zip_Postal_Code__c = zipPostalCode;
        candidate.CPF__c = cpf;
        candidate.Country_List__c = country;

        candidate.Should_Redirect__c = false;

        if (currentlyEmployed != null){

            candidate.Currently_Employed__c = currentlyEmployed;

        } else{
            candidate.Currently_Employed__c = false;
        }

        insert candidate;

        msg = 'Candidate inserted. Id: ' + candidate.Id;

        return msg;

    }

    //método para atualizar um candidato
    @HttpPut
    global static String doPut(String candidateId, String firstName, String lastName, String email, String mobile, String education,
                               String currentEmployer, Integer yearsExperience, String streetAddress1, String streetAddress2, String streetAddress3,
                               String city, String stateProvince, String zipPostalCode, String country, String cpf) {

                                
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        candidateId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);

        Candidate__c candidate = [
            SELECT Id, First_Name__c, Last_Name__c, Email__c, Mobile__c, Education__c, Current_Employer__c,
                    Years_of_Experience__c, Street_Address_1__c, Street_Address_2__c, City__c, State_Province__c,
                    Zip_Postal_Code__c, CPF__c, Country_List__c, Street_Address_3__c
            FROM Candidate__c 
            WHERE Id = :candidateId];

        String msg;
        

        if (!String.isBlank(firstName)) {
            candidate.First_Name__c = firstName;
        }
        if (!String.isBlank(lastName)) {
            candidate.Last_Name__c = lastName;
        }
        if (!String.isBlank(email)) {
            candidate.Email__c = email;
        }
        if (!String.isBlank(mobile)) {
            candidate.Mobile__c = mobile;
        }
        if (!String.isBlank(education)) {
            candidate.Education__c = education;
        }
        if (!String.isBlank(currentEmployer)) {
            candidate.Current_Employer__c = currentEmployer;
        }
        if (!String.isBlank(String.valueOf(yearsExperience))) {
            candidate.Years_of_Experience__c = yearsExperience;
        }
        if (!String.isBlank(streetAddress1)) {
            candidate.Street_Address_1__c = streetAddress1;
        }
        if (!String.isBlank(streetAddress2)) {
            candidate.Street_Address_2__c = streetAddress2;
        }
        if (!String.isBlank(streetAddress3)) {
            candidate.Street_Address_3__c = streetAddress3;
        }
        if (!String.isBlank(city)) {
            candidate.City__c = city;
        }
        if (!String.isBlank(stateProvince)) {
            candidate.State_Province__c = stateProvince;
        }
        if (!String.isBlank(zipPostalCode)) {
            candidate.Zip_Postal_Code__c = zipPostalCode;
        }
        if (!String.isBlank(cpf)) {
            candidate.CPF__c = cpf;
        }
        if (!String.isBlank(country)) {
            candidate.Country_List__c = country;
        }

        update candidate;

        msg = 'Candidate updated. Id: ' + candidate.Id;

        return msg;

    }

    //método para excluir um candidato
    @HttpDelete
    global static String doDelete() {

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String candidateInfo = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);

        String msg;

        Candidate__c candidate = [
            SELECT Id, Name 
            FROM Candidate__c 
            WHERE (Id = :candidateInfo) 
                OR (Name = :candidateInfo) 
                OR (CPF__c = :candidateInfo) 
                OR (Email__c = :candidateInfo) 
            LIMIT 1
        ];

        msg = 'Candidate '+ candidate.Name + ' deleted. Id: ' + candidate.Id;

        //Candidate__c candidate = new Candidate__c();
        //candidate.Id = candidateId;
        delete candidate;

        return msg;

    }
}