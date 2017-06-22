/** ------------------------------------------------------------------------------------------------------
* @Description The service class to log and format errors<br/>
* <b>NOTE</b> - there is without sharing on the class so that anyone can get an error they encounted logged into the system.
*
* @Author      NTT Data - Deborah Orth - deborah.orth@nttdata.com
* @Date        April 2016
* Steve MunLeeuw Aug 2016, added record to debug message, for failed insert/update getId() returns null
*-----------------------------------------------------------------------------------------------------*/
public without sharing class ECO_Service_ErrorLog {
	public static Boolean loggingSetupDone = false;
		
	/**
	 * Writes an entry in the error log when a standard system exception is encountered
	 *
	 * @Author  NTT Data - Deborah Orth - deborah.orth@nttdata.com
	 * @Date    April 2016
	 *
	 * @param	thrownException - the exception caught in the calling class
	 * @return 	void
	 **/
	public static void logException( Exception thrownException){
		ErrorLog__c logEntry;
		
		try {

			//baseline exception info
			logEntry = new ErrorLog__C( LineNumber__c = thrownException.getLineNumber(),
										Message__c = thrownException.getMessage().left(5000),
										Level__c = 'ERROR',
										StackTrace__c = thrownException.getStackTraceString().left(32768),
										Type__c = thrownException.getTypeName().left(100)
									  );
			
			//get the class name from the stack trace string
			logEntry.ClassOrPage__c = logEntry.StackTrace__c.substring((logEntry.StackTrace__c.left(6) == 'class.' ? 6 : 0), 
																				logEntry.StackTrace__c.indexOf(':')).left(2000);
		
			//save the log entry
			writeEntryToLog(logEntry, ApexPages.Severity.ERROR); 

		} catch( Exception e){
			//this wasn't supposed to happen...
			//JSON Error: System.debug('****>Error in ECO_Service_ErrorLog.logException1: ' + JSON.serializePretty(thrownException));
			System.debug('****>Error in ECO_Service_ErrorLog.logException1: ' + thrownException);
		}
	}

	/**
	 * Writes an entry in the error log when a standard system exception is encountered and the method wants more data logged
	 *
	 * @Author  NTT Data - Deborah Orth - deborah.orth@nttdata.com
	 * @Date    October 2016
	 *
	 * @param	thrownException - the exception caught in the calling class
	 * @param	extraData - a string of extra information to log
	 * @return 	void
	 **/
	public static void logException( Exception thrownException, String extraData){
		ErrorLog__c logEntry;
		
		try {

			//baseline exception info
			logEntry = new ErrorLog__C( LineNumber__c = thrownException.getLineNumber(),
										Message__c = thrownException.getMessage().left(5000),
										Level__c = 'ERROR',
										StackTrace__c = (thrownException.getStackTraceString() + '\nExtra Data: ' + extraData).left(32768),
										Type__c = thrownException.getTypeName().left(100)
									  );
			
			//get the class name from the stack trace string
			logEntry.ClassOrPage__c = logEntry.StackTrace__c.substring((logEntry.StackTrace__c.left(6) == 'class.' ? 6 : 0), 
																				logEntry.StackTrace__c.indexOf(':')).left(2000);
		
			//save the log entry
			writeEntryToLog(logEntry, ApexPages.Severity.ERROR); 

		} catch( Exception e){
			//this wasn't supposed to happen...
			//System.debug('****>Error in ECO_Service_ErrorLog.logException2: ' + JSON.serializePretty(thrownException) + '\n' + extraData);
			System.debug('****>Error in ECO_Service_ErrorLog.logException2: ' + thrownException + '\n' + extraData);
		}
	}

	/**
	 * Writes an entry in the error log for records that error out during a Database.Insert() or Database.Update() call
	 *
	 * @Author  NTT Data - Deborah Orth - deborah.orth@nttdata.com
	 * @Date    April 2016
	 *
	 * @param	records - the records being inserted or updated
	 * @param	results - the save results from an insert or update
	 * @param	classMethod - the class and method name where the error occurred
	 * @return 	void
	 **/
	public static void logException( List<SObject> records, List<Database.SaveResult> results, String classMethod){
		Integer recordCounter = 0;
		String errorDetails = '';

		// Iterate through each returned result
		for( Database.SaveResult sr : results) {
			if( !sr.isSuccess()) {
				errorDetails += buildSaveDetailHtml( records[recordCounter], (Id)sr.getId());

				// Record failed, so get all errors                
				for( Database.Error err : sr.getErrors()) {
					errorDetails += '<li>Status Code: ' + err.getStatusCode() + ' - ' + err.getMessage() + '</li>';
					errorDetails += '<li>Fields: ' + err.getFields() + '</li>';
					errorDetails += '<li>Record: ' + records[recordCounter] + '</li></ul></p>';
				}
			}
			recordCounter++;
		}

		try {
			//save the log entry, if there is anything to log
			if( !String.isEmpty(errorDetails)){
				writeEntryToLog( new ErrorLog__c( Message__c = 'Database.SaveResult', 
												Level__c = 'ERROR',
												ClassOrPage__c = classMethod.left(2000),
												Detail__c = errorDetails.left(32768)
												),
								ApexPages.Severity.ERROR
								); 
			}

		} catch( Exception e){
			//this wasn't supposed to happen...
			System.debug('****>Error in ECO_Service_ErrorLog.logException(saveResult): ' + JSON.serializePretty(results));
		}
	}

	/**
	 * Writes an entry in the error log for EACH record that fails in a Database.Insert() or Database.Update() call
	 *
	 * @Author	AECOM - Duke Ames
	 * @Date    August 2016
	 *
	 * @param	records - the records being inserted or updated
	 * @param	results - the save results from an insert or update
	 * @param	classMethod - the class and method name where the error occurred
	 * @param	type - developer defined value to categorize the error, can be used to filter the ListView, 100 char
	 * @return 	void
	 **/
	public static void logException( List<SObject> records, List<Database.SaveResult> results, String classMethod, String type){
		
		ErrorLog__c[] errorLogList = new List<ErrorLog__c>();

		Integer recordCounter = 0;
		String errorDetails = '';
		String recordString = '';

		String recordId = '';
		String recordId2 = '';

		// Iterate through each returned result
		for( Database.SaveResult sr : results) {
			if( !sr.isSuccess()) {
				errorDetails = '';
				recordId = 'unknown';

				errorDetails += buildSaveDetailHtml( records[recordCounter], (Id)sr.getId());
				recordString = String.valueOf(records[recordCounter]);

				// Record failed, so get all errors                
				for( Database.Error err : sr.getErrors()) {
					errorDetails += '<li>Status Code: ' + err.getStatusCode() + ' - ' + err.getMessage() + '</li>';
					errorDetails += '<li>Fields: ' + err.getFields() + '</li>';
					errorDetails += '<li>Record: ' + recordString + '</li></ul></p>';
				}
			
				if (type == 'User to Contact Trigger Contact Insert' || type == 'User To Contact Trigger Contact Update'){
					
					Contact contact = (Contact) records.get(recordCounter);

					if (type == 'User To Contact Trigger Contact Update') {
						recordId = contact.Id;
					}

					recordId2 = contact.User__c;
				}
				else {
					Integer idStartIndex = recordString.indexOf(', Id=') + 5;

					if (idStartIndex < 5) {
						idStartIndex = recordString.indexOf(':{Id=') + 5;
					}

					if (idStartIndex > 4) {
					    Integer idEndIndex = idStartIndex + 18;
					    recordId = recordString.substring(idStartIndex, idEndIndex);
					}
				}

				ErrorLog__c errorLog = new ErrorLog__c( Message__c = 'Database.SaveResult', 
															Level__c = 'ERROR',
															ClassOrPage__c = classMethod.left(2000),
															Detail__c = errorDetails.left(32768),
															Type__c = type,
															RecordId__c = recordId,
															Recordid2__c = recordId2
														);

				errorLogList.add(errorLog);
			}

			recordCounter++;
		}

		try {
			//save the ErrorLog list, if there is anything to log
			if(errorLogList.size() > 0){
				insertErrorLogList(errorLogList, ApexPages.Severity.ERROR, type);
			}

		} catch( Exception e){
			//this wasn't supposed to happen...
			System.debug('****>Error in ECO_Service_ErrorLog.logException(saveResult): ' + JSON.serializePretty(results));
		}
	}

	/**
	 * Writes an entry in the error log for records that error out during a approval process call
	 *
	 * @Author  NTT Data - Timothy Chiang
	 * @Date    Jul 2016
	 *
	 * @param	records - the records being inserted or updated
	 * @param	results - the save results from an approval process call
	 * @param	classMethod - the class and method name where the error occurred
	 * @return 	void
	 **/
	public static void logException( List<Approval.ProcessWorkItemRequest> records, List<Approval.ProcessResult> results, String classMethod){
		Integer recordCounter = 0;
		String errorDetails = '';

		// Iterate through each returned result
		for( Approval.ProcessResult sr : results) {
			if( !sr.isSuccess()) {
				//errorDetails += buildSaveDetailHtml( records[recordCounter], (Id)sr.getEntityId());
				errorDetails += '<p>Workitem - Id: ' + (Id)sr.getEntityId() + '<ul>';

				// Record failed, so get all errors                
				for( Database.Error err : sr.getErrors()) {
					errorDetails += '<li>Status Code: ' + err.getStatusCode() + ' - ' + err.getMessage() + '</li>';
					errorDetails += '<li>Fields: ' + err.getFields() + '</li></ul></p>';
				}
			}
			recordCounter++;
		}

		try {
			//save the log entry, if there is anything to log
			if( !String.isEmpty(errorDetails)){
				writeEntryToLog( new ErrorLog__c( Message__c = 'Database.SaveResult', 
												Level__c = 'ERROR',
												ClassOrPage__c = classMethod.left(2000),
												Detail__c = errorDetails.left(32768)
												),
								ApexPages.Severity.ERROR
								); 
			}

		} catch( Exception e){
			//this wasn't supposed to happen...
			System.debug('****>Error in ECO_Service_ErrorLog.logException(saveResult): ' + JSON.serializePretty(results));
		}
	}


	/**
	 * Writes an entry in the error log for records that error out during a Database.Upsert()
	 *
	 * @Author  NTT Data - Deborah Orth - deborah.orth@nttdata.com
	 * @Date    April 2016
	 *
	 * @param	records - the records being upserted
	 * @param	results - the save results from the upsert
	 * @param	classMethod - the class and method name where the error occurred
	 * @return 	void
	 **/
	public static void logException( List<SObject> records, List<Database.UpsertResult> results, String classMethod){
		Integer recordCounter = 0;
		String errorDetails = '';

		// Iterate through each returned result
		for( Database.UpsertResult ur : results) {
			if( !ur.isSuccess()) {
				errorDetails += buildSaveDetailHtml( records[recordCounter], (Id)ur.getId());

				// Record failed, so get all errors                
				for( Database.Error err : ur.getErrors()) {
					errorDetails += '<li>Status Code: ' + err.getStatusCode() + ' - ' + err.getMessage() + '</li>';
					errorDetails += '<li>Fields: ' + err.getFields() + '</li></ul></p>';
				}
			}
			recordCounter++;
		}

		try {
			//save the log entry, if there is anything to log
			if( !String.isEmpty(errorDetails)){
				writeEntryToLog( new ErrorLog__c( Message__c = 'Database.UpsertResult', 
												Level__c = 'ERROR',
												ClassOrPage__c = classMethod.left(2000),
												Detail__c = errorDetails.left(32768)
												),
								ApexPages.Severity.ERROR
								); 
			}

		} catch( Exception e){
			//this wasn't supposed to happen...
			System.debug('****>Error in ECO_Service_ErrorLog.logException(upsert): ' + JSON.serializePretty(results));
		}
	}

	/**
	 * Writes an entry in the error log for records that error out during a Database.Delete()
	 *
	 * @Author  NTT Data - Deborah Orth - deborah.orth@nttdata.com
	 * @Date    April 2016
	 *
	 * @param	records - the records being deleted
	 * @param	results - the save results from the delete
	 * @param	classMethod - the class and method name where the error occurred
	 * @return 	void
	 **/
	public static void logException( List<SObject> records, List<Database.DeleteResult> results, String classMethod){
		Integer recordCounter = 0;
		String errorDetails = '';

		// Iterate through each returned result
		for( Database.DeleteResult dr : results) {
			if( !dr.isSuccess()) {
				errorDetails += buildSaveDetailHtml( records[recordCounter], (Id)dr.getId());

				// Record failed, so get all errors                
				for( Database.Error err : dr.getErrors()) {
					errorDetails += '<li>Status Code: ' + err.getStatusCode() + ' - ' + err.getMessage() + '</li>';
					errorDetails += '<li>Fields: ' + err.getFields() + '</li></ul></p>';
				}
			}
			recordCounter++;
		}

		try {
			//save the log entry, if there is anything to log
			if( !String.isEmpty(errorDetails)){
				writeEntryToLog( new ErrorLog__c( Message__c = 'Database.DeleteResult', 
												Level__c = 'ERROR',
												ClassOrPage__c = classMethod.left(2000),
												Detail__c = errorDetails.left(32768)
												),
								ApexPages.Severity.ERROR
								); 
			}

		} catch( Exception e){
			//this wasn't supposed to happen...
			System.debug('****>Error in ECO_Service_ErrorLog.logException(delete): ' + JSON.serializePretty(results));
		}
	}

	/**
	 * Writes an entry in the error log for records that error out during a Database.Undelete()
	 *
	 * @Author  NTT Data - Deborah Orth - deborah.orth@nttdata.com
	 * @Date    April 2016
	 *
	 * @param	records - the records being Undelete
	 * @param	results - the save results from the Undelete
	 * @param	classMethod - the class and method name where the error occurred
	 * @return 	void
	 **/
	public static void logException( List<SObject> records, List<Database.UndeleteResult> results, String classMethod){
		Integer recordCounter = 0;
		String errorDetails = '';

		// Iterate through each returned result
		for( Database.UndeleteResult udr : results) {
			if( !udr.isSuccess()) {
				errorDetails += buildSaveDetailHtml( records[recordCounter], (Id)udr.getId());

				// Record failed, so get all errors                
				for( Database.Error err : udr.getErrors()) {
					errorDetails += '<li>Status Code: ' + err.getStatusCode() + ' - ' + err.getMessage() + '</li>';
					errorDetails += '<li>Fields: ' + err.getFields() + '</li></ul></p>';
				}
			}
			recordCounter++;
		}

		try {
			//save the log entry, if there is anything to log
			if( !String.isEmpty(errorDetails)){
				writeEntryToLog( new ErrorLog__c( Message__c = 'Database.UndeleteResult', 
												Level__c = 'ERROR',
												ClassOrPage__c = classMethod.left(2000),
												Detail__c = errorDetails.left(32768)
												),
								ApexPages.Severity.ERROR
								); 
			}

		} catch( Exception e){
			//this wasn't supposed to happen...
			System.debug('****>Error in ECO_Service_ErrorLog.logException(undelete): ' + JSON.serializePretty(results));
		}
	}

	/**
	 * Formats a pageMessage & adds it to the current page and logs the error in the errorLog, no level or details specified
	 *
	 * @Author  NTT Data - Deborah Orth - deborah.orth@nttdata.com
	 * @Date    April 2016
	 *
	 * @param	errorMessage - the message to put on the page
	 * @return 	void
	 **/
	public static void formatPageError( String errorMessage){
		ECO_Service_ErrorLog.formatPageError( errorMessage, ApexPages.Severity.ERROR, '');
	}

	/**
	 * Formats a pageMessage & adds it to the current page and logs the error in the errorLog, no level or details specified
	 * Also combines the error logging functionality
	 *
	 * @Author  NTT Data - Deborah Orth - deborah.orth@nttdata.com
	 * @Date    April 2016
	 *
	 * @param	thrownException - the exception caught in the calling class
	 * @param	errorMessage - the message to put on the page
	 * @return 	void
	 **/
	public static void formatPageError( Exception thrownException, String errorMessage){
		logException(thrownException);
		ECO_Service_ErrorLog.formatPageError( errorMessage, ApexPages.Severity.ERROR, '');
	}

	/**
	 * Formats a pageMessage & adds it to the current page and logs the error in the errorLog, no details specified
	 *
	 * @Author  NTT Data - Deborah Orth - deborah.orth@nttdata.com
	 * @Date    April 2016
	 *
	 * @param	errorMessage - the message to put on the page
	 * @param	errorLevel - ApexPages.Severity level
	 * @return 	void
	 **/
	public static void formatPageError( String errorMessage, ApexPages.Severity errorLevel){
		ECO_Service_ErrorLog.formatPageError( errorMessage, errorLevel, '');
	}

	/**
	 * Formats a pageMessage & adds it to the current page and logs the error in the errorLog
	 *
	 * @Author  NTT Data - Deborah Orth - deborah.orth@nttdata.com
	 * @Date    April 2016
	 *
	 * @param	errorMessage - the message to put on the page
	 * @param	errorLevel - ApexPages.Severity level
	 * @param	errorDetails - additional details for the smaller print section in the error message on the page
	 * @return 	void
	 **/
	public static void formatPageError( String errorMessage, ApexPages.Severity errorLevel, String errorDetails){
		ErrorLog__c logEntry;
		String url = ApexPages.currentPage().getUrl();
		String pageName = url.right(url.length() - url.indexOf('apex/') + 5).left(url.indexOf('?'));
		
		try {
			logEntry = new ErrorLog__C( Message__c = errorMessage.left(5000),
										Level__c = errorLevel.name(),
										Type__c = 'Custom',
										Detail__c = errorDetails.left(32768),
										ClassOrPage__c = pageName.left(2000)
									  );

			//update the log
			writeEntryToLog( logEntry, errorLevel);
			
			//format the page message
			ApexPages.Message formattedMessage = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage, errorDetails);
			ApexPages.addMessage(formattedMessage);

		} catch( Exception e){
			//this wasn't supposed to happen...
			System.debug('****>Error in ECO_Service_ErrorLog.formatPageError: ' + e.getMessage());
		}
	}

	/**
	 * Formats a detail HTML message for the log
	 *
	 * @Author  NTT Data - Deborah Orth - deborah.orth@nttdata.com
	 * @Date    April 2016
	 *
	 * @param	obj - the record from the DML record set
	 * @param	resultId - the record Id from the result
	 * @return 	String
	 **/
	private static String buildSaveDetailHtml( SObject obj, Id resultId){
		String returnString = '';

		try {
			returnString = '<p>' 
				+ obj.getSObjectType().getDescribe().getName()
				+ ' - Id: ' 
				+ resultId;
			returnString += ' Name: ' 
				+ obj.get('Name'); 
		} catch (Exception e){
			System.debug('*****>Error in ECO_Service_ErrorLog.buildSaveDetailHtml: ' + e.getMessage()); //probably is managed package
		} finally {
			returnString += '<ul>';
		}
		return returnString;
	}

	/**
	 * Does the actual writing to the DB or handling an error here by writing to the debug log.  Similar to insertErrorLogList
	 *
	 * @Author  NTT Data - Deborah Orth - deborah.orth@nttdata.com
	 * @Date    April 2016
	 *
	 * @param	logEntry - the record from the DML record set
	 * @param	errorLevel - System.Severity Enum value
	 * @return 	
	 **/
	 //FYI - FATAL=0, ERROR=1, WARNING=2, INFO=3, CONFIRM=4
	private static void writeEntryToLog( ErrorLog__c logEntry, ApexPages.Severity errorLevel){
		List<ECO_ErrorLogSettings__c> loggingSetup = new List<ECO_ErrorLogSettings__c>();

		if( !ECO_Service_ErrorLog.loggingSetupDone) {
			loggingSetup = [SELECT IsEnabled__c, ThresholdLevel__c FROM ECO_ErrorLogSettings__c];
			ECO_Service_ErrorLog.loggingSetupDone = true;
		}
		
		if( loggingSetup.isEmpty() || (loggingSetup[0].IsEnabled__c && errorLevel.Ordinal() <= loggingSetup[0].ThresholdLevel__c)){
			try {
				insert logEntry;
			} catch (Exception e){
				System.debug( '*****>Error writing ErrorLog to DB: ' + JSON.serializePretty(logEntry));
			}
		}
	}





	/**
	 * Does the actual writing to the DB or handling an error here by writing to the debug log.  Similar to writeEntryToLog except takes a List of ErrorLogs
	 *
	 * @Author  AECOM - Duke Ames
	 * @Date    August 2016
	 *
	 * @param	errorLogList - List of ErrorLog objects to insert
	 * @param	errorLevel - System.Severity Enum value
	 * @param	type - developer defined value to categorize the error, can be used to filter the ListView, 100 char
	 * @return 	
	 **/
	 //FYI - FATAL=0, ERROR=1, WARNING=2, INFO=3, CONFIRM=4
	private static void insertErrorLogList( List<ErrorLog__c> errorLogList, ApexPages.Severity errorLevel, String type){
		List<ECO_ErrorLogSettings__c> loggingSetup = new List<ECO_ErrorLogSettings__c>();

		if( !ECO_Service_ErrorLog.loggingSetupDone) {
			loggingSetup = [SELECT IsEnabled__c, ThresholdLevel__c FROM ECO_ErrorLogSettings__c];
			ECO_Service_ErrorLog.loggingSetupDone = true;
		}
		
		if( loggingSetup.isEmpty() || (loggingSetup[0].IsEnabled__c && errorLevel.Ordinal() <= loggingSetup[0].ThresholdLevel__c)){
			try {
				insert errorLogList;
			} catch (Exception e){
				System.debug( '*****>Error writing ErrorLog to DB: ' + type);
			}
		}
	}







}