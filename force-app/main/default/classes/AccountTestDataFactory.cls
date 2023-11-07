@isTest
public with sharing class AccountTestDataFactory {

    public static Account createAccountSample(Boolean doInsert){
        Account acc = new Account();
        acc.Name = 'Test Account';
        if(doInsert){
            insert acc;
        }
        return acc;
    }

    public static List<Account> createAccountSampleList(Boolean doInsert, Integer numAcc){
        
        List<Account> lstAcc = new List<Account>();

        for(Integer i = 1; i <= numAcc; i++) {
            Account acc = new Account();
            acc.Name = 'Test Account ' + i;
            lstAcc.add(acc);
		}

        if(doInsert){
            insert lstAcc;
        }
        return lstAcc;
    }
}