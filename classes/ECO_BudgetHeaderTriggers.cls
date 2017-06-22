public without sharing class ECO_BudgetHeaderTriggers {
	public static Boolean run = true;
	public static Boolean isSysAdmin;
	public static Map<Id, pse__Proj__c> mapProjects = new Map<Id, pse__Proj__c>();
	
	/**
     * @Description Getter function to see if the user is a "System Administrator" 
     *              in a language agnostic way 
     * @Author  NTT Data - Omar Abdel-Latief
     * @Date    12/16/2016
     *
     * @param 
     * @return  
     **/
    public static Boolean getIsSysAdmin() {
        if (isSysAdmin == null) {
            isSysAdmin = [SELECT Id, PermissionsAuthorApex FROM Profile WHERE Id = :UserInfo.getProfileId()].PermissionsAuthorApex;
        }

        return isSysAdmin;
    }

	public static void validateBudgetHeadersAreUpdatable(List<BudgetHeader__c> newBudgetHeaders, Map<Id, BudgetHeader__c> oldBudgetHeaderMap) {

		if(!run) {
			return;
		}

		BudgetHeader__c oldBudgetHeader;

		for(BudgetHeader__c newBudgetHeader:newBudgetHeaders) {
			oldBudgetHeader = oldBudgetHeaderMap.get(newBudgetHeader.Id);
			if((oldBudgetHeader.Status__c == 'Forecast' ||  oldBudgetHeader.Status__c == 'Approved') &&  
				((newBudgetHeader.Status__c != 'Approved' && newBudgetHeader.Status__c != 'Forecast')
                      || (oldBudgetHeader.TotalCost__c != newBudgetHeader.TotalCost__c) 
				 	  || (oldBudgetHeader.AppliedTotalRevenue__c != newBudgetHeader.AppliedTotalRevenue__c))) {

				if(!UserInfo.getUserName().toLowerCase().contains('integration@aecom.com') && !UserInfo.getUserName().toLowerCase().contains('integrations@aecom.com') && !getIsSysAdmin()){
					newBudgetHeader.addError('You cannot edit a Budget in Forecast or Approved Status.');
				}
			}
		}	
	}	
	
	public static void copyDefaultsFromProject(List<BudgetHeader__c> newBHList) {
		if (!run) return;

		Set<Id> projIds = new Set<Id>();

		// Map<Id, pse__Proj__c> mapProjects = new Map<Id, pse__Proj__c>();

		for (BudgetHeader__c bh : newBHList) {
			// Check if we already cached it before we add it to the list to query
			if(!mapProjects.containsKey(bh.Project__c)) {
				projIds.add(bh.Project__c);
			}
		}

		// Save the SOQL hit if we already have everything we need cached
		if (projIds.size() > 0) {
			mapProjects.putAll( [Select Id, BudgetStrategyRevenue__c, ProjectFunctionalCurrencyCode__c  From pse__Proj__c Where Id IN :projIds]);
		}

		for (BudgetHeader__c bh : newBHList) {
	    	pse__Proj__c proj = mapProjects.get(bh.Project__c);
	    	bh.CurrencyIsoCode = proj.ProjectFunctionalCurrencyCode__c;
	    	bh.BudgetStrategyRevenue__c = proj.BudgetStrategyRevenue__c;
	    }
	}
	
	public static void cascadeApprovalStatus (Map<Id, BudgetHeader__c> bhNew, Map<Id, BudgetHeader__c> bhOld) {
		if (!run || !ECO_TriggerSettings.getIsTriggerEnabled('BH_cascadeApproval')) {
			return;
		}
		
		Set<Id> budgetHeaderIdsThatChangedStatus = new Set<Id>();
		
		for (BudgetHeader__c bh : bhNew.values()) {
			if (bh.Status__c != bhOld.get(bh.Id).Status__c) {  // Safe, since we always run after update.
				budgetHeaderIdsThatChangedStatus.add(bh.Id);
			}
		}
		
		// OAL - 3/3/17 - SAVE THE SOQL!!
		if (budgetHeaderIdsThatChangedStatus.size() > 0) {
			List<BudgetAssignment__c> budgetAssignmentsToUpdate = new List<BudgetAssignment__c>();
			
			for (BudgetResource__c br : [SELECT Id 
												, (SELECT Id 
														, BudgetResource__r.BudgetHeader__r.Status__c
													FROM BudgetAssignments__r)
											FROM BudgetResource__c 
											WHERE BudgetHeader__c IN :budgetHeaderIdsThatChangedStatus]) {
				for (BudgetAssignment__c ba : br.BudgetAssignments__r) {
					ba.ApprovalStatus__c = ba.BudgetResource__r.BudgetHeader__r.Status__c;
					budgetAssignmentsToUpdate.add(ba);
				}
			}
			
			System.debug('___BudgetHeader: ECO_BudgetAssignmentTriggers.runCount='+ECO_BudgetAssignmentTriggers.runCount);

			update budgetAssignmentsToUpdate;
		}
	}
	
	public static void rollUpValuesToProject (List<BudgetHeader__c> newBHList, List<BudgetHeader__c> oldBHList) {
		if (!run || !ECO_TriggerSettings.getIsTriggerEnabled('BH_rollUpToProject')) {
			return;
		}
		
		ECO_Service_Budget.rollUpValuesToProject(newBHList, oldBHList);

		/*bak commented Map<Id, pse__Proj__c> projectsToUpdate = new Map<Id, pse__Proj__c>();
		
		for (BudgetHeader__c bh : newBHList) {
			projectsToUpdate.put(bh.Project__c, new pse__Proj__c(Id = bh.Project__c
																, TotalApprovedRevenue__c = 0
																, TotalApprovedCost__c = 0
																, TotalForecastRevenue__c = 0
																, TotalForecastCost__c = 0));
		}
		
		for (BudgetHeader__c bh : oldBHList) {
			projectsToUpdate.put(bh.Project__c, new pse__Proj__c(Id = bh.Project__c
																, TotalApprovedRevenue__c = 0
																, TotalApprovedCost__c = 0
																, TotalForecastRevenue__c = 0
																, TotalForecastCost__c = 0));
		} */
		
		/*for (AggregateResult ar : [SELECT Project__c
											, SUM(AppliedTotalRevenue__c) totalRevenue
											, SUM(TotalCost__c) totalCost
									FROM BudgetHeader__c
									WHERE Project__c IN :projectsToUpdate.keySet()
										AND Status__c = 'Approved'
									GROUP BY Project__c]) {
			pse__Proj__c projToUpdate = projectsToUpdate.get((Id)ar.get('Project__c'));
			projToUpdate.TotalApprovedRevenue__c = (Decimal)ar.get('totalRevenue');
			projToUpdate.TotalApprovedCost__c = (Decimal)ar.get('totalCost');*/
		/*bak for (BudgetHeader__c bh : [SELECT Project__c
											, AppliedTotalRevenue__c
											, TotalCost__c 
									FROM BudgetHeader__c
									WHERE Project__c IN :projectsToUpdate.keySet()
										AND Status__c = 'Approved']) {
			pse__Proj__c projToUpdate = projectsToUpdate.get(bh.Project__c);
			projToUpdate.TotalApprovedRevenue__c = bh.AppliedTotalRevenue__c + projToUpdate.TotalApprovedRevenue__c;
			projToUpdate.TotalApprovedCost__c = bh.TotalCost__c + projToUpdate.TotalApprovedCost__c;
			projToUpdate.TotalForecastRevenue__c = bh.AppliedTotalRevenue__c + projToUpdate.TotalForecastRevenue__c;
			projToUpdate.TotalForecastCost__c = bh.TotalCost__c + projToUpdate.TotalForecastCost__c;

		} */
		
		/*for (AggregateResult ar : [SELECT Project__c
											, SUM(AppliedTotalRevenue__c) totalRevenue
											, SUM(TotalCost__c) totalCost
									FROM BudgetHeader__c
									WHERE Project__c IN :projectsToUpdate.keySet()
										AND Status__c = 'Forecast'
									GROUP BY Project__c]) {
			pse__Proj__c projToUpdate = projectsToUpdate.get((Id)ar.get('Project__c'));
			projToUpdate.TotalForecastRevenue__c = (Decimal)ar.get('totalRevenue') + projToUpdate.TotalApprovedRevenue__c;
			projToUpdate.TotalForecastCost__c = (Decimal)ar.get('totalCost') + projToUpdate.TotalApprovedCost__c;
		}*/
		/*bak for (BudgetHeader__c bh : [SELECT Project__c
											, AppliedTotalRevenue__c
											, TotalCost__c 
									FROM BudgetHeader__c
									WHERE Project__c IN :projectsToUpdate.keySet()
										AND Status__c = 'Forecast']) {
			pse__Proj__c projToUpdate = projectsToUpdate.get(bh.Project__c);
			projToUpdate.TotalForecastRevenue__c = bh.AppliedTotalRevenue__c + projToUpdate.TotalForecastRevenue__c;
			projToUpdate.TotalForecastCost__c = bh.TotalCost__c + projToUpdate.TotalForecastCost__c;
		}
		
		update projectsToUpdate.values(); // This will always have values in it... no need to check for isempty
		*/
	}
}