public with sharing class ContractTriggerHandler {
    
    //construtor vazio
    public ContractTriggerHandler() {

    }

    //--------------------------------------------------------------------------
    //!método para bloquear a criação de contrato com o mesmo range de data
    //! public void contractRepeat(List<Contract> lstContracts){
    //!     Set<Id> accountsIds = new Set<Id>(); 
    //!     for(Contract contract : lstContracts){
    //!          accountsIds.add(contract.AccountId); 
    //!      }
    //!      if (!accountsIds.isEmpty()) {
    //!          List<Contract> listContractExisting = [
    //!              SELECT Id
    //!              FROM Contract
    //!              WHERE 
    //!                 AccountId IN :accountsIds
    //!                 AND (
    //!                         (StartDate <= :lstContracts[0].StartDate AND EndDate >= :lstContracts[0].StartDate) OR 
    //!                         (StartDate <= :lstContracts[0].EndDate AND EndDate >= :lstContracts[0].EndDate) OR 
    //!                         (StartDate >= :lstContracts[0].StartDate AND EndDate <= :lstContracts[0].EndDate)
    //!                     )
    //!                 AND Id NOT IN :lstContracts
    //!         ];
    //!         for(Contract contract : lstContracts) {                
    //!             if (listContractExisting.size() > 0) {
    //!                 contract.addError('Já existe um contrato com a mesma Conta e com datas conflitantes!');    
    //!             }
    //!         }
    //!     }
    //!}

    //--------------------------------------------------------------------------
    //método para bloquear a criação de contrato com o mesmo range de data
    public void contractRepeatAfter(List<Contract> lstContracts){
        Set<Id> lstAccountsIds = new Set<Id>(); 
        Set<Contract> lstContractsRepeat = new Set<Contract>();
        
        for(Contract contract : lstContracts){
            lstAccountsIds.add(contract.AccountId); 
        }
        System.debug('lstContracts.size(): ' + lstContracts.size());
        
        if (!lstAccountsIds.isEmpty()) {
            List<Contract> lstContractsExisting = [
                SELECT Id, StartDate, EndDate, AccountId
                FROM Contract
                WHERE AccountId IN :lstAccountsIds AND Id NOT IN :lstContracts
            ];
        
            System.debug('lstContractsExisting.size(): ' + lstContractsExisting.size());
        
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
                                lstContractsRepeat.add(contract);
                            }  
                        }
                    }                      
                }
            }
        }
        System.debug('lstContractsRepeat.size(): ' + lstContractsRepeat.size());
        
        if (!lstContractsRepeat.isEmpty()) {
            for (Contract contract : lstContractsRepeat) {
                contract.addError('There is already a contract with the same Account and conflicting dates!');
            }
        }
    }

    //método para bloquear a criação de contrato com o mesmo range de data
    public void contractRepeatBefore(List<Contract> lstContracts) {
        Set<Contract> lstContractsFirst = new Set<Contract>();
        Set<Contract> lstContractsSecond = new Set<Contract>();
        Set<Contract> lstContractsRepeat = new Set<Contract>();

        for(Contract contract : lstContracts){
            lstContractsFirst.add(contract);
            lstContractsSecond.add(contract);
        }
   
        for (Contract contractFst : lstContractsFirst) {
            for (Contract contractScd : lstContractsSecond) {
                if (contractFst != contractScd) {
                    if (
                        contractFst.AccountId == contractScd.AccountId &&
                        contractFst.StartDate == contractScd.StartDate &&
                        contractFst.ContractTerm == contractScd.ContractTerm
                        ) 
                    {
                        lstContractsRepeat.add(contractFst);
                    }
                }
            }
        }
        
        System.debug('lstContractsRepeat.size(): ' + lstContractsRepeat.size());
    
        if (!lstContractsRepeat.isEmpty()) {
            for (Contract contract : lstContractsRepeat) {
                contract.addError('There is already a contract with the same Account and conflicting dates! (records in bulk)');
            }        
        }
    }

    //--------------------------------------------------------------------------
    //método que não deixa outro perfil a não ser "System Administrator" e "Human Resources Manager" ativar um contrato
    //na verdade não pode mudar o status a não ser para Draft
    public void contractChangeStatus(Map<Id, Contract> mapContractsNew, Map<Id, Contract> mapContractsOld) {

        String idCurrentProfile = UserController.getCurrentUserProfileId();
        String nameCurrentProfile = UserController.getProfileName(idCurrentProfile);
        System.debug('nameCurrentProfile: ' + nameCurrentProfile);

        if (nameCurrentProfile != 'System Administrator' && nameCurrentProfile != 'Human Resources Manager') {            
            for (Id id : mapContractsNew.keySet()) {
                Contract contractNew = mapContractsNew.get(id);
                if(mapContractsOld != null){
                    Contract contractOld = mapContractsOld.get(id);
                    if(contractOld != null){
                        if((contractOld.Status == 'New' && contractNew.Status != 'Draft')||  (contractOld.Status == 'Draft' && contractNew.Status != 'New')){
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


    //--------------------------------------------------------------------------
    //método que verifica se o contrato tem mais de 7 dias criado e não foi ativado enviar para aprovação para que seja observado pelo gerente
}