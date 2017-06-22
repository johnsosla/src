/*************************************************************************
*
* PURPOSE: Controller for popup project lookup
*
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
public class rsProjectLookupController {
    public List<rsProject> Projects {get; set;}

    public String SearchName {get; set;}
    public String SearchProjectNumber {get; set;}
    public String SearchLocation {get; set;}
    public String SearchClient {get; set;}

    public rsProjectLookupController() {
        SearchName = System.currentPageReference().getParameters().get('lksrch');
        if( String.isNotBlank(SearchName) ) {
            Projects = rsProject.find.getLookupResults(SearchName, SearchProjectNumber, SearchLocation, SearchClient);
        }
    }

    public PageReference refreshResults() {
        if ( String.isNotBlank(SearchName) || String.isNotBlank(SearchProjectNumber) || String.isNotBlank(SearchLocation) || String.isNotBlank(SearchClient) ) {
            Projects = rsProject.find.getLookupResults(SearchName, SearchProjectNumber, SearchLocation, SearchClient);
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must enter at least one search term'));
        }
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