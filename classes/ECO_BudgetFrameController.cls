/** ------------------------------------------------------------------------------------------------------
 *  @Description
 * 
 * @Author      NTT Data 
 * @Date        August 2016
 *-----------------------------------------------------------------------------------------------------*/
public class ECO_BudgetFrameController extends ECO_Financial_Security{
    public Id sProjectId {get; set;}
    public Id sBudgetHeaderId {get; set;}

    public String recordTypeName {get; set;}
    public Boolean isAccessible {get; set;}

/*
    public Boolean evFlyoutTesting {
        get {
            String testing = ApexPages.currentPage().getParameters().get('evtest');

            if (testing == null)
                return true;

            return Boolean.valueOf(testing);
        }
    }
*/    
    
    public boolean bAllowHeaderNavigation {
        get{
            if(sBudgetHeaderId == null){
                return false;
            }
            
            return true;
        }
        
        private set;
    }
    
    public boolean bHasBudgetHeader {
        get{ 
            if(sBudgetHeaderId == null){
                return false;
            }

            return true;
        }

        private set;
    }

/**
    * constructor
    *
    * @Author
    * @Date 
    *
    * @param none
    * @return none
    **/
    public ECO_BudgetFrameController(){
        Id sRecordId = (Id)ApexPages.currentPage().getParameters().get('Id');

//        if (evFlyoutTesting) {
            Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=10; IE=9; IE=8; IE=7; IE=EDGE');
//        }
        
        if(sRecordId == null){
            //Handle
            
            return;
        }
        
        String sObjName = sRecordId.getSObjectType().getDescribe().getName();

        if(sObjName == 'pse__Proj__c'){
            sProjectId = sRecordId;
            sBudgetHeaderId = null;
        }else if(sObjName == 'BudgetHeader__c'){
            sProjectId = ECO_Service_Projects.getProjectIdByBudgetHeader(sRecordId);
            sBudgetHeaderId = sRecordId;
            recordTypeName = [SELECT Id, RecordType.DeveloperName FROM BudgetHeader__c Where Id = :sBudgetHeaderId].RecordType.DeveloperName;
        }

        //US-06776, check the Security Matrix to see if the current user has access, if not then disable the "Create" drop down
        isAccessible = ECO_Service_RecordAccess.getRecordAccess(sProjectId, 'BudgetHeader__c');

    }

/**
    * 
    * 
    * @Author  NTT Data - 
    * @Date 
    *
    * @param sProjectId
    * @param action
    * @return PageReference
    **/
    public PageReference doAction(Id sProjectId, String action) {
        PageReference oPageReference = Page.ECO_BudgetEACLoading;
        oPageReference.setRedirect(true);
        oPageReference.getParameters().put('Id', sProjectId);
        oPageReference.getParameters().put('action', action);
        return oPageReference;
    }

/**
    * 
    * 
    * @Author  NTT Data - 
    * @Date 
    *
    * @param none
    * @return PageReference
    **/
    public PageReference createSpecificEAC() {
        return null;
    }
    
    public PageReference createGenericEAC() {
        return doAction(sProjectId, 'createGenericEAC');
         System.savePoint oSavePoint = Database.setSavepoint();

        try {
            Id budgetHeaderId = ECO_BudgetEACService.createGenericECO(sProjectId);
            
            PageReference oPageReference = Page.ECO_BudgetHeader;
            oPageReference.setRedirect(true);
            oPageReference.getParameters().put('Id', budgetHeaderId);
            return oPageReference;
            
        } catch (Exception e) {
            system.debug(Logginglevel.ERROR, 'Handled Exception:  ' + e.getMessage());
            system.debug(Logginglevel.ERROR, 'Handled Exception.getLineNumber:  ' + e.getLineNumber());
            system.debug(Logginglevel.ERROR, 'Handled Exception.getStackTraceString:  ' + e.getStackTraceString());
            Database.rollback(oSavePoint);
            ApexPages.addMessages(e);
        }

        return null;
    } 

/**
    * 
    * 
    * @Author  NTT Data - 
    * @Date 
    *
    * @param none
    * @return PageReference
    **/
    public PageReference createEAC() {
        return doAction(sProjectId, 'createEAC');
        System.savePoint oSavePoint = Database.setSavepoint();

        try {
            Id budgetHeaderId = ECO_BudgetEACService.createInitECO(sProjectId);
            
            PageReference oPageReference = Page.ECO_BudgetHeader;
            oPageReference.setRedirect(true);
            oPageReference.getParameters().put('Id', budgetHeaderId);
            return oPageReference;
            
        } catch (Exception e) {
            system.debug(Logginglevel.ERROR, 'Handled Exception:  ' + e.getMessage());
            system.debug(Logginglevel.ERROR, 'Handled Exception.getLineNumber:  ' + e.getLineNumber());
            Database.rollback(oSavePoint);
            ApexPages.addMessages(e);
        }
        
        return null;
    }

/**
    * 
    * 
    * @Author  NTT Data - 
    * @Date 
    *
    * @param none
    * @return PageReference
    **/
   public PageReference createEstimate() {
        return createBudgetHeader('Estimate');
    }

/**
    * 
    * 
    * @Author  NTT Data - 
    * @Date 
    *
    * @param none
    * @return PageReference
    **/
    public PageReference createChangeOrder(){
        return createBudgetHeader('Change Order');
    }

/**
    * 
    * 
    * @Author  NTT Data - 
    * @Date 
    *
    * @param prefixName
    * @return PageReference
    **/
    public PageReference createBudgetHeader(String prefixName){
        System.savePoint oSavePoint = Database.setSavepoint();

        BudgetHeader__c oBudgetHeader = new BudgetHeader__c();

        try {
            oBudgetHeader.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(BudgetHeader__c.sObjectType, 'Change_Order');
            oBudgetHeader.Project__c = sProjectId;
            oBudgetHeader.Status__c = ECO_DTO_BudgetHeader.STATUS_ESTIMATE;

            list<BudgetHeader__c> lBudgetHeader = new list<BudgetHeader__c>([SELECT Id FROM BudgetHeader__c WHERE Project__c = :sProjectId]);

            oBudgetHeader.BudgetName__c = prefixName + ' ' + lBudgetHeader.size();

            insert oBudgetHeader;
        } catch (Exception e) {
            system.debug('Handled Exception:  ' + e.getMessage());
            system.debug('Handled Exception.getLineNumber:  '+e.getLineNumber());
            Database.rollback(oSavePoint);
            ApexPages.addMessages(e);
        }

        try {
            map<Id, BudgetTask__c> mBudgetTask = new map<Id, BudgetTask__c>();
            
            for (pse__Project_Task__c oProjectTask : [SELECT Id
                                                    , Name 
                                                    , (SELECT Id FROM pse__Immediate_Sub_Tasks__r)
                                            FROM pse__Project_Task__c 
                                            WHERE pse__Project__c = :sProjectId
                                                  AND IsWorkPlanTask__c = false]) {

                BudgetTask__c oBudgetTask = new BudgetTask__c();
                oBudgetTask.ProjectTask__c = oProjectTask.Id;
                oBudgetTask.BudgetHeader__c = oBudgetHeader.Id;
                oBudgetTask.TaskName__c = oProjectTask.Name;
                mBudgetTask.put(oProjectTask.Id, oBudgetTask);
            }
            
            if (!mBudgetTask.isEmpty()) {
                insert mBudgetTask.values();
            }

        } catch (Exception e) {
            system.debug('Handled Exception:  '+e.getMessage());
            system.debug('Handled Exception.getLineNumber:  '+e.getLineNumber());
            Database.rollback(oSavePoint);
            ApexPages.addMessages(e);
        }


        PageReference oPageReference = Page.ECO_BudgetHeader;

        oPageReference.getParameters().put('Id', oBudgetHeader.Id);
        oPageReference.setRedirect(true);
        return oPageReference;
    }

/**
    * 
    * 
    * @Author  NTT Data - 
    * @Date 
    *
    * @param none
    * @return PageReference
    **/
    public PageReference returnToProject(){
        PageReference oPageReference = new PageReference('/' + sProjectId);
        oPageReference.setRedirect(true);
        return oPageReference;
    }

/**
    * 
    * 
    * @Author  NTT Data - 
    * @Date 
    *
    * @param none
    * @return PageReference
    **/
    public PageReference gotoSetup(){
        PageReference oPageReference = Page.ECO_BudgetQuestionnaire;
        oPageReference.getParameters().put('retURL', '/apex/ECO_BudgetHeaderSummary?id=' + sProjectId);
        oPageReference.getParameters().put('id', sProjectId);
        oPageReference.setRedirect(true);
        return oPageReference;
    }

/**
    * 
    * 
    * @Author  NTT Data - 
    * @Date 
    *
    * @param none
    * @return PageReference
    **/
    public PageReference gotoAgreements() {
        PageReference oPageReference = Page.ECO_ProjectAgreement;
        oPageReference.getParameters().put('retURL', '/apex/ECO_BudgetHeaderSummary?id=' + sProjectId);
        oPageReference.getParameters().put('ProjectId', sProjectId);
        oPageReference.setRedirect(true);
        return oPageReference;
    }

/**
    * 
    * 
    * @Author  NTT Data - 
    * @Date 
    *
    * @param none
    * @return PageReference
    **/
    public PageReference showBudgetList(){
        PageReference oPageReference = Page.ECO_BudgetHeaderSummary;
        oPageReference.setRedirect(true);
        oPageReference.getParameters().put('id', sProjectId);
        
        return oPageReference;
    }

/**
    * 
    * 
    * @Author  NTT Data - 
    * @Date 
    *
    * @param none
    * @return PageReference
    **/
    public PageReference showArchivedBudgetList(){
        PageReference oPageReference = Page.ECO_BudgetHeadersArchived;
        oPageReference.setRedirect(true);
        oPageReference.getParameters().put('id', sProjectId);
        
        return oPageReference;
    }

/**
    * 
    * 
    * @Author  NTT Data - 
    * @Date 
    *
    * @param none
    * @return PageReference
    **/
    public PageReference showBudgetSummary(){
        PageReference oPageReference = Page.ECO_BudgetHeader;

        oPageReference.getParameters().put('id', sBudgetHeaderId);
        oPageReference.setRedirect(true);
        return setFilters(oPageReference);
    }

/**
    * 
    * 
    * @Author  NTT Data - 
    * @Date 
    *
    * @param none
    * @return PageReference
    **/
    public PageReference showTaskTab(){
        PageReference oPageReference = Page.ECO_TaskDetail;
        oPageReference.setRedirect(true);
        oPageReference.getParameters().put('id', sProjectId);
        
        return setFilters(oPageReference);
    }

/**
    * 
    * 
    * @Author  NTT Data - 
    * @Date 
    *
    * @param none
    * @return PageReference
    **/
    public PageReference showLaborTab(){
        PageReference oPageReference;
        
        if (recordTypeName != 'EAC')
            oPageReference = Page.ECO_BudgetLabourDetail;
        else {
            oPageReference = Page.ECO_BudgetLabourEAC;
        }
        
        oPageReference.getParameters().put('id', sBudgetHeaderId);
        oPageReference.setRedirect(true);
        return setFilters(oPageReference);
    }

/**
    * 
    * 
    * @Author  NTT Data - 
    * @Date 
    *
    * @param none
    * @return PageReference
    **/
    public PageReference showSubTab(){
        PageReference oPageReference = Page.ECO_BudgetSubDetail;
        
        if (recordTypeName == 'EAC') {
            oPageReference = Page.ECO_BudgetSubDetailEAC;
        }
        oPageReference.getParameters().put('id', sBudgetHeaderId);
        oPageReference.setRedirect(true);
        return setFilters(oPageReference);
    }

/**
    * 
    * 
    * @Author  NTT Data - 
    * @Date 
    *
    * @param none
    * @return PageReference
    **/
    public PageReference showODCTab(){
        PageReference oPageReference = Page.ECO_BudgetODCDetail;

        if (recordTypeName == 'EAC') {
            oPageReference = Page.ECO_BudgetODCDetailEAC;
        }
        oPageReference.getParameters().put('id', sBudgetHeaderId);
        oPageReference.setRedirect(true);
        return setFilters(oPageReference);
    }

/**
    * 
    * 
    * @Author  NTT Data - 
    * @Date 
    *
    * @param none
    * @return PageReference
    **/
    public PageReference showContTab(){
        PageReference oPageReference = Page.ECO_BudgetContingency;
        
        if (recordTypeName == 'EAC') {
            oPageReference = Page.ECO_BudgetContingencyEAC;
        }

        oPageReference.getParameters().put('id', sBudgetHeaderId);
        oPageReference.setRedirect(true);
        return setFilters(oPageReference);
    }

/**
    * 
    * 
    * @Author  NTT Data - 
    * @Date 
    *
    * @param pr
    * @return PageReference
    **/
    public PageReference setFilters(PageReference pr) {
        PageReference currentPage = System.currentPageReference();
        List<String> filters = new List<String> { 'parentTaskFilter', 'taskRange' };

        Map<String, String> mapCurrentParams = currentPage.getParameters();
        for( String filter : filters) {
            if (mapCurrentParams.containsKey(filter)) {
                String filterParam = mapCurrentParams.get(filter);
                pr.getParameters().put(filter, filterParam);
            }
        }

        return pr;
    }
}