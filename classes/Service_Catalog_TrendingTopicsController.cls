public with sharing class Service_Catalog_TrendingTopicsController {

    public ConnectApi.TopicPage trendData { get; set; }
    public String strBaseURL{ get; set; }

    public Service_Catalog_TrendingTopicsController()
    {

            strBaseURL = URL.getSalesforceBaseUrl().toExternalForm().replace('http:','https:');
            strBaseURL = strBaseURL+'/';
            List<Service_Catalog_Settings__c> mcs = Service_Catalog_Settings__c.getall().values();
            String chatterGroupId = mcs[0].ChatterId__c;
            

//'0F9M00000009QBv'
        trendData = ConnectApi.Topics.getRecentlyTalkingAboutTopicsForGroup(null,chatterGroupId) ;

    }
/*
    public ConnectApi.TopicPage gettrendData() 
    {
        


        return trendData;
    }*/
}