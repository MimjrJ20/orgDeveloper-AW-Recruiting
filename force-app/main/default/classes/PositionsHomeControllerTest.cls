@isTest
public with sharing class PositionsHomeControllerTest {
    
    @isTest
    static void testGetPositions(){
        
        Position__c[] listPositions = [SELECT Id, Name, Job_Description__c FROM Position__c];
        
        for(Integer i = 1;i <= 20; i++){
            
            Account accNew = new Account();
            accNew.Name = 'Teste Conta ' + i;
            insert accNew;
            
            Contract contrNew = new Contract();
            contrNew.AccountId = accNew.Id;
            contrNew.Status = 'New';
            contrNew.ContractTerm = 1;
            contrNew.StartDate = System.today();
            contrNew.PositionMonth__c = 1;
            insert contrNew;
			contrNew.Status = 'Activated';
            update contrNew;
            
            Position__c posNew = new Position__c();
            posNew.Name = 'Teste Position ' + i;
            posNew.Job_Description__c = 'Description Position ' + i;
            posNew.Account__c = accNew.Id;
            
            listPositions.add(posNew); 
        }
      
        insert listPositions;
                
		Boolean result = PositionsHomeController.getPositions().isEmpty() ? false : true;
        System.assertEquals(true, result);
    }
    
    @isTest
    static void testGetPositionsAndAccount(){
        
        Position__c[] listPositions = [SELECT Id, Name, Job_Description__c, Account__r.Name, Approval_Status__c FROM Position__c];
        
        for(Integer i = 1;i <= 20; i++){
            
            Account accNew = new Account();
            accNew.Name = 'Teste Conta ' + i;
            insert accNew;
            
            Contract contrNew = new Contract();
            contrNew.AccountId = accNew.Id;
            contrNew.Status = 'New';
            contrNew.ContractTerm = 1;
            contrNew.StartDate = System.today();
            contrNew.PositionMonth__c = 1;
            insert contrNew;
			contrNew.Status = 'Activated';
            update contrNew;
            
            Position__c posNew = new Position__c();
            posNew.Name = 'Teste Position ' + i;
            posNew.Job_Description__c = 'Description Position ' + i;
            posNew.Account__c = accNew.Id;
            
            listPositions.add(posNew); 
        }
        
        insert listPositions;
        
        //System.debug(PositionsHomeController.getPositionsAndAccount());
		Boolean result = PositionsHomeController.getPositionsAndAccount().isEmpty() ? false : true;
        System.assertEquals(true, result);
    }


}