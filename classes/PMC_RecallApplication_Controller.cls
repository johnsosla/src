public class PMC_RecallApplication_Controller {
    public PMCertReq__c certReq { get; set ;}

    public PMC_RecallApplication_Controller(ApexPages.StandardController sc) {
        certReq = (PMCertReq__c)PMC_CertificationRequest.find.byId(sc.getId());
    }

    public PageReference loadAction() {

        Map<String, Schema.RecordTypeInfo> rt_map = Schema.getGlobalDescribe().get('PMCertReq__c').getDescribe().getRecordTypeInfosByName();
        String initialRtId = rt_map.get('Initial Certification').getRecordTypeId();

        certReq.CertificationRequestStatus__c = 'Application Recalled';
        certReq.RecordTypeId = initialRtId; 
        certReq.OwnerId = certReq.Candidate__c;

        update certReq;

        PageReference viewPage = new ApexPages.StandardController(certReq).view();
        viewPage.setRedirect(true);
        return viewPage;

    }
}