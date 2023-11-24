public with sharing class CandidateDAO {

    //pegar candidate por id
    @AuraEnabled
    public static Candidate__c getCandidateById(String id){

        return [
            SELECT Id, Name, City__c, Current_Employer__c, Currently_Employed__c,
            Education__c, Email__c, First_Name__c, Last_Name__c, Legacy_Candidate_Number__c,
            Mobile__c, Phone__c, State_Province__c, Street_Address_1__c, Street_Address_2__c,
            Years_of_Experience__c, Zip_Postal_Code__c, CPF__c, Country_List__c, Street_Address_3__c
            FROM Candidate__c
            WHERE Id = :id LIMIT 1
        ];
    }

    //pegar candidate por cpf
    @AuraEnabled
    public static Candidate__c getCandidateByCPF(String cpf){

        return [
            SELECT Id, Name, City__c, Current_Employer__c, Currently_Employed__c,
            Education__c, Email__c, First_Name__c, Last_Name__c, Legacy_Candidate_Number__c,
            Mobile__c, Phone__c, State_Province__c, Street_Address_1__c, Street_Address_2__c,
            Years_of_Experience__c, Zip_Postal_Code__c, CPF__c, Country_List__c, Street_Address_3__c
            FROM Candidate__c
            WHERE CPF__c = :cpf LIMIT 1
        ];
    }

    //pegar valores de picklist
    @AuraEnabled
    public static List<String> getPicklistValuesCandidate(String fieldApiName) {
        
        List<String> picklistValues = new List<String>();
        
        String objectApiName = 'Candidate__c';
        
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