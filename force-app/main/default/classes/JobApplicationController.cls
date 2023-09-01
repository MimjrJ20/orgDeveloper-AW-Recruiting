public with sharing class JobApplicationController {

    @AuraEnabled
    public static Map<String, String> updateJobApplicationProposal(String idJob){

        Job_Application__c job = new Job_Application__c();
        job.Id = idJob;
        job.Status__c = 'Proposal';
        job.Stage__c = 'Generate Proposal';

        Job_Application__c getJob = [SELECT Name FROM Job_Application__c WHERE Id = :idJob LIMIT 1];

        Map<String, String> response = new Map<String, String>();
        response.put('jobName', getJob.Name);

        
        try {
            update job;
            return response;
        } catch (Exception e) {
            throw new AuraHandledException('Error updating job application: ' + e.getMessage());
        }

    }
}