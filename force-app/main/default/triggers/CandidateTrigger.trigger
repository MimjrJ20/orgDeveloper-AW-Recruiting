trigger CandidateTrigger on Candidate__c (after insert, after update, before insert, before update) {

    CandidateTriggerHandler handlerCand = new CandidateTriggerHandler();

    if(Trigger.isInsert || Trigger.isUpdate){
        handlerCand.validateCPF(Trigger.new);
        handlerCand.validateCEP(Trigger.new);
        handlerCand.validateAddress(Trigger.new);

    }

    if(Trigger.isAfter){
        if(Trigger.isInsert || Trigger.isUpdate){
            handlerCand.setAddressViaCEP(Trigger.oldMap, Trigger.newMap);
        }
    }

}