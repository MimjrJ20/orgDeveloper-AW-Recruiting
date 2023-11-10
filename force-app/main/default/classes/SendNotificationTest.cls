@IsTest
public class SendNotificationTest {

    @TestSetup
    static void setupTestData() {

        Account acc = AccountTestDataFactory.createAccountSample(true);
        Contract contract = ContractTestDataFactory.createContract(true, acc.Id, 1, Date.today(),'New');
        Contract contractUpdated = ContractTestDataFactory.updateContractStatusFull(false, true, contract, 'Activated',1);
        Position__c position = PositionTestDataFactory.createPosition(true,acc.Id,'New','Pending');

        System.runAs(UserTestDataFactory.createUser(true)) {
            User user = UserTestDataFactory.createUser(true);
            Group queue = UserTestDataFactory.createQueue(true);
            GroupMember userMember = UserTestDataFactory.createGroupMember(true,queue.Id, user.Id);
        }
    }

    @IsTest
    static void testSendEmailToQueue() {
        Group queue = [SELECT Id, Name FROM Group WHERE DeveloperName = 'My_Queue_Developer_Name' LIMIT 1];
        Position__c position = [SELECT Id FROM Position__c LIMIT 1];

        Test.startTest();
        SendNotification.sendEmail(queue.Id, new List<String>{position.Id});
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        Assert.areEqual(1, invocations, 'An email should be sent');

    }


    @IsTest
    static void testSendEmailToUser() {

        User user = [SELECT Id, FirstName, LastName FROM User WHERE Email = 'testuser@testorg.com' LIMIT 1];
        Position__c position = [SELECT Id FROM Position__c LIMIT 1];

        Test.startTest();
        SendNotification.sendEmail(user.Id, new List<String>{position.Id});
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();     
        
        Assert.areEqual(1, invocations, 'An email should be sent');

    }

    @IsTest
    static void testCreateNotifications() {

        Position__c position = [SELECT Id FROM Position__c LIMIT 1];

        Test.startTest();
        SendNotification.createNotifications(UserInfo.getUserId(), new List<String>{position.Id});
        Test.stopTest();

        Assert.areEqual(true, SendNotification.isNotificationSent, 'A notification should be sent');
    }

}
