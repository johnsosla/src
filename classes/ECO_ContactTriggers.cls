public with sharing class ECO_ContactTriggers {
	public ECO_ContactTriggers() {
		
	}
    
	public static void checkInactive(list<contact> updatedContacts, map<id, contact> oldContacts){


		id alertRecordTypeId = ECO_Utils_Meta.getRecordTypeId(PortalMessage__c.sObjectType, ECO_Constants.PortalMessage_AlertRecordTypeDeveloperName);

		map<id, contact> lstDeactivedContacts = new map<id, contact>();
		map<id, contact> mapContacts = new map<id, contact>();
		list<PortalMessage__c>  alertsToInsert = new list<PortalMessage__c>();

		for(contact c: updatedContacts){
			if(c.pse__Is_Resource_Active__c == false && oldContacts.get(c.id).pse__Is_Resource_Active__c == true){
				lstDeactivedContacts.put(c.id, c);
			}
			mapContacts.put(c.id, c);
		}

		if(lstDeactivedContacts.size() >0){

			list<ProjectTeamMember__c> lstProjectTeamMember = [select id, Name__c, Contact__c, Project__c, Project__r.name, project__r.EcoSystemReferenceNumber__c, ProjectRole__c, ProjectRole__r.name from ProjectTeamMember__c 
																	where 	Contact__c IN: lstDeactivedContacts.keySet() and 
																			Active__c = true and
																			Project__r.pse__Stage__c <> 'Closed' and 
																			Project__r.pse__Stage__c <> 'Complete'];

			map<id, list<ProjectTeamMember__c>> lstContact2ProjectTeamMember = new map<id, list<ProjectTeamMember__c>>();
			map<id, list<ProjectTeamMember__c>> lstProject2ProjectTeamMember = new map<id, list<ProjectTeamMember__c>>();

			for(ProjectTeamMember__c ptm: lstProjectTeamMember){


				if(!lstContact2ProjectTeamMember.containskey(ptm.Contact__c)){
					lstContact2ProjectTeamMember.put(ptm.Contact__c, new list<ProjectTeamMember__c>());
				} 

				lstContact2ProjectTeamMember.get(ptm.Contact__c).add(ptm);

				if(!lstProject2ProjectTeamMember.containskey(ptm.Project__c)){
					lstProject2ProjectTeamMember.put(ptm.Project__c, new list<ProjectTeamMember__c>());
				} 

				lstProject2ProjectTeamMember.get(ptm.Project__c).add(ptm);
			}

			/*list<ProjectTeamMember__c> lstTargetProjectTeamMember = [select id, Contact__c, Project__c, Project__r.name, project__r.EcoSystemReferenceNumber__c, ProjectRole__r.name, Contact__r.User__c from ProjectTeamMember__c 
																		where 	Project__c IN: lstProject2ProjectTeamMember.keySet() and 
																				Active__c = true and
																				(ProjectRole__r.name = 'Project Approver' or ProjectRole__r.name = 'Project Manager')];*/

			list<ProjectTeamMember__c> lstTargetProjectTeamMember = [select id, Contact__c, Project__c, Project__r.name, project__r.EcoSystemReferenceNumber__c, ProjectRole__r.name, Contact__r.User__c from ProjectTeamMember__c 
																		where 	Project__c IN: lstProject2ProjectTeamMember.keySet() and 
																				Active__c = true and ProjectRole__r.type__c = 'Key Member'];


			map<id, ProjectTeamMember__c> project2Approver = new map<id, ProjectTeamMember__c>();
			map<id, ProjectTeamMember__c> project2ProjectManager = new map<id, ProjectTeamMember__c>();
			list<ProjectTeamMember__c> lstProjectTeamMemberToUpsert = new list<ProjectTeamMember__c>();

			for(ProjectTeamMember__c ptm: lstTargetProjectTeamMember){

				if(ptm.ProjectRole__r.name == 'Project Approver'){
					project2Approver.put(ptm.Project__c, ptm);
				} else if (ptm.ProjectRole__r.name == 'Project Manager'){
					project2ProjectManager.put(ptm.Project__c, ptm);
				}
			}

			for(ProjectTeamMember__c deactivated :lstProjectTeamMember){

				// handle specific logic if the role is a project manager
				if(deactivated.ProjectRole__r.name == 'Project Manager'){
					/*if(project2Approver.containskey(deactivated.Project__c)){
						alertsToInsert.add(createNewAlert(deactivated.Project__r, 
														project2Approver.get(deactivated.Project__c).Contact__r.User__c ,
														date.today(), 
														'The current ' + deactivated.ProjectRole__r.name + ' on the project ' + deactivated.Project__r.name + ' is no longer active in the system.  Please review and update your project with a new key member.', 
														alertRecordTypeId)); 
					}*/

					// enddate the teammember and create a new team member for the supervisor
					deactivated.EndDate__c = date.today().adddays(-1);
					deactivated.Is_Active__c = false;
					deactivated.NotifyChange__c = true;
					lstProjectTeamMemberToUpsert.add(deactivated);

					//create a new project teamember entry for the supervisor
					if(mapContacts.get(deactivated.contact__c).ReportsToid != null){

						ProjectTeamMember__c p = new ProjectTeamMember__c(Contact__c = mapContacts.get(deactivated.contact__c).ReportsToid, ProjectRole__c = deactivated.ProjectRole__c, Project__c = deactivated.Project__c, StartDate__c = date.today());

						lstProjectTeamMemberToUpsert.add(p);
						//system.debug(lstProjectTeamMemberToUpsert);

						if(project2Approver.containskey(deactivated.Project__c)){
							p.ProjectApproverforInactiveNotify__c = project2Approver.get(deactivated.Project__c).Contact__r.User__c;
							//alertsToInsert.add(createNewAlert(deactivated.Project__r, project2Approver.get(deactivated.Project__c).Contact__r.User__c ,date.today(), deactivated.Name__c + ' has been made inactive', alertRecordTypeId)); 
						}
					}


				} else {

					if(project2ProjectManager.containskey(deactivated.Project__c)){
						alertsToInsert.add(createNewAlert(deactivated.Project__r, 
														project2ProjectManager.get(deactivated.Project__c).Contact__r.User__c ,
														date.today(), 
														'The current ' + deactivated.ProjectRole__r.name + ' on the project ' + deactivated.Project__r.name + ' is no longer active in the system.  Please review and update your project with a new key member.', 
														alertRecordTypeId)); 

					}				

				}
			}

			if(alertsToInsert.size() > 0){

				insert alertsToInsert;
			}

			if(lstProjectTeamMemberToUpsert.size() > 0){
				upsert lstProjectTeamMemberToUpsert;
			}
		}

	}

	public static PortalMessage__c createNewAlert (pse__Proj__c proj, id userid, Date theDate, String theMessage, id msgrecordtypeid) {
		PortalMessage__c newPM = new PortalMessage__c();


		newPM.Project_Number__c = proj.EcoSystemReferenceNumber__c;
		newPM.User__c = userid;
		newPM.RecordTypeId = msgrecordtypeid;
		newPM.StartDate__c = theDate;
		newPM.EndDate__c = theDate.adddays(1);
		newPM.IsEscalationAlert__c = true;
		newPM.Subject__c = proj.name;
		newPM.LinkToRecord__c = URL.getSalesforceBaseUrl().toExternalForm()+'/'+proj.Id;
		newPM.LongDescriptionMaxLength__c = theMessage;
		newPM.IsEmailAlert__c = true;
		return newPM;
	}

}