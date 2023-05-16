trigger CandidateTrigger on Candidate__c (before insert, before update) {

    CandidateTriggerHandler handler = new CandidateTriggerHandler();

    if(Trigger.isInsert || Trigger.isUpdate){
        handler.validateCPF(Trigger.new);

    }
    

}