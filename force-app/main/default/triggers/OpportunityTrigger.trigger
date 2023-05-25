trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update) {

    OpportunityTriggerHandler handlerOpp = new OpportunityTriggerHandler();

    if(Trigger.isAfter && Trigger.isUpdate){
        handlerOpp.oppWinCreateContract(Trigger.new);
    }

    if(Trigger.isInsert || Trigger.isUpdate){
        handlerOpp.oppDatePast(Trigger.new);
        handlerOpp.oppWinWithout(Trigger.new);

    }

}