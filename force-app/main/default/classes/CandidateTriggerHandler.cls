public with sharing class CandidateTriggerHandler {
    
    //Construtor Vazio
    public CandidateTriggerHandler() {
    
    }

    //Método para validar o CPF
    public void validateCPF(List <Candidate__c> candidateList){

        //List<Candidate__c> candidateList = new List <Candidate__c>();

        for(Candidate__c cand : candidateList){

            if(cand.CPF__c != null){
            
                //Se o CPF tiver caracteres diferente de numérico
                if(!cand.CPF__c.isNumeric()){
                    cand.addError('O CPF só pode haver números. Sem letras, pontos e traços!');
                } 
                
                //Se o CPF tiver menor que 11 números
                if (cand.CPF__c.length() < 11 && cand.CPF__c.isNumeric()) {
                    cand.addError('O CPF precisa ter 11 números!');
                } 

                //Validar se o CPF existe

            }
            
        }
    }
}