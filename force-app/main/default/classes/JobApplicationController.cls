public with sharing class JobApplicationController {

    @AuraEnabled
    public static Map<String, String> updateJobApplicationProposal(String idJob){

        Job_Application__c job = new Job_Application__c();
        job.Id = idJob;
        job.Status__c = 'Proposal';
        job.Stage__c = 'Generate Proposal';

        Job_Application__c getJob = JobApplicationDAO.searchJobByIdDetails(idJob);

        String salary = String.valueOf(getJob.Salary__c);
        String manager = (getJob.Position__r.Hiring_Manager__r.FirstName != null ? getJob.Position__r.Hiring_Manager__r.FirstName : 'Manager') + ' ' 
                            + getJob.Position__r.Hiring_Manager__r.LastName;

        String startDate = String.valueOf(getJob.Expected_Start_Date__c);
        String deadline = getJob.Expected_Start_Date__c != null ? (String.valueOf(getJob.Expected_Start_Date__c.addMonths(1))) : 'TBD';     
        
        String candidateName = getJob.Candidate__r.First_Name__c + (getJob.Candidate__r.Last_Name__c != null ? (' ' + getJob.Candidate__r.Last_Name__c) : '');
                
        Map<String, String> response = new Map<String, String>();
        response.put('jobName', setDefaultValue(getJob.Name));
        response.put('city', setDefaultValue(getJob.Candidate__r.City__c));
        response.put('state', setDefaultValue(getJob.Candidate__r.State_Province__c));
        response.put('country', setDefaultValue(getJob.Candidate__r.Country_List__c));
        response.put('candidateNumber', setDefaultValue(getJob.Candidate__r.Name));
        response.put('candidateName', setDefaultValue(candidateName));
        response.put('positionName', setDefaultValue(getJob.Position__r.Name));
        response.put('accountName', setDefaultValue(getJob.Position__r.Account__r.Name));
        response.put('description', setDefaultValue(getJob.Position__r.Job_Description__c));
        response.put('skills', setDefaultValue(getJob.Candidate_Skills__c));
        response.put('department', setDefaultValue(getJob.Position__r.Department__c));
        response.put('salary', setDefaultValue(salary));
        response.put('manager', setDefaultValue(manager));
        response.put('startDate', setDefaultValue(startDate));
        response.put('deadline', deadline);
        
        try {
            update job;
            return response;
        } catch (Exception e) {
            throw new AuraHandledException('Error updating job application: ' + e.getMessage());
        }
    }

    private static String setDefaultValue(String value) {
        return String.isNotBlank(value) ? value : 'TBD';
    }
}
