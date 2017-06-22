/** ------------------------------------------------------------------------------------------------------
* @Description Grant and Restrict Access to Users for different objects based on their roles on the Project
*
* @Author      NTT Data - Priya Parepalli
* @Date        April 2016
*-----------------------------------------------------------------------------------------------------*/
public class ECO_Service_RecordAccess {


    public static boolean PCCCreate = false;
    public static boolean ignoreRestOfSecurity = false;
    public static boolean classificationFieldChanged = false;
    public static boolean isDataUserChecked = false;
    public static Boolean hasDataMaintenanceAccess = false;
    public static set<string> CheckedSObjects = new set<string>();
    
    /**
     * Checks whether user has access to record based on their Project Role 
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    April 2016
     *
     * @param 	Id - currentProjectId
     * @param	String - objectName
     * @return  Boolean - true of false based on the entries in Security Matrix
     **/
    public static Boolean getRecordAccess (Id currentProjectId, String objectName) {

        List<ProjectTeamMember__c> listPTM = [ SELECT Id, Name, User__c, Active__c, projectRole__r.Name FROM ProjectTeamMember__c where Project__c = :currentProjectId and contact__r.pse__Salesforce_User__c = :userinfo.getuserId() ] ;
        
        system.debug( 'listPTM ' + listPTM + ' currentProjectId ' + currentProjectId + ' userinfo.getuserId() ' + userinfo.getuserId() );
        
    	if (listPTM.IsEmpty()) {
        	return false;
        }
        
        Set<String> projectRoles = new Set<String>();
        for(ProjectTeamMember__c teamMember:listPTM) {
            projectRoles.add(teamMember.projectRole__r.Name);
        }
        //String roleName = listPTM[0].projectRole__r.Name;
        
       // system.debug( 'Role matched ' + roleName );
        
        List<ECO_SecurityObjectAccess__c> sac = [ select Id, RoleName__c from ECO_SecurityObjectAccess__c Where ObjectName__c = :objectName and RoleName__c in :projectRoles and ReadWriteAccess__c = true ];
        
    	if (sac.IsEmpty()) {
        	return false;
        }
		else {
        	return true;
        }
    }

    /**
     * Checks whether user has access to VF Page
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    09/26/2016
     *
     * @param   currentProjectId 
     * @return  
     **/
    public static Boolean getPageAccess (Id currentProjectId){

        List<ProjectTeamMember__c> listPTM = new List<ProjectTeamMember__c>();
        List<ECO_SecurityRestrictPageAccess__c> lSRPA = new List<ECO_SecurityRestrictPageAccess__c>();
        Boolean restrictAccess = false;

        listPTM = [ SELECT Id, Name, User__c, Active__c, projectRole__r.Name FROM ProjectTeamMember__c where Project__c = :currentProjectId and contact__r.pse__Salesforce_User__c = :userinfo.getuserId() ] ;
        
        Set <String> roleNames = new Set<String>();
        Set <String> restrictedRoles = new Set<String>();
        String sAccessString = '';
        Integer numberOfRoles = 0;
        if(listPTM != null && listPTM.size()>0){
            for(ProjectTeamMember__c ptm : listPTM){
                roleNames.add(ptm.ProjectRole__r.Name);
            }
            numberOfRoles = roleNames.size();
            User u = [Select Id, ECO_OUID__c From User Where Id = :userinfo.getuserId()];
            String sOUID = u.ECO_OUID__c;

            lSRPA = [Select Id, RestrictedRole__c, RestrictedOU__c, RestrictAccess__c FROM ECO_SecurityRestrictPageAccess__c Where RestrictedRole__c IN :roleNames];
            if(lSRPA != null && lSRPA.size() > 0){
                //Throw new ECO_SecurityAccessException('You do not have permissions to view financials for this project');
                if(sOUID == null || sOUID == ''){
                    sOUID = 'All';
                }
                for(ECO_SecurityRestrictPageAccess__c srpa : lSRPA){
                    for(String role : roleNames){
                        if(srpa.RestrictedRole__c == role && (srpa.RestrictedOU__c == sOUID || (srpa.RestrictedOU__c == 'All' && srpa.RestrictAccess__c == true))){
                            sAccessString += srpa.RestrictAccess__c + ';';
                            roleNames.remove(role);
                            restrictedRoles.add(role);
                            
                        }
                    }
                }
                if(!sAccessString.contains('false') && numberOfRoles != 0 && numberOfRoles ==  restrictedRoles.size()){
                    restrictAccess = true;
                }
            }

        }
        
        return restrictAccess;
       
    }
    
    public static Boolean bAllowEditAccess {
        get{
            List<ECO_AllowEditAccessInactivePTM__c> listEditAccess = [Select Id, Name, Allow_Edit_Access_for_Inactive__c From ECO_AllowEditAccessInactivePTM__c Where Name = 'Allow Edit For Inactive'];
            if(listEditAccess.size()>0)
                return listEditAccess[0].Allow_Edit_Access_for_Inactive__c;
            else
                return true;
        }
        set;
    }

    /**
     * Checks whether user has access to submit the record for approval
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    April 2016
     *
     * @param 	String - nameOfObject
     * @param 	Id - projectId
     * @return  Boolean - True or False
     **/
    public static Boolean getProjectRecordAccessForApprovalProcess (String nameOfObject, Id projectId ) {
        
        List<SObject> listObjects;
		string uName = UserInfo.getUserName();
        Id id1 = UserInfo.getProfileId();
        Id userId = UserInfo.getUserId();
        for( ECO_SecurityObjectAccessUserExclusions__c soae : listSOAExcl )
        {            
            if( soae.User_Name__c == uName )
            {
				system.debug( ' returning ' );                
                return true;            
            }                
        }
        
        System.debug('******************Profile ID' +id1);
		List<Profile> listProfile = [Select Name from Profile where Id = :id1 Limit 1]; 
            
		if( listProfile.isEmpty() )
            return false;
            
		system.debug( 'UName ' + uName ); 
        
        if( listProfile[0].Name == 'System Administrator')
        {
            //if( uName != 'bobby.hoque@aecom.com.ecosysdev' )
            	return true;          
        }


        system.debug('Running User Id Id: ' + userId);
            
		List <ID> projectIDs = new List <ID> ();
        Map<ID, ID> mapTQTIdToProject = new Map<ID, ID> ();
        Map<ID, ID> mapDevIdToProject = new Map<ID, ID> ();
        Map<ID, ID> mapTQTRIdToProject = new Map<ID, ID> ();
        
        String TriggerObjectName;
        
        TriggerObjectName = nameOfObject;			
        
        projectIDs.add( projectId );
        
        system.debug( 'TriggerObjectName ' + TriggerObjectName );
   		
        Map<Id, String> mapProjectIDUserRole = new Map<Id, String>();
        
        Map<String, ECO_SecurityObjectAccess__c> mapSObA = new Map<String, ECO_SecurityObjectAccess__c>();
        List <String> lRoles = new List<String>();
        List<ProjectTeamMember__c> listPTM = new List<ProjectTeamMember__c> ();
        if(bAllowEditAccess){
            listPTM = [ SELECT Id, Name, User__c, Project__c, Active__c, ProjectRole__r.Type__c, projectRole__r.Name 
                                                FROM ProjectTeamMember__c 
                                                where Project__c IN :projectIDs 
                                                and contact__r.pse__Salesforce_User__c = :userinfo.getuserId() ] ;
                                                
        }
        else{
            listPTM = [ SELECT Id, Name, User__c, Project__c, Active__c, ProjectRole__r.Type__c, projectRole__r.Name 
                                                FROM ProjectTeamMember__c 
                                                where Project__c IN :projectIDs 
                                                and contact__r.pse__Salesforce_User__c = :userinfo.getuserId()
                                                and Active__c = true] ;
        }

        system.debug( ' listPTM size ' + listPTM.size() + ' ' + listPTM );

        for( ProjectTeamMember__c ptm : listPTM )
        {            
            mapProjectIDUserRole.put( ptm.Project__c, ptm.projectRole__r.Name );
            system.debug( 'listPTM ==>' + ptm.Name + ' Project ' + ptm.Project__c + '  Role: '+ptm.projectRole__r.Name);
            lRoles.add(ptm.projectRole__r.Name);          
        }
        
        List<ECO_SecurityObjectAccess__c> listSOA = [ select Id, ObjectName__c, RoleName__c, ReadWriteAccess__c, SubmitApprovalProcess__c 
                                                        from ECO_SecurityObjectAccess__c 
                                                        Where ObjectName__c = :TriggerObjectName ];
        
        for( ECO_SecurityObjectAccess__c soa : listSOA )
        {
            //mapSOA.put( soa.RoleName__c, soa.ReadWriteAccess__c );
            mapSObA.put( soa.RoleName__c, soa );
            
        }	
        
        system.debug( 'TriggerObjectName ' + TriggerObjectName );

        String roleName;
        
        if( mapProjectIDUserRole.ContainsKey( projectId) )
        	roleName = mapProjectIDUserRole.get(projectId); 
        else
            return false;
        
        system.debug( 'roleName 131 ' + roleName );
        String hasAccess = '';
        
        //ECO_SecurityObjectAccess__c soa = mapSObA.get( roleName );
        List<ECO_SecurityObjectAccess__c> lSOA = [Select Id, ObjectName__c, RoleName__c, ReadWriteAccess__c, SubmitApprovalProcess__c 
                                                    from ECO_SecurityObjectAccess__c 
                                                    Where  ObjectName__c = :TriggerObjectName 
                                                    AND RoleName__c IN :lRoles];
        System.debug('lSOA:::'+lSOA);
        
        //For implementing most permissive role wins scenario
        for(ECO_SecurityObjectAccess__c oSOA : lSOA){
            if(oSOA.SubmitApprovalProcess__c){
                hasAccess = hasAccess +'true';
            }
            else{
                hasAccess = hasAccess + 'false';
            }
        }
        System.debug('hasAccess:::'+hasAccess);
        if(!String.isBlank(hasAccess)){
            if(hasAccess.contains('true'))
                return true;
            else
                return false;
        }
        else
            return false;
            
        /*if( soa != null )
        {            
        	return soa.SubmitApprovalProcess__c;
        }
        else
        	return false; */             
    }     
    
    public static List<ECO_SecurityObjectAccessUserExclusions__c> listSOAExcl {
        get {
            if (listSOAExcl == null) {
                listSOAExcl = [ select Id, User_Name__c from ECO_SecurityObjectAccessUserExclusions__c ];
            } 

            return listSOAExcl;
        }

        set;
    }
    
    public static List<Profile> listProfile {
        get {
            if (listProfile == null) {
                Id id1 = UserInfo.getProfileId();
                System.debug('******************Profile ID' +id1);
               listProfile = [Select Name from Profile where Id = :id1 Limit 1]; 
            } 

            return listProfile;
        }

        set;
    }
    
    /**
     * Checks if there is a change to the Sobject that is on the Sobject's exlusion list.
     * if a change is found, the Sobject is exempt from further record access checks
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    April 2016
     *
     * @param 	List<SObject> - triggernew
     * @param 	map<id, Sobject> - oldMap
     * @return  list<sobject> - list of checkable objects
     **/
    public static list<sobject> getListofCheckableObjects (List<SObject> triggernew, map<id, Sobject> oldMap) {

        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 

        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(triggernew[0].getSObjectType().getDescribe().getName());
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get('AccessExclusionList');

        System.debug('DescribeSObjectResultObj:::'+DescribeSObjectResultObj.getName());

        //US-05111: Exclusion of Classification fields on Project for Data Maintenance Users
        if(DescribeSObjectResultObj.getName() == 'pse__Proj__c'){
        	System.debug('Inside classification field check');
        	Schema.FieldSet classificationFieldSet = DescribeSObjectResultObj.FieldSets.getMap().get('ECO_OracleClassificationFields');
        	if(classificationFieldSet != null){
	        	for(sobject s:triggernew){

		            for(Schema.FieldSetMember fieldSetMemberObj : classificationFieldSet.getFields()){	
		                if(s.get(fieldSetMemberObj.getFieldPath()) != oldmap.get((id)s.get('id')).get(fieldSetMemberObj.getFieldPath())){
		                    system.debug('Classification Change Found');
		                    classificationFieldChanged = true;
		                    break;
		                }
		            }

		            /*if(!classificationFieldChanged){
		                lstOfCheckableObjects.add(s);
		            }*/

	        	}
	        }
        }
        System.debug('classificationFieldChanged:::'+classificationFieldChanged);
        //the exclusion list for this object has not been found
        IF(fieldSetObj==null){
            return triggernew;
        } 

        list<sobject> lstOfCheckableObjects = new list<sobject>();

        for(sobject s:triggernew){

            boolean foundChange = false;

            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetObj.getFields()){	
                system.debug('API Name ====>' + fieldSetMemberObj.getFieldPath()); //api name
                system.debug('Label ====>' + fieldSetMemberObj.getLabel());
                system.debug('Required ====>' + fieldSetMemberObj.getRequired());
                system.debug('DbRequired ====>' + fieldSetMemberObj.getDbRequired());
                system.debug('Type ====>' + fieldSetMemberObj.getType());   //type - STRING,PICKLIST

                if(s.get(fieldSetMemberObj.getFieldPath()) != oldmap.get((id)s.get('id')).get(fieldSetMemberObj.getFieldPath())){
                    system.debug('Change Found');
                    foundChange = true;
                }
            }

            if(!foundChange){
                lstOfCheckableObjects.add(s);
            }

        }

        system.debug(lstOfCheckableObjects);
        return lstOfCheckableObjects;
    }

    public static Map<String, List<ECO_SecurityObjectAccess__c>> mapListSOAbyTriggerObjectName = new Map<String, List<ECO_SecurityObjectAccess__c>>();

    /**
     * Gets all the entries in Security Matrix for an object 
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    April 2016
     *
     * @param 	String - triggerObjectName
     * @return  List<ECO_SecurityObjectAccess__c>
     **/
    public static List<ECO_SecurityObjectAccess__c> getListSOA(String triggerObjectName) {
         List<ECO_SecurityObjectAccess__c> listSOA = mapListSOAbyTriggerObjectName.get(triggerObjectName);

        if(listSOA == null) {
            listSOA = [ select Id, ObjectName__c, RoleName__c, ReadWriteAccess__c from ECO_SecurityObjectAccess__c Where ObjectName__c = :triggerObjectName ];
            mapListSOAbyTriggerObjectName.put(triggerObjectName, listSOA);
        } 
        
        return listSOA;
    }

    

    /**
     * Checks if logged in user has valid Security Matrix entries or other permissions
 	 * to access the record
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    April 2016
     *
     * @param 	List<SObject> - listObjects
     * @return  
     **/
    public static void getProjectRecordAccess (List<SObject> listObjects) {
            

        if(listObjects.size() == 0 || ignoreRestOfSecurity){ 
            return;
        }

        if(listObjects.size() > 0){
            string SObjectName = listObjects[0].getSObjectType().getDescribe().getName();

            if(!(CheckedSObjects.add(SObjectName))){
                system.debug('getProjectRecordAccess** Already checked access for ' + SObjectName);
                return;
            } else {
                system.debug('getProjectRecordAccess** First time checking access for ' + SObjectName);
            }

        } 

        string uName = UserInfo.getUserName();
        Id userId = UserInfo.getUserId();
        
        system.debug( 'uName ' + uName );

        System.debug('hasDataMaintenanceAccess:::'+hasDataMaintenanceAccess);
        System.debug('classificationFieldChanged in getProjectRecordAccess:::'+classificationFieldChanged);
        
        /*
        List<ECO_SecurityObjectAccessUserExclusions__c> listSecurityUserExclusion = [ select Id, User_Name__c from ECO_SecurityObjectAccessUserExclusions__c ];
		system.debug( 'listSecurityUserExclusion ' + listSecurityUserExclusion );
        */
        
        // If the user is from the list of excuded users (integration and so forth) just return
        for( ECO_SecurityObjectAccessUserExclusions__c soae : listSOAExcl )
        {            
            if( soae.User_Name__c == uName )
            {
				system.debug( ' returning ' );                
                return;            
            }                
        }
            
		if( listProfile.isEmpty() )
            return;
            
		
        if( listProfile[0].Name == 'System Administrator')
        {
            //if( uName != 'bobby.hoque@aecom.com.ecosysdev' )
            	return;          
        }

            
		List <ID> projectIDs = new List <ID> ();
        Map<ID, ID> mapTQTIdToProject = new Map<ID, ID> ();
        
        String TriggerObjectName = listObjects[0].getSObjectType().getDescribe().getName();
        String TriggerLabel = listObjects[0].getSObjectType().getDescribe().getLabelPlural();

        //US-05111 Skip validation for Data Maintenance Users
        if(!isDataUserChecked){
	        List<PermissionSet> ps = new List<PermissionSet>();
	        List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
	        List<ECO_DataMaintenanceUserExclusion__c> lDataMaintenance = new List<ECO_DataMaintenanceUserExclusion__c>();	 
	        //Boolean isAddedInCustomSetting = false; 

	        //String uName = UserInfo.getUserName();
	        lDataMaintenance = [SELECT Id, User_Name__c FROM ECO_DataMaintenanceUserExclusion__c WHERE User_Name__c =:uName];

	        System.debug('lDataMaintenance::::'+lDataMaintenance);
	        ps = [SELECT Id, Label, Name FROM PermissionSet WHERE Name = 'Eco_EPM_Data_Maintenance' ];
	        if(ps!= null){
	            
	            psa = [SELECT Id, PermissionSetId, PermissionSet.Label FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() AND PermissionSetId =:ps[0].Id ];
	            
	        }
	        if(psa.size() > 0 && lDataMaintenance.size() > 0){
	        	hasDataMaintenanceAccess = true;
	        }else{
	        	hasDataMaintenanceAccess = false;
	        }
	        isDataUserChecked = true;
	    }

        //if( TriggerObjectName == 'pse__Proj__c' && hasDataMaintenanceAccess && classificationFieldChanged){
        /*if( TriggerObjectName == 'pse__Proj__c' && hasDataMaintenanceAccess){
        	System.debug('inside skip data maintenance user validation for classification fields');
        	return;
        }*/
        if(( TriggerObjectName == 'ProjectTeamMember__c' || TriggerObjectName == 'ProjectOrganization__c' 
            || TriggerObjectName == 'pse__Project_Task__c' || TriggerObjectName == 'pse__Proj__c'
           ) && hasDataMaintenanceAccess){
        	System.debug('inside skip data maintenance user validation for PTM and Project Org');
        	return;
        }
        
        if( TriggerObjectName == 'pse__Proj__c' )
        {            
            for (SObject nextProject : listObjects) {
        		projectIDs.add(nextProject.ID);
            }                
    	}
   		else	
   		if(( TriggerObjectName == 'QuestionnaireSet__c' ) || (  TriggerObjectName == 'BudgetSetupQuestionnaire__c' ) || ( TriggerObjectName == 'Risk__c' ) 
               	|| ( TriggerObjectName == 'ProjectActivities__c' ) ||  ( TriggerObjectName == 'BudgetHeader__c') 
              	|| ( TriggerObjectName == 'Induction__c' ) || ( TriggerObjectName == 'Deliverable__c' ) || ( TriggerObjectName == 'ProjectCity__c' ) 
           		|| ( TriggerObjectName == 'Funding__c' )  || ( TriggerObjectName == 'ProjectReview__c' )  || ( TriggerObjectName == 'ChangeManager__c' ) 
               	|| ( TriggerObjectName == 'POHeader__c' ) || ( TriggerObjectName == 'ProjectTeamMember__c' ) || ( TriggerObjectName == 'Project_Site__c' ) 
          		|| ( TriggerObjectName == 'Stakeholder__c' ) || ( TriggerObjectName == 'CommunicationPlan__c' ) || ( TriggerObjectName == 'DOARegister__c' )  
                || ( TriggerObjectName == 'DOAApprovalRequest__c' ) || ( TriggerObjectName == 'DOAConditions__c' ) || ( TriggerObjectName == 'VendorSub__c' ) 
                || (TriggerObjectName == 'VendorSite__c' ) || (TriggerObjectName == 'SurveySchedule__c' ) || (TriggerObjectName == 'EarnedValueHeader__c' ) 
           		|| (TriggerObjectName == 'Assumption__c' ) || (TriggerObjectName == 'ProjectOrganization__c'))
        {
            for (SObject nextProject : listObjects) {
        		projectIDs.add(String.valueof(nextProject.get('Project__c')));
                
            }    

            system.debug( 'projectIDs QuestionnaireSet__c ' + projectIDs );           
    	}        
   		else	
        if( TriggerObjectName == 'Packages__c' )
        {
            for (SObject nextProject : listObjects) {
        		projectIDs.add(String.valueof(nextProject.get('Scope__c')));
            }    

			system.debug( 'projectIDs Packages__c ' + projectIDs );           
    	}  
   		else	
        if( TriggerObjectName == 'pse__Project_Task__c' )
        {
            for (SObject nextProject : listObjects) {
        		projectIDs.add(String.valueof(nextProject.get('pse__Project__c')));
            }    

			system.debug( 'projectIDs Packages__c ' + projectIDs );           
    	}  
        else if( TriggerObjectName == 'Agreement__c'){
            List<Agreement__c> listAgreement = [Select Id, RecordTypeId From Agreement__c Where ID IN :listObjects];
            for (SObject nextProject : listObjects) {
                String RecordTypeName = [Select Id, DeveloperName From RecordType Where Id = :String.valueof(nextProject.get('RecordTypeId'))].DeveloperName;
                //String RecordTypeName = Schema.SObjectType.Agreement__c.getRecordTypeInfosById().get(String.valueof(nextProject.get('RecordTypeId'))).getname();
               	//mapTQTIdToProject.put(String.valueof(nextProject.get('id')), String.valueof(nextProject.get('Project__c')));
               	if(RecordTypeName == 'PrimeMSA')
                    return;
                else
                	projectIDs.add(String.valueof(nextProject.get('Project__c')));
            }
        }
   		else	
        if( ( TriggerObjectName == 'TechnicalQualityTeam__c' )  )
        {
            List<TechnicalQualityTeam__c> listTQT  = [ SELECT id, deliverable__r.project__c FROM TechnicalQualityTeam__c WHERE ID IN :listObjects ];
            
            system.debug( '106 listTQT ' + listTQT + ' projectIDs ' + projectIDs +'  listObjects  '+listObjects );
            for (SObject nextProject : listObjects) {
                System.debug('Projid__c:::'+String.valueof(nextProject.get('Projid__c')));
        		mapTQTIdToProject.put(String.valueof(nextProject.get('id')), String.valueof(nextProject.get('Projid__c')));
                projectIDs.add(String.valueof(nextProject.get('Projid__c')));
            }
            /*for (TechnicalQualityTeam__c nextTQT : listTQT) {
        		mapTQTIdToProject.put(nextTQT.id, nextTQT.deliverable__r.project__c);
                projectIDs.add(nextTQT.deliverable__r.project__c);
            } */
            
    	}  
        else    
        if(( TriggerObjectName == 'TechnicalQualityReview__c' ) )
        {
            List<TechnicalQualityReview__c> listTQTR  = [ SELECT id, deliverable__r.project__c FROM TechnicalQualityReview__c WHERE ID IN :listObjects ];
            
            System.debug('inside TechnicalQualityReview__c:::');
            for (TechnicalQualityReview__c nextTQTR : listTQTR) {
                mapTQTIdToProject.put(nextTQTR.id, nextTQTR.deliverable__r.project__c);
                projectIDs.add(nextTQTR.deliverable__r.project__c);
            } 
            //System.debug('projectIDs:::'+projectIDs+'     mapTQTIdToProject::'+mapTQTIdToProject);
        }  
        else    
        if( ( TriggerObjectName == 'DeliverableRevision__c' ) )
        {
            List<DeliverableRevision__c> listDev  = [ SELECT id, deliverable__r.project__c FROM DeliverableRevision__c WHERE ID IN :listObjects ];
            
            for (DeliverableRevision__c nextDev : listDev) {
                mapTQTIdToProject.put(nextDev.id, nextDev.deliverable__r.project__c);
                projectIDs.add(nextDev.deliverable__r.project__c);
            } 
        }  
        else
        if( TriggerObjectName == 'MarketAssessment__c' ){
            try{
                List<MarketAssessment__c> listMA = [ SELECT id, QuestionnaireSet__r.Project__c From MarketAssessment__c Where ID IN :listObjects];
                for(MarketAssessment__c nextMA : listMA){
                    mapTQTIdToProject.put(nextMA.id, nextMA.QuestionnaireSet__r.Project__c);
                    projectIDs.add(nextMA.QuestionnaireSet__r.Project__c);
                }
            }catch(Exception e){
                ECO_Service_ErrorLog.formatPageError(e, '' + e.getMessage());
                
            }
        }
        else if (TriggerObjectName == 'Form__c' ){
            List<Form__c> listForm = [ SELECT id, DOAApprovalRequest__r.Project__c From Form__c Where ID IN :listObjects];
            for(Form__c nextForm : listForm){
                mapTQTIdToProject.put(nextForm.id, nextForm.DOAApprovalRequest__r.Project__c);
                projectIDs.add(nextForm.DOAApprovalRequest__r.Project__c);
            }
        }
        else if (TriggerObjectName == 'ReviewMember__c'){
            List<ReviewMember__c> listRM = [ SELECT id, TechnicalQualityReview__r.Deliverable__r.Project__c From ReviewMember__c Where ID IN :listObjects];
            for(ReviewMember__c nextRM : listRM){
                mapTQTIdToProject.put(nextRM.id, nextRM.TechnicalQualityReview__r.Deliverable__r.Project__c);
                projectIDs.add(nextRM.TechnicalQualityReview__r.Deliverable__r.Project__c);
            }
        }
        else if (TriggerObjectName == 'DOAApprover__c'){
            List<DOAApprover__c> listApprovers = [ SELECT id, DOAApprovalRequest__r.Project__c From DOAApprover__c Where ID IN :listObjects];
            for(DOAApprover__c nextApprover : listApprovers){
                mapTQTIdToProject.put(nextApprover.id, nextApprover.DOAApprovalRequest__r.Project__c);
                projectIDs.add(nextApprover.DOAApprovalRequest__r.Project__c);
            }
        }

        
        Map<Id, String> mapProjectIDUserRole = new Map<Id, String>();
        
        Map<String, Boolean> mapSOA = new Map<String, Boolean>();
        
        Map<String, ECO_SecurityObjectAccess__c> mapSObA = new Map<String, ECO_SecurityObjectAccess__c>();

        List<ProjectTeamMember__c> listPTM = new List<ProjectTeamMember__c> ();
        
        System.debug('bAllowEditAccess:::'+bAllowEditAccess);
        if(bAllowEditAccess){
            listPTM = [ SELECT Id, Name, User__c, Project__c, Active__c, ProjectRole__r.Type__c, projectRole__r.Name 
                                                    FROM ProjectTeamMember__c 
                                                    where Project__c IN :projectIDs 
                                                    and contact__r.pse__Salesforce_User__c = :userinfo.getuserId() ] ;
                                                    
        }else{
            listPTM = [ SELECT Id, Name, User__c, Project__c, Active__c, ProjectRole__r.Type__c, projectRole__r.Name 
                                                    FROM ProjectTeamMember__c 
                                                    where Project__c IN :projectIDs 
                                                    and contact__r.pse__Salesforce_User__c = :userinfo.getuserId() 
                                                    and Active__c = true] ;
        }


        system.debug( ' listPTM size ' + listPTM.size() );

        for( ProjectTeamMember__c ptm : listPTM )
        {
            
            /*if( ptm.projectRole__r.Type__c == 'Team member' ) //Commented: Priya -  US-03842
            {
            	// user is a Team member not a key member, so do the default role processing  
            	System.debug( 'Team member processing' )  ;
                
                mapProjectIDUserRole.put( ptm.Project__c, 'Default' );
            }      
            else
            {  */              
                mapProjectIDUserRole.put( ptm.Project__c, ptm.projectRole__r.Name );
                system.debug( 'listPTM ==>' + ptm.Name + ' Project ' + ptm.Project__c + ' Project Role ' + ptm.projectRole__r.Name);
            //}                
        }
        
        system.debug( ' mapProjectIDUserRole ' + mapProjectIDUserRole );

        // OMAR Edit:
        // List<ECO_SecurityObjectAccess__c> listSOA = [ select Id, ObjectName__c, RoleName__c, ReadWriteAccess__c from ECO_SecurityObjectAccess__c Where ObjectName__c = :TriggerObjectName ];
        List<ECO_SecurityObjectAccess__c> listSOA = getListSOA(TriggerObjectName);

        for( ECO_SecurityObjectAccess__c soa : listSOA )
        {
            mapSOA.put( soa.RoleName__c, soa.ReadWriteAccess__c );
            mapSObA.put( soa.RoleName__c, soa );
        }	
        
        system.debug( 'TriggerObjectName ' + TriggerObjectName + ' mapSOA 305 ' + mapSOA );

        String roleName;
        
        Boolean FirstTimeProjectCreation = false;
        //Boolean hasAccess = true;
        String sAccessString = '';
        string error_desc = '';
        SObject errorObject;

        for( ProjectTeamMember__c ptm : listPTM )
            {    
                for( SObject proj : listObjects )            
                {
                    Boolean hasAccess = true;
                    
                    if( TriggerObjectName == 'pse__Proj__c' )
                    {
                        //roleName = mapProjectIDUserRole.get( proj.Id );  
                        roleName =  ptm.projectRole__r.Name;
                        
                        if(ECO_Service_RecordAccess.PCCCreate == true){
                            FirstTimeProjectCreation = true;
                        }
                        
                    }
                    else    
                    if(( TriggerObjectName == 'QuestionnaireSet__c' ) || (  TriggerObjectName == 'BudgetSetupQuestionnaire__c' ) || ( TriggerObjectName == 'Risk__c' ) 
                        || ( TriggerObjectName == 'ProjectActivities__c' ) || ( TriggerObjectName == 'Agreement__c') ||  ( TriggerObjectName == 'BudgetHeader__c') 
                        || ( TriggerObjectName == 'Induction__c' ) || ( TriggerObjectName == 'Deliverable__c' ) || ( TriggerObjectName == 'ProjectCity__c' ) 
                        || ( TriggerObjectName == 'Funding__c' )  || ( TriggerObjectName == 'ProjectReview__c' )  || ( TriggerObjectName == 'ChangeManager__c' ) 
                        || ( TriggerObjectName == 'POHeader__c' ) || ( TriggerObjectName == 'ProjectTeamMember__c' ) || ( TriggerObjectName == 'Project_Site__c' ) 
                        || ( TriggerObjectName == 'Stakeholder__c' ) || ( TriggerObjectName == 'CommunicationPlan__c' ) || ( TriggerObjectName == 'DOARegister__c' )  
                        || ( TriggerObjectName == 'DOAApprovalRequest__c' ) || ( TriggerObjectName == 'DOAConditions__c' ) || ( TriggerObjectName == 'VendorSub__c' ) 
                        || (TriggerObjectName == 'VendorSite__c' ) || (TriggerObjectName == 'SurveySchedule__c' ) || (TriggerObjectName == 'EarnedValueHeader__c' ) 
                        || (TriggerObjectName == 'Assumption__c' ) || (TriggerObjectName == 'ProjectOrganization__c'))
                    {
                        //roleName = mapProjectIDUserRole.get(String.valueof(proj.get('Project__c')) ); 
                        roleName =  ptm.projectRole__r.Name;
                        system.debug( 'TriggerObjectName projectIDs 353 ' + projectIDs + ' => ' + TriggerObjectName );
        
                        
                    }             
                    else    
                    if( TriggerObjectName == 'Packages__c' )
                    {
                        //roleName = mapProjectIDUserRole.get(String.valueof(proj.get('Scope__c')) );               
                        roleName =  ptm.projectRole__r.Name;
                        system.debug( 'projectIDs Packages__c ' + projectIDs );           
                    }
                    else    
                    if( TriggerObjectName == 'pse__Project_Task__c' )
                    {
                        //roleName = mapProjectIDUserRole.get(String.valueof(proj.get('pse__Project__c')) );               
                        roleName =  ptm.projectRole__r.Name;
                        system.debug( 'projectIDs pse__Project_Task__c ' + projectIDs );           
                    }
                    else    
                    if( ( TriggerObjectName == 'TechnicalQualityTeam__c' ) || ( TriggerObjectName == 'TechnicalQualityReview__c' ) 
                        || ( TriggerObjectName == 'DeliverableRevision__c' ) || (  TriggerObjectName == 'MarketAssessment__c') 
                        || (  TriggerObjectName == 'Form__c') || (  TriggerObjectName == 'ReviewMember__c') || (TriggerObjectName == 'DOAApprover__c')){
                        
                            Id ProjectId = mapTQTIdToProject.get(proj.id);
                            //roleName = mapProjectIDUserRole.get(ProjectId);
                            roleName =  ptm.projectRole__r.Name;
                            System.debug('mapTQTIdToProject.get(proj.id):::'+mapTQTIdToProject.get(proj.id)+'  roleName:::'+roleName);
                    }             
                    
                    system.debug( 'roleName for project ' + roleName + ' ' + proj.Id  );
                    
                    
                    // Role blank means no PTM record found for the project and the user
                    /*if( ( String.isblank(roleName) ) || ( roleName == null ) )
                    {
                        if(( Test.isRunningTest() ) || ECO_Service_RecordAccess.PCCCreate == true || ((TriggerObjectName == 'pse__Proj__c') && proj.get('ownerid') == userId) )
                            return;
                        sAccessString = sAccessString + 'false';
                        hasAccess = false;  
                        error_desc = 'Project Team Member record not found for the user (' + uName + ' | ' + userId + ') while editing object ' + TriggerObjectName;
                        errorObject = proj;
                        System.debug('Inside if sAccessString::'+sAccessString);
                    }                
                    else*/
                    if ( mapSOA.containsKey(roleName) )
                    {
                        sAccessString = sAccessString + mapSOA.get( roleName );
                        hasAccess = mapSOA.get( roleName );
                        System.debug('mapSOA.get( roleName ):::'+mapSOA.get( roleName )+'::: roleName::'+roleName);
                        if( ! hasAccess ){
                            error_desc = 'Adding or Changing '+TriggerLabel+ ' is not permitted for the '+roleName+' role.'; //Priya
                            
                        }   
                        errorObject = proj;
                        System.debug('Inside else if sAccessString::'+sAccessString);
                        system.debug( 'roleName for project ' + roleName + ' hasAccess ' + hasAccess + ' ' + proj.Id  );
                    } 
                    else
                    {
                        //Priya
                        // User is a PTM for project but NO custom settings found for the Object and role, by default give the user access
                        sAccessString = sAccessString + 'false';
                        hasAccess = false;
                        error_desc = 'Adding or Changing '+TriggerLabel+' is not permitted for the '+roleName+' role.';
                        errorObject = proj;
                        System.debug('Inside else   sAccessString::'+sAccessString);
                    }                
                    
                    //if( ! hasAccess ){                
                        //proj.addError( addErrorMessage );
                        //proj.addError( error_desc );
                    //}                
                }  
            }
        if(listPTM.size() == 0){
            if(( Test.isRunningTest() ) || ECO_Service_RecordAccess.PCCCreate == true || ((TriggerObjectName == 'pse__Proj__c') && listObjects[0].get('ownerid') == userId) )
                return;
            sAccessString = 'false';
            error_desc = 'Active Project Team Member record not found for the user (' + uName + ' | ' + userId + ') while editing object ' + TriggerObjectName;
            errorObject = listObjects[0];
            
        }
        
        System.debug('sAccessString:::final:::'+sAccessString);
        System.debug('errorObject:::'+errorObject);
        if( (String.isBlank(sAccessString) || (!String.isBlank(sAccessString) && !sAccessString.contains('true'))) && errorObject != null){
            errorObject.addError( error_desc );
        }
        
    }   



}