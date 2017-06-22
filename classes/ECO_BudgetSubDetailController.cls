/** ------------------------------------------------------------------------------------------------------
 *  @Description
 * 
 * @Author      NTT Data 
 * @Date        August 2016
 *-----------------------------------------------------------------------------------------------------*/
public with sharing class ECO_BudgetSubDetailController extends ECO_BudgetGenericDetailController  implements IBudgetSave{
	public static final Integer PAGE_SIZE = 5;
	public IBudgetSave parentExt { get; set;}


  public String parentTaskFilter                          { get; set; }
    public Boolean tooManyTasks                             { get; set; }
    public List<SelectOption> taskFilterOptions             { get; set; }
    public Integer totalPages {get; set;}
	public transient Map<String, Blob> baHashes;   

    public Map<String, Blob> brHashes;

    public ApexPages.StandardSetController brSsc {
        get;
        set;
    }
	
    public Id budgetResourceId {get;set;}
     public ECO_DTO_BudgetLabourWrapper budgetLabourWrapper{get; set;}

     public ECO_DTO_BudgetTask totalRow {get; set;}

    public Integer currentPage {get; set;}
    public Integer lastPage {get; set;}

    public Integer totalRecords {get; set;}

    public Boolean enablePageFirst {get; set;}
    public Boolean enablePagePrevious {get; set;}
    public Boolean enablePageNext {get; set;}
    public Boolean enablePageLast {get; set;}


/**
    * constructor
    *
    * @Author
    * @Date 
    *
    * @param con
    * @return none
    **/
    public ECO_BudgetSubDetailController (ApexPages.StandardController con) {
        String strPageNum = System.currentPageReference().getParameters().get('pagenum');
        parentExt = this;
		budgetHeaderId = con.getId();
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

        brSsc = new ApexPages.StandardSetController(ECO_DTO_BudgetLabourWrapper.budgetResourceSelector(budgetHeaderId, 'Subcontractor', parentTaskFilter));
        // brSsc.setPageSize(5);


        //System.debug('budgetHeaderId: ' + budgetHeaderId);
        //System.debug('con: ' + con);
        Integer pageNum = 1;

        if (strPageNum != null) {
           pageNum = Integer.valueOf(strPageNum);
        }
        budgetLabourWrapper = new ECO_DTO_BudgetLabourWrapper(brSsc, budgetHeaderId, 'Subcontractor', pageNum, parentTaskFilter);

        currentPage = 1;
        if (strPageNum != null) {
            brSsc.setPageNumber(Integer.valueOf(strPageNum));
            currentPage = Integer.valueOf(strPageNum);
        }


        Decimal dtotalPages;

        dtotalPages = (brSsc.getResultSize() / brSsc.getPageSize());
        dtotalPages = Math.floor(dtotalPages) + ((Math.mod(brSsc.getResultSize(), brSsc.getPageSize()) > 0) ? 1 : 0);
        totalPages = Integer.valueOf(dtotalPages);
		recalcHashes();
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
     * @return   void  
     **/
    public void recalcHashes() {
        Decimal dtotalPages;


        dtotalPages = (brSsc.getResultSize() / brSsc.getPageSize());
        dtotalPages = Math.floor(dtotalPages) + ((Math.mod(brSsc.getResultSize(), brSsc.getPageSize()) > 0) ? 1 : 0);
        totalPages = Integer.valueOf(dtotalPages);

        brHashes = new Map<String, Blob>();
        //baHashes = new Map<String, Blob>();

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
     * @Author  NTT Data
     * @Date   
     *
     * @param    
     * @return   void  
     **/
    public void reset() {
        budgetLabourWrapper.reset(brSsc.getRecords());
        recalcHashes();
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

        return save( totalPages);
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
        return save( brSsc.getPageNumber() + 1);
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
        return save(brSsc.getPageNumber() - 1);

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
        return save(1);

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
    @TestVisible
    private void initPage() {
        currentPage = 0;

        if (ApexPages.currentPage().getParameters().get('pg') != null)
        	currentPage = Integer.valueOf(ApexPages.currentPage().getParameters().get('pg'));

        totalRecords = budgetLabourWrapper.dtoBudgetLabourDetails.size();

        lastPage = (totalRecords - 1) / PAGE_SIZE;
        
        if (lastPage < 0)
        	lastPage = 0;

		List<ECO_DTO_BudgetLabourDetail> newdtoBudgetLabourDetails = new List<ECO_DTO_BudgetLabourDetail>();

		Integer i = currentPage * PAGE_SIZE;
		
		while ((i < totalRecords) && (newdtoBudgetLabourDetails.size() < PAGE_SIZE)) {
			newdtoBudgetLabourDetails.add(budgetLabourWrapper.dtoBudgetLabourDetails.get(i));
			
			i++;
		}

		budgetLabourWrapper.dtoBudgetLabourDetails = newdtoBudgetLabourDetails;

		enablePageFirst = currentPage > 0;
		enablePagePrevious = currentPage > 0;
		enablePageNext = currentPage < lastPage;
		enablePageLast  = currentPage < lastPage;
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
    public PageReference movePage() {
		PageReference pageReference = new PageReference('/apex/ECO_BudgetSubDetail');
        
        pageReference.getParameters().put('id', budgetHeaderId);
        pageReference.getParameters().put('pg', String.valueOf(currentPage));
		pageReference.setRedirect(true);
        
        return pageReference;
    }

	/*
    public PageReference pageFirst() {
    	currentPage = 0;

    	return movePage();
    }

    public PageReference pagePrevious() {
    	currentPage--;

    	return movePage();
    }

    public PageReference pageNext() {
    	currentPage++;

    	return movePage();
    }

    public PageReference pageLast() {
    	currentPage = lastPage;

    	return movePage();
    }
       */

/**
     * 
     *
     * @Author  NTT Data
     * @Date   
     *
     * @param    
     * @return   PageReference  
     **/
    public PageReference calculateRevenue() {
        for(ECO_DTO_BudgetLabourDetail oBudgetResource : budgetLabourWrapper.dtoBudgetLabourDetails) {
            if(oBudgetResource.marginType == 'Percent') {
                for(BudgetAssignment__c budgetAssignment : oBudgetResource.mAssignmentMap.values()) {
                    budgetAssignment.OverrideTotalRevenue__c = Null;
                }
            }    
        }
        
        return null;
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
                                                	, VendorSite__c
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
											WHERE Id = :budgetSubId AND ResourceType__c =: 'Subcontractor'];
											
			BudgetResource__c clonedResource = sourceResource.clone(false, false, false, false);
			List<BudgetAssignment__c> clonedAssignments = new List<BudgetAssignment__c>();
			
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
        
        PageReference pageReference = new PageReference('/apex/ECO_BudgetSubDetail');
        pageReference.getParameters().put('Id', budgetHeaderId );
		pageReference.setRedirect(True);
		
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
    public PageReference removeEntireColumn () {
		Id budgetSubId = System.currentPageReference().getParameters().get('budgetSubId');
		delete new BudgetResource__c(Id = budgetSubId);
		
		//budgetLabourWrapper = new ECO_DTO_BudgetLabourWrapper(budgetHeaderId, 'Subcontractor');
		//budgetLabourWrapper.removeBudgetLabourDetail(budgetSubId);
        
		PageReference pageReference = new PageReference('/apex/ECO_BudgetSubDetail');
        pageReference.getParameters().put('Id', budgetHeaderId );
		pageReference.setRedirect(True);
        
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
    public PageReference save() {
        return save(brSsc.getPageNumber());
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
    public PageReference save(Integer pageNum) {
        PageReference pageReference = hardRefresh();
        pageReference.getParameters().put('pagenum', String.valueOf(pageNum));
        
         if (!isSaveAllowed(budgetHeaderId)) {
            return pageReference;
         }
    	//system.debug('In ECO_BudgetLabourDetailController.save()');
	List<BudgetResource__c> budgetResourcesToUpdate = new List<BudgetResource__c>();        
        List<BudgetAssignment__c> budgetAssignmentsToUpdate = new List<BudgetAssignment__c>();
	for(ECO_DTO_BudgetLabourDetail dtoBudgetDetail : budgetLabourWrapper.dtoBudgetLabourDetails) {
            if (brHashes.get(dtoBudgetDetail.oBudgetResource.Id) != ECO_Utils_Meta.getHash(dtoBudgetDetail.oBudgetResource)) {
      		budgetResourcesToUpdate.add(dtoBudgetDetail.oBudgetResource);
            }
            // budgetAssignmentsToUpdate.addAll(dtoBudgetDetail.mAssignmentMap.values());
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
        
        if (budgetResourcesToUpdate.size() > 0) {
        	//system.debug('save br- ' + budgetResourcesToUpdate[0]);
    	}
	
    	try {
		upsert budgetAssignmentsToUpdate;
	        upsert budgetResourcesToUpdate;
        } catch (Exception ex) {
		system.debug(LoggingLevel.ERROR, ex.getMessage());
            
		system.debug(LoggingLevel.ERROR, ex.getStackTraceString());
		ECO_Service_ErrorLog.logException(ex);			
	}
       
        return pageReference;
    }

}