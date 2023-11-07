@isTest
public with sharing class PositionTestDataFactory {

    //massa para criar UM único 
    public static Position__c createPosition(Boolean doInsert, Id accId, String status, String approval){
        
        Position__c position = new Position__c();
        position.Name = 'Teste Position Post New';
        position.Account__c = accId;
        position.Status__c = status;
        position.Approval_Status__c = approval;


        if(doInsert){
            insert position;
        }
        return position;
    }
}