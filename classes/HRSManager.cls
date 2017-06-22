/*
*    Project Name        : eConnect
*    Project NameSpace   : HRS
*    Class Name          : HRSManager
*    Date                : Oct 11th, 2016
*    Description         : A main class to store all data to drive the HRS API Data component
*                        : A parent class to HRSWorker class
*/

public class HRSManager {

    Public Case hrcase {get; set;}              //To store the case object [CaseNumber, Type, TrackingId]
    Public JSON2Employee employee {get;set;}    //To store the employee data
    Public JSON2Case casepii {get;set;}         //To Store the case data
    Public HRSWorker readWorker {get; set;}     //To store all variables to construct the read URI
    Public HRSWorker editWorker {get; set;}     //To store all variables to construct the write URI
    Public Boolean isLocked {get; set;}         //A boolean to determine if the form is locked for further editing
    Public String pageName {get; set;}          //A variable to identify page origin and display data correctly
    Public String inputStr { get; set; }        //A variable to store input value list
    Public String picklistStr { get; set; }     //A variable to store picklist value list
    Public String dateStr { get; set; }         //A variable to store date value list
    Public String eTag {get; set;}              //A variable to store the eTag for PUT operations
    Public List<String> inputList {get; set;}   //A List of all the input values
    Public List<String> picklistList { get; set; }   //A List of all the picklist values
    Public List<String> dateList { get; set; }  //A List of all the date values
    Public Map<String, List<SelectOption>> picklistOptionsMapping { get; set; } //A List of all the picklist option
	Public Boolean isEditRead { get; set; }     //A boolean to determine if the form is allow to be edit
	Public Boolean isEditEdit { get; set; }     //A boolean to determine if the form is in edit mode
    Public FINAL Integer MAXTIMEOUT = 12000;    //A static variable to declare the timeout for the http callout

    //Function : HRSManager
    //Parameter : None
    //Return : None
    //Default class construction / variable creation
    public HRSManager() {

        hrcase = new Case();
        employee = new JSON2Employee();
        casepii = new JSON2Case();
        readWorker = new HRSWorker();
        editWorker = new HRSWorker();
        picklistOptionsMapping = new Map<String, List<SelectOption>>();
        
        //To get the Employee and Case URI from Custom Setting
        ECO_IntegrationEndpoints__c employeeEP, caseEP;
        employeeEP = ECO_IntegrationEndpoints__c.getInstance('HRS_EMPLOYEE');
        caseEP = ECO_IntegrationEndpoints__c.getInstance('HRS_CASE');
        //To store into their respective worker instance
        readWorker.baseUrl = employeeEP.EndPointUrl__c;
        editWorker.baseUrl = caseEP.EndPointUrl__c;

        inputStr = '';          //Used to restrict display of only input fields
        picklistStr = '';       //Used to restrict display of only picklist fields
        dateStr = '';           //Used to restrict display of only date fields

        inputList = new List<String>();
        picklistList = new List<String>();
        dateList = new List<String>();

        pageName = ApexPages.currentPage().getUrl().split('apex/')[1];
        eTag = '';                  //A variable to store the eTag for put operation

        isLocked = false;           //Assume the page is not locked
		isEditRead = true;          //Initialize the edit page to default to read only
		isEditEdit = false;         //Initialize the edit page not to be edit when first load
    }

    //Function : prePopulateJsonStr
    //Parameter : None
    //Return : String 
    //To populate a json string when a new case is create and new data is not present
    //in the database.  It will only prefill the matching field, it doesn't save any
    //data into the database.  The request will only map the requested field into
    //this new json string.
    Public String prePopulateJsonStr(){
        String jsonStr;
        Map<String, Object> jsonMap = new Map<String, Object>();

        //To loop through the input type list and put only the requested field into the Json
        //if Field match the employee api data.  Default into NULL value
        for ( String s : inputList ){
            if ( readWorker.keyValueMap.get(s) != null )
                jsonMap.put( s, readWorker.keyValueMap.get(s) );
            else 
                jsonMap.put( s, NULL);

        }

        //To loop through the picklist type list and put only the requested field into the Json
        //if Field match the employee api data.  Default into none selection
        for ( String s : picklistList ){
            if ( readWorker.keyValueMap.get(s) != null )
                jsonMap.put( s, readWorker.keyValueMap.get(s) );
            else 
            jsonMap.put( s, '--None--');
        }

        //To loop through the date type list and put only the requested field into the Json
        //if Field match the employee api data.  Default into today's 

        Date dt = Date.newinstance(1900, 1, 1);

        for ( String s : dateList ){
            if ( readWorker.keyValueMap.get(s) != null )
                jsonMap.put( s, readWorker.keyValueMap.get(s) );
            else 
            jsonMap.put( s, String.valueOf( dt ) );
        }

        //Transform the Map into a string json format
        jsonStr = System.JSON.serialize( jsonMap );

        return jsonStr;
    }

    //Function : setPicklistMapping
    //Parameter : None
    //Return : None 
    //To selected required picklist values mapping identified from the picklistList List
    //Creates a picklist field mapping with the associated picklist options
    Public void setPicklistMapping(){

        if ( picklistList.size() > 0 ){
            try { 
                List<HRS_API_Picklist__mdt> hrsPicklists = [select Id, Picklist_Field__c, Picklist_Value__c from HRS_API_Picklist__mdt where 
                                                            Picklist_Field__c in: picklistList and isActive__c = true  order by Picklist_Value__c asc ];

                for ( HRS_API_Picklist__mdt pl : hrsPicklists ) {
                    if ( picklistOptionsMapping.containsKey( pl.Picklist_Field__c )  ){
                        List<SelectOption> str = picklistOptionsMapping.get( pl.Picklist_Field__c );
                            str.add( new SelectOption( pl.Picklist_Value__c, pl.Picklist_Value__c) );
                            picklistOptionsMapping.put( pl.Picklist_Field__c, str );
                        
                    } else {
                            picklistOptionsMapping.put( pl.Picklist_Field__c, new List<SelectOption> { new SelectOption( pl.Picklist_Value__c , pl.Picklist_Value__c) } );
                        
                    }    
                }
            } catch (Exception ex ){
                System.debug('The following exception has occurred: ' + ex.getMessage());
            }
        }
    }   

    //Function : CancelEdit
    //Parameter : None
    //Return : PageReference NULL
    //When user enter into the edit mode and clicks on the cancel button
    //Page will go back to the read mode, with data still presist 
    //A message alerts the user that the data is not saved.
	Public PageReference CancelEdit(){
		isEditEdit = false;
		isEditRead = true;
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.recordCancel));

		return null;
	}

    //Function : EnableEdit
    //Parameter : None
    //Return : PageReference NULL
    //When user clicks the edit button on the edit page
    //Page will render from read mode into edit mode
    //All input field will render with their data type
	Public PageReference EnableEdit(){
		isEditEdit = true;
		isEditRead = false;
		return null;
	}

    //Function : SaveCase
    //Parameter : None
    //Return : PageReference NULL
    //The main operation when user clicks on the save button
    //It will parse the data from JSON2Case object into json string
    //We will need to compare both values and determine what to send to database
    //We are looping both keyValueMap and store only the changes into finalValueMap
    //Be default we added the unique key value into the json [caseNumber, trackingId]
    //
	Public pageReference SaveCase(){

		String JSONString = JSON.serialize( casepii );

		Map<String, Object> keyValueMapNew = JSON2Case.parseValue( JSONString );
		Map<String, Object> finalValueMap = new Map<String, Object>();
        Map<String, Object> newCasefinalValueMap = new Map<String, Object>();

		finalValueMap.put('CaseNumber', hrcase.CaseNumber );
		finalValueMap.put('trackingId', hrcase.Tracking_ID__c);
        finalValueMap.put('caseStatus', hrcase.Status);

        newCasefinalValueMap.put('CaseNumber', hrcase.CaseNumber );
        newCasefinalValueMap.put('trackingId', hrcase.Tracking_ID__c);
        newCasefinalValueMap.put('caseStatus', hrcase.Status);

        //On a brand new case, all values should be saved to database
        //On a update case, only the changed value should be saved to database
		for (  String s : editWorker.fieldsList ){

			if ( keyValueMapNew.get( s ) != editWorker.keyValueMap.get( s ) ){
				finalValueMap.put ( s,  keyValueMapNew.get( s ) ) ;
			}

            newCasefinalValueMap.put ( s,  keyValueMapNew.get( s ) ) ;
		}

        //This is to query the oracle key and formatting for URI
        //For security purpose, this is on demand only and not stored in anywhere
    	User user = [select Id, ShaKey__c, FederationIdentifier from User where Id = :UserInfo.getUserId()];
    	String key = user.ShaKey__c;
    	String fid = user.FederationIdentifier;

		String finalJSONString = '';

        //Creating the http request
        //it depends on if the request is a POST ( new case entry ) OR PUT ( update existing case)
        //the eTag field will drives which api request based on the Flag
		HttpResponse a = new HttpResponse();
		if ( eTag == '' ){
            finalJSONString = JSON.serialize( newCasefinalValueMap );
			a =	ECO_Service_Authentication.DynamicProxyRequestNew( editWorker.baseUrl , key, 'eConnect', TRUE, false, MAXTIMEOUT, fid, finalJSONString, eTag );
        }
		else {
            finalJSONString = JSON.serialize( finalValueMap );
			a =	ECO_Service_Authentication.DynamicProxyRequestNew( editWorker.baseUrl , key, 'eConnect', false, TRUE, MAXTIMEOUT, fid, finalJSONString, eTag );
        }

        //To identify the status code and output result to the end user
        //We only display the status code to end user
		if ( a.getStatusCode() == 204 )
	       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, System.Label.recordSaved ));
        else if ( a.getStatusCode() == 400 )
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.recordNotSaved + ' Code 400: '+ a.getBody() ));
        else if ( a.getStatusCode() == 401 )
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.recordNotSaved + ' Code 401: '+ a.getBody()  ));
		else if ( a.getStatusCode() == 409 )
	       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.recordNotSaved + ' Code 409: '+ a.getBody()   ));
        else if ( a.getStatusCode() == 412 )
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.recordNotSaved + ' Code 412: '+ a.getBody()   ));
	    else
	       ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.recordNotSaved + a.getStatusCode() ));

        //after the transmission is done, the page will become locked and user will have to
        //refresh the page to be able to edit again. A concurrency validation is in place to
        //check if two employee modify the same record
		isLocked = true;
		isEditRead = true;	
        isEditEdit = false;
        
		return null;
	
	}
}