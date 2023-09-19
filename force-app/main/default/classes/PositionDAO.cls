public with sharing class PositionDAO {

    //pegar lista de positions disponíveis com status igual a New ou Open
    @AuraEnabled
    public static List<Position__c> getPositionsAvailable(){

        return [
                    SELECT Id, Account__c, Account__r.Name, Approval_Status__c, Department__c, Education__c, 
                            Hiring_Manager__c, Job_Description__c, Legacy_Position_Number__c, Location__c, 
                            Name, OwnerId, Owner.Name, Pay_Grade__c, Salary_Range__c, Skills_Required__c, 
                            Status__c, VagaContrato__c 
                    FROM Position__c 
                    WHERE Status__c IN ('New','Open')
                ];
    }
}