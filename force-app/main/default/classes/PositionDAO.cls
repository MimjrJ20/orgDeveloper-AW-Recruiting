public with sharing class PositionDAO {

    //pegar lista de positions disponíveis com status igual a New ou Open
    @AuraEnabled
    public static List<Position__c> getPositionsAvailableNotFilter(){

        Set<String> statusValues = new Set<String> {'New', 'Open'};

        return [
                    SELECT Id, Account__c, Account__r.Name, Approval_Status__c, Department__c, Education__c, 
                            Hiring_Manager__c, Job_Description__c, Legacy_Position_Number__c, Location__c, 
                            Name, OwnerId, Owner.Name, Pay_Grade__c, Salary_Range__c, Skills_Required__c, 
                            Status__c, VagaContrato__c 
                    FROM Position__c 
                    WHERE Status__c IN :statusValues
                ];
    }

    //pegar lista de positions disponíveis com status igual a New ou Open
    @AuraEnabled
    public static List<Position__c> getPositionsAvailable(String searchTerm, String selectedStatus, String selectedOwner, Boolean profileHumanResource, String idUser){
    
        Set<String> statusValues = new Set<String> {'New', 'Open'};
    
        String query = 'SELECT Id, CreatedDate, LastModifiedDate, Account__c, Account__r.Name, Approval_Status__c, Department__c, Education__c, Hiring_Manager__c, Hiring_Manager__r.Name, Hiring_Manager__r.FirstName, Job_Description__c, Legacy_Position_Number__c, Location__c, Name, OwnerId, Owner.Name, Pay_Grade__c, Salary_Range__c, Skills_Required__c, Status__c, VagaContrato__c ' +
                        'FROM Position__c ' +
                        'WHERE Status__c IN :statusValues';
    
        if (profileHumanResource) {
            if (!String.isBlank(searchTerm)) {
                searchTerm = '%' + searchTerm + '%'; 
                query += ' AND (Name LIKE :searchTerm OR Account__r.Name LIKE :searchTerm)';
            }
    
            if (selectedStatus != 'All') {
                query += ' AND Status__c = :selectedStatus';
            }
    
            if (idUser != null) {
                query += ' AND OwnerId = :idUser';
            }
        } else {
            
            if (!String.isBlank(searchTerm)) {
                searchTerm = '%' + searchTerm + '%'; 
                query += ' AND (Name LIKE :searchTerm OR Account__r.Name LIKE :searchTerm)';
            }
    
            if (selectedStatus != 'All') {
                query += ' AND Status__c = :selectedStatus';
            }
    
            if (selectedOwner != 'All') {
                query += ' AND OwnerId = :selectedOwner';
            }
        }
        
        return Database.query(query);
    }

    //pegar valores de picklist
    @AuraEnabled
    public static List<String> getPicklistValues(String fieldApiName) {
        
        List<String> picklistValues = new List<String>();
        
        String objectApiName = 'Position__c';
        

        Schema.DescribeFieldResult fieldDescribe = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldApiName).getDescribe();
        
        if (fieldDescribe.getType() == Schema.DisplayType.Picklist || fieldDescribe.getType() == Schema.DisplayType.MultiPicklist) {

            List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
            
            for (Schema.PicklistEntry entry : picklistEntries) {
                picklistValues.add(entry.getValue());
            }
        }
        
        return picklistValues;
    }
    
}