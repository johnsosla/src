/** ------------------------------------------------------------------------------------------------------
* @ Controller for handling Project Teamholder logic
*
* @Author      NTT Data - Tim Chiang
* @Date        2016
*-----------------------------------------------------------------------------------------------------*/
public class ECO_StakeholdersController
{

    private Transient Attachment stakeHolderAttachment;
    public String overrideStakeHolderAttachment  {get;set;}

    public pse__Proj__c oProject {get; set;}
    public List<TeamMember> lActiveMembersKey {get; set;}
    public List<TeamMember> lInactiveMembersKey {get; set;}
    public List<TeamMember> lMembersTeam {get; set;}
    public List<TeamMember> lInactiveMembersTeam {get; set;}
    public List<ProjectRole__c> lProjectRoles {get; set;}
    public List<ProjectTeamMember__c> lProjectTeamMembers {get; set;}
    public Map<Id, List<ProjectTeamMember__c>> lProjectKeyMembers {get; set;}
    public List<Stakeholder__c> lStakeholders {get; set;}
    public List<CommunicationPlan__c> lCommPlans {get; set;}
    public list<SurveySchedule__c> lSurveySchedules {get; set;}
    public List<Project_Site__c> lProjectSites {get; set;}
    public List<Account> lAccounts {get; set;}
    public Set<Id> setAccountIds {get; set;}
    public String recordObjectType {get; set;}
    public String recordObjectId {get; set;}
    public ApexPages.StandardController oStandardController {get; set;}
    public Boolean showStakeholderNote {get; set;}
    public Boolean showCommPlanNote {get; set;}
    public Boolean showVacantKeyMemberNote {get; set;}
    public list<SelectOption> clients { get; set; }
    public map<id, list<SelectOption>> mapClient2Contact{ get; set; }
    public list<ScheduleWrapper> lstSSW {get;set;} 
    public map<id, id> mapSiteToAccount { get; set; }
    public ProjectTeamMember__c insertReplaceProjectTeamMember{get; set;}
    public String userSelectQueryType{get; set;}
    public List<Contact> queryDelegates{get; set;}
    public Boolean saveError{get; set;}
    public Contact pAndLTeamMember{get; set;}
    public Contact financeTeamMember{get; set;}
    private static Set<String> financeRoles = new Set<String>{'Project Accountant', 'Project Accountant 2', 'Finance Lead', 'Finance Lead 2'};
    public map<string, ProjectTeamMember__c> mapActiveRoles;


    public map<Id, Attachment> attachmentsMap {get; set;}
    public Boolean activePA {get;set;}

    /**
     * Constructor
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     * @param   stdController
     * @return
     *
     **/
    public ECO_StakeholdersController(ApexPages.StandardController oStandardController) 
    {
        //US-06752: To avoid addFields error for 'Print Project Plan' button, reset the fields to
        //call addFields below also as some other calling class could have done addFields too
        if(!Test.isRunningTest()){
            oStandardController.reset();
        }
        
        this.oStandardController = oStandardController;
        List<string> lFields = new List<String>();
        lFields.add('OUID__c');
        if(!Test.isRunningTest()){
            oStandardController.addFields(lFields);
        }
        
        //oStandardController.addFields(LIST<String>);
        oProject = (pse__Proj__c)oStandardController.getRecord();
        initStakeHolders(oProject);
        resetModalValues();
        attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :oproject.Id]);
    }

    /**
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *     
     * @param   
     * @return Attachment 
     **/
    public Attachment docStakeHolderAttachment
    {
        get
        {
            if(stakeHolderAttachment==null)
            {
                stakeHolderAttachment = new Attachment(parentid = oproject.id);
            }
            return stakeHolderAttachment;
        }
        set;
    }
    
    /**
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *     
     * @param   
     * @return Attachment list
     **/
    public list<Attachment> getStakeholderDoc()
    {

        list<String> attachmentIds = new list<String>();
        if(oproject.StakeholderAttachments__c != null)
            attachmentIds = oproject.StakeholderAttachments__c.split(';');
            
        return getAttachmentListFromIdList(attachmentIds);
    }

    /**
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *     
     * @param   
     * @return 
     **/
    public void saveStakeholderDoc()
    {
        if(stakeHolderAttachment.Body != null)
        {   
            if(overrideStakeHolderAttachment != null && overrideStakeHolderAttachment != '')
                stakeHolderAttachment.Name = overrideStakeHolderAttachment;               
            insert stakeHolderAttachment;
            
            if(oproject.StakeholderAttachments__c != null)
                oproject.StakeholderAttachments__c += stakeHolderAttachment.Id + ';';
            else
                oproject.StakeholderAttachments__c = stakeHolderAttachment.Id + ';';          
            update oproject;
            
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :oproject.Id]);
            stakeHolderAttachment = null;
        }           
    }

    /**
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *     
     * @param   attachmentIds list
     * @return Attachment list
     **/
    private list<Attachment> getAttachmentListFromIdList(list<String> attachmentIds)
    {
        list<Attachment> attachments = new list<Attachment>();
        for(String attachmentId:attachmentIds)
        {
            if(attachmentsMap.containsKey(attachmentId) && attachmentId != null && attachmentId != '')
                attachments.add(attachmentsMap.get(attachmentId));
        }
        return attachments; 
    }


    /** 
     * returns a string of the current url to the page
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     * @param   
     * @return String 
     **/
    public String returnURL{
        get{
            return ApexPages.currentPage().getUrl();
        }   
        set;
    }
    
    /**
     * Returns Project Role Id of Client Account Manager role
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     * @param   
     * @return Id
     **/
    public static Id iCAMId{
        get{
            ProjectRole__c[] oRole = [Select Id, Name From ProjectRole__c Where Name = 'Client Account Manager'];
            return oRole[0].Id;
        }
        set;
    }

    /**
     * Returns Project Role Id of Go/No Go Approver role
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   
     * @return Id
     **/
    public static Id iGNGId{
        get{
            ProjectRole__c[] oRole = [Select Id, Name From ProjectRole__c Where Name = 'Go/No Go Approver'];
            return oRole[0].Id;
        }
        set;
    }

    /**
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     * @param   
     * @return 
     **/
    private void SearchSites(){

        string strSOQL = 'SELECT ';
        
        for (Schema.FieldSetMember fsmField: SObjectType.Project_Site__c.FieldSets.pse_ClientFinder_Display_Fieldset.getFields()) {
            strSOQL += fsmField.getFieldPath() + ', ';
        }
        
        strSOQL += 'ID, SITE__C, Is_Billing__c, Is_Default_Top_Task__c, Is_End__c, Is_Primary_End__c, Site__r.Account__c  FROM Project_Site__c WHERE Project__c=\'' + oProject.Id + '\'';

        lProjectSites = (list<Project_Site__c>)Database.query(strSOQL);

        clients = new list<SelectOption>(); 

        set<id> lstSiteID = new set<id>();
        set<id> lstAccountID = new set<id>();

        mapSiteToAccount = new map<id, id>(); 

        clients.add(new SelectOption('', ''));

        for(Project_Site__c p:lProjectSites){
            mapSiteToAccount.put(p.SITE__C, p.Site__r.Account__c);
            clients.add(new SelectOption(p.SITE__C, p.Account_Name__c));
            lstAccountID.add(p.Site__r.Account__c);
        }

        mapClient2Contact = new map<id, list<SelectOption>>();

        for(contact c:[select id, lastname, firstname, OracleContactID__c, site__c, accountid from contact where accountid IN: lstAccountID]){
            if(!mapClient2Contact.containskey(c.site__c)){
                mapClient2Contact.put(c.accountid, new list<SelectOption>());
            } 

            mapClient2Contact.get(c.accountid).add(new SelectOption(c.id, c.lastname + ', ' + c.firstname));
        }

    }   
    
    /**
     * initializes all of the data list on the page
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     * @param  pse__Proj__c
     * @return 
     **/
    public void initStakeHolders(pse__Proj__c thisProject) {    
        if(thisProject != null)
        {
            lProjectSites = new list<Project_Site__c>();
            lProjectTeamMembers = new List<ProjectTeamMember__c>();
            lProjectKeyMembers = new Map<Id, List<ProjectTeamMember__c>>();

            SearchSites();

            lProjectRoles = new List<ProjectRole__c>([Select Id, Name, Type__c, FrName__c From ProjectRole__c Where Active__c = true Order By SortOrder__c ASC]);
            
            List<ProjectTeamMember__c> projectTeamMembers = new List<ProjectTeamMember__c>([SELECT Id, ProjectRole__c, ProjectRole__r.Name, ProjectRole__r.FrName__c,
                                                                                                    ProjectRole__r.Type__c, Contact__c, 
                                                                                                    Contact__r.Name, Contact__r.pse__Is_Resource_Active__c, 
                                                                                                    Contact__r.pse__Salesforce_User__c, Status__c, 
                                                                                                    ProjectRoleTitle__c, Project__c, StartDate__c, 
                                                                                                    EndDate__c, Phone__c, Email__c, Active__c, Is_Active__c,
                                                                                                    Contact__r.ReportsTo.pse__Salesforce_User__c 
                                                                                                FROM ProjectTeamMember__c 
                                                                                                WHERE Project__c = :thisProject.Id 
                                                                                                ORDER BY ProjectRole__r.Type__c, StartDate__c ASC]);
            
            lStakeholders = new List<Stakeholder__c>([SELECT Id, StakeholderType__c, Organization__c, 
                                                            Contact__c, ContactName__c, ContactPhone__c, 
                                                            Interest__c, AECOMContact__c, AECOMContactlookup__c 
                                                            FROM Stakeholder__c 
                                                            WHERE Project__c = :thisProject.Id]);
            
            lCommPlans = new List<CommunicationPlan__c>([SELECT Id, When__c, ResponsiblePerson__c, 
                                                                How__c, Frequency__c, Audience__c, 
                                                                Activity__c, GenerateTask__c, ResponsiblePTM__c 
                                                            FROM CommunicationPlan__c 
                                                            WHERE Project__c = :thisProject.Id]);

            lSurveySchedules = new list<SurveySchedule__c>([SELECT Id, Name, Comments__c, ScheduledDate__c, Client__c, Contact__c, Site_Account__c 
                                                                FROM SurveySchedule__c 
                                                                WHERE Project__c = :thisProject.Id]);

            lstSSW = new list<ScheduleWrapper>();

            for(ProjectTeamMember__c projectTeamMember : projectTeamMembers){
                if(projectTeamMember.ProjectRole__r.Type__c == 'Key Member'){
                    List<ProjectTeamMember__c> projectMembers = new List<ProjectTeamMember__c>();
                    if(lProjectKeyMembers.containsKey(projectTeamMember.ProjectRole__c)){
                        projectMembers = lProjectKeyMembers.get(projectTeamMember.ProjectRole__c);
                    }
                    projectMembers.add(projectTeamMember);
                    lProjectKeyMembers.put(projectTeamMember.ProjectRole__c, projectMembers);
                    if(projectTeamMember.ProjectRole__r.Name == 'Project Approver 2' && pAndLTeamMember == null){
                        pAndLTeamMember = projectTeamMember.Contact__r;
                    }
                    if(projectTeamMember.ProjectRole__r.Name == 'Finance Lead' && financeTeamMember == null){
                        financeTeamMember = projectTeamMember.Contact__r;
                    }
                }
                else{
                    if(projectTeamMember.ProjectRole__r.Name != 'Project Owner')
                        lProjectTeamMembers.add(projectTeamMember);
                }
            }
            
            //create wrapper versions of the surveyschedules            
            if(lSurveySchedules.size() > 0){
                Integer surveyCounter = 0;
                List<Id> siteIds = new List<Id>();
                for(SurveySchedule__c ss: lSurveySchedules){
                    siteIds.add(ss.Client__c);
                }

                Map<Id, Site__c> siteMap = new Map<Id, Site__c>([SELECT Id, Account__c FROM Site__c WHERE Id IN : siteIds]);
                List<Id> accountIds = new List<Id>();
                for(Site__c site : siteMap.values()){
                    accountIds.add(site.Account__c);
                }
                Map<Id, Account> accountIdMap = new Map<Id, Account>([SELECT Id, 
                                                                            (SELECT Id, Name, AccountId 
                                                                                FROM Contacts 
                                                                                WHERE (NOT FirstName LIKE '%payable%') 
                                                                                AND (NOT LastName LIKE '%payable%') ORDER BY Name) 
                                                                                FROM Account 
                                                                                WHERE Id IN: accountIds]);

                for(SurveySchedule__c ss: lSurveySchedules){
                    if(accountIdMap != null && siteMap != null 
                        && siteMap.containsKey(ss.Client__c) && accountIdMap.containsKey(siteMap.get(ss.Client__c).Account__c) 
                        && accountIdMap.get(siteMap.get(ss.Client__c).Account__c).Contacts != null ){
                        List<Contact> contacts = accountIdMap.get(siteMap.get(ss.Client__c).Account__c).Contacts;
                        lstSSW.add(new ScheduleWrapper(ss, surveyCounter, contacts));
                        ++surveyCounter;
                    }
                }
            }

            setOptions();

            showStakeholderNote = false;
            showCommPlanNote = false;
            showVacantKeyMemberNote = false;
            if(lStakeholders.isEmpty()){
                showStakeholderNote = true;
            }
            if(lCommPlans.isEmpty()){
                showCommPlanNote = true;
            }

            setAccountIds = new Set<Id>();
            for(Project_Site__c oPS : lProjectSites)
            {
                setAccountIds.add(oPS.Site__r.Account__c);
            }
            lAccounts = getClientInfo();
            
            lActiveMembersKey = new List<TeamMember>();
            lInactiveMembersKey = new List<TeamMember>();
            lMembersTeam = new List<TeamMember>();
            lInactiveMembersTeam = new List<TeamMember>();

            mapActiveRoles = new map<string, ProjectTeamMember__c>();


            //load Key Roles Data Table
            for(ProjectRole__c pr : lProjectRoles)
            {
                if(pr.Type__c == 'Key Member')
                {
                    
                    if(lProjectKeyMembers.containsKey(pr.Id)){
                        for(Integer i=0; i < lProjectKeyMembers.get(pr.Id).size(); i++)
                        {
                            ProjectTeamMember__c pkm = lProjectKeyMembers.get(pr.Id)[i];
                            TeamMember teamMember = createNewTeamMember(thisProject, pr);
                            
                            if(pkm.Contact__c != null)
                            {
                                if(!pkm.Active__c)
                                {
                                    TeamMember inactiveTM = createNewTeamMember(thisProject, pr);
                                    inactiveTM.oPTM = pkm;
                                    lInactiveMembersKey.add(inactiveTM);
                                }
                                else
                                {
                                    teamMember.canEdit = canEditKeyMember(pkm.ProjectRole__r.Name);
                                    teamMember.oPTM = pkm;
                                    lActiveMembersKey.add(teamMember);
                                    mapActiveRoles.put(pkm.ProjectRole__r.Name, pkm);
                                }
                            }
                        }
                    }
                    /*else{
                        TeamMember teamMember = createNewTeamMember(thisProject, pr);
                        teamMember.canEdit = canEditKeyMember(pr.Name);
                        lActiveMembersKey.add(teamMember);
                    }*/
                }
            }

            for(ProjectRole__c pr : lProjectRoles)
            {
                if(pr.Type__c == 'Key Member')
                {
                    if(!mapActiveRoles.containskey(pr.name)){
                        TeamMember teamMember = createNewTeamMember(thisProject, pr);
                        teamMember.canEdit = canEditKeyMember(pr.Name);
                        lActiveMembersKey.add(teamMember);
                    }
                }
            }


            
            activePA = false;

            for(TeamMember tm : lActiveMembersKey)
            {
                if(tm.RoleName == 'Project Approver'){
                    activePA = true;
                }

                if(tm.oPTM.Contact__c == null && tm.RoleName != 'Deputy Project Manager' 
                    && tm.RoleName != 'Project Biller' && tm.RoleName != 'FCAP Subcontract Administrator' 
                    && tm.RoleName != 'Project Administrator'
                    && tm.RoleName != 'Project Management Administrator')     
                {
                    showVacantKeyMemberNote = true;
                    break;
                }
            }
            //To get translated role name field
            String sField = ECO_Service_MasterDataTranslation.translatedField('ProjectRole__c', 'Name');
            String sTranslatedRole = '';
            
            for(ProjectTeamMember__c ptm : lProjectTeamMembers)
            {
                if(ptm.Contact__c != null)
                {   
                    if(String.valueof(ptm.ProjectRole__r.get(sField)) != null){
                        sTranslatedRole = String.valueof(ptm.ProjectRole__r.get(sField));
                    }else{
                        sTranslatedRole = ptm.ProjectRole__r.Name;
                    }
                    List<ProjectRole__c> sortedProjectRoles = lProjectRoles;
                    sortedProjectRoles.sort();
                    TeamMember tm = new TeamMember(thisProject, lProjectRoles);
                    tm.RoleID = ptm.ProjectRole__c;
                    tm.RoleName = ptm.ProjectRole__r.Name;
                    tm.TranslatedRoleName = sTranslatedRole;
                    tm.RoleType = ptm.ProjectRole__r.Type__c;
                    tm.oPTM = ptm;

                    if(ptm.contact__r.pse__Is_Resource_Active__c && ptm.Is_Active__c ){
                        lMembersTeam.add(tm);
                    } else {
                        lInactiveMembersTeam.add(tm);
                    }
                    
                }   
            }
            
            if(lMembersTeam.isEmpty())
            {
                List<ProjectRole__c> sortedProjectRoles = lProjectRoles;
                sortedProjectRoles.sort();
                TeamMember tm = new TeamMember(thisProject, lProjectRoles);
                tm.RoleType = 'Team Member';
                lMembersTeam.add(tm);
            }

            if(lStakeholders.isEmpty()){
                lStakeholders.add(new Stakeholder__c(Project__c = thisProject.Id));
            }
        }
    }

    /**
     * does the current project have all of the necessary default team members assigned to allow editing?
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     * @param   String 
     * @return  Boolean 
     **/
    private Boolean canEditKeyMember(String projectRoleName){
        if(projectRoleName == 'CFO or Delegate'){
            return false;
        }
        else if(financeRoles.contains(projectRoleName) && financeTeamMember != null){
            if(projectRoleName == 'Finance Lead' && financeTeamMember.pse__Salesforce_User__c == UserInfo.getUserId()){
                return true;
            }
            else if(projectRoleName == 'Finance Lead'){
                return false;
            }
            else{
                return true;
            }
        }
        else if(pAndLTeamMember != null && !financeRoles.contains(projectRoleName)){
            if(projectRoleName == 'Project Approver 2' && pAndLTeamMember.pse__Salesforce_User__c == UserInfo.getUserId()){
                return true;
            }
            else if(projectRoleName == 'Project Approver 2'){
                return false;
            }
            else{
                return true;
            }
        }
        return false;
    }

    /**
     * creates a new TeamMember wrapper object
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     * @param   pse__Proj__c, ProjectRole__c
     * @return  TeamMember 
     **/
    private TeamMember createNewTeamMember(pse__Proj__c thisProject, ProjectRole__c projectRole){
        String sField = ECO_Service_MasterDataTranslation.translatedField('ProjectRole__c', 'Name');
        String sTranslatedRole = '';
        if(String.valueof(projectRole.get(sField)) != null){
            sTranslatedRole = String.valueof(projectRole.get(sField));
        }else{
            sTranslatedRole = projectRole.Name;
        }

        TeamMember teamMember = new TeamMember(thisProject, lProjectRoles);
        teamMember.RoleID = projectRole.Id;
        teamMember.RoleName = projectRole.Name; //Needs translation
        teamMember.TranslatedRoleName = sTranslatedRole;
        teamMember.RoleType = projectRole.Type__c;

        sTranslatedRole = '';
        return teamMember;
    }
    
    /**
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     * @param   
     * @return  Schema.FieldSetMember list
     **/
    public List<Schema.FieldSetMember> getAccountBasicListFields()
    {
        return SObjectType.Account.FieldSets.Basic_List_Set.getFields();
    }
    
     /**
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     * @param   
     * @return  Account list
     **/
    public List<Account> getClientInfo()
    {
        List<Account> lAccounts = new List<Account>();
        if(setAccountIds.size() > 0)
        {
            String query = 'SELECT Id';
            for(Schema.FieldSetMember f : getAccountBasicListFields()) 
            {
                query += ', ' + f.getFieldPath();
            }
            query += ' FROM Account WHERE Id In :setAccountIds';
            lAccounts = Database.query(query);
        }
        return lAccounts;
    }

    /**
     * resets all fields in modal window after closing the window
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     * @param   
     * @return  PageReference 
     **/
    public PageReference resetModalValues(){
        insertReplaceProjectTeamMember = new ProjectTeamMember__c();
        userSelectQueryType = 'Delegate';
        saveError = false;
        queryDelegates = null;
        return null;
    }

    /**
     * button that returns to project page
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     * @param   
     * @return  PageReference 
     **/
    public PageReference ReturnToProject()
    {
        PageReference oPR = new PageReference('/' + oProject.Id);
        oPR.setRedirect(true);
        return oPR;
    }
    
    /**
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     * @param   
     * @return  Boolean 
     **/
    private Boolean isValid()
    {
        List<TeamMember> lAllKeyMembers = new List<TeamMember>();
        lAllKeyMembers.addAll(lActiveMembersKey);
        lAllKeyMembers.addAll(lInactiveMembersKey);
        for(TeamMember tm1 : lAllKeyMembers)
        {
            for(TeamMember tm2 : lAllKeyMembers)
            {
                if(tm1.oPTM.Id != tm2.oPTM.Id)
                {
                    String contactID1 = tm1.oPTM.Contact__c;
                    String contactID2 = tm2.oPTM.Contact__c;
                    String roleID1 = tm1.RoleID;
                    String roleID2 = tm2.RoleID;
                    String roleName = tm2.RoleName;
                
                    //make sure the same person or role is not represented twice during the same time frame
                    if( (contactID1 != null) && (contactID1 == contactID2 || (roleID1 == roleID2 && roleName != 'Deputy Project Manager' ) ))
                    { 
                        Date startDate1 = tm1.oPTM.StartDate__c;
                        Date startDate2 = tm2.oPTM.StartDate__c;
                        Date endDate1 = tm1.oPTM.EndDate__c;
                        Date endDate2 = tm2.oPTM.EndDate__c;
                        if(endDate1 == null)
                        {
                            endDate1 = Date.newInstance(2199,12,31);
                        }
                        if(endDate2 == null)
                        {
                            endDate2 = Date.newInstance(2199,12,31);
                        }
                    }
                }
            }
        }

        //system.debug('DEBUG ******* GOT HERE');
        for(TeamMember tm : lMembersTeam)
        {
            if(tm.oPTM.Contact__c != null && (tm.RoleID == null || tm.RoleID == '')){
                //system.debug('DEBUG ******* GOT HERE 1');
                ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'All team members must have a role defined.');
                ApexPages.addMessage(oMsg);
                return false;
            }
        }

        return true;
    }
    
    /**
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     * @param   
     * @return  PageReference 
     **/
    public PageReference SaveAll()
    {
        PageReference oPR;

        //system.debug( 'Saving all..');

        if(isValid())
        {
            lProjectTeamMembers.clear();
            
            Set<Id> contactIdsOfTeamMembers = new Set<Id>();

            for(TeamMember tm : lActiveMembersKey)
            {
                //system.debug( 'tm.oPTM.Contact__c ' + tm.oPTM.Contact__c );
                if(tm.oPTM.Contact__c != null)
                {
                    contactIdsOfTeamMembers.add( tm.oPTM.Contact__c );
                }
            }
            
            Map<ID, Contact> mapOfContactRecordsForTeamMembers = new Map<ID, Contact> ( [SELECT Id, name, pse__Salesforce_User__r.ProjectAccountantAuthority__c 
                                                                                            FROM Contact 
                                                                                            WHERE Id IN :contactIdsOfTeamMembers] );
            
            Contact conTM ; 
            
            for(TeamMember tm : lInactiveMembersKey)
            {
                if(tm.oPTM.Contact__c != null)
                {
                    tm.oPTM.ProjectRole__c = tm.RoleID;
                    tm.oPTM.Is_Active__c = false;
                    lProjectTeamMembers.add(tm.oPTM);
                }
            }
            for(TeamMember tm : lMembersTeam)
            {
                //system.debug( 'tm.oPTM.Contact__c ' + tm.oPTM.Contact__c + '  RoleName:::'+  tm.oPTM.ProjectRole__r.Name + '  Role:::'+tm.oPTM.ProjectRole__c);
                if(tm.oPTM.Contact__c != null)
                {
                    tm.oPTM.ProjectRole__c = tm.RoleID;
                    lProjectTeamMembers.add(tm.oPTM);
                }
                
                
            }
            
            for(Integer i=0; i<lStakeholders.size(); i++)
            {
                if(lStakeholders[i].StakeholderType__c == null)
                    lStakeholders.remove(i);
            }
            for(Integer i=0; i<lCommPlans.size(); i++)
            {
                if(lCommPlans[i].Activity__c == null)
                    lCommPlans.remove(i);
            }

            for(Integer i=0; i<lSurveySchedules.size(); i++)
            {
                if(lSurveySchedules[i].ScheduledDate__c == null){
                    lSurveySchedules.remove(i);
                    lstSSW.remove(i);
                }
            }           
            
            try
            {
                oStandardController.save();
                upsert lProjectTeamMembers;
                upsert lStakeholders;
                upsert lCommPlans;
                upsert lSurveySchedules;
                update oProject;
                oPR = ApexPages.currentPage();
                oPR.getParameters().clear();
                oPR.getParameters().put('id', oProject.Id);
                oPR.setRedirect(true);
            }
            catch(DMLException e)
            {
                System.debug('Error: ' + e.getMessage());
                //ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                ApexPages.addMessages(e);
                for (Integer i = 0; i < e.getNumDml(); i++) 
                {
                    for(ProjectTeamMember__c oPTM : lProjectTeamMembers)
                    {
                        if(oPTM.Id == e.getDmlId(i))
                        {
                            oPTM.Contact__c.addError('Please correct');
                        }
                    }
                }
            }
        }
        return oPR;
    }

    /**
     * resets the queryDelegates list so the modal table will not show
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     * @param   
     * @return  PageReference 
     **/
    public PageReference resetQueryTable(){
        queryDelegates = new List<Contact>();
        return null;
    }

    /**
     * queries for the key member in the search parameters on the modal window
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     * @param   
     * @return  PageReference
     **/
    public PageReference searchForKeyMembers(){
        String queryContactName = ApexPages.currentPage().getParameters().get('contactName');
        String queryType = ApexPages.currentPage().getParameters().get('queryType');
        String selectedRole = ApexPages.currentPage().getParameters().get('selectedRole');
        String startDate = ApexPages.currentPage().getParameters().get('startDate');
        String contactQuery = 'Select Id, Name, Title, Email, Phone, ReportsTo.Name from Contact Where pse__Is_Resource__c = true and pse__Is_Resource_Active__c = true and pse__Salesforce_User__r.isActive = true';
        String firstName;
        String lastName;
        Boolean bUseOuId = false;
        String sProjOUID = oProject.OUID__c;

        if(queryContactName != null && queryContactName != ''){
            if(queryContactName.trim().contains(' ')){
                List<String> nameSplit = queryContactName.trim().split(' ');
                firstName = String.escapeSingleQuotes(nameSplit[0].replace(',', ''));
                lastName = String.escapeSingleQuotes(nameSplit[nameSplit.size() - 1].replace(',', ''));
            }
            else{
                firstName = String.escapeSingleQuotes(queryContactName);
            }
        }

        //Priya
        List<ECODelegationOrgPreference__c> lCSetting = new List<ECODelegationOrgPreference__c>();

        lCSetting = [SELECT Name, UseDefaultDelegation__c 
                       FROM ECODelegationOrgPreference__c 
                       Where Name = :oProject.OUID__c
                       AND UseDefaultDelegation__c = TRUE];

        if(lCSetting != null && lCSetting.size() > 0){
            bUseOuId = true;
        }
        //End

        if(selectedRole== 'Deputy Project Manager' || 
            selectedRole== 'Project Manager' || 
            selectedRole=='Project Approver 2' || 
            selectedRole=='Project Administrator' || 
            selectedRole=='Project Biller' || 
            selectedRole=='FCAP Subcontract Administrator' ||
            selectedRole=='Project Management Administrator'){ 
            queryType = 'Unfiltered';
        }

        if(queryType == 'Delegate' && !bUseOuId){ //Priya

            
            String delegateQuery = 'Select Delegate__c, Allowed_Organizations__c From Delegate__c';
            if(queryContactName != null && queryContactName != ''){
                delegateQuery += ' Where ((Delegate__r.FirstName Like \'' + firstName + '%\'';
                if(lastName != null){
                    delegateQuery += ' AND Delegate__r.LastName Like \'' + lastName + '%\'';
                }
                delegateQuery += ') OR (Delegate__r.LastName Like \'' + firstName + '%\'';
                if(lastName != null){
                    delegateQuery += ' AND Delegate__r.FirstName Like \'' + lastName + '%\'';
                }   
                delegateQuery += '))';          
            }
            if(selectedRole != null && selectedRole != 'undefined' && selectedRole != ''){
                if(delegateQuery.contains('Where')){
                    delegateQuery += ' AND';
                }
                else{
                    delegateQuery += ' Where';
                }
                if(selectedRole == 'Finance Lead 2'){

                    RecordType alternateRecordType = null;

                    try{
                        alternateRecordType = [Select Id from RecordType where SObjectType = 'Delegate__c' AND DeveloperName = 'Alternate'];
                    } catch( Exception e){
                        ECO_Service_ErrorLog.formatPageError(e, 'Error while searching for Projects during a delegate search: ' + e.getMessage());
                        return null;
                    }

                    delegateQuery += ' RecordTypeId = \'' + alternateRecordType.Id + '\'';
                }
                else{
                    if(selectedRole == 'Project Accountant 2'){
                        selectedRole = 'Project Accountant';
                    }
                    delegateQuery += ' Key_Member_Role__c = \'' + selectedRole + '\'';
                }
            }
            if(pAndLTeamMember != null || financeTeamMember != null){
                if(delegateQuery.contains('Where')){
                    delegateQuery += ' AND';
                }
                else{
                    delegateQuery += ' Where';
                }
                if(financeRoles.contains(selectedRole)){
                    delegateQuery += ' Delegator__c = \'' + financeTeamMember.Id + '\'';
                }
                else{
                    delegateQuery += ' Delegator__c = \'' + pAndLTeamMember.Id + '\'';
                }
            }
            if(insertReplaceProjectTeamMember.StartDate__c != null){
                if(delegateQuery.contains('Where')){
                    delegateQuery += ' AND';
                }
                else{
                    delegateQuery += ' Where';
                }
                delegateQuery += ' (Start_Date__c <= ' + convertDateToSoqlDateString(insertReplaceProjectTeamMember.StartDate__c);
                delegateQuery += ' AND(End_Date__c = NULL OR End_Date__c >= ' + convertDateToSoqlDateString(insertReplaceProjectTeamMember.StartDate__c) + '))';
            }
            else if(startDate != null && startDate != ''){
                if(delegateQuery.contains('Where')){
                    delegateQuery += ' AND';
                }
                else{
                    delegateQuery += ' Where';
                }
                delegateQuery += ' (Start_Date__c <= ' + convertStringSOQLString(startDate);
                delegateQuery += ' AND(End_Date__c = NULL OR End_Date__c >= ' + convertStringSOQLString(startDate) + '))';
            }
            delegateQuery += ' AND Approval_Status__c = \'Approved\'';

            List<Delegate__c> delegates = Database.query(delegateQuery);
            Set<Id> delegateIds = new Set<Id>();

            pse__proj__c project = null;

            try{

                project = [SELECT Id, PnLManager__r.pse__Salesforce_User__c, OUID__c, 
                                CarryingOutOrganization__r.FAManager__r.pse__Salesforce_User__c, CarryingOutOrganization__c 
                                FROM pse__Proj__c 
                                WHERE Id =: oProject.Id];

            } catch( Exception e){
                ECO_Service_ErrorLog.formatPageError(e, 'Error while searching for Projects during a delegate search: ' + e.getMessage());
                return null;
            }           

            
            for(Delegate__c delegate : delegates){
                if(project.CarryingOutOrganization__c != null){
                    //look for delegates that are allowed for the project's carrying out organization
                    if(delegate.Allowed_Organizations__c != null){
                        List<String> tempList = delegate.Allowed_Organizations__c.split(';');
                        Set<String> allowedOrganizations = new Set<String>();
                        allowedOrganizations.addAll(tempList);
                        if(allowedOrganizations.contains(project.CarryingOutOrganization__c)){
                            delegateIds.add(delegate.Delegate__c);
                        }
                    }
                    else{
                        delegateIds.add(delegate.Delegate__c);
                    }
                }
                //no carrying out organization was supplied to the project
                else{
                    delegateIds.add(delegate.Delegate__c);
                }
            }
            contactQuery += ' AND Id IN: delegateIds';
        }
        else{
            if(firstName != null){
                if(lastName == null){
                    contactQuery += ' And (FirstName Like \'' + firstName + '%\' OR LastName Like \'' + firstName + '%\')';
                }
                else{
                    contactQuery += ' And ((FirstName Like \'' + firstName + '%\' AND LastName Like \'' + lastName + '%\')';
                    contactQuery += ' OR (FirstName Like \'' + lastName + '%\' AND LastName Like \'' + firstName + '%\'))';
                }
            }
        }
        //contactQuery += ' AND (NOT pse__Salesforce_User__r.TrackingID__c Like \'%U\')';
        
        contactQuery += ' AND pse__Salesforce_User__r.PersonId__c != null ';
        contactQuery += ' AND pse__Salesforce_User__r.TrackingID__c != null ';
        contactQuery += ' AND (OracleContactID__c LIKE \'EMPLOYEE-%\') ';

        if(selectedRole== 'Project Manager'){
            //contactQuery += ' AND (pse__Salesforce_User__r.ProjectManagerAuthority__c = true) ';
            contactQuery += ' AND (pse__Salesforce_User__r.Certified_PM__c = \'Y\' or pse__Salesforce_User__r.Certified_PM__c = \'Yes\' or pse__Salesforce_User__r.Certified_PM__c = \'Provisional\') ';
        } else if (selectedRole== 'Deputy Project Manager'){
            contactQuery += ' AND pse__Salesforce_User__r.DPMAuthority__c = true';
        } else if(selectedRole== 'Project Approver' && bUseOuId){ //Priya
            contactQuery += ' AND pse__Salesforce_User__r.Project_Approver__c = \'Y\'';
            if(queryType == 'Delegate'){
                contactQuery += ' AND pse__Salesforce_User__r.ECO_OUID__c = :sProjOUID';
            }
        } else if((selectedRole== 'Project Accountant' || selectedRole== 'Project Accountant 2') && bUseOuId){
            contactQuery += ' AND pse__Salesforce_User__r.ProjectAccountantAuthority__c = true';
            if(queryType == 'Delegate'){
                contactQuery += ' AND pse__Salesforce_User__r.ECO_OUID__c = :sProjOUID';
            }
        } else if (selectedRole== 'Project Management Administrator'){
            contactQuery += ' AND pse__Salesforce_User__r.PMA_Authority__c = true';
        }
        //End
        contactQuery += ' LIMIT 50';

        try{
            queryDelegates = Database.query(contactQuery);      
        } catch( Exception e){
            ECO_Service_ErrorLog.formatPageError(e, 'Error while searching for Teammembers: ' + e.getMessage());
            return null;
        }


        return null;
    }

    /**
     * To replace or update key members on Project Team Member
     *
     * @Author  NTT Data - ?,Priya Parepalli
     * @Date    September, 2016
     *
     * @param   
     * @return  PageReference 
     **/
    public PageReference selectReplaceKeyMember(){
        String selectedContactId = ApexPages.currentPage().getParameters().get('selectedContactId');
        String selectedRoleName = ApexPages.currentPage().getParameters().get('selectedRole');
        String startDate = ApexPages.currentPage().getParameters().get('startDate');
        String existingId = ApexPages.currentPage().getParameters().get('existingId');
        String queryType = ApexPages.currentPage().getParameters().get('queryType');
        List<pse__Proj__Share> lProjShare = new List<pse__Proj__Share>();

        ProjectRole__c projectRole;
        
        //retrieve the project role object
        for(ProjectRole__c projRole : lProjectRoles){
            if(projRole.Name == selectedRoleName){
                projectRole = projRole;
            }
        }

        //check to make sure the data is validated
        if(validateKeyMember(startDate, projectRole, selectedContactId, existingId)){


            RecordType keyRecordType = [Select Id from RecordType where sobjecttype = 'ProjectTeamMember__c' and Name = 'Key Member'];

            Savepoint savePoint = Database.setSavepoint();

            try{
                List<ProjectTeamMember__c> projectTeamMembers = new List<ProjectTeamMember__c>();
                List<ProjectTeamMember__c> projectTeamMembersToUpdate = new List<ProjectTeamMember__c>();
                List<ProjectTeamMember__c> projectTeamMembersToDelete = new List<ProjectTeamMember__c>();
                Date keyMemberStartDate;

                if(oProject.pse__Stage__c == 'Planning' || oProject.pse__Stage__c == 'Pending Go/No Go')
                {
                    if(oProject.pse__Start_Date__c == null)
                        keyMemberStartDate = oProject.EstimatedStartDate__c;
                    else
                        keyMemberStartDate = oProject.pse__Start_Date__c;
                }
                else
                    keyMemberStartDate = insertReplaceProjectTeamMember.StartDate__c;

                ProjectTeamMember__c projectTeamMember;
                if((oProject.pse__Stage__c == 'Planning' || oProject.pse__Stage__c == 'Pending Go/No Go') && existingId != null && existingId != '')    
                {
                    Approval.ProcessWorkItemRequest pwr = new Approval.ProcessWorkItemRequest();
        
                    List<ProcessInstance> procins = new List<ProcessInstance>([select Id from ProcessInstance where Status = 'Pending' and TargetObjectId = :existingId]);
                    if(!procins.isEmpty())
                    {
                        // Retrieve the process work instance id associated to the process instance
                        List<ProcessInstanceWorkitem>  workitem = new List<ProcessInstanceWorkitem>([select Id from ProcessInstanceWorkitem where ProcessInstanceId = :procins[0].id]);
                        if ((workitem != null) && (workitem.size() > 0))
                        {
                            pwr.SetComments('Recalling Approval');
                            pwr.setWorkItemId(workitem[0].id);
                            pwr.setAction('Removed'); 
                 
                            // Execute process request
                            Approval.ProcessResult pr = Approval.process(pwr);
                        }   
                    }
                    projectTeamMember = new ProjectTeamMember__c(Id = (Id)existingId, Project__c = oProject.Id, 
                                                                Contact__c = selectedContactId, RecordTypeId = keyRecordType.Id, 
                                                                ProjectRole__c = projectRole.Id, Is_Active__c = true, 
                                                                StartDate__c = keyMemberStartDate);
                }
                else
                    projectTeamMember = new ProjectTeamMember__c(Project__c = oProject.Id, Contact__c = selectedContactId, 
                                                                    RecordTypeId = keyRecordType.Id, ProjectRole__c = projectRole.Id, 
                                                                    Is_Active__c = true, StartDate__c = keyMemberStartDate);
                
                if(queryType == 'Delegate'){
                    projectTeamMember.Status__c = 'Approved';
                }
                else{
                    if(selectedRoleName != 'Project Administrator' &&
                        selectedRoleName != 'Project Biller' &&
                        selectedRoleName != 'FCAP Subcontract Administrator'){

                        projectTeamMember.Status__c = 'Pending';

                    } else {
                        projectTeamMember.Status__c = 'Approved';
                    }
            
                    if(financeRoles.contains(selectedRoleName)){
                        projectTeamMember.Unfiltered_Delegate_Approver__c = financeTeamMember.pse__Salesforce_User__c;
                        projectTeamMember.UnfilteredDelegateSupervisor__c = financeTeamMember.ReportsTo.pse__Salesforce_User__c;
                    }
                    else{
                        projectTeamMember.Unfiltered_Delegate_Approver__c = pAndLTeamMember.pse__Salesforce_User__c;
                        projectTeamMember.UnfilteredDelegateSupervisor__c = pAndLTeamMember.ReportsTo.pse__Salesforce_User__c;
                    }
                    pse__Proj__Share ps = new pse__Proj__Share();
                    ps.AccessLevel = 'Edit';
                    ps.ParentId = oProject.Id;
                    ps.UserOrGroupId =  projectTeamMember.UnfilteredDelegateSupervisor__c;  
                    ps.RowCause = Schema.pse__Proj__Share.RowCause.Delegation__c;     
                    lProjShare.add(ps);           
                    
                    //system.debug('lProjShare:::'+lProjShare);   
                    /*Contact cReportsTo = [SELECT Id, ReportsTo.pse__Salesforce_User__c 
                                        FROM Contact 
                                        WHERE Id = :projectTeamMember.Contact__c];

                    projectTeamMember.UnfilteredDelegateSupervisor__c =  cReportsTo.ReportsTo.pse__Salesforce_User__c;*/
                
                }

                list<ProjectTeamMember__c> lstFuturePTM = [SELECT id, StartDate__c, EndDate__c 
                                                            FROM ProjectTeamMember__c 
                                                            WHERE project__c=:oProject.Id 
                                                            AND ProjectRole__c =: projectRole.Id 
                                                            AND StartDate__c >: projectTeamMember.StartDate__c 
                                                            ORDER BY StartDate__c ASC];
                
                if(lstFuturePTM.size() > 0 && oProject.pse__Stage__c != 'Planning' && oProject.pse__Stage__c != 'Pending Go/No Go'){
                    projectTeamMember.EndDate__c = lstFuturePTM[0].StartDate__c.addDays(-1);
                } else {
                    projectTeamMember.EndDate__c = null;
                }

                projectTeamMembers.add(projectTeamMember);

                if(existingId != null && existingId != '')
                {
                    if(oProject.pse__Stage__c != 'Planning' && oProject.pse__Stage__c != 'Pending Go/No Go')
                        projectTeamMembersToUpdate.add(new ProjectTeamMember__c(Id = existingId, EndDate__c = insertReplaceProjectTeamMember.StartDate__c.addDays(-1)));
                    //else
                    //  projectTeamMembersToDelete.add(new ProjectTeamMember__c(Id = existingId));
                }
                
                // need to update the team member first in order to accomplish the validation rule embedded in the trigger
                //if(!projectTeamMembersToDelete.isEmpty())
                //  delete projectTeamMembersToDelete;

                //system.debug('DEBUG@@@ PTM update size: ' + projectTeamMembersToUpdate.size());

                if(!projectTeamMembersToUpdate.isEmpty()){
                    update projectTeamMembersToUpdate;
                    if(selectedRoleName == 'Project Approver' || selectedRoleName == 'Project Manager' 
                        || selectedRoleName == 'Capture Manager' || selectedRoleName == 'Project Approver 2')
                    {
                        //System.debug('inside skip secuirty for project:::');
                        ECO_Service_RecordAccess.CheckedSObjects.add('pse__Proj__c');
                    }
                }
                
                upsert projectTeamMembers; 
                saveError = false;
                if(projectTeamMember.Status__c == 'Pending'){
                    sendApprovalProcess(projectTeamMember, selectedRoleName);
                }
                if(lProjShare!= null && lProjShare.size()>0){
                    try{
                        insert lProjShare;
                    }catch(Exception e){
                        ECO_Service_ErrorLog.formatPageError(e, e.getMessage());
                    }
                }
            }
            catch(Exception ex){
                saveError = true;
                Database.rollback(savePoint);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error inserting/updating Key Member ' + ex.getMessage()));
                //throw(ex);
            }   
        }
        else{
            saveError = true;
        }
        return null;
    }

    /**
     * starts the aproval process for a requested delegate is they have a pending status
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     * @param   ProjectTeamMember__c, String 
     * @return 
     **/
    @TestVisible 
    private void sendApprovalProcess(ProjectTeamMember__c projectTeamMember, String roleName){
        Contact contact;

        if(roleName != 'Project Approver 2' && 
            roleName != 'Finance Lead' && 
            roleName != 'Deputy Project Manager' &&
            roleName != 'Project Administrator' &&
            roleName != 'Project Biller' &&
            roleName != 'FCAP Subcontract Administrator' &&
            roleName != 'Project Management Administrator'
            ){
            //find the contact from the loaded list already in viewstate
            for(Contact queryDelegate : queryDelegates){
                if(queryDelegate.Id == projectTeamMember.Contact__c){
                    contact = queryDelegate;
                }
            }

            Approval.ProcessSubmitRequest newPendingRequest = new Approval.ProcessSubmitRequest();
            newPendingRequest.setComments('Submitting request for ' + contact.Name + ' to be in the role of ' + roleName + ' for Project ' + oProject.Name);
            newPendingRequest.setObjectId(projectTeamMember.Id);
            //newPendingRequest.setProcessDefinitionNameOrId('Project_Team_Member_Approve_Team_Member');
            newPendingRequest.setProcessDefinitionNameOrId('Project_Team_Member_Approve_Team_Member2');
            newPendingRequest.setSkipEntryCriteria(true);
            Approval.ProcessResult processResult = Approval.process(newPendingRequest);
        }
    }

    /**
     * validates assigning a new team member for key roles to the project
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     * @param   String, ProjectRole__c, String, String  
     * @return  Boolean 
     **/
    private Boolean validateKeyMember(String startDate, ProjectRole__c selectedRole, String selectedContactId, String existingId){
        Boolean isValid = true;
        Date startDte;
        Date endDte;

        //Start Date cannot be null
        if(insertReplaceProjectTeamMember.StartDate__c != null){
            startDte = insertReplaceProjectTeamMember.StartDate__c;
        }
        else{
            if((startDate == null || startDate == '') && (oProject.pse__Stage__c != 'Planning' && oProject.pse__Stage__c != 'Pending Go/No Go')){
                insertReplaceProjectTeamMember.StartDate__c.addError('Start Date is Required');
                isValid = false;
            }
            else{
                if(oProject.pse__Stage__c != 'Planning' && oProject.pse__Stage__c != 'Pending Go/No Go')
                    startDte =  convertStringToDate(startDate);
                else
                {
                    if(oProject.pse__Start_Date__c == null) 
                        startDte = oProject.EstimatedStartDate__c;
                    else
                        startDte = oProject.pse__Start_Date__c;
                }
            }
        }


        if((startDte < oProject.EstimatedStartDate__c) && oProject.pse__Start_Date__c == null){
            insertReplaceProjectTeamMember.StartDate__c.addError('Start Date cannot be before Project Estimated Start Date');
            isValid = false;
        }

        if((startDte < oProject.pse__Start_Date__c) && oProject.pse__Start_Date__c != null){
            insertReplaceProjectTeamMember.StartDate__c.addError('Start Date cannot be before Project Start Date');
            isValid = false;
        }

        //find the latest end date for the role to compare against start date of new role assignment
        if(existingId != null && lProjectKeyMembers.containsKey(selectedRole.Id) && selectedRole.Name != 'Deputy Project Manager'){
            List<ProjectTeamMember__c> teamMembersInRole = lProjectKeyMembers.get(selectedRole.Id);
            for(ProjectTeamMember__c teamMemberInRole : teamMembersInRole){
                if((endDte == null || teamMemberInRole.EndDate__c > endDte) && teamMemberInRole.EndDate__c != null){
                    endDte = teamMemberInRole.EndDate__c;
                }
                else if(endDte == null){
                    endDte = teamMemberInRole.StartDate__c;
                }
            }
        }

        if(startDte <= endDte && oProject.pse__Stage__c != 'Planning' && oProject.pse__Stage__c != 'Pending Go/No Go'){
            insertReplaceProjectTeamMember.StartDate__c.addError('Effective Date cannot be less than the latest date of chosen role');
            isValid = false;
        }


        /*ProjectRole__c otherRole;

        //retrieve the project role object
        for(ProjectRole__c projRole : lProjectRoles){
            if(projRole.Name == 'Other'){
                otherRole = projRole;
            }
        }*/

        //verifies the user is not assigned to any other key role during the same time period
        for(List<ProjectTeamMember__c> teamMembersInRole : lProjectKeyMembers.values()){
            for(ProjectTeamMember__c teamMemberInRole : teamMembersInRole){
                //if(teamMemberInRole.ProjectRole__c != otherRole.id ){
                    if(teamMemberInRole.Contact__c == selectedContactId && teamMemberInRole.ProjectRole__c != selectedRole.Id){
                        if(startDte >= teamMemberInRole.StartDate__c && (startDte <= teamMemberInRole.EndDate__c || teamMemberInRole.EndDate__c == null)){
                            isValid = false;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please ensure that the same Contact is not assigned twice during the same time frame.'));
                            break;
                        }
                    }
                //}
            }
        }

        return isValid;
    }

    /**
     * converts a date value into a string in the format of yyyy-mm-dd
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     * @param   Date 
     * @return  String 
     **/
    private String convertDateToSoqlDateString(Date inputDate){
        String month = String.valueof(inputDate.month());
        String day = String.valueOf(inputDate.day());

        if(month.length() < 2){
            month = '0' + month;
        }

        if(day.length() < 2){
            day = '0' + day;
        }

        return inputDate.year() + '-' + month + '-' + day;
    }

    /**
     * converts a string in the format of mm/dd/yyyy, yyyy.mm.dd, yyyy-mm-dd to a date type
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     * @param   String 
     * @return  Date 
     **/
    private Date convertStringToDate(String inputDate){
        List<String> dateString = new List<String>();
        if(inputDate.contains('/')){
            dateString = inputDate.split('/');
            return date.newInstance(Integer.valueOf(dateString[2]), Integer.valueOf(dateString[0]), Integer.valueOf(dateString[1]));
        }
        else if(inputDate.contains('.')){
            return Date.valueOf(inputDate.replace('.', '-'));
        }
        return Date.valueOf(inputDate);
    }

    /**
     * converts a string in the format of mm/dd/yyyy, yyyy.mm.dd, yyyy-mm-dd to a string in the format of yyyy-mm-dd
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     * @param   String 
     * @return  String 
     **/
    @TestVisible 
    private String convertStringSOQLString(String inputDate){
        List<String> dateString = new List<String>();
        if(inputDate.contains('/')){
            dateString = inputDate.split('/');
            if(dateString[1].length() < 2){
                dateString[1] = 0 + dateString[1];
            }
            if(dateString[0].length() < 2){
                dateString[0] = 0 + dateString[0];
            }
            return dateString[2] + '-' + dateString[0] + '-' + dateString[1];
        }
        else if(inputDate.contains('.')){
            return inputDate.replace('.', '-');
        } 
        return inputDate;
    }
    
    /**
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     * @param   
     * @return 
     **/
    public void addRecord()
    {
        //system.debug('***Adding a record');

        if(recordObjectType == 'MembersTeam')
        {
            TeamMember tm = new TeamMember(oProject, lProjectRoles);
            tm.RoleType = 'Team Member';
            lMembersTeam.add(tm);
        }
        else if(recordObjectType == 'Stakeholder__c')
        {
            lStakeholders.add(new Stakeholder__c(Project__c = oProject.Id));
        }
        else if(recordObjectType == 'CommunicationPlan__c')
        {
            CommunicationPlan__c communicationPlan = new CommunicationPlan__c(Project__c = oProject.Id);
            insert communicationPlan;
            lCommPlans.add(communicationPlan);
        }
        else if(recordObjectType == 'SurveySchedule__c')
        {
            SurveySchedule__c ss = new SurveySchedule__c(Project__c = oProject.Id);
            lSurveySchedules.add(ss);
            lstSSW.add(new ScheduleWrapper(ss, lstSSW.size()));
            setOptions();
        }
    }
    
    /**
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     * @param   
     * @return  PageReference 
     **/
    public PageReference defaultDates(){
        for(TeamMember tm:lActiveMembersKey){
            if(tm.oPTM.StartDate__c == null && tm.oPTM.Contact__c != null){
                tm.oPTM.StartDate__c = oProject.EstimatedStartDate__c;
            }
        }
        return null;
    }

    /**
     * sets the contact picklist for the survey field depending on which client was selected
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     * @param   
     * @return  PageReference
     **/
    public PageReference setOptions(){
        if(ApexPages.currentPage().getParameters().get('surveyToRefresh') != null){
            Integer surveyToRefresh = Integer.valueOf(ApexPages.currentPage().getParameters().get('surveyToRefresh'));
            try{
                Site__c site = [Select Id, Account__c from Site__c where Id =: lstSSW[surveyToRefresh].ss.Client__c];
                List<Contact> contacts = [Select Id, Name from Contact where AccountId =: site.Account__c and (not FirstName Like '%payable%') AND (not LastName Like '%payable%') order by Name];
                lstSSW[surveyToRefresh].cOptions = new list<SelectOption>();
                lstSSW[surveyToRefresh].cOptions.add(new SelectOption('&nbsp;', '--None--'));
                for(Contact contact : contacts){
                    lstSSW[surveyToRefresh].cOptions.add(new SelectOption(contact.Id, contact.Name));
                }
            }
            catch(Exception ex){
                //no available contacts for the select list
            }
        }
        return null;
    }

    /**
     * formats the date sent to the proper locale format
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     * @param   String 
     * @return  String 
     **/  
    @RemoteAction
    public static String formatDate(String currentDate) {
        Date newDate = Date.parse(currentDate);
        newDate = newDate.addDays(1);
        return newDate.format();
    }

    /**
     * removes a record from the related lists
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     * @param   
     * @return  PageReference 
     **/ 
    public PageReference removeRecord(){
        if(recordObjectType == 'MembersTeam')
        {
            Integer teamMemberToRemove = Integer.valueOf(ApexPages.currentPage().getParameters().get('teamMemberToRemove'));
            //system.debug('***teamMemberToRemove ' + teamMemberToRemove);
            if(lMembersTeam[teamMemberToRemove].oPTM.Id != null){
                lMembersTeam[teamMemberToRemove].oPTM.Is_Active__c = false;
                lMembersTeam[teamMemberToRemove].oPTM.EndDate__c = Date.today().adddays(-1);

                if(lMembersTeam[teamMemberToRemove].oPTM.StartDate__c > lMembersTeam[teamMemberToRemove].oPTM.EndDate__c){
                    lMembersTeam[teamMemberToRemove].oPTM.EndDate__c = lMembersTeam[teamMemberToRemove].oPTM.StartDate__c;
                }

                update lMembersTeam[teamMemberToRemove].oPTM;
                lInactiveMembersTeam.add(lMembersTeam[teamMemberToRemove]);
            }
            lMembersTeam.remove(teamMemberToRemove);
        }
        else if(recordObjectType == 'Stakeholder__c')
        {
            Integer otherToRemove = Integer.valueOf(ApexPages.currentPage().getParameters().get('otherToRemove'));
            if(lStakeholders[otherToRemove].Id != null){
                Stakeholder__c stakeHolder = lStakeholders[otherToRemove];
                lStakeholders.remove(otherToRemove);
                delete stakeHolder;
            }
            else{
                lStakeholders.remove(otherToRemove);
            }
        }
        else if(recordObjectType == 'CommunicationPlan__c')
        {
            Integer planToRemove = Integer.valueOf(ApexPages.currentPage().getParameters().get('planToRemove'));
            if(lCommPlans[planToRemove].Id != null){
                CommunicationPlan__c communicationPlan = lCommPlans[planToRemove];
                lcommPlans.remove(planToRemove);
                delete communicationPlan;
            }
            else{
                lcommPlans.remove(planToRemove);
            }
        }
        else if(recordObjectType == 'SurveySchedule__c')
        {
            Integer surveyToRemove = Integer.valueOf(ApexPages.currentPage().getParameters().get('surveyToRemove'));
            if(lSurveySchedules[surveyToRemove].Id != null){
                SurveySchedule__c surveySchedule = lSurveySchedules[surveyToRemove];
                lSurveySchedules.remove(surveyToRemove);
                lstSSW.remove(surveyToRemove);
                delete surveySchedule;
            }
            else{
                lSurveySchedules.remove(surveyToRemove);
                lstSSW.remove(surveyToRemove);
            }
        }       
        else if(recordObjectType == 'KeyMember')
        {
            Integer teamMemberToRemove = Integer.valueOf(ApexPages.currentPage().getParameters().get('teamMemberToRemove'));
            //system.debug('***teamMemberToRemove ' + teamMemberToRemove);
            if(lActiveMembersKey[teamMemberToRemove].oPTM.Id != null){
                lActiveMembersKey[teamMemberToRemove].oPTM.Is_Active__c = false;
                lActiveMembersKey[teamMemberToRemove].oPTM.EndDate__c = Date.today().adddays(-1);

                if(lActiveMembersKey[teamMemberToRemove].oPTM.StartDate__c > lActiveMembersKey[teamMemberToRemove].oPTM.EndDate__c){
                    lActiveMembersKey[teamMemberToRemove].oPTM.EndDate__c = lActiveMembersKey[teamMemberToRemove].oPTM.StartDate__c;
                }

                update lActiveMembersKey[teamMemberToRemove].oPTM;
                lInActiveMembersKey.add(lActiveMembersKey[teamMemberToRemove]);
            }
            lActiveMembersKey.remove(teamMemberToRemove);   
        }
        PageReference oPR = ApexPages.currentPage();
        oPR.getParameters().clear();
        oPR.getParameters().put('id', oProject.Id);
        oPR.setRedirect(true);
        return oPR;
    }
    
    /** ------------------------------------------------------------------------------------------------------
    * @ TeamMember
    *
    * @Author      NTT Data - Tim Chiang
    * @Date        2016
    *-----------------------------------------------------------------------------------------------------*/
    public class TeamMember
    {
        public pse__Proj__c oProject {get; set;}
        public List<ProjectRole__c> lProjectRoles {get; set;}
        public String RoleID {get; set;}
        public String RoleName {get; set;}
        public String TranslatedRoleName {get;set;}
        public String RoleType {get; set;}
        public Date previousDate {get; set;}
        public ProjectTeamMember__c oPTM {get; set;}
        public List<SelectOption> lTeamRoleTypes {get; set;}
        public List<SelectOption> lKeyRoleTypes {get; set;}
        public Boolean canEdit{get; set;}
        /**
         * constructor
         *
         * @Author  NTT Data - Tim Chiang
         * @Date    2016
         *
         **/ 
        public TeamMember(pse__Proj__c proj, List<ProjectRole__c> prList){
            this(proj, prList, null, false);
        }

        /**
         * constructor
         *
         * @Author  NTT Data - Tim Chiang
         * @Date    2016
         *
         **/
        public TeamMember(pse__Proj__c proj, List<ProjectRole__c> prList, String existingId){
            this(proj, prList, existingId, false);
        }

        /**
         * constructor
         *
         * @Author  NTT Data - Tim Chiang
         * @Date    2016
         *
         **/ 
        public TeamMember(pse__Proj__c proj, List<ProjectRole__c> prList, String existingId, Boolean edit)
        {
            
            this.oProject = proj;
            this.lProjectRoles = prList;
            this.canEdit = edit;
            if(existingId != null){
                this.oPTM = new ProjectTeamMember__c(Id = existingId);
            }
            else{
                this.oPTM = new ProjectTeamMember__c(Project__c = oProject.Id);
            }
            lTeamRoleTypes = new List<SelectOption>();
            lTeamRoleTypes.add(new SelectOption('', '--None--'));
            lKeyRoleTypes = new List<SelectOption>();
            lKeyRoleTypes.add(new SelectOption('', '--None--'));

            String sField = ECO_Service_MasterDataTranslation.translatedField('ProjectRole__c', 'Name');
            
            String sTranslatedRole = '';

            for(ProjectRole__c pr : lProjectRoles)
            {
                if(pr.Type__c == 'Team Member' && pr.Name != 'Inactive Deliverable Owner' && pr.Name != 'Project Owner' )
                {   
                    if( String.valueof(pr.get(sField)) == null){
                        sTranslatedRole = pr.Name;
                    }else{
                        sTranslatedRole = String.valueof(pr.get(sField));
                    }

                    //lTeamRoleTypes.add(new SelectOption(pr.Id, pr.Name));
                    lTeamRoleTypes.add(new SelectOption(pr.Id, sTranslatedRole));
                    sTranslatedRole = '';
                }
            }

        }
    }

    /** ------------------------------------------------------------------------------------------------------
    * @ ScheduleWrapper
    *
    * @Author      NTT Data - Tim Chiang
    * @Date        2016
    *-----------------------------------------------------------------------------------------------------*/
     public class ScheduleWrapper {
        public SurveySchedule__c ss {get;set;}
        public list<SelectOption> cOptions {get;set;}
        public Integer counter{get; set;}
        public id accountid {get;set;}

        /**
         * constructor
         *
         * @Author  NTT Data - Tim Chiang
         * @Date    2016
         *
         **/ 
        public ScheduleWrapper(SurveySchedule__c oSS, Integer count){
            this(oSS, count, null);
        }

        /**
         * constructor
         *
         * @Author  NTT Data - Tim Chiang
         * @Date    2016
         *
         **/
        public ScheduleWrapper(SurveySchedule__c oSS, Integer count, List<Contact> contacts){
            this.ss = oSS;
            this.counter = count;
            cOptions = new list<SelectOption>();
            if(contacts != null){
                cOptions = new list<SelectOption>();
                cOptions.add(new SelectOption('&nbsp;', '--None--'));
                for(Contact contact : contacts){
                    cOptions.add(new SelectOption(contact.Id, contact.Name));
                }
            }
        }
    }
    
    
}