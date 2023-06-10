global with sharing class PositionUpdateBatchJob implements Database.Batchable<SObject>{

    //você define a consulta que usará neste contexto de lote 'selecionar ID da conta'
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, VagaContrato__c, Account__c FROM Position__c WHERE VagaContrato__c = true';
        return Database.getQueryLocator(query);
    }

    //mas recebe apenas uma lista relativamente curta de registros (padrão 200)
    global void execute (Database.BatchableContext bc, List<Position__c> posList){

        // Lista para atualizar vagas
        List<Position__c> posUpdate = new List<Position__c>();

        // Conjunto para armazenar os Ids das contas
        Set<Id> accountsIds = new Set<Id>(); 

        for(Position__c posAcc : posList){

            // Adiciona o Id da conta atual ao conjunto
            accountsIds.add(posAcc.Account__c); 
        }

        Contract[] contracts = [SELECT Id, AccountId, StartDate, EndDate, Status FROM Contract WHERE AccountId = :accountsIds AND Status = 'Activated' LIMIT 1];

        for(Position__c posUp : posList){

            //Contract[] contracts = [SELECT Id, AccountId, StartDate, EndDate, Status FROM Contract WHERE AccountId = :posUp.Account__c AND Status = 'Activated' LIMIT 1];
            if (posUp.VagaContrato__c) {

                if (contracts.isEmpty()) {
                    posUp.Status__c = 'Canceled';
                    posUpdate.add(posUp);

                } 
            }
        }

        update posUpdate;
    }

    // encerra todas as pontas soltas conforme necessário
    global void finish(Database.BatchableContext bc){
        System.debug('Batch position processed!');

    }
}