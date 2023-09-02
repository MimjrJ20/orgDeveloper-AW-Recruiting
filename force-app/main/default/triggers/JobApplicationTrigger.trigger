trigger JobApplicationTrigger on Job_Application__c (after insert, after update, before delete) {

    JobApplicationTriggerHandler handlerJobApp = new JobApplicationTriggerHandler();

    if(Trigger.isInsert || Trigger.isUpdate){
        handlerJobApp.postChatterJob(Trigger.oldMap, Trigger.newMap);
        handlerJobApp.jobStartDateDays(Trigger.new);
    }

    if(Trigger.isBefore && Trigger.isDelete){
        handlerJobApp.jobNotDelete(Trigger.old);
    }


}