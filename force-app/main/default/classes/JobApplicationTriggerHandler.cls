public with sharing class JobApplicationTriggerHandler {
    
    //Construtor vazio
    public JobApplicationTriggerHandler() {

    }

    //Postar no chatter se for aplicado a vaga quando novo registro
    public void postChatterJob(Map<Id, Job_Application__c> jobsOldMap, Map<Id, Job_Application__c> jobsNewMap){

        List<FeedItem> postsList = new List<FeedItem>();

        // Obtenha os IDs das aplicações de vaga
        Set<Id> jobApplicationIds = new Set<Id>(jobsNewMap.keySet());
        jobApplicationIds.addAll(jobsOldMap.keySet());

        // Consulta para obter os campos relacionados Position__r.Name, Position__r.Status__c e Candidate__c
        List<Job_Application__c> jobApplications = [SELECT Id, Name, Position__r.Name, Position__r.Status__c, Candidate__c, Stage__c,
                                                            CreatedDate, CreatedBy.Name
                                                    FROM Job_Application__c 
                                                    WHERE Id IN :jobApplicationIds];

        for (Job_Application__c jobNew : jobApplications) {

            Id jobId = jobNew.Id;

            if (!jobsOldMap.containsKey(jobId)) {

                FeedItem post = new FeedItem();
                post.ParentId = jobNew.Candidate__c;
                post.Body = 'Nova Aplicação a vaga' + '\n\n' +
                            'Aplicação/Nome da vaga: ' + jobNew.Name + '/' + jobNew.Position__r.Name + '\n' +
                            'Status: ' + jobNew.Position__r.Status__c + '\n' +
                            'Fase: ' + jobNew.Stage__c + '\n' +
                            'Vaga criada no dia: ' + jobNew.CreatedDate + ' por ' + jobNew.CreatedBy.Name;
                postsList.add(post); 
                         
            } else if (jobsOldMap.containsKey(jobId) && jobsOldMap.get(jobId) != jobsNewMap.get(jobId)) {

                FeedItem post = new FeedItem();
                post.ParentId = jobNew.Candidate__c;
                post.Body = 'Atualização da vaga aplicada' + '\n\n' +
                            'Aplicação/Nome da vaga: ' + jobNew.Name + '/' + jobNew.Position__r.Name + '\n' +
                            'Status: ' + jobNew.Position__r.Status__c + '\n' +
                            'Fase: ' + jobNew.Stage__c + '\n' +
                            'Vaga atualizada no dia: ' + jobNew.CreatedDate + ' por ' + jobNew.CreatedBy.Name;
                postsList.add(post); 
            }
        }
        insert postsList;
    }
}
