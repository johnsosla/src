public without sharing class ECO_Service_ProjectTeamMemberBatch {
	public ECO_Service_ProjectTeamMemberBatch() {
		
	}

	/**
	 *  Helper class for the batch start method
	 *
	 * @Author  NTT Data - Tim Chiang
	 * @Date    Nov 2016
	 *
	 * @param   regionOuIds
	 * @param   fiscalList
	 * @return  string
	**/
	public static string BatchStartHelper(string regionOuIds){
		string query;


		query = 'SELECT Id,name,Department__c,  Contact__c,LaborCost01FiscalMonthAgo__c,LaborCost02FiscalMonthAgo__c,'+
			'LaborCost03FiscalMonthsAgo__c,LaborCost04FiscalMonthsAgo__c,LaborCost05FiscalMonthsAgo__c,'+
			'LaborCost06FiscalMonthsAgo__c,LaborCost07FiscalMonthsAgo__c,LaborCost08FiscalMonthsAgo__c,'+
			'LaborCost09FiscalMonthsAgo__c,LaborCost10FiscalMonthsAgo__c,LaborCost11FiscalMonthsAgo__c,'+
			'LaborCost12FiscalMonthsAgo__c,LaborHours01FiscalMonthAgo__c,LaborHours02FiscalMonthsAgo__c,'+
			'LaborHours03FiscalMonthsAgo__c,LaborHours04FiscalMonthsAgo__c,LaborHours05FiscalMonthsAgo__c,'+
			'LaborHours06FiscalMonthsAgo__c,LaborHours07FiscalMonthsAgo__c,LaborHours08FiscalMonthsAgo__c,'+
			'LaborHours09FiscalMonthsAgo__c,LaborHours10FiscalMonthsAgo__c,LaborHours11FiscalMonthsAgo__c,'+
			'LaborHours12FiscalMonthsAgo__c, PersonId__c, Project__c, Project__r.pse__Is_Active__c'+
			' FROM ProjectTeamMember__c'+
			' WHERE Project__r.pse__Stage__c=\'Execution\' ';
		if( regionOuIds != null && regionOuIds != ''){
			query += ' AND Project__r.OuIdText__c IN (';
			for( String region : regionOuIds.Split(',')){
				query += '\'' + region + '\',';
			}
			query = query.left(query.length()-1) + ')';
		}
			
		//System.debug('PTM SOQL='+query);


	    return query;

	}

	/**
	 *
	 * @Author  NTT Data - Tim Chiang
	 * @Date    Nov 2016
	 *
	 * @return  List<String>
	**/
	public static List<String> formFiscalList(){

		List<String> fiscalList = new List<String>();

	    // scope limiting optimization
	    ECOBatchOptimization__c eBo = ECOBatchOptimization__c.getvalues('ECO_ProjectTeamMemberBatch');

	    Date scopeDate = Date.today();
	    Boolean useOptimization = false;

	    if(eBo != null){
	      if(eBo.UseOptimization__c){
	        useOptimization = true;
	      }

	      if(eBo.TestDate__c != null){
	        scopeDate = eBO.TestDate__c;
	      }
	    }

	    pse__Time_Period__c cpt = [SELECT id, name, pse__End_Date__c, pse__start_Date__c, TimePeriodCode__c, pse__type__c 
	      FROM pse__Time_Period__c WHERE pse__type__c = 'Month' AND pse__start_Date__c <=: scopeDate AND pse__end_date__c >=: scopeDate 
	      ORDER BY pse__start_date__c DESC LIMIT 1];

	    if(cpt != null){
	      String currentFiscalPeriod = cpt.TimePeriodCode__c;

	      fiscalList = new List<String>();

	      if(useOptimization && currentFiscalPeriod != null){
	        if (cpt.pse__start_Date__c != null && cpt.pse__start_Date__c == scopeDate) {
	          fiscalList = fiscalMethod(currentFiscalPeriod);
	        } else {
	          fiscalList.add(currentFiscalPeriod);
	        }
	      } else {
	        fiscalList = fiscalMethod(currentFiscalPeriod);
	      }
	    }

	    //system.debug('FISCAL PERIODS @@@ ' + fiscalList);

	    return fiscalList;
	}


	/**
	 *
	 * @Author  NTT Data - Tim Chiang
	 * @Date    Nov 2016
	 *
	 * @param   str
	 * @return  List<String>
	**/
	public static List<String> fiscalMethod(String str){
		String Year = str.subStringAfter('FY').subStringBefore('-');
		String Month = str.subStringAfter('FY').subStringAfter('-');
		List<String> fiscalList = new List<String>();
		fiscalList.add(str);
		Integer d =0;
		Integer d1 =0;
		for (Integer i=0; i<=13; i++)
		{
			Integer Mon = Integer.valueOf(Month)-i;
			if (Mon >=1)
			{
				String ste;
				if (Mon <10)
					ste = 'FY'+Year+'-0'+Mon;
				else
					ste = 'FY'+Year+'-'+Mon;
				fiscalList.add(ste); 
			 }
			 else
			 {
				Integer lastyear;
				Integer lastYearMonth;
				if(d !=12)
				{
					 lastyear = Integer.valueof(Year)-1;
					lastYearMonth = 12-d;
					String ste;
					if(lastYearMonth <10)
						ste = 'FY'+lastyear+'-0'+lastYearMonth;
					else
						ste = 'FY'+lastyear+'-'+lastYearMonth;
					 
					fiscalList.add(ste);
					d = d+ 1; 
				 }
				 else{
					lastyear = integer.valueof(Year)-2;
					lastYearMonth = 12-d1;            
					String ste;
					if (lastYearMonth <10)
						ste = 'FY'+lastyear+'-0'+lastYearMonth;
					else
						ste = 'FY'+lastyear+'-'+lastYearMonth;
								 
					fiscalList.add(ste);
					d1 = d1+1;
				 }
			 }
		}  
		return fiscalList;
	}


}