trigger PositionTrigger on Position__c (after insert, after update) {

    PositionTriggerHandler handlerPos = new PositionTriggerHandler();

    if (Trigger.isInsert) {
        handlerPos.createPositionWithoutContract(Trigger.new);
        
    }

}