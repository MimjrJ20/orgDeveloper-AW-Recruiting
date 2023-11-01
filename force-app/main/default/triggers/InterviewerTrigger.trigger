trigger InterviewerTrigger on Interviewer__c (before insert, before update, after insert, after update) {

    InterviewerTriggerHandler handlerInter = new InterviewerTriggerHandler();


    if(Trigger.isInsert || Trigger.isUpdate){

        if (Trigger.isBefore) {
            handlerInter.updateInterviewerCandidate(Trigger.new);
            handlerInter.verifyInterviewerDate(Trigger.new);
            handlerInter.updateInterviewerEquals(Trigger.new);
        } 

        if (Trigger.isAfter) {
            handlerInter.updateInterviewerJob(Trigger.new);
        }
    }



}