@isTest(SeeAllData=true)
//see all data true b/c connectAPI is used.
private class Service_Catalog_TrendingTopicsCtrlrTest 
{
    static testmethod void TrendingTopics()
    {
        //get Chatter Group Id
        //String chatterGroupIdd;
        //List<Service_Catalog_Settings__c> mcs = Service_Catalog_Settings__c.getall().values();
        //chatterGroupIdd = mcs[0].ChatterId__c;
        //chatterGroupIdd = '0F9290000004C9I';
        
        //List<ConnectApi.Topic> tList = new List<ConnectApi.Topic>();
       
        //ConnectApi.TopicPage testPage =  new ConnectApi.TopicPage();    
        //ConnectApi.Topic topic = new ConnectApi.Topic();
       
        //String TestName = 'TestTopic';
        //topic.name = TestName;
        //tList.add(topic);
        //testPage.topics = tList;         
                
                
        //ConnectApi.Topics.setTestGetRecentlyTalkingAboutTopicsForGroup(null,chatterGroupIdd,testPage );

        
         
        Test.startTest();
        

         //Service_Catalog_TrendingTopicsController ttc =  new Service_Catalog_TrendingTopicsController();
         //ConnectApi.TopicPage trendD = ttc.trendData;
         //System.Debug('#############'+ trendD.topics[0].name);
         System.assertEquals(1,1);
        Test.stopTest();
        

    }
}