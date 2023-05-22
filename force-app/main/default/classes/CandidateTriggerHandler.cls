public with sharing class CandidateTriggerHandler {
    
    //Construtor Vazio
    public CandidateTriggerHandler() {
    
    }

    //Método para validar o CPF
    public void validateCPF(List <Candidate__c> candidateList){

        //List<Candidate__c> candidateList = new List <Candidate__c>();

        Integer numCPF = 11;

        for(Candidate__c cand : candidateList){

            if(cand.CPF__c != null){
            
                //Se o CPF tiver caracteres diferente de numérico
                if(!cand.CPF__c.isNumeric()){
                    cand.addError('O CPF só pode haver números. Sem letras, pontos e traços!');
                } 
                
                //Se o CPF tiver menor que 11 números
                if (cand.CPF__c.length() < numCPF && cand.CPF__c.isNumeric()) {
                    cand.addError('O CPF precisa ter 11 números!');
                } 

                //Validar se o CPF existe
                if(cand.CPF__c.length() == numCPF && cand.CPF__c.isNumeric()){
                    
                    //Integer intCPF = Integer.valueOf(cand.CPF__c);
                    Integer subOneCPF = numCPF - 1;

                    Integer resultSoma1 = 0;
                    Integer resultFinal1 = 0;
                    String resultMidPenul = cand.CPF__c.mid(numCPF - 2,1);
                    Integer midPenul = Integer.valueOf(resultMidPenul);

                    Integer resultSoma2 = 0;
                    Integer resultFinal2 = 0;
                    String resultMidLast = cand.CPF__c.mid(numCPF - 1,1);
                    Integer midLast = Integer.valueOf(resultMidLast);

                    //cálculo penúltimo número do CPF
                    for(Integer i = 1; i <= (subOneCPF-1); i++){
                        Integer midCPF = Integer.valueOf(cand.CPF__c.mid((i-1),1));
                        Integer resultMult1 = midCPF * (numCPF - i);
                        resultSoma1 += resultMult1;
                    }

                    Integer resultValid1 = resultSoma1 * subOneCPF;
                    Integer resultDiv1 = math.mod(resultValid1,numCPF);

                    if(resultDiv1 <= subOneCPF - 2){
                        resultFinal1 = resultDiv1;
                    } else {
                        resultFinal1 = 0;
                    }

                    //cálculo último número do CPF
                    for(Integer j = 1; j <= subOneCPF; j++){
                        Integer midCPF = Integer.valueOf(cand.CPF__c.mid((j-1),1));
                        Integer resultMult2 = midCPF * ((numCPF + 1) - j);
                        resultSoma2 += resultMult2;
                    }

                    Integer resultValid2 = resultSoma2 * subOneCPF;
                    Integer resultDiv2 = math.mod(resultValid2,numCPF);

                    if(resultDiv2 <= subOneCPF - 1){
                        resultFinal2 = resultDiv2;
                    } else {
                        resultFinal2 = 0;
                    }
                    
                    //retorna msg
                    if(midPenul != resultFinal1 || midLast != resultFinal2){
                        cand.addError('Este CPF não é válido!');
                    }
                }

                //se os números forem repetidos
                Pattern numOnly = Pattern.compile('\\b(\\d)\\1*\\b');
                Matcher validFieldCPF = numOnly.matcher(cand.CPF__c);

                if(validFieldCPF.matches()){
                    cand.addError('O CPF não pode ser composto por um único número!');
                }
            }    
        }
    }

    //Método preenche CEP
    //representa uma coleção de candidatos identificados por seus IDs
    public void setAddressViaCEP(Map<Id, Candidate__c> candidateListOld, Map<Id, Candidate__c> candidateListNew){

        //itera sobre as chaves (IDs dos candidatos)
        for (Id candId : candidateListNew.keySet()) {

            //D atual dentro do loop e o armazena na variável cand. 
            //Isso permite acessar os campos do candidato
            Candidate__c cand = candidateListNew.get(candId);

            if (cand.Zip_Postal_Code__c != null) {

                if(candidateListOld.get(candId).Zip_Postal_Code__c != candidateListNew.get(candId).Zip_Postal_Code__c
                    || (candidateListOld.get(candId).Country_List__c != 'BR - Brazil' && candidateListNew.get(candId).Country_List__c == 'BR - Brazil')){

                    //Essa linha verifica se o método está sendo chamado de um contexto que não seja futuro 
                    // nem de um contexto de lote
                    if (!System.isFuture() && !System.isBatch()) {
                            IntegrationViaCEPCallout.getCEP(cand.Zip_Postal_Code__c, candId);
                    }
                }
            }
        }
    }

    //validação número cep
    public void validateCEP(List <Candidate__c> candidateList){

        for(Candidate__c cand : candidateList){

            if(cand.Zip_Postal_Code__c != null){

                if(cand.Country_List__c == 'BR - Brazil' && cand.Zip_Postal_Code__c.length() != 8){
                    cand.addError('O CEP para o país Brasil deve conter 8 dígitos!');
                }

                if(!cand.Zip_Postal_Code__c.isNumeric()){
                    cand.addError('No CEP não pode ser inserido letra ou ponto!');

                }
            }



        }

    }

}