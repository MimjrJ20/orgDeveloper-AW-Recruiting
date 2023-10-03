public with sharing class UserController {

    @AuraEnabled
    public static String getCurrentUserName() {
        return UserInfo.getName();
    }

    @AuraEnabled
    public static Id getCurrentUserId() {
        return UserInfo.getUserId();
    }

    @AuraEnabled
    public static String getCurrentUserProfileId() {
        return UserInfo.getProfileId();
    }

    @AuraEnabled
    public static String getProfileName(String id) {

        String nameProfile;

        if (!String.isBlank(id)) {
            nameProfile = [SELECT Id, Name FROM Profile WHERE Id = :id].Name;
        } else {
            nameProfile = 'NO';
        }

        return nameProfile;
    }

    @AuraEnabled
    public static List<User> getUsers() {
        return [SELECT Id, Name FROM User WHERE IsActive = true];
    }

    
}