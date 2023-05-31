trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update) {

    OpportunityTriggerHandler handlerOpp = new OpportunityTriggerHandler();

    if (Trigger.isBefore && Trigger.isUpdate) {
        handlerOpp.oppWinCreateContract(Trigger.new, Trigger.oldMap);
        handlerOpp.oppWinCreatePosition(Trigger.new);

    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        handlerOpp.oppClosedNotEdit(Trigger.oldMap, Trigger.newMap);
    }

    if(Trigger.isInsert || Trigger.isUpdate){
        handlerOpp.oppDatePast(Trigger.new);
        handlerOpp.oppWinContractWithout(Trigger.new);
    }

}