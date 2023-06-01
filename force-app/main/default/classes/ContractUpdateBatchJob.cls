global with sharing class ContractUpdateBatchJob implements Database.Batchable<SObject>{


    //você define a consulta que usará neste contexto de lote 'selecionar ID da conta'
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, StartDate, Status FROM Contract WHERE Status IN (\'New\', \'Draft\', \'In Approval Process\') AND StartDate = TODAY';
        return Database.getQueryLocator(query);
    }

    //mas recebe apenas uma lista relativamente curta de registros (padrão 200)
    global void execute (Database.BatchableContext bc, List<Contract> contractList){

        List<Contract> contractUpdate = new List<Contract>();

        for (Contract contrUp : contractList){
            contrUp.Status = 'Activated';
            contractUpdate.add(contrUp);
        }

        update contractUpdate;
    }

    // encerra todas as pontas soltas conforme necessário
    global void finish(Database.BatchableContext bc){
        System.debug('Batch processed!');

    }

}