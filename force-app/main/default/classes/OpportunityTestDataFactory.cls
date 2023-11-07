@isTest
public with sharing class OpportunityTestDataFactory {

    //
    public static Opportunity createOpportunitySample(Boolean doInsert, String typeName, Date closeDate, Id accId, String stage){

        RecordType recordType = [SELECT Id FROM RecordType WHERE Name =:typeName LIMIT 1];

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.RecordTypeId = recordType.Id;
        opp.CloseDate = closeDate;
        opp.AccountId = accId;
        opp.StageName = stage;

        if(doInsert){
            insert opp;
        }
        return opp;
    }

    //
    public static Opportunity createOpportunitySampleContract(Boolean doInsert, Date closeDate, Date startDate, Id accId, String stage){

        RecordType recordType = [SELECT Id FROM RecordType WHERE Name = 'Contract' LIMIT 1];

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.RecordTypeId = recordType.Id;
        opp.CloseDate = closeDate;
        opp.StartDate__c = startDate;
        opp.AccountId = accId;
        opp.StageName = stage;

        if(doInsert){
            insert opp;
        }
        return opp;
    }

    //
    public static List<Opportunity> createOpportunitySampleList(Boolean doInsert, Integer numOpp){
        
        List<Opportunity> lstOpp = new List<Opportunity>();

        for(Integer i = 1; i <= numOpp; i++) {
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opportunity ' + i;
            lstOpp.add(opp);
		}

        if(doInsert){
            insert lstOpp;
        }
        return lstOpp;
    }

    //
    public static Opportunity updateOpportunityStatus(Boolean doUpdate, Opportunity opp, String stage){
        
        Opportunity oppUpdate = opp;
        oppUpdate.StageName = stage;
        
        if(doUpdate){
            update oppUpdate;
        }
        return oppUpdate;
    }    

    //
    public static Opportunity updateOpportunityDate(Boolean doUpdate, Opportunity opp, Date startDate){
    
        Opportunity oppUpdate = opp;
        oppUpdate.StartDate__c = startDate;
        
        if(doUpdate){
            update oppUpdate;
        }
        return oppUpdate;
    }  

    //
    public static Opportunity updateOpportunityContract(Boolean doUpdate, Opportunity opp, String stage, Date startDate, Integer posMonth, Integer term){
        
        Opportunity oppUpdate = opp;
        oppUpdate.StageName = stage;
        oppUpdate.StartDate__c = startDate;
        oppUpdate.PositionMonth__c = posMonth;
        oppUpdate.Term__c = term;
        
        if(doUpdate){
            update oppUpdate;
        }
        return oppUpdate;
    }    
}