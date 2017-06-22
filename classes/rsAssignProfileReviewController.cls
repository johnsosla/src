/*************************************************************************
*
* PURPOSE: Controller for the the page used to assign/reassign Profile Reviews
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
public with sharing class rsAssignProfileReviewController
{
    private User mReviewee;
    private Boolean mIsReassign;
    public rsAssignProfileReviewController() {
        mReviewee = (User)rsProfile.find.byId(ApexPages.currentPage().getParameters().get('UserId')).getObj();
        mIsReassign = (ApexPages.currentPage().getParameters().get('type') == rsProfileReviewsController.REV_ASSIGNEDTOME);
    }

    public User getReviewee() {
        return mReviewee;
    }

    public Boolean getIsReassign() {
        return mIsReassign;
    }


    //A valid assignment is either a content manager OR empty (unassign)
    public PageReference save() {
        PageReference pr = null;
        if( mReviewee.Profile_Reviewer__c != null && !Profile_Info__c.getInstance(mReviewee.Profile_Reviewer__c).Is_Content_Manager__c) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Not_Content_Manager));
        } else if (mReviewee.Id == UserInfo.getUserId() ) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.Cant_Review_Self));
        } else {
            try{
                rsDataUtils.save(mReviewee);
            } catch (DmlException ex) {
                if (ex.getMessage().toLowerCase().contains('circular') ) {
                    return null;
                }
                else throw ex;
            }
            pr = Page.rsProfileReviews;
        }
        return pr;
    }
}