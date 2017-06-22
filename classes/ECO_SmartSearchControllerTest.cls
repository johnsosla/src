@isTest
private class ECO_SmartSearchControllerTest {
	
    static testMethod void testOnLoad() {
		PageReference pageRef = Page.ECO_SmartSearch;

		ECO_Smart_Search_Settings__c smartSearchSetting = new ECO_Smart_Search_Settings__c();
		smartSearchSetting.Analytics_End_Point__c = 'https://smartsearchrest.aecom.com:8443/rest/analytics';
        smartSearchSetting.CoveoTab_All_Expression1__c = 'NOT @sfid OR @objecttype==("User","ProjectC","Opportunity","Account") OR (@objecttype==("FeedItem") @sfparentname=(TPN,TPG) @sfcollaborationgroupid=({!collaborationGroups}))';
        smartSearchSetting.CoveoTab_All_Expression2__c = '(@objecttype==("FeedComment") @sffeeditemid=[[@sfid] @objecttype==("FeedItem","FeedComment") @sfparentname=(TPN,TPG) @sfcollaborationgroupid=({!collaborationGroups}) ])';
        smartSearchSetting.CoveoTab_People_Expression__c = '@objecttype==("User")';
        smartSearchSetting.CoveoTab_Practice_Expression_1__c = '(@objecttype==("FeedItem") @sfparentname=(TPN,TPG) @sfcollaborationgroupid=({!collaborationGroups})) OR (@sysspsitename = TPN)';
        smartSearchSetting.CoveoTab_Practice_Expression_2__c = '(@objecttype==("FeedComment") @sffeeditemid=[[@sfid] @objecttype==("FeedItem","FeedComment") @sfparentname=(TPN,TPG) @sfcollaborationgroupid=({!collaborationGroups}) ])';
        smartSearchSetting.CoveoTab_Projects_Expression__c = '(@objecttype==("ProjectC")) OR (NOT(@sysspsitename = TPN) AND @sysconnectortype == ("Sharepoint") AND @syscollection = ("Projects"))';
        smartsearchSetting.endPointURL__c = 'https://smartsearchrest.aecom.com:8443/rest/search/';
        smartSearchSetting.Filter_By_File_Type_Allowed_Values__c = 'doc,pdf,ppt,xls,Zip,xlsx,exe,wav,swf,rtf,msg,html,vsd';
        smartSearchSetting.Key__c = 'anyrandomstringffjkfajl;akf0452098234790dklqer098923498aslsdk2340';
        smartSearchSetting.OrganizationId__c = '';
        smartSearchSetting.Name = 'SmartSearch';
        smartSearchSetting.Search_CoveoSearchInterface_Expression__c = 'NOT(@sysfiletype==("spuserprofile"))';
        smartSearchSetting.TPN_Search_Expression1__c = '(@objecttype==("FeedItem") @sfparentname=(TPN,TPG) @sfcollaborationgroupid=({!collaborationGroups}))';
        smartSearchSetting.TPN_Search_Expression_2__c = '(@objecttype==("FeedComment") @sffeeditemid=[[@sfid] @objecttype==("FeedItem","FeedComment") @sfparentname=(TPN,TPG) @sfcollaborationgroupid=({!collaborationGroups}) ])';
        
        insert smartSearchSetting;
        
        Test.startTest();
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new ECO_SmartSearchMockHttpResponseGenerator());
        
        ECO_SmartSearchController controller = new ECO_SmartSearchController();
        controller.onLoad();
        
        System.assertEquals('token', controller.coveoToken);
        System.assertEquals('https://smartsearchrest.aecom.com:8443/rest/search/', controller.endPointURL);
        
        ECO_SmartSearch_TokenExt extension = new ECO_SmartSearch_TokenExt();
        System.assertEquals('token', extension.coveoToken);
        System.assertEquals('https://smartsearchrest.aecom.com:8443/rest/search/', extension.endPointURL);
        
        ECO_Temp_PortalController templateController = new ECO_Temp_PortalController();
        System.assertEquals('token', templateController.coveoToken);
        System.assertEquals('https://smartsearchrest.aecom.com:8443/rest/search/', templateController.endPointURL);
        Test.stopTest();
        
        ECO_SmartSearchController.getMyRecentSearch();
        ECO_SmartSearchController.pushMyRecentSearch('searchString');
        ECO_SmartSearchController.getMyRecentlyViewed();
        ECO_SmartSearchController.pushMyRecentlyViewed('recentlyViewed');
    }
}