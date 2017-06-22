public with sharing class ECO_GBSDetailsController {
    ECO_GBSCore core;
	SharedServicesRequest__c ssr {get; set;}
    
    // Hide Approval Related List if Geo = Americas
    public Boolean displayApprovalRelatedList {get{ return ssr.Geography__c == 'Americas' ? false : true; }}
    
    // Disable Submit Request button for all Status' except Pending and On Hold
    public Boolean disableSubmitRequestButton {get { return (ssr.Status__c == 'Pending' || ssr.Status__c == 'On Hold') ? false : true; }}
    public Boolean isUserGBSAdmin { get{ return core.isUserGBSAdmin; }}
    public Boolean isRequestInSyncRelationship { get { return core.isRequestInSyncRelationship; }}
    public Boolean isEditButtonEnabled { get { return core.isEditButtonEnabled; }}
    public String editButtonHoverText { get { return core.editButtonHoverText; }}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public ECO_GBSDetailsController(ApexPages.StandardController stdController) {
        ssr = (SharedServicesRequest__c)stdController.getRecord();
        core = new ECO_GBSCore(ssr);
    }

    public PageReference submitRequest(){
        ssr.AssigntoSharedServices__c = true;
        ssr.Status__c = 'In Review';
        ssr.GenerateObjects__c = true;
        update ssr;

        ApexPages.StandardController controller = new ApexPages.StandardController(ssr);
        return controller.view();
    }
}