public with sharing class PositionController {

    //---------------
    //métodos update
    @AuraEnabled
    public static void updatePosition(List<Id> ids, String approvalStatus, String status){

        List<Position__c> positionsUpdate = new List<Position__c>();

        if (ids != null && ids.size()>0) {
            
            for (Id id : ids) {
                Position__c pos = new Position__c();
                pos.Id = id;

                if (!String.isBlank(approvalStatus)) {
                    pos.Approval_Status__c = approvalStatus;
                }

                if (!String.isBlank(status)) {
                    pos.Status__c = status;
                }
                positionsUpdate.add(pos);
            }
        }

        if (positionsUpdate != null && positionsUpdate.size() > 0) {
            update positionsUpdate;
        }
        
    }

    //---------------
    //métodos insert


}