trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update) {

    OpportunityTriggerHandler handlerOpp = new OpportunityTriggerHandler();

    if(Trigger.isUpdate){
        handlerOpp.oppWinWithout(Trigger.new);
    }

    if(Trigger.isInsert || Trigger.isUpdate){
        handlerOpp.oppDatePast(Trigger.new);
    }

}