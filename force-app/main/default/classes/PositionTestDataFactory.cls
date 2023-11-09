@isTest
public with sharing class PositionTestDataFactory {

    //massa para criar UM único 
    public static Position__c createPosition(Boolean doInsert, Id accId, String status, String approval){
        
        Position__c position = new Position__c();
        position.Name = 'Test Position';
        position.Account__c = accId;
        position.Status__c = status;
        position.Approval_Status__c = approval;

        if(doInsert){
            insert position;
        }
        return position;
    }


    //massa para criar uma LISTA contratos como 'New'
    public static List<Position__c> createPositionList(Boolean doInsert, List<Account> lstAcc, String status, String approval){
        
        List<Position__c> lstPositions = new List<Position__c>();

        for (Integer i = 0; i < lstAcc.size(); i++) {
            
            Position__c position = new Position__c();
            position.Name = 'Test Position List ' + i;
            position.Account__c = lstAcc[i].Id;
            position.Status__c = status;
            position.Approval_Status__c = approval;
            lstPositions.add(position);
        }

        if(doInsert){
            insert lstPositions;
        }
        return lstPositions;
    }  
    

}