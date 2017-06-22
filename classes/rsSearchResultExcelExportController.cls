public with sharing class rsSearchResultExcelExportController {
    public List<rsSearchResult> Results {get; set;}
    public List<String> Headers {get; set;}
    private String mRecordId;
    public String xlsHeader {
                                get {
                                    String strHeader = '';
                                    strHeader += '<?xml version="1.0" encoding="utf-16"?>';
                                    strHeader += '<?mso-application progid="Excel.Sheet"?>';
                                    return strHeader;
                                }
                            }
    public rsSearchResultExcelExportController() {
        String resultsId = ApexPages.currentPage().getParameters().get('id');
        if(resultsId != null){
            List<rs_Search__c> searches = [select Result_Fields__c,User_Fields__c,PR_Team_Employee_Fields__c, Search_Fields__c,Overflow_Fields__c,
                                            Overflow_Fields_2__c,Overflow_Fields_3__c,Overflow_Fields_4__c,Overflow_Fields_5__c,Overflow_Fields_6__c,Overflow_Fields_7__c,
                                            Overflow_Fields_8__c,Overflow_Fields_9__c
                                           from rs_Search__c where Id = :resultsId];
            if(!searches.isEmpty()){
                mRecordId = searches[0].Id;
                results = new List<rsSearchResult>();
                if(String.isNotBlank(searches[0].Result_Fields__c)) results.addAll((List<rsSearchResult>) JSON.deserialize((String)searches[0].Result_Fields__c, List<rsSearchResult>.class));
                if(String.isNotBlank(searches[0].User_Fields__c)) results.addAll((List<rsSearchResult>) JSON.deserialize((String)searches[0].User_Fields__c, List<rsSearchResult>.class));
                if(String.isNotBlank(searches[0].PR_Team_Employee_Fields__c)) results.addAll((List<rsSearchResult>) JSON.deserialize((String)searches[0].PR_Team_Employee_Fields__c, List<rsSearchResult>.class));
                if(String.isNotBlank(searches[0].Overflow_Fields__c)) results.addAll((List<rsSearchResult>) JSON.deserialize((String)searches[0].Overflow_Fields__c, List<rsSearchResult>.class));
                if(String.isNotBlank(searches[0].Overflow_Fields_2__c)) results.addAll((List<rsSearchResult>) JSON.deserialize((String)searches[0].Overflow_Fields_2__c, List<rsSearchResult>.class));
                if(String.isNotBlank(searches[0].Overflow_Fields_3__c)) results.addAll((List<rsSearchResult>) JSON.deserialize((String)searches[0].Overflow_Fields_3__c, List<rsSearchResult>.class));
                if(String.isNotBlank(searches[0].Overflow_Fields_4__c)) results.addAll((List<rsSearchResult>) JSON.deserialize((String)searches[0].Overflow_Fields_4__c, List<rsSearchResult>.class));
                if(String.isNotBlank(searches[0].Overflow_Fields_5__c)) results.addAll((List<rsSearchResult>) JSON.deserialize((String)searches[0].Overflow_Fields_5__c, List<rsSearchResult>.class));
                if(String.isNotBlank(searches[0].Overflow_Fields_6__c)) results.addAll((List<rsSearchResult>) JSON.deserialize((String)searches[0].Overflow_Fields_6__c, List<rsSearchResult>.class));
                if(String.isNotBlank(searches[0].Overflow_Fields_7__c)) results.addAll((List<rsSearchResult>) JSON.deserialize((String)searches[0].Overflow_Fields_7__c, List<rsSearchResult>.class));
                if(String.isNotBlank(searches[0].Overflow_Fields_8__c)) results.addAll((List<rsSearchResult>) JSON.deserialize((String)searches[0].Overflow_Fields_8__c, List<rsSearchResult>.class));
                if(String.isNotBlank(searches[0].Overflow_Fields_9__c)) results.addAll((List<rsSearchResult>) JSON.deserialize((String)searches[0].Overflow_Fields_9__c, List<rsSearchResult>.class));
                headers = (List<String>) JSON.deserialize((String)searches[0].Search_Fields__c, List<String>.class);
            }
            // Added in to remove Full Name from headers
            // Resulted from Name having always being a default field
            Integer remove = 0;
            for(Integer i = 0; i < results.size(); i++) {
                if(headers[i] == 'Name') {
                    headers.remove(i);
                    remove = i;
                    break;
                }
            }
            for(rsSearchResult res : results) {
                res.cells.remove(remove);
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