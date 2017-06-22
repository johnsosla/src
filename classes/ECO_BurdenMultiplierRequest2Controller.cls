public class ECO_BurdenMultiplierRequest2Controller {

	public static final String HOME_OFFICE = 'Home';
	public static final String FIELD_OFFICE = 'Field';

	public ProjectBurdenMultiplierRequest__c request {get; set;}
	public pse__Proj__c project {get; set;}

//	public List<SelectOption> homeFieldOptions {get; set;}
	public String homeField {get; set;}

	public List<SelectOption> burdenSchedules {get; set;}
	public String burdenSchedule {get; set;}
	public String burdenScheduleField {get; set;}

    public ECO_BurdenMultiplierRequest2Controller(ApexPages.StandardController controller)
    {
    	List<String> fields = new List<String>();
//    	fields.add('HomeField__c');
    	fields.add('OracleBurdenScheduleName__c');
    	fields.add('OracleBurdenScheduleNameField__c');
        fields.add('ApprovalStatus__c');

        if (!Test.isRunningTest()) {
    	   controller.addFields(fields);
        }

        request = (ProjectBurdenMultiplierRequest__c)controller.getRecord();
        project = [select Id, Name
        					, PrimaryEndClient__r.AccountName__c
        				    , DefaultTopTaskCustomer__c 
        				    , pse__Stage__c 
        				    , OracleProjectNumber__c 
        				    , EstimatedContractValue__c
        				    , AECOMLaborCosts__c
        				    , EstimatedStartDate__c
        				    , pse__Start_Date__c
        				    , pse__End_Date__c
        				    , EstAwardDate__c
        				    , ProposalDue__c
        				    , CapitalValue__c
        				    , SubsCost__c
        				    , ODCsCost__c
        				    , RFPIssueDate__c
        				    , NetServicesRevenue__c
        				    , ProjectDescription__c 
        				    , pse__Project_Manager__r.pse__Salesforce_User__c
        				    , EcoSystemReferenceNumber__c
        				    from pse__Proj__c where Id = :request.Project__c];
        
        //

/*
        homeFieldOptions = new List<SelectOption>();
        homeFieldOptions.add(new SelectOption(HOME_OFFICE, HOME_OFFICE));
        homeFieldOptions.add(new SelectOption(FIELD_OFFICE, FIELD_OFFICE));

        homeField = (request.HomeField__c == null) ? HOME_OFFICE : request.HomeField__c;
*/        

        loadBurdenSchedules();
    }

    public void loadBurdenSchedules() {
//    	List<BurdenReference__c> references = null;

/*
    	if (homeField.equals(HOME_OFFICE)) {
//    		references = [select id, Schedule__c from BurdenReference__c where Home_Field__c = 'HOME_OFFICE'];
    	} else if (homeField.equals(FIELD_OFFICE)) {
//    		references = [select id, Schedule__c from BurdenReference__c where Home_Field__c = 'FIELD_OFFICE'];
    	}
*/    	

    	List<BurdenSchedule__c> scheduleListRaw = [select id, OracleRateScheduleName__c from BurdenSchedule__c];

    	Set<String> schedules = new Set<String>();

//    	for (BurdenReference__c reference : references) {
//    		schedules.add(reference.Schedule__c);
//    	}

		for (BurdenSchedule__c schedule : scheduleListRaw) {
			schedules.add(schedule.OracleRateScheduleName__c);
		}

    	List<String> scheduleList = new List<String>(schedules);

    	scheduleList.sort();

    	burdenSchedules = new List<SelectOption>();
    	burdenSchedules.add(new SelectOption('', '-- None --'));

    	boolean found = false;
    	boolean foundField = false;

    	for (String schedule : scheduleList) {
    		burdenSchedules.add(new SelectOption(schedule, schedule));

    		if ((request.OracleBurdenScheduleName__c != null) && schedule.equals(request.OracleBurdenScheduleName__c)) {
    			found = true;
    		}

    		if ((request.OracleBurdenScheduleNameField__c != null) && schedule.equals(request.OracleBurdenScheduleNameField__c)) {
    			foundField = true;
    		}
    	}

        burdenSchedule = (found) ? request.OracleBurdenScheduleName__c : '';
        burdenScheduleField = (foundField) ? request.OracleBurdenScheduleNameField__c : '';
    }

    public PageReference save() {
//    	request.HomeField__c = homeField;
    	request.OracleBurdenScheduleName__c = ((burdenSchedule == null) || burdenSchedule.equals('')) ? null : burdenSchedule;
    	request.OracleBurdenScheduleNameField__c = ((burdenScheduleField == null) || burdenScheduleField.equals('')) ? null : burdenScheduleField;

    	update request;

    	return null;
    }
    
    public void init()
    {   	
    	if(request.ProjectManager__c == null)
    		request.ProjectManager__c = project.pse__Project_Manager__r.pse__Salesforce_User__c;
    	if(request.ProjectApprover__c == null)
    		request.ProjectApprover__c = ECO_Service_ProjectTeam.getActiveProjectApproverId(project.Id);
    	if(request.FinanceLead__c == null)
    		request.FinanceLead__c = ECO_Service_ProjectTeam.getActiveProjectFinanceLead(project.Id);	   	
    }
    
	public list<SelectOption> getYesNoOptions()
	{
	    list<SelectOption> options = new list<SelectOption>();
	    options.add(new SelectOption('Yes', 'Yes'));
	    options.add(new SelectOption('No', 'No'));
	
	    return options;
	}    
	
	public PageReference cancel()
	{
		return new PageReference('/' + request.Project__c);
	}
    
    /**
     * Validate user against security matrix and submit Project Burden Multiplier Request for Approval
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    08/16/2016
     *
     * @param 
     * @return  PageReference
     **/
    public PageReference submitForApproval(){
		
        System.debug('Came in for submission');
        Boolean hasPermissionForApprovalProcess = ECO_Service_RecordAccess.getProjectRecordAccessForApprovalProcess ('ProjectBurdenMultiplierRequest__c', project.Id);
        System.debug('hasPermissionForApprovalProcess:::'+hasPermissionForApprovalProcess);
        if (! hasPermissionForApprovalProcess)  
        {   
            ECO_Service_ErrorLog.formatPageError('You do not have permission to Submit for Approval', ApexPages.Severity.ERROR);

            return null;
        }
		
        //Check if all approvers are active and approved
        list<ECO_Service_ProjectTeam.CheckMember> lstCheckMembers = new list<ECO_Service_ProjectTeam.CheckMember>();
        lstCheckMembers.add(new ECO_Service_ProjectTeam.CheckMember(project.id, 'Finance Lead'));
        
        ECO_Service_ProjectTeam.CheckMembers(lstCheckMembers);
        List<ProjectTeamMember__c> lPTM = new List<ProjectTeamMember__c>();

        for(ECO_Service_ProjectTeam.CheckMember chk: lstCheckMembers){
            if(chk.errormsg !=null){
                ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR,chk.errormsg);
                ApexPages.addMessage(oPageMessage);
                return null;
            }
            else{
                lPTM.add(chk.approvedPTM);
            }
        }
		System.debug('approved approvers:::'+lPTM);
        if(!lPTM.isEmpty()){
            for(ProjectTeamMember__c ptm : lPTM){
                if(ptm.ProjectRole__r.Name == 'Finance Lead' && request.FinanceLead__c != ptm.Contact__r.pse__Salesforce_User__c ){
                    request.FinanceLead__c = ptm.Contact__r.pse__Salesforce_User__c;
                    
                }
                
            }
        }

        try {
            update request;
        } catch (Exception e){
            ECO_Service_ErrorLog.formatPageError(e, '' + e.getMessage());
        }
		
        System.debug('now submitting for approval');
        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();  
        req1.setComments('Submitted for Approval');
        req1.setObjectId(request.Id);
        Approval.ProcessResult result = Approval.process(req1);
		System.debug('submission complete:::'+result);
        //return new PageReference('/apex/ECO_BurdenMultiplierRequest2?id='+request.Id);
        PageReference pageRef = new PageReference('/apex/ECO_BurdenMultiplierRequest2?id='+request.Id);
        pageRef.setRedirect(true);
        return pageRef;
		//return null;
    }
}