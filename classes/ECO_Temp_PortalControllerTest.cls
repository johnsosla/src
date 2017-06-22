@isTest
public with sharing class ECO_Temp_PortalControllerTest {
	
    static testMethod void testPageLoadAndNavigation () {
        PageReference pageRef = Page.ECO_Temp_Portal;
		
		ECO_Smart_Search_Settings__c smartSearchCS = new ECO_Smart_Search_Settings__c();
		smartSearchCS.Name='SmartSearch';
		smartSearchCS.Analytics_End_Point__c = 'https://smartsearchrest.aecom.com:8443/rest/analytics';
		smartSearchCS.CoveoTab_All_Expression1__c = 'NOT @sfid OR @objecttype==("User","ProjectC","Opportunity","Account", "ServiceCatalogEntryC", "FeedItem")';
		smartSearchCS.CoveoTab_All_Expression2__c = '@objecttype==("FeedComment")';
		smartSearchCS.CoveoTab_People_Expression__c = '@objecttype==("User")';
		smartSearchCS.CoveoTab_Practice_Expression_1__c = '(@objecttype==("FeedItem") @sfparentname=(TPN,TPG)) OR (@sysspsitename = TPN) OR (@objecttype==("ServiceCatalogEntryC"))';
		smartSearchCS.CoveoTab_Practice_Expression_2__c = '(@objecttype==("FeedComment") @sffeeditemid=[[@sfid] @objecttype==("FeedItem","FeedComment") @sfparentname=(TPN,TPG) ])';
		smartSearchCS.CoveoTab_Projects_Expression__c = '(@objecttype==("ProjectC")) OR (NOT(@sysspsitename = TPN) AND @sysconnectortype == ("Sharepoint") AND @syscollection = ("Projects"))';
		smartSearchCS.endPointURL__c = 'https://smartsearchrest.aecom.com:8443/rest/search/';
		smartSearchCS.Filter_By_File_Type_Allowed_Values__c = 'doc,pdf,ppt,xls,Zip,xlsx,exe,wav,swf,rtf,msg,html,vsd,mp4';
		smartSearchCS.Key__c = 'anyrandomstringffjkfajl;akf0452098234790dklqer098923498aslsdk2340';
		smartSearchCS.Search_CoveoSearchInterface_Expression__c = 'NOT(@sysfiletype==("spuserprofile"))';
		smartSearchCS.TPN_Search_Expression1__c = '(@objecttype==("FeedItem") @sfparentname=(TPN,TPG) @sfcollaborationgroupid=({!collaborationGroups}))';
		smartSearchCS.TPN_Search_Expression_2__c = '(@objecttype==("FeedComment") @sffeeditemid=[[@sfid] @objecttype==("FeedItem","FeedComment") @sfparentname=(TPN,TPG) @sfcollaborationgroupid=({!collaborationGroups}) ])';
		   
		insert smartSearchCS;
		
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new ECO_SmartSearchMockHttpResponseGenerator());
		
		ECO_SmartSearchController controller = new ECO_SmartSearchController();
        controller.onLoad();
        
        System.assertEquals('token', controller.coveoToken);
        System.assertEquals('https://smartsearchrest.aecom.com:8443/rest/search/', controller.endPointURL);
        
        ECO_SmartSearch_TokenExt extension = new ECO_SmartSearch_TokenExt();
        System.assertEquals('token', extension.coveoToken);
        System.assertEquals('https://smartsearchrest.aecom.com:8443/rest/search/', extension.endPointURL);
        
		ECO_Temp_PortalController templateController = new ECO_Temp_PortalController();
		templateController.onLoad();
		templateController.retrieveCustomSettingParameters();
		
		templateController.goToApplicationConfiguration();
		templateController.goToReportBuilder();
		templateController.goToNewProject();
		templateController.goToNewOpportunity();
		Test.stopTest();
    }
}