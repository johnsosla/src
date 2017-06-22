public without sharing virtual class ECO_ProjectReviewsController {
    protected pse__Proj__c theProject { get; set; }
    public ApexPages.StandardController oStandardController {get; set;}
    public ProjectReview__c oProjectReview {get; set;}
    public List<ECO_Utils_Activities.Attendee> lAttendees {get; set;}
    public List<EventRelation> lInvitees {get; set;}
    public List<AgendaItem__c> lAgendaItems {get; set;}
    public List<AgendaItem__c> lDelete_AgendaItems {get; set;}
    public List<Event> lEvents {get; set;}
    public List<SelectOption> lRTOptions {get; set;}
    public String recordObjectType {get; set;}
    public String recordObjectId {get; set;}
    public Boolean showScheduleButton {get; set;}
    public Boolean showKPIs {get; set;}
    public Boolean perfActiveStatus {get; set;}
    public Boolean isPerfReview {get; set;}
    public Boolean isProjectPerfReview {get; set;}
    public Boolean showOtherSections {get; set;}
    public Map<Id,RecordType> mRecordTypes {get; set;}
    public List<KPI_Result__c> lKPI_Results {get; set;}
    public List<DOAConditions__c> lstDOAConditions {get; set;}
    public List<Task> reviewTasks {get; set;}
    public ProjectReview__c lastProjectReview {get; set;}

    public String tabState {get;set;}

    public ECO_ProjectReviewsController(ApexPages.StandardController oStandardController) 
    {
        this.oStandardController = oStandardController;
        List<String> lFields = new List<String>();
        lFields.add('Project__c');
        lFields.add('EventID__c');
        lFields.add('ProjectReviewTemplate__c');
        if(!test.isRunningTest()) { // Else will fail UnitTest
            oStandardController.addFields(lFields);
        }
        lstDOAConditions = new List<DOAConditions__c>();
        isProjectPerfReview = false;
        oProjectReview = (ProjectReview__c)oStandardController.getRecord();

        if (ECO_Utils_String.NullCheck(oProjectReview.Project__c) == '')
        {
            oProjectReview.Project__c = ApexPages.currentPage().getParameters().get('ProjectId');
            System.debug('___ProjectId Param: oProjectReview='+oProjectReview);
        }

        if (ECO_Utils_String.NullCheck(oProjectReview.RecordTypeId) == '')
        {
            oProjectReview.RecordTypeId = ApexPages.currentPage().getParameters().get('RecordTypeId');
        }
        
        if (ECO_Utils_String.NullCheck(oProjectReview.Project__c) == '')
        {
            ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR,
                'You have reached this page improperly, please access it FROM the Project screen.');
            ApexPages.addMessage(oPageMessage);
            return;
        }

        mRecordTypes = new Map<Id,RecordType>([SELECT Id, Name, DeveloperName FROM RecordType 
                                                WHERE Id = :oProjectReview.RecordTypeId]);
        
        if (ECO_Utils_String.NullCheck(oProjectReview.ProjectReviewTemplate__c) == '')
        {
            List<ProjectReviewTemplate__c> lPRT = new List<ProjectReviewTemplate__c>([SELECT Id, Purpose__c 
                FROM ProjectReviewTemplate__c 
                WHERE TemplateType__c = :mRecordTypes.get(oProjectReview.RecordTypeId).Name Limit 1]);
            if (!lPRT.isEmpty())
            {
                oProjectReview.ProjectReviewTemplate__c = lPRT[0].Id;
                oProjectReview.Purpose__c = lPRT[0].Purpose__c;
            }
        }

        isPerfReview = false;

        getTheProject();

        showScheduleButton = true;
        perfActiveStatus = false;
        showOtherSections = false;
        lAttendees = new List<ECO_Utils_Activities.Attendee>();
        lKPI_Results = new List<KPI_Result__c>();
        
        if (oProjectReview.EventID__c != null)
        {
            lEvents = new List<Event>([SELECT Id FROM Event WHERE Id = :oProjectReview.EventID__c Limit 1]);
            if (!lEvents.isEmpty())
            {
                showScheduleButton = false;
            }
            else
            {
                oProjectReview.EventID__c = null;
            }
            fetchInviteesAndAttendees();
        }
        
        loadConditions();                   
    }

    public boolean getShowApprovalProcessList()
    {
        List<ProcessInstance> processInstanceList = [SELECT Id
                                                    FROM ProcessInstance 
                                                    WHERE TargetObjectId = :oProjectReview.Id];

        if (processInstanceList.isEmpty())
            return false;

        return true;
    }

    public List<Schema.FieldSetMember> getCustomProjFields()
    {
        theProject = getTheProject();
        if (theProject.pse__Stage__c == 'Planning' || theProject.pse__Stage__c == 'Pending Go/No Go')  
            return SObjectType.pse__Proj__c.FieldSets.ECO_ProjectReviewPlanning.getFields();
        else
            return SObjectType.pse__Proj__c.FieldSets.ECO_ProjectReviewPostPlanning.getFields();
    }


    public ProjectReview__c getProjectReview(Id projectReviewId)
    {
        ECO_Utils_Meta.SelectAll soUtil = new ECO_Utils_Meta.SelectAll();
        soUtil.GetFields('ProjectReview__c');
        String queryString = soUtil.SOQL;
        queryString = queryString.remove('lastreferenceddate,');
        queryString = querystring.replace('FROM ProjectReview__c', 
            ', ProjectReviewTemplate__r.Purpose__c, RecordType.Name FROM ProjectReview__c');
        queryString += ' WHERE Id = \''+ projectReviewId +'\'';
        
        List<ProjectReview__c> projectReviews = Database.query(queryString);
        return projectReviews[0];
    }
    
    public PageReference init()
    {
        try {
            if (mRecordTypes.get(oProjectReview.RecordTypeId).DeveloperName == 'ProjectPerformanceReview' ||
                mRecordTypes.get(oProjectReview.RecordTypeId).DeveloperName == 'PerformanceReview')
            {
            system.debug('here');
                return new PageReference('/apex/ECO_ProjectPerformanceReviews?id=' + oProjectReview.Id + 
                    '&RecordTypeId=' + oProjectReview.RecordTypeid + '&ProjectId=' + oProjectReview.Project__c);
            }
    
            showKPIs = false;
            showOtherSections = true;
    
            if (ECO_Utils_String.NullCheck(oProjectReview.Name) == '')
                oProjectReview.Name = mRecordTypes.get(oProjectReview.RecordTypeId).Name + ' ' + 'Review';      
    
            if (ECO_Utils_String.NullCheck(oProjectReview.Status__c) == '')
                oProjectReview.Status__c = 'Assessing';
    
            if (ApexPages.currentPage().getParameters().get('ProjectId') != null && oProjectReview.Id == null)
            {
                try{
                    insert oProjectReview;
                    return new PageReference('/apex/ECO_ProjectReviews?id=' + oProjectReview.Id + '&RecordTypeId=' +
                         oProjectReview.RecordTypeId + '&ProjectId=' + oProjectReview.Project__c);
                }
                catch(Exception e){
                    ECO_Service_ErrorLog.logException(e);
                }
            }
    
            oProjectReview = getProjectReview(oProjectReview.Id);
            
            reviewTasks = [SELECT Id, Subject,  ActivityDate, OwnerId FROM Task WHERE whatId = :oProjectReview.Id];
        
            fetchAgendaItems();
            
            lDelete_AgendaItems = new List<AgendaItem__c>();    

            // US-07141 Removing this query.  It's causing a limit error and it's not needed
            // because the Copy Comments button has been removed from the VF.    
            /*List<ProjectReview__c> previousReviews = [SELECT Id, MeetingMinutes__c FROM ProjectReview__c 
                WHERE Id != :oProjectReview.Id AND RecordTypeId = :oProjectReview.RecordTypeId 
                AND CreatedDate < :oProjectReview.CreatedDate ORDER BY id desc ];
            if (!previousReviews.isEmpty())
                lastProjectReview = previousReviews[0];*/
    
            if (oProjectReview.Responsible_Person__c == null)    
                oProjectReview.Responsible_Person__c = ECO_Service_ProjectTeam.getProjectManagerFromProjectTeam(theProject.Id);
        }
        catch( Exception e){
            ECO_Service_ErrorLog.logException(e);
        }
        
        return null;
    }

    public PageReference initPerformanceReviews()
    {
        showKPIs = true;
        tabState = 'name1';

        try {
            if ((mRecordTypes.get(oProjectReview.RecordTypeId).DeveloperName == 'ProjectPerformanceReview' ||
                mRecordTypes.get(oProjectReview.RecordTypeId).DeveloperName == 'PerformanceReview') && oProjectReview.Id == null)
            {   
                DateTime dt = DateTime.now();
                String month = dt.format('MMMMM');
                String dateString  = dt.format('dd-MMM-yyyy');
                oProjectReview.Name = mRecordTypes.get(oProjectReview.RecordTypeId).Name + ' ' + dateString;    
            }       
    
            if (ApexPages.currentPage().getParameters().get('ProjectId') != null && oProjectReview.Id == null)
            {
                try{
                    insert oProjectReview;

                    return new PageReference('/apex/ECO_ProjectPerformanceReviews?id=' + oProjectReview.Id + '&RecordTypeId=' +
                         oProjectReview.RecordTypeId + '&ProjectId=' + oProjectReview.Project__c);
                }
                catch(Exception e){
                    ECO_Service_ErrorLog.logException(e);
                }
            }
            else
            {
                if (oProjectReview.Status__c == '' || oProjectReview.Status__c == 'Not Started' || oProjectReview.Status__c == null ||
                    oProjectReview.Status__c == 'Rejected' || oProjectReview.Status__c == 'Assessing')
                {
                    try
                    {
                        update oProjectReview;
                    }
                    catch(Exception e)
                    {
                        ApexPages.Message oMsg = 
                            new ApexPages.Message(ApexPages.Severity.ERROR,'An error occured while saving record:'+e);
                        ApexPages.addMessage(oMsg);
                    }
                }
            }
    
            oProjectReview = getProjectReview(oProjectReview.Id);
    
            if (oProjectReview.Responsible_Person__c == null)    
                oProjectReview.Responsible_Person__c = ECO_Service_ProjectTeam.getProjectManagerFromProjectTeam(theProject.Id);
    
            if (oProjectReview.ProjectApprover__c == null)   
                oProjectReview.ProjectApprover__c = ECO_Service_ProjectTeam.getActiveProjectApproverId(theProject.Id);              
    
            if (oProjectReview.ProjectAccountant__c == null) 
                oProjectReview.ProjectAccountant__c = ECO_Service_ProjectTeam.getActiveProjectAccountantId(theProject.Id);

            if(oProjectReview.PMApprover__c == null)
                oProjectReview.PMApprover__c = ECO_Service_ProjectTeam.getProjectManagerFromProjectTeam(theProject.Id);
    
            if (oProjectReview.Status__c == null)
            {
                oProjectReview.Status__c = 'Not Started';
            }
            
            if (oProjectReview.Status__c != 'Not Started')
            {
                perfActiveStatus = true;
            }
            
            PerformHealthCheck();   
        
            isPerfReview = true;
            if (mRecordTypes.get(oProjectReview.RecordTypeId).DeveloperName == 'ProjectPerformanceReview')
                isProjectPerfReview = true;
    
            lastProjectReview = getPreviousProjectReview();     
    
            if (isPerfReview && perfActiveStatus)
            {
                showOtherSections = true;
            }
            reviewTasks = [SELECT Id, Subject,  ActivityDate, OwnerId FROM Task WHERE whatId = :oProjectReview.Id];
        }
        catch(Exception e){
            ECO_Service_ErrorLog.logException(e);
        }
        return null;
    }

    private ProjectReview__c getPreviousProjectReview()
    {
        List<ProjectReview__c> previousReviews = [SELECT Id, MeetingMinutes__c, SafetyExceptionReport__c, ClientRelations__c, 
            ChangeManagementExceptionReport__c, FinancialPerformanceExceptionReport__c,
            SheduleExceptionReport__c, QualityException__c, RiskManagement__c, StaffResourcesExceptionReport__c, SubsExceptionReport__c 
            FROM ProjectReview__c WHERE  Project__c = :oProjectReview.Project__c AND Id != :oProjectReview.Id 
            AND RecordTypeId = :oProjectReview.RecordTypeId 
            AND CreatedDate < :oProjectReview.CreatedDate ORDER BY id DESC ];
        if (!previousReviews.isEmpty())
            return previousReviews[0];  
        return null;
    }

    public PageReference returnToAllReviews()
    {
        PageReference pageRef = new PageReference('/apex/ECO_ProjectReviewRecordType?id=' + oProjectReview.Project__c);
        return pageRef;
    }

    public PageReference returnToRMASummary()
    {
        List<QuestionnaireSet__c> lQS = [Select Id From QuestionnaireSet__c Where Project__c = :theProject.Id Order By LastModifiedDate DESC Limit 1];

        PageReference pageRef = new PageReference('/apex/ECO_RMSummary?id=' + lQs[0].Id);
        return pageRef;
    }

    public PageReference copyComments()
    {         
        PageReference pageRef;  
        try {
            if (oProjectReview.MeetingMinutes__c != null)
            {
                oProjectReview.MeetingMinutes__c += lastProjectReview.MeetingMinutes__c;
                oProjectReview.SafetyExceptionReport__c += lastProjectReview.SafetyExceptionReport__c;
                oProjectReview.ClientRelations__c += lastProjectReview.ClientRelations__c;
                oProjectReview.ChangeManagementExceptionReport__c += lastProjectReview.ChangeManagementExceptionReport__c;
                oProjectReview.FinancialPerformanceExceptionReport__c += lastProjectReview.FinancialPerformanceExceptionReport__c;
                oProjectReview.SheduleExceptionReport__c += lastProjectReview.SheduleExceptionReport__c;
                oProjectReview.QualityException__c += lastProjectReview.QualityException__c;
                oProjectReview.RiskManagement__c += lastProjectReview.RiskManagement__c;
                oProjectReview.StaffResourcesExceptionReport__c += lastProjectReview.StaffResourcesExceptionReport__c;
                oProjectReview.SubsExceptionReport__c += lastProjectReview.SubsExceptionReport__c;
            }
            else
            {
                oProjectReview.MeetingMinutes__c = lastProjectReview.MeetingMinutes__c;
                oProjectReview.SafetyExceptionReport__c = lastProjectReview.SafetyExceptionReport__c;
                oProjectReview.ClientRelations__c = lastProjectReview.ClientRelations__c;
                oProjectReview.ChangeManagementExceptionReport__c = lastProjectReview.ChangeManagementExceptionReport__c;
                oProjectReview.FinancialPerformanceExceptionReport__c = lastProjectReview.FinancialPerformanceExceptionReport__c;
                oProjectReview.SheduleExceptionReport__c = lastProjectReview.SheduleExceptionReport__c;
                oProjectReview.QualityException__c = lastProjectReview.QualityException__c;
                oProjectReview.RiskManagement__c = lastProjectReview.RiskManagement__c;
                oProjectReview.StaffResourcesExceptionReport__c = lastProjectReview.StaffResourcesExceptionReport__c;
                oProjectReview.SubsExceptionReport__c = lastProjectReview.SubsExceptionReport__c;
            }
            oProjectReview.CommentsCopiedFromPreviousReview__c = true;
            update oProjectReview;
    
            pageRef = new PageReference('/apex/ECO_ProjectReviews?id=' + oProjectReview.Id);
            pageRef.getParameters().put('ProjectId', oProjectReview.Project__c);
            pageRef.getParameters().put('RecordTypeId', oProjectReview.RecordTypeId);
        }
        catch(Exception e){
            ECO_Service_ErrorLog.logException(e);
        }
        return pageRef;
    }

    private void loadConditions(){
        String strSOQL = 'SELECT ';
        String projectID = oProjectReview.Project__c;
            
        for (Schema.FieldSetMember fsmField: SObjectType.DOAConditions__c.FieldSets.DOA_ApprovalView.getFields()) {
            strSOQL += fsmField.getFieldPath() + ', ';
        }
        
        strSOQL += 'ID FROM DOAConditions__c WHERE Project__c =: projectID';

        lstDOAConditions = (List<DOAConditions__c>)Database.query(strSOQL);
    }

    public List<Schema.FieldSetMember> getCustomProjSetupFields()
    {
        return SObjectType.pse__Proj__c.FieldSets.pse_ProjectFieldsforCustomProjectSetup.getFields();
    }
    
    public void PerformHealthCheck()
    {
        try {
            lKPI_Results = [SELECT Id, Trigger_Name__c, Evaluation_Result__c, Alert_Message__c, Explanation__c, 
                    KPI_Result__c.ThresholdDescription__c FROM KPI_Result__c WHERE Project_Review__c = :oProjectReview.Id 
                    ORDER BY Trigger_Name__c];       
            if (lKPI_Results.isEmpty())
            {
                System.debug('PerformHealthCheck, ProjectID: ' + oProjectReview.Project__c);
                ECO_HealthCheckEvaluator hc = new ECO_HealthCheckEvaluator();
                //List<ECO_HealthCheckEvaluator.Response> lResponses = 
                  //  new List<ECO_HealthCheckEvaluator.Response>(hc.EvaluateProject(oProjectReview.Project__c));
                List<Id> projectIds = new List<Id>();
                Id projectId = oProjectReview.Project__c;
                projectIds.add(projectId);
                Map<Id, List<ECO_HealthCheckEvaluator.Response>> responseMap = hc.EvaluateProjects(projectIds);
                List<ECO_HealthCheckEvaluator.Response> lResponses = responseMap.get(projectId);
                if (lResponses != null) {
                    for (ECO_HealthCheckEvaluator.Response resp : lResponses)
                    {
                        System.debug('Message: ' + resp.message);
                        KPI_Result__c oKPI = new KPI_Result__c();
                        oKPI.Trigger_Name__c = resp.triggerName;
                        oKPI.Project_Review__c = oProjectReview.Id;
                        oKPI.Evaluation_Result__c = resp.evalResult;
                        oKPI.Alert_Message__c = resp.message;
                        oKPI.ThresholdDescription__c = resp.thresholdDescription;
                        oKPI.OverrideRegion__c = resp.regionOverride;
                        lKPI_Results.add(oKPI);
                    }
                    insert lKPI_Results;
                }
            }

            lKPI_Results = [SELECT Id, Name, Trigger_Name__c, Evaluation_Result__c, Alert_Message__c, Explanation__c, 
                KPI_Result__c.ThresholdDescription__c FROM KPI_Result__c 
                WHERE Project_Review__c = :oProjectReview.Id ORDER BY Trigger_Name__c];
        }
        catch(Exception e){
            ECO_Service_ErrorLog.logException(e);
        }
    }

    public PageReference SaveHealthCheck()
    {
       try {
            System.debug('___theProject.Id='+theProject.Id);
            System.debug('___oProjectReview.Project__c ='+oProjectReview.Project__c);
            
            //oProjectReview.Project__c = theProject.Id;
            oProjectReview.Status__c = 'Assessing';
            oProjectReview.Snapshot_Date__c = Date.today();
            
            update oProjectReview;
            System.debug('___oProjectReview = '+oProjectReview);
            
            upsert lKPI_Results;
            SaveAll();      
            
            ECO_Service_ProjectSnapshots projectSnapshotService = new ECO_Service_ProjectSnapshots(theProject.Id);
            ProjectSnapshot__c projectSnapshot = projectSnapshotService.getProjectSnapshot(DateTime.now());
            projectSnapshot.ProjectReview__c = oProjectReview.Id;
            //update projectSnapshot; 
            System.debug('__ projectSnapshot.Snapshot_Project_Key__c='+projectSnapshot.Snapshot_Project_Key__c);
            upsert projectSnapshot projectSnapshot.Snapshot_Project_Key__c;
            upsert lKPI_Results;
            //return SaveAll();
            
            showOtherSections = true;
        }
        catch(Exception e){
            ECO_Service_ErrorLog.logException(e);
        }
        return new PageReference('/' + oProjectReview.Id);
    }

    public PageReference newTask() {
        PageReference pageRef;
        try {
            Id taskRecordTypeId = ECO_Utils_Meta.getRecordTypeId(Task.sObjectType, 'ECO Tasks');
           
            Task t = new Task();
            t.WhatId = oProjectReview.Id;
            t.RecordTypeId = taskRecordTypeId;
            insert t;
    
            pageRef = new PageReference('/' + t.Id + '/e');
            pageRef.getParameters().put('retURL', '/' + oProjectReview.Id);
        }
        catch(Exception e){
            ECO_Service_ErrorLog.logException(e);
        }
        return PageRef;
    }

    public pse__Proj__c getTheProject()
    {
        if (theProject == null)
        {
            set<string> setSelectFields = new set<string>();
            setSelectFields.add('ProjectNumber__c');
            setSelectFields.add('Name');
            setSelectFields.add('TotalApprovedRevenue__c');
            setSelectFields.add('OwnerId');
            setSelectFields.add('pse__Stage__c');
            setSelectFields.add('pse__Opportunity__c');
            setSelectFields.add('OpportunityName__c');
            setSelectFields.add('pse__End_Date__c');
            setSelectFields.add('CarryingOutOrganizationFormula__c');
            setSelectFields.add('PercentageMargin__c');
            setSelectFields.add('WeightedNSR__c');
            setSelectFields.add('ProjectApprover__c');
            setSelectFields.add('pse__Start_Date__c');
            setSelectFields.add('RecordType.Name');
            setSelectFields.add('CarryingOutOrganization__c');
            setSelectFields.add('CarryingOutOrganization__r.Region__c');
            setSelectFields.add('pse__Project_Manager__c');
            setSelectFields.add('NetServicesRevenue__c');
            setSelectFields.add('ProjectOwningOrg__c');
            setSelectFields.add('TotalMargin__c');
            setSelectFields.add('PrimaryEndClient__c');
            setSelectFields.add('PrimaryEndClientName__c');
            setSelectFields.add('TotalBidBudget__c');
            setSelectFields.add('PrimaryBillingClient__c');
            setSelectFields.add('PrimaryBillingClientName__c');

            for (Schema.FieldSetMember f : SObjectType.pse__Proj__c.FieldSets.ECO_ProjectReviewPlanning.getFields())
            {
                setSelectFields.add(f.getFieldPath());
            }

            for (Schema.FieldSetMember f : SObjectType.pse__Proj__c.FieldSets.ECO_ProjectReviewPostPlanning.getFields())
            {
                setSelectFields.add(f.getFieldPath());
            }


           /* String query = 'SELECT Id, ProjectNumber__c, TotalApprovedRevenue__c, OwnerId, pse__Stage__c' +
                ', pse__Opportunity__c, OpportunityName__c, pse__End_Date__c, CarryingOutOrganizationFormula__c'+ 
                ', PercentageMargin__c, WeightedNSR__c, ProjectApprover__c, pse__Start_Date__c, RecordType.Name'+ 
                ', CarryingOutOrganization__c, CarryingOutOrganization__r.Region__c, pse__Project_Manager__c, NetServicesRevenue__c'+ 
                ', ProjectOwningOrg__c, TotalMargin__c, PrimaryEndClient__c, PrimaryEndClientName__c, TotalBidBudget__c'+ 
                ', PrimaryBillingClient__c, PrimaryBillingClientName__c';*/

            String query = 'SELECT Id';

            for (string s : setSelectFields)
            {
                query += ', ' + s;
            }


            /*for (Schema.FieldSetMember f : getCustomProjSetupFields())
            {
                query += ', ' + f.getFieldPath();
            }*/
            query += ' FROM pse__Proj__c WHERE Id = \'' + oProjectReview.Project__c + '\' Limit 1';
            System.debug('___getTheProject: query='+query);

            try{
                theProject = Database.query(query);
            } catch (Exception e){
                ECO_Service_ErrorLog.formatPageError(e, 'Error while trying to obtain project information. Please contact your administrator. ' + e.getMessage());
            }
        }
        return theProject;
    }
    
    public void fetchAgendaItems()
    {
        lAgendaItems = new List<AgendaItem__c>([SELECT Id, Name, Agenda_Num__c, ProjectReview__c, Comments__c FROM AgendaItem__c 
            WHERE ProjectReview__c = :oProjectReview.Id Order By Agenda_Num__c]);
        List<AgendaItemTemplate__c>  lAgendaItemTemplates;
        String sField = ECO_Service_MasterDataTranslation.translatedField('AgendaItemTemplate__c', 'Description__c');
        if (lAgendaItems.isEmpty() && isProjectPerfReview)
        {
            //System.debug('sField called in if:::'+sField);
            lAgendaItemTemplates = new List<AgendaItemTemplate__c>([SELECT Id, Name, Section__c, SortOrder__c, Description__c, FrDescription__c 
                FROM AgendaItemTemplate__c 
                WHERE ProjectReviewTemplate__r.TemplateType__c = :mRecordTypes.get(oProjectReview.RecordTypeId).Name]);
            Integer iAgendaNum = 1;

            if (!lAgendaItemTemplates.isEmpty())
            {
                for (AgendaItemTemplate__c ait : lAgendaItemTemplates)
                {
                    lAgendaItems.add(new AgendaItem__c(Agenda_Num__c = iAgendaNum, Name = ait.Name, 
                        Section__c = ait.Section__c, SortOrder__c = ait.SortOrder__c, Description__c = ait.Description__c, 
                        ProjectReview__c = oProjectReview.Id, AgendaItemTemplate__c = ait.Id));
                    iAgendaNum++;                   
                }           
            }
            if (lAgendaItems.isEmpty())
            {
                lAgendaItems.add(new AgendaItem__c(ProjectReview__c = oProjectReview.Id));
            }
        }
        
        else if ((oProjectReview.MeetingMinutes__c == null || oProjectReview.MeetingMinutes__c == '') && !isProjectPerfReview)
        {
            lAgendaItemTemplates = new List<AgendaItemTemplate__c>([SELECT Id, Name, Section__c, SortOrder__c, Description__c, FrDescription__c 
                FROM AgendaItemTemplate__c WHERE ProjectReviewTemplate__r.TemplateType__c = :mRecordTypes.get(oProjectReview.RecordTypeId).Name 
                ORDER BY SortOrder__c]);
            Integer iAgendaNum = 1;

            if (!lAgendaItemTemplates.isEmpty())
            {   
                //System.debug('sField called in else if:::'+sField);
                String meetingMinutesAgendateItems = '<html><b>Agenda Items</b><br/><br/>'; 
                for (AgendaItemTemplate__c ait : lAgendaItemTemplates)
                {   
                    if(sField != 'Description__c' && ait.get(sField) != null && ait.get(sField) != ''){
                        meetingMinutesAgendateItems += ait.get(sField) +  '<br/>';
                    }else{
                        meetingMinutesAgendateItems += ait.Description__c +  '<br/>';
                    }
                }
                meetingMinutesAgendateItems += '</ul></html>';
                oProjectReview.MeetingMinutes__c = meetingMinutesAgendateItems;             
            }
        }
    }

    public void fetchInviteesAndAttendees()
    {
        lInvitees = ECO_Utils_Activities.getInvitees(oProjectReview.EventID__c);
        lAttendees = ECO_Utils_Activities.getAttendees(lInvitees);
    }
    
    public void addRecord()
    {
        if (recordObjectType == 'AgendaItem__c')
        {
            lAgendaItems.add(new AgendaItem__c(ProjectReview__c = oProjectReview.Id));
        }
    }
    
    public void removeRecord()
    {
        if (recordObjectType == 'AgendaItem__c')
        {
            for (Integer i=0; i<lAgendaItems.size(); i++)
            {
                if (lAgendaItems[i].Id == recordObjectId)
                    lDelete_AgendaItems.add(lAgendaItems.remove(i));
            }
        }
    }
    
    public PageReference SaveAll()
    {
        PageReference oPR;
        String prString = '';
        try {
            if (mRecordTypes.get(oProjectReview.RecordTypeId).DeveloperName == 'ProjectPerformanceReview' || 
                mRecordTypes.get(oProjectReview.RecordTypeId).DeveloperName == 'PerformanceReview')
            {
                    prString = '/apex/ECO_ProjectPerformanceReviews?id=';
            }
            else {
                    prString = '/apex/ECO_ProjectReviews?id=';
            }
            oPR = new PageReference( prString + oProjectReview.Id + '&RecordTypeId=' + oProjectReview.RecordTypeId +
                 '&ProjectId=' + oProjectReview.Project__c);
            System.debug('___SaveAll: oPR ='+oPR);
            oPR.setRedirect(true); //Needed to propagate RecordTypeId and ProjectId (for Notes relatedList)
            
            try
            {
                update oProjectReview;
                
                if (!lKPI_Results.isEmpty())
                    update lKPI_Results;
            }
            catch(DMLException e){
                ECO_Service_ErrorLog.logException(e);
            }
        }
        catch(Exception e){
            ECO_Service_ErrorLog.logException(e);
        }

        return oPR;
    }
    
    public PageReference ReturnToProjectFromReview()
    {
        PageReference oPR = new PageReference('/' + theProject.Id);
        //oPR.setRedirect(true);
        return oPR;
    }
    
    public PageReference ScheduleMeeting()
    {
        try {
            update oProjectReview;
            if (oProjectReview.ScheduledDate__c != null)
            {
                Event evt;
                Id eventRecordTypeId = ECO_Utils_Meta.getRecordTypeId(Event.sObjectType, 'Eco Project Event');
    
                if (oProjectReview.EventID__c == null)
                {
                    evt = new Event();
                    evt.WhatId = oProjectReview.Id;
                    evt.StartDateTime = oProjectReview.ScheduledDate__c;
                    evt.Subject = oProjectReview.Name + ' - ' + theProject.Name;
                    evt.DurationInMinutes = 60;
                    evt.RecordTypeId = eventRecordTypeId;
                    insert evt;
                    oProjectReview.EventID__c = evt.Id;
                    update oProjectReview;  
    
                    createProjectTeamInvites(evt);          
                }
            }
            else
            {
                ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR,
                    'Please specify the Scheduled Date before scheduling a meeting.');
                ApexPages.addMessage(oPageMessage);
                return null;
            }
        }
        catch(Exception e){
            ECO_Service_ErrorLog.logException(e);
        }
        return ManageEvent();
    }
    
    private void createProjectTeamInvites(Event event)
    {
        try {
            Id userId = UserInfo.getUserId();
            
            EventRelation eventRelation;
            Map<Id, EventRelation> eventRelationsMap = new Map<Id, EventRelation>();
            for (ProjectTeamMember__c projectTeamMember:[SELECT Id, Name, Contact__r.pse__Salesforce_User__c 
                FROM ProjectTeamMember__c WHERE Project__c = :theProject.Id and UserIsActive__c = true])
            {
    
                if (projectTeamMember.Contact__r.pse__Salesforce_User__c != null && 
                    projectTeamMember.Contact__r.pse__Salesforce_User__c != userId)
                {
                    eventRelation = new EventRelation(EventId = event.Id, 
                        RelationId=projectTeamMember.Contact__r.pse__Salesforce_User__c);
                    eventRelationsMap.put(projectTeamMember.Contact__r.pse__Salesforce_User__c, eventRelation);
                }
            }
            if (!eventRelationsMap.values().isEmpty())
                insert eventRelationsMap.values();
        }
        catch(Exception e){
            ECO_Service_ErrorLog.logException(e);
        }
    }

    public PageReference ManageEvent()
    {
        PageReference oPR;
        if (oProjectReview.EventID__c != null)
        {
            oPR = new PageReference('/' + oProjectReview.EventID__c );
            oPR.getParameters().put('retURL', '/' + oProjectReview.Id);
            oPR.getParameters().put('saveURL', '/' + oProjectReview.Id);            
            oPR.setRedirect(true);
        }
        return oPR;
    }
    
    public PageReference CreateCalendarInvite()
    {
        PageReference oPR;
        if (oProjectReview.EventID__c != null)
        {
            oPR = new PageReference('/servlet/servlet.OutlookEvent?id=' + oProjectReview.EventID__c);
            oPR.setRedirect(true);
        }
        return oPR;
    }

    public boolean validateKPIMetrics()
    {
        for (KPI_Result__c result:lKPI_Results)
        {
            if (result.Evaluation_Result__c && (result.Explanation__c == null || result.Explanation__c == ''))
            {
                return false;
            }
        }
        return true;
    }

    public PageReference submitforescalaton(){

        oProjectReview.FlagForEscalate__c = true;

        try {
            update oProjectReview;

            PageReference myPage = new PageReference('/' + oProjectReview.Id);
            myPage.setRedirect(true);
            return myPage;

        }
        catch(Exception e){
            ApexPages.addMessages(e);
            throw(e);
        }

        return null;
    }

    public PageReference SubmitForApproval()
    {
        Boolean hasPermissionForApprovalProcess = ECO_Service_RecordAccess.getProjectRecordAccessForApprovalProcess ('ProjectReview__c', theProject.Id);
            
        if (! hasPermissionForApprovalProcess)  
        {   
            system.debug( 'No Permission for approval process' );
            
            ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'You do not have permission to Submit for Approval');
            ApexPages.addMessage(oPageMessage);            

            return null;
        }

        if (!validateKPIMetrics())
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'Explanations are required for all failed KPI\'s.  ' +
                'Please return to Step 1 – KPI Review tab and enter explanations for all failed KPI\'s.') );  
            return null;
        }

        try {

            list<ECO_Service_ProjectTeam.CheckMember> lstCheckMembers = new list<ECO_Service_ProjectTeam.CheckMember>();
            if (mRecordTypes.get(oProjectReview.RecordTypeId).DeveloperName == 'ProjectPerformanceReview' || mRecordTypes.get(oProjectReview.RecordTypeId).DeveloperName == 'PerformanceReview'){
                lstCheckMembers.add(new ECO_Service_ProjectTeam.CheckMember(theProject.id, 'Project Approver'));
                lstCheckMembers.add(new ECO_Service_ProjectTeam.CheckMember(theProject.id, 'Project Manager'));
            }
            if (mRecordTypes.get(oProjectReview.RecordTypeId).DeveloperName == 'ProjectPerformanceReview'){
                lstCheckMembers.add(new ECO_Service_ProjectTeam.CheckMember(theProject.id, 'Project Accountant'));
            }
            

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
            
            if(!lPTM.isEmpty()){
                for(ProjectTeamMember__c ptm : lPTM){
                    if(ptm.ProjectRole__r.Name == 'Project Approver' && oProjectReview.ProjectApprover__c != ptm.Contact__r.pse__Salesforce_User__c){
                        oProjectReview.ProjectApprover__c = ptm.Contact__r.pse__Salesforce_User__c;
                    }
                    if(ptm.ProjectRole__r.Name == 'Project Accountant' && oProjectReview.ProjectAccountant__c != ptm.Contact__r.pse__Salesforce_User__c){
                        oProjectReview.ProjectAccountant__c = ptm.Contact__r.pse__Salesforce_User__c;
                    }
                    if(ptm.ProjectRole__r.Name == 'Project Manager' && oProjectReview.PMApprover__c != ptm.Contact__r.pse__Salesforce_User__c){
                        oProjectReview.PMApprover__c = ptm.Contact__r.pse__Salesforce_User__c;
                    }
                }
            }
            
            List<ProjectReview__c> listPR = new List<ProjectReview__c>();
            listPR.add(oProjectReview);

            ECO_Service_Delegation.evaluateDelegation(listPR, null);
            ECO_Service_Delegation.insertDelegations(listPR);

            update oProjectReview;
            if (!lKPI_Results.isEmpty()){
                update lKPI_Results;
            }
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();  
            req1.setComments('Submitted for Approval');
            req1.setObjectId(oProjectReview.Id);
            Approval.ProcessResult result = Approval.process(req1); 

            if (result.isSuccess())
            {
                return new PageReference('/' + oProjectReview.Id);
            }

        }
        catch(Exception e){
            ApexPages.addMessages(e);
            throw(e);
        }

        return null;
    }
    
    public virtual String getProjectSnapshotRecord()
    {
        List<ProjectSnapshot__c> projectSnapshotRecords = [SELECT Id FROM ProjectSnapshot__c 
            WHERE Project__c = :theProject.Id  and ProjectReview__c = :oProjectReview.Id ORDER BY Id DESC LIMIT 1];
        
        if (projectSnapshotRecords.size() > 0)
            return projectSnapshotRecords[0].id;
        return '';
    }   
    
    public PageReference printProjectReviews() {
        PageReference oPageReference = Page.ECO_ProjectReviewsPdf;
        oPageReference.getParameters().put('Id', oProjectReview.Id);
        oPageReference.setRedirect(true);
        return oPageReference;
    }  
}