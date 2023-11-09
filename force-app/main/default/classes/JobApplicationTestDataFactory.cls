@isTest
public with sharing class JobApplicationTestDataFactory {

    //massa para criar UM único 
    public static Job_Application__c createJobApplication(Boolean doInsert, Id candId, Id posId, String status, String stage){
        
        Job_Application__c job = new Job_Application__c();
        job.Candidate__c = candId;
        job.Position__c = posId;
        job.Status__c = status;
        job.Stage__c = stage;

        if(doInsert){
            insert job;
        }
        return job;
    }

    //massa para criar LISTA 
    public static List<Job_Application__c> createJobApplicationList(Boolean doInsert, List<Candidate__c> lstCandidates, Id posId, String status, String stage){
        
        List<Job_Application__c> lstJobs = new List<Job_Application__c>();

        for (Candidate__c candidate : lstCandidates) {

            Job_Application__c job = new Job_Application__c();
            job.Candidate__c = candidate.Id;
            job.Position__c = posId;
            job.Status__c = status;
            job.Stage__c = stage;
            lstJobs.add(job);
        }

        if(doInsert){
            insert lstJobs;
        }
        return lstJobs;
    }

    //massa para atualizar UM único 
    public static Job_Application__c updateJobApplication(Boolean doUpdate, Job_Application__c job, String status, String stage){
        
        Job_Application__c jobUpdated = job;
        jobUpdated.Status__c = status;
        jobUpdated.Stage__c = stage;

        if(doUpdate){
            update jobUpdated;
        }
        return jobUpdated;
    }
    
    //massa para atualizar UM único job 'StartDate'
    public static Job_Application__c updateJobApplicationDate(Boolean doUpdate, Job_Application__c job, Date startDate){
    
        Job_Application__c jobUpdated = job;
        jobUpdated.Expected_Start_Date__c = startDate;

        if(doUpdate){
            update jobUpdated;
        }
        return jobUpdated;
    }   

    //massa para deletar UM único 
    public static void deleteJobApplication(Boolean doDelete, Job_Application__c job){

        if(doDelete){
            delete job;
        }
    }  
}