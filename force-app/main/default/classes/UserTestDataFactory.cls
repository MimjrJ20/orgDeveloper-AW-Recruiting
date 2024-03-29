@isTest
public with sharing class UserTestDataFactory {

    //massa para usuário
    public static User createUser(Boolean doInsert){

        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        String uniqueUserName = 'testuser' + DateTime.now().getTime() + '@testorg.com';

        User user = new User();
        user.Alias = 'testuser';
        user.Email = 'testuser@testorg.com';
        user.EmailEncodingKey ='UTF-8';
        user.FirstName ='User';
        user.LastName ='Test';
        user.LanguageLocaleKey ='en_US';
        user.LocaleSidKey ='en_US';
        user.ProfileId = adminProfile.Id;
        user.TimeZoneSidKey ='America/Los_Angeles';
        user.UserName = uniqueUserName;

        if (doInsert) {
            insert user;
        }


        return user;
    }

    //massa para usuário a partir do perfil
    public static User userByProfileId(Id profileId){

        String uniqueUserName = 'testuser' + DateTime.now().getTime() + '@testorg.com';

        User user = new User();
        user.Alias = 'testuser';
        user.Email = 'testuser@testorg.com';
        user.EmailEncodingKey ='UTF-8';
        user.FirstName ='User';
        user.LastName ='Test';
        user.LanguageLocaleKey ='en_US';
        user.LocaleSidKey ='en_US';
        user.ProfileId = profileId;
        user.TimeZoneSidKey ='America/Los_Angeles';
        user.UserName = uniqueUserName;

        return user;
    }

    //
    public static Group createQueue(Boolean doInsert) {

        Group queue = new Group();
        queue.Type = 'Queue'; 
        queue.Name = 'My Queue Name';
        queue.DeveloperName = 'My_Queue_Developer_Name';
        queue.Email = 'queueemail@testorg.com';
        
        if (doInsert) {
            insert queue;
        }
    
        return queue;
    }

    //
    public static GroupMember createGroupMember(Boolean doInsert, Id queueId, Id userId) {

        GroupMember userMember = new GroupMember();
        userMember.GroupId = queueId;
        userMember.UserOrGroupId  = userId;

        if (doInsert) {
            insert userMember;
        }
    
        return userMember;
    }
    
}