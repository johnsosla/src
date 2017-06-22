/*
*    Project Name        : eConnect
*    Project NameSpace   : HRS
*    Description         : Apex Class to Insertion/Updation of Email Message
*    Known               : This class will only called by trigger.
*/

public class HRS_EmailMessageHandler {

	//A main After Insert trigger function, contains all process goes into isAfter && isInsert
	//Param : @List<EmailMessage>
	public static void afterInsertEmailMessages( List<EmailMessage> EmailMessageList ){
		//Allow user to use email to case functionality to approve Case
		emailCaseApproval( EmailMessageList );
	}

	//A main Before Insert trigger function, contains all process goes into isBefore && isInsert
	//Param : @List<EmailMessage>
	public static void beforeInsertEmailMessages( List<EmailMessage> EmailMessageList ){
		String casePrefix = Case.sobjecttype.getDescribe().getKeyPrefix();
		Map<String, Schema.RecordTypeInfo> mRtInfo = Case.SObjectType.getDescribe().getRecordTypeInfosByName();
		List<EmailMessage> messages = new List<EmailMessage>();
		Set<Id> caseIds = new Set<Id>();
		for(EmailMessage email : EmailMessageList) {
			if(String.valueOf(email.ParentId).startsWith(casePrefix)) {
				caseIds.add(email.ParentId);
			}
		}
		
		Map<Id, Case> caseMap = new Map<Id, Case>([Select Id, RecordTypeId, RecordType.Name, Contact.Email from Case where Id IN: caseIds]);
		
		for(EmailMessage email : EmailMessageList) {
			Set<Id> toIds = new Set<Id>(email.ToIds);
			if(caseMap.containsKey(email.ParentId) 
				&& caseMap.get(email.ParentId).RecordTypeId == mRtInfo.get('HR - Exit Management').getRecordTypeId()
				&& email.toAddress == caseMap.get(email.ParentId).Contact.Email) {
					email.addError('Recipient is employee to be terminated');
			}
		}
	}
	
	//Case approval Using standard Email to Case function
	//Param : @List<EmailMessage>
	public static void emailCaseApproval( List<EmailMessage> EmailMessageList ){
		
		Set<Id> caseIdSet = new set<Id>();
		Set<String> emailSet = new set<String>();
		Map<Id, EmailMessage> emailMap = new Map<Id, EmailMessage>();
		List<Approval.ProcessWorkitemRequest> approvalList = new List<Approval.ProcessWorkitemRequest>();
		Set<Id> piSet = new set<Id>();

		for(EmailMessage message : EmailMessageList ){
			//Only look at email message that related to Case Approval
			if( message.TextBody.contains('Approve') || message.TextBody.contains('Reject') ){
				//add into email set to query user record for verification 
				emailSet.add( message.FromAddress );
				//add all email into a map
				emailMap.put( message.Id, message);
				//add all related case to query 
				caseIdSet.add(message.ParentId);
			}
		}             

		if ( caseIdSet.size() > 0 ){ 
			//Create a user ID map, it's intentional to skip user that is not active and is an api user as one user should only have one record
			Map<Id, User> userIdMap = new Map<Id, User>([select Id, Name, Email from User where email =: emailSet and isActive = true and usertype = 'standard' and ( NOT profile.name like 'API' ) ]);
			//Create a list with all the process instance that is related to this email, which approval is needed
			List<ProcessInstance> pi = [ SELECT Id,ProcessDefinitionId,Status,TargetObjectId FROM ProcessInstance WHERE TargetObjectId in: caseIdSet and status = 'Pending' ];
			//Create a set for all the Process Instance record
			for ( ProcessInstance piRecord : pi ){
				piSet.add( piRecord.Id );
			}
			//Create a List for all the Process Instance work item record
			List<ProcessInstanceWorkitem> workItemList = [ SELECT Id, ActorId,ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId =: piSet];

			if ( pi.size() > 0 && pi != null  && workItemList.size() > 0 ){
				for ( ProcessInstance piRecord : pi ){
					for ( ProcessInstanceWorkitem workItem : workItemList){ 
						for ( EmailMessage approvalEmail : emailMap.values() ){

							String Decision;
							//Based on the email reply, it directs the Decision
							//Value is currently being default and will not have to capture any other cases
							if( approvalEmail.TextBody.contains('Approve') ){
								Decision = 'Approve';
							}
							if( approvalEmail.TextBody.contains('Reject') ){
								Decision = 'Reject';							
							}
							//Validate if the user is indeed the user in the process instance work item
							if ( userIdMap.get(workitem.ActorId) != null && userIdMap.get(workitem.ActorId).Email == approvalEmail.FromAddress 
								 && userIdMap.get(workitem.ActorId).Id == workitem.ActorId ){
								//Manually force the approval process according to Email decision
								//Add tracking syntax into approval comment box
								Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
								req2.setAction( Decision );
								req2.setWorkitemId( workitem.id );
								req2.setComments( Decision + ' by ' + userIdMap.get(workitem.ActorId).Name +' using ' + userIdMap.get(workitem.ActorId).Email );
								approvalList.add( req2 );   
							}			            	
						
						}

					}
				}

			}
		}
		//Process all approval if the list is not empty
		if ( approvalList != null )
			List<Approval.ProcessResult> resultApproval = Approval.process( approvalList ); 	    

	}


}