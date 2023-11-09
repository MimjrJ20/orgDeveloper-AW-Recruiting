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
    
    //massa para criar LISTA  
    public static List<Candidate__c> createCandidateList(Boolean doInsert, Integer numCandidate){

        List<Candidate__c> lstCandidates = new List<Candidate__c>();

        for (Integer i = 0; i < numCandidate; i++) {
            Candidate__c candidate = new Candidate__c();
            candidate.First_Name__c = 'Test Candidate ' + i;    
            lstCandidates.add(candidate);
        }

        if(doInsert){
            insert lstCandidates;
        }
        return lstCandidates;
    }
}