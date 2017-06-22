public without sharing class ECO_BudgetGenericFilterController {
	public IBudgetSave parentController {get; set; }
	public String strResourceType { 
		get; 
		set {
			if (strResourceType == null) {
				strResourceType = value;
				if (budgetHeaderId != null)
					init();
			}
		}
	}
	public String budgetHeaderId { 
		get; 
		set {
			if (budgetHeaderId == null) {
				budgetHeaderId = value;
				if (strResourceType != null)
					init();
			}
		}
	}
	public String memberids {get; set;}
	public List<ProjectTeamMember__c> memberList {get; set;}
	public List<BudgetResource__c> brList {get; set;}
	public pse__Proj__c theProject {get; set;}
	public Map<Id, Boolean> mapSelected {get; set;}
	public BudgetHeader__c budgetHeader {get; set;}

	public ECO_BudgetGenericFilterController() {
		
	}

	public void init() {
		budgetHeader = [select id, Project__c from BudgetHeader__c where id = :budgetHeaderId];

		System.debug(LoggingLevel.ERROR, 'budget header id - ' + budgetHeader.id);

		if (budgetHeader.id == null)
			return;

		theProject = [select id, DefaultBillRate__c, DefaultUpliftLabor__c from pse__Proj__c where id = :budgetHeader.Project__c];

		populateProjectTeam();

	}

	public void populateProjectTeam() {
		Id projid = theProject.id;
		Cookie resourceList = ApexPages.currentPage().getCookies().get('' + budgetHeaderId);
		Set<String> brIds = new Set<String>();
		mapSelected = new Map<Id, Boolean>();
		
		if (resourceList != null) {
			brIds.addAll(resourceList.getValue().split(','));
		}

		system.debug('---budgetHeaderId ' + budgetHeaderId + ' - ' + 'strResourceType: ' + strResourceType);
		memberList = [select id, role__c, projectrole__r.name, name__c, name, startdate__c, enddate__c, Phone__c, Email__c from projectteammember__c where project__c = :projid order by name, projectrole__r.name];
		brList = [Select Id, Name, ColumnHeader__c FROM BudgetResource__c 
					WHERE BudgetHeader__c = :budgetHeaderId AND ResourceType__c = :strResourceType AND IsHidden__c = false
					ORDER BY ColumnHeader__c asc];


		for (BudgetResource__c br : brList)	{

			Boolean isSelected = brIds.contains(br.Id);

			mapSelected.put(br.Id, isSelected);
		}	

	}

	public PageReference filterResources() {
		List<String> memberidsList = memberids.split(',');
		Cookie resourceList = new Cookie('' + budgetHeaderId, memberids, null, 2628000,false); 
		/*
		memberidsList.add(null); // Pull Generic Resources as well for now

		System.debug('memberlist - ' + memberids);

		// List<ProjectTeamMember__c> membersTemp = [select id, Contact__c from ProjectTeamMember__c where id in :memberidsList];
		// List<BudgetResource__c> brTemp = [select id from BudgetResource__c where ProjectTeamMember__c in :memberidsList]
		
		String brIds = '';

		for ( BudgetResource__c br : [select id from BudgetResource__c where BudgetHeader__c = :budgetHeaderId AND ProjectTeamMember__c in :memberidsList]) {
			brIds += '' + br.Id + ',';
		}
		*/
		ApexPages.currentPage().setCookies(new Cookie[]{resourceList});

		PageReference pr = parentController.hardRefresh();
		pr.getParameters().put('brFilterIds', memberids);
		/*
		Cookie brfilterCookie = new Cookie('' + budgetHeaderId,'1',null,-1,false);

		Cookie brFilterIds = ApexPages.currentPage().getCookies().get('brFilterIds');
    	
    	counter =
        // If this is the first time the user is accessing the page, 
        // create a new cookie with name 'counter', an initial value of '1', 
        // path 'null', maxAge '-1', and isSecure 'false'. 
        if (counter == null) {
            counter = new Cookie('counter','1',null,-1,false);
        } else {
        // If this isn't the first time the user is accessing the page
        // create a new cookie, incrementing the value of the original count by 1
            Integer count = Integer.valueOf(counter.getValue());
            counter = new Cookie('counter', String.valueOf(count+1),null,-1,false);
        }
    
        // Set the new cookie for the page
        ApexPages.currentPage().setCookies(new Cookie[]{counter});
		*/
		return pr;
	}


}