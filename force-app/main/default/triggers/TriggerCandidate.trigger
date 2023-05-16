trigger TriggerCandidate on Candidate__c (before insert, before update) {

    //List<Candidate__c> candidateList = new List <Candidate__c>();

    for(Candidate__c cand : Trigger.new){

        if(Trigger.isInsert && Trigger.isUpdate){

            if(cand.CPF__c != null){
                cand.addError('Este CPF está inválido!');
            }
        
        }
    

    }

}