public with sharing class PositionTriggerHandler {
    
    //construtor vazio
    public PositionTriggerHandler() {

    }


    //método para bloquear a criação de position se não tiver no contrato
    public void createPositionWithoutContract(List<Position__c> posList){

        for(Position__c posNew : posList){

            Contract[] contracts = [SELECT Id, AccountId, PositionMonth__c, StartDate, EndDate, Status
                                    FROM Contract 
                                    WHERE AccountId = :posNew.Account__c AND Status = 'Activated'
                                    LIMIT 1];

            if (posNew.VagaContrato__c) {

                if (contracts.isEmpty()) {
                    posNew.Account__c.addError('Essa conta não possui contrato ativo!');  
                } 
    
                if (!contracts.isEmpty()) {
                    
                    Boolean dateAvailable = System.today() >= contracts[0].StartDate.toStartOfMonth() 
                                            && System.today() <= contracts[0].EndDate.toStartOfMonth().addMonths(1).addDays(-1);
    
                    
                    if (dateAvailable == false) {
                        posNew.Account__c.addError('Essa conta não possui contrato ativo para este mês!');
                    }
    
                    if (dateAvailable) {
    
                        Position__c[] posSumMonth = [SELECT Id, CreatedDate, VagaContrato__c
                                                      FROM Position__c
                                                      WHERE 
                                                            CreatedDate = THIS_MONTH
                                                            AND VagaContrato__c = true];
                        
                        Decimal posAvailable = contracts[0].PositionMonth__c - posSumMonth.size();
    
                        if (posAvailable < 0) {
                            posNew.Account__c.addError('Essa conta não possui vagas disponíves em contrato! ' + 
                                                        +'Vaga(s) utilizada(s): ' + (posSumMonth.size()-1) + ' / Vaga(s) disponível(is): ' + contracts[0].PositionMonth__c);
                        }
                    }
                }  
            }
        }
    }
}