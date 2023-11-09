@isTest
public with sharing class UserTest {

    //criação de registros 
    @TestSetup
    static void createTestData() {
        User user = UserTestDataFactory.createUser(true);
        Group queue = UserTestDataFactory.createQueue(true);
        GroupMember userMember = UserTestDataFactory.createGroupMember(true,queue.Id, user.Id);
    }

    //
    @isTest
    static void testGetCurrentUserName(){

        User user = [SELECT Id, FirstName, LastName FROM User WHERE Email = 'testuser@testorg.com' LIMIT 1];
        String nameUser = user.FirstName + ' ' + user.LastName;
        String currentUserName;

        System.runAs(user) {
            Test.startTest();
            currentUserName = UserController.getCurrentUserName();
            Test.stopTest();
        }
        Assert.areEqual(nameUser, currentUserName);
    }

    //
    @isTest
    static void testGetCurrentUserId(){

        User user = [SELECT Id FROM User WHERE Email = 'testuser@testorg.com' LIMIT 1];
        String currentUserId;

        System.runAs(user) {
            Test.startTest();
            currentUserId = UserController.getCurrentUserId();
            Test.stopTest();
        }
        Assert.areEqual(user.Id, currentUserId);
    }

    //
    @isTest
    static void testGetCurrentProfileId(){

        User user = [SELECT Id, ProfileId FROM User WHERE Email = 'testuser@testorg.com' LIMIT 1];
        String currentProfileId;

        System.runAs(user) {
            Test.startTest();
            currentProfileId = UserController.getCurrentUserProfileId();
            Test.stopTest();
        }
        Assert.areEqual(user.ProfileId, currentProfileId);
    }

    //
    @isTest
    static void testGetCurrentProfileName(){

        User user = [SELECT Id, ProfileId FROM User WHERE Email = 'testuser@testorg.com' LIMIT 1];
        String userProfileName = [SELECT Id, Name FROM Profile WHERE Id =:user.ProfileId].Name;
        String userProfileId;
        String currentProfileName;
        String currentProfileNameNA;

        Test.startTest();
        currentProfileName = UserController.getProfileName(user.ProfileId);
        currentProfileNameNA = UserController.getProfileName(userProfileId);
        Test.stopTest();

        Assert.areEqual(userProfileName, currentProfileName);
        Assert.areEqual('N/A', currentProfileNameNA);
    }

    //
    @isTest
    static void testGetUsers(){

        List<User> lstUser = [
            SELECT Id, Name, Profile.Name, ProfileId 
            FROM User 
            WHERE (IsActive = true) AND (Profile.Name != '') AND (Profile.Name != 'Chatter Free User') 
            ORDER BY Name ASC
        ];

        Test.startTest();
        List<User> lstUserController = UserController.getUsers();
        Test.stopTest();
        
        Assert.areEqual(lstUser.size(), lstUserController.size());
    }

    //
    @isTest
    static void testGetUserName(){

        User user = [SELECT Id, FirstName, LastName FROM User WHERE Email = 'testuser@testorg.com' LIMIT 1];
        User userQuery = [ SELECT Id, Name FROM User WHERE Id = :user.id AND IsActive = true LIMIT 1];

        String userName = user.FirstName + ' ' + user.LastName;
        
        String userIdInvalid = '005000000000000';
        String userIdNA, userGetName, nullMessage, naMessage;

        Boolean resultQuery = userQuery != null ? true : false;

        Test.startTest();
        userGetName = UserController.getUserName(userQuery.Id);
        naMessage = UserController.getUserName(userIdNA);
        try {
            nullMessage = UserController.getUserName(userIdInvalid);
        } catch (Exception error) {
            Boolean result = error.getMessage().contains('User not found');
            Assert.areEqual(true, result);
        }
        Test.stopTest();
        Assert.areEqual(userName, userGetName);
        Assert.areEqual(true, resultQuery);
        Assert.areEqual('N/A', naMessage);
    }

    @isTest
    static void testGetUserById(){
        
        User user = [SELECT Id, Username FROM User WHERE Email = 'testuser@testorg.com' LIMIT 1];
        
        Test.startTest();
        User userGet = UserController.getUserById(user.id);
        Test.stopTest();

        Assert.areEqual(user.Username, userGet.Username);
    }
 
    //
    @isTest
    static void testGetQueues(){

        List<Group> lstQueues = [SELECT Id, Name FROM Group WHERE Type = 'Queue' ORDER BY Name ASC];

        Test.startTest();
        List<Group> lstQueuesController = UserController.getQueues();
        Test.stopTest();
        
        Assert.areEqual(lstQueues.size(), lstQueuesController.size());
    }

    //
    @isTest
    static void testGetUserByQueueId(){

        Group queue = [SELECT Id, Name FROM Group WHERE DeveloperName = 'My_Queue_Developer_Name' LIMIT 1];

        Test.startTest();
        List<User> lstUserMember = UserController.getUserByQueueId(queue.Id);
        Test.stopTest();
        
        Assert.areEqual(1, lstUserMember.size());
    }
}