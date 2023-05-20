trigger JobApplicationTrigger on Job_Application__c (after insert, after update) {

    JobApplicationTriggerHandler handlerJobAp = new JobApplicationTriggerHandler();

    if(Trigger.isInsert){
        handlerJobAp.postChatterNewJob(Trigger.new);
    }

    if(Trigger.isUpdate){
        handlerJobAp.postChatterUpJob(Trigger.new);

    }


}