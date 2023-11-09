public with sharing class UserController {
    //o nome da classe era para ser UserDAO - depois ver isso
    
    //pegar o NOME do usuário que está navegando na página
    @AuraEnabled
    public static String getCurrentUserName() {
        return UserInfo.getName();
    }

    //pegar o ID do usuário que está navegando na página
    @AuraEnabled
    public static Id getCurrentUserId() {
        return UserInfo.getUserId();
    }

    //pegar o PROFILE ID do usuário que está navegando na página
    @AuraEnabled
    public static String getCurrentUserProfileId() {
        return UserInfo.getProfileId();
    }

    //pegar o PROFILE NAME do usuário que está navegando na página
    @AuraEnabled
    public static String getProfileName(String id) {

        String nameProfile;

        if (!String.isBlank(id)) {
            nameProfile = [SELECT Id, Name FROM Profile WHERE Id = :id].Name;
        } else {
            nameProfile = 'N/A';
        }

        return nameProfile;
    }

    //pegar a lista dos usuários 
    @AuraEnabled
    public static List<User> getUsers() {
        return [
            SELECT Id, Name, Profile.Name, ProfileId 
            FROM User 
            WHERE (IsActive = true) AND (Profile.Name != '') AND (Profile.Name != 'Chatter Free User') 
            ORDER BY Name ASC
        ];
    }

    //pegar o NOME do usuário por id 
    @AuraEnabled
    public static String getUserName(String id) {
        
        if (!String.isBlank(id)) {
            try {
                User user = [ SELECT Id, Name FROM User WHERE Id = :id AND IsActive = true LIMIT 1];
                return user.Name;
            } catch (Exception error) {
                return 'User not found. Error: ' + error.getMessage();
            }
        } else {
            return 'N/A';
        }
    }

    //buscar usuário por Id
    public static User getUserById(String id){

        return [
            SELECT Id, Username, LastName, FirstName, Name, CompanyName, Title, City, State, Country, Address, Email, Alias, IsActive, ProfileId, 
                    CreatedDate, CreatedById, LastModifiedDate, LastModifiedById 
            FROM User 
            WHERE Id =:id
        ];
    }
    
    //pegar a lista dos filas 
    @AuraEnabled
    public static List<Group> getQueues() {
        return [SELECT Id, Name FROM Group WHERE Type = 'Queue' ORDER BY Name ASC];
    }    

    //buscar usuários por queueId
    public static List<User> getUserByQueueId(String id){
        List<User> userMembers = new List<User>();
    
        Group queue = [SELECT Id FROM Group WHERE Type='Queue' AND Id = :id LIMIT 1];
    
        if (queue != null) {
            List<GroupMember> groupMembers = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :queue.Id];
            
            for (GroupMember member : groupMembers) {

                String memberId = member.UserOrGroupId;

                if (String.isNotBlank(memberId) && memberId.startsWith('005')) {
                    
                    User user = getUserById(memberId);
                    if (user != null) {
                        userMembers.add(user);
                    }
                }
            }
        }
    
        return userMembers;
    }        
}