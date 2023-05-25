public with sharing class OpportunityTriggerHandler {
    
    //construtor vazio
    public OpportunityTriggerHandler() {

    }

    //método para criar contrato
    public void oppWinCreateContract(List<Opportunity> oppList){

        List<Contract> contractList = new List<Contract>();

        for(Opportunity opp : oppList){

            Contract contractNew = new Contract();

            RecordType recordTypeContract = [SELECT Id FROM RecordType WHERE Name = 'Contract' LIMIT 1];

            if(opp.StageName == 'Closed Won' && opp.RecordTypeId == recordTypeContract.Id) {

                contractNew.Status = 'New';
                contractNew.AccountId = opp.AccountId;
                contractNew.StartDate = opp.StartDate__c;
                //contractNew.ContractTerm = opp.Term__c;
                contractNew.PositionMonth__c = opp.PositionMonth__c;
            }
            contractList.add(contractNew);
        }
        System.debug(contractList);
        System.debug(contractList.size());
        insert contractList;


    }

    //--------------------------------------------------------------------------

    //método para impedir que fecha a oportunidade
    public void oppWinWithout(List<Opportunity> oppList){

        for(Opportunity opp : oppList){

            RecordType recordTypeContract = [SELECT Id FROM RecordType WHERE Name = 'Contract' LIMIT 1];

            if(opp.StageName == 'Closed Won' && opp.RecordTypeId == recordTypeContract.Id) {

                if(opp.Term__c == null || opp.StartDate__c == null){
                    opp.addError('Não é possível fechar a oportunidade com os campos: Prazo de Contrato e/ou Início do Contrato em branco!');
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    //método para impedir que a data seja data passada
    public void oppDatePast(List<Opportunity> oppList){

        for(Opportunity opp : oppList){

            if(opp.StartDate__c < System.today()){
                opp.StartDate__c.addError('Não é possível salvar a oportunidade se a data de Início do Contrato estiver no passado!');
            }
        }
    }

    //--------------------------------------------------------------------------
}