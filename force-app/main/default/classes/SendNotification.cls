public with sharing class SendNotification {

    @AuraEnabled
    public static void sendEmail(List<String> emails, List<String> titlesPositions){

        Messaging.reserveSingleEmailCapacity(2);

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        String[] toAddresses = emails;
        //String[] ccAddresses = new String[] {'smith@gmail.com'}; ver depois

        mail.setToAddresses(toAddresses);
        //mail.setCcAddresses(ccAddresses);
        mail.setReplyTo('support@acme.com');
        mail.setSenderDisplayName('Salesforce Support');
        mail.setSubject('New Position Assigned: ' + titlesPositions);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setPlainTextBody('Your Position(s): ' + titlesPositions +' has been assigned.');
        mail.setHtmlBody('Your Position(s):<b> ' + titlesPositions +' </b>has been assigned.<p>'+
            'To view your Position(s) <a href=https://hr-mjr-dev-ed.develop.lightning.force.com/lightning/n/Recruitment_Management>Click Here.</a>');

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    @AuraEnabled
    public static void createNotifications(List<String> ids, List<String> targetIds) {
        // Get the Id for our custom notification type
        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='Custom_Notification'];
        
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        // Set the contents for the notification
        notification.setTitle('Apex Custom Notification');
        notification.setBody('The notifications are coming from INSIDE the Apex!');

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(targetId);
        
        // Actually send the notification
        try {
            notification.send(recipientsIds);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
    
}