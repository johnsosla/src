global class INC_AGGRCalculationBatch implements Database.Batchable<sObject> {
	
	global INC_AGGRCalculationBatch() {}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(getQuery('Name LIKE \'AGGR:%\''));
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<IncentiveProject__c> projsToUpdate = new List<IncentiveProject__c>();  
        List<String> allFields = getAllFields();

		for(sObject s : scope){
			IncentiveProject__c prj = (IncentiveProject__c)s; 
        	List<IncentiveProject__c> prjs = Database.query(getQuery('Aggregated_Parent_Project__c = \'' + prj.Id + '\''));
        	
        	for (String f: allFields){
        		prj.put(f, 0);
        	}

        	for (IncentiveProject__c p: prjs){
        		for (String f: allFields){
        			Double a = prj.get(f) != null ? (Double) prj.get(f) : 0;
        			Double b = p.get(f) != null ? (Double) p.get(f) : 0;
        			prj.put(f, a + b);
        		}
                prj.put('ActualPercentProjectCompleteITD__c', (Double) prj.get('ForecastCostBudget__c') != 0 ? (Double) prj.get('ActualTotalCostsITD__c') / (Double) prj.get('ForecastCostBudget__c') * 100 : 0);
                prj.put('ApprovedSalaryCostMultiplier__c', (Double) prj.get('ApprovedDPEBudget__c') != 0 ? (Double) prj.get('ApprovedNSRBudget__c') / (Double) prj.get('ApprovedDPEBudget__c') : 0);
                prj.put('ApprovedDirectLaborMultiplier__c', (Double) prj.get('ApprovedDirectLaborBudget__c') != 0 ? (Double) prj.get('ApprovedNSRBudget__c') / (Double) prj.get('ApprovedDirectLaborBudget__c') : 0);
                prj.put('ForecastSalaryCostMultiplier__c', (Double) prj.get('ForecastDPEBudget__c') != 0 ? (Double) prj.get('ForecastNSRBudget__c') / (Double) prj.get('ForecastDPEBudget__c') : 0);
                prj.put('ForecastDirectLaborMultiplier__c', (Double) prj.get('ForecastDirectLabor__c') != 0 ? (Double) prj.get('ForecastNSRBudget__c') / (Double) prj.get('ForecastDirectLabor__c') : 0);
                //prj.put('ActualSalaryCostMultiplier__c', (Double) prj.get('ActualDPEBudgetITD__c') != 0 ? (Double) prj.get('ActualNSRITD__c') / (Double) prj.get('ActualDPEBudgetITD__c') : 0);
                prj.put('ActualLaborCostMultiplier__c', (Double) prj.get('AcutalDirectLaborITD__c') != 0 ? (Double) prj.get('ActualNSRITD__c') / (Double) prj.get('AcutalDirectLaborITD__c') : 0);
        	}
    		projsToUpdate.add(prj);
    	}
		try{
			update projsToUpdate;
		}
		catch(Exception e){
			system.debug(logginglevel.error,'Handling aggregate project data error: ' + e.getMessage());
		}
	}
	
	global void finish(Database.BatchableContext BC) {}

	private String getQuery(String whereClause){
        String qry = 'SELECT Id,';
    	qry += String.join(getAllFields(), ',');
    	qry += ' FROM IncentiveProject__c WHERE ' + whereClause;
		return qry;
	}
	
    private List<String> getAllFields(){
    	List<String> flds = new List<String>();
		Map <String, Schema.SObjectField> fieldMap = Schema.SObjectType.IncentiveProject__c.fields.getMap();
		for(Schema.SObjectField sfield : fieldMap.Values()){
			schema.describefieldresult dfield = sfield.getDescribe();
			if (dfield.getType() == Schema.DisplayType.Currency && dfield.isUpdateable()){
				flds.add(dfield.getName());
			}
		}
		return flds;
    }
}