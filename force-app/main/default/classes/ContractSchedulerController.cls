public with sharing class ContractSchedulerController {
    
    public static void scheduleContractUpdate() {
        ContractSchedulerHandler scheduler = new ContractSchedulerHandler();
        String jobName = 'Update Contract';
        System.schedule(jobName, ContractSchedulerHandler.CRON_EXP, scheduler);
    }

    
}