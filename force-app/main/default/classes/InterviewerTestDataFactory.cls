@isTest
public with sharing class InterviewerTestDataFactory {

    //massa para criar UM único 
    public static Interviewer__c createInterviewer(Boolean doInsert, Id candId, Id jobId, Datetime valueDateTime){
    
        Interviewer__c interviewer  = new Interviewer__c();
        interviewer.Candidate__c = candId;
        interviewer.Job_Application__c = jobId;
        interviewer.Date_Time_Interview__c = valueDateTime;

        if(doInsert){
            insert interviewer;
        }
        return interviewer;
    }  

    //massa para criar uma LISTA 
    public static List<Interviewer__c> createInterviewerList(Boolean doInsert, List<Job_Application__c> lstJobs, Datetime valueDateTime){
        
        List<Interviewer__c> lstInterviewers = new List<Interviewer__c>();

        for (Job_Application__c job : lstJobs) {
            Interviewer__c interviewer = new Interviewer__c();
            interviewer.Job_Application__c = job.Id;
            interviewer.Date_Time_Interview__c = valueDateTime;
            lstInterviewers.add(interviewer);
        }

        if(doInsert){
            insert lstInterviewers;
        }
        return lstInterviewers;
    }

    //massa para atualizar UM único 
    public static Interviewer__c updateInterviewer(Boolean doUpdate, Interviewer__c interviewer){
        
        Interviewer__c interviewerUpdate = interviewer;

        if(doUpdate){
            update interviewerUpdate;
        }
        return interviewerUpdate;
    }
    
    //massa para atualizar uma LISTA 
    public static List<Interviewer__c> updateInterviewerDate(Boolean doUpdate, List<Interviewer__c> lstInterviewers, Datetime valueDateTime){

        List<Interviewer__c> lstInterviewersUpdated = new List<Interviewer__c>();
        
        for (Interviewer__c interviewer : lstInterviewers) {
            interviewer.Date_Time_Interview__c = valueDateTime;
            lstInterviewersUpdated.add(interviewer);
        }

        if(doUpdate){
            update lstInterviewersUpdated;
        }
        return lstInterviewersUpdated;
    }

    //massa para atualizar uma LISTA 
    public static List<Interviewer__c> updateInterviewerStatus(Boolean doUpdate, List<Interviewer__c> lstInterviewers, String status){

        List<Interviewer__c> lstInterviewersUpdated = new List<Interviewer__c>();
        
        for (Interviewer__c interviewer : lstInterviewers) {
            interviewer.Status__c = status;
            lstInterviewersUpdated.add(interviewer);
        }

        if(doUpdate){
            update lstInterviewersUpdated;
        }
        return lstInterviewersUpdated;
    }
}