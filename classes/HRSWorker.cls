/*
*    Project Name        : eConnect
*    Project NameSpace   : HRS
*    Class Name        	 : HRSWorker
*    Date 				 : Oct 11th, 2016
*    Description         : An class to hold all values related to each http request.
*    			         : There are three different worker instances.
*    			         : ReadWorker - To store data from the Employee PII/NonPII
*    			         : EditWorker - To store data from the Case PII 
*    			         : AutoWorker - To store data from the Employee PII/NonPII 
*    			         : 				and prepopulate them into new case creation 
*/

public class HRSWorker {

	Public Map<String, Object> keyValueMap {get;set;}	//To store the key value map for this instance 

	Public List<String> fieldsList { get; set; }		//To store field list from custom metadata for this instance
	
	Public String baseUrl {get; set;}					//To store base URI
	
	Public Transient HttpResponse resultRsp {get; set;}	//To store complete http response 
	
	Public String dynamicQuery {get; set;}				//To store dynamic query created base on fieldList

	Public String idStr {get; set;}						//Not in use yet, but it's good to store the ID of this instace

	//Function : HRSWorker
	//Parameter : None
	//Return : None
	//Default class construction / variable creation
	Public HRSWorker() {

		keyValueMap = new Map<String, Object>();
		fieldsList = new List<String>();
		baseUrl = '';
		resultRsp = new HttpResponse();
		dynamicQuery = '';
		idStr = '';
	}
	
}