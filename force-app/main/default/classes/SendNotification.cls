public with sharing class SendNotification {

    @AuraEnabled
    public static void sendEmail(String ownerId, List<String> recordIds){

        Messaging.reserveSingleEmailCapacity(1);

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        User user = UserController.getUserById(ownerId);

        List<String> toAddresses = new List<String>{user.Email};
        
        List<String> lisTitles = new List<String>();

        for (String id : recordIds) {

            Position__c pos = PositionDAO.getPositionById(id);
            lisTitles.add(pos.Name);
            System.debug('Email id: ' + id);
        }

        System.debug('lisTitles: ' + lisTitles);

        mail.setToAddresses(toAddresses);
        mail.setReplyTo('support@acme.com');
        mail.setSenderDisplayName('AW Computing - Recruiting');
        mail.setSubject('New Positions assigned: ' + lisTitles.size() + ' record(s).');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setPlainTextBody('You have new position(s): ' + lisTitles +' has been assigned.');
        mail.setHtmlBody('You have new position(s):<b> ' + lisTitles +' </b>has been assigned.<p>' +
                        'To view your Position(s) <a href=https://hr-mjr-dev-ed.develop.lightning.force.com/lightning/n/Recruitment_Management>Click Here.</a><br><br>' +
                        'Do not reply to this email.<br><br>' + 
                        'Sincerely,<br>' +
                        'AW');

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    @AuraEnabled
    public static void createNotifications(String ownerId, List<String> targetIds) {

        Set<String> lstIds = new Set<String>{ownerId};

        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName = 'Custom_Notification'];

        Messaging.CustomNotification notification = new Messaging.CustomNotification();
    
        for (String targetId : targetIds) {

            Position__c pos = PositionDAO.getPositionById(targetId);

            String namePosition = pos.Name;
            String nameChangePosition = pos.LastModifiedBy.Name;
            String statusPosition = pos.Status__c;
            Datetime dateTimePosition = pos.LastModifiedDate;
    
            notification.setTitle('New Position Assign: ' + namePosition);
            notification.setBody('The position ' +  namePosition + ' with status ' + statusPosition +  ' has been assigned to you at ' +  dateTimePosition + ' by ' + nameChangePosition + '.');
    
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(targetId);
            
            try {
                notification.send(lstIds);
                System.debug('Send notification recordId: ' + targetId);

            } catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage() + 'recordId: ' + targetId);
            }
        }
    

    }
    
    
}