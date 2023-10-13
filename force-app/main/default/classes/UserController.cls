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
        return [SELECT Id, Name, Profile.Name, ProfileId FROM User WHERE (IsActive = true) AND (Profile.Name != '') AND (Profile.Name != 'Chatter Free User') ORDER BY Name ASC];
    }

    @AuraEnabled
    public static List<Group> getQueues() {
        return [SELECT Id, Name FROM Group WHERE Type = 'Queue' ORDER BY Name ASC];
    }    

    @AuraEnabled
    public static String getUserName(String id) {
        
        if (!String.isBlank(id)) {
            try {
                User user = [SELECT Id, Name FROM User WHERE Id = :id AND IsActive = true LIMIT 1];
                if (user != null) {
                    return user.Name;
                } else {
                    return 'User not found';
                }
            } catch (QueryException e) {
                return 'Error: ' + e.getMessage();
            }
        } else {
            return 'N/A';
        }

    }
    
}