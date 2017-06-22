public with sharing class rsAttachmentController {

    public Attachment attachment {
        get {
            if (attachment == null)
            attachment = new Attachment();
            return attachment;
        }
        set;
    }

    private String mRetUrl;

    private rs_Profile_Part__c mProfilePart;

    public rsAttachmentController(){
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String retUrl = params.get('retUrl');
        String returnTab = params.get('tab');
        String returnUser = params.get('ownerId');
        retUrl += '?u=' + returnUser +'&tab='+returnTab;
        String subTabParam = 'tab.'+returnTab+'.subtab';
        String subTabReturn = params.get(subTabParam);
        retUrl += ('&'+subTabParam + '=' + subTabReturn);

        mRetUrl = retUrl;

        mProfilePart = (rs_Profile_Part__c)rsProfilePart.find.byId(params.get('partId')).getObj();
    }

    public PageReference upload() {

        PageReference pg = null;

        //attachment.OwnerId = ApexPages.currentPage().getParameters().get('ownerId'); AECR-550, this throws an exception if the owner is not current user and current user doesn't have modify all data
        attachment.ParentId = ApexPages.currentPage().getParameters().get('partId');

        if(attachment.Body == null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Select_File_Error));
            return null;
        }

        try {

          if(mProfilePart.Attachment_Id__c != null){
            delete [select Id from Attachment where Id = :mProfilePart.Attachment_Id__c];
          }
          insert attachment;

        } catch (DMLException e) {
              System.debug('!! Exception Uploading Attachment. Cause: ' + e );
              System.debug('!! Exception Uploading Attachment. Attachment: ' + attachment);
              ApexPages.addMessages(e);

              return null;

        } finally {

          if(attachment.Id != null){
            this.mProfilePart.Attachment_Id__c = attachment.Id;
            this.mProfilePart.Attachment_Name__c = attachment.Name;

            update this.mProfilePart;
          }

          attachment.body = null; // clears the viewstate

          attachment = new Attachment();

        }

        //---Update last modified data on User, assume only done by the actual user, not a CM User
        User targetUser = [Select Id, Last_User_Profile_Update__c from User where id = :mProfilePart.User__c];
        targetUser.Last_User_Profile_Update__c = DateTime.now();

        try {
            update targetUser;
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
            System.debug ('!!Exception on profile part save, User DateTime update. ' + ex + ex.getStackTraceString());
        }

        pg = new PageReference(mRetUrl);

        return pg;
    }

    public PageReference cancel(){
        return new PageReference(mRetUrl);
    }

    public PageReference getAttachmentStatus(){
        if(mProfilePart.Attachment_Id__c != null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, Label.Attachment_Max_Error));
        }

        return null;
    }
}