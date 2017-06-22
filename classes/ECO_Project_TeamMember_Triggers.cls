/** ------------------------------------------------------------------------------------------------------
* @Description Trigger handler for ProjectTeamMember__c object
*
* @Author      NTT Data - ?, Deborah Orth
* @Date        2015
*-----------------------------------------------------------------------------------------------------*/
public without sharing class ECO_Project_TeamMember_Triggers {
	
	public static Boolean run = true;

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public static void createPortalAlertForChangedKeyMember(Map<Id, ProjectTeamMember__c> oldTeamMembers, List<ProjectTeamMember__c> newTeamMembers)
	{
		if ( ! run) { return; }
		//System.debug('createPortalAlertForChangedKeyMember called');
		Id alertRecordTypeId = ECO_Utils_Meta.getRecordTypeId(PortalMessage__c.sObjectType, ECO_Constants.PortalMessage_AlertRecordTypeDeveloperName);
		for(ProjectTeamMember__c teamMember:newTeamMembers)
		{
			if((teamMember.EndDate__c != oldTeamMembers.get(teamMember.Id).EndDate__c) && teamMember.ProjectRoleName__c == 'Project Manager')
			{
				//private static PortalMessage__c createNewAlertForPM (pse__Proj__c proj, Date theDate, String theMessage) {
				PortalMessage__c newPM = new PortalMessage__c();
				newPM.User__c = teamMember.TeamMemberUserId__c;
				newPM.RecordTypeId = alertRecordTypeId;
				newPM.StartDate__c = Date.today();
				newPM.EndDate__c = Date.today().addDays(7);
				newPM.IsEscalationAlert__c = true;
				newPM.Project_Number__c = teamMember.ePMSystemReferenceNumber__c;
				newPM.LongDescriptionMaxLength__c = 'A new Project Manager has been assigned to project ' + teamMember.OracleProjectNumber__c + ' - ' + teamMember.ProjectName__c + '. If applicable, complete the PM Handover form in the Change Management section of the Project Plan.';
				newPM.Subject__c = teamMember.ProjectName__c;
				newPM.LinkToRecord__c = URL.getSalesforceBaseUrl().toExternalForm()+'/'+teamMember.Project__c;


/*RecordTypeId = alertRecordTypeId
											, User__c = project.Project_Manager_User__c
											, StartDate__c = Date.today()
											, EndDate__c = Date.today().addDays(1)
											, LongDescriptionMaxLength__c = 'You have passed the restart date for this On Hold Project'
											, Subject__c = project.Name
											, LinkToRecord__c = '/' + project.Id*/
				insert newPM;
				//return newPM;
			}
		}
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public static void setProjectFields(List<ProjectTeamMember__c> newTeamMembers){
		Map<id, pse__Proj__c> mapProj;
		Map<id, pse__Proj__c> mapProjToUpdate = new Map<id, pse__Proj__c>();
		List<ProjectTeamMember__c> lstPTMtoUpdate = new List<ProjectTeamMember__c>();
		Set<id> sProj = new Set<id>();

		if (!run || !ECO_TriggerSettings.getIsTriggerEnabled('setProjectFields')) {
			return;
		}

		//get all the active roles available for a project
		Map<ID, ProjectRole__c> mapOfProjectRoles = new Map<ID, ProjectRole__c> ( [SELECT 
																					Active__c, 
																					Type__c, 
																					Id, 
																					Name 
																				FROM ProjectRole__c 
																				WHERE Active__c = true] ); 

		//what projects are we handling?
		for(ProjectTeamMember__c obj: newTeamMembers){
			sProj.add(obj.Project__c);
		}

		//get the project member info for those projects
		mapProj = new Map<id, pse__Proj__c>([SELECT 
												Id, 
												ProjectApprover__c, 
												CaptureManager__c, 
												pse__Project_Manager__c, 
												PnLManager__c, 
												pse__Stage__c, 
												FinanceLead__c 
											FROM pse__Proj__c 
											WHERE id IN: sProj]);
		
		//process each team member
		for(ProjectTeamMember__c oPTM: newTeamMembers){
			if( (oPTM.StartDate__c <= Date.today() && (oPTM.EndDate__c == null || oPTM.EndDate__c >= Date.today())) 
				|| (mapProj.get(oPTM.Project__c).pse__Stage__c == 'Planning' || mapProj.get(oPTM.Project__c).pse__Stage__c == 'Pending Go/No Go')
				|| mapOfProjectRoles.get(oPTM.ProjectRole__c).Name == 'Capture Manager' 
				&& oPTM.ProjectUpdated__c == false 
				&& (
					mapOfProjectRoles.get(oPTM.ProjectRole__c).Name == 'Project Approver' 
					|| mapOfProjectRoles.get(oPTM.ProjectRole__c).Name == 'Project Manager' 
					|| mapOfProjectRoles.get(oPTM.ProjectRole__c).Name == 'Project Approver 2'
				)
			){

				//System.debug('DEBUG***: PASSED CONDITION to process team members.  Project Role:' + oPTM.ProjectRole__c + 'oPTM.Contact__c: ' + oPTM.Contact__c); 
				if( mapOfProjectRoles.get(oPTM.ProjectRole__c).Name == 'Capture Manager' 
					&& !ECO_TriggerSettings.isBypassed( 'PR_createCaptureManagerTeamMember')){
					if(mapProj.get(oPTM.Project__c).CaptureManager__c != oPTM.Contact__c){
						mapProj.get(oPTM.Project__c).CaptureManager__c = oPTM.Contact__c; 
						mapProjToUpdate.put(mapProj.get(oPTM.Project__c).id, mapProj.get(oPTM.Project__c));  
					}
				}

				// this line of code has to stay in order to facilitate snapshot MTD dirty flagging. Discuss with the team before removing.
				// Its important because we count on this action to set the project to dirty so that it will be picked up in a batch job.		
				if(oPTM.Status__c == 'Approved'){
					if(mapOfProjectRoles.get(oPTM.ProjectRole__c).name == 'Project Approver'){
						if(mapProj.get(oPTM.Project__c).ProjectApprover__c != oPTM.Contact__c){
							mapProj.get(oPTM.Project__c).ProjectApprover__c = oPTM.Contact__c;  
							mapProjToUpdate.put(mapProj.get(oPTM.Project__c).id, mapProj.get(oPTM.Project__c));             
						}
	
	
					} else if(mapOfProjectRoles.get(oPTM.ProjectRole__c).name == 'Project Manager'){
						if(mapProj.get(oPTM.Project__c).pse__Project_Manager__c != oPTM.Contact__c){
							mapProj.get(oPTM.Project__c).pse__Project_Manager__c = oPTM.Contact__c; 
							mapProjToUpdate.put(mapProj.get(oPTM.Project__c).id, mapProj.get(oPTM.Project__c));             
						}
	
	
					}else if(mapOfProjectRoles.get(oPTM.ProjectRole__c).name == 'Project Approver 2'){
	
						if(mapProj.get(oPTM.Project__c).PnLManager__c != oPTM.Contact__c){
							mapProj.get(oPTM.Project__c).PnLManager__c = oPTM.Contact__c;   
							mapProjToUpdate.put(mapProj.get(oPTM.Project__c).id, mapProj.get(oPTM.Project__c));         
						}
	
					}else if(mapOfProjectRoles.get(oPTM.ProjectRole__c).name == 'Finance Lead'){
	
						if(mapProj.get(oPTM.Project__c).FinanceLead__c != oPTM.Contact__c){
							mapProj.get(oPTM.Project__c).FinanceLead__c = oPTM.Contact__c;   
							mapProjToUpdate.put(mapProj.get(oPTM.Project__c).id, mapProj.get(oPTM.Project__c));         
						}
	
					}
				}
			}
		}

		if(mapProjToUpdate.size() >0 && !ECO_TriggerSettings.isBypassed('PR_createCaptureManagerTeamMember')){
			try {
				update mapProjToUpdate.values();
			} catch (Exception e){
				ECO_Service_ErrorLog.logException(e);
			}
		}        
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/	
	public static void setChangeManagerIsChangedFlag(List<ProjectTeamMember__c> updatedTeamMembers)
	{
		if (!run || ECO_TriggerSettings.isBypassed('PTMT_setChangeManagerIsChangedFlag') || UserInfo.getUserName().toLowerCase().contains('integration@aecom.com')) 
			return;
		for(ProjectTeamMember__c teamMember : updatedTeamMembers){
			teamMember.ChangeManagerIsChanged__c = true; 
		}
	}    

	/**
	 * Creates new pse__Permission records for new team members, some roles get edit and other's get view only
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   newTeamMembers - the trigger.new list
	 * @return  
	 **/	
	public static void permissionGanttView(List<ProjectTeamMember__c> newTeamMembers){

		if (!run || !ECO_TriggerSettings.getIsTriggerEnabled('permissionGanttView')) {
			return;
		}
		Set<id> sContacts = new Set<id>();

		for(ProjectTeamMember__c ptm: newTeamMembers){
			sContacts.add(ptm.Contact__c);
		}

		Map<Id, Contact> contactsMap = new Map<Id, Contact>([select Id, FirstName, LastName, pse__Salesforce_User__c from Contact where Id in :sContacts]);
		Map<ID, ProjectRole__c> mapOfProjectRoles = new Map<ID, ProjectRole__c> ( [SELECT Active__c, Type__c, Id, Name FROM ProjectRole__c Where Active__c = true] );    
		List<pse__Permission_Control__c> newPermissions = new List<pse__Permission_Control__c>();

		for(ProjectTeamMember__c ptm: newTeamMembers){

			if(contactsMap.get(ptm.contact__c).pse__Salesforce_User__c != null){
				pse__Permission_Control__c permission = new pse__Permission_Control__c(				
																					ProjectTeamMember__c = ptm.id,
																					pse__End_Date__c = ptm.enddate__c,
																					pse__Project__c = ptm.project__c,
																					pse__Start_Date__c = ptm.startdate__c,
																					pse__User__c = contactsMap.get(ptm.contact__c).pse__Salesforce_User__c,
																					pse__View_Task_Manager__c = true,
																					AccessReason__c = mapOfProjectRoles.get(ptm.ProjectRole__c).name
																					);

				if(mapOfProjectRoles.get(ptm.ProjectRole__c).name == 'Deputy Project Manager' ||
					mapOfProjectRoles.get(ptm.ProjectRole__c).name == 'Project Manager' ||
					mapOfProjectRoles.get(ptm.ProjectRole__c).name == 'Capture Manager' ||
					mapOfProjectRoles.get(ptm.ProjectRole__c).name == 'Project Accountant' ||
					mapOfProjectRoles.get(ptm.ProjectRole__c).name == 'Project Accountant 2'){
					permission.pse__Edit_Task_Manager__c = true;
					   
				}
				newPermissions.add(permission);

			}

		}
		if(newPermissions.size() > 0){
			try {
				insert newPermissions;
			} catch (Exception e){ 
				ECO_Service_ErrorLog.logException(e);
			}
		}

	}

	/**
	 * Checks for a change in Project Team Member for a project; updates old Project Team Member permissions to expire their record
	 * and adds new Project Team Member permission with edit access
	 * Priya 06/15/2016: Modified code to support updating of all roles in Permission Control.
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    May 2016
	 *
	 * @param   tOld - the list of records before the change
	 * @param   tNewMap - the map of records after the change
	 * @return  
	 **/	
	public static void permissionGanttViewChangeCaptureManager(List<ProjectTeamMember__c> tOld, Map<Id, ProjectTeamMember__c> tNewMap){
	
		Set<Id> outgoingCM = new Set<Id>();
		Set<Id> incomingCM = new Set<Id>();
		Set<Id> outgoingPermissionUsers = new Set<Id>();
		Set<Id> projectIds = new Set<Id>();
		
		if (!run || !ECO_TriggerSettings.getIsTriggerEnabled('permissionGanttViewChangeCaptureManager')) {
			return;
		}

		Map<Id, ProjectRole__c> mapOfProjectRoles = new Map<Id, ProjectRole__c> ( [SELECT 
																					Id, 
																					Name 
																				FROM ProjectRole__c 
																				WHERE Active__c = true]);    

		//do we have any capture manager changes?
		for(ProjectTeamMember__c ptm : tOld){
			if( mapOfProjectRoles.get(ptm.ProjectRole__c).Name != mapOfProjectRoles.get(tNewMap.get(ptm.Id).ProjectRole__c).Name ){
				outgoingCM.add( ptm.Contact__c);
				incomingCM.add( tNewMap.get(ptm.Id).Contact__c);
				projectIds.add(ptm.Project__c);
			}
		}

		//do we have any capture manager personnel changes?
		for(ProjectTeamMember__c ptm : tOld){
			if( ptm.Contact__c != tNewMap.get(ptm.Id).Contact__c ){
				outgoingCM.add( ptm.Contact__c);
				incomingCM.add( tNewMap.get(ptm.Id).Contact__c);
				projectIds.add(ptm.Project__c);
			}
		}

		//are there any CM changes, if not get out of here
		if( outgoingCM.isEmpty() && incomingCM.isEmpty()){
			return;
		}

		//what users are losing the CM designation?
		for( Contact outgoing : [SELECT 
									Id, 
									FirstName, 
									LastName, 
									pse__Salesforce_User__c 
								FROM Contact 
								WHERE Id IN : outgoingCM
								]){
			outgoingPermissionUsers.add( outgoing.pse__Salesforce_User__c);
		}

		//get the outgoing permission records for updated projects and update to expire the permissions
		
		List<pse__Permission_Control__c> updateOutgoingPermissions = [SELECT 
																		Id 
																		FROM pse__Permission_Control__c
																		WHERE pse__User__c IN :outgoingPermissionUsers
																			AND pse__Project__c IN :projectIds];

		//set pse__End_Date__c to yesterday to expire the permission
		for( pse__Permission_Control__c pc : updateOutgoingPermissions){
			pc.pse__End_Date__c = Date.today().addDays(-1);
		}

		//What users are gaining new permissions?
		Map<Id, Contact> incomingContactMap = new Map<Id, Contact>([SELECT 
																		Id, 
																		FirstName, 
																		LastName, 
																		pse__Salesforce_User__c 
																	FROM Contact 
																	WHERE Id IN : incomingCM]);

		List<pse__Permission_Control__c> newPermissions = new List<pse__Permission_Control__c>();		
		for( ProjectTeamMember__c ptm : tNewMap.values()){
			if( incomingContactMap.containsKey(ptm.Contact__c)){
				pse__Permission_Control__c permission = new pse__Permission_Control__c(
																ProjectTeamMember__c = ptm.id,
																pse__End_Date__c = ptm.enddate__c,
																pse__Project__c = ptm.project__c,
																pse__Start_Date__c = ptm.startdate__c,
																pse__User__c = incomingContactMap.get(ptm.contact__c).pse__Salesforce_User__c,
																pse__View_Task_Manager__c = true,
																AccessReason__c = mapOfProjectRoles.get(ptm.ProjectRole__c).name);

				if(mapOfProjectRoles.get(ptm.ProjectRole__c).name == 'Deputy Project Manager' ||
					mapOfProjectRoles.get(ptm.ProjectRole__c).name == 'Project Manager' ||
					mapOfProjectRoles.get(ptm.ProjectRole__c).name == 'Capture Manager' ||
					mapOfProjectRoles.get(ptm.ProjectRole__c).name == 'Project Accountant' ||
					mapOfProjectRoles.get(ptm.ProjectRole__c).name == 'Project Accountant 2'){
					permission.pse__Edit_Task_Manager__c = true;
					   
				}

				newPermissions.add(permission);
			}

		}

		Savepoint savePoint = Database.setSavepoint();

		//update the old
		if( !updateOutgoingPermissions.isEmpty()){
			try {
				update updateOutgoingPermissions;
			} catch (Exception e){
				Database.rollback( savePoint);
				ECO_Service_ErrorLog.logException(e);
				return;
			}
		}
		//insert the new	
		if( !newPermissions.isEmpty()){
			try {
				insert newPermissions;
			} catch (Exception e){
				Database.rollback( savePoint);
				ECO_Service_ErrorLog.logException(e);
			}
		}

	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/	
	public static void handleAfterInsertValidation(Map<id, ProjectTeamMember__c> newTeamMemberMap)
	{


		if (!run || ECO_TriggerSettings.isBypassed('PTMT_handleAfterInsertValidation')) {
			return;
		}
		//System.debug('handleAfterInsertValidation called');
		// validate if the stakeholder has an overlapping timeframe

		Set<id> projIDs = new Set<id>();
		
		for(ProjectTeamMember__c ptm: newTeamMemberMap.values()){
			projIDs.add(ptm.project__c);
		}


		List<ProjectTeamMember__c> lstProjectMembers = [select id, project__c, ProjectRole__c, ProjectRole__r.name, StartDate__c, EndDate__c, Name__c from ProjectTeamMember__c where project__c IN: projIDs ORDER BY project__c, ProjectRole__c, StartDate__c ASC];


		Map<string, List<ProjectTeamMember__c>> ptmMap = new Map<string, List<ProjectTeamMember__c>>();

		for(ProjectTeamMember__c ptm: lstProjectMembers){

			string idRoleKey = ptm.project__c + '-' + ptm.ProjectRole__c;

			if(!ptmMap.containsKey(idRoleKey)){
				ptmMap.put(idRoleKey, new List<ProjectTeamMember__c>());
			}

			ptmMap.get(idRoleKey).add(ptm);
		}

		for(ProjectTeamMember__c ptm: newTeamMemberMap.values()){

			string idRoleKey = ptm.project__c + '-' + ptm.ProjectRole__c;

			if(ptmMap.containskey(idRoleKey)){

				for(ProjectTeamMember__c existingPTM: ptmMap.get(idRoleKey) ){

					if(existingPTM.id != ptm.id && existingPTM.ProjectRole__r.name != 'Deputy Project Manager' &&
						(
						(ptm.StartDate__c >= existingPTM.StartDate__c && ((ptm.StartDate__c <= existingPTM.EndDate__c) || (existingPTM.EndDate__c == null ))) ||
						(ptm.EndDate__c >= existingPTM.StartDate__c && ((ptm.EndDate__c <= existingPTM.EndDate__c) || (existingPTM.EndDate__c == null )))
						)){

						ptm.adderror('Cannot save team member due to overlapping start and/or end date ' + existingPTM.id + ' and ' + ptm.id);
						/* bk added for debugging ptm.adderror('Existing Role Name ' + existingPTM.ProjectRole__c);
						ptm.adderror('New Role Name ' + ptm.ProjectRole__c);
						ptm.addError('New PTM Start Date' + ptm.StartDate__c );
						ptm.addError('Existing PTM Start Date' + existingPTM.StartDate__c );
						ptm.addError('New PTM' + ptm.Name__c);
						ptm.addError('Existing PTM' + existingPTM.Name__c);*/

					}
				}
			}
		}        
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/	
	public static void handleBeforeInsert(List<ProjectTeamMember__c> newTeamMembers)
	{
		if ( ! run) { return; }
		//system.debug( 'ECO_Project_TeamMember_AllEvents - catch3 ');
		/*Map<Id, Id> projectTeamContactMap = new Map<Id, Id>();
		
		for(ProjectTeamMember__c ptm: newTeamMembers)
			projectTeamContactMap.put(ptm.id, ptm.Contact__c);
		
		Map<Id, Contact> contactsMap = new Map<Id, Contact>([select Id, FirstName, LastName from Contact where Id in :projectTeamContactMap.values()]);
		
		for(ProjectTeamMember__c ptm: newTeamMembers)
		{
			ptm.Name = contactsMap.get(projectTeamContactMap.get(ptm.Id)).FirstName + ' ' + contactsMap.get(projectTeamContactMap.get(ptm.Id)).LastName;
		}*/


		//Map<Id, Id> projectTeamContactMap = new Map<Id, Id>();
		//System.debug('handleBeforeInsert called');
		Set<id> sContacts = new Set<id>();
		Set<id> projIDs = new Set<id>();
		for(ProjectTeamMember__c ptm: newTeamMembers){
		   // projectTeamContactMap.put(ptm.id, ptm.Contact__c);
			sContacts.add(ptm.Contact__c);
			projIDs.add(ptm.project__c);
		}
		
		Map<Id, Contact> contactsMap = new Map<Id, Contact>([select Id, FirstName, LastName from Contact where Id in :sContacts]);
		
		for(ProjectTeamMember__c ptm: newTeamMembers)
		{
			ptm.Name = contactsMap.get(ptm.Contact__c).FirstName + ' ' + contactsMap.get(ptm.Contact__c).LastName;
		}
		
	}
	
	/**Project can have only one Capture Manager
	 * 
	 *
	 * @Author  NTT Data - Priya Parepalli, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/	
	public static void checkDuplicateCM (List<ProjectTeamMember__c> newTeamMembers, Map<Id, ProjectTeamMember__c> oldPTMMap, Map<Id, ProjectTeamMember__c> newPTMMap){
		if ( ! run || ECO_TriggerSettings.isBypassed('PR_createCaptureManagerTeamMember')) { return; }
		
		//System.debug('inside checkDuplicateCM called');
		ProjectRole__c oRole = [Select Id, Name From ProjectRole__c Where Name = 'Capture Manager'];
		List<Id> lProjectIds = new List<Id>();
		
		for(ProjectTeamMember__c projectTeamMember : newTeamMembers){
			lProjectIds.add(projectTeamMember.Project__c);
		}
		List<ProjectTeamMember__c> lALLPTM = [Select Id, Project__c, ProjectRole__c, ProjectRoleName__c, Name__c 
												From ProjectTeamMember__c 
												Where Project__c IN: lProjectIds 
												AND ProjectRole__c = :oRole.id AND Is_Active__c = TRUE];
		for(ProjectTeamMember__c projectTeamMember : newTeamMembers){
			Integer count = 0;
			for(ProjectTeamMember__c oPTM : lALLPTM){
				if(projectTeamMember.Project__c == oPTM.Project__c && projectTeamMember.ProjectRole__c == oRole.Id && oPTM.ProjectRole__c == oRole.Id){
					count++;
				}
			}
			if(count > 1){
				projectTeamMember.addError('Error: Cannot have more than one Capture Manager for a Project.');
			}
		}
		
	}
	
    /**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public static void DeleteSharingForTeamMembers(List<ProjectTeamMember__c> deletedTeamMembers, Map<Id, ProjectTeamMember__c> oldProjectsTMMap, Map<Id, ProjectTeamMember__c> newProjectsTMMap) {
		
		if ( ! run) { return; }
		//system.debug( 'deletedTeamMembers size ' + deletedTeamMembers.size() + ' deletedTeamMembers ' + deletedTeamMembers );
		//Priya: Modified for US-04688 - Project Share not deleted for old team members

		Set<Id> listCon = new Set<Id>();
		Set<Id> listprojectId = new Set<Id>();
		Set<String> sProjPTM2 = new Set<String>();
		Set<Id> listOfSalesforceUserId = new Set<Id>();
		for (ProjectTeamMember__c projectTeamMember : deletedTeamMembers) {
			if( projectTeamMember.contact__c != oldProjectsTMMap.get(projectTeamMember.Id).contact__c )
			{                
				listCon.add(oldProjectsTMMap.get(projectTeamMember.Id).contact__c);
				listprojectId.add( projectTeamMember.project__c );   
				sProjPTM2.add(oldProjectsTMMap.get(projectTeamMember.Id).TeamMemberUserId__c+'-'+oldProjectsTMMap.get(projectTeamMember.Id).project__c);

			}                
		}
		
		List<ProjectTeamMember__c> lPTM = new List<ProjectTeamMember__c>([Select Id, Project__c, Contact__c, TeamMemberUserId__c 
																			From ProjectTeamMember__c 
																			Where Project__c in :listprojectId 
																			AND  Contact__c in :listCon]);
		
		for(ProjectTeamMember__c ptm : lPTM){
			String mapValue = ptm.TeamMemberUserId__c +'-' + ptm.Project__c;
			if(sProjPTM2.contains(mapValue)){
				sProjPTM2.remove(mapValue);
			}
		}
		
		Set<Id> listprojectIds = new Set<Id>();

		for(String str : sProjPTM2){
			listprojectIds.add( Id.valueOf(str.substringAfter('-') ));
			listOfSalesforceUserId.add(Id.valueOf(str.substringBefore('-')));
		}

		List<pse__Proj__Share> listProjectShare2 = [ Select Id, ParentId, UserOrGroupId, RowCause 
														From pse__Proj__Share 
														Where RowCause = 'KeyMember__c' 
														AND UserOrGroupId In :listOfSalesforceUserId 
														and ParentId In :listprojectIds ];
		
		List <pse__Proj__Share> delProjectShare = new List<pse__Proj__Share>();

		for(pse__Proj__Share projShare : listProjectShare2){
			if(sProjPTM2.contains(String.valueOf(projShare.UserOrGroupId).substring(0, 15)  +'-' + String.valueOf(projShare.ParentId))){
				delProjectShare.add(projShare);
			}

		}
		
		if(delProjectShare.size() > 0){
			try{
				delete delProjectShare;
			}catch(Exception e){
				ECO_Service_ErrorLog.formatPageError(e, e.getMessage());
			}
		}
		
		
	}
	
	/**
	 * 
	 *
	 * @Author  NTT Data - ?, Deborah Orth
	 * @Date    2015
	 *
	 * @param   
	 * @return  
	 **/
	public static void CreateSharingForTeamMembers(List<ProjectTeamMember__c> updatedTeamMembers) {
		if ( ! run) { return; }            
		//system.debug( 'CreateSharingForTeamMembers called ' + updatedTeamMembers );

		set<id> projIDs  = new set<id>();

		for(ProjectTeamMember__c ptm: updatedTeamMembers){
			projIDs.add(ptm.project__c);
		}

	
		List<ProjectTeamMember__c> activeKM = [ select id, project__c, ProjectRole__r.Type__c, contact__c From ProjectTeamMember__c Where Project__c IN: projIDs and Active__c = true And ProjectRole__r.Type__c = 'Key Member' ];
	
		//system.debug( 'activeKM ' + activeKM );
	
		List<pse__Proj__Share> projectShare = new List<pse__Proj__Share>();
	
		Map<ID, ProjectRole__c> mapOfProjectRoles = new Map<ID, ProjectRole__c> ( [SELECT Active__c, Type__c, Id, Name FROM ProjectRole__c Where Active__c = true] );
	
		Set<Id> contactIds = new Set<Id>();
	
		Set<string> KeyMemberString = new Set<string>();
		//Set<Id> KeyMembers = new Set<Id> ();

		for( ProjectTeamMember__c stored_key_member : activeKM )
		{
			KeyMemberString.add(stored_key_member.project__c + '-' + stored_key_member.contact__c);
			//KeyMembers.add( stored_key_member.contact__c ) ;                               
		}
	
		for(ProjectTeamMember__c ptm : updatedTeamMembers){ 
			
			ProjectRole__c pr = mapOfProjectRoles.get( ptm.projectrole__c );
			
			if ( pr.Type__c == 'Key Member' ) 
			{                    
				contactIds.add( ptm.contact__c );   
				//KeyMembers.add( ptm.contact__c );
				KeyMemberString.add(ptm.project__c + '-' + ptm.contact__c);
				//system.debug( 'KM has been added ' + ptm.contact__c );
			}                
			
			if ( pr.Type__c == 'Team Member' ) 
			{     
				//system.debug( 'TM has been added ' + ptm.contact__c );
				contactIds.add(ptm.contact__c);     
			}                
		}
	
		Map<ID, Contact> mapOfContacts = new Map<ID, Contact>([SELECT Id, pse__Salesforce_User__c, pse__Salesforce_User__r.isactive FROM Contact where id in :contactIds]);

		for (ProjectTeamMember__c projectTeamMember : updatedTeamMembers) {
			
			Contact c = mapOfContacts.get(projectTeamMember.contact__c);

			if(c != null)
			{
				//system.debug( 'projectTeamMember.contact__c ' + c + ' SF User =>' + c.pse__Salesforce_User__c );                
				string access;
				
				if( ( c.pse__Salesforce_User__c != null ) && ( c.pse__Salesforce_User__r.IsActive == true ) )
				{     
					ProjectRole__c pr = mapOfProjectRoles.get( projectTeamMember.projectrole__c );
					
					access = 'Read';
					
					if ( pr.Type__c == 'Key Member' )
					{                    
						access = 'Edit';        
					}                
					
					if ( pr.Type__c == 'Team Member' )
					{                              
						//system.debug( 'Project Role Name ' + pr.Name + ' KeyMembers ' + KeyMembers + ' projectTeamMember.contact__c ' + projectTeamMember.contact__c );
						
						if( ( pr.Name == 'Project Management Administrator' ) || ( pr.Name == 'Task Manager' ) 
						   || ( pr.Name == 'Capture Manager' ) || ( pr.Name == 'Technical Lead' ) || ( pr.Name == 'TQR Participant' ) 
						   || ( pr.Name == 'Reviewer' ) || ( pr.Name == 'Lead Verifier' ) || ( pr.Name == 'Resilience Director' ) 
						   || ( pr.Name == 'Independent Reviewer' ) || ( pr.Name == 'Deliverable Originator' ) || (pr.Name == 'BIM Healthy Start Reviewer')
						   || ( pr.Name == 'Contract Manager') || ( pr.Name == 'Document Manager/Controller')
						   || ( pr.Name == 'Healthy Start Reviewer') || ( pr.Name == 'Legal Counsel') || (pr.Name == 'ORM Contact')
						   || ( pr.Name == 'Package Owner') || ( pr.Name == 'Procurement Lead') || ( pr.Name == 'Procurement Team Member')
						   || ( pr.Name == 'Safety Manager') || ( pr.Name == 'Contract Manager') || ( pr.Name == 'Risk Manager')
						   || ( pr.Name == 'FCAP Subcontract Administrator') || ( pr.Name == 'DOA Approver')
						  )
						{
							access = 'Edit';        
						} 
						
						
						//if( KeyMembers.contains(projectTeamMember.contact__c) )
						if( KeyMemberString.contains(projectTeamMember.project__c + '-' + projectTeamMember.contact__c) )
						{
							//system.debug( 'Found Team Member In KM ' + projectTeamMember.contact__c );
							access = 'Edit';                                  
						}                                
					}                          
					
					//system.debug( 'Inside projectTeamMember.contact__c ' + projectTeamMember.contact__c + ' ' +  projectTeamMember.project__c + ' ' + projectTeamMember.User__c );              
						//projectTeamMember.AccessLevel__c ;
					
					/*if( ( projectTeamMember.AccessLevel__c == '' ) || ( projectTeamMember.AccessLevel__c == null ) )
					{
						// If no access level defined at the user level default to Edit share. (Give User Read write access to Project).
						access = 'Edit';
					}*/ 
					
					pse__Proj__Share ps = new pse__Proj__Share();
					ps.AccessLevel = access;
					ps.ParentId = projectTeamMember.project__c;
					ps.UserOrGroupId =  c.pse__Salesforce_User__c;  
					ps.RowCause = Schema.pse__Proj__Share.RowCause.KeyMember__c;                    
					projectShare.add(ps);                   
				}      
			}
		}
	
		if (!projectShare.isEmpty())
		{                               
			upsert projectShare;
			
			//system.debug( 'projectShare => ' + projectShare );
		}                
	}
}