@isTest
public with sharing class JobApplicationTriggerHandlerTest {

    @isTest
    static void testNewJob(){
        
        Candidate__c candNew = new Candidate__c();
        candNew.First_Name__c = 'Teste Candidate New';
        insert candNew;

        Position__c posNew = new Position__c();
        posNew.Name = 'Teste Position New';
        posNew.Approval_Status__c = 'Pending';
        posNew.Status__c = 'New';
        insert posNew;

        Job_Application__c jobNew = new Job_Application__c();
        jobNew.Candidate__c = candNew.Id;
        jobNew.Position__c = posNew.Id;
        jobNew.Status__c = 'Open';
        jobNew.Stage__c = 'New';

        Test.startTest();
        insert jobNew;
        new JobApplicationTriggerHandler().postChatterJob(new Map<Id, Job_Application__c>(), new Map<Id, Job_Application__c>{jobNew.Id => jobNew});
        Test.stopTest();

        // Recupera o post do Chatter
        List<FeedItem> chatterPostsTest = [SELECT Id, Body 
                                            FROM FeedItem 
                                            LIMIT 1];
        Boolean result = chatterPostsTest[0].Body.contains('Nova Aplicação a vaga') ? true : false;
        
        // Compara o body do post do Chatter
        System.assertEquals(true, result);    
    }

    @isTest
    static void testUpJob(){
        
        Candidate__c candNew = new Candidate__c();
        candNew.First_Name__c = 'Teste Candidate Up';
        insert candNew;

        Position__c posNew = new Position__c();
        posNew.Name = 'Teste Position Up';
        posNew.Approval_Status__c = 'Pending';
        posNew.Status__c = 'New';
        insert posNew;

        Job_Application__c jobNew = new Job_Application__c();
        jobNew.Candidate__c = candNew.Id;
        jobNew.Position__c = posNew.Id;
        jobNew.Status__c = 'Open';
        jobNew.Stage__c = 'New';
        insert jobNew;

        jobNew.Status__c = 'Hold';
        jobNew.Stage__c = 'Offer Extended';
        update jobNew;

        Test.startTest();
        new JobApplicationTriggerHandler().postChatterJob(new Map<Id, Job_Application__c>{jobNew.Id => jobNew}, new Map<Id, Job_Application__c>{jobNew.Id => jobNew});
        Test.stopTest();

        // Recupera o post do Chatter
        List<FeedItem> chatterPostsTest = [SELECT Id, Body, CreatedDate
                                            FROM FeedItem];
        Boolean result = chatterPostsTest[1].Body.contains('Atualização da vaga aplicada') ? true : false;
        
        // Compara o body do post do Chatter
        System.assertEquals(true, result);    
    }

    @isTest
    static void testDeleteJob(){

        Candidate__c candNew = new Candidate__c();
        candNew.First_Name__c = 'Teste Candidate Delete';
        insert candNew;

        Position__c posNew = new Position__c();
        posNew.Name = 'Teste Position Delete';
        posNew.Approval_Status__c = 'Pending';
        posNew.Status__c = 'New';
        insert posNew;

        Job_Application__c jobNew = new Job_Application__c();
        jobNew.Candidate__c = candNew.Id;
        jobNew.Position__c = posNew.Id;
        jobNew.Status__c = 'Open';
        jobNew.Stage__c = 'New';
        insert jobNew;

        try {
            Test.startTest();
            delete jobNew;
            Test.stopTest();
            
        } catch (Exception error){
            Boolean result = error.getMessage().contains('Por questão de compliance, após a vaga ser aplicada' +
                                                        + ' nestas condições o registro não pode ser deletado!') ? true : false;
            System.assertEquals(result, true);
        }
    }


}