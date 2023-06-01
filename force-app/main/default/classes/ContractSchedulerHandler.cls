global with sharing class ContractSchedulerHandler implements Schedulable {

    //public static String CRON_EXP = '0 0 0 * * ?';

    global void execute(SchedulableContext ctx){

        ContractUpdateBatchJob contractBatch = new ContractUpdateBatchJob();
        Integer bacthSize = 200;
        Database.executeBatch(contractBatch, bacthSize);
    }

}