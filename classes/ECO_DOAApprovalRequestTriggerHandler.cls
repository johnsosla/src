public without sharing class ECO_DOAApprovalRequestTriggerHandler {

    private static void handleDOAApprovalStampingHelper(string approverCount, string approvedCount, DOAApprovalRequest__c DOAR, Schema.FieldSet fs){

        integer iApproverCount = 0;
        integer iApprovedCount = 0;

        for (Schema.FieldSetMember fsmField: fs.getFields()) {

            string checkbox = fsmField.getFieldPath();
            string fieldLabel = fsmField.getLabel();
            //System.debug('BEFORE*****checkbox:   '+DOAR.get(checkbox));
            string approver = checkbox.replace('CheckApp__c', 'Approver__c');
            string approvedby = checkbox.replace('CheckApp__c', 'ApprovedBy__c');
            string approvedbyDate = checkbox.replace('CheckApp__c', 'TimeApp__c');
            
            //if(DOAR.get(checkbox) == true && DOAR.get(approver) == null){
            if(DOAR.get(checkbox) != null && DOAR.get(approver) == null){
                DOAR.adderror('Trying to set ' + fieldLabel + ' without a specified approver');
                return;
            }

            //if(DOAR.get(checkbox) == true && DOAR.get(approvedby) == null){
            if((DOAR.get(checkbox) == 'Approved' || DOAR.get(checkbox) == 'Rejected' || DOAR.get(checkbox) == 'Conditionally Approved') && DOAR.get(approvedby) == null){
                DOAR.put(approvedby, UserInfo.getName());
                DOAR.put(approvedbyDate, datetime.now());
            }
            if(DOAR.get(checkbox) == 'Approved' || DOAR.get(checkbox) == 'Conditionally Approved' || DOAR.get(checkbox) == 'Rejected'){
                iApprovedCount++;
            }
            
            /*if(DOAR.get(checkbox) != null || DOAR.get(checkbox) !=''){
                iApprovedCount++;
            }*/
    
            if(!(DOAR.get(approver) == null || DOAR.get(approver) == '')){
                System.debug('DOAR.get(approver):    '+DOAR.get(approver));
                iApproverCount++;
            }


        }
        System.debug('iApproverCount:    '+iApproverCount);
        DOAR.put(approverCount, iApproverCount);
        DOAR.put(approvedCount, iApprovedCount);        
        
    }

    public static void handleDOAApprovalStamping(list<DOAApprovalRequest__c> approvalRequests){

        for(DOAApprovalRequest__c DOAR: approvalRequests){

            handleDOAApprovalStampingHelper('AECOMHubCountofApprovers__c', 'AECOMHubCountofApproved__c', DOAR, SObjectType.DOAApprovalRequest__c.FieldSets.EcoAECOMHubDoAapprovalCheck);
            handleDOAApprovalStampingHelper('DCSHubCountofApprovers__c', 'DCSHubCountOfApproved__c', DOAR, SObjectType.DOAApprovalRequest__c.FieldSets.EcoDCSHubDoAapprovalCheck);
            handleDOAApprovalStampingHelper('EnterpriseCountofApprovers__c', 'EnterpriseCountofApproved__c', DOAR, SObjectType.DOAApprovalRequest__c.FieldSets.EcoEnterpriseDoAapprovalCheck);
            handleDOAApprovalStampingHelper('GeoCountOfApprovers__c', 'GeoCountofApproved__c', DOAR, SObjectType.DOAApprovalRequest__c.FieldSets.EcoGeoDoAapprovalCheck);
            handleDOAApprovalStampingHelper('GroupCountofApprovers__c', 'GroupCountofApproved__c', DOAR, SObjectType.DOAApprovalRequest__c.FieldSets.EcoGroupDoAApprovalCheck);
        }
    }



    public static void handleDOAApprovalRequestChange(list<DOAApprovalRequest__c> approvalRequests)
    {
        System.debug('Inside handleDOAApprovalRequestChange');
        list<Id> projectIds = new list<Id>();
        for(DOAApprovalRequest__c approvalRequest:approvalRequests)
        {
            if(approvalRequest.Project__c != null)  
                projectIds.add(approvalRequest.Project__c);
        }
                        
        set<Id> projectsWithUnapprovedRequests = new set<Id>();
        for(DOAApprovalRequest__c request:[select Id, Project__c from DOAApprovalRequest__c 
                                           where Project__c in :projectIds 
                                           and ApprovalStatus__c != 'Approved'])
        {
            projectsWithUnapprovedRequests.add(request.Project__c); 
        }
        
        list<pse__Proj__c> updatedProjects = new list<pse__Proj__c>();
        for(pse__Proj__c project:[select Id, Name, DOAUnapprovedRequestsExist__c from pse__Proj__c where Id in :projectIds])
        {
            if(projectsWithUnapprovedRequests.contains(project.Id) && project.DOAUnapprovedRequestsExist__c == false)
            {
                project.DOAUnapprovedRequestsExist__c = true;
                updatedProjects.add(project);           
            }
            else if(!projectsWithUnapprovedRequests.contains(project.Id) && project.DOAUnapprovedRequestsExist__c == true)
            {
                project.DOAUnapprovedRequestsExist__c = false;
                updatedProjects.add(project);               
            }
        }
        
        if(updatedProjects.size() > 0)
            update updatedProjects;

        System.debug('end of handleDOAApprovalRequestChange');
    }
    
    public static void createORMContact(list<DOAApprovalRequest__c> approvalRequests, Map<Id, DOAApprovalRequest__c> oldDOAMap, Map<Id, DOAApprovalRequest__c> newDOAMap, Boolean isInsert, Boolean isUpdate){
        System.debug('Inside createORMContact ');
        
        Set<Id> projectIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        Set<Id> oldOwnerIds = new Set<Id>();
        Set<String> sPTMcombi = new Set<String>();
        
        Map<Id,DOAApprovalRequest__c> mDOAToInsert = new Map<Id,DOAApprovalRequest__c>();
        Map<Id,DOAApprovalRequest__c> mDOAToUpdates = new Map<Id,DOAApprovalRequest__c>();
        Map<Id,Id> mUserContact = new Map<Id,Id>();

        List<ProjectTeamMember__c> listPTMToInsert = new List<ProjectTeamMember__c>();
        List<ProjectTeamMember__c> listPTMToUpdate = new List<ProjectTeamMember__c>();
        List<ProjectTeamMember__c> listPTMToDelete = new List<ProjectTeamMember__c>();

        for(DOAApprovalRequest__c approvalRequest:approvalRequests){
            String ownerId = String.valueOf(approvalRequest.OwnerId);
            if( approvalRequest.Project__c!= null && ((isUpdate && oldDOAMap.get(approvalRequest.Id).OwnerId != approvalRequest.OwnerId) || isInsert)){//PP &&  ownerId.startsWith('005') ){//  approvalRequest.owner.type == 'User'){
                projectIds.add(approvalRequest.Project__c);
                userIds.add(approvalRequest.OwnerId);
                if(isUpdate && oldDOAMap.get(approvalRequest.Id).OwnerId != approvalRequest.OwnerId){ //PPP && String.valueOf(oldDOAMap.get(approvalRequest.Id).OwnerId).startsWith('005') ){
                    mDOAToUpdates.put(oldDOAMap.get(approvalRequest.Id).Id, oldDOAMap.get(approvalRequest.Id));
                    oldOwnerIds.add(oldDOAMap.get(approvalRequest.Id).OwnerId);
                    userIds.add(oldDOAMap.get(approvalRequest.Id).OwnerId);
                    
                }
                else{
                    mDOAToInsert.put(approvalRequest.Id, approvalRequest);
                }

            }
        }

        
        if(mDOAToInsert != null || mDOAToUpdates != null ){
            ProjectRole__c[] pRole = [select id, Name from ProjectRole__c where Name = 'ORM Contact'];

            List <ProjectTeamMember__c> lPTM = new List <ProjectTeamMember__c>([Select Id, Project__c, ProjectRole__c, Contact__r.pse__Salesforce_User__c 
                                                                                From ProjectTeamMember__c 
                                                                                Where Project__c in :projectIds
                                                                                AND ProjectRole__c = :pRole[0].Id]);

            if(lPTM.size()>0){
                for(ProjectTeamMember__c ptm : lPTM){
                    sPTMcombi.add(ptm.Project__c+'-'+ptm.Contact__r.pse__Salesforce_User__c);
                }
            }

            for(Contact con : [Select Id, pse__Salesforce_User__c From Contact Where pse__Salesforce_User__c in :userIds]){
                mUserContact.put(con.pse__Salesforce_User__c, con.Id);
            }

            List<DOAApprovalRequest__c> lDOA = new List<DOAApprovalRequest__c>();
            if(oldOwnerIds != null)
                lDOA = [Select Id, Project__c, OwnerId From DOAApprovalRequest__c Where Project__c in :projectIds AND OwnerId IN :oldOwnerIds];

            for(DOAApprovalRequest__c doa : mDOAToUpdates.values()){
                Id oldOwnerContact = mUserContact.get(doa.OwnerId);
                Id newOwnerContact = mUserContact.get(newDOAMap.get(doa.Id).OwnerId);

                Integer count = 0;
                if(lDOA.size() == 0){
                    for(ProjectTeamMember__c ptm : lPTM){
                        if(doa.Project__c == ptm.Project__c && oldOwnerContact == ptm.Contact__c){
                            if(String.valueOf(doa.OwnerId).startsWith('005') && !String.valueOf(newDOAMap.get(doa.Id).OwnerId).startsWith('005')){
                                listPTMToDelete.add(ptm);
                            }
                            else{
                                if(newOwnerContact != null){
                                    ptm.Contact__c = newOwnerContact;
                                    listPTMToUpdate.add(ptm);
                                    count++;
                                }
                            }
                        }
                    }
                }
                if(count == 0 && newOwnerContact != null && (sPTMcombi == null || (sPTMcombi!= null && !sPTMcombi.contains(String.valueOf(doa.Project__c)+'-'+String.valueOf(newDOAMap.get(doa.Id).OwnerId))))){
                    listPTMToInsert.add(new ProjectTeamMember__c(Contact__c = newOwnerContact, ProjectRole__c = pRole[0].Id, Project__c = doa.Project__c));
                }
            }
            
            if(mDOAToInsert != null || lDOA.size()>0){
                for(DOAApprovalRequest__c doa : mDOAToInsert.Values()){
                    Id contactId = mUserContact.get(doa.OwnerId);
                    if( contactId != null && (sPTMcombi == null || (sPTMcombi!= null && !sPTMcombi.contains(String.valueOf(doa.Project__c)+'-'+String.valueOf(doa.OwnerId))))){
                        listPTMToInsert.add(new ProjectTeamMember__c(Contact__c = contactId, ProjectRole__c = pRole[0].Id, Project__c = doa.Project__c));
                    }

                }

                if(listPTMToInsert.size() > 0 ){
                    try{
                        //ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
                        insert listPTMToInsert;
                    }
                    catch(Exception e){
                        ECO_Service_ErrorLog.logException(e);
                    }
                }
            }
            if(listPTMToUpdate.size() > 0 ){
                try{
                    update listPTMToUpdate;
                }
                catch(Exception e){
                    ECO_Service_ErrorLog.formatPageError(e, 'An Error has occurred while attempting to insert Project Team Member: ');
                }
            }
            if(listPTMToDelete.size() > 0){
                try{
                    delete listPTMToDelete;
                }
                catch(Exception e){
                    ECO_Service_ErrorLog.formatPageError(e, 'An Error has occurred while attempting to insert Project Team Member: ');
                }
            }

            

        }
    }

    public static void createDOAApprovers(list<DOAApprovalRequest__c> approvalRequests, Map<Id, DOAApprovalRequest__c> oldDOAMap, Boolean isInsert, Boolean isUpdate){
        System.debug('Inside createDOAApprovers ');

        Set<Id> projectIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        //Set<Id> sOldUserIds = new Set<Id>();
        Set<String> sPTMcombi = new Set<String>();
        Set<String> sProjectUser = new Set<String>();
        Set<String> sProjectOldNewUser = new Set<String>();
        //Set<String> sProjectOldUser = new Set<String>();

        Map<Id,Id> mUserContact = new Map<Id,Id>();
        Map<Id,DOAApprovalRequest__c> mDOAToInsert = new Map<Id,DOAApprovalRequest__c>();
        Map<Id,DOAApprovalRequest__c> mDOAToUpdate = new Map<Id,DOAApprovalRequest__c>();
        //Map<Id,Id> mToUpdateProjectUser = new Map<Id,Id>();
        //Map<Id,Id> mToInsertProjectUser = new Map<Id,Id>();
        
        List<ProjectTeamMember__c> listPTMToInsert = new List<ProjectTeamMember__c>();
        List<ProjectTeamMember__c> listPTMToUpdate = new List<ProjectTeamMember__c>();
        List<ProjectTeamMember__c> listPTMtoDelete = new List<ProjectTeamMember__c>();
        
        for(DOAApprovalRequest__c doa : approvalRequests){
            for(Schema.FieldSetMember fld : Schema.SObjectType.DOAApprovalRequest__c.fieldSets.EcoDOAApprovers.getFields()){
                if(doa.get(fld.getFieldPath()) != oldDOAMap.get(doa.Id).get(fld.getFieldPath())){
                    //sProjectOldUser.add(doa.Project__c + '-' + (String)oldDOAMap.get(doa.Id).get(fld.getFieldPath()));
                    userIds.add((Id)doa.get(fld.getFieldPath()));
                    if(oldDOAMap.get(doa.Id).get(fld.getFieldPath()) != null)
                        userIds.add((Id)oldDOAMap.get(doa.Id).get(fld.getFieldPath()));
                    projectIds.add(doa.Project__c);
                    if(oldDOAMap.get(doa.Id).get(fld.getFieldPath()) == null){
                        mDOAToInsert.put(doa.Id, doa);
                        //mToInsertProjectUser.put(doa.project__c, (Id)doa.get(fld.getFieldPath()));
                        sProjectUser.add(doa.Project__c + '-' + (String)doa.get(fld.getFieldPath()));
                    }
                    else{
                        mDOAToUpdate.put(doa.Id, doa);
                        //mToUpdateProjectUser.put(doa.project__c, (Id)doa.get(fld.getFieldPath()));
                        sProjectOldNewUser.add(doa.project__c+'-'+(String)oldDOAMap.get(doa.Id).get(fld.getFieldPath())+'-'+(String)doa.get(fld.getFieldPath()));
                    }
                }
            }

        }

        if(mDOAToInsert != null || mDOAToUpdate!= null){
            ProjectRole__c[] pRole = [select id, Name from ProjectRole__c where Name = 'DOA Approver'];

            List <ProjectTeamMember__c> lPTM = new List<ProjectTeamMember__c>([Select Id, Project__c, ProjectRole__c, Contact__r.pse__Salesforce_User__c, Contact__c 
                                                                                From ProjectTeamMember__c
                                                                                Where Project__c in :projectIds
                                                                                AND ProjectRole__c = :pRole[0].Id]);

            Map<Id, ProjectTeamMember__c> mPTM = new Map<Id, ProjectTeamMember__c>();
            if(lPTM.size()>0){
                for(ProjectTeamMember__c ptm : lPTM){
                    sPTMcombi.add(ptm.Project__c+'-'+ptm.Contact__r.pse__Salesforce_User__c);
                    mPTM.put(ptm.Id, ptm);
                }
            }

            for(Contact con : [Select Id, pse__Salesforce_User__c From Contact Where pse__Salesforce_User__c in :userIds]){
                mUserContact.put(con.pse__Salesforce_User__c, con.Id);
            }

            //TODO List <DOAApprovalRequest__c>() = new List<DOAApprovalRequest__c>([Select Id from DOAApprovalRequest__c Where Project IN :projectIds]);
            //run for loop on this list and inner for loop on for(Schema.FieldSetMember fld : Schema.SObjectType.DOAApprovalRequest__c.fieldSets.EcoDOAApprovers.getFields()){ 
            //and see if (doa.project == sProjectOldUser.substringbefore('-') && sProjectOldUser.substringafter('-') == (String)doa.get(fld.getFieldPath())
            
            String queryString = 'Select Id, Project__c';
            for(Schema.FieldSetMember fld : Schema.SObjectType.DOAApprovalRequest__c.fieldSets.EcoDOAApprovers.getFields()){
                queryString += ', ' + fld.getFieldPath();
            }

            queryString += ' From DOAApprovalRequest__c Where Project__c IN :projectIds ';

            List<DOAApprovalRequest__c> lDOA = new List<DOAApprovalRequest__c>();
            lDOA = Database.query(queryString);

            Set <String> sAllDOAProjectUser = new Set<String>();

            for(DOAApprovalRequest__c doa : lDOA){
                for(Schema.FieldSetMember fld : Schema.SObjectType.DOAApprovalRequest__c.fieldSets.EcoDOAApprovers.getFields()){
                    sAllDOAProjectUser.add(doa.Project__c+'-'+(String)doa.get(fld.getFieldPath()));
                }
            }

            Set<String> sDeletePTM = new Set<String>();
            for(String str : sProjectOldNewUser){
                String[] sProjectOldU = str.split('-');
                Id contactId = mUserContact.get((Id)sProjectOldU[2]);
                Boolean isUpdateRemoved = false;
                if((sAllDOAProjectUser.contains(sProjectOldU[0]+'-'+sProjectOldU[1]) && sPTMcombi!= null && sPTMcombi.contains(sProjectOldU[0]+'-'+sProjectOldU[1]))){
                    sProjectOldNewUser.remove(str);
                    isUpdateRemoved = true;
                }
                if(sPTMcombi!= null && !sPTMcombi.contains(sProjectOldU[0]+'-'+sProjectOldU[2]) && contactId!= null && isUpdateRemoved){
                    listPTMToInsert.add(new ProjectTeamMember__c(Contact__c = contactId, ProjectRole__c = pRole[0].Id, Project__c = (Id)sProjectOldU[0]));
                }
                
            }

            //For updating existing DOA Manager record
            for(ProjectTeamMember__c ptm: mPTM.Values()){
                for(String str : sProjectOldNewUser){
                    String[] sStrSplit = str.split('-');
                    Id oldContactId = mUserContact.get((Id)sStrSplit[1]);
                    Id newContactId = mUserContact.get((Id)sStrSplit[2]);
                    if(ptm.Project__c == (Id)sStrSplit[0] && ptm.Contact__c == oldContactId && newContactId != null ){
                        if(sPTMcombi.contains(ptm.Project__c+'-'+sStrSplit[2]) ){
                            listPTMtoDelete.add(ptm);
                        }
                        else{
                            ptm.Contact__c = newContactId;
                            listPTMToUpdate.add(ptm);
                        }
                        
                    }
                }
            }

            for(String str : sProjectUser){
                if(sPTMcombi == null || (sPTMcombi!= null && !sPTMcombi.contains(str))){
                    Id contactId = mUserContact.get((Id)str.substringAfter('-'));
                    if(contactId!= null){
                        listPTMToInsert.add(new ProjectTeamMember__c(Contact__c = contactId, ProjectRole__c = pRole[0].Id, Project__c = (Id)str.substringBefore('-')));
                    }
                }

            }

            if(listPTMToInsert.size()>0){
                try{
                    insert listPTMToInsert;
                }
                catch(Exception e){
                    ECO_Service_ErrorLog.formatPageError(e, e.getMessage());
                }
            }

            if(listPTMToUpdate.size()>0){
                try{
                    update listPTMToUpdate;
                }
                catch(Exception e){
                    ECO_Service_ErrorLog.formatPageError(e, e.getMessage());
                }
            }
            
            if(listPTMtoDelete.size()>0){
                try{
                    delete listPTMtoDelete;
                }
                catch(Exception e){
                    ECO_Service_ErrorLog.formatPageError(e, e.getMessage());
                }
            }
        }

    }

    public static void sendCancelEmailNotification(list<DOAApprovalRequest__c> approvalRequests){
        Boolean sendEmail = false;
        List<String> lToEmail = new List<String>();
        Map<String, Schema.SObjectField> objfieldMap = DOAApprovalRequest__c.sObjectType.getDescribe().fields.getMap();
        String strfieldName = '';
        
        for(Schema.SObjectField Field : objfieldMap.Values()){
             Schema.DescribeFieldResult fieldResult = Field.getDescribe();
             strfieldName += fieldResult.getName() + ',';
        }
        strfieldName = strfieldName + 'GeoPresidentApprover__r.Email, GeoChiefOperatingOfficerApprover__r.Email, RegBLExecutiveApprover__r.Email, AreaManagerApprover__r.Email, BusinessUnitLeaderApprover__r.Email, ProjectManagerApprover__r.Email, GeographyChiefCounselApprover__r.Email, RegionChiefCounselApprover__r.Email, CounselContractsManagerApprover__r.Email, AreaCounselApprover__r.Email, FinanceGeographyControlApprover__r.Email, FedContractsandProcurementApprover__r.Email, GeoOtherApprover__r.Email, DCSgeoRiskCommitteeApprover__r.Email, HRDirectorGeographyDirApprover__r.Email, GroupChiefExecutiveApprover__r.Email, GroupChiefCounselApprover__r.Email, GroupChiefFinancialOfficerApprover__r.Email, GroupOtherApprover__r.Email, EnterpriseRiskCommitteeApprover__r.Email, EnterpriseOtherApprover__r.Email, GeneralCounselApprover__r.Email, PresidentCFOApprover__r.Email, CEOApprover__r.Email, DCSHubAdministratorApprover__r.Email, AECOMHubAdministratorApprover__r.Email'; 
        
        List<DOAApprovalRequest__c> lDOA = Database.query('Select ' + strfieldName + ' From DOAApprovalRequest__c Where Id IN :approvalRequests');
        
        for(DOAApprovalRequest__c doa:lDOA){
            if(doa.GeographyApprovalRAG__c == 'Pending' || doa.AECOMHubApprovalRAG__c == 'Pending' || doa.DCSApprovalStatusRAG__c == 'Pending' || doa.EnterpriseApprovalRag__c == 'Pending' || doa.GroupApprovalRag__c == 'Pending'){
                sendEmail = true;
            }
            if(doa.GeographyApprovalRAG__c == 'Pending'){
                if((doa.GeoPresidentApprover__c != null || doa.GeoPresidentApprover__c != '') && String.isBlank(doa.GeoPresidentCheckApp__c) && String.isNotBlank(doa.GeoPresidentApprover__r.Email) ){
                    lToEmail.add(doa.GeoPresidentApprover__r.Email);
                }
                if((doa.GeoChiefOperatingOfficerApprover__c != null || doa.GeoChiefOperatingOfficerApprover__c != '') && String.isBlank(doa.GeoChiefOperatingOfficerCheckApp__c) && String.isNotBlank(doa.GeoChiefOperatingOfficerApprover__r.Email)){
                    lToEmail.add(doa.GeoChiefOperatingOfficerApprover__r.Email);
                }
                if((doa.RegBLExecutiveApprover__c != null || doa.RegBLExecutiveApprover__c != '') && String.isBlank(doa.RegBLExecutiveCheckApp__c) && String.isNotBlank(doa.RegBLExecutiveApprover__r.Email)){
                    lToEmail.add(doa.RegBLExecutiveApprover__r.Email);
                }
                if((doa.AreaManagerApprover__c != null || doa.AreaManagerApprover__c != '') && String.isBlank(doa.AreaManagerCheckApp__c) && String.isNotBlank(doa.AreaManagerApprover__r.Email)){
                    lToEmail.add(doa.AreaManagerApprover__r.Email);
                }
                if((doa.BusinessUnitLeaderApprover__c != null || doa.BusinessUnitLeaderApprover__c != '') && String.isBlank(doa.BusinessUnitLeaderCheckApp__c)  && String.isNotBlank(doa.BusinessUnitLeaderApprover__r.Email)){
                    lToEmail.add(doa.BusinessUnitLeaderApprover__r.Email);
                }
                if((doa.ProjectManagerApprover__c != null || doa.ProjectManagerApprover__c != '') && String.isBlank(doa.ProjectManagerCheckApp__c) && String.isNotBlank(doa.ProjectManagerApprover__r.Email)){
                    lToEmail.add(doa.ProjectManagerApprover__r.Email);
                }
                if((doa.GeographyChiefCounselApprover__c != null || doa.GeographyChiefCounselApprover__c != '') && String.isBlank(doa.GeographyChiefCounselCheckApp__c) && String.isNotBlank(doa.GeographyChiefCounselApprover__r.Email)){
                    lToEmail.add(doa.GeographyChiefCounselApprover__r.Email);
                }
                if((doa.RegionChiefCounselApprover__c != null || doa.RegionChiefCounselApprover__c != '') && String.isBlank(doa.RegionChiefCounselCheckApp__c)  && String.isNotBlank(doa.RegionChiefCounselApprover__r.Email)){
                    lToEmail.add(doa.RegionChiefCounselApprover__r.Email);
                }
                if((doa.CounselContractsManagerApprover__c != null || doa.CounselContractsManagerApprover__c != '') && String.isBlank(doa.CounselContractsManagerCheckApp__c) && String.isNotBlank(doa.CounselContractsManagerApprover__r.Email)){
                    lToEmail.add(doa.CounselContractsManagerApprover__r.Email);
                }
                if((doa.AreaCounselApprover__c != null || doa.AreaCounselApprover__c != '') && String.isBlank(doa.AreaCounselCheckApp__c) && String.isNotBlank(doa.AreaCounselApprover__r.Email)){
                    lToEmail.add(doa.AreaCounselApprover__r.Email);
                }
                if((doa.FinanceGeographyControlApprover__c != null || doa.FinanceGeographyControlApprover__c != '') && String.isBlank(doa.FinanceGeographyControlCheckApp__c) && String.isNotBlank(doa.FinanceGeographyControlApprover__r.Email)){
                    lToEmail.add(doa.FinanceGeographyControlApprover__r.Email);
                }
                if((doa.FedContractsandProcurementApprover__c != null || doa.FedContractsandProcurementApprover__c != '') && String.isBlank(doa.FedContractsandProcurementCheckApp__c) && String.isNotBlank(doa.FedContractsandProcurementApprover__r.Email)){
                    lToEmail.add(doa.FedContractsandProcurementApprover__r.Email);
                }
                if((doa.GeoOtherApprover__c != null || doa.GeoOtherApprover__c != '') && String.isBlank(doa.GeoOtherCheckApp__c) && String.isNotBlank(doa.GeoOtherApprover__r.Email)){
                    lToEmail.add(doa.GeoOtherApprover__r.Email);
                }
                if((doa.DCSgeoRiskCommitteeApprover__c != null || doa.DCSgeoRiskCommitteeApprover__c != '') && String.isBlank(doa.DCSgeoRiskCommitteeCheckApp__c) && String.isNotBlank(doa.DCSgeoRiskCommitteeApprover__r.Email)){
                    lToEmail.add(doa.DCSgeoRiskCommitteeApprover__r.Email);
                }
                if((doa.HRDirectorGeographyDirApprover__c != null || doa.HRDirectorGeographyDirApprover__c != '') && String.isBlank(doa.HRDirectorGeographyDirCheckApp__c) && String.isNotBlank(doa.HRDirectorGeographyDirApprover__r.Email)){
                    lToEmail.add(doa.HRDirectorGeographyDirApprover__r.Email);
                }
                
            }
            if(doa.GroupApprovalRag__c == 'Pending'){
                if((doa.GroupChiefExecutiveApprover__c != null || doa.GroupChiefExecutiveApprover__c != '') && String.isBlank(doa.GroupChiefExecutiveCheckApp__c) && String.isNotBlank(doa.GroupChiefExecutiveApprover__r.Email)){
                    lToEmail.add(doa.GroupChiefExecutiveApprover__r.Email);
                }
                if((doa.GroupChiefCounselApprover__c != null || doa.GroupChiefCounselApprover__c != '') && String.isBlank(doa.GroupChiefCounselCheckApp__c) && String.isNotBlank(doa.GroupChiefCounselApprover__r.Email)){
                    lToEmail.add(doa.GroupChiefCounselApprover__r.Email);
                }
                if((doa.GroupChiefFinancialOfficerApprover__c != null || doa.GroupChiefFinancialOfficerApprover__c != '') && String.isBlank(doa.GroupChiefFinancialOfficerCheckApp__c) && String.isNotBlank(doa.GroupChiefFinancialOfficerApprover__r.Email)){
                    lToEmail.add(doa.GroupChiefFinancialOfficerApprover__r.Email);
                }
                if((doa.GroupOtherApprover__c != null || doa.GroupOtherApprover__c != '') && String.isBlank(doa.GroupOtherCheckApp__c) && String.isNotBlank(doa.GroupOtherApprover__r.Email)){
                    lToEmail.add(doa.GroupOtherApprover__r.Email);
                }
            }
            if(doa.EnterpriseApprovalRag__c == 'Pending'){
                if((doa.EnterpriseRiskCommitteeApprover__c != null || doa.EnterpriseRiskCommitteeApprover__c != '') && String.isBlank(doa.EnterpriseRiskCommitteeCheckApp__c) && String.isNotBlank(doa.EnterpriseRiskCommitteeApprover__r.Email)){
                    lToEmail.add(doa.EnterpriseRiskCommitteeApprover__r.Email);
                }
                if((doa.EnterpriseOtherApprover__c != null || doa.EnterpriseOtherApprover__c != '') && String.isBlank(doa.EnterpriseOtherCheckApp__c) && String.isNotBlank(doa.EnterpriseOtherApprover__r.Email)){
                    lToEmail.add(doa.EnterpriseOtherApprover__r.Email);
                }
                if((doa.GeneralCounselApprover__c != null || doa.GeneralCounselApprover__c != '') && String.isBlank(doa.GeneralCounselCheckApp__c)  && String.isNotBlank(doa.GeneralCounselApprover__r.Email)){
                    lToEmail.add(doa.GeneralCounselApprover__r.Email);
                }
                if((doa.PresidentCFOApprover__c != null || doa.PresidentCFOApprover__c != '') && String.isBlank(doa.PresidentCFOCheckApp__c) && String.isNotBlank(doa.PresidentCFOApprover__r.Email)){
                    lToEmail.add(doa.PresidentCFOApprover__r.Email);
                } 
                if((doa.CEOApprover__c != null || doa.CEOApprover__c != '') && String.isBlank(doa.CEOCheckApp__c) && String.isNotBlank(doa.CEOApprover__r.Email)){
                    lToEmail.add(doa.CEOApprover__r.Email);
                }
            }
            if(doa.DCSApprovalStatusRAG__c == 'Pending' && (doa.DCSHubAdministratorApprover__c != null || doa.DCSHubAdministratorApprover__c != '') && String.isBlank(doa.DCSHubAdministratorCheckApp__c) && String.isNotBlank(doa.DCSHubAdministratorApprover__r.Email)){
                lToEmail.add(doa.DCSHubAdministratorApprover__r.Email);
            }
            if(doa.AECOMHubApprovalRAG__c == 'Pending' && (doa.AECOMHubAdministratorApprover__c != null || doa.AECOMHubAdministratorApprover__c != '') && String.isBlank(doa.AECOMHubAdministratorCheckApp__c) && String.isNotBlank(doa.AECOMHubAdministratorApprover__r.Email)){
                lToEmail.add(doa.AECOMHubAdministratorApprover__r.Email);
            }
        }
        
        DOAApprovalRequest__c doa = lDOA[0];
        Id ContactId =  [Select Id From Contact Where User__c <> null LIMIT 1].Id;
        try{
            List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            if(doa.Project__c != null)
                msg.setTemplateId( [select id from EmailTemplate where DeveloperName= 'EcoDOAApprovalRequestCancelledEcosystem'].id );
            else
                msg.setTemplateId( [select id from EmailTemplate where DeveloperName= 'EcoDOAApprovalRequestCancelledNonEcosystem'].id );
            msg.setWhatId(doa.Id);
            msg.setTargetObjectId(ContactId);
            msg.setToAddresses(lToEmail);
            msg.setSaveAsActivity(false);
            
            lstMsgs.add(msg);
            
            Savepoint sp = Database.setSavepoint();
            try{Messaging.sendEmail(lstMsgs);}catch(EmailException e){}
            
            Database.rollback(sp);
            
            List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
            for (Messaging.SingleEmailMessage email : lstMsgs) {
                Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                emailToSend.setToAddresses(email.getToAddresses());
                emailToSend.setPlainTextBody(email.getPlainTextBody());
                emailToSend.setHTMLBody(email.getHTMLBody());
                emailToSend.setSubject(email.getSubject());
                lstMsgsToSend.add(emailToSend);
            }
            Messaging.sendEmail(lstMsgsToSend);
        }
        catch (EmailException e) {}
        
    }

}