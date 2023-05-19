public with sharing class JobApplicationTriggerHandler {
    
    //Construtor vazio
    public JobApplicationTriggerHandler() {

    }

    //Postar no chatter se for aplicado a vaga quando novo registro
    public void postChatterNewJob(List<Job_Application__c> ids){

        List<FeedItem> postsList = new List<FeedItem>();

        for (Job_Application__c job : [SELECT 
                                        Id, 
                                        Name,
                                        Stage__c,
                                        Candidate__c, 
                                        Position__c, 
                                        Candidate__r.First_Name__c, 
                                        Position__r.Name,
                                        Position__r.Status__c
                                      FROM Job_Application__c WHERE Id = :ids]
        ) {
            FeedItem post = new FeedItem();
            post.ParentId = job.Candidate__c;
            post.Body = 'Nova Aplicação a vaga' + '\n\n' +
                        + 'Nome Candidato: ' + job.Candidate__r.First_Name__c + '\n' + 
                        + 'Aplicação/Nome da vaga: ' + job.Name + '/' + job.Position__r.Name + '\n' +
                        + 'Status: ' + job.Position__r.Status__c + '\n' +
                        + 'Fase: ' + job.Stage__c;

            postsList.add(post);
        }
        insert postsList;
    }

    //Postar no chatter se for aplicado a vaga quando atualizado
    public void postChatterUpJob(List<Job_Application__c> ids){

        List<FeedItem> postsList = new List<FeedItem>();

        for (Job_Application__c job : [SELECT 
                                        Id, 
                                        Name,
                                        Stage__c,
                                        Candidate__c, 
                                        Position__c, 
                                        Candidate__r.First_Name__c, 
                                        Position__r.Name,
                                        Position__r.Status__c
                                      FROM Job_Application__c WHERE Id = :ids]
        ) {

            FeedItem post = new FeedItem();
            post.ParentId = job.Candidate__c;
            post.Body = 'Atualização da vaga aplicada' + '\n\n' +
                        + 'Nome Candidato: ' + job.Candidate__r.First_Name__c + '\n' + 
                        + 'Aplicação/Nome da vaga: ' + job.Name + '/' + job.Position__r.Name + '\n' +
                        + 'Status: ' + job.Position__r.Status__c + '\n' +
                        + 'Fase: ' + job.Stage__c;

            postsList.add(post);
        }
        insert postsList;
    }
}