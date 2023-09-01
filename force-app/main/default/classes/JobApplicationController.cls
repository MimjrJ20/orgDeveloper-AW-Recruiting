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
            String deadline = String.valueOf(getJob.Expected_Start_Date__c.addMonths(1));     
            
            String candidateName = getJob.Candidate__r.First_Name__c + (getJob.Candidate__r.Last_Name__c != null ? (' ' + getJob.Candidate__r.Last_Name__c) : '');
                    
            Map<String, String> response = new Map<String, String>();
            response.put('jobName', getJob.Name);
            response.put('city', getJob.Candidate__r.City__c);
            response.put('state', getJob.Candidate__r.State_Province__c);
            response.put('country', getJob.Candidate__r.Country_List__c);
            response.put('candidateNumber', getJob.Candidate__r.Name);
            response.put('candidateName', candidateName);
            response.put('positionName', getJob.Position__r.Name);
            response.put('accountName', getJob.Position__r.Account__r.Name);
            response.put('description', getJob.Position__r.Job_Description__c);
            response.put('skills', getJob.Candidate_Skills__c);
            response.put('department', getJob.Position__r.Department__c);
            response.put('salary', salary);
            response.put('manager', manager);
            response.put('startDate', startDate);
            response.put('deadline', deadline);
            
            try {
                update job;
                return response;
            } catch (Exception e) {
                throw new AuraHandledException('Error updating job application: ' + e.getMessage());
            }

        }
    }