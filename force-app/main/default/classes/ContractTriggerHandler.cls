public with sharing class ContractTriggerHandler {
    
    //construtor vazio
    public ContractTriggerHandler() {

    }

    //--------------------------------------------------------------------------

    //método para bloquear a criação de contrato com o mesmo range de data
    public void contractRepeat(List<Contract> contractList){

        // Conjunto para armazenar os Ids das contas
        Set<Id> accountsIds = new Set<Id>(); 

        for(Contract contract : contractList){

            // Adiciona o Id da conta atual ao conjunto
            accountsIds.add(contract.AccountId); 
        }

        if (!accountsIds.isEmpty()) {
            
            List<Contract> contractListExisting = [SELECT Id
                                                    FROM Contract
                                                    WHERE AccountId IN :accountsIds
                                                        AND ((StartDate <= :contractList[0].StartDate AND EndDate >= :contractList[0].StartDate)
                                                            OR (StartDate <= :contractList[0].EndDate AND EndDate >= :contractList[0].EndDate)
                                                            OR (StartDate >= :contractList[0].StartDate AND EndDate <= :contractList[0].EndDate))
                                                        AND Id NOT IN :contractList];
            

            for (Contract contract : contractList) {
                
                if (contractListExisting.size() > 0) {
                    contract.addError('Já existe um contrato com a mesma Conta e com datas conflitantes!');    
                }
            }
        }
    }
    //--------------------------------------------------------------------------

}