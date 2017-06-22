/** ------------------------------------------------------------------------------------------------------
* @Description Controller class for ECO_TechnicalQualityTeamOverride page to add Technical Quality Team
*
* @Author      NTT Data - Priya Parepalli
* @Date        2016
*-----------------------------------------------------------------------------------------------------*/
public with sharing class ECO_DeliverableADDTQReviewersController {

    public Deliverable__c oDeliverable ;

    private string retUrl;
    private string idProject {get;set;}
    private string idDeliverable {get;set;}

    public boolean bDeliverablePassedIn {get;set;}

    public map<Integer,Project_TeamWrapper> mapDisplayTeamAvailable {get;set;}
    public map<Integer,TQT_Wrapper> mapDisplayTQTExisting {get;set;}
    public list<Integer> ListDisplayTeamKeys{get;set;}
    public list<Integer> listDisplayTQTKeys{get;set;}
    public list<ProjectRole__c> lstProjectRoles {get;set;}
        
    /*Constructor*/
    public ECO_DeliverableADDTQReviewersController(ApexPages.StandardController stdController) {
        
        bDeliverablePassedIn = true;
        
        oDeliverable = (Deliverable__c)stdController.getRecord();
        
        oDeliverable = ECO_Service_Deliverable.getDeliverable(new set<String>{oDeliverable.id})[0];

        if(oDeliverable == null){
            ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.WARNING,'You have reached this page improperly, please access it from the Deliverables screen.');
            ApexPages.addMessage(oPageMessage);
        }else{
            loadValues();
        }

        lstProjectRoles = [select id, name, definition__c from ProjectRole__c where Active__c = true order by name ASC];
    }
    
    /**
     * To fetch Project Team Member data and Technical Quality Team data on load of page
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   
     * @return  
     **/
    private void loadValues(){
        set<id> setUsersInTQT = new set<id>();
        //first load Technical quailtiy team
        integer iRow = 1;
        mapDisplayTQTExisting = new map<Integer,TQT_Wrapper>();
        mapDisplayTeamAvailable = new map<Integer,Project_TeamWrapper>();
        ListDisplayTeamKeys = new list<Integer>();
        listDisplayTQTKeys = new list<Integer>();

        //Get the list of existing Technical Quality Team for this deliverable
        for(TechnicalQualityTeam__c oTQT: getTQTFromDeliverableIDs(new set<String>{oDeliverable.id})){
            //System.Debug(logginglevel.error,'oTQT ' + oTQT);
            mapDisplayTQTExisting.put(iRow,new TQT_Wrapper(oTQT));
            setUsersInTQT.add(oTQT.TechnicalQualityTeamMember__c);
            listDisplayTQTKeys.add(iRow);
            iRow ++;
        }
       
        iRow = 1;
        boolean bExists = false;
        //Get list of Project Team Members for this project
        for(ProjectTeamMember__c oPTM: getProjectTeamByProjectID(new set<String>{oDeliverable.Project__c})){
            //System.Debug(logginglevel.error,'oPtm.user__r.Name ' + oPtm);
            if(setUsersInTQT == null || !setUsersInTQT.contains(oPTM.Contact__r.pse__Salesforce_User__c)){ //|| oPTM.ProjectRole__r.Name == 'Deliverable Originator' ){
                if(oPTM.ProjectRole__r.Name == 'Deliverable Originator' && oDeliverable.DeliverablesOwner__c != oPTM.Contact__c)
                    bExists = true;
                else
                    bExists = false;
            }
            else{
                bExists = true;
            }
            //System.Debug(logginglevel.error,'bExists: ' + bExists + ' ' + oPTM);
            mapDisplayTeamAvailable.put(iRow,new Project_TeamWrapper(oPTM,bExists));
            if(!bExists){
                ListDisplayTeamKeys.add(iRow);
            }
            iRow++;
        }
        //System.Debug(logginglevel.error,'ListDisplayTeamKeys: ' + ListDisplayTeamKeys);
        //System.Debug(logginglevel.error,'mapDisplayTeamAvailable: ' + mapDisplayTeamAvailable);
    }

    /**
     * To refresh Project Team Member after a Member is selected from here
     * and added to Technical Quality Team
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   
     * @return  
     **/
    public void resetRowNumberDisplay(){
       list<Integer> lRows = new list<Integer>(mapDisplayTQTExisting.keyset());
       lRows.Sort();
       Integer iNewRow = 1;
       map<Integer,TQT_Wrapper> mapTemp = new map<Integer,TQT_Wrapper>();
       for(Integer iRow: lRows){
           mapTemp.put(iNewRow,mapDisplayTQTExisting.get(iRow));
           iNewRow ++;
       }
       mapDisplayTQTExisting.clear();
       for(Integer iRow: mapTemp.keySet()){
         mapDisplayTQTExisting.put(iRow,mapTemp.get(iRow));
       }
    }

    /**
     * To create a new Technical Quality Team member
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   
     * @return  
     **/
    public void addNewMemberNotInTeam(){
       resetRowNumberDisplay();
       
       set<Integer> setRows = mapDisplayTQTExisting.keyset();
       //System.Debug(logginglevel.error,'setRows: ' + setRows);
       Integer iRow = setRows.size() + 1;

       TechnicalQualityTeam__c oTQTMember = new TechnicalQualityTeam__c(
                                                     Deliverable__c = oDeliverable.id);
        TQT_Wrapper oTQTWrapper = new TQT_Wrapper(oTQTMember);
        mapDisplayTQTExisting.put(iRow,oTQTWrapper);
    }

    /**
     * To add an existing Project Team Member as Technical Quality Team Member
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   
     * @return  
     **/
    public void moveMembersDown(){
       set<Integer> setRows = mapDisplayTQTExisting.keyset();
       Integer iRow = setRows.size() + 1;
       set<Integer> setRowsToRemove = new set<Integer>();

       for(Integer iDisplayRow: mapDisplayTeamAvailable.Keyset()){
            Project_TeamWrapper PTW = mapDisplayTeamAvailable.get(iDisplayRow);
            //System.Debug(logginglevel.error,'Selected: ' + PTW.bSelected);
            if(PTW.bSelected){
                PTW.bSelected = false;
                setRowsToRemove.add(iDisplayRow);
                PTW.bAlreadyTeamMember = true;
                //To get a role for the new Technical Quality Team member
                String sRole = ECO_Service_Deliverable.getTQTRoleFromProjectRole(PTW.oProjectTeamMember.ProjectRole__r.Name);
                
                if(!isRoleValidForTechTeam(sRole)){
                    sRole = '';
                }
                  
                TechnicalQualityTeam__c oTQTMember = new TechnicalQualityTeam__c(
                                                         Deliverable__c = oDeliverable.id,
                                                         TechnicalQualityTeamMember__c = PTW.oProjectTeamMember.Contact__r.pse__Salesforce_User__c,
                                                         Role__c = sRole);
                TQT_Wrapper oTQTWrapper = new TQT_Wrapper(oTQTMember);
                oTQTWrapper.oPTM = PTW.oProjectTeamMember;
                oTQTWrapper.sUserName = PTW.oProjectTeamMember.Contact__r.Name;
                mapDisplayTQTExisting.put(iRow,oTQTWrapper);
                iRow ++;
          }
       }

       if(setRowsToRemove != null && setRowsToRemove.size() > 0){
        list<Integer> lTemp = new list<Integer>();
        for(Integer i: ListDisplayTeamKeys){
            if(setRowsToRemove.contains(i)){
                continue;
            }else{
                lTemp.add(i);
            }
        }
        ListDisplayTeamKeys.clear();
        ListDisplayTeamKeys.addAll(lTemp);
       }
        
    }

    /**
     * To remove selected team member from the list
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   
     * @return  
     **/
    public void removeSelectedMembers(){
        set<id> setRedisplaymembers = new set<id>();
        for(Integer iRow : mapDisplayTQTExisting.keyset()){
            TQT_Wrapper oTQTW = mapDisplayTQTExisting.get(iRow);
            if(oTQTW.bSelected){
                if(oTQTW.oPTM == null){ //means existing project team record
                    setRedisplaymembers.add(oTQTW.oTechnicalQualityTeam.TechnicalQualityTeamMember__c);
                }
                mapDisplayTQTExisting.remove(iRow);
                try{
                    delete oTQTW.oTechnicalQualityTeam;
                }catch(Exception e){
                    ApexPages.addMessages(e);
                }
                
            }
        }

        for(Integer iRow : mapDisplayTeamAvailable.keyset()){
            Project_TeamWrapper oPTW = mapDisplayTeamAvailable.get(iRow);
            if(setRedisplaymembers.Contains(oPTW.oProjectTeamMember.Contact__r.pse__Salesforce_User__c)){
                ListDisplayTeamKeys.add(iRow);
            }
        }
        ListDisplayTeamKeys.sort();
    }

    /**
     * To undo changes done on the page
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   value
     * @return  value
     **/
    public pageReference cancel(){
        pageReference pr = new pageReference('/'+oDeliverable.id);
        pr.setredirect(true);
        return pr;
    }

    /**
     * To save and continue working on the Deliverable record
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   value
     * @return  value
     **/
    public pageReference saveandContiue(){
        pageReference pr = new pageReference('/'+oDeliverable.id);
        pr.setredirect(true);
        saveChanges();
        return pr;
    }

    /**
     * To save all the changes made to Technical Quality Team
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   value
     * @return  value
     **/
    public void saveChanges(){
        if(!checkForErrors()){
            //first look for members to add and build those records before changing anything
            list<ProjectTeamMember__c> lInsertTeamMembers = addMemberToProjectTeam();
            //now build the TQT's to insert
            list<TechnicalQualityTeam__c> lUpdatesInserts = prepareTeamForSave();

            if(lUpdatesInserts != null && lUpdatesInserts.size() > 0){
                System.savePoint sp = Database.setSavePoint();
                try{
                    upsert lUpdatesInserts;
                    insert lInsertTeamMembers;
                    loadValues();

                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Save Successful.'));
                }catch(Exception e){
                    system.debug('Handling Exception:  '+e.getMessage());
                    Database.rollBack(sp);
                    ApexPages.addMessages(e);
                }
            }
            
        }else{
            ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.Error,'Please enter all required information for the highlighted rows.');
            ApexPages.addMessage(oPageMessage);
        }

    }

    /**
     * To check for all sort of validation errors and display on page
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   
     * @return  Boolean - True if and exists and False if nothing is wrong
     **/
    public boolean checkForErrors(){
        boolean bReturn = false;
        for(TQT_Wrapper oTQTW: mapDisplayTQTExisting.Values()){
            if(oTQTW.oTechnicalQualityTeam.Role__c == null || oTQTW.oTechnicalQualityTeam.Role__c == ''){
                oTQTW.bHasError = true;
                bReturn = true;
            }
            if(oTQTW.oTechnicalQualityTeam.TechnicalQualityTeamMember__c == null){
                if(oTQTW.oPTM.Contact__c == null){
                    oTQTW.bHasError = true;
                }
            }
        }

        return bReturn;
    }

    /**
     * To populate all the necessary fields and prepare the record for save
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   
     * @return  List of Technical Quality Team Members with valid data
     **/
    public list<TechnicalQualityTeam__c> prepareTeamForSave(){

        list<TechnicalQualityTeam__c> lReturn = new list<TechnicalQualityTeam__c>();
        set<id> setContactID = new set<id>();
        map<id,Contact> mapContacts = new map<id,Contact>();
        
        for(Integer iRow : mapDisplayTQTExisting.keyset()){
            TQT_Wrapper oTempTQTW = mapDisplayTQTExisting.get(iRow);
            if(oTempTQTW.oPTM.Contact__c != null && oTempTQTW.oTechnicalQualityTeam.TechnicalQualityTeamMember__c == null){
                setContactID.add(oTempTQTW.oPTM.Contact__c);
            }

        }
        
        if(setContactID != null && setContactID.size() > 0){
            mapContacts = getUserByContact(setContactID);
        }
        
        for(TQT_Wrapper oTQTW: mapDisplayTQTExisting.Values()){
            if(oTQTW.oTechnicalQualityTeam != null 
               && oTQTW.oTechnicalQualityTeam.TechnicalQualityTeamMember__c == null 
               && mapContacts != null
               && mapContacts.get(oTQTW.oPTM.Contact__c) != null
               && mapContacts.get(oTQTW.oPTM.Contact__c).pse__Salesforce_User__c != null){
                   
                   oTQTW.oTechnicalQualityTeam.TechnicalQualityTeamMember__c = mapContacts.get(oTQTW.oPTM.Contact__c).pse__Salesforce_User__c;
            }
            lReturn.add(oTQTW.oTechnicalQualityTeam);
                
        }

        return lReturn;
    }
    
    /**
     * To get list of all Technical Quality Team Members from all Deliverable of this project.
     * TODO: Can be added to a utility class or seperate class 
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   value
     * @return  value
     **/
    public list<TechnicalQualityTeam__c> getTQTFromDeliverableIDs(set<String> setID){
        return[Select id
                        , ApprovalNeeded__c
                        , Deliverable__c
                        , RequiredDate__c
                        , Role__c
                        , Status__c
                        , Submit_For_Approval__c
                        , TechnicalQualityTeamMember__c
                        , TechnicalQualityTeamMember__r.Name
                        From TechnicalQualityTeam__c 
                        where Deliverable__c =: setID 
                        AND Role__c <> 'Inactive Deliverable Owner'];
                        //AND Role__c <> 'Deliverable Originator']; //6512
    }
    
    /**
     * To get list of applicable roles for Technical Quality Team
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   
     * @return  List of roles
     **/
    public List<SelectOption> getTQTRoles(){
        List<SelectOption> roles = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = TechnicalQualityTeam__c.Role__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple)
        {   
            //Deliverable Originator is already created so don't display
            //Inactive Deliverable Owner is not a valid role to create new TQT
            if(//f.getValue() != 'Deliverable Originator' &&  //6512
                f.getValue() != 'Inactive Deliverable Owner' && 
                f.getValue() != 'Owner'){
                roles.add(new SelectOption(f.getValue(), f.getLabel()));
            }
        } 
        return roles;           
    }
    
    /**
     * To get all Project Team Members for this Deliverables Project
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   
     * @return  List of Project Team Members
     **/
    public list<ProjectTeamMember__c> getProjectTeamByProjectID(set<String>setID){
        return [Select id
                         , Contact__c
                         , Contact__r.Name
                         , Contact__r.pse__Salesforce_User__c
                         , ProjectRole__c
                         , ProjectRole__r.Name
                         , User__c
                         , User__r.Name
                         , Role__c 
                         , Active__c
                From ProjectTeamMember__c where Project__c =: setID and (EndDate__c = null or EndDate__c > TODAY) and ProjectRoleName__c <> 'Project Owner'];
                //need to find out the difference between Active__c and Is_Active__c
                //will need to use one of those to only get active members.
    }

    /**
     * To validate of selected Project Team role is valid for Technical Quality Team
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   String: Role picked from Project Team record
     * @return  True if valid, False if invalid
     **/
    private boolean isRoleValidForTechTeam(String sRole){
        boolean bReturn = false;
        for(SelectOption SO: ECO_Service_Deliverable.getTechTeamRoles()){
            if(SO.getLabel() == sRole){
                bReturn = true;
                break;
            }
        }

        return bReturn;
    }

    /**
     * To get user ids for the contacts
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   Set of contact ids which need User Ids
     * @return  Map of contacts with user ids
     **/
    private map<id,Contact> getUserByContact(set<id> setContacts){
        return new map<id,Contact>([Select id
                                             , pse__Salesforce_User__c
                                    from Contact
                                    Where id =: setContacts]);
    }

    /**
     * To create Project Team Member records for respective Technical Quality Team record
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   
     * @return  List of Project Team Member records with all data populated
     **/
    private list<ProjectTeamMember__c> addMemberToProjectTeam(){
        list<ProjectTeamMember__c> lAddMembers = new list<ProjectTeamMember__c>();
        map<String,ProjectTeamMember__c> mPTM = new map<String, ProjectTeamMember__c>();

        //To get a map of all Project Team Members and use this to avoid adding duplicate team members
        for(ProjectTeamMember__c ptm : getProjectTeamByProjectID(new set<String>{oDeliverable.Project__c})){
            mPTM.put(ptm.ProjectRole__c+'-'+ptm.Contact__c, ptm);
        }
        
        for(TQT_Wrapper oTQT: mapDisplayTQTExisting.Values()){
            String roleName = ECO_Service_Deliverable.getProjectTeamRoleFromTQTRole(oTQT.oTechnicalQualityTeam);
            if(oTQT.bNewRecord && !mPTM.containskey(roleName+'-'+oTQT.oPTM.Contact__c) && oTQT.oPTM.Contact__c != null){ //&& roleName != 'Project Manager'){
                lAddMembers.add(new ProjectTeamMember__c(Contact__c = oTQT.oPTM.Contact__c,
                                                         Project__c = oDeliverable.Project__c,
                                                         ProjectRole__c = roleName,
                                                         RecordTypeID = ECO_Utils_Meta.getRecordTypeId(ProjectTeamMember__c.sObjectType,'TeamMember')));
            }
        }
        return lAddMembers;
    }

       
    public class Project_TeamWrapper{
        public boolean bAlreadyTeamMember {get;set;}
        public ProjectTeamMember__c oProjectTeamMember{get;set;}
        public boolean bSelected {get;set;}
        public boolean bCanBeUser {get;set;}
        public string approvalMessage {get;set;}
        public Project_TeamWrapper(ProjectTeamMember__c oProjectTeamMember, boolean bAlreadyTeamMember){
            bSelected = false;
            bCanBeUser = false;
            this.oProjectTeamMember = oProjectTeamMember;
            this.bAlreadyTeamMember = bAlreadyTeamMember;

            if(oProjectTeamMember.Active__c){
                if(oProjectTeamMember.Contact__r.pse__Salesforce_User__c != null){ 
                    bCanBeUser = true;
                } else {
                    approvalMessage = 'User does not have a Salesforce license';
                }                
            } else {
                approvalMessage = 'Team Member is not currently active on the project';
            }



            
        }

    }
	
    @TestVisible
    public class TQT_Wrapper{
        public boolean bSelected {get;set;}
        public TechnicalQualityTeam__c oTechnicalQualityTeam {get;set;}
        public boolean bNewRecord{get;set;}
        public ProjectTeamMember__c oPTM{get;set;}
        public String sUserName {get;set;}
        public boolean bHasError{get;set;}
        
        public TQT_Wrapper(TechnicalQualityTeam__c oTeam){
            bSelected = false;
            bHasError = false;
            
            oTechnicalQualityTeam = oTeam;
            if(oTeam.Id == null){
                bNewRecord = true;
                /*if(oTeam.TechnicalQualityTeamMember__c == null){
                    oPTM = new ProjectTeamMember__c();

                }*/
            }else{
                sUserName = oTeam.TechnicalQualityTeamMember__r.Name;
                bNewRecord = false;
            }

            if(oTeam.TechnicalQualityTeamMember__c == null){
                oPTM = new ProjectTeamMember__c();

            }
        }
    }
}