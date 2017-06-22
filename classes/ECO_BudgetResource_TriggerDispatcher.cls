/* 	When a record is saved AND the Expenditure Type value is changed (from null or another value), 
	take the Expenditure Type value, look it up in ExpenditureType.Name. Pick up the Group, Subgroup, 
	and Resource Type values and set them on the corresponding fields in the BudgetResource object.
*/
public without sharing class ECO_BudgetResource_TriggerDispatcher
{
	public static void Main(List<BudgetResource__c> newList, Map<Id, BudgetResource__c> newMap, 
		List<BudgetResource__c> oldList, Map<Id, BudgetResource__c> oldMap, Boolean isBefore, Boolean isAfter, 
		Boolean isInsert, Boolean isUpdate, Boolean isDelete, Boolean isExecuting)
	{
		if (isBefore) {
			if (!isDelete) {
				List<BudgetResource__c> budgetResourceListToSave = new List<BudgetResource__c>();
				for (BudgetResource__c budgetResource : newList) {
					if (budgetResource.ExpenditureType__c != null) {
						if (isInsert) {
							System.debug('___isInsert: budgetResource='+budgetResource);
							budgetResourceListToSave.add(budgetResource);
						}
						else if (isUpdate) {
		                    if (budgetResource.ExpenditureType__c != oldMap.get(budgetResource.id).ExpenditureType__c) {
		                    	System.debug('___isUpdate: budgetResource='+budgetResource);
								budgetResourceListToSave.add(budgetResource);
		                    }
						}
					}
				}
				adjustBudgetResources(budgetResourceListToSave);
			}
		}
	}

	private static void adjustBudgetResources(List<BudgetResource__c> budgetResourceList) {
		System.debug('___START adjustBudgetResources');
		if (budgetResourceList != null && budgetResourceList.size() > 0) {
			try {
				Set<String> expTypeSet = new Set<String>();
				for (BudgetResource__c budgetResource : budgetResourceList) {
					expTypeSet.add(budgetResource.ExpenditureType__c);
				}
				System.debug('___expTypeSet='+expTypeSet);
				
				Map<String, ExpenditureType__c> expTypeMap = new Map<String, ExpenditureType__c>();
				List<ExpenditureType__c> expTypeList =
					[SELECT Name, ExpenditureCategory__c, PLReportCategory__c, ResourceType__c 
					 FROM ExpenditureType__c WHERE Name IN: expTypeSet];
				for (ExpenditureType__c et : expTypeList) {
					expTypeMap.put(et.Name, et);
				}
				System.debug('___expTypeMap='+expTypeMap);

				for (BudgetResource__c budgetResource : budgetResourceList) {
					String expTypeName = budgetResource.ExpenditureType__c;
					ExpenditureType__c expType = (ExpenditureType__c) expTypeMap.get(expTypeName);
					System.debug('___expType='+expType);
					if (expType != null) {
						budgetResource.ExpenditureResourceType__c = expType.ResourceType__c;
						budgetResource.ExpenditureTypeCategory__c = expType.ExpenditureCategory__c;
						budgetResource.PLReportCategory__c = expType.PLReportCategory__c;
						System.debug('___Adjusted budgetResource='+budgetResource);
					}
				}
			}
			catch(Exception e) {
				System.debug(e.getStackTraceString());
			}
		}
		System.debug('___END adjustBudgetResources');
	}
}