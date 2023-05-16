trigger TriggerCandidate on Candidate__c (before insert, before update) {

    //List<Candidate__c> candidateList = new List <Candidate__c>();

    for(Candidate__c cand : Trigger.new){

        if(Trigger.isInsert || Trigger.isUpdate){

            if(cand.CPF__c.isNumeric() == false){
                cand.addError('O CPF só pode haver números. Sem letras, pontos e traços!');
                
            } 
            
            if (cand.CPF__c.length() < 11) {
                cand.addError('O CPF precisa ter 11 números!');

            } 
        
        }
    

    }

}