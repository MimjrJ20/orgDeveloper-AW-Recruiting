public with sharing class PositionTriggerHandler {
    
    //construtor vazio
    public PositionTriggerHandler() {

    }

    //----------------------------------------------------------------------

    //método para bloquear a criação de position se não tiver no contrato
    public void createPositionWithoutContract(List<Position__c> posList){

        Set<Id> accountIds = new Set<Id>();

        for(Position__c posNew : posList){
            accountIds.add(posNew.Account__c);
        }

        Map<Id, Contract> activeContractsMap = new Map<Id, Contract>([
            SELECT Id, AccountId, PositionMonth__c, StartDate, EndDate, Status
            FROM Contract 
            WHERE AccountId IN :accountIds 
                AND Status = 'Activated'
        ]);
        
        Map<Id, Integer> posCountMap = new Map<Id, Integer>();

        List<Position__c> posExisting = [
            SELECT Id, Account__c, CreatedDate
            FROM Position__c 
            WHERE Account__c IN :accountIds 
                AND CreatedDate = THIS_MONTH
        ];

        for(Position__c posMap : posExisting) {
                        
            Id accountId = posMap.Account__c;
            
            if (!posCountMap.containsKey(accountId)) {
                posCountMap.put(accountId, 0);
            }

            Integer posCount = posCountMap.get(accountId);
            posCount++;

            posCountMap.put(accountId, posCount);
        }


        for(Position__c posNew : posList){
        
            Id accountId = posNew.Account__c;
            Contract contract = null;

            for(Contract contractMap : activeContractsMap.values()) {
                if (contractMap.AccountId == accountId) {
                    contract = contractMap;
                    break;
                }
            }

            if (posNew.VagaContrato__c) {

                if (contract == null) {
                    posNew.Account__c.addError('This account does not have an active contract!');

                } else {
                    
                    Boolean dateAvailable = System.today() >= contract.StartDate.toStartOfMonth() 
                                            && System.today() <= contract.EndDate.toStartOfMonth().addMonths(1).addDays(-1);
                    
                    if (dateAvailable == false) {
                        posNew.Account__c.addError('This account does not have an active contract for this month!');
                    }
    
                    if (dateAvailable) {

                        Integer posCount = posCountMap.containsKey(accountId) ? posCountMap.get(accountId) : 0;

                        if (posCount > contract.PositionMonth__c) {
                            posNew.Account__c.addError('This account does not have available positions in the contract! Used position(s): ' + (posCount - 1) + ' / Available position(s): ' + contract.PositionMonth__c + '.');
                        }
                    }
                }  
            }
        }
    }

    //----------------------------------------------------------------------

}