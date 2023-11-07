@isTest
public with sharing class ContractTestDataFactory {

    //massa para criar UM único contrato como 'New'
    public static Contract createContract(Boolean doInsert, Id accId, Integer months, Date startDate, String status){
        Contract contract = new Contract();
        contract.AccountId = accId;
        contract.Status = status;
        contract.ContractTerm = months;
        contract.StartDate = startDate;
        if(doInsert){
            insert contract;
        }
        return contract;
    }

    //massa para criar uma LISTA contratos como 'New'
    public static List<Contract> createContractList(Boolean doInsert, List<Account> lstAcc, Integer months, Date startDate, String status){
        
        List<Contract> lstContract = new List<Contract>();

        for(Account acc : lstAcc) {
            Contract contract = new Contract();
            contract.AccountId = acc.Id;
            contract.Status = status;
            contract.ContractTerm = months;
            contract.StartDate = startDate;
            lstContract.add(contract);
        }

        if(doInsert){
            insert lstContract;
        }
        return lstContract;
    }

    //massa para atualizar UM contrato Status
    public static Contract updateContractStatus(Boolean isVerifyStatus, Boolean doUpdate, Contract contract, String status){
        
        ContractTriggerHandler.setIsVerifyStatus(isVerifyStatus);

        Contract contractUpdate = contract;
        contractUpdate.Status = status;
        
        if(doUpdate){
            update contractUpdate;
        }
        return contractUpdate;
    }
    
    //massa para atualizar UM contrato com todos campos preenchidos
    public static Contract updateContractStatusFull(Boolean isVerifyStatus, Boolean doUpdate, Contract contract, String status){
    
        ContractTriggerHandler.setIsVerifyStatus(isVerifyStatus);

        Contract contractUpdate = contract;
        contractUpdate.Status = status;
        contractUpdate.PositionMonth__c = 1;
        contractUpdate.SpecialTerms = 'SpecialTerms';           
        contractUpdate.Description__c = 'Description';
        
        if(doUpdate){
            update contractUpdate;
        }
        return contractUpdate;
    }

    //massa para atualizar UM contrato StartDate
    public static Contract updateContractStartDate(Boolean isVerifyDate, Boolean doUpdate, Contract contract, Date value){
    
        ContractTriggerHandler.setIsVerifyDate(isVerifyDate);

        Contract contractUpdate = contract;
        contractUpdate.StartDate = value;
        
        if(doUpdate){
            update contractUpdate;
        }
        return contractUpdate;
    }
    
    //massa para atualizar VÁRIOS contratos
    public static List<Contract> updateContractListStatus(Boolean isVerifyStatus, Boolean doUpdate, List<Contract> lstContracts, String status){
        
        ContractTriggerHandler.setIsVerifyStatus(isVerifyStatus);

        List<Contract> lstContractUpdated = new List<Contract>();

        for(Contract contract : lstContracts) {
            contract.Status = status;
            lstContractUpdated.add(contract);
        }

        if(doUpdate){
            update lstContractUpdated;
        }
        return lstContractUpdated;
    }

    //massa para atualizar VÁRIOS contratos para Data
    public static List<Contract> updateContractListStartDate(Boolean isVerifyDate, Boolean doUpdate, List<Contract> lstContracts, Date value){

        ContractTriggerHandler.setIsVerifyDate(isVerifyDate);

        List<Contract> lstContractUpdated = new List<Contract>();

        for(Contract contract : lstContracts) {
            contract.StartDate = value;
            lstContractUpdated.add(contract);
        }

        if(doUpdate){
            update lstContractUpdated;
        }
        return lstContractUpdated;

    }
}