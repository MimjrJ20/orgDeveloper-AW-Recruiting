public with sharing class JobApplicationDAO {

    //search por id
    public static Job_Application__c searchJobById(String idJob){

        return [SELECT Id, Name, Status__c
                FROM Job_Application__c
                WHERE Id = :idJob
                LIMIT 1];
    }

    //search por id com detalhes
    public static Job_Application__c searchJobByIdDetails(String idJob){

        return [SELECT 
                    Id, Name, Status__c, Legacy_Job_Application_Number__c, Expected_Start_Date__c, Salary__c, Candidate_Skills__c,
                    Position__c, Position__r.Name, Position__r.Account__r.Name, Position__r.Skills_Required__c, Position__r.Job_Description__c, Position__r.Department__c, Position__r.Hiring_Manager__c, Position__r.Hiring_Manager__r.FirstName, Position__r.Hiring_Manager__r.LastName,
                    Candidate__c, Candidate__r.Name, Candidate__r.City__c, Candidate__r.State_Province__c, Candidate__r.Country_List__c, Candidate__r.Email__c, Candidate__r.First_Name__c, Candidate__r.Last_Name__c 
                FROM Job_Application__c
                WHERE Id = :idJob
                LIMIT 1];
    }

    //search por id do candidato
    public static List<Job_Application__c> searchJobByIdCandidate(String idCandidate){

        return [SELECT Status__c, Stage__c, Position__c, Legacy_Job_Application_Number__c, Candidate__c, Candidate__r.Name, Id, Name 
                FROM Job_Application__c
                WHERE Candidate__c = :idCandidate];
    }

    //search por nome do candidato
    public static List<Job_Application__c> searchJobByNameCandidate(String nameCandidate){

        return [SELECT Status__c, Stage__c, Position__c, Legacy_Job_Application_Number__c, Candidate__c, Candidate__r.Name, Id, Name 
                FROM Job_Application__c
                WHERE Candidate__r.Name = :nameCandidate];
    }

    @AuraEnabled
    //search por id do candidato com as entrevistas finalizadas
    public static List<Job_Application__c> searchJobByIdCandidateAndInterview(String idCandidate){

        String interview = 'Interviews Completed';

        return [SELECT 
                    Id, Name, Status__c, Stage__c, Position__c, Position__r.Name
                FROM Job_Application__c
                WHERE Candidate__c = :idCandidate AND Stage__c = :interview
                ORDER BY Name];
    }
}