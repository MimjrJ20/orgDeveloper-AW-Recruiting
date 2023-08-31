public with sharing class JobApplicationController {

    @AuraEnabled
    public static void updateJobApplicationProposal(String idJob){

        Job_Application__c job = new Job_Application__c();
        job.Id = idJob;
        job.Status__c = 'Proposal';
        job.Stage__c = 'Generate Proposal';
        
        try {
            update job;
        } catch (Exception e) {
            throw new AuraHandledException('Error updating job application: ' + e.getMessage());
        }

    }
}