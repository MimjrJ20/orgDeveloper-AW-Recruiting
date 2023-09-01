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
    public static String generatePDFContent(String idCandidate) {

        PageReference pref = Page.CandidatePDF; 
        pref.getParameters().put('id', idCandidate);
        pref.setRedirect(true);
        Blob bdata = pref.getContentAsPDF();
    
        String pdfContentBase64 = EncodingUtil.base64Encode(bdata);

        return pdfContentBase64;
    }
    


}