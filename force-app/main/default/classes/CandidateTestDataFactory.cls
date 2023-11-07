@isTest
public with sharing class CandidateTestDataFactory {

    //massa para criar UM único 
    public static Candidate__c createCandidateSample(Boolean doInsert){

        Candidate__c candidate = new Candidate__c();
        candidate.First_Name__c = 'Test Candidate';

        if(doInsert){
            insert candidate;
        }
        return candidate;
    }
    
}