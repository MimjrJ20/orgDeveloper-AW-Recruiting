public with sharing class PositionsHomeController {
    
    //pegar todas as vagas + o nome da Conta e habilitar para componente Aura
    @AuraEnabled
    public static List<Position__c> getPositionsAndAccount(){
        return [SELECT Id, Name, Job_Description__c, Account__r.Name, Approval_Status__c
                FROM Position__c];
    }
    
}