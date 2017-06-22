/** ------------------------------------------------------------------------------------------------------
* @Description The controller for the Closeout Project Opportunity Phase page - it allows for users to select
* available tasks to allocate to POs on the project.
*
* @Author      NTT Data - ?, Deborah Orth
* @Date        2015
*-----------------------------------------------------------------------------------------------------*/
public class ECO_CloseoutOpportunityPhaseController {

	private Transient Attachment closureAttachment;
	public String overrideControlSystemName  					{ get; set; }
	public Map<Id, Attachment> attachmentsMap 					{ get; set; }

	public pse__Proj__c oProject 								{ get; set; }
	public List<SelectOption> types 							{ get; set; }
	public List<SelectOption> closureStatusOptions 				{ get; set; }
	public List<SelectOption> reasonsWonLostOptions 			{ get; set; }
	public Boolean bHasAccessToOpportunity 						{ get; set; }

	public List<QuestionnaireSet__c> lstNogo 					{ get; set; }
	public String sOpportunityName 								{ get; set; }

	/* Custom classes to facilitate this controller */
	public class EcoControllerException extends Exception {}

	/**
	 * The extension constructor initializes the private member
	 * variable mysObject by using the getRecord method from the standard
	 * controller.
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   stdController - the standard controller for the page, pse__Proj__c object
	 * @return   
	**/
	public ECO_CloseoutOpportunityPhaseController(ApexPages.StandardController stdController) {
		this.oProject = (pse__Proj__c)stdController.getRecord();

		oProject = [select  id 
							,ClosureAttachment__c   
							,ProjOpptyClosureStatus__c
							,Reason_Won_or_Lost__c
							,StatusChangeDate__c
							,ProjOpptyCloseoutNotes__c
							,AlsoCloseRelatedOpportunityList__c
							,ClientDebrief__c
							,ClientDebriefNotes__c
							,InternalDebrief__c
							,InternalDebriefNotes__c
							,pse__Opportunity__c
							,pse__Opportunity__r.name
							,ProjectSectionHeaderName__c
							,ProjectClosureNotes__c
							,PreviousProjectStatus__c
							,pse__Stage__c
					from pse__Proj__c
					where id =: oProject.id];

		types = new List<SelectOption>();
		types.add(new SelectOption('No', 'No'));
		types.add(new SelectOption('Yes', 'Yes'));  
		
		sopportunityName = oProject.pse__Opportunity__r.name;

		lstNogo = [select id, GoNoGoDate__c from QuestionnaireSet__c where Project__c =: oProject.id and GoNoGoRecommendation__c = 'No Go' order by GoNoGoDate__c desc];

		if(lstNogo.size() > 0 && oProject.StatusChangeDate__c == null){
			oProject.StatusChangeDate__c = lstNogo[0].GoNoGoDate__c;
		}

		attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :oProject.Id]);

		list<UserRecordAccess> lstURA = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess FROM UserRecordAccess WHERE  UserId=:UserInfo.getUserId() AND RecordId =: oProject.pse__Opportunity__c];
		bHasAccessToOpportunity = false;

		if(lstURA.size() > 0){
			if(lstURA[0].HasReadAccess){
				bHasAccessToOpportunity = true;
			}
		}
	}

	/**
	 * initialize the picklist values for the page
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    2016
	 *
	 * @param    
	 * @return   
	**/
	public void init(){
		this.closureStatusOptions = fillSelectedClosureStatusList();
		this.reasonsWonLostOptions = fillReasonsWonLostList();
	}
	
	/**
	 * read the pse__Proj__c object schema for selected picklist values - closure status
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	* @param    
	* @return   List<SelectOption>
	**/
	private List<SelectOption> fillSelectedClosureStatusList(){
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', '--None--'));

		Schema.DescribeFieldResult fieldResult = pse__Proj__c.ProjOpptyClosureStatus__c.getDescribe();
		//List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry ple : fieldResult.getPicklistValues()){
			if( ple.getValue() != '5B Program Signed and Active'
				&& ple.getValue() != '6 Contracted/Booked/Won'
				&& ple.getValue() != '6A Program Closed/Completed'){
				options.add( new SelectOption(ple.getLabel(), ple.getValue()));
			}
		} 

		return options;           
	}

	/**
	 * gets the list of available Reasons Won/Lost in a selectOption list
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    2016
	 *
	 * @param    
	 * @return   List<SelectOption>
	**/
	private List<SelectOption> fillReasonsWonLostList(){
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', '--None--'));
		
		Schema.DescribeFieldResult fieldResult = pse__Proj__c.Reason_Won_or_Lost__c.getDescribe();
		for( Schema.PicklistEntry ple : fieldResult.getPicklistValues()){
			options.add( new SelectOption(ple.getLabel(), ple.getValue()));
		} 

		return options;
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param    
	 * @return   PageReference
	**/
	public PageReference createChangeManagement(){


		list<RecordType> lstRT = [select id from recordtype where sObjectType='ChangeManager__c' and developername='InternalChange'];

		//Id budgetHeaderId = ECO_BudgetEACService.createProjectCloseOutBudget(oProject.Id);

		//System.Debug('BudgetHeaderId' + budgetHeaderId);

		ChangeManager__c cm = new ChangeManager__c(Process__c = ECO_Service_Delegation.CMProcessNameClose, recordtypeid = lstRT[0].id, Project__c = oProject.id, IntExtProjectClosure__c=true);

		try{
			insert cm;
		}catch(EcoControllerException e){
			ECO_Service_ErrorLog.formatPageError(e, 'An Error has occurred while attempting to insert Change Manager: ');
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attempting to insert Change Manager: ' + e));

			return null; 
		} 

		return new PageReference('/apex/eco_changemanagerdetail?id=' + cm.id + '&Mode=Edit');


	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param    
	 * @return   PageReference
	**/
	public PageReference createChangeManagementPlanning()
	{
		Integer UpdateFlag = 0;

		Id recordTypeId;

		//recordTypeId = [select Id from RecordType where Name = 'Customer Project (Planning)' limit 1].Id;
		//oProject.RecordTypeId = recordTypeId;
		if(oProject.PreviousProjectStatus__c != null && oProject.PreviousProjectStatus__c != '')
			oProject.pse__Stage__c = oProject.PreviousProjectStatus__c;//'Planning';

		Savepoint oSavePoint = Database.setSavepoint();

		try
		{
			update oProject;
			UpdateFlag = 1;
		}
		catch(EcoControllerException e)
		{
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attempting to update project. Please contact your administrator with the following error: ' + e));
			Database.rollback(oSavePoint);
			ECO_Service_ErrorLog.formatPageError(e, 'An Error has occurred while attempting to update project. Please contact your administrator with the following error: ');
			return null; 
		} 

		//OPPORTUNITY UPDATES
		if (UpdateFlag == 1)
		{
			Opportunity oOpp = [select id, Name, Previous_StageName__c from opportunity where id=: oProject.pse__Opportunity__c];

			System.debug('oProject.Name ' + oProject.Name);
			System.debug('oOpp.Name ' + oOpp.Name);
			System.debug('oOpp.Previous_StageName__c ' + oOpp.Previous_StageName__c);

			if(oOpp.Previous_StageName__c != null && oOpp.Previous_StageName__c != '')
			{
				System.debug('Inside If');

				oOpp.StageName = oOpp.Previous_StageName__c;

				oOpp.Date_lost_cancelled_no_go__c = null;
				oOpp.Date_Canceled__c = null;
				oOpp.Date_No_Go__c = null;

				/*
				if (oProject.pse__Stage__c == 'Lost')
					oOpp.Date_lost_cancelled_no_go__c = oProject.StatusChangeDate__c;
				else if (oProject.pse__Stage__c == 'Canceled by Client')
					oOpp.Date_Canceled__c = oProject.StatusChangeDate__c;
				else if (oProject.pse__Stage__c == 'No-Go')
					oOpp.Date_No_Go__c = oProject.StatusChangeDate__c;
				*/

				Savepoint oSavePoint1 = Database.setSavepoint();

				try
				{
					update oOpp;
				}
				catch(EcoControllerException e)
				{
					//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attempting to update related opportunity. Please contact your administrator with the following error: ' + e));
					Database.rollback(oSavePoint1);
					ECO_Service_ErrorLog.formatPageError(e, 'An Error has occurred while attempting to update related opportunity. Please contact your administrator with the following error: ');
					return null; 
				}
			}
		}

		/*list<RecordType> lstRT = [select id from recordtype where sObjectType='ChangeManager__c' and developername='InternalChange'];
		
		ChangeManager__c cm;
		
		cm = new ChangeManager__c(recordtypeid = lstRT[0].id, Project__c = oProject.id, IntExtProjectClosure__c=true,  IsProjectReOpen__c=true, IntExtProjectClosureComments__c = 'Putting Project back to Planning from No-Go');

		try{
			insert cm;
		}catch(EcoControllerException e){
			ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attempting to insert Change Manager: ' + e);
			ApexPages.addMessage(oMsg);
			return null; 
		} 

		return new PageReference('/apex/eco_changemanagerdetail?id=' + cm.id + '&Mode=');*/
		return new PageReference('/' + oProject.Id);
	}


	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param    
	 * @return   Attachment
	**/
	public Attachment dclosureAttachment
	{
		get
		{
			if(closureAttachment==null)
			{
				closureAttachment = new Attachment(parentid = oProject.id);
			}
			return closureAttachment;
		}
		set;
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param    
	 * @return   PageReference
	**/
	public PageReference stub(){
		return null;
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param    
	 * @return   PageReference
	**/
	public PageReference back(){
		return new PageReference('/' + oProject.id);
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param    
	 * @return   PageReference
	**/
	public PageReference closesave()
	{


		if(oProject.StatusChangeDate__c > date.today()){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Status Change Date cannot be in the future.'));
			return null;
		}

		system.debug('HERE1');
		Savepoint oSavePoint = Database.setSavepoint();

		try{
			if(oProject.ProjOpptyClosureStatus__c != null)
			{
				String newStatus = oProject.ProjOpptyClosureStatus__c.split(' ', 2)[1];
				if(newStatus == 'Lost' || newStatus == 'Canceled by Client' || newStatus == 'No-Go')
					oProject.PreviousProjectStatus__c = oProject.pse__Stage__c; 
				oProject.pse__Stage__c = newStatus;
			}
			update oProject;
		}catch(exception e){
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attempting to update project. Please contact your administrator with the following error: ' + e));
			Database.rollback(oSavePoint);
			ECO_Service_ErrorLog.formatPageError(e, 'An Error has occurred while attempting to update project. Please contact your administrator with the following error: ');
			return null; 
		} 

		 system.debug('HERE2');
		if(oProject.AlsoCloseRelatedOpportunityList__c == 'Yes'){

			system.debug('HERE3');
			opportunity oOpp = [select id from opportunity where id=: oProject.pse__Opportunity__c];
			oOpp.StageName = oProject.ProjOpptyClosureStatus__c;
			oOpp.Reason_Won_or_Lost__c = oProject.Reason_Won_or_Lost__c;
			oOpp.Reason_Won_or_Lost_Comment__c = oProject.ProjOpptyCloseoutNotes__c;

			//2492: Updating individual fields for status dates. In the code, just for FYI, notice the split function used above to flush
			//out numbers from the Status string
			//oOpp.Date_lost_cancelled_no_go__c = oProject.StatusChangeDate__c;
			if (oProject.pse__Stage__c == 'Lost')
				oOpp.Date_lost_cancelled_no_go__c = oProject.StatusChangeDate__c;
			else if (oProject.pse__Stage__c == 'Canceled by Client')
				oOpp.Date_Canceled__c = oProject.StatusChangeDate__c;
			else if (oProject.pse__Stage__c == 'No-Go')
				oOpp.Date_No_Go__c = oProject.StatusChangeDate__c;

			try{
				update oOpp;
			
			}catch(EcoControllerException e){
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attempting to update related opportunity. Please contact your administrator with the following error: ' + e));
				Database.rollback(oSavePoint);
				ECO_Service_ErrorLog.formatPageError(e, 'An Error has occurred while attempting to update related opportunity. Please contact your administrator with the following error: ');
				return null; 
			} 
		}

		return new PageReference('/' + oProject.id);
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param    attachmentIds
	 * @return   List<Attachment>
	**/
	private List<Attachment> getAttachmentListFromIdList(List<String> attachmentIds)
	{
		List<Attachment> attachments = new List<Attachment>();
		for(String attachmentId:attachmentIds)
		{
			if(attachmentsMap.containsKey(attachmentId) && attachmentId != null && attachmentId != '')
				attachments.add(attachmentsMap.get(attachmentId));
		}
		return attachments; 
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param    
	 * @return   List<Attachment>
	**/
	public List<Attachment> getAttachedClosureFiles()
	{

		List<String> attachmentIds = new List<String>();
		if(oProject.ClosureAttachment__c != null)
			attachmentIds = oProject.ClosureAttachment__c.split(';');
			
		return getAttachmentListFromIdList(attachmentIds);
	}
	
	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param    
	 * @return   PageReference
	**/
	public PageReference saveClosureAttachmentAndProject()
	{
		if(closureAttachment.Body != null)
		{   
			if(overrideControlSystemName != null && overrideControlSystemName != '')
				closureAttachment.Name = overrideControlSystemName;

			try {               
				insert closureAttachment;
			} catch (Exception e){
				ECO_Service_ErrorLog.formatPageError(e, 'An Error has occurred while attempting to add closure attachment to project: ');
			}
			
			if(oProject.ClosureAttachment__c != null)
				oProject.ClosureAttachment__c += closureAttachment.Id + ';';
			else
				oProject.ClosureAttachment__c = closureAttachment.Id + ';';          
			//update oProject;
			
			attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :oProject.Id]);
			closureAttachment = null;
		}   

		return null;        
	}
}