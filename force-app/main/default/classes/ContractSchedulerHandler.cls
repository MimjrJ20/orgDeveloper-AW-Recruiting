global with sharing class ContractSchedulerHandler implements Schedulable {

    global void execute(SchedulableContext ctx){

        ContractUpdateBatchJob contractBatch = new ContractUpdateBatchJob();
        Integer bacthSize = 200;
        Database.executeBatch(contractBatch, bacthSize);
    }

}