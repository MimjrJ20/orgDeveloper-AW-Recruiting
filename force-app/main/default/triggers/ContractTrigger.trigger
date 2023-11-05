trigger ContractTrigger on Contract (before insert, before update, after insert, after update) {

    ContractTriggerHandler handlerContract = new ContractTriggerHandler();


    if (Trigger.isAfter && Trigger.isUpdate) {
        handlerContract.submitContractToApprovals(Trigger.new);    
    }

    if (Trigger.isInsert || Trigger.isUpdate) {

        if (Trigger.isBefore) {
            handlerContract.verifyContractDate(Trigger.new);
        }

        if (Trigger.isAfter) {
            handlerContract.contractDuplicate(Trigger.new);    
            handlerContract.contractDuplicateBulk(Trigger.new);  
            System.debug('aqui ContractTriggerHandler.isVerifyStatus: ' + ContractTriggerHandler.isVerifyStatus);
            if (ContractTriggerHandler.isVerifyStatus) {
                handlerContract.contractChangeStatus(Trigger.newMap,Trigger.oldMap);        
            }
        }
    }


}