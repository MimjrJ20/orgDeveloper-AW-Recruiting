trigger ContractTrigger on Contract (after insert, after update) {

    ContractTriggerHandler handlerContract = new ContractTriggerHandler();

    if (Trigger.isInsert || Trigger.isUpdate) {
        handlerContract.contractRepeat(Trigger.new);        
    }

}