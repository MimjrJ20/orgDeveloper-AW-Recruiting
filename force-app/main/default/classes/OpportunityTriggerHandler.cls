public with sharing class OpportunityTriggerHandler {
    
    //construtor vazio
    public OpportunityTriggerHandler() {

    }

    //--------------------------------------------------------------------------
    //método para criar contrato
    public void oppWinCreateContract(List<Opportunity> oppList, Map<Id, Opportunity> oppMap) {

        List<Contract> contractNewList = new List<Contract>();
        List<Opportunity> oppUpdateList = new List<Opportunity>();

        Map<Id, Contract> contractMap = new Map<Id, Contract>(); 

        RecordType recordTypeContract = [SELECT Id FROM RecordType WHERE Name = 'Contract' LIMIT 1];

        for(Opportunity opp : oppList) {

            if (opp.StageName == 'Closed Won' && opp.RecordTypeId == recordTypeContract.Id) {

                Contract contractNew = new Contract();
                contractNew.Status = 'New';
                contractNew.AccountId = opp.AccountId;
                contractNew.StartDate = opp.StartDate__c;
                contractNew.PositionMonth__c = opp.PositionMonth__c;
                contractNew.ContractTerm = Integer.valueOf(opp.Term__c);
                contractNew.Description = 'Contract created from an opportunity.'+ '\n' +
                                            + 'Opportunity: ' + opp.Name;

                contractNewList.add(contractNew);
                contractMap.put(opp.Id, contractNew);            
            }
        }

        if (!contractNewList.isEmpty()) {
            insert contractNewList;
        }

        for(Opportunity opp : oppList) {

            if (contractMap.containsKey(opp.Id)) {
                Contract contractOpp = contractMap.get(opp.Id);
                opp.ContractId = contractOpp.Id; 
                oppUpdateList.add(opp);
            }
        }
    }
    
    //--------------------------------------------------------------------------
    //método para impedir que fecha a oportunidade
    public void oppWinContractWithout(List<Opportunity> oppList){

        RecordType recordTypeContract = [SELECT Id FROM RecordType WHERE Name = 'Contract' LIMIT 1];
        for(Opportunity opp : oppList){
            if(opp.StageName == 'Closed Won' && opp.RecordTypeId == recordTypeContract.Id) {
                if(opp.Term__c == null || opp.StartDate__c == null){
                    opp.addError('You cannot close the opportunity with the Contract Term and/or Start Date fields blank!');
                }
            }
        }
    }

    //--------------------------------------------------------------------------
    //método para impedir que a data seja data passada
    public void oppDatePast(List<Opportunity> oppList){
        for(Opportunity opp : oppList){
            if(opp.StartDate__c < System.today()){
                opp.StartDate__c.addError('You cannot save the opportunity if the Contract Start Date is in the past!');
            }
        }
    }

    //--------------------------------------------------------------------------
    //método para barrar alteração quando a oportunidade estiver fechada
    public void oppClosedNotEdit(Map<Id, Opportunity> oppListOld, Map<Id, Opportunity> oppListNew){

        for(Id oppId : oppListNew.keySet()){

            Opportunity oppNew = oppListNew.get(oppId);

            if(oppListOld != null){

                Opportunity oppOld = oppListOld.get(oppId);

                if(oppOld != null){
                    
                    if(
                        (oppOld.StageName == 'Closed Won' || oppOld.StageName == 'Closed Lost')
                    ||  (oppOld.StageName == 'Closed Won' && oppNew.StageName != 'Closed Won')
                    ||  (oppOld.StageName == 'Closed Lost' && oppNew.StageName != 'Closed Lost')){

                        if(!oppListOld.equals(oppListNew)){
                            
                            oppNew.addError('You cannot modify the opportunity after it has been closed!');
                        }
                    }
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    //método para criar vaga
    public void oppWinCreatePosition(List<Opportunity> oppList) {

        List<Position__c> posNewList = new List<Position__c>();
        List<Position__c> posUpList = new List<Position__c>();

        RecordType recordTypePosition = [SELECT Id FROM RecordType WHERE Name = 'Position' LIMIT 1];

        for(Opportunity opp : oppList) {

            if (opp.StageName == 'Closed Won' && opp.RecordTypeId == recordTypePosition.Id) {

                Position__c posNew = new Position__c();
                posNew.Name = opp.Name;
                posNew.Status__c = 'New';
                posNew.Account__c = opp.AccountId;
                posNew.VagaContrato__c = false;
                posNew.Job_Description__c = 'Position created from a closed opportunity. Please fill in the remaining details.';

                posNewList.add(posNew);    
            }
        }

        if (!posNewList.isEmpty()) {
            insert posNewList;
        }

        if (!posNewList.isEmpty()) {
            
            QueueSobject[] queueRecruiters = [SELECT Id, Queue.Id, Queue.Name, Queue.Type, SobjectType FROM QueueSobject WHERE Queue.Name = 'Recruiters' AND SobjectType = 'Position__c' LIMIT 1];

            for(Position__c posUp : posNewList){

                posUp.OwnerId = queueRecruiters[0].Queue.Id;
                posUpList.add(posUp);
            }

            if (!posUpList.isEmpty()) {
                update posUpList;
            } 
        }
    }
    

    //--------------------------------------------------------------------------

}