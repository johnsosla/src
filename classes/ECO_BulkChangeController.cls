/** ------------------------------------------------------------------------------------------------------
* @Description Controller for the Bulk Change page
*
* @Author      NTT Data - Tim Chiang
* @Date        2016
*-----------------------------------------------------------------------------------------------------*/
public with sharing class ECO_BulkChangeController {
	
	public static final String PROJECT_TEAM_CHANGE = 'ProjectTeamChange';
	public static final String ORGANIZATION_CHANGE = 'OrganizationChange';
	public static final String CLASSIFICATION_CHANGE = 'ClassificationChange';
	public static final Integer PAGE_SIZE = 10;

	public BulkChange__c bulkChange {get; set;}
	public List<BulkChangeCriteriaWrapper> bulkChangeCriterias {get; set;}
	public List<BulkChangeReplacement__c> bulkChangeReplacements {get; set;}
	public Map<id, BulkChangeCriteriaWrapper> bulkChangeCriteriaMap {get;set;}
	public map<string, List<SelectOption>> mapClassificationToOptions {get;set;}

	public List<ProjectTeamMember__c> resultTeamMembers {get; set;}
	public BulkChangeCriteria__c newBulkChangeCriteria {get; set;}
	public BulkChangeCriteriaWrapper newBulkChangeCriteriaWrapper {get;set;}
	public Date todayDateTemp {get; set;}
	private ApexPages.StandardSetController setController;
	public Integer pageNumber {get; set;}

    public List<FieldSetMemberWrapper> lClassifications {get; set;}
    public FieldSetMemberWrapper lClassificationsFSM {get; set;}
    public List<SelectOption> classifications {get; set;}
	public List<SelectOption> optionsNewClassifications {get; set;}

    public Map<String, String> classificationFieldLabelToFieldNameMap {get; set;}
    public string recordTypeName {get;set;}

    private Map<String, List<SelectOption>> classificationSelections;

	public Boolean needOracleLogin {get; set;}
    public String OracleUserName {get; set;}
    public String OraclePassword {get; set;}
    public String authenticationResult {get; set;}	

	public list<string> lstRegion {get;set;}
	public list<string> lstBusinessLines {get;set;}

	public List<SelectOption> optionsRegions {get;set;}
	public List<SelectOption> optionsBusinessLines {get;set;}
	public List<OrganizationString__c> listOrgStrings {get;set;}

	public id selectOrgId {get;set;}

	public boolean isValid {get;set;}

	public boolean canEdit {get;set;}
	public boolean isSubmitted {get;set;}
	public boolean isExecuted {get;set;}
	public boolean isCreate {get;set;}
	public boolean isExecute {get;set;}
	public boolean newButtonDisabled {get;set;}

	public integer batchSize {get;set;}

	public List<BulkChangeReplacement__c> includedReplacements {get;set;}

	public id selectedCriteria {get;set;}

	public Map<id, integer> mapDupeCount {get;set;}
	public Map<String, Integer> mapDupeClassCount {get;set;}

	public string reportURL {get;set;}

	public String classSelected {get; set;}
	public String newclassValSelected {get; set;}
	public String classFilterSelected {get; set;}

	public boolean isResend {get;set;}

	public String classPicklist {
		get {
			if (classPicklist == null) {
				classPicklist = '';
			}
			return classPicklist;
		} 
		set;
	}

	public pse__Proj__c oProject {get; set;}

	public Integer totalPages { get; set; } 

	/**
	 * getProject
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 **/
	public pse__Proj__c getProject() {
		oProject = new pse__Proj__c();
		return oProject;
	}

	/**
	 * selectedNewClassVal
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 **/
	public void selectedNewClassVal() {
		//System.debug('___newBulkChangeCriteria 2a ='+newBulkChangeCriteria);
		newclassValSelected = newBulkChangeCriteria.NewClassificationValue__c;
		//System.debug('___newclassValSelected ='+ newclassValSelected);
		newBulkChangeCriteria.NewClassificationValue__c = newclassValSelected;
		//System.debug('___newBulkChangeCriteria 2b ='+newBulkChangeCriteria);
	}

	/**
	 * selectedClassification
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 **/
	public void selectedClassification() {
		//System.debug('___newBulkChangeCriteria 1='+newBulkChangeCriteria);
		classSelected = newBulkChangeCriteria.Classification__c;
		//System.debug('___classSelected='+classSelected);
		if (classSelected != null && classSelected != '') {
			classPickList = classificationFieldLabelToFieldNameMap.get(classSelected);
		}
		else {
			classPickList = '';
		}
		//System.debug('___classPickList='+classPickList);

		// Create the NewClassificationPicklist
		Schema.DescribeSObjectResult objSchema = pse__Proj__c.sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getmap();
        //Schema.DisplayType fieldDataType = fieldMap.get(oFSM.getFieldPath()).getDescribe().getType();
		////System.debug('___Field DataType='+fielddataType);
		List<Schema.Picklistentry> fieldPicklists =fieldmap.get(classPickList).getDescribe().getpicklistValues();
		//System.debug('___fieldPicklists='+fieldPicklists);
		//List<Schema.PicklistEntry> ple = classPicklistMap.get(classPickList);
		optionsNewClassifications = new List<SelectOption>();
		optionsNewClassifications.add(new SelectOption('', '-- Select one --'));  // SelectOption(value, label)
		for( Schema.PicklistEntry f : fieldPicklists)
	   {
	      optionsNewClassifications.add(new SelectOption(f.getLabel(), f.getLabel()));
	   }
	   //System.debug('___optionsNewClassifications='+optionsNewClassifications);
	}

	/**
	 * queries for replacements
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	List<BulkChangeReplacement__c>
	 **/
	public List<BulkChangeReplacement__c> getReplacements() {

		return [select Id, 
					IntegrationMessageQueue__c, 
					IntegrationMessageQueue__r.SuccessMessage__c,
					IntegrationMessageQueue__r.ErrorMessage__c,
					BulkChangeRecordType__c,
					ProjectTeamMember__c,
					MessageStatus__c, 
					Change__c, 
					BulkChangeCriteria__c, 
					status__c, 
					ProjectStage__c,
					Project__c, 
					NewTeamMember__c, 
					NewOrganizationString__c, 
					ExistingTeamMember__c, 
					ExistingOrganizationString__c, 
					EffectiveDate__c, 
					ProjectRole__c, 
					ProjectRole__r.Type__c,
					Exclude__c, 
					ExistingClassificationValue__c, 
					NewClassificationValue__c, 
					ErrorMessage__c,
					project__r.CarryingOutOrganization__r.BusinessLineName__c,
					project__r.CarryingOutOrganization__r.Region__c,
					project__r.CarryingOutOrganization__c,
					project__r.ProjectNumber__c,
					project__r.PnLManager__c,
					Project__r.FinanceLead__c,
					Project__r.OUID__c,
					ProjectRole__r.name,
					Classification__c 
				from BulkChangeReplacement__c 
				where BulkChange__c = :bulkChange.Id 
				order by project__r.ProjectNumber__c asc];

	}

	/** ------------------------------------------------------------------------------------------------------
	* @Description Wrapper to contain field set member contents
	*
	* @Author      NTT Data - Tim Chiang
	* @Date        2016
	*-----------------------------------------------------------------------------------------------------*/
    public class FieldSetMemberWrapper {
        public FieldSetMember fsm { get; set; }
        public Boolean isRequired { get; set; }
    }	

	/** ------------------------------------------------------------------------------------------------------
	* @Description Wrapper to organize data with each criteria
	*
	* @Author      NTT Data - Tim Chiang
	* @Date        2016
	*-----------------------------------------------------------------------------------------------------*/
	public class BulkChangeCriteriaWrapper
	{
		public Boolean isNew {get; set;}
		public BulkChangeCriteria__c criteria {get; set;}
		list<BulkChangeReplacement__c> replacements {get;set;}

		/**
		 * Constructor
		 *
		 * @Author      NTT Data - Tim Chiang
		 * @Date        2016
		 *
		 **/
		public BulkChangeCriteriaWrapper(BulkChangeCriteria__c criteria, Boolean isNew)
		{
			this.isNew = isNew;
			this.criteria = criteria;
			replacements = new list<BulkChangeReplacement__c>();
		}
	}

	/**
	 * Controller Constructor
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @param	standardController - standard controller for bulk change
	 **/
	public ECO_BulkChangeController(ApexPages.StandardController standardController) {
		//System.debug('___newBulkChangeCriteria 0='+newBulkChangeCriteria);
		bulkChange = (BulkChange__c)standardController.getRecord();	
		bulkChange.Status__c = ECO_Constants.BulkChangeStatusDraft;

		batchSize = Integer.valueOf(ECOMassUpdateParameters__c.getOrgDefaults().BulkUpdateBatchSize__c);

		RecordType rt = [select id, Name, DeveloperName from RecordType where id =: bulkChange.RecordTypeid limit 1];
		recordTypeName  = rt.DeveloperName;
		isValid = false;

		if (recordTypeName == PROJECT_TEAM_CHANGE || recordTypeName == CLASSIFICATION_CHANGE) {
			getOrganizationDropdowns();
		}

		canEdit = false;
		isSubmitted = false;
		isExecuted = false;
		init();
		
		isCreate = false;
		isExecute = false;

		newButtonDisabled = false;
		isResend = false;

		list<PermissionSetAssignment> psa = [SELECT ID FROM PermissionSetAssignment WHERE (PermissionSetId IN (SELECT ID FROM PermissionSet WHERE name='ePMMassUpdateCreation') AND AssigneeId=:userinfo.getuserid()) limit 1];

		if (!psa.isempty()) {
			isCreate = true;
		}

		list<PermissionSetAssignment> psaexecute = [SELECT ID FROM PermissionSetAssignment WHERE (PermissionSetId IN (SELECT ID FROM PermissionSet WHERE name='ePMMassUpdateExecution') AND AssigneeId=:userinfo.getuserid()) limit 1];

		if (!psaexecute.isempty()) {
			isCreate = true;
			isExecute = true;
		}
	}

	/**
	 * uncheck all exclusions
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	PageReference
	 **/
    public PageReference RemoveExclusions() {

		for(BulkChangeReplacement__c bcr:includedReplacements) {
			bcr.Exclude__c = false;
		}

		return null;
    }

	/**
	 * Handles deleting of bulk criteria
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	PageReference
	 **/
	public PageReference RemoveCriteria() {

		BulkChangeCriteria__c foundCriteria;

		for(BulkChangeCriteriaWrapper bcw :bulkChangeCriterias) {
			if (bcw.criteria.id == selectedCriteria) {
				foundCriteria = bcw.criteria;
			}
		}

		if (foundCriteria != null) {

			try{
				delete foundCriteria;
			}
	        catch(Exception e)
	        {
	            ECO_Service_ErrorLog.formatPageError(e, label.Problem_deleting_criteria);
	        }
		}

		init();

        return null;
	}

	/**
	 * Handles rejection action of a bulk change
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	PageReference
	 **/
	public PageReference rejectBulkChange() {

		bulkChange.Status__c = ECO_Constants.BulkChangeStatusRejected;

		try{
			update bulkChange;
		}
        catch(Exception e)
        {
            ECO_Service_ErrorLog.formatPageError(e, label.Problem_rejecting_bulk_change);
        }

        PageReference returnpage =  new PageReference('/apex/ECO_BulkChange?id=' + bulkChange.id);
        returnpage.setRedirect(true);
		return returnpage;
	}

	/**
	 * Handles rejection action of a bulk change
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	PageReference
	 **/
	public PageReference RecallBulkChange() {

		bulkChange.Status__c = ECO_Constants.BulkChangeStatusDraft;

		try{
			update bulkChange;
		}
        catch(Exception e)
        {
            ECO_Service_ErrorLog.formatPageError(e, label.Problem_recalling_bulk_change);
        }
	
        PageReference returnpage =  new PageReference('/apex/ECO_BulkChange?id=' + bulkChange.id);
        returnpage.setRedirect(true);
		return returnpage;
	}


	/**
	 * Handles saving of bulk changes
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	PageReference
	 **/
	public PageReference saveBulkChange() {
		try{
			upsert bulkChange;
		}
        catch(Exception e)
        {
            //ECO_Service_ErrorLog.formatPageError(e, 'Problem saving bulk changes');
            //System.debug('___EXCEPTION: '+e.getStackTraceString());
            ECO_Service_ErrorLog.logException(e);
        }

        PageReference returnpage =  new PageReference('/apex/ECO_BulkChange?id=' + bulkChange.id);
        returnpage.setRedirect(true);
		return returnpage;
	}

	/**
	 * Handles submission of teammember bulk change
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	PageReference
	 **/
	public PageReference submitTeamMembers() {
		validateTeamMembers();

        if (isValid) {
        	bulkChange.Status__c = ECO_Constants.BulkChangeStatusSubmitted;

			try{
				update bulkChange;
			}
	        catch(Exception e)
	        {
	            ECO_Service_ErrorLog.formatPageError(e, label.Problem_saving_the_submitted_status_of_the_bulk_change);
	        }
        }

        PageReference returnpage =  new PageReference('/apex/ECO_BulkChange?id=' + bulkChange.id);
        returnpage.setRedirect(true);
		return returnpage;
	}

	/**
	 * Handles submission of organization bulk change
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	PageReference
	 **/
	public PageReference submitOrganizations() {
		validateOrg();

        if (isValid) {
        	bulkChange.Status__c = ECO_Constants.BulkChangeStatusSubmitted;

			try{
				update bulkChange;
			}
	        catch(Exception e)
	        {
	            ECO_Service_ErrorLog.formatPageError(e, label.Problem_saving_the_submitted_status_of_the_bulk_change);
	        }
        }

        PageReference returnpage =  new PageReference('/apex/ECO_BulkChange?id=' + bulkChange.id);
        returnpage.setRedirect(true);
		return returnpage;
	}

	/**
	 * Handles submission of Classifications bulk change
	 *
	 * @Author      NTT Data - Arman Shah
	 * @Date        2016
	 *
	 * @return 	PageReference
	 **/
	public PageReference submitClassifications() {
		validateClassifications();

        if (isValid) {
        	bulkChange.Status__c = ECO_Constants.BulkChangeStatusSubmitted;

			try {
				update bulkChange;
			}
	        catch(Exception e)
	        {
	            ECO_Service_ErrorLog.formatPageError(e, label.Problem_saving_the_submitted_status_of_the_bulk_change);
	            //System.debug('___EXCEPTION: '+e.getStackTraceString());
	        }
        }
        else {
        	//System.debug('___INVALID Classifications');
        }
        //System.debug('___bulkChange='+bulkChange);
        PageReference returnpage =  new PageReference('/apex/ECO_BulkChange?id=' + bulkChange.id);
        returnpage.setRedirect(true);
		return returnpage;
	}

	/**
	 * Handles validation of org bulk change
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	PageReference
	 **/
	public PageReference validateOrg() {
		if (includedReplacements == null) {
			isValid = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
            	label.Error_cannot_validate_without_any_replacements_defined));
			return null;
		}

		isValid = true;

		mapDupeCount = new Map<id, integer>();	
		set<id> setOrgIds = new set<id>();
		
		for(BulkChangeReplacement__c br:includedReplacements) {

			if (br.Exclude__c) {
				continue;
			}

			br.ErrorMessage__c = null;

			if (mapDupeCount.containskey(br.project__c)) {
				mapDupeCount.put(br.project__c, mapDupeCount.get(br.project__c) + 1);
			} else {
				mapDupeCount.put(br.project__c, 0);
			}

			setOrgIds.add(br.NewOrganizationString__c);
		}

		Map<id, OrganizationString__c> mapOS = new Map<id, OrganizationString__c>([select id, isActive__c, ProjectOwning__c from OrganizationString__c where id IN: setOrgIds]) ;


		for(BulkChangeReplacement__c br:includedReplacements) {

			if (br.Exclude__c) {
				continue;
			}

			if (!(mapOS.containskey(br.NewOrganizationString__c) && mapOS.get(br.NewOrganizationString__c).isActive__c && mapOS.get(br.NewOrganizationString__c).ProjectOwning__c)) {
				br.ErrorMessage__c = label.The_new_organization_string_must_be_active_and_project_owning;
			}

			if (mapDupeCount.containskey(br.project__c) && mapDupeCount.get(br.project__c) > 0) {
				br.ErrorMessage__c = label.Duplicate_target_project_detected;
			}

			if (br.NewOrganizationString__c == null) {
				br.ErrorMessage__c = label.New_target_organization_org_has_not_been_entered;
			}

			if (br.ErrorMessage__c != null) {
				isValid = false;
				br.Exclude__c = true;
			} else {
				br.ErrorMessage__c = label.Success;
			}
		}


		try{
			update includedReplacements;
		}
        catch(Exception e)
        {
            ECO_Service_ErrorLog.formatPageError(e, label.Problem_saving_the_validation_on_bulk_replacements);
        }

        return null;
	}

	/**
	 * Handles validation of teammember bulk change
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	PageReference
	 **/
	public PageReference validateTeamMembers() {

		if (includedReplacements == null) {
			isValid = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,label.Error_cannot_validate_without_any_replacements_defined));
			return null;
		}

		isValid = true;

		//get the alternate rectype
		RecordType alternateRecordType = [Select Id from RecordType where SObjectType = 'Delegate__c' AND DeveloperName = 'Alternate' limit 1];

		//get all of the delegates
		set<id> pnlIds = new set<id>();
		set<id> faIds = new set<id>();
		set<id> conIds = new set<id>();
		set<id> projectIds = new set<id>();
		map<string, boolean> OUIDs = new map<string, boolean>();

		mapDupeCount = new Map<id, integer>();

		for(BulkChangeReplacement__c br:includedReplacements) {

			if (br.Exclude__c) {
				continue;
			}

			if (mapDupeCount.containskey(br.ProjectTeamMember__c)) {
				mapDupeCount.put(br.ProjectTeamMember__c, mapDupeCount.get(br.ProjectTeamMember__c) + 1);
			} else {
				mapDupeCount.put(br.ProjectTeamMember__c, 0);
			}

			pnlIds.add(br.Project__r.PnLManager__c);
			faIds.add(br.Project__r.FinanceLead__c);
			conIds.add(br.NewTeamMember__c);
			projectIds.add(br.project__c);

			// cache OUID preferences
			if(!OUIDs.containskey(br.project__r.OUID__c)){
				ECODelegationOrgPreference__c DOP = ECODelegationOrgPreference__c.getvalues(br.project__r.OUID__c);

				if(DOP != null){
					OUIDs.put(br.project__r.OUID__c, DOP.UseDefaultDelegation__c);
				} else {
					OUIDs.put(br.project__r.OUID__c, false);
				}
			}
		}


		//get a cache of project teamember data
		set<string> PtmKeys = new set<string>();

		for(ProjectTeamMember__c ptm: [select id, project__c, Contact__c, ProjectRole__r.Type__c from ProjectTeamMember__c where project__c in: projectIds and Active__c = true]) {
			if(ptm.ProjectRole__r.Type__c == 'Key Member'){
				PtmKeys.add((id)ptm.project__c + '-' + (id)ptm.Contact__c);
			}
		}



		list<Delegate__c> lstDelegates = [Select id, 
												RecordTypeId,
												Delegator__c,
												Delegate__c, 
												Key_Member_Role__c,
												Allowed_Organizations__c,
												Start_Date__c,
												End_Date__c 
											From Delegate__c 
											Where (Delegator__c IN: pnlIds and (RecordTypeId=: alternateRecordType.id or Key_Member_Role__c = 'Project Approver')) OR
												(Delegator__c IN: faIds and (RecordTypeId=: alternateRecordType.id or Key_Member_Role__c = 'Project Accountant'))
											Order by Start_Date__c desc
											];



		//Create a map of delegates seperated by the type of delegates via key
		Map<string, list<Delegate__c>> mapKeyDelegate = new Map<string, list<Delegate__c>>();


		for(Delegate__c d: lstDelegates) {

			string key = (id)d.Delegator__c + '-' + (id)d.Delegate__c + '-';

			if (d.Key_Member_Role__c == 'Project Accountant') {
				key += 'Acc';
			} else if (d.Key_Member_Role__c == 'Project Approver') {
				key += 'App';
			} else if (d.RecordTypeId == alternateRecordType.id) {
				key += 'Alt';
			} else {
				continue;
			}

			//System.debug('DEBUG@@@: SET KEY -- ' + key);

			if (!mapKeyDelegate.containskey(key)) {
				mapKeyDelegate.put(key, new list<Delegate__c>());
			}

			mapKeyDelegate.get(key).add(d);
		}


		Map<id, contact> mapContact = new Map<id, contact>([select id, 
																pse__Salesforce_User__r.Certified_PM__c, 
																pse__Salesforce_User__r.PersonId__c, 
																pse__Salesforce_User__r.TrackingID__c, 
																pse__Salesforce_User__r.DPMAuthority__c,
																pse__Salesforce_User__r.Project_Approver__c,
																pse__Salesforce_User__r.ProjectAccountantAuthority__c,
																pse__Is_Resource__c,
																pse__Is_Resource_Active__c,
																pse__Salesforce_User__r.isActive,
																OracleContactID__c 
															from contact 
															where id IN: conIds]);

		// Loop through the members and work that validation magic...
		for(BulkChangeReplacement__c br:includedReplacements) {

			if (br.Exclude__c) {
				continue;
			}

			br.ErrorMessage__c = null;


			if (br.NewTeamMember__c == null || 
				br.EffectiveDate__c == null) {
				br.ErrorMessage__c = label.Please_fill_out_all_fields;
			} else {


				if (br.ProjectRole__r.name == 'Project Accountant' || 
							br.ProjectRole__r.name ==  'Project Accountant 2' || 
							br.ProjectRole__r.name ==  'Project Approver'  || 
							br.ProjectRole__r.name ==  'Finance Lead 2') {

					// check if the org default is being used
					if(!OUIDs.get(br.project__r.OUID__c)){

						string key;

						if (br.ProjectRole__r.name == 'Project Accountant' || br.ProjectRole__r.name ==  'Project Accountant 2') {
							key = (id)br.Project__r.FinanceLead__c + '-' + (id)br.NewTeamMember__c + '-Acc';
						} else if (br.ProjectRole__r.name ==  'Project Approver') {
							key = (id)br.Project__r.PnLManager__c + '-' + (id)br.NewTeamMember__c + '-App';
						} else if (br.ProjectRole__r.name ==  'Finance Lead 2') {
							key = (id)br.Project__r.FinanceLead__c + '-' + (id)br.NewTeamMember__c + '-Alt';
						}

						boolean isDelegateFound = false;


						if (mapKeyDelegate.containskey(key)) {
							for(Delegate__c d: mapKeyDelegate.get(key)) {

								if (d.Allowed_Organizations__c != null && d.Allowed_Organizations__c.indexof(br.project__r.CarryingOutOrganization__c) != -1) {
									if (br.EffectiveDate__c >= d.Start_Date__c && (br.EffectiveDate__c <= d.End_Date__c || d.End_Date__c == null)) {
										isDelegateFound = true;
										break;
									}
								}
							}

						} 

						if (!isDelegateFound) {
							if (br.ProjectRole__r.name == 'Project Accountant' || br.ProjectRole__r.name ==  'Project Accountant 2') {
								br.ErrorMessage__c = label.Cannot_find_delegate_for_new_accountant;
							} else if (br.ProjectRole__r.name ==  'Project Approver') {
								br.ErrorMessage__c = label.Cannot_find_delegate_for_new_approver;
							} else if (br.ProjectRole__r.name ==  'Finance Lead 2') {
								br.ErrorMessage__c = label.Cannot_find_alternate;
							}
						}
					} else {

						if (mapContact.containskey(br.NewTeamMember__c)) {
							contact c = mapContact.get(br.NewTeamMember__c);

							if (br.ProjectRole__r.name == 'Project Accountant' || br.ProjectRole__r.name ==  'Project Accountant 2') {

								if (c.pse__Salesforce_User__r.ProjectAccountantAuthority__c != true) {
									br.ErrorMessage__c = label.New_Member_is_not_a_Project_Accountant_Authority;
								}

							} else if (br.ProjectRole__r.name ==  'Project Approver') {
								
								if (c.pse__Salesforce_User__r.Project_Approver__c != 'Y') {
									br.ErrorMessage__c = label.New_Member_is_not_a_Project_Approver;
								}
							}

						} else {
							br.ErrorMessage__c = label.Cannot_find_contact_for_new_team_member;
						}
					}


				} else {
					if (mapContact.containskey(br.NewTeamMember__c)) {
						contact c = mapContact.get(br.NewTeamMember__c);

						if (c.pse__Salesforce_User__r.PersonId__c == null) {
							br.ErrorMessage__c = label.Cannot_find_personid_for_new_team_member;
						}

						if (c.pse__Salesforce_User__r.TrackingID__c == null) {
							br.ErrorMessage__c = label.Cannot_find_tracking_id_for_new_team_member;
						}

						if (c.OracleContactID__c.indexof('EMPLOYEE-') == -1) {
							br.ErrorMessage__c = label.Invalid_Oracle_Contact_id_for_new_team_member;
						}

						if (!c.pse__Is_Resource__c) {
							br.ErrorMessage__c = label.Team_member_is_not_a_resource;
						}

						if (!c.pse__Is_Resource_Active__c) {
							br.ErrorMessage__c = label.Team_member_is_not_an_active_resource;
						}

						if (!c.pse__Salesforce_User__r.isActive) {
							br.ErrorMessage__c = label.Team_member_user_is_not_active;
						}


						if (br.ProjectRole__r.name == 'Project Manager') {
							if (!(c.pse__Salesforce_User__r.Certified_PM__c == 'Y' || 
								c.pse__Salesforce_User__r.Certified_PM__c == 'Yes' || 
								c.pse__Salesforce_User__r.Certified_PM__c == 'Provisional')) {
								br.ErrorMessage__c = label.New_Member_is_not_a_certified_PM;
							}
						} else if (br.ProjectRole__r.name == 'Deputy Project Manager') {
							if (c.pse__Salesforce_User__r.DPMAuthority__c = false) {
								br.ErrorMessage__c = label.New_Member_is_not_a_DPM_Authority;
							}
						}

					} else {
						br.ErrorMessage__c = label.Cannot_find_contact_for_new_team_member;
					}
				}

				//System.debug('DEBUG KEY SEARCH@@@ ' +  (id)br.Project__c + '-' + (id)br.NewTeamMember__c);
				if (PtmKeys.contains( (id)br.Project__c + '-' + (id)br.NewTeamMember__c ) && br.ProjectRole__r.Type__c == 'Key Member' ) {
					//System.debug('DEBUG KEY SEARCH@@@ FOUND');
					br.ErrorMessage__c = label.The_new_team_member_already_has_a_key_role_on_the_project;
				}

				if (mapDupeCount.containskey(br.ProjectTeamMember__c) && mapDupeCount.get(br.ProjectTeamMember__c) > 0) {
					br.ErrorMessage__c = label.Duplicate_team_member_replacement_detected;
				}

			}

			if (br.ErrorMessage__c != null) {
				isValid = false;
				br.Exclude__c = true;
			} else {
				br.ErrorMessage__c = label.Success;
			}
		}


		try{
			update includedReplacements;
		}
        catch(Exception e)
        {
            ECO_Service_ErrorLog.formatPageError(e, label.Problem_saving_the_validation_on_bulk_replacements);
        }

		return null;
	}

	/**
	 * Handles validation of Classification change
	 *
	 * @Author      NTT Data - Arman Shah
	 * @Date        2016
	 *
	 * @return 	PageReference
	 **/
	public PageReference validateClassifications() {
		if (includedReplacements == null) {
			isValid = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
            	label.Error_cannot_validate_without_any_replacements_defined));
            //System.debug('Error: cannot validate Classifications without any replacements defined');
			return null;
		}

		isValid = true;

		Set<String> dupeClassSet = new Set<String>();
		
		for (BulkChangeReplacement__c br : includedReplacements) {

			if (br.Exclude__c) {
				continue;
			}

			String dupeClass = br.Project__c + '_' + br.Classification__c;
			
			if (dupeClassSet.contains(dupeClass)) {
				br.ErrorMessage__c = label.Duplicate_target_Classification_detected;
			} 
			else {
				dupeClassSet.add(dupeClass);
			}

			if (br.NewClassificationValue__c == null) {
				br.ErrorMessage__c = label.New_target_Classification_value_has_not_been_entered;
			}

			if (br.ErrorMessage__c != null && br.ErrorMessage__c != label.Success) {
				//System.debug('___br.ErrorMessage__c = '+br.ErrorMessage__c);
				isValid = false;
				br.Exclude__c = true;
			} 
			else {
				br.ErrorMessage__c = label.Success;
			}
		}

		try {
			update includedReplacements;
		}
        catch(Exception e)
        {
            ECO_Service_ErrorLog.formatPageError(e, label.Problem_saving_the_validation_on_bulk_replacements);
            //System.debug('Exception='+e.getStackTraceString());
        }
        //System.debug('___Classifications: isValid='+isValid);
        return null;
	}

	/**
	 * Gets the org strings for region and business line dropdowns
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	void
	 **/
	public void getOrganizationDropdowns() {

		set<string> setRegion = new set<string>();
		set<string> setBusinessLines = new set<string>();

		for(OrganizationString__c os: [SELECT Id, 
								OrganizationName__c,
								GeographyName__c,
								District__c,
								LocationName__c,
								Department__c,
								Region__c, 
								BusinessLineName__c
							FROM OrganizationString__c 
							WHERE ProjectOwning__c=true]) {
			setRegion.add(os.Region__c);
			setBusinessLines.add(os.BusinessLineName__c);
		}											

		list<string> lstRegion = new list<string>();
		list<string>lstBusinessLines = new list<string>();

		lstRegion.addall(setRegion);
		lstBusinessLines.addall(setBusinessLines);

		lstRegion.sort();
		lstBusinessLines.sort();

		optionsRegions = new List<SelectOption>();
		optionsBusinessLines = new List<SelectOption>();

		for(string s: lstRegion) {
			optionsRegions.add(new SelectOption(s,s));
		}

		for(string s: lstBusinessLines) {
			optionsBusinessLines.add(new SelectOption(s,s));
		}
	}

	/**
	 * Gets the org strings based on region and business line dropdowns
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	PageReference
	 **/
	public PageReference searchOrgString() {
        String sQuery = 'SELECT Id, OrganizationName__c, GeographyName__c, Region__c, District__c' +
        	', LocationName__c, BusinessLineName__c, Department__c FROM OrganizationString__c WHERE ';

        if (ECO_Utils_String.NullCheck(newBulkChangeCriteria.searchRegion__c) != '') {
            sQuery += 'Region__c = \'' + newBulkChangeCriteria.searchRegion__c + '\' and ';
        }

        if (ECO_Utils_String.NullCheck(newBulkChangeCriteria.SearchBusinessLine__c) != '') {
            sQuery += 'BusinessLineName__c = \'' + newBulkChangeCriteria.SearchBusinessLine__c + '\' and ';
        }

        sQuery += ' ProjectOwning__c=true';

        //System.debug('DEBUG**** sQuery = ' + sQuery);
        listOrgStrings = Database.query(sQuery);
        //System.debug('DEBUG**** listOrgStrings.size() = ' + listOrgStrings.size());

        selectOrgId = null;

        return null;
	}

	/**
	 * Handles the select org string action
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	PageReference
	 **/
	public PageReference selectOrgString() {
		if (selectOrgId != null) {
			newBulkChangeCriteria.SearchOrganizationString__c = selectOrgId;
		}

		if (newclassValSelected != null) {
			newBulkChangeCriteria.NewClassificationValue__c = newclassValSelected;
		}

		return null;
	}

	/**
	 * Handles the accept bulk change action
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	PageReference
	 **/
	public PageReference handleAccept() {
		return null;
	}


	/**
	 * Handles the initialization of lists
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	void
	 **/
	public void init()
	{
		//System.debug('___newBulkChangeCriteria init()='+newBulkChangeCriteria);
		if (bulkChange.id != null) {
			bulkChange = [select id, Description__c, Comment__c, Status__c, ownerid, Geography__c from BulkChange__c where id=: bulkChange.id];

			ReportDetails__c BulkReplacementReport = null;

			if (recordTypeName == PROJECT_TEAM_CHANGE) {
				BulkReplacementReport = ReportDetails__c.getValues('PTM Bulk Replacement');
			} 
			else if (recordTypeName == ORGANIZATION_CHANGE) {
				BulkReplacementReport = ReportDetails__c.getValues('Org Bulk Replacement');
			}
			else if (recordTypeName == CLASSIFICATION_CHANGE) {
				BulkReplacementReport = ReportDetails__c.getValues('Classification Bulk Replacement');
			}

			if (BulkReplacementReport!=null) {
				reportURL = '/' + BulkReplacementReport.Report_Id__c + '?pv0=' + String.valueOf(bulkChange.id).substring(0, 15);
			} else {
				reportURL = null;
			}
			//System.debug('___reportURL='+reportURL);
		}

		if (bulkChange.Status__c == ECO_Constants.BulkChangeStatusDraft ||  bulkChange.Status__c == ECO_Constants.BulkChangeStatusRejected) {
			canEdit = true;
		} 
		else {
			if (bulkChange.Status__c == ECO_Constants.BulkChangeStatusSubmitted) {
				isSubmitted = true;
			} else if (bulkChange.Status__c == ECO_Constants.BulkChangeStatusExecuted){
				isExecuted = true;
			}
			canEdit = false;
		}

		classificationFieldLabelToFieldNameMap = new Map<String, String>();

		bulkChangeCriterias = new List<BulkChangeCriteriaWrapper>();
		bulkChangeReplacements = new List<BulkChangeReplacement__c>();
		bulkChangeCriteriaMap = new Map<id, BulkChangeCriteriaWrapper>();

		List<Id> contactIds = new List<Id>();


		// Create the NewClassificationPicklist
		Schema.DescribeSObjectResult objSchema = pse__Proj__c.sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getmap();

		if(recordTypeName == CLASSIFICATION_CHANGE){


			classifications = new List<SelectOption>();
			lClassifications = new List<FieldSetMemberWrapper>();
			
			classifications.add(new SelectOption('', '-- Select one --'));  // SelectOption(value, label)

	        for (FieldSetMember oFSM : SObjectType.pse__Proj__c.FieldSets.ECO_OracleClassificationFields.getFields()) {

	            classifications.add(new SelectOption(oFSM.getLabel(), oFSM.getLabel())); // SelectOption(value, label)
	            classificationFieldLabelToFieldNameMap.put(oFSM.getLabel(), oFSM.getFieldPath()); // API name

				////System.debug('___CLASSIFICATION: Label='+oFSM.getLabel()+', API Name='+oFSM.getFieldPath());

	            Schema.DisplayType fieldDataType = fieldMap.get(oFSM.getFieldPath()).getDescribe().getType();
				////System.debug('___Field DataType='+fielddataType);

	            List<Schema.Picklistentry> fieldPicklists =fieldmap.get(oFSM.getFieldPath()).getDescribe().getpicklistValues();
				////System.debug('___Field Picklists='+fieldPicklists);

				String classApi = oFSM.getFieldPath();
				if (fieldDataType == Schema.DisplayType.PICKLIST) {
					//classPicklistMap.put(classApi, fieldPicklists);
				}
				else {
					//classPicklistMap.put(classApi, new List<Schema.Picklistentry>());
					//System.debug('___CLASSIFICATION: Label='+oFSM.getLabel()+', API Name='+oFSM.getFieldPath());
					//System.debug('___Field DataType='+fielddataType);
				}

				String sOrganizationStringValue = oFSM.getFieldPath();
				if (oProject == null) {
					oProject = new pse__Proj__c();
				}

	   		}


			mapClassificationToOptions = new map<string, List<SelectOption>>();
		}

		if (bulkChange.Id != null) {


			for(BulkChangeCriteria__c criteria:[select Id, 
													Name, 
													SearchBusinessLine__c,
													SearchOrganizationString__c,
													SearchRegion__c,
													ExistingTeamMember__c, 
													NewTeamMember__c, 
													EffectiveDate__c, 
													ProjectRole__c, 
													NewOrganizationString__c, 
													ExistingOrganizationString__c, 
													ExistingClassificationValue__c, 
													NewClassificationValue__c, 
													Classification__c,
													ProjectNumber__c
												from BulkChangeCriteria__c 
												where BulkChange__c = :bulkChange.Id]) {
				bulkChangeCriteriaMap.put(criteria.id, new BulkChangeCriteriaWrapper(criteria, false));


				// put in logic to figure out which classification list is needed
				if(recordTypeName == CLASSIFICATION_CHANGE){

					if(criteria.Classification__c != null){

						string apiName = classificationFieldLabelToFieldNameMap.get(criteria.Classification__c);

						List<Schema.Picklistentry> fieldPicklists = fieldMap.get(apiName).getDescribe().getpicklistValues();
						List<SelectOption> options = new List<SelectOption>();
						options.add(new SelectOption('', '-- Select one --'));  // SelectOption(value, label)
						for( Schema.PicklistEntry f : fieldPicklists)
					   	{
					      options.add(new SelectOption(f.getLabel(), f.getLabel()));
					   	}

					   	mapClassificationToOptions.put(criteria.Classification__c, options);

				   	}


				}

			}

			bulkChangeCriterias = bulkChangeCriteriaMap.values();
			//System.debug('___bulkChangeCriterias='+bulkChangeCriterias);

			includedReplacements = getReplacements();
			//System.debug('___includedReplacements size='+includedReplacements.size());

			setController = new Apexpages.Standardsetcontroller(includedReplacements);
	        setController.setPageSize(PAGE_SIZE);	
	        bulkChangeReplacements.addAll((List<BulkChangeReplacement__c>)setController.getRecords());

	        for(BulkChangeReplacement__c br: includedReplacements) {
	        	if (bulkChangeCriteriaMap.containskey(br.BulkChangeCriteria__c)) {

	        		/*IntegrationMessageQueue__c message = null;

	        		if (mapChangeIdToMessage.containskey(br.Change__c)) {
	        			message = mapChangeIdToMessage.get(br.Change__c);
	        		}*/

	        		//ReplacementWrapper rw = new ReplacementWrapper(br, message);

	        		bulkChangeCriteriaMap.get(br.BulkChangeCriteria__c).replacements.add(br);
	        		//bulkChangeCriteriaMap.get(br.BulkChangeCriteria__c).replacementWrapper.add(rw);
	        	}
	        }	

	        Decimal dtotalPages = (setController.getResultSize() / setController.getPageSize());
	        dtotalPages = Math.floor(dtotalPages) + ((Math.mod(setController.getResultSize(), PAGE_SIZE)>0) ? 1 : 0);
	        totalPages = Integer.valueOf(dtotalPages);
	        pageNumber = setController.getPageNumber();
    	} 
    	else {
			setController = new Apexpages.Standardsetcontroller(new List<BulkChangeReplacement__c>());
	        setController.setPageSize(PAGE_SIZE);   
    	}
    	//System.debug('___totalPages='+totalPages+', pageNumber='+pageNumber);




		return;
	}

	/**
	 * Gets Sobjects based on the type of bulk changes
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	List<SObject>
	 **/
	public List<SObject> populateCriteriaResults()
	{
		//System.debug('___newBulkChangeCriteria populateCriteriaResults='+newBulkChangeCriteria);
		String selectStatement = '';
		String whereClause = '';

		if (recordTypeName == PROJECT_TEAM_CHANGE) {
			selectStatement = 'select Id, Name, Contact__c, Project__r.Name, ProjectRole__c from ProjectTeamMember__c';
		}
		else if (recordTypeName == CLASSIFICATION_CHANGE) {
			selectStatement = 'select Id, Name';
			String classification = newBulkChangeCriteria.Classification__c;
			String classificationAPI = '';
			if (classification != null && classification != '') {
				classificationAPI = classificationFieldLabelToFieldNameMap.get(
					classification);
				selectStatement += ', '+classificationAPI;
			} 
			//System.debug('___classification='+classification+', classificationAPI='+classificationAPI);
			selectStatement +=  ' from pse__Proj__c';
			//System.debug('___Class selectStatement='+selectStatement);
		}
		else {
			selectStatement = 'select Id, Name from pse__Proj__c';	
		}
		
		if (recordTypeName == PROJECT_TEAM_CHANGE) { 

			String contactId = newBulkChangeCriteriaWrapper.criteria.ExistingTeamMember__c;
			String roleId = newBulkChangeCriteriaWrapper.criteria.ProjectRole__c;
			String region = newBulkChangeCriteriaWrapper.criteria.SearchRegion__c;
			String business = newBulkChangeCriteriaWrapper.criteria.SearchBusinessLine__c;
			String org = newBulkChangeCriteriaWrapper.criteria.SearchOrganizationString__c;

			whereClause = ' where project__r.pse__Stage__c = \'Execution\' and ProjectRole__r.Type__c = \'Key Member\' and (Contact__c = \'' + contactId + '\'';

			if (roleId != null) {
				whereClause += ' and ProjectRole__c = \'' + roleId + '\'' + ')';
			}
			else {
				whereClause += ') and Active__c = true ';
			}

			if (business != null && business != '') {
				whereClause += ' and project__r.CarryingOutOrganization__r.BusinessLineName__c =\'' + business + '\'';
			}

			if (region != null && region != '') {
				whereClause += ' and project__r.CarryingOutOrganization__r.Region__c =\'' + region + '\'';
			}

			if (org != null && org != '') {
				whereClause += ' and project__r.CarryingOutOrganization__c =\'' + org + '\'';
			}

			if (newBulkChangeCriteria.EffectiveDate__c != null) {
				Date effectiveDate = date.newinstance(newBulkChangeCriteria.EffectiveDate__c.year(), 
					newBulkChangeCriteria.EffectiveDate__c.month(), newBulkChangeCriteria.EffectiveDate__c.day());
				string sdate = String.valueof(effectiveDate);
				whereClause += ' and StartDate__c < ' + sdate + ' and (EndDate__c = null or EndDate__c >= ' + sdate + ')';
			}

			if (newBulkChangeCriteria.ProjectNumber__c != null) {
				whereClause += ' and project__r.ProjectNumber__c = \'' + newBulkChangeCriteria.ProjectNumber__c + '\'';
			}

			
		} 
		else if (recordTypeName == ORGANIZATION_CHANGE) { 

			whereClause = ' where (pse__Stage__c = \'Execution\' or pse__Stage__c = \'Pre-Contract\' or pse__Stage__c = \'Planning\' or pse__Stage__c = \'Pending Go/No Go\' )';

			if (newBulkChangeCriteria.ProjectNumber__c != null) {
				whereClause += ' and ProjectNumber__c = \'' + newBulkChangeCriteria.ProjectNumber__c + '\'';
			} else {
				whereClause += ' and CarryingOutOrganization__c = \'' + newBulkChangeCriteria.ExistingOrganizationString__c + '\'';
			}
		}
		else if (recordTypeName == CLASSIFICATION_CHANGE) {
			String classification = newBulkChangeCriteriaWrapper.criteria.Classification__c;
			String classificationFilter = newBulkChangeCriteriaWrapper.criteria.ExistingClassificationValue__c;
			String region = newBulkChangeCriteriaWrapper.criteria.SearchRegion__c;
			String business = newBulkChangeCriteriaWrapper.criteria.SearchBusinessLine__c;
			String org = newBulkChangeCriteriaWrapper.criteria.SearchOrganizationString__c;

			whereClause = ' WHERE pse__Stage__c = \'Execution\' ';

			if (business != null && business != '') {
				whereClause += ' and CarryingOutOrganization__r.BusinessLineName__c =\'' + business + '\'';
			}

			if (region != null && region != '') {
				whereClause += ' and CarryingOutOrganization__r.Region__c =\'' + region + '\'';
			}

			if (org != null && org != '') {
				whereClause += ' and CarryingOutOrganization__c =\'' + org + '\'';
			}

			// Does classification field have a value that's defined in the Criteria ?
			if (classification != null || classification == '') {
				//whereClause += ' and ' + classificationFieldLabelToFieldNameMap.get(
				//	classification) + ' = \'' + classification + '\'';
				String classificationAPI = '';
				if (classification != null && classification != '') {
					classificationAPI = classificationFieldLabelToFieldNameMap.get(classification);
					//System.debug('___classification='+classification+', classificationAPI='+classificationAPI);
					if (classificationFilter != null && classificationFilter != '') {
						whereClause += ' and ' + classificationAPI + ' = \'' + classificationFilter + '\'';
					}
				}
			}

			if (newBulkChangeCriteria.ProjectNumber__c != null) {
				whereClause += ' and EcoSystemReferenceNumber__c = \'' + newBulkChangeCriteria.ProjectNumber__c + '\'';
			}
		}

		/*else if (recordTypeName == 'Organization Change') {

			String organizationId = newBulkChangeCriteriaWrapper.criteria.ExistingOrganizationString__c;
			
			whereClause = ' where CarryingOutOrganization__c = \'' + organizationId + '\'';
			
		}

		else if (recordTypeName == 'Classification Change') {

			String classificationValue = newBulkChangeCriteriaWrapper.criteria.ExistingClassificationValue__c;
			
			whereClause = ' where ' + classificationFieldLabelToFieldNameMap.get(newBulkChangeCriteriaWrapper.criteria.Classification__c) + ' = \'' + classificationValue + '\'';
		}*/

		String soql = selectStatement + whereClause;
		//System.debug('___populateCriteriaResults SOQL = '+soql);
		return Database.query(soql);
	}

	/**
	 * Creates a new blank criteria
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	PageReference
	 **/
	public PageReference newCriteria()
	{
		newBulkChangeCriteria = new BulkChangeCriteria__c();
		newBulkChangeCriteriaWrapper = new BulkChangeCriteriaWrapper(newBulkChangeCriteria, true);

		bulkChangeCriterias.add(newBulkChangeCriteriaWrapper);

		optionsNewClassifications = new List<SelectOption>(); // reset


		newButtonDisabled = true;

		return null;
	}

	/**
	 * Handles the save critera action
	 *
	 * @Author      NTT Data - Tim Chiang, Arman Shah
	 * @Date        2016
	 *
	 * @return 	PageReference
	 **/
	public PageReference saveCriteria()
	{


		if (recordTypeName == PROJECT_TEAM_CHANGE) {
			if (newBulkChangeCriteria.ExistingTeamMember__c == null || newBulkChangeCriteria.EffectiveDate__c == null) {
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
					label.Error_Please_populate_both_Existing_Team_Member_and_Effective_Date);
	            ApexPages.addMessage(myMsg);
				return null;
			}
		} 
		else if (recordTypeName == ORGANIZATION_CHANGE) {
			if (newBulkChangeCriteria.ProjectNumber__c == null && newBulkChangeCriteria.ExistingOrganizationString__c == null) {
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
					label.Error_Please_populate_either_Project_Number_or_Existing_Org);
	            ApexPages.addMessage(myMsg);
				return null;
			}			
		}
		else if (recordTypeName == CLASSIFICATION_CHANGE) {
			if (newBulkChangeCriteria.Classification__c == null || newBulkChangeCriteria.Classification__c == '') {
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,
					label.Error_Please_enter_a_criteria_to_filter_on);
	            ApexPages.addMessage(myMsg);
				return null;
			}			
		}



		System.Savepoint savePoint = Database.setSavepoint();

		if (bulkChange.Id == null) {
			try{
				insert bulkChange;
			}
            catch(Exception e)
            {
                ECO_Service_ErrorLog.formatPageError(e, label.Problem_saving_new_bulk_change);
                //System.debug('Exception='+e.getStackTraceString());
                return null;
            }
		}


		if (newBulkChangeCriteria != null) {

			if (newclassValSelected != null) {
				newBulkChangeCriteria.NewClassificationValue__c = newclassValSelected;
			}
			newBulkChangeCriteria.BulkChange__c = bulkChange.Id;

			try{
				upsert newBulkChangeCriteria;
				newclassValSelected = '';  //reset
			}
            catch(Exception e)
            {
                ECO_Service_ErrorLog.formatPageError(e, label.Problem_saving_new_criteria);
                //System.debug('Exception='+e.getStackTraceString());
                Database.rollback(savePoint);
                return null;
            }
		} 
		else {
			return null;
		}


		List<BulkChangeReplacement__c> savedReplacements = new List<BulkChangeReplacement__c>();

		if (recordTypeName == PROJECT_TEAM_CHANGE) {
			List<ProjectTeamMember__c> teamMembers = populateCriteriaResults();

			//System.debug('DEBUG***: Got Results :' + teamMembers.size());

			for(ProjectTeamMember__c projectTeam:teamMembers) {
				savedReplacements.add(new BulkChangeReplacement__c(
										BulkChangeCriteria__c = newBulkChangeCriteria.id, 
										BulkChange__c = bulkChange.Id, 
										Project__c = projectTeam.Project__c, 
										ProjectRole__c = projectTeam.ProjectRole__c, 
										EffectiveDate__c = newBulkChangeCriteria.EffectiveDate__c, 
										ExistingTeamMember__c = newBulkChangeCriteria.ExistingTeamMember__c, 
										NewTeamMember__c = newBulkChangeCriteria.NewTeamMember__c,
										ProjectTeamMember__c = projectTeam.id
										));
			}
		}
		else if (recordTypeName == ORGANIZATION_CHANGE) {
			List<pse__Proj__c> projects = populateCriteriaResults();
			for(pse__Proj__c project:projects) {
				savedReplacements.add(new BulkChangeReplacement__c(
										BulkChangeCriteria__c = newBulkChangeCriteria.id, 
										BulkChange__c = bulkChange.Id, 
										Project__c = project.Id, 
										NewOrganizationString__c = newBulkChangeCriteria.NewOrganizationString__c , 
										ExistingOrganizationString__c = newBulkChangeCriteria.ExistingOrganizationString__c
										));
			}	
		}
		else if (recordTypeName == CLASSIFICATION_CHANGE) {


			List<pse__Proj__c> projects = populateCriteriaResults();
			for(pse__Proj__c project:projects) {
				String classification = newBulkChangeCriteria.Classification__c;
				String classificationAPI = '';
				String classValue = '';
				if (classification != null && classification != '') {
					classificationAPI = classificationFieldLabelToFieldNameMap.get(classification);

					classValue = (String) project.get(classificationAPI);
				}
				else {
					classValue = newBulkChangeCriteria.ExistingClassificationValue__c;
				}

				
				savedReplacements.add(new BulkChangeReplacement__c(
										BulkChangeCriteria__c = newBulkChangeCriteria.id, 
										BulkChange__c = bulkChange.Id, 
										Project__c = project.Id, 
										Classification__c = newBulkChangeCriteria.Classification__c, 
										NewClassificationValue__c = newBulkChangeCriteria.NewClassificationValue__c, 
										ExistingClassificationValue__c = classValue //newBulkChangeCriteria.ExistingClassificationValue__c
										));
			}	
		}


		if (!savedReplacements.isEmpty()) {
			try{
				upsert savedReplacements;

			}
            catch(Exception e)
            {
                ECO_Service_ErrorLog.formatPageError(e, label.Problem_saving_bulk_change_replacements);

                Database.rollback(savePoint);
                return null;
            }			
		}


		init();
		newButtonDisabled = false;

		return null;
	}

	/**
	 * Gets classification values
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	PageReference
	 **/
	public List<SelectOption> getClassValues()
	{
		return null;
	}

	/**
	 * getHasNext setController action
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	Boolean
	 **/
	public Boolean getHasNext() 
    {
        return setController.getHasNext();  
    }

	/**
	 * next setController action
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	PageReference
	 **/
    public PageReference next() 
    {
    	setController.save();
        setController.next();
        bulkChangeReplacements = (List<BulkChangeReplacement__c>)setController.getRecords();
        pageNumber = setController.getPageNumber();
        return null;
    }   
    
	/**
	 * getHasPrevious setController action
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	Boolean
	 **/    
    public Boolean getHasPrevious() 
    {
        return setController.getHasPrevious();  
    }
    
	/**
	 * previous setController action
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	PageReference
	 **/
    public PageReference previous() 
    {
    	setController.save();
        setController.previous();
        bulkChangeReplacements = (List<BulkChangeReplacement__c>)setController.getRecords();
        pageNumber = setController.getPageNumber();
        return null;
    }

	/**
	 * handles the execution of changes action
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	PageReference
	 **/
    public PageReference executeChanges() {

    	includedReplacements = getReplacements();



		for(BulkChangeReplacement__c bcr:includedReplacements) {
			if (bcr.Exclude__c == false && (bcr.status__c == ECO_Constants.BulkChangeReplacementStatusPending || 
				bcr.status__c == ECO_Constants.BulkChangeReplacementStatusError)) {
					bcr.status__c = ECO_Constants.BulkChangeReplacementStatusSubmitted;
			}
		}

		try{
			update includedReplacements;
		}
        catch(Exception e)
        {
            ECO_Service_ErrorLog.formatPageError(e, label.Problem_saving_the_submitted_status_on_bulk_replacements);
            //System.debug('Exception='+e.getStackTraceString());
            return null;
        }

		// Run Batch Job		
		ECO_Batch_BulkChange batchBulkChange = new ECO_Batch_BulkChange();
		batchBulkChange.bulkChangeId = bulkChange.id;
		Id batchInstanceId = Database.executeBatch(batchBulkChange, batchSize);
		//System.debug('___batchInstanceId = '+batchInstanceId);

    	bulkChange.Status__c =ECO_Constants.BulkChangeStatusApproved;

		try{
			update bulkChange;
		}
        catch(Exception e)
        {
            ECO_Service_ErrorLog.formatPageError(e, label.Problem_saving_the_approved_status_of_the_bulk_change);
            //System.debug('Exception='+e.getStackTraceString());
            return null;
        }

        init();

        PageReference returnpage =  new PageReference('/apex/ECO_BulkChange?id=' + bulkChange.id);
        returnpage.setRedirect(true);
		return returnpage;
    }

	/**
	 * handles the resend of changes action
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	PageReference
	 **/
    public PageReference resendChanges() {

    	includedReplacements = getReplacements();

    	list<BulkChangeReplacement__c> resendList = new list<BulkChangeReplacement__c>();

		for(BulkChangeReplacement__c bcr:includedReplacements) {
			if (bcr.Exclude__c == false && bcr.MessageStatus__c == 'Error') {
				bcr.status__c = ECO_Constants.BulkChangeReplacementStatusSubmitted;
				bcr.Change__c = null;
				bcr.IntegrationMessageQueue__c = null;
				resendList.add(bcr);
			}
		}

		if(!resendList.isEmpty()){
			try{
				update resendList;
			}
	        catch(Exception e)
	        {
	            ECO_Service_ErrorLog.formatPageError(e, label.Problem_saving_the_submitted_status_on_bulk_replacements);
	            //System.debug('Exception='+e.getStackTraceString());
	            return null;
	        }

			// Run Batch Job		
			ECO_Batch_BulkChange batchBulkChange = new ECO_Batch_BulkChange();
			batchBulkChange.bulkChangeId = bulkChange.id;
			batchBulkChange.resend = true;
			Id batchInstanceId = Database.executeBatch(batchBulkChange, batchSize);
			//System.debug('___batchInstanceId = '+batchInstanceId);

			bulkChange.Status__c =ECO_Constants.BulkChangeStatusResent;

			try{
				update bulkChange;
			}
	        catch(Exception e)
	        {
	            ECO_Service_ErrorLog.formatPageError(e, label.Problem_saving_the_approved_status_of_the_bulk_change);
	            //System.debug('Exception='+e.getStackTraceString());
	            return null;
	        }

	        init();
		}
		
        PageReference returnpage =  new PageReference('/apex/ECO_BulkChange?id=' + bulkChange.id);
        returnpage.setRedirect(true);
		return returnpage;
    }


	/**
	 * handles the save replacements action
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	PageReference
	 **/
	public PageReference saveReplacements()
	{
		setController.save();
		return null;
	}	

	/**
	 * authenticates oracle login credentials
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	PageReference
	 **/
    public PageReference authenticateCredentials()
    {
        String username = ApexPages.currentPage().getParameters().get('username');
        String password = ApexPages.currentPage().getParameters().get('password');

        ECO_IntegrationEndpoints__c cs = ECO_IntegrationEndpoints__c.getInstance('Project Sync 2');
        String endPointUrl = cs.EndPointUrl__c;

        authenticationResult = ECO_Service_Authentication.TestProxy(endPointUrl, 
        	'PICAction=CreateSHAKey&UserId=' + username + '&Password=' + EncodingUtil.URLENCODE(password,'UTF-8'));
        //System.debug('___authenticationResult='+authenticationResult);
        return null;
    }

	/**
	 * handles close authentication action
	 *
	 * @Author      NTT Data - Tim Chiang
	 * @Date        2016
	 *
	 * @return 	PageReference
	 **/
    public PageReference closeAuthenticationWindow()
    {
    	if(isExecuted){
    		resendChanges();
    	} else {
    		executeChanges();
    	}
    	
    	return null;         
    }     
}