public without sharing class ECO_RevenueTriggers {
    public static Boolean run = true;
    
    public static void calculateFiscalMonths(list<Revenue__c> revenues)
    {
        if (!run) { return; }
        
            list<date> enddatelist = new list<date>();
        for (Revenue__c ba : revenues){
             if (ba.GLDate__c != null){ 
                 
                 enddatelist.add((ba.GLDate__c).addmonths(2));
                 enddatelist.add((ba.GLDate__c).addmonths(-3));
             }
        }
		// Time period
         List<pse__Time_Period__c> timePeriods  = new  List<pse__Time_Period__c>();
        if(enddatelist.size()>0)
        {
            timePeriods = ECO_Utils_Date.calcTimePeriods(enddatelist,'Month');
            
            // Time period
           // List<pse__Time_Period__c> timePeriods = ECO_ProjectTaskService.calcTimePeriods;
		
		pse__Time_Period__c fm = null;
		for (Revenue__c r : revenues){
			
			if (r.GLDate__c != null){	
				fm = ECO_Utils_Date.getFiscalPeriod(r.GLDate__c, 0, timePeriods);  
				if (fm != null){
					r.GLDateFiscalMonth__c = fm.TimePeriodCode__c;
				}
				
				fm = ECO_Utils_Date.getFiscalPeriod(r.GLDate__c, 1, timePeriods);  
				if (fm != null){
					r.GLDatePreviousFiscalMonth__c = fm.TimePeriodCode__c;
				}
			}
			
			if (r.PADate__c != null){	
				fm = ECO_Utils_Date.getFiscalPeriod(r.PADate__c, 0, timePeriods);  
				if (fm != null){
					r.PADateFiscalMonth__c = fm.TimePeriodCode__c;
				}
				
				fm = ECO_Utils_Date.getFiscalPeriod(r.PADate__c, 1, timePeriods);  
				if (fm != null){
					r.PADatePreviousFiscalMonth__c = fm.TimePeriodCode__c;
				}
			}						
		}
	}
    }

}