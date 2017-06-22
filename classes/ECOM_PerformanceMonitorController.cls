public class ECOM_PerformanceMonitorController {

	@AuraEnabled
	public static String getHeaderInfo(Object loadTime, Object networkLatency, String pathName, String userAgent, String language, String host) { 
		System.debug('Got request: L:' + loadTime + '|N:' + networkLatency + '|P:' + pathName);
        
        Browser_Request__c br = new Browser_Request__c(); 
        br.time__c = Datetime.now(); 
        br.user__c = UserInfo.getUserId(); 

        insert br; 

        List<Browser_Request_Header__c> toInsert = new List<Browser_Request_Header__c>(); 
        Browser_Request_Header__c requestHeader = new Browser_Request_Header__c(); 
        requestHeader.browser_request__c = br.id; 
        requestHeader.key__c = 'key'; 
        requestHeader.value__c = 'value'; 
        requestHeader.Load_Time__c = String.valueOf(loadTime); 
        requestHeader.Network_Latency__c = String.valueOf(networkLatency); 
        requestHeader.Path_Name__c = pathName;
        requestHeader.Accept_Language__c = language;
        requestHeader.Host__c = host;
        if(userAgent.length() > 255){ 
            requestHeader.User_Agent__c = userAgent.substring(0,254); 
        } else { 
            requestHeader.User_Agent__c = userAgent; 
        } 
 

        DateTime d = datetime.now(); 
        requestHeader.Request_Time__c = String.valueOf(d.timeGmt()); 
        toInsert.add(requestHeader); 

        insert toInsert; 

        return 'OK';
    }


}