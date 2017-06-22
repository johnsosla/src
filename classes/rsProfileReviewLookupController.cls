/*************************************************************************
*
* PURPOSE: Controller for custom lookup on rsAssignProfileReview
*
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
public class rsProfileReviewLookupController {
    public List<User> UserResults {get; set;}
    public String SearchName {get; set;}

    public rsProfileReviewLookupController() {
        SearchName = System.currentPageReference().getParameters().get('lksrch');
        refreshResults();
    }


    public PageReference refreshResults() {
        UserResults = rsProfile.find.getProfileReviewLookupResults(SearchName);
        return null;
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