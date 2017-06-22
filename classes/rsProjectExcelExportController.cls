public with sharing class rsProjectExcelExportController {

    public List<rsPRTeamEmployee> searchResults { get; set; }

    private String mRecordId;

    public String xlsHeader {
        get
        {
            String strHeader = '';
            strHeader += '<?xml version="1.0" encoding="utf-16"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }

	public rsProjectExcelExportController() {
        mRecordId = ApexPages.currentPage().getParameters().get('id');

        if (!String.isBlank(mRecordId)) {
            List<rs_Search__c> searches = [select Id from rs_Search__c where Id = :mRecordId];

            if (!searches.isEmpty()) {
                List<Attachment> attachments = [Select Id, Body from Attachment where ParentId =: mRecordId limit 1];

                if (!attachments.isEmpty()) {
                    String attachBody = attachments[0].Body.toString();
                    attachments = null; // Salesforce is not clear on how their memory management works but this appears to clear out memory

                    searchResults = (List<rsPRTeamEmployee>) JSON.deserialize(attachBody, List<rsPRTeamEmployee>.class);
                    attachBody = null;

                }
                else {
                    System.debug(LoggingLevel.ERROR, 'No attachments found for rs_Search to populate JSON');
                }
            }
        }
	}






    //--Delete the record once we're done generating the xls
    public void deleteSearchRecord(){
        if(mRecordId != null){
            delete [select Id from rs_Search__c where Id = :mRecordId];
        }
    }
}