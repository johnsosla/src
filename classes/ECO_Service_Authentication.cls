public class ECO_Service_Authentication {

	public static boolean authenticateOracleToken(Id userId)
	{
		Datetime timestamp = DateTime.now();
		list<User> users = [select Id, Name, ShaKey__c, NormalTransDateTime__c from User where Id = :UserInfo.getUserId() and NormalTransDateTime__c > :timestamp  and ShaKey__c != null and ShaKey__c != '' limit 1];


		if(!users.isEmpty())
		{
			return true;
		}

		if(Test.isRunningTest()){
			return true;
		}

		return false;
	}

	public static boolean authenticateOracleTokenSecure(Id userId)
	{
		Datetime timestamp = DateTime.now();
		list<User> users = [select Id, Name, ShaKey__c, SecureTransDateTime__c from User where Id = :UserInfo.getUserId() and SecureTransDateTime__c > :timestamp  and ShaKey__c != null and ShaKey__c != '' limit 1];


		if(!users.isEmpty())
		{
			return true;
		}

		if(Test.isRunningTest()){
			return true;
		}

		return false;
	}	

	private static void storeAuthenticationForUser(PICRequestStatus requestStatus)
	{
		User user = [select Id, ShaKey__c, NormalTransDateTime__c, MobileTransDateTime__c, SecureTransDateTime__c from User where Id = :UserInfo.getUserId()];

		user.NormalTransDateTime__c = requestStatus.NormalTrans;
		user.SecureTransDateTime__c = requestStatus.SecureTrans;
		user.MobileTransDateTime__c = requestStatus.MobileTrans;
		user.ShaKey__c = requestStatus.ShaKey;

		update user;

	}

	public static string TestProxy(string url, string body){
		Http h = new Http();

	    // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
	    HttpRequest req = new HttpRequest();
	    req.setEndpoint(url);
	    req.setMethod('GET');
        
        req.setCompressed(true);
        req.setTimeout(30000);
        req.setClientCertificateName('ECOProjService');
        
        req.setBody(body);
        String returnResult = '';
        String result = '';
        PICRequestStatus requestStatus;
	    // Send the request, and return a response
	    try{
	    	HttpResponse res = h.send(req);
			result = res.getBody();
			System.Debug('BrentBrentBrentResult' + result);
			if(!String.isEmpty(result)){
		    	result = result.trim();
		    	
				requestStatus = new PICRequestStatus();
				requestStatus.Status = 'SENT';

				requestStatus = parseXMLResponse(result);
				returnResult = requestStatus.Status + requestStatus.Message;

			}
			else
				return 'ERROR: Body of the response from ORACLE is empty';
	    }
	    catch(Exception e)
	    {
	    	return e.getMessage() + result;
	    }

	    if(requestStatus.Status == 'SUCCESS')
	    {
	    	storeAuthenticationForUser(requestStatus);
	    	returnResult = 'SUCCESS';
	    }

	    return returnResult;
	}

	public static string TestProxyHR(string url, string body){
		Http h = new Http();

	    // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
	    HttpRequest req = new HttpRequest();
	    req.setEndpoint(url);
	    req.setMethod('GET');

        req.setCompressed(true);
        req.setTimeout(30000);
        if( !Test.isRunningTest() )
        	req.setClientCertificateName('eConnect');
        
        req.setBody(body);
        String returnResult = '';
        String result = '';
        PICRequestStatus requestStatus;
	    // Send the request, and return a response
	    try{
	    	HttpResponse res = h.send(req);

			result = res.getBody();

			if(!String.isEmpty(result)){
		    	result = result.trim();
		    	
				requestStatus = new PICRequestStatus();
				requestStatus.Status = 'SENT';

				requestStatus = parseXMLResponse(result);
				returnResult = requestStatus.Status + requestStatus.Message;

			}
			else
				return 'ERROR: Body of the response from ORACLE is empty';
	    }
	    catch(Exception e)
	    {	
	    	return e.getMessage() + result;
	    }

	    if(requestStatus.Status == 'SUCCESS')
	    {
	    	storeAuthenticationForUser(requestStatus);
	    	returnResult = 'SUCCESS';
	    }

	    return returnResult;
	}

    /*   Method to Get / Post / Put request for URI
    *    @param url 	: url of URI endpoint
    *    @param keys 	: a combination of the SHAKeys + N; 
    *    @param certName: certificate for additional security
    *    @param isPost	: Boolean value if request is post
    *    @param isPut	: Boolean value if request is update
    *    @param timeoutNumb : Timeout of the callout request
    *    @param FredId	: Frederation Id from the user
    *    @param jsonBody: a json formatted string
    *    @param eTag	: a values needed for update case
    *    return: httpResponse 
    */ 
	public static HttpResponse DynamicProxyRequestNew( String url, String keys, String certName, Boolean isPost, Boolean isPut, Integer timeoutNumb, String FredId, String jsonBody, String eTag  ){

		Http h = new Http();

	    // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
	    HttpRequest req = new HttpRequest();

	    if ( url != null )
	    	req.setEndpoint( url );
	    
	    if ( isPost ){
	    	req.setMethod( 'POST' );   
	        req.setHeader('Content-Type', 'application/json' );
	        req.setHeader('X-AECOM-Upn', FredId );	
        	req.setBody( jsonBody );      		           	    
	    } else if ( isPut ){
	    	req.setMethod( 'PUT' ); 
	        req.setHeader('Content-Type', 'application/json' );
	        req.setHeader('X-AECOM-Upn', FredId );	
        	req.setBody( jsonBody );
        	if ( eTag != null  )
	        	req.setHeader('If-Match', eTag );	    	
	    } else 
	    	req.setMethod( 'GET' );       
	    
	    if ( certName != null && !Test.isRunningTest() )
        	req.setClientCertificateName( certName );
        
        if ( keys != null )
        	req.setHeader('X-AECOM-ApiKey', keys+';S' );
        
        if ( timeoutNumb > 0 )
        	req.setTimeout( timeoutNumb );

		HttpResponse res = new HttpResponse();
	    // Send the request, and return a response

		if(Test.isRunningTest()){
	        HttpResponse resTest = new HttpResponse();
	        resTest.setHeader('Content-Type', 'application/json');
	        resTest.setBody('{"careerBand":"s2","birthDate":"1951-12-01"}');
	        resTest.setStatusCode(200);
	        resTest.setStatus('OK');
	        return resTest;
		}

	    try{

	    	 res = h.send(req);

	    }
	    catch(Exception e)
	    {
	    	return null;
	    }

	    return res;
	}


    public class PICRequestStatus {
        public String Status {get;set;}
        public String Message {get;set;}
        public String Details {get;set;}
        public DateTime NormalTrans {get;set;}
        public DateTime SecureTrans {get;set;}  
        public DateTime MobileTrans {get;set;}      
        public String ShaKey {get; set;}
    } 	

    private static PICRequestStatus parseXMLResponse(String xml){
        //example of response xml
        //<?xml version="1.0" encoding="UTF-8"?> <PICRequestStatus> <Status>SUCCESS</Status> <Message></Message> <Details></Details> </PICRequestStatus>

        Dom.Document doc = new Dom.Document();
        doc.load(xml);

        PICRequestStatus requestStatus = new PICRequestStatus();
        String result = '';

        for(dom.XmlNode node : doc.getRootElement().getChildElements()) {
            String nodeName = node.getName().toLowerCase();
            if(nodeName =='status') {
                requestStatus.Status = node.getText();
            }
            else if(nodeName == 'message') 
            {
                requestStatus.Message = node.getText();
            } 
            else if(nodeName == 'details') 
            {
                requestStatus.Details = node.getText();
            }
            else if(nodeName == 'shakey')
            {
            	requestStatus.ShaKey = node.getText();
            }
            else if(nodeName == 'outputparams')
            {
            	dom.xmlNode node1 = node.getChildElement('NormalTrans', null);
            	//requestStatus.NormalTrans = DateTime.parse(node1.getText());
            	System.Debug('BrentBrentBrent' + node1.getText());
            	requestStatus.NormalTrans = ECO_Utils_Date.getDateTimeFromPICRequestStatusString(node1.getText());
            	System.Debug('BrentBrentBrent' + requestStatus.NormalTrans);
            	dom.xmlNode node2 = node.getChildElement('ShaKey', null);
            	requestStatus.ShaKey = node2.getText();

            	dom.xmlNode node3 = node.getChildElement('SecureTrans', null);
            	requestStatus.SecureTrans = ECO_Utils_Date.getDateTimeFromPICRequestStatusString(node3.getText());            	

            	dom.xmlNode node4 = node.getChildElement('MobileTrans', null);
            	requestStatus.MobileTrans = ECO_Utils_Date.getDateTimeFromPICRequestStatusString(node4.getText());            	

            }
			else if(nodeName == 'normaltrans')
			{
				requestStatus.NormalTrans = DateTime.parse(node.getText());
			}  
			else if(nodeName == 'SecureTrans')
			{
				requestStatus.SecureTrans = DateTime.parse(node.getText());
			} 
			else if(nodeName == 'MobileTrans')
			{
				requestStatus.MobileTrans = DateTime.parse(node.getText());
			} 
        } 

        return requestStatus;       
    } 	

}