trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update) {

    OpportunityTriggerHandler handlerOpp = new OpportunityTriggerHandler();
    
    if(Trigger.isAfter){

        if(Trigger.isUpdate){
            handlerOpp.oppClosedNotEdit(Trigger.oldMap, Trigger.newMap);
        }

        if(Trigger.isInsert || Trigger.isUpdate){
            handlerOpp.oppWinContractWithout(Trigger.new);
        }

    }

    if (Trigger.isBefore) {

        if(Trigger.isInsert || Trigger.isUpdate){
            handlerOpp.oppDatePast(Trigger.new);
        }

        if(Trigger.isUpdate){
            handlerOpp.oppWinCreateContract(Trigger.new, Trigger.oldMap);
            handlerOpp.oppWinCreatePosition(Trigger.new);
        }
    }


}