trigger CandidateTrigger on Candidate__c (after insert, after update, before insert, before update) {

    CandidateTriggerHandler handler = new CandidateTriggerHandler();

    if(Trigger.isInsert || Trigger.isUpdate){
        handler.validateCPF(Trigger.new);

    }

    if(Trigger.isAfter){
        if(Trigger.isInsert || Trigger.isUpdate){
            CandidateTriggerHandler.setAddressViaCEP(Trigger.newMap);
        }
    }

}