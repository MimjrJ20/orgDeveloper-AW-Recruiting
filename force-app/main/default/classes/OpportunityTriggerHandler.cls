public with sharing class OpportunityTriggerHandler {
    
    //construtor vazio
    public OpportunityTriggerHandler() {

    }

    //--------------------------------------------------------------------------

    //método para criar contrato
    public void oppWinCreateContract(List<Opportunity> oppList, Map<Id, Opportunity> oppMap) {

        //lista para inserir os novos contratos, atualizar as oporunidades e os ids das oportunidades
        List<Contract> contractNewList = new List<Contract>();
        List<Opportunity> oppUpdateList = new List<Opportunity>();
        List<Id> oppIds = new List<Id>();

        //uma lista com chave e objeto do contrato
        Map<Id, Contract> contractMap = new Map<Id, Contract>(); 

        //busca do id do RecordType igual a Contrato
        RecordType recordTypeContract = [SELECT Id FROM RecordType WHERE Name = 'Contract' LIMIT 1];

        //percorrer a lista de oportunidade para criar o novo contrato
        for(Opportunity opp : oppList) {

            //condição se Closede Won E do tipo Contrato
            if (opp.StageName == 'Closed Won' && opp.RecordTypeId == recordTypeContract.Id) {

                //instanciando o objeto Contrato e definindo os valores dos campos
                Contract contractNew = new Contract();
                contractNew.Status = 'New';
                contractNew.AccountId = opp.AccountId;
                contractNew.StartDate = opp.StartDate__c;
                contractNew.PositionMonth__c = opp.PositionMonth__c;
                contractNew.ContractTerm = Integer.valueOf(opp.Term__c);

                //adiciona o registro para lista de novos contratos
                contractNewList.add(contractNew);

                //adiciona como chave do map do contrato o Id da oportunidade e contrato
                contractMap.put(opp.Id, contractNew);            
            }
        }

        //cria os contratos da lista
        if (!contractNewList.isEmpty()) {
            insert contractNewList;
        }

        //percorrer a lista de oportuidade para atualizar o campo com o contrato criado
        for (Opportunity opp : oppList) {

            //condição se o map do Contrato contem o Id da oportunidade da lista percorrida
            if (contractMap.containsKey(opp.Id)) {

                //passando como ojeto o contrato relacionado a chave da oportunidade buscada
                Contract contractOpp = contractMap.get(opp.Id);

                //atualizando o contrato da oportunidade
                opp.ContractId = contractOpp.Id; 

                //adiciona a oportunidade atualiza a uma lista
                oppUpdateList.add(opp);
            }
        }
                
        //obter os Ids das oportunidades atualizadas para o método futuro 
        for (Opportunity opp : oppUpdateList) {
            //adicionando os ids das oportunidade na lista de Ids
            oppIds.add(opp.Id);
        }
    }

    //método futuro chamado acima
    @future
    public static void updateOppsAsync(List<Id> oppIds) {
        
        if (!System.isFuture()) {

            //criando uma lista que será atualizado com o id igual ao id passado no método
            List<Opportunity> oppUpdateListAsync = [SELECT Id, ContractId FROM Opportunity WHERE Id IN :oppIds];
            
            //atualiza as oportunidades da lista
            if (!oppUpdateListAsync.isEmpty()) {
                update oppUpdateListAsync;
            }
        }
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

    //método para barrar alteração quando a oportunidade estiver fechada
    public void oppClosedNotEdit(Map<Id, Opportunity> oppListOld, Map<Id, Opportunity> oppListNew){

        for(Id oppId : oppListNew.keySet()){

            Opportunity oppNew = oppListNew.get(oppId);

            if(oppListOld != null){

                Opportunity oppOld = oppListOld.get(oppId);

                if(oppOld != null){
                    
                    if((oppOld.StageName == 'Closed Won' || oppOld.StageName == 'Closed Lost')
                    || (oppOld.StageName == 'Closed Won' && oppNew.StageName != 'Closed Won')
                    || (oppOld.StageName == 'Closed Lost' && oppNew.StageName != 'Closed Lost')){

                        if(!oppListOld.equals(oppListNew)){
                            
                            oppNew.addError('Não pode alterar a oportunidade depois de fechada!');
                        }
                    }
                }
            }
        }
    }
    

    //--------------------------------------------------------------------------

}