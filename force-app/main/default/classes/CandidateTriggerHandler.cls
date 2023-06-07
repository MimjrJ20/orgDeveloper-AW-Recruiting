public with sharing class CandidateTriggerHandler {
    
    //Construtor Vazio
    public CandidateTriggerHandler() {
    
    }

    //--------------------------------------------------------

    //Método para validar o CPF
    public void validateCPF(List <Candidate__c> candidateList){

        //List<Candidate__c> candidateListUp = [SELECT Id, CPF__c FROM Candidate__c WHERE Id IN :candidateList];

        Integer numCPF = 11;

        for(Candidate__c cand : candidateList){

            if(cand.CPF__c != null){
            
                //Se o CPF tiver caracteres diferente de numérico
                if(!cand.CPF__c.isNumeric()){
                    cand.CPF__c.addError('O CPF só pode haver números. Sem letras, pontos e traços!');
                } 
                
                //Se o CPF tiver menor que 11 números
                if (cand.CPF__c.length() < numCPF && cand.CPF__c.isNumeric()) {
                    cand.CPF__c.addError('O CPF precisa ter 11 números!');
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
                        cand.CPF__c.addError('Este CPF não é válido!');
                    }
                }

                //se os números forem repetidos
                Pattern numOnly = Pattern.compile('\\b(\\d)\\1*\\b');
                Matcher validFieldCPF = numOnly.matcher(cand.CPF__c);

                if(validFieldCPF.matches()){
                    cand.CPF__c.addError('O CPF não pode ser composto por um único número!');
                }
            }    
        }
    }

    //--------------------------------------------------------

    //Método preenche CEP
    //representa uma coleção de candidatos identificados por seus IDs
    public void setAddressViaCEP(Map<Id, Candidate__c> candidateListOld, Map<Id, Candidate__c> candidateListNew){

        //itera sobre as chaves (IDs dos candidatos)
        for(Id candId : candidateListNew.keySet()) {

            //atual dentro do loop e o armazena na variável cand. 
            //Isso permite acessar os campos do candidato
            Candidate__c candNew = candidateListNew.get(candId);

            if (candNew.Zip_Postal_Code__c != null && candNew.Country_List__c == 'BR - Brazil') {

                //nessa parte chama quando o candidateListOld estiver  DIFERENTE null, portanto registro que será atualizado
                if(candidateListOld != null){

                    Candidate__c candOld = candidateListOld.get(candId);

                     if(candOld != null){

                        if(candOld.Zip_Postal_Code__c != candNew.Zip_Postal_Code__c){

                            //Essa linha verifica se o método está sendo chamado de um contexto que não seja futuro nem de um contexto de lote
                            if (!System.isFuture() && !System.isBatch()) {
                                IntegrationViaCEPCallout.getCEP(candNew.Zip_Postal_Code__c, candId);
                            }
                        }
                    }
                }

                //nessa parte chama quando o candidateListOld estiver null, portanto registro novo
                //Essa linha verifica se o método está sendo chamado de um contexto que não seja futuro nem de um contexto de lote
                else if (!System.isFuture() && !System.isBatch()) {
                    IntegrationViaCEPCallout.getCEP(candNew.Zip_Postal_Code__c, candId);
                }
                
            }   
        }
    }

    //--------------------------------------------------------

    //validação número cep
    public void validateCEP(List <Candidate__c> candidateList){

        //List<Candidate__c> candidateListUp = [SELECT Id, Zip_Postal_Code__c, Country_List__c FROM Candidate__c WHERE Id IN :candidateList];

        for(Candidate__c cand : candidateList){

            if(cand.Zip_Postal_Code__c != null){

                if(cand.Country_List__c == 'BR - Brazil' && cand.Zip_Postal_Code__c.length() != 8){
                    cand.Zip_Postal_Code__c.addError('O CEP para o país Brasil deve conter 8 dígitos!');
                }

                if(!cand.Zip_Postal_Code__c.isNumeric()){
                    cand.Zip_Postal_Code__c.addError('No CEP não pode ser inserido letra ou ponto!');
                }
            }
        }
    }

    //--------------------------------------------------------

}