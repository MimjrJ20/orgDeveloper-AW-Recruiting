public with sharing class SendNotification {

    @AuraEnabled
    public static void sendEmail(List<String> emails, List<String> titlesPositions){

        Messaging.reserveSingleEmailCapacity(2);

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        String[] toAddresses = emails;
        //String[] ccAddresses = new String[] {'smith@gmail.com'};

        mail.setToAddresses(toAddresses);
        //mail.setCcAddresses(ccAddresses);
        mail.setReplyTo('support@acme.com');
        mail.setSenderDisplayName('Salesforce Support');
        mail.setSubject('New Position Assigned: ' + titlesPositions);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setPlainTextBody('Your Position(s): ' + titlesPositions +' has been assigned.');
        mail.setHtmlBody('Your Position(s):<b> ' + titlesPositions +' </b>has been created.<p>'+
            'To view your Position(s) <a href=https://hr-mjr-dev-ed.develop.lightning.force.com/lightning/n/Recruitment_Management>Click Here.</a>');

        // Send the email you have created.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}