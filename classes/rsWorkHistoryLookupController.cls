/*************************************************************************
*
* PURPOSE: Controller for popup work history lookup
*
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
public class rsWorkHistoryLookupController {
    public List<rs_Profile_Part__c> Parts {get; set;}
    private String mUserId;

    public rsWorkHistoryLookupController() {
        mUserId = System.currentPageReference().getParameters().get('userId');
        Parts = rsProfilePart.find.getWorkHistoryLookupResults(mUserId);
    }

    public String getFormTag()
    {
        return System.currentPageReference().getParameters().get('frm');
    }

    public String getTextBox()
    {
        return System.currentPageReference().getParameters().get('txt');
    }

}