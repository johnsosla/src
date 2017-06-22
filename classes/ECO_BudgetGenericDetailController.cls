/** ------------------------------------------------------------------------------------------------------
 *  @Description
 * 
 * @Author      NTT Data 
 * @Date        August 2016
 *-----------------------------------------------------------------------------------------------------*/
public without sharing virtual class ECO_BudgetGenericDetailController extends ECO_Financial_Security  {
	
	//task filtering for projects with more than 1000 tasks
	public String parentTaskFilter                          { get; set; }
	public Boolean tooManyTasks                             { get; set; }
	public List<SelectOption> taskFilterOptions             { get; set; }
	public String strBrFilterIds {get; set; }
	Public String brFilterId {get; set;}
	// public List<SelectOption> brFilterOptions {get; set; }
	public Id budgetHeaderId {get; set;}
	public Integer totalPages {get; set;}

	public Boolean canModify { 
		get {
			if(canModify == null) canModify = isSaveAllowed(budgetHeaderId);
			return canModify;
		} 
		private set; 
	}
	public ECO_DTO_BudgetLabourWrapper budgetLabourWrapper {get; set;}

	public  ECO_DTO_BudgetTask totalRow {get; set;}

	public transient Map<String, Blob> baHashes;   

	public Map<String, Blob> brHashes;

	public ApexPages.StandardSetController brSsc {
		get;
		set;
	}

	public Integer getTaskLimit() { return ECO_DTO_BudgetLabourWrapper.taskLimit; }
	
/**
	* constructor
	*
	* @Author
	* @Date 
	*
	* @param none
	* @return none
	**/
	public ECO_BudgetGenericDetailController() {
		System.debug('In ECO_BudgetGenericDetailController()');
	}

/**
	* constructor
	*
	* @Author
	* @Date 
	*
	* @param con
	* @param resourceType
	* @return none
	**/
	public ECO_BudgetGenericDetailController(ApexPages.StandardController con, String resourceType) {
		system.debug('In ECO_BudgetGenericDetailController(con,resourceType)');
		budgetHeaderId = con.getId();
		brSsc = new ApexPages.StandardSetController(new List<BudgetResource__c>());
		String strShowHidden = System.currentPageReference().getParameters().get('showhidden');
		
		String strPageNum = System.currentPageReference().getParameters().get('pagenum');
		Cookie resourceListCookie = ApexPages.currentPage().getCookies().get('' + budgetHeaderId);
		//DJO 8/2016 issue 5113 - add filter by parent task
		this.taskFilterOptions = new List<SelectOption>();
		this.taskFilterOptions.add( new SelectOption( '-1', 'All'));

		//get the requested filter task from the param list
		this.parentTaskFilter = ApexPages.currentPage().getParameters().get('parentTaskFilter');
		this.strBrFilterIds = null; // = resourceListCookie == null ? '' : resourceListCookie.getValue();
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

		List<Id> brFilterIds = null;
		if (resourceListCookie != null) {
			brFilterIds = resourceListCookie.getValue().split(',');
		}

		Boolean showHidden = strShowHidden != null ? true : false;

		brSsc = new ApexPages.StandardSetController(ECO_DTO_BudgetLabourWrapper.budgetResourceSelector(budgetHeaderId, resourceType , parentTaskFilter, showHidden, brFilterIds));

		//System.debug('budgetHeaderId: ' + budgetHeaderId);
		//System.debug('con: ' + con);
		Integer pageNum = 1;

		if (strPageNum != null) {
		   pageNum = Integer.valueOf(strPageNum);
		}

		budgetLabourWrapper = new ECO_DTO_BudgetLabourWrapper(brSsc, budgetHeaderId, 'Labor/Person', pageNum, parentTaskFilter);

		if (strPageNum != null) {
			brSsc.setPageNumber(Integer.valueOf(strPageNum));
		}
		//system.debug('brSsc is not null' + brSsc);
	}

	public static Boolean checkIsSaveAllowed(Id bhId) {
		/** Query budget header again in case it changed in the meantime **/
		BudgetHeader__c bh = [
			Select 
				Id, ApprovalStatus__c, InternalChangeManager__c, ExternalChangeManager__c, 
				InternalChangeManager__r.ApprovalStatus__c, 
				ExternalChangeManager__r.ApprovalStatus__c, Project__c
			FROM BudgetHeader__c Where Id = :bhId];
	
		if (bh.ExternalChangeManager__c == null && bh.InternalChangeManager__c == null) {
			return true;
		}

		String intApprovalStatus = bh.InternalChangeManager__r.ApprovalStatus__c;
		String extApprovalStatus = bh.ExternalChangeManager__r.ApprovalStatus__c;

		if (intApprovalStatus == 'Submitted' || extApprovalStatus == 'Submitted') return false;

		if (intApprovalStatus == 'Approved') {
			for(IntegrationMessageQueue__c imq : [select Id, Project__c, Status__c, Change__c from IntegrationMessageQueue__c 
														where (Change__c = :bh.InternalChangeManager__c)
														  and JobName__c = 'ETL Budget' order by LastModifiedDate desc limit 1])
			{
				if (imq.Status__c != 'Succes') return true;
			}

			return false;
		} else if (extApprovalStatus == 'Approved') {
			 for(IntegrationMessageQueue__c imq : [select Id, Project__c, Status__c, Change__c from IntegrationMessageQueue__c 
														where (Change__c = :bh.ExternalChangeManager__c)
														  and JobName__c = 'ETL Budget' order by LastModifiedDate desc limit 1])
			{
				if (imq.Status__c != 'Succes') return true;
			}

			return false;
		}

		return true;
	}

	public Boolean isSaveAllowed(Id bhId) {
		return ECO_BudgetGenericDetailController.checkIsSaveAllowed(bhId);        
	}
/*
	public virtual PageReference hardRefresh() {
		system.debug('parent hardRefresh');
		return null;
	}
	*/
}