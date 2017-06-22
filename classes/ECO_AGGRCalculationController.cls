public with sharing class ECO_AGGRCalculationController {
	
	private IncentiveProject__c prj; 

    public ECO_AGGRCalculationController(ApexPages.StandardController stdController) {

        prj = (IncentiveProject__c)stdController.getRecord();
        
        System.Debug('prj' + prj);
        
        String qry = 'select Id,';
        qry += String.join(getAllFields(), ',');
        qry += ' from IncentiveProject__c where Id = \'' + prj.Id + '\'';
        
        System.Debug('qry' + qry);
        
        prj = Database.query(qry);

    }
    	
	public PageReference calculateAGGR(){
		try {
	        List<String> allFields = getAllFields();
	        
	        String qry = 'select Id,';
        	qry += String.join(allFields, ',');
        	qry += ' from IncentiveProject__c where Aggregated_Parent_Project__c = \'' + prj.Id + '\'';
        	
        	List<IncentiveProject__c> prjs = Database.query(qry);
        	
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
        	
        	update prj;
        		
	        
	        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Aggregate data successful!'));  
		} catch (Exception e){
		   	ApexPages.addMessages(e);  
		}
        
        return null;

    }
    
    public PageReference back(){
		PageReference pr = new PageReference('/' + prj.Id);
		pr.SetRedirect(true);
        return pr;

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