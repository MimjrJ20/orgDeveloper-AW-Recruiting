public with sharing class JobApplicationTriggerHandler {
    
    // Construtor vazio
    public JobApplicationTriggerHandler() {

    }

    //-----------------------------------------------------------------

    // Postar no chatter se for aplicada a vaga quando novo registro
    public void postChatterJob(Map<Id, Job_Application__c> jobsOldMap, Map<Id, Job_Application__c> jobsNewMap) {

        List<FeedItem> postsList = new List<FeedItem>();

        // Obter os IDs das aplicações de vaga
        Set<Id> jobApplicationIds = new Set<Id>(jobsNewMap.keySet());

        //verifica se oldMap é vazio ou nulo, se ambos verdadeiros significa que existem registro antingo e adiciona na nova lista
        if (jobsOldMap != null && !jobsOldMap.isEmpty()) {
            jobApplicationIds.addAll(jobsOldMap.keySet());
        }

        // Consulta para obter os campos relacionados Position__r.Name, Position__r.Status__c e Candidate__c
        List<Job_Application__c> jobApplications = [
            SELECT Id, Name, Position__c, Status__c, Position__r.Name, Position__r.Status__c, Candidate__c, Stage__c,
                CreatedDate, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name
            FROM Job_Application__c
            WHERE Id IN :jobApplicationIds];

        for(Job_Application__c jobNew : jobApplications) {

            Id jobId = jobNew.Id;

            if (jobsOldMap == null || !jobsOldMap.containsKey(jobId)) {

                FeedItem post = new FeedItem();

                post.ParentId = jobNew.Candidate__c;
                post.Body = 'Nova Aplicação a vaga' + '\n\n' +
                            'Aplicação/Nome da vaga: ' + jobNew.Name + '/' + jobNew.Position__r.Name + '\n' +
                            'Status: ' + jobNew.Status__c + '\n' +
                            'Fase: ' + jobNew.Stage__c + '\n' +
                            'Vaga criada no dia: ' + jobNew.CreatedDate.format('dd/MM/yyyy') + ' por ' + jobNew.CreatedBy.Name;

                postsList.add(post);

            } else if (jobsOldMap.containsKey(jobId) && jobsOldMap.get(jobId) != jobsNewMap.get(jobId)) {

                FeedItem post = new FeedItem();

                post.ParentId = jobNew.Candidate__c;
                post.Body = 'Atualização da vaga aplicada' + '\n\n' +
                            'Aplicação/Nome da vaga: ' + jobNew.Name + '/' + jobNew.Position__r.Name + '\n' +
                            'Status: ' + jobNew.Status__c + '\n' +
                            'Fase: ' + jobNew.Stage__c + '\n' +
                            'Vaga atualizada no dia: ' + jobNew.LastModifiedDate.format('dd/MM/yyyy') + ' por ' + jobNew.LastModifiedBy.Name;

                postsList.add(post);
            }
        }

        if (!postsList.isEmpty()) {
            insert postsList;
        }
    }


    //-----------------------------------------------------------------

    public void jobNotDelete(List<Job_Application__c> jobsList){

        for(Job_Application__c job : jobsList){
            
            if (!jobsList.isEmpty()) {
                    job.addError('Por questão de compliance, após a vaga ser aplicada nestas condições o registro não pode ser deletado!');            
            }
        }
    }


    //-----------------------------------------------------------------
    //-----------------------------------------------------------------

    public void jobStartDateDays(List<Job_Application__c> jobsList){

        for(Job_Application__c job : jobsList){
            
            if (!jobsList.isEmpty()) {

                Integer days = System.today().daysBetween(job.Expected_Start_Date__c);

                if (days <= 30) {

                    job.addError('Devido ao fluxo de contratação, a data de início deve ser MAIOR que 30 dias a partir de hoje!' + 
                                 + ' Diferença inserida: ' + days + ' dias.');
                }
         
            }
        }
    }

}