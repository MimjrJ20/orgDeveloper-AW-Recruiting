public class AccountController {
 
    @AuraEnabled(cacheable=true)
    public static List < Account > fetchAccounts() {

        return [
            SELECT Id, Name, Industry
            FROM Account LIMIT 5
        ];
        
    }
     
}