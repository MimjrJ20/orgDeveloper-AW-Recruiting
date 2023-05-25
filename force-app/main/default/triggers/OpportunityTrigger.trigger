trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update) {

    OpportunityTriggerHandler handlerOpp = new OpportunityTriggerHandler();

    if (Trigger.isBefore && Trigger.isUpdate) {
        handlerOpp.oppWinCreateContract(Trigger.new, Trigger.oldMap);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {

        List<Id> oppIds = new List<Id>();
        for (Opportunity opp : Trigger.new) {
            oppIds.add(opp.Id);
        }
        if (!oppIds.isEmpty()) {
            OpportunityTriggerHandler.updateOppsAsync(oppIds);
        }
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        handlerOpp.oppClosedNotEdit(Trigger.oldMap, Trigger.newMap);
    }

    if(Trigger.isInsert || Trigger.isUpdate){
        handlerOpp.oppDatePast(Trigger.new);
        handlerOpp.oppWinWithout(Trigger.new);
    }

}