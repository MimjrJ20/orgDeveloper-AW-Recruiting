public with sharing class JobApplicationDAO {

    //search por id
    public static Job_Application__c searchJobById(String idJob){

        return [SELECT Status__c, Stage__c, Position__c, Legacy_Job_Application_Number__c, Candidate__c, Candidate__r.Name, Id, Name 
                FROM Job_Application__c
                WHERE Id = :idJob];
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

        return [SELECT Status__c, Position__c, Legacy_Job_Application_Number__c, Candidate__c, Candidate__r.Name, Id, Name, Position__r.Name 
                FROM Job_Application__c
                WHERE Candidate__c = :idCandidate AND Stage__c = :interview
                ORDER BY Name];
    }
}