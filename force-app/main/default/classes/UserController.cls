public with sharing class UserController {

    @AuraEnabled
    public static String getCurrentUserName() {
        return UserInfo.getName();
    }
    
}