global class ECO_ProjectTeamMemberBatch extends ECO_BatchAdminService {
		public static final Integer DEFAULT_BATCH_SIZE = 200;
		public String query {get; set;}
		public List<String> fiscalList{get;set;}
			
	public ECO_ProjectTeamMemberBatch() {}

	public ECO_ProjectTeamMemberBatch(Integer batchSize) {    
		if (batchSize != null && batchSize > 0) {
				this.batchSize = batchSize;
		}
	}
	

	
	/**
	 *  setup the query to run the batch against
	 *
	 * @Author  NTT Data - Arman Shah
	 * @Date    query changed in August 2016
	 *
	 * @param   BC
	 * @return  Database.QueryLocator
	**/
	global Database.QueryLocator start(Database.BatchableContext BC) {
		this.logId = ECO_Service_BatchLog.logJobStart('ECO_ProjectTeamMemberBatch', this.batchStream, this.regionOuIds, BC.getJobId(), this.jobName);

		this.query = ECO_Service_ProjectTeamMemberBatch.BatchStartHelper(this.regionOuIds);
		this.fiscalList = ECO_Service_ProjectTeamMemberBatch.formFiscalList();

		//system.debug('FISCAL PERIODS @@@@ ' + this.fiscalList);

		return Database.getQueryLocator(this.query);
	}

	/**
	 *  
	 *
	 * @Author  NTT Data - ?
	 * @Date    
	 *
	 * @param   BC
	 * @param   scope
	 * @return  
	**/
	global void execute(Database.BatchableContext BC, List<ProjectTeamMember__c> scope) {

		ECO_Project_TeamMember_Triggers.run = false;
		List<String> projectIdList = new List<String>();
		List<String> personIdList = new List<String>();
		Map<String,decimal> labourHoursMap = new map<String,decimal>();
		Map<String,decimal> labourCostMap = new map<String,decimal>();
		List<ProjectTeamMember__c> teamMemberToBeUpdatedList = new List<ProjectTeamMember__c>();
		for (ProjectTeamMember__c ptm:scope ){


			if (ptm.project__c !=null)
				projectIdList.add(ptm.project__c);
			if (ptm.personid__c !=null)
				personIdList.add(ptm.personid__c);
		}
		
		if (projectIdList.size()>0 || personIdList.size()>0)
		{
			for (ExpendItem__c exp :[select id,Quantity__c,  PersonId__c,project__r.pse__Is_Active__c,Project__c,ExpenditureType__c, ExpenditureItemDate__c,ExpenditureDateFiscalMonth__c from ExpendItem__c  where personid__c !=null  and project__r.pse__Is_Active__c = true and project__c IN:projectIdList and personid__c IN:Personidlist and ExpenditureDateFiscalMonth__c IN:fiscalList])
			{
					if (exp.quantity__c !=null)
					{
					
							if (labourHoursMap.containsKey(exp.personid__c+exp.project__c+exp.ExpenditureDateFiscalMonth__C))
							{
											Decimal Qty = labourHoursMap.get(exp.personid__c+exp.project__c+exp.ExpenditureDateFiscalMonth__C) + exp.quantity__c;
											labourHoursMap.put(exp.personid__c+exp.project__c+exp.ExpenditureDateFiscalMonth__C,qty);
									
							}
							else
							{
											labourHoursMap.put(exp.personid__c+exp.project__c+exp.ExpenditureDateFiscalMonth__C,exp.quantity__c);
							}
					}
			} 
		 
			for (CostDistLine__c cdl :[select id,ExpenditureItem__r.project__c,ExpenditureItem__r.PersonId__c,ExpenditureItem__c,ProjectNumber__c,ProjectFunctionalBurdenedCost__c,PAFiscalMonth__c,ExpenditureItem__r.project__r.pse__Is_Active__c  from CostDistLine__c where ExpenditureItem__r.PersonId__c !=null and ExpenditureItem__r.project__r.pse__Is_Active__c = true and ExpenditureItem__r.project__c IN:projectIdList and ExpenditureItem__r.PersonId__c IN:personIdList and PAFiscalMonth__c IN:fiscalList])
			{
				 if (cdl.ProjectFunctionalBurdenedCost__c !=null)
				{
			
					if (labourCostMap.containsKey(cdl.ExpenditureItem__r.PersonId__c+cdl.ExpenditureItem__r.project__c+cdl.PAFiscalMonth__c))
					{
						Decimal Cost = labourCostMap.get(cdl.ExpenditureItem__r.PersonId__c+cdl.ExpenditureItem__r.project__c+cdl.PAFiscalMonth__c)+ cdl.ProjectFunctionalBurdenedCost__c;
						labourCostMap.put((cdl.ExpenditureItem__r.PersonId__c+cdl.ExpenditureItem__r.project__c+cdl.PAFiscalMonth__c),cost);
					}
				}
				else
				{
					labourCostMap.put((cdl.ExpenditureItem__r.PersonId__c+cdl.ExpenditureItem__r.project__c+cdl.PAFiscalMonth__c),cdl.ProjectFunctionalBurdenedCost__c);
				}
			}
			
			for(ProjectTeamMember__c ptm:scope){

				if(labourHoursMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[0]))
					ptm.LaborHours01FiscalMonthAgo__c = labourHoursMap.get(ptm.personid__c+ptm.project__c+fiscalList[0]);


        if(fiscalList.size() > 1){

  				if(labourHoursMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[1]))
  					ptm.LaborHours02FiscalMonthsAgo__c = labourHoursMap.get(ptm.personid__c+ptm.project__c+fiscalList[1]);
  				if(labourHoursMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[2]))
  					ptm.LaborHours03FiscalMonthsAgo__c = labourHoursMap.get(ptm.personid__c+ptm.project__c+fiscalList[2]);
  				if(labourHoursMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[3]))
  					ptm.LaborHours04FiscalMonthsAgo__c = labourHoursMap.get(ptm.personid__c+ptm.project__c+fiscalList[3]);
  				if(labourHoursMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[4]))
  					ptm.LaborHours05FiscalMonthsAgo__c = labourHoursMap.get(ptm.personid__c+ptm.project__c+fiscalList[4]);
  				if(labourHoursMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[5]))
  					ptm.LaborHours06FiscalMonthsAgo__c = labourHoursMap.get(ptm.personid__c+ptm.project__c+fiscalList[5]);
  				if(labourHoursMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[6]))
  					ptm.LaborHours07FiscalMonthsAgo__c = labourHoursMap.get(ptm.personid__c+ptm.project__c+fiscalList[6]);
  				if(labourHoursMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[7]))
  					ptm.LaborHours08FiscalMonthsAgo__c = labourHoursMap.get(ptm.personid__c+ptm.project__c+fiscalList[7]);
  				if(labourHoursMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[8]))
  					ptm.LaborHours09FiscalMonthsAgo__c = labourHoursMap.get(ptm.personid__c+ptm.project__c+fiscalList[8]);
  				if(labourHoursMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[9]))
  					ptm.LaborHours10FiscalMonthsAgo__c = labourHoursMap.get(ptm.personid__c+ptm.project__c+fiscalList[9]);
  				if(labourHoursMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[10]))
  					ptm.LaborHours11FiscalMonthsAgo__c = labourHoursMap.get(ptm.personid__c+ptm.project__c+fiscalList[10]);
  				if(labourHoursMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[11]))
  					ptm.LaborHours12FiscalMonthsAgo__c = labourHoursMap.get(ptm.personid__c+ptm.project__c+fiscalList[11]);
				}


				if(labourCostMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[0]))
					ptm.LaborCost01FiscalMonthAgo__c = labourCostMap.get(ptm.personid__c+ptm.project__c+fiscalList[0]);

        if(fiscalList.size() > 1){

  				if(labourCostMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[1]))
  					ptm.LaborCost02FiscalMonthAgo__c = labourCostMap.get(ptm.personid__c+ptm.project__c+fiscalList[1]);
  				if(labourCostMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[2]))
  					ptm.LaborCost03FiscalMonthsAgo__c = labourCostMap.get(ptm.personid__c+ptm.project__c+fiscalList[2]);
  				if(labourCostMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[3]))
  					ptm.LaborCost04FiscalMonthsAgo__c = labourCostMap.get(ptm.personid__c+ptm.project__c+fiscalList[3]);
  				if(labourCostMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[4]))
  					ptm.LaborCost05FiscalMonthsAgo__c = labourCostMap.get(ptm.personid__c+ptm.project__c+fiscalList[4]);
  				if(labourCostMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[5]))
  					ptm.LaborCost06FiscalMonthsAgo__c = labourCostMap.get(ptm.personid__c+ptm.project__c+fiscalList[5]);
  				if(labourCostMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[6]))
  					ptm.LaborCost07FiscalMonthsAgo__c = labourCostMap.get(ptm.personid__c+ptm.project__c+fiscalList[6]);
  				if(labourCostMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[7]))
  					ptm.LaborCost08FiscalMonthsAgo__c = labourCostMap.get(ptm.personid__c+ptm.project__c+fiscalList[7]);
  				if(labourCostMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[8]))
  					ptm.LaborCost09FiscalMonthsAgo__c = labourCostMap.get(ptm.personid__c+ptm.project__c+fiscalList[8]);
  				if(labourCostMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[9]))
  					ptm.LaborCost10FiscalMonthsAgo__c = labourCostMap.get(ptm.personid__c+ptm.project__c+fiscalList[9]);
  				if(labourCostMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[10]))
  					ptm.LaborCost11FiscalMonthsAgo__c = labourCostMap.get(ptm.personid__c+ptm.project__c+fiscalList[10]);
  				if(labourCostMap.containsKey(ptm.personid__c+ptm.project__c+fiscalList[11]))
  					ptm.LaborCost12FiscalMonthsAgo__c = labourCostMap.get(ptm.personid__c+ptm.project__c+fiscalList[11]);
			  }

				teamMemberToBeUpdatedList.add(ptm);
			}
		}
		if(teamMemberToBeUpdatedList.size() > 0)
				update teamMemberToBeUpdatedList ;
	}
	
	/**
	 *  
	 *
	 * @Author  NTT Data - ?
	 * @Date    
	 *
	 * @param   BC
	 * @param   scope
	 * @return  
	*/
	global void execute(SchedulableContext sc)
	{
		ECO_ProjectTeamMemberBatch b = new ECO_ProjectTeamMemberBatch(this.batchSize);
		b.batchSize = this.batchSize;
		b.batchStream = this.batchStream;
		b.regionOuIds = this.regionOuIds;
		b.jobName = this.jobName;
		if (this.batchSize == null) {
		//System.debug('___Batch size='+DEFAULT_BATCH_SIZE);
			database.executebatch(b, DEFAULT_BATCH_SIZE);
		}
		else {
		//System.debug('___Batch size='+this.batchSize);
			database.executebatch(b, this.batchSize);
		}
	}

	/**
	 *  
	 *
	 * @Author  NTT Data - ?
	 * @Date    
	 *
	 * @param   BC
	 * @param   scope
	 * @return  
	*/
	global void finish(Database.BatchableContext BC) {
		runNextBatchInStream( BC.getJobId(), 'ECO_ProjectTeamMemberBatch'); 
	}
}