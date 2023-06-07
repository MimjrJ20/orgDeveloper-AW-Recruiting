global with sharing class ContractUpdateBatchJob implements Database.Batchable<SObject>{

    //você define a consulta que usará neste contexto de lote 'selecionar ID da conta'
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, StartDate, EndDate, Status, Description FROM Contract';
        return Database.getQueryLocator(query);
    }

    //mas recebe apenas uma lista relativamente curta de registros (padrão 200)
    global void execute (Database.BatchableContext bc, List<Contract> contractList){

        List<Contract> contractUpdate = new List<Contract>();

        for(Contract contrUp : contractList){

            if (contrUp.Status == 'New' || contrUp.Status == 'Draft' || contrUp.Status == 'In Approval Process') {

                if (contrUp.StartDate <= System.TODAY()) {
                    contrUp.Status = 'Activated';
                    contrUp.Description = 'Contrato ativado através de schedule.';
                    contractUpdate.add(contrUp);
                }  

            } else if (contrUp.Status == 'Activated') {
                
                if (contrUp.EndDate < System.TODAY()) {
                    contrUp.Status = 'Closed';
                    contrUp.Description = 'Contrato fechado através de schedule.';
                    contractUpdate.add(contrUp);
                }  
            }
        }

        update contractUpdate;
    }

    // encerra todas as pontas soltas conforme necessário
    global void finish(Database.BatchableContext bc){
        System.debug('Batch contract processed!');

    }

}