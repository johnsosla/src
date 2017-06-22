/** ------------------------------------------------------------------------------------------------------
 *  @Description
 * 
 * @Author      NTT Data 
 * @Date        August 2016
 *-----------------------------------------------------------------------------------------------------*/
public without sharing class ECO_BudgetLabourEACController extends ECO_BudgetGenericDetailController implements IBudgetSave{
    public IBudgetSave parentExt { get; set;}

    public Boolean isBurdenRateRevised {get; set;}

    public List<SelectOption> getBrFilterOptions() {
        List<SelectOption> brOptions = new List<SelectOption>();

        brOptions.add(new SelectOption('-1', 'All'));

        return brOptions;
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
    public ECO_BudgetLabourEACController(ApexPages.StandardController con) {
        super(con, 'Labor/Person');
        parentExt = this;

        // brSsc.setPageSize(5);
        if (budgetLabourWrapper == null ) return;
        recalcHashes();

        // totalRow = ECO_BudgetTaskService.getTotalRow(budgetLabourWrapper.dtoBudgetTasks);

        List<BudgetResource__c> bResources = (List<BudgetResource__c>) brSsc.getRecords();
        for (BudgetResource__c br : bResources) {
            if (br.isBurdenRateRevised__c) {
                //System.debug('___$$ BurdenRateRevised BR='+br);
                this.isBurdenRateRevised = true;
                break;
            }
        }
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

        if (budgetLabourWrapper != null && 
            budgetLabourWrapper.parentTaskFilter == this.parentTaskFilter && 
            budgetLabourWrapper.taskRange != null) 
        {
            pageReference.getParameters().put('taskRange', budgetLabourWrapper.taskRange);
        }
        
        pageReference.setRedirect(true);

        return pageReference;
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
    public PageReference hardRefresh() {
        String strPageNum = System.currentPageReference().getParameters().get('pagenum');
        return hardRefresh(strPageNum);
    }

/**
    * 
    * 
    * @Author  NTT Data - 
    * @Date 
    *
    * @param strPageNum
    * @return PageReference
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
    * @Author  NTT Data - 
    * @Date 
    *
    * @param none
    * @return void
    **/
    public void recalcHashes() {
        Decimal dtotalPages;


        dtotalPages = (brSsc.getResultSize() / brSsc.getPageSize());
        dtotalPages = Math.floor(dtotalPages) + ((Math.mod(brSsc.getResultSize(), brSsc.getPageSize()) > 0) ? 1 : 0);
        totalPages = Integer.valueOf(dtotalPages);

        brHashes = new Map<String, Blob>();
        //baHashes = new Map<String, Blob>();
        //system.debug('ECO_DTO_BudgetLabourDetail: ' + budgetLabourWrapper);
        //system.debug('dtoBudgetLabourDetails: ' + budgetLabourWrapper.dtoBudgetLabourDetails);

        for (ECO_DTO_BudgetLabourDetail dtoBudgetDetail : budgetLabourWrapper.dtoBudgetLabourDetails) {

            brHashes.put(dtoBudgetDetail.oBudgetResource.Id, ECO_Utils_Meta.getHash(dtoBudgetDetail.oBudgetResource));
            /*
            for (BudgetAssignment__c ba : dtoBudgetDetail.mAssignmentMap.values()) {
                baHasChanged.put('' + ba.BudgetTask__c + ba.BudgetResource__c, false);
                // baHashes.put('' + ba.BudgetTask__c + ba.BudgetResource__c, ECO_Utils_Meta.getHash(ba));
            }
            */
        }
        //system.debug(LoggingLevel.INFO, baHashes.size());
    }

/**
    * 
    * 
    * @Author  NTT Data - 
    * @Date 
    *
    * @param none
    * @return void
    **/
    public void reset() {
        budgetLabourWrapper.reset(brSsc.getRecords());
        recalcHashes();
    }

/**
    * 
    * 
    * @Author  NTT Data - 
    * @Date 
    *
    * @param pageNum
    * @return PageReference
    **/
    public PageReference gotoPage(Integer pageNum) {
        PageReference pr = hardRefresh();
        pr.getParameters().put('pagenum', String.valueOf(pageNum) );

        return pr;
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
    public PageReference pageLast() {

        return saveEACRecords( totalPages);
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
    public PageReference pageNext() {
        return saveEACRecords( brSsc.getPageNumber() + 1);
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
    public PageReference pagePrevious() {
        return saveEACRecords(brSsc.getPageNumber() - 1);

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
    public PageReference pageFirst() {
        return saveEACRecords(1);

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
    public PageReference removeEntireColumn () {
        Id budgetLabourId = System.currentPageReference().getParameters().get('budgetLabourId');
        //system.debug('budgetLabourId : ' + budgetLabourId);
        
        delete new BudgetResource__c(Id = budgetLabourId);

        //budgetLabourWrapper = new ECO_DTO_BudgetLabourWrapper(budgetHeaderId, 'Labor/Person');
        //budgetLabourWrapper.removeBudgetLabourDetail(budgetLabourId);

        return gotoPage(1);
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
    public PageReference unlockColumnETC() {
        Id budgetLabourId = System.currentPageReference().getParameters().get('budgetLabourId');
        List<BudgetAssignment__c> basToUpdate = new List<BudgetAssignment__c>();
        //system.debug('In zeroColumnETC - budgetLabourId: ' + budgetLabourId);
        for (ECO_DTO_BudgetLabourDetail dtoBudgetResource : budgetLabourWrapper.dtoBudgetLabourDetails) {
            if (dtoBudgetResource.oBudgetResource.Id == budgetLabourId) {                
                dtoBudgetResource.oBudgetResource.SetZeroETC__c = false;
                for (BudgetAssignment__c ba : dtoBudgetResource.mAssignmentMap.values()) {
                    if (ba.Id == null) continue;
                    ba.OverrideTotalRawCost__c = null;
                    /* ba.SetZeroETC__c = false;
                    ba.OverrideTotalFringe__c = null;
                    ba.OverrideTotalOverhead__c = null;
                    */
                    basToUpdate.add(ba);
                }
                update basToUpdate;
                update dtoBudgetResource.oBudgetResource;
                return hardRefresh();
            }
        }

        return null;
    }

/**
    * 
    * 
    * @Author  NTT Data - 
    * @Date 
    *
    * @param val
    * @return Decimal
    **/
    private static Decimal ifNull(Decimal val) {
        return val == null ? 0 : val;
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
    public PageReference setAllZeroETC() {
        budgetLabourWrapper.setAllZeroETC();
        return hardRefresh();
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
    public PageReference zeroColumnETC() {
        Id budgetLabourId = System.currentPageReference().getParameters().get('budgetLabourId');
        List<BudgetAssignment__c> basToUpdate = new List<BudgetAssignment__c>();
        //system.debug('In zeroColumnETC - budgetLabourId: ' + budgetLabourId);

        for (ECO_DTO_BudgetLabourDetail dtoBudgetResource : budgetLabourWrapper.dtoBudgetLabourDetails) {
            if (dtoBudgetResource.oBudgetResource.Id == budgetLabourId) {
                dtoBudgetResource.oBudgetResource.SetZeroETC__c = true;
                for (BudgetAssignment__c ba : dtoBudgetResource.mAssignmentMap.values()) {
                    if (ba.Id == null) continue;
                    //ba.SetZeroETC__c = true;
                    ba.Quantity__c = ifNull(ba.EACActualQuantityRollup__c) - ifNull(ba.EACForecastQuantity__c);
                    ba.OverrideTotalRawCost__c = ifNull(ba.EACActualCostRollup__c) - ifNull(ba.EACForecastTotalCost__c);
                    /*
                    ba.OverrideRawCost__c = ifNull(ba.EACActualCost__c) - ifNull(ba.EACForecastRawCost__c);
                    ba.OverrideTotalFringe__c = 0;
                    ba.OverrideTotalOverhead__c = 0;
                    ba.OverrideTotalCost__c = -1 * ifNull(ba.EACForecastTotalCost__c);
                    */
                    basToUpdate.add(ba);
                }
                update basToUpdate;
                update dtoBudgetResource.oBudgetResource;
                return hardRefresh();
            }
        }

        return null;
    }

/**
    * 
    * 
    * @Author  NTT Data - 
    * @Date 
    *
    * @param pageNum
    * @return PageReference
    **/
    public PageReference saveEACRecords(Integer pageNum) {
        PageReference pr = hardRefresh();
        pr.getParameters().put('pagenum', String.valueOf(pageNum));

        if (!isSaveAllowed(budgetHeaderId)) {
           return pr;
        }

        List<BudgetAssignment__c> budgetAssignmentsToUpdate = new List<BudgetAssignment__c>();
        List<BudgetResource__c> budgetResourcesToUpdate = new List<BudgetResource__c>();

        //system.debug(LoggingLevel.ERROR, 'budgetLabourWrapper.dtoBudgetLabourDetails size: ' + budgetLabourWrapper.dtoBudgetLabourDetails.size());
        for (ECO_DTO_BudgetLabourDetail dtoBudgetDetail : budgetLabourWrapper.dtoBudgetLabourDetails) {
            if (brHashes.get(dtoBudgetDetail.oBudgetResource.Id) != ECO_Utils_Meta.getHash(dtoBudgetDetail.oBudgetResource)) {
                budgetResourcesToUpdate.add(dtoBudgetDetail.oBudgetResource);
            }


            for (BudgetAssignment__c ba : dtoBudgetDetail.mAssignmentMap.values()) {
                //system.debug(LoggingLevel.ERROR, 'Quantity: ' + ba.Quantity__c + ' hash: ' + System.hashCode(ba));
                // Integer hashComp = ECO_Utils_Meta.getHash(ba);
                // if (baHashes.get('' + ba.BudgetTask__c + ba.BudgetResource__c) != ECO_Utils_Meta.getHash(ba)) {
                Boolean hasChanged = budgetLabourWrapper.baHasChanged.get('' + ba.BudgetResource__c + ba.BudgetTask__c);
                //System.debug('' + ba.BudgetResource__c + ba.BudgetTask__c + ' - ' + hasChanged);
                if (hasChanged != null && hasChanged == true) {
                    budgetAssignmentsToUpdate.add(ba);
                }
            }

        }

        try {
            Schema.DescribeSObjectResult budgetAssignment = BudgetAssignment__c.sObjectType.getDescribe();
            Boolean isCreateable = budgetAssignment.isCreateable();
            Boolean isUpdateable = budgetAssignment.isUpdateable();
            //System.debug('isUpdateable:::'+isUpdateable+'   isCreateable::: '+isCreateable);
            if(isUpdateable || isCreateable){
                upsert budgetAssignmentsToUpdate;
                upsert budgetResourcesToUpdate;
            } else if ( pageNum == brSsc.getPageNumber()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Current user does not have permission to update the EAC'));
                return null;
            }

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
    * @Author  NTT Data - 
    * @Date 
    *
    * @param none
    * @return PageReference
    **/
    public PageReference save() {
        return saveEAC();
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
    public PageReference saveEAC() {

        return saveEACRecords(brSsc.getPageNumber());

    }
}