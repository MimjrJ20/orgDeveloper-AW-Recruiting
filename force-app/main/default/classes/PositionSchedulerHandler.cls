global with sharing class PositionSchedulerHandler implements Schedulable {

    global void execute(SchedulableContext ctx){

        PositionUpdateBatchJob positionBatch = new PositionUpdateBatchJob();
        Integer bacthSize = 200;
        Database.executeBatch(positionBatch, bacthSize);
    }

}