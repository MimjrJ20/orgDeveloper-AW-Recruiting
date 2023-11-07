global with sharing class ContractUpdateBatchJob implements Database.Batchable<SObject>{

    //você define a consulta que usará neste contexto de lote 
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, StartDate, EndDate, Status, Description__c FROM Contract LIMIT 200';
        return Database.getQueryLocator(query);
    }

    //recebe apenas uma lista
    global void execute (Database.BatchableContext bc, List<Contract> lstContracts){

        List<Contract> lstContractsToUpdate = new List<Contract>();

        for(Contract contract : lstContracts){

            if (contract.Status == 'Approved') {

                if (contract.StartDate < Date.today()) {
                    contract.Status = 'Activated';
                    contract.Description__c = 'Contract activated through a schedule.';
                    lstContractsToUpdate.add(contract);
                }  

            } else if (contract.Status == 'Activated') {
                
                if (contract.EndDate < Date.today()) {
                    contract.Status = 'Closed';
                    contract.Description__c = 'Contract closed through a schedule.';
                    lstContractsToUpdate.add(contract);
                }  
            }
        }

        update lstContractsToUpdate;
    }

    //encerra todas as pontas soltas conforme necessário
    global void finish(Database.BatchableContext bc){
        System.debug('Batch contract processed!');
    }

}