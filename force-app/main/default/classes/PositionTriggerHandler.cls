public with sharing class PositionTriggerHandler {
    
    //construtor vazio
    public PositionTriggerHandler() {

    }

    //----------------------------------------------------------------------

    //método para bloquear a criação de position se não tiver no contrato
    public void createPositionWithoutContract(List<Position__c> posList){

        //um conjunto (Set) de IDs de conta para coletar os IDs das contas relacionadas às posições.
        Set<Id> accountIds = new Set<Id>();

        for(Position__c posNew : posList){
            accountIds.add(posNew.Account__c);
        }

        //armazenar os contratos ativos relacionados às contas, usando o ID da conta como chave
        Map<Id, Contract> activeContractsMap = new Map<Id, Contract>([SELECT Id, AccountId, PositionMonth__c, StartDate, EndDate, Status
                                                                        FROM Contract 
                                                                        WHERE AccountId IN :accountIds 
                                                                            AND Status = 'Activated']);
        
        //armazenar a contagem de posições para cada conta.
        Map<Id, Integer> posCountMap = new Map<Id, Integer>();

        //armazenar as posições existentes no mês atual para as contas fornecidas
        List<Position__c> posExisting = [SELECT Id, Account__c, CreatedDate
                                            FROM Position__c 
                                            WHERE Account__c IN :accountIds 
                                                AND CreatedDate = THIS_MONTH];

        //para cada posição, o ID da conta é recuperado. 
        //verifica-se se a conta já existe como chave no mapa posCountMap. 
        //se não existir, é adicionada uma entrada com o valor 0. 
        //a contagem de posições para a conta é incrementada em 1 e atualizada no mapa.
        for (Position__c posMap : posExisting) {
                        
            Id accountId = posMap.Account__c;
            
            if (!posCountMap.containsKey(accountId)) {
                posCountMap.put(accountId, 0);
            }

            Integer posCount = posCountMap.get(accountId);
            posCount++;

            posCountMap.put(accountId, posCount);
        }


        for(Position__c posNew : posList){
        
            //ID da conta da posição
            Id accountId = posNew.Account__c;
            
            //inicializa uma variável para armazenar o contrato correspondente
            Contract contract = null;

            //percorre sobre os valores do mapa para encontrar o contrato com a conta correspondente
            for (Contract contractMap : activeContractsMap.values()) {
                if (contractMap.AccountId == accountId) {
                    contract = contractMap;
                    break;
                }
            }

            if (posNew.VagaContrato__c) {

                if (contract == null) {
                    posNew.Account__c.addError('Essa conta não possui contrato ativo!');  

                } else {
                    
                    Boolean dateAvailable = System.today() >= contract.StartDate.toStartOfMonth() 
                                            && System.today() <= contract.EndDate.toStartOfMonth().addMonths(1).addDays(-1);
                    
                    if (dateAvailable == false) {
                        posNew.Account__c.addError('Essa conta não possui contrato ativo para este mês!');
                    }
    
                    if (dateAvailable) {

                        //verifica se há uma contagem de posições registrada para uma determinada conta no mapa posCountMap e atribui esse valor à variável 
                        //xaso não haja uma contagem de posições registrada, o valor 0 é atribuído à variável 
                        Integer posCount = posCountMap.containsKey(accountId) ? posCountMap.get(accountId) : 0;

                            
                        if (posCount > contract.PositionMonth__c) {
                            posNew.Account__c.addError('Essa conta não possui vagas disponíves em contrato! ' + 
                                                        +'Vaga(s) utilizada(s): ' + (posCount - 1) + ' / Vaga(s) disponível(is): ' + contract.PositionMonth__c + '.');
                        }
                    }
                }  
            }
        }
    }

    //----------------------------------------------------------------------

}