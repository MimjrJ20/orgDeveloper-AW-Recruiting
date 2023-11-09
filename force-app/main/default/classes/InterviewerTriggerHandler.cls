public with sharing class InterviewerTriggerHandler {
    
    //-----------------------------------------------------------------
    public InterviewerTriggerHandler() {
    }

    //-----------------------------------------------------------------
    //método para incluir o Candidato no registro Interview (assim aparece a lista relacionada de entrevista mas não precisa preencher pois no Job Application já tem essa informação)
    public void updateInterviewerCandidate(List<Interviewer__c> lstInterviewrs) {
        
        Set<Id> lstJobIds = new Set<Id>();
        for (Interviewer__c interviewer : lstInterviewrs) {
            if (interviewer.Job_Application__c != null) {
                lstJobIds.add(interviewer.Job_Application__c);
            }
        }

        Map<Id, Job_Application__c> mapJobs = new Map<Id, Job_Application__c>(
            [SELECT Id, Candidate__c 
            FROM Job_Application__c 
            WHERE Id IN :lstJobIds]
        );

        for (Interviewer__c interviewer : lstInterviewrs) {
            if (interviewer.Job_Application__c != null) {
                Job_Application__c job = mapJobs.get(interviewer.Job_Application__c);
                if (job != null) {
                    interviewer.Candidate__c = job.Candidate__c;
                }
            }
        }
    }

    //-----------------------------------------------------------------
    //método que verifica a data e hora de agora
    public void verifyInterviewerDate(List<Interviewer__c> lstInterviewrs) {
        
        for (Interviewer__c interviewer : lstInterviewrs) {
            
            Datetime dateNow = Datetime.now();
            Integer offset = UserInfo.getTimezone().getOffset(dateNow);
            Datetime dateLocal = dateNow.addSeconds(offset/1000);

            if (interviewer.Date_Time_Interview__c <= dateLocal) {
                interviewer.Date_Time_Interview__c.addError('The interview date and time must be greater than the current moment. Now: ' + dateLocal);
            }
        }
    }

    //-----------------------------------------------------------------
    //método para atualizar o registro de Job Application para entrevista completada
    public void updateInterviewerJob(List<Interviewer__c> lstInterviewrs) {
        
        Set<Id> lstJobIds = new Set<Id>();
        List<Job_Application__c> lstJobsToUpdate = new  List<Job_Application__c>();

        for (Interviewer__c interviewer : lstInterviewrs) {
            if (interviewer.Job_Application__c != null) {
                lstJobIds.add(interviewer.Job_Application__c);
            }
        }

        Map<Id, Job_Application__c> mapJobs = new Map<Id, Job_Application__c>(
            [SELECT Id, Candidate__c 
            FROM Job_Application__c 
            WHERE Id IN :lstJobIds]
        );

        for (Interviewer__c interviewer : lstInterviewrs) {
            if (interviewer.Job_Application__c != null) {
                if (interviewer.Status__c == 'Completed') {                    
                    Job_Application__c job = mapJobs.get(interviewer.Job_Application__c);
                    if (job != null) {
                        job.Status__c = 'Open';
                        job.Stage__c = 'Interviews Completed';
                        lstJobsToUpdate.add(job);
                    }
                }                
            }
        }

        if (lstJobsToUpdate != null & lstJobsToUpdate.size() > 0) {
            update lstJobsToUpdate;
        }
    } 

    //-----------------------------------------------------------------
    //método para verificar se a entrevista criada possui o mesmo candidato e data/hora   
    public void updateInterviewerEquals(List<Interviewer__c> lstInterviewrs) {

        //lista de date/time
        List<Datetime> lstInterviewrsDate = new List<Datetime>();
        for (Interviewer__c interviewr : lstInterviewrs) {
            lstInterviewrsDate.add(interviewr.Date_Time_Interview__c);
        }

        //query com as interviews com todas as interview
        List<Interviewer__c> lstInterviewrsSameDate = [
            SELECT Id, Date_Time_Interview__c, Candidate__c
            FROM Interviewer__c
            WHERE Date_Time_Interview__c IN :lstInterviewrsDate AND Id NOT IN :lstInterviewrs
        ];

        //for para ver se o candidato é o mesmo
        if (lstInterviewrsSameDate != null && lstInterviewrsSameDate.size() > 0) {
            for (Interviewer__c interviewr : lstInterviewrsSameDate) {
                for (Interviewer__c interviewrCurrent : lstInterviewrs) {
                    if (interviewr.Date_Time_Interview__c == interviewrCurrent.Date_Time_Interview__c) {
                        
                        if (interviewr.Candidate__c == interviewrCurrent.Candidate__c) {
                            interviewrCurrent.addError('There is already an interview with the same Date and Time for this candidate.');
                        }
                    }
                }
            }
        }
    }   
}
