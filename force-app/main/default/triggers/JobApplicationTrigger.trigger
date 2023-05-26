trigger JobApplicationTrigger on Job_Application__c (after insert, after update) {

    JobApplicationTriggerHandler handlerJobApp = new JobApplicationTriggerHandler();

    if(Trigger.isInsert || Trigger.isUpdate){
        handlerJobApp.postChatterJob(Trigger.oldMap, Trigger.newMap);
    }


}