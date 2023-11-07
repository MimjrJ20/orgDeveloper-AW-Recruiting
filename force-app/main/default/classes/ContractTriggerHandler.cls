public with sharing class ContractTriggerHandler {
    
    //construtor vazio
    public ContractTriggerHandler() {

    }

    //--------------------------------------------------------------------------
    //método para bloquear a criação de contrato com o mesmo range de data
    public void contractDuplicate(List<Contract> lstContracts){

        Set<Id> lstAccountsIds = new Set<Id>(); 
        List<Contract> lstContractsError = new List<Contract>();
        List<Contract> lstContractsSame = new List<Contract>();
        Map<String,String> mapContractsRepeatInfos = new Map<String,String>();

        for(Contract contract : lstContracts){
            lstAccountsIds.add(contract.AccountId); 
        }
        
        if (!lstAccountsIds.isEmpty()) {
            List<Contract> lstContractsExisting = [
                SELECT Id,ContractNumber, StartDate, EndDate, AccountId
                FROM Contract
                WHERE AccountId IN :lstAccountsIds AND Id NOT IN :lstContracts
            ];
                
            if (!lstContractsExisting.isEmpty()) {
                for (Contract contractExisting : lstContractsExisting) {
                    for (Contract contract : lstContracts) { 
                        if (contractExisting.AccountId == contract.AccountId) {
                            if (
                                (contractExisting.StartDate <= contract.StartDate && contractExisting.EndDate >= contract.StartDate) || 
                                (contractExisting.StartDate <= contract.EndDate && contractExisting.EndDate >= contract.EndDate) || 
                                (contractExisting.StartDate >= contract.StartDate && contractExisting.EndDate <= contract.EndDate)
                                ) 
                            {
                                lstContractsError.add(contract);
                                lstContractsSame.add(contractExisting);
                            }  
                        }
                    }                      
                }
            }
        }

        if (!lstContractsError.isEmpty()) {

            if (!lstContractsSame.isEmpty()) {
                for (Contract contract : lstContractsSame) {
                    mapContractsRepeatInfos.put(contract.ContractNumber, contract.Id);
                }
            }

            for (Contract contract : lstContractsError) {
                contract.addError('There is already a contract with the same Account and conflicting dates! Number/Id duplicate records: ' + mapContractsRepeatInfos);
            }
        }
    }
    

    //método para bloquear a criação de contrato com o mesmo range de data (em massa)
    public void contractDuplicateBulk(List<Contract> lstContracts) {
        Set<String> contractKeys = new Set<String>();
        for (Contract contract : lstContracts) {
            String contractKey = contract.AccountId + '_' + contract.StartDate + '_' + contract.ContractTerm;
            if (contractKeys.contains(contractKey)) {
                contract.addError('There is already a contract with the same Account and conflicting dates! (Records in bulk)');
            } else {
                contractKeys.add(contractKey);
            }
        }
    }

    //--------------------------------------------------------------------------
    //método que não deixa outro perfil a não ser "System Administrator" e "Human Resources Manager" ativar um contrato
    @TestVisible
    public static Boolean isVerifyStatus = true;

    @TestVisible
    public static void setIsVerifyStatus(Boolean value) {
        isVerifyStatus = value;
    }

    public void contractChangeStatus(Map<Id, Contract> mapContractsNew, Map<Id, Contract> mapContractsOld) {

        if (ContractTriggerHandler.isVerifyStatus) {
            List<String> lstProfileNameAccept = new List<String>{'System Administrator','Human Resources Manager' };
            Map<String, Set<String>> validStatusTransitions = new Map<String, Set<String>>{
                'New' => new Set<String>{'Draft'},
                'Draft' => new Set<String>{'New'}
            };
    
            String idCurrentProfile = UserController.getCurrentUserProfileId();
            String nameCurrentProfile = UserController.getProfileName(idCurrentProfile);
    
            if (!lstProfileNameAccept.contains(nameCurrentProfile)) { 
                for (Id id : mapContractsNew.keySet()) {
                    Contract contractNew = mapContractsNew.get(id);
                    if(mapContractsOld != null){
                        Contract contractOld = mapContractsOld.get(id);
                        if(contractOld != null){
                            if (!validStatusTransitions.containsKey(contractOld.Status) || !validStatusTransitions.get(contractOld.Status).contains(contractNew.Status)) {
                                if (contractOld != null && contractNew != null) {
                                    if (contractOld.Status != contractNew.Status) {
                                        contractNew.addError('You do not have the required profile to change the contract status, only from New to Draft or oposite.');
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

    }



    //--------------------------------------------------------------------------
    //método que verifica se o contrato tem mais de 7 dias criado e não foi ativado enviar para aprovação para que seja observado pelo gerente
    public void submitContractToApprovals(List<Contract> lstContracts){

        String userId = UserController.getCurrentUserId();
        
        for (Contract contract : lstContracts) {

            if (contract.SubmitAutomaticApprovals__c) {
                isVerifyStatus = false;
                Approval.ProcessSubmitRequest approvals = new Approval.ProcessSubmitRequest();
                approvals.setComments('Submitting record for approval automatic.');
                approvals.setObjectId(contract.Id);
                approvals.setSubmitterId(userId); 
                approvals.setProcessDefinitionNameOrId('Approval_Process_Contract_Approved');
                approvals.setSkipEntryCriteria(false);
                Approval.ProcessResult result = Approval.process(approvals);
            }
        }
    }

    //-----------------------------------------------------------------
    //método que verifica a data de inicio do contrato
    @TestVisible
    public static Boolean isVerifyDate = true;

    @TestVisible
    public static void setIsVerifyDate(Boolean value) {
        isVerifyDate = value;
    }
    public void verifyContractDate(List<Contract> lstContracts) {
        
        if (ContractTriggerHandler.isVerifyDate) {
            for (Contract contract : lstContracts) {

                if (contract.StartDate != null) {
                    Integer betweenDate = Date.today().daysBetween(contract.StartDate);
                    if (betweenDate < 0) {
                        contract.StartDate.addError('The contract start date cannot be earlier than today. Difference: ' + betweenDate + ' days.');
                    }
                }

            }  
        } 
    }

}