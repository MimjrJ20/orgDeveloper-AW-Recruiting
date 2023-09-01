public with sharing class CandidatePDFController {

    @AuraEnabled
    public static void savePDFCandidate(String idCandidate, String pdfBody, String jobName) {

        Blob pdfBlob = EncodingUtil.base64Decode(pdfBody);

        ContentVersion cv = new ContentVersion();
        cv.Title = jobName + ' - Generated Proposal.pdf';
        cv.VersionData = pdfBlob; 
        cv.PathOnClient = jobName + ' - Generated Proposal.pdf';

        insert cv;

        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = conDocId;
        cdl.LinkedEntityId = idCandidate; 
        cdl.ShareType = 'V'; 
        cdl.Visibility = 'AllUsers'; 

        insert cdl;
    }

    @AuraEnabled
    public static String generatePDFContent(String idCandidate, String city, String state, String country, String candidateNumber, String candidateName, 
                                            String positionName, String accountName, String description, String skills, String department, String salary, 
                                            String manager, String startDate, String deadline) {

        PageReference pref = Page.CandidatePDF; 
        pref.getParameters().put('id', idCandidate);
        pref.getParameters().put('city', city);
        pref.getParameters().put('state', state);
        pref.getParameters().put('country', country);
        pref.getParameters().put('candidateNumber', candidateNumber);
        pref.getParameters().put('candidateName', candidateName);
        pref.getParameters().put('positionName', positionName);
        pref.getParameters().put('accountName', accountName);
        pref.getParameters().put('description', description);
        pref.getParameters().put('skills', skills);
        pref.getParameters().put('department', department);
        pref.getParameters().put('salary', salary);
        pref.getParameters().put('manager', manager);
        pref.getParameters().put('startDate', startDate);
        pref.getParameters().put('deadline', deadline);
        pref.setRedirect(true);
        Blob bdata = pref.getContentAsPDF();
    
        String pdfContentBase64 = EncodingUtil.base64Encode(bdata);

        return pdfContentBase64;
    }
    


}