/** ------------------------------------------------------------------------------------------------------
* @Description the page controller extension for the ECO_BudgetLabourDetail.page which 
*              uses the standardController="BudgetHeader__c"
*
* @Author      NTT Data - Omar Abdel-Latief & Arman Shah
* @Date        2016
*-----------------------------------------------------------------------------------------------------*/
public class ECO_BudgetODCDetailEACController extends ECO_BudgetGenericDetailController  implements IBudgetSave{
    public IBudgetSave parentExt { get; set;}

    //task filtering for projects with more than 1000 tasks
    public String parentTaskFilter                          { get; set; }
    public Boolean tooManyTasks                             { get; set; }
    public List<SelectOption> taskFilterOptions             { get; set; }
    public Integer totalPages {get; set;}
    public ECO_DTO_BudgetLabourWrapper budgetLabourWrapper{get; set;}
     
    public List<SelectOption> expenditureTypes {get; set;}
    public List<SelectOption> unitTypes {get; set;}

    public ECO_DTO_BudgetTask totalRow {get; set;} 
    public String defaultExpValue {get; set;}
    public ApexPages.StandardSetController brSsc {
        get;
        set;
    }

/**
    * constructor
    *
    * @Author
    * @Date 
    *
    * @param con
    * @return none
    **/
    public ECO_BudgetODCDetailEACController (ApexPages.StandardController con) {
        String strPageNum = System.currentPageReference().getParameters().get('pagenum');
        parentExt = this;
        budgetHeaderId = con.getId();
        //DJO 8/2016 issue 5113 - add filter by parent task
        this.taskFilterOptions = new List<SelectOption>();
        this.taskFilterOptions.add( new SelectOption( '-1', 'All'));

        //get the requested filter task from the param list
        this.parentTaskFilter = ApexPages.currentPage().getParameters().get('parentTaskFilter');
        // this.taskRange = ApexPages.currentPage().getParameters().get('taskRange');
        if( this.parentTaskFilter == null){
            this.parentTaskFilter = '-1';
        }

        this.tooManyTasks = false;
        Integer taskListSize = ECO_DTO_BudgetLabourWrapper.loadParentTaskFilter(budgetHeaderId, parentTaskFilter, taskFilterOptions);
        if( taskListSize > ECO_DTO_BudgetLabourWrapper.taskLimit && this.parentTaskFilter == '-1'){
            this.tooManyTasks = true;
            return;
        }

        brSsc = new ApexPages.StandardSetController(ECO_DTO_BudgetLabourWrapper.budgetResourceSelector(budgetHeaderId, 'ODC/FEE', parentTaskFilter));
        // brSsc.setPageSize(5);


        //System.debug('budgetHeaderId: ' + budgetHeaderId);
        //System.debug('con: ' + con);
        Integer pageNum = 1;

        if (strPageNum != null) {
           pageNum = Integer.valueOf(strPageNum);
        }
        budgetLabourWrapper = new ECO_DTO_BudgetLabourWrapper(brSsc, budgetHeaderId, 'ODC/FEE', pageNum, parentTaskFilter);

        if (strPageNum != null) {
            brSsc.setPageNumber(Integer.valueOf(strPageNum));
        }
    Decimal dtotalPages;


        dtotalPages = (brSsc.getResultSize() / brSsc.getPageSize());
        dtotalPages = Math.floor(dtotalPages) + ((Math.mod(brSsc.getResultSize(), brSsc.getPageSize()) > 0) ? 1 : 0);
        totalPages = Integer.valueOf(dtotalPages);

        setupExpenditureTypes();      
        setupUnitTypes();  
    }

/**
     * refreshes the data on oparent task filter change
     *
     * @Author  NTT Data - Deborah Orth
     * @Date    August 2016
     *
     * @param    
     * @return   PageReference  
     **/
    public PageReference refreshData(){
        PageReference pageReference = new PageReference(ApexPages.currentPage().getUrl());
        String strPageNum = System.currentPageReference().getParameters().get('pagenum');
        pageReference.getParameters().clear();
        pageReference.getParameters().put('Id', this.budgetHeaderId );
        pageReference.getParameters().put('pagenum', strPageNum);
        pageReference.getParameters().put('parentTaskFilter', this.parentTaskFilter);
        if (budgetLabourWrapper != null && budgetLabourWrapper.taskRange != null) pageReference.getParameters().put('taskRange', budgetLabourWrapper.taskRange);
        pageReference.setRedirect(true);

        return pageReference;
    }

/**
     * 
     *
     * @Author  NTT Data
     * @Date   
     *
     * @param    
     * @return   PageReference  
     **/
    public PageReference hardRefresh() {
        String strPageNum = System.currentPageReference().getParameters().get('pagenum');
        return hardRefresh(strPageNum);
    }

/**
     * 
     *
     * @Author  NTT Data
     * @Date   
     *
     * @param    strPageNum
     * @return   PageReference  
     **/
    public PageReference hardRefresh(String strPageNum) {
        PageReference pageReference = ApexPages.currentPage();
        pageReference.getParameters().clear();
        pageReference.getParameters().put('Id', budgetHeaderId );
        pageReference.getParameters().put('pagenum', strPageNum);
        pageReference.getParameters().put('parentTaskFilter', this.parentTaskFilter);
        if (budgetLabourWrapper != null && budgetLabourWrapper.taskRange != null) {
            pageReference.getParameters().put('taskRange', budgetLabourWrapper.taskRange);
        }
        
        pageReference.setRedirect(true);

        return pageReference;
    }

/**
     * 
     *
     * @Author  NTT Data
     * @Date   
     *
     * @param    
     * @return   PageReference  
     **/
    public PageReference setAllZeroETC() {
        budgetLabourWrapper.setAllZeroETC();
        return hardRefresh();
    }

/**
     * 
     *
     * @Author  NTT Data
     * @Date   
     *
     * @param    
     * @return   void  
     **/
    public void reset() {
        budgetLabourWrapper.reset(brSsc.getRecords());
    }

/**
     * 
     *
     * @Author  NTT Data
     * @Date   
     *
     * @param    
     * @return   PageReference  
     **/
    public PageReference rerender() {
        return null;
    }

/**
     * 
     *
     * @Author  NTT Data
     * @Date   
     *
     * @param    
     * @return   void  
     **/
    private void setupExpenditureTypes() {
        expenditureTypes = new List<SelectOption>();

        Schema.DescribeFieldResult fieldResult = BudgetResource__c.ExpenditureType__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        defaultExpValue = 'MISC-Materials';
        //system.debug('defaultExpValue ' + defaultExpValue);
        for (Schema.PicklistEntry f : ple) {
            expenditureTypes.add(new SelectOption(f.getValue(), f.getLabel()));
        }

        for(ECO_DTO_BudgetLabourDetail resource : budgetLabourWrapper.dtoBudgetLabourDetails) {
            if (resource.expenditureType == null) {
                resource.expenditureType = defaultExpValue;
            }
        }
    }

/**
     * 
     *
     * @Author  NTT Data
     * @Date   
     *
     * @param    
     * @return   void  
     **/
    private void setupUnitTypes() {
        unitTypes = new List<SelectOption>();

        Schema.DescribeFieldResult fieldResult = BudgetResource__c.CostCalcType__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry f : ple) {
            unitTypes.add(new SelectOption(f.getValue(), f.getLabel()));
        }       
    }

/**
     * 
     *
     * @Author  NTT Data
     * @Date   
     *
     * @param    pageNum
     * @return   PageReference  
     **/
     public PageReference gotoPage(Integer pageNum) {
        PageReference pr = hardRefresh();
        pr.getParameters().put('pagenum', String.valueOf(pageNum) );

        return pr;
    }

/**
     * 
     *
     * @Author  NTT Data
     * @Date   
     *
     * @param    
     * @return   PageReference  
     **/
    public PageReference pageLast() {

        return saveEACRecords( totalPages);
    }

/**
     * 
     *
     * @Author  NTT Data
     * @Date   
     *
     * @param    
     * @return   PageReference  
     **/
    public PageReference pageNext() {
        return saveEACRecords( brSsc.getPageNumber() + 1);
    }

/**
     * 
     *
     * @Author  NTT Data
     * @Date   
     *
     * @param    
     * @return   PageReference  
     **/
    public PageReference pagePrevious() {
        return saveEACRecords(brSsc.getPageNumber() - 1);

    }

/**
     * 
     *
     * @Author  NTT Data
     * @Date   
     *
     * @param    
     * @return   PageReference  
     **/
    public PageReference pageFirst() {
        return saveEACRecords(1);

    }

/**
     * 
     *
     * @Author  NTT Data
     * @Date   
     *
     * @param    
     * @return   PageReference  
     **/
    public PageReference cloneResource () {
        System.savepoint sp = Database.setSavepoint();
        
        Id budgetSubId = System.currentPageReference().getParameters().get('budgetSubId');
        
        try {
            
            BudgetResource__c sourceResource = [SELECT Id
                                                    , Name 
                                                    , BudgetHeader__c
                                                    , ExternalId__c
                                                    , MarginType__c
                                                    , ProjectTeamMember__c
                                                    , ResourceType__c
                                                    , SubsAndVendors__c 
                                                    , TotalCost__c
                                                    , TotalRevenue__c
                                                    , OverrideBillRate__c
                                                    , OverrideFringeMultiplier__c
                                                    , OverrideOverheadMultiplier__c
                                                    , OverrideRawCost__c
                                                    , OverrideUplift__c 
                                                    , FullyBurdenedCostRate__c 
                                                    , CostRate__c
                                                    , OverrideRatesOnLines__c 
                                                    , CostCalcType__c
                                                    , ResourceName__c
                                                    , ColumnHeader__c
                                                    , ProjectTeamMember__r.Contact__c
                                                    , SortOrder__c
                                                    , Sort_Order_Detail__c
                                                    , ForeignResource__c
                                                    , JobName__c
                                                    , TotalHours__c
                                                    , IsQuoted__c
                                                    , IsEstimated__c
                                                    , IsBillable__c
                                                    , (SELECT Id 
                                                            , Name
                                                            , ApprovalStatus__c
                                                            , DefaultBillRate__c
                                                            , DefaultFringeMultiplier__c
                                                            , DefaultOverheadMultiplier__c
                                                            , DefaultRawCost__c
                                                            , DefaultUplift__c
                                                            , FullyBurdenedCost__c
                                                            , FullyBurdenedCostRate__c
                                                            , MarginType__c
                                                            , OverrideBillRate__c
                                                            , OverrideFringeMultiplier__c
                                                            , OverrideOverheadMultiplier__c
                                                            , OverrideRawCost__c
                                                            , OverrideUplift__c
                                                            , MarginAmountQtyTimesRate__c 
                                                            , MarginAmountCostTimesUplift__c
                                                            , Quantity__c 
                                                            , BudgetResource__c
                                                            , BudgetTask__c
                                                            , CalculatedRevenue__c 
                                                            , OverrideTotalCost__c
                                                            , OverrideTotalRawCost__c 
                                                            , OverrideTotalRevenue__c 
                                                            , ProjectTaskAssignment__c
                                                        FROM BudgetAssignments__r)
                                            FROM BudgetResource__c 
                                            WHERE Id = :budgetSubId AND ResourceType__c =: 'ODC/FEE'];
                                            
            BudgetResource__c clonedResource = sourceResource.clone(false, false, false, false);
            List<BudgetAssignment__c> clonedAssignments = new List<BudgetAssignment__c>();

            clonedResource.costCalcType__c = sourceResource.costCalcType__c;
            
            insert clonedResource;
            
            for (BudgetAssignment__c ba : sourceResource.BudgetAssignments__r) {
                BudgetAssignment__c clonedAssignment = ba.clone(false, false, false, false);
                clonedAssignment.BudgetResource__c = clonedResource.Id;
                clonedAssignments.add(clonedAssignment);
            }
            
            if (!clonedAssignments.isEmpty()) {
                insert clonedAssignments;
            }
            //budgetLabourWrapper = new ECO_DTO_BudgetLabourWrapper(budgetHeaderId, 'Subcontractor');
            //budgetLabourWrapper.dtoBudgetLabourDetails.add(new ECO_DTO_BudgetLabourDetail(clonedResource, clonedAssignments));
            
        } catch (Exception e) {
            system.debug('Cloning Exception:  '+e.getMessage());
            system.debug('Cloning Exception Trace:  '+e.getStackTraceString());
            Database.rollBack(sp);
            ApexPages.addMessages(e);
        }
        
        return reDirect();
    }

/**
     * 
     *
     * @Author  NTT Data
     * @Date   
     *
     * @param    
     * @return   PageReference  
     **/
    public PageReference removeEntireColumn () {
        Id budgetSubId = System.currentPageReference().getParameters().get('budgetSubId');
        delete new BudgetResource__c(Id = budgetSubId);
        
        //budgetLabourWrapper = new ECO_DTO_BudgetLabourWrapper(budgetHeaderId, 'Subcontractor');
        //budgetLabourWrapper.removeBudgetLabourDetail(budgetSubId);
        
        return reDirect();
    }

/**
     * 
     *
     * @Author  NTT Data
     * @Date   
     *
     * @param    
     * @return   PageReference  
     **/
    public PageReference save() {
        return saveEAC();
    }

/**
     * 
     *
     * @Author  NTT Data
     * @Date   
     *
     * @param    
     * @return   PageReference  
     **/
    public PageReference saveEAC() {

        return saveEACRecords(brSsc.getPageNumber());

    }

/**
     * 
     *
     * @Author  NTT Data
     * @Date   
     *
     * @param    pageNum
     * @return   PageReference  
     **/
    public PageReference saveEACRecords(Integer pageNum) {
        PageReference pr = hardRefresh();
        pr.getParameters().put('pagenum', String.valueOf(pageNum));

        if (!isSaveAllowed(budgetHeaderId)) {
           return pr;
        }

        List<BudgetAssignment__c> budgetAssignmentsToUpdate = new List<BudgetAssignment__c>();
        List<BudgetResource__c> budgetResourcesToUpdate = new List<BudgetResource__c>();
        
        for(ECO_DTO_BudgetLabourDetail dtoBudgetDetail : budgetLabourWrapper.dtoBudgetLabourDetails) {
            budgetResourcesToUpdate.add(dtoBudgetDetail.oBudgetResource);
            
            for(Id budgetTaskId : dtoBudgetDetail.mAssignmentMap.KeySet()) {
                BudgetAssignment__c budgetAssignment = dtoBudgetDetail.mAssignmentMap.get(budgetTaskId);
                if ( dtoBudgetDetail.marginType == 'Amount') {
                    budgetAssignment.OverrideTotalRevenue__c = dtoBudgetDetail.mapForecastRevenue.get(budgetTaskId) - ifDecimalNull(budgetAssignment.EACForecastRevenueNumber__c);
                } else {
                    budgetAssignment.OverrideTotalRevenue__c = null;
                }
                //budgetAssignment.OverrideTotalRawCost__c = dtoBudgetDetail.mapCostToComplete.get(budgetTaskId) - ifDecimalNull(budgetAssignment.EACForecastTotalCost__c);
                budgetAssignmentsToUpdate.add(budgetAssignment);
            }
            //budgetAssignmentsToUpdate.addAll(dtoBudgetDetail.mAssignmentMap.values());
        }
        
        try {
            upsert budgetResourcesToUpdate;
            upsert budgetAssignmentsToUpdate;

            return pr;
        } catch (Exception ex) {
            system.debug(LoggingLevel.ERROR, ex.getMessage());
            system.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            ECO_Service_ErrorLog.logException(ex);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error Saving Budget: ' + ex.getMessage()));
            // throw ex;
        }

        return null;
    }

/**
     * 
     *
     * @Author   NTT Data
     * @Date   
     *
     * @param    value 
     * @return   Decimal  
     **/
    public Decimal ifDecimalNull(Decimal value) {
        if(value == null) {
            value = 0.0;
        }
        
        return value;
    }

/**
     * 
     *
     * @Author  NTT Data
     * @Date   
     *
     * @param    
     * @return   PageReference  
     **/
    public PageReference reDirect() {
        PageReference pageReference = new PageReference('/apex/ECO_BudgetODCDetailEAC');
        pageReference.getParameters().put('Id', budgetHeaderId );
        pageReference.setRedirect(True);
        
        return pageReference;
    }
}