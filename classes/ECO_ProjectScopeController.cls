/** ------------------------------------------------------------------------------------------------------
* @Description To provide extended controller capabilities for the Project Scope Page
*
* @Author      NTT Data - Tim Chiang
* @Date        30/01/2015
*-----------------------------------------------------------------------------------------------------*/

public virtual with sharing class ECO_ProjectScopeController extends ECO_PageControllerBase { 
    public String errorLevel {get; set;}
    public String messageName {get; set;}
    
    private final Packages__c oPackage;
    public integer packageCount;
    public boolean scrolltobottom {get;set;}
    public Packages__c oProjectPackage {get;set;}
    public list<Packages__c> lstPackages {get;set;}
    public list<Risk__c> lstRisk {get;set;}
    public list<Deliverable__c> lstSearchDeliverables {get;set;}
    public list<DeliverableWrapper> lstAssignedDeliverables {get;set;}
    public map<string, list<DeliverableWrapper>> lstMapAssignedDeliverables {get;set;}
    public map<string, boolean> MapRenderAssigned{get;set;} 
    public map<string, list<DeliverableWrapper>> lstMapUnassignedDeliverables {get;set;}
    public list<DeliverableWrapper> lstUnAssignedDeliverables {get;set;}
    public List<SelectOption> lstScopeOptions {get;set;}
    public final Id sProjectId {get; set;}
    public string sSelectedPackageId {get; set;}
    public string sSelectedPackageName {get; set;}
    public boolean booNewProjectInPlay {get;set;}
    public string UtilizeBMI {get;set;}
    public string ProjectQualityAudit {get;set;}
    public string SafetyInDesign {get;set;}
    public pse__Proj__c theProject {get; set;}

    public integer selectedTab {get;set;}
    public Id AttachmentId{get;set;}

    /**
     * Leverages parent project information to determine and pull all sibling packages
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    30/01/2015
     *
     * @param   
     * @return  
     **/
    private void SearchPackages(){

        lstPackages = new list<Packages__c>();
        lstScopeOptions = new list<SelectOption>();

        // Obtain all sibling packages related to the package in the standard controller
        list<Packages__c> lstSearchPackages = [SELECT ID
                                                    , Name
                                                    , Type__c
                                                    , Scope_Approach__c
                                                    , Scope_Details__c
                                                    , Scope__c
                                                    , PackageTitle__c
                                                    ,  Scope_Owner__c
                                                    , Utilize_BMI_Technology__c
                                                    , SafetyInDesign__c
                                                    , Safety_In_Design_Description__c
                                                    , ProjectQualityAudit__c
                                                    , Status__c
                                                    , CancelledReason__c
                                                    , (SELECT Id, Name, ContentType FROM Attachments) 
                                               FROM Packages__c 
                                               WHERE Scope__c = :sProjectId];
                                               //ORDER BY Name ASC];

        if  (lstSearchPackages.size() > 0)  {

            // Sort out and find the package with type = "project". Separate the rest
            for (Packages__c oSearchPackage: lstSearchPackages) {

                if  (oSearchPackage.Type__c.trim() == 'Project') {
                    if(lstScopeOptions.isEmpty()){
                        lstScopeOptions.add(new SelectOption(oSearchPackage.id, oSearchPackage.PackageTitle__c));
                    } else {
                        lstScopeOptions.add(0,new SelectOption(oSearchPackage.id, oSearchPackage.PackageTitle__c));
                    }
                    
                    oProjectPackage = oSearchPackage;
                    
                    //System.debug( ' oProjectPackage BIM ' + oProjectPackage.Utilize_BMI_Technology__c );
                    
                    if( oProjectPackage.Utilize_BMI_Technology__c == true )
                    {
                        UtilizeBMI = 'true';
                    }
                    else
                    if( oProjectPackage.Utilize_BMI_Technology__c == false )
                    {
                        UtilizeBMI = 'false';
                    } 
                    else
                    {
                        UtilizeBMI = 'null';
                    } 
                    
                    //System.debug( 'UtilizeBMI ' + UtilizeBMI );

                    if( oProjectPackage.ProjectQualityAudit__c == true )
                    {
                        ProjectQualityAudit = 'true';
                    }
                    else
                    if( oProjectPackage.ProjectQualityAudit__c == false )
                    {
                        ProjectQualityAudit = 'false';
                    } 
                    else
                    {
                        ProjectQualityAudit = 'null';
                    } 

                    if( oProjectPackage.SafetyInDesign__c == true )
                    {
                        SafetyInDesign = 'true';
                    }
                    else
                    if( oProjectPackage.SafetyInDesign__c == false )
                    {
                        SafetyInDesign = 'false';
                    } 
                    else
                    {
                        SafetyInDesign = 'null';
                    } 
                    
                } else {
                    lstPackages.add(oSearchPackage);
                    lstScopeOptions.add(new SelectOption(oSearchPackage.id, oSearchPackage.PackageTitle__c));
                }

            }


        }else{
            // If the project is new treat it as the new "Project Scope".
            oProjectPackage = new Packages__c();
            oProjectPackage.Scope__c = sProjectId;
            oProjectPackage.PackageTitle__c = 'Project Scope';
            oProjectPackage.Type__c = 'Project';
            
            UtilizeBMI = '';
            ProjectQualityAudit = '';
            SafetyInDesign = '';
        }
    }
    
    /**
     * 
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    30/01/2015
     *
     * @param   
     * @return  PageReference
     **/
    public PageReference DeleteSelectedScope()
    {
        //System.debug('BrentBrentBrent' + sSelectedPackageId);

        list<Packages__c> scope = [select Id from Packages__c where Id = :sSelectedPackageId];
        
        if(scope.size() > 0)
            delete scope;
        
        PageReference newpage = Page.ECO_ProjectScope;
        newpage.getParameters().put('projectId',sProjectId); 
        newpage.setRedirect(true);

        return newpage;
    }

    /**
     * 
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    30/01/2015
     *
     * @param   
     * @return  
     **/
    private void SearchDeliverables(){

        lstMapAssignedDeliverables = new map<string, list<DeliverableWrapper>>();
        lstMapUnassignedDeliverables = new map<string, list<DeliverableWrapper>>();

        for(Packages__c p:lstPackages){
            lstMapAssignedDeliverables.put(p.id, new list<DeliverableWrapper>());
            lstMapUnassignedDeliverables.put(p.id, new list<DeliverableWrapper>());
        }


        lstSearchDeliverables = [SELECT ID, Name, Project_Scope__c, Status__c, Description__c, DeliverableType__c, DueDate__c FROM Deliverable__c WHERE Project__c = :sProjectId];
        lstMapAssignedDeliverables.put(oProjectPackage.id, new list<DeliverableWrapper>());

        if (lstSearchDeliverables.size() > 0)  {
            for(Deliverable__c d: lstSearchDeliverables){
                if(d.Project_Scope__c == null|| d.Project_Scope__c == oProjectPackage.id){

                    for(Packages__c p :lstPackages){
                        lstMapUnassignedDeliverables.get(p.id).add(new DeliverableWrapper(d, lstScopeOptions));
                    }

                    lstMapAssignedDeliverables.get(oProjectPackage.id).add(new DeliverableWrapper(d, lstScopeOptions));                    


                } else {
                    if(lstMapAssignedDeliverables.containskey(d.Project_Scope__c)){

                    } else {
                        lstMapAssignedDeliverables.put(d.Project_Scope__c, new list<DeliverableWrapper>());
                    }

                    lstMapAssignedDeliverables.get(d.Project_Scope__c).add(new DeliverableWrapper(d, lstScopeOptions));

                    //lstassignedDeliverables.add(new DeliverableWrapper(d, lstScopeOptions));
                }
            }
        }        

        // need to create a list of rendered assignment because we cannot use a variable in VF to reliably replicate this functionality
        MapRenderAssigned = new map<string, boolean>();

        for(string key: lstMapAssignedDeliverables.keySet()){

            if(lstMapAssignedDeliverables.get(key).size() > 0){
                 MapRenderAssigned.put( key, true );
            } else {
                MapRenderAssigned.put( key, false );
            }
        }

    }

    /**
     * 
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    30/01/2015
     *
     * @param   
     * @return  PageReference
     **/
    public PageReference AddSelectedDeliverables(){

        //System.debug('DEBUG ***: ' + sSelectedPackageId);

        //list<DeliverableWrapper> tmpLstUnAssignedDeliverables = new list<DeliverableWrapper>();

        for(DeliverableWrapper d: lstMapUnassignedDeliverables.get(sSelectedPackageId)){

            //System.debug('DEBUG 2 ***: ' + d.oDeliverable.id + ' ' + d.booSelected);

            if(d.booSelected == true){
                //lstassignedDeliverables.add(d);
                
                d.oDeliverable.Project_Scope__c = sSelectedPackageId;

                /*if(lstMapAssignedDeliverables.containskey(sSelectedPackageId)){

                } else {
                    lstMapAssignedDeliverables.put(sSelectedPackageId, new list<DeliverableWrapper>());
                }

                lstMapAssignedDeliverables.get(sSelectedPackageId).add(d);*/


            } else {
               /* tmpLstUnAssignedDeliverables.add(d);*/
            }
        }
        //System.debug('DEBUG END ***: ');
        //lstUnAssignedDeliverables = tmpLstUnAssignedDeliverables;

        scrolltobottom = false;

        SaveDeliverables();
       // SearchDeliverables();

        PageReference newpage = Page.ECO_ProjectScope;
        newpage.getParameters().put('projectId',sProjectId); 
        newpage.setRedirect(true);

        return newpage;
    }

    /**
     * 
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    30/01/2015
     *
     * @param   
     * @return  PageReference
     **/
     public PageReference AttachFile(){
         
         list<Packages__c> lstPackagesToInsert = new list<Packages__c>();
         lstPackagesToInsert.addAll(lstPackages);
         lstPackagesToInsert.add(oProjectPackage);
         
         //System.debug( 'lstPackagesToInsert ' + lstPackagesToInsert );

         for (Packages__c p: lstPackagesToInsert) {
             if(p.id == null){
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please save all packages before attaching a file'));
                 return null;
             }
         }  
         
         //System.debug( 'sSelectedPackageId ' + sSelectedPackageId );
         
        SavePackages();
        scrolltobottom = false;
        return new PageReference('/p/attach/NoteAttach?pid=' + sSelectedPackageId + '&parentname=' + sSelectedPackageName + '&retURL=%2Fapex%2FECO_ProjectScope?projectId='+ sProjectId);
    }


    /**
     * 
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    30/01/2015
     *
     * @param   
     * @return  PageReference
     **/
    public PageReference deleteAttachment(){
        Attachment[] attach = [Select Id From Attachment where Id = :AttachmentId];
        delete attach;
        SearchPackages();

        return null;
    }

    /**
     * Leverages parent project information to determine and pull all related risk
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    30/01/2015
     *
     * @param   
     * @return  
     **/
    private void SearchRisk(){

        string strSOQL = 'SELECT ';
            
        for (Schema.FieldSetMember fsmField: SObjectType.Risk__c.FieldSets.RiskFlyoutDisplayFields.getFields()) {
            strSOQL += fsmField.getFieldPath() + ', ';
        }
        
        strSOQL += 'ID, PlanElement__c FROM Risk__c WHERE Project__c =\'' + sProjectId + '\' and PlanElement__c = \'Scope\' ORDER BY PlanElement__c';

        lstRisk = (list<Risk__c>)Database.query(strSOQL);
    }

    /**
     * Default Constructor
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    30/01/2015
     *
     * @param   
     * @return  
     **/
    public ECO_ProjectScopeController() {
        this(ApexPages.currentPage().getParameters().get('projectId'));
    }
    
    /**
     * Constructor - refactored by Sujit to support doc gen code reuse
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    30/01/2015
     *
     * @param   sProjectId
     * @return  
     **/
    public ECO_ProjectScopeController(Id sProjectId) {
        this.sProjectId = sProjectId;

        if (ECO_Utils_String.NullCheck(sProjectId) == '') {
            ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.WARNING,'You have reached this page improperly, please access it from the Project Control Center screen.');
            ApexPages.addMessage(oPageMessage);
            return;
        }
        theProject = [select Id, Name, ProjectSectionHeaderName__c, pse__Stage__c, pse__Project_ID__c, ProjectNumber__c from pse__Proj__c where Id = :sProjectId limit 1];
 
        scrolltobottom = false;
        lstPackages = new list<Packages__c>();
        lstRisk = new list<Risk__c>();
        //lstAssignedDeliverables = new list<DeliverableWrapper>();
        lstMapAssignedDeliverables = new map<string, list<DeliverableWrapper>>();
        lstMapUnassignedDeliverables = new map<string, list<DeliverableWrapper>>();
        //lstUnassignedDeliverables = new list<DeliverableWrapper>();
        lstScopeOptions = new list<SelectOption>();
        booNewProjectInPlay = false;          

        SearchPackages();
        SearchRisk();
        SearchDeliverables();
        //SaveFirstPackages() ;
        
        //update oProjectPackage;
        //

    }

    /**
     * Method to handle adding new packages to the project 
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    30/01/2015
     *
     * @param   
     * @return  PageReference
     **/
    Public PageReference AddScopePackage() {

        Packages__c oNewPackage = new Packages__c();
        oNewPackage.Type__c = 'Package';
        oNewPackage.Scope__c = sProjectId;
        oNewPackage.Name = 'New Package';
        oNewPackage.PackageTitle__c = 'New Package';

        lstPackages.add(oNewPackage);

        scrolltobottom = true;
        booNewProjectInPlay = true;

        selectedTab = lstPackages.size();
        
        SavePackages() ;

        return null;
    }
    
    /**
     * Bulk saves all packages
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    30/01/2015
     *
     * @param   
     * @return  PageReference
     **/
    Public PageReference SavePackages() {
        //return null;

        boolean canSave = true;

        if(UtilizeBMI == null || ProjectQualityAudit == null || SafetyInDesign == null){
            if(UtilizeBMI == null){
                ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please answer BIM');
                ApexPages.addMessage(oMsg);         
        }

            if(ProjectQualityAudit == null){
                ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please answer Project Quality Audit');
                ApexPages.addMessage(oMsg); 
        }  

            if(SafetyInDesign == null){
                ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please answer Safety In Design');
                ApexPages.addMessage(oMsg); 
        } 
            return null;          
        }


        checkBIMChoice();
        checkPQAChoice();
        checkSIDChoice();


        list<Packages__c> lstPackagesToInsert = new list<Packages__c>();
        //System.debug('SavePackages ' + UtilizeBMI );
                
        lstPackagesToInsert.addAll(lstPackages);
        lstPackagesToInsert.add(oProjectPackage);

        boolean bExit = false;

        for(Packages__c p:lstPackagesToInsert){
            

            if(p.Status__c == 'Cancelled' && theProject.pse__Stage__c != 'Execution'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The package, ' + p.name  + ', cannot be cancelled unless the project is in the "Execution" stage.')); 
                bExit = true;            
            }
        }

        if(bExit){
            return null;
        }
        
        for(Packages__c p:lstPackagesToInsert){

            if(p.Status__c == 'Cancelled' && theProject.pse__Stage__c == 'Execution' && (p.CancelledReason__c == null || p.CancelledReason__c == '')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The package, ' + p.name  + ', must have a cancel reason filled out.'));
                bExit = true;            
            }
        }

        if(bExit){
            return null;
        }

        try {
            upsert lstPackagesToInsert;
            SearchPackages();
            //SearchDeliverables();
            SaveDeliverables();
            booNewProjectInPlay = false;
            
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attmpting to save packages: ' + e));
            return null;
        }        

        scrolltobottom = false;


        return null;
    }

    /**
     * 
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    30/01/2015
     *
     * @param   
     * @return  PageReference
     **/
    public PageReference Cancel(){
        return new PageReference('/' + sProjectId);
    }

    /**
     * 
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    30/01/2015
     *
     * @param   
     * @return  PageReference
     **/
    Public PageReference SaveDeliverables() {
        try {
            //System.debug(lstScopeOptions );
            //System.debug(lstSearchDeliverables);

            update lstSearchDeliverables;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Save Successful.'));

        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attmpting to save deliverables: ' + e));
            return null;
        }     

        SearchDeliverables();

        scrolltobottom = false;

        return null;
    }

    /*public PageReference CancelDeliverables(){
        SearchDeliverables();
        return null;
    }*/

/** ------------------------------------------------------------------------------------------------------
* @Description
*
* @Author      NTT Data - Tim Chiang
* @Date        30/01/2015
*-----------------------------------------------------------------------------------------------------*/
    public class DeliverableWrapper{
        public boolean booSelected {get;set;}
        public Deliverable__c oDeliverable {get;set;}
        public List<SelectOption> lstScopeOptions {get;set;}

        public DeliverableWrapper(Deliverable__c oDeliverable, List<SelectOption> lstScopeOptions){

            booSelected = false;

            /*if(oDeliverable.Project_Scope__c == null){
                booSelected = false;
            } else {
                booSelected = true;
            }*/

            this.oDeliverable = oDeliverable;
        }

        
    }
    
    /**
     * 
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    30/01/2015
     *
     * @param   
     * @return  List<SelectOption>
     **/
    public List<SelectOption> getYesNo() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('true','Yes')); 
        options.add(new SelectOption('false','No')); 
        return options; 
    } 
    
    /**
     * 
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    30/01/2015
     *
     * @param   
     * @return  PageReference
     **/
    public PageReference checkBIMChoice() {

        //System.debug( 'checkBIMChoice getYesNo => ' + UtilizeBMI );
        
        if( UtilizeBMI == 'true' )       
            oProjectPackage.Utilize_BMI_Technology__c = true;
        else
        if( UtilizeBMI == 'false' )       
            oProjectPackage.Utilize_BMI_Technology__c = false;
        
        return null;
    }  

    /**
     * 
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    30/01/2015
     *
     * @param   
     * @return  PageReference
     **/
    public PageReference checkPQAChoice() {

        //System.debug( 'checkPQAChoice getYesNo => ' + ProjectQualityAudit );
        
        if( ProjectQualityAudit == 'true' )       
            oProjectPackage.ProjectQualityAudit__c = true;
        else
        if( ProjectQualityAudit == 'false' )       
            oProjectPackage.ProjectQualityAudit__c = false;
        
        return null;
    }    

    /**
     * 
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    30/01/2015
     *
     * @param   
     * @return  PageReference
     **/
    public PageReference checkSIDChoice() {

        //System.debug( 'checkSIDChoice getYesNo => ' + SafetyInDesign );
        
        if( SafetyInDesign == 'true' )       
            oProjectPackage.SafetyInDesign__c = true;
        else
        if( SafetyInDesign == 'false' )       
            oProjectPackage.SafetyInDesign__c = false;
        
        return null;
    }    
    
    /**
     * 
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    30/01/2015
     *
     * @param   
     * @return  List<SelectOption>
     **/
    public List<SelectOption> getYesNoBIM() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('true','Yes')); 
        options.add(new SelectOption('false','No')); 
        //options.add(new SelectOption('null','')); 

        //SelectOption op = new SelectOption('false','No');        
        //op.        

        return options; 
    }     
}