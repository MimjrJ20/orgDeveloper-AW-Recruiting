trigger ContractTrigger on Contract (before insert, before update, after insert, after update) {

    ContractTriggerHandler handlerContract = new ContractTriggerHandler();

    if (Trigger.isInsert || Trigger.isUpdate) {
        if (Trigger.isBefore) {
            handlerContract.contractRepeatBefore(Trigger.new);        
        }
        if (Trigger.isAfter) {
            handlerContract.contractRepeatAfter(Trigger.new);        
        }
    }

}