/** ------------------------------------------------------------------------------------------------------
 *	The mapper class for the pse__Proj__c sObject
 * 
 * @Author      NTT Data - Deborah Orth
 * @Date        September 2016
 *-----------------------------------------------------------------------------------------------------*/
public class ECO_Mapper_Project extends ECO_BaseMapper {
	//key fields
	public Id  id 										{ get; set; }
	public String name 									{ get; set; }
	public String budgetStrategyRevenue 				{ get; set; }
	public Decimal pmd_CostAccruals 					{ get; set; }
	public Decimal pmd_CostBudgetOriginal				{ get; set; }
	public Decimal pmd_CostITD3FiscalMonthEndsAgo 		{ get; set; }
	public Decimal pmd_CostMTD 							{ get; set; }
	public Decimal pmd_CostPrevMTD 						{ get; set; }
	public Decimal pmd_EarnedValue 						{ get; set; }
	public Decimal pmd_NetMarginBudgetCurrent			{ get; set; }
	public Decimal pmd_NetMarginBudgetOriginal 			{ get; set; }
	public Decimal pmd_PlannedCost 						{ get; set; }
	public Decimal pmd_PlannedValue 					{ get; set; }
	public Decimal pmd_RevenueBudgetCurrent 			{ get; set; }
	public Decimal pmd_RevenueBudgetOriginal 			{ get; set; }
	public Decimal pmd_TotalActualCost 					{ get; set; }
	public Decimal pmd_TotalApprovedCost 				{ get; set; }
	public Decimal pmd_TotalEstimateCost 				{ get; set; }
	public Decimal pmd_TotalForecastCostPrevME 			{ get; set; }
	public Decimal pmd_TotalHours 						{ get; set; }
	public Decimal pmd_CPI								{ get; set; }
	public Decimal pmd_SPI								{ get; set; }
	public Date startDate                               { get; set; }
	public Date endDate                                 { get; set; }
	public Date forecastStartDate                       { get; set; }
	public Date forecastEndDate                         { get; set; }
	//public List<ECO_Mapper_ProjectTask> projectTasks 	{ get; set; }

	/**
	 * @Description empty contructor is used when this class is a child of another mapper class
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    Aug 2016
	 *
	 * @param	
	 * @return 	
	 **/
	public ECO_Mapper_Project(){}

	/**
	 * @Description this contructor is used when accessing data from the DB
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    Aug 2016
	 *
	 * @param	record
	 * @return 	
	 **/
	public ECO_Mapper_Project( pse__Proj__c record){
		Map<String, Object> fieldsInRecord = record.getPopulatedFieldsAsMap();
		//this.projectTasks = new List<ECO_Mapper_ProjectTask>();

		for( String fieldName : fieldsInRecord.keySet()) {
			if( fieldName == 'Id'){
				this.id = record.Id;
			} else if( fieldName == 'Name'){
				this.name = record.Name;
			} else if( fieldName == 'BudgetStrategyRevenue__c'){
				this.budgetStrategyRevenue = record.BudgetStrategyRevenue__c;
			} else if( fieldName == 'PMD_RevenueBudgetOriginal__c'){
				this.pmd_RevenueBudgetOriginal = record.PMD_RevenueBudgetOriginal__c;
			} else if( fieldName == 'PMD_CostBudgetOriginal__c'){
				this.pmd_CostBudgetOriginal = record.PMD_CostBudgetOriginal__c;
			} else if( fieldName == 'PMD_RevenueBudgetCurrent__c'){
				this.pmd_RevenueBudgetCurrent = record.PMD_RevenueBudgetCurrent__c;
			} else if( fieldName == 'PMD_TotalApprovedCost__c'){
				this.pmd_TotalApprovedCost = record.PMD_TotalApprovedCost__c;
			} else if( fieldName == 'PMD_TotalEstimateCost__c'){
				this.pmd_TotalEstimateCost = record.PMD_TotalEstimateCost__c;
			} else if( fieldName == 'PMD_CostPrevMTD__c'){
				this.pmd_CostPrevMTD = record.PMD_CostPrevMTD__c;
			} else if( fieldName == 'PMD_TotalForecastCostPrevME__c'){
				this.pmd_TotalForecastCostPrevME = record.PMD_TotalForecastCostPrevME__c;
			} else if( fieldName == 'PMD_CostMTD__c'){
				this.pmd_CostMTD = record.PMD_CostMTD__c;
			} else if( fieldName == 'PMD_TotalActualCost__c'){
				this.pmd_TotalActualCost = record.PMD_TotalActualCost__c;
			} else if( fieldName == 'PMD_EarnedValue__c'){
				this.pmd_EarnedValue = record.PMD_EarnedValue__c;
			} else if( fieldName == 'PMD_PlannedCost__c'){
				this.pmd_PlannedCost = record.PMD_PlannedCost__c;
			} else if( fieldName == 'PMD_CostITD3FiscalMonthEndsAgo__c'){
				this.pmd_CostITD3FiscalMonthEndsAgo = record.PMD_CostITD3FiscalMonthEndsAgo__c;
			} else if( fieldName == 'PMD_NetMarginBudgetOriginal__c'){
				this.pmd_NetMarginBudgetOriginal = record.PMD_NetMarginBudgetOriginal__c;
			} else if( fieldName == 'PMD_NetMarginBudgetCurrent__c'){
				this.pmd_NetMarginBudgetCurrent = record.PMD_NetMarginBudgetCurrent__c;
			} else if( fieldName == 'PMD_PlannedValue__c'){
				this.pmd_PlannedValue = record.PMD_PlannedValue__c;
			} else if( fieldName == 'PMD_CostAccruals__c'){
				this.pmd_CostAccruals = record.PMD_CostAccruals__c;
			} else if( fieldName == 'PMD_CPI__c'){
				this.pmd_CPI = record.PMD_CPI__c;
			} else if( fieldName == 'PMD_SPI__c'){
				this.pmd_SPI = record.PMD_SPI__c;
			} else if( fieldName == 'PMD_TotalHours__c'){
				this.pmd_totalHours = record.PMD_TotalHours__c;
			//} else if( fieldName == 'pse__Project_Tasks__r'){
			//	this.projectTasks = new ECO_Mapper_ProjectTask((pse__Project_Task__c)record.pse__Project_Tasks__r);
			} else if( fieldName == 'pse__Start_Date__c'){
				this.startDate = record.pse__Start_Date__c;
			} else if( fieldName == 'pse__End_Date__c'){
				this.endDate = record.pse__End_Date__c;
			} else if( fieldName == 'RevisedStartDate__c'){
				this.forecastStartDate = record.RevisedStartDate__c;
			} else if( fieldName == 'RevisedEndDate__c'){
				this.forecastEndDate = record.RevisedEndDate__c;
			}
		}
	}

	/**
	 * @Description this contructor is used when accessing data from JSON for testing but user just wants to pass a string in
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    September 2016
	 *
	 * @param	parser
	 * @return 	
	 **/
	public ECO_Mapper_Project( String jsonRecord){
		this(System.JSON.createParser( jsonRecord));
	}

	/**
	 * @Description this contructor is used when accessing data from JSON for testing
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    Aug 2016
	 *
	 * @param	parser
	 * @return 	
	 **/
	public ECO_Mapper_Project( JSONParser parser) {
		//this.projectTasks = new List<ECO_Mapper_ProjectTask>();

		while (parser.nextToken() != JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
				String token = parser.getText();
				if (parser.nextToken() != JSONToken.VALUE_NULL) {
					if( token == 'attributes'){
						attributes = new Attributes(parser);
					} else if( token == 'Id'){
						this.id = parser.getText();
					} else if( token == 'Name'){
						this.name = parser.getText();
					} else if( token == 'BudgetStrategyRevenue__c'){
						this.budgetStrategyRevenue = parser.getText();
					} else if (token == 'PMD_CPI__c') {
						this.pmd_CPI = parser.getDecimalValue();
					} else if (token == 'PMD_SPI__c') {
						this.pmd_SPI = parser.getDecimalValue();
					} else if( token == 'PMD_RevenueBudgetOriginal__c'){
						this.pmd_RevenueBudgetOriginal = parser.getDecimalValue();
					} else if( token == 'PMD_CostBudgetOriginal__c'){
						this.pmd_CostBudgetOriginal = parser.getDecimalValue();
					} else if( token == 'PMD_RevenueBudgetCurrent__c'){
						this.pmd_RevenueBudgetCurrent = parser.getDecimalValue();
					} else if( token == 'PMD_TotalApprovedCost__c'){
						this.pmd_TotalApprovedCost = parser.getDecimalValue();
					} else if( token == 'PMD_TotalEstimateCost__c'){
						this.pmd_TotalEstimateCost = parser.getDecimalValue();
					} else if( token == 'PMD_CostPrevMTD__c'){
						this.pmd_CostPrevMTD = parser.getDecimalValue();
					} else if( token == 'PMD_TotalForecastCostPrevME__c'){
						this.pmd_TotalForecastCostPrevME = parser.getDecimalValue();
					} else if( token == 'PMD_CostMTD__c'){
						this.pmd_CostMTD = parser.getDecimalValue();
					} else if( token == 'PMD_TotalActualCost__c'){
						this.pmd_TotalActualCost = parser.getDecimalValue();
					} else if( token == 'PMD_EarnedValue__c'){
						this.pmd_EarnedValue = parser.getDecimalValue();
					} else if( token == 'PMD_PlannedCost__c'){
						this.pmd_PlannedCost = parser.getDecimalValue();
					} else if( token == 'PMD_CostITD3FiscalMonthEndsAgo__c'){
						this.pmd_CostITD3FiscalMonthEndsAgo = parser.getDecimalValue();
					} else if( token == 'PMD_NetMarginBudgetOriginal__c'){
						this.pmd_NetMarginBudgetOriginal = parser.getDecimalValue();
					} else if( token == 'PMD_NetMarginBudgetCurrent__c'){
						this.pmd_NetMarginBudgetCurrent = parser.getDecimalValue();
					} else if( token == 'PMD_PlannedValue__c'){
						this.pmd_PlannedValue = parser.getDecimalValue();
					} else if( token == 'PMD_CostAccruals__c'){
						this.pmd_CostAccruals = parser.getDecimalValue();
					} else if( token == 'PMD_TotalHours__c'){
						this.pmd_TotalHours = parser.getDecimalValue();
					//} else if (token == 'pse__Project_Tasks__r') {
					//	this.projectTasks = new ECO_Mapper_ProjectTask(parser);
					} else if( token == 'pse__Start_Date__c'){
						this.startDate = parser.getDateValue();
					} else if( token == 'pse__End_Date__c'){
						this.endDate = parser.getDateValue();
					} else if( token == 'RevisedStartDate__c'){
						this.forecastStartDate = parser.getDateValue();
					} else if( token == 'RevisedEndDate__c'){
						this.forecastEndDate = parser.getDateValue();
					} else {
						//System.debug(LoggingLevel.WARN, '*****Error in ECO_Mapper_Project mock constructor - Root consuming unrecognized property: ' + token);
						stepOverObject(parser);
					}
				}
			}
		}
	}

	/**
	 * @Description this method is used to return the mapped object back into an SObject
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    September 2016
	 *
	 * @param	fieldToPopulate
	 * @return 	pse__Proj__c
	 **/
	public pse__Proj__c unmapToSOject( List<String> fieldToPopulate){
		pse__Proj__c newRecord = new pse__Proj__c();

		for( String fieldName : fieldToPopulate) {
			if( fieldName == 'Id'){
				newRecord.id = this.Id;
			} else if( fieldName == 'Name'){
				newRecord.name = this.Name;
			} else if( fieldName == 'BudgetStrategyRevenue__c'){
				newRecord.BudgetStrategyRevenue__c = this.budgetStrategyRevenue;
			} else if( fieldName == 'PMD_RevenueBudgetOriginal__c'){
				newRecord.PMD_RevenueBudgetOriginal__c = this.pmd_RevenueBudgetOriginal;
			//} else if( fieldName == 'pmd_CostBudgetOriginal'){
				newRecord.PMD_CostBudgetOriginal__c = this.pmd_CostBudgetOriginal;
			} else if( fieldName == 'PMD_RevenueBudgetCurrent__c'){
				newRecord.PMD_RevenueBudgetCurrent__c = this.pmd_RevenueBudgetCurrent;
			} else if( fieldName == 'PMD_TotalApprovedCost__c'){
				newRecord.PMD_TotalApprovedCost__c = this.pmd_TotalApprovedCost;
			} else if( fieldName == 'PMD_TotalEstimateCost__c'){
				newRecord.PMD_TotalEstimateCost__c = this.pmd_TotalEstimateCost;
			} else if( fieldName == 'PMD_CostPrevMTD__c'){
				newRecord.PMD_CostPrevMTD__c = this.pmd_CostPrevMTD;
			} else if( fieldName == 'PMD_TotalForecastCostPrevME__c'){
				newRecord.PMD_TotalForecastCostPrevME__c = this.pmd_TotalForecastCostPrevME;
			} else if( fieldName == 'PMD_CostMTD__c'){
				newRecord.PMD_CostMTD__c = this.pmd_CostMTD;
			} else if( fieldName == 'PMD_TotalActualCost__c'){
				newRecord.PMD_TotalActualCost__c = this.pmd_TotalActualCost;
			} else if( fieldName == 'PMD_EarnedValue__c'){
				newRecord.PMD_EarnedValue__c = this.pmd_EarnedValue;
			} else if( fieldName == 'PMD_PlannedCost__c'){
				newRecord.PMD_PlannedCost__c = this.pmd_PlannedCost;
			} else if( fieldName == 'PMD_CostITD3FiscalMonthEndsAgo__c'){
				newRecord.PMD_CostITD3FiscalMonthEndsAgo__c = this.pmd_CostITD3FiscalMonthEndsAgo;
			} else if( fieldName == 'PMD_NetMarginBudgetOriginal__c'){
				newRecord.PMD_NetMarginBudgetOriginal__c = this.pmd_NetMarginBudgetOriginal;
			} else if( fieldName == 'PMD_NetMarginBudgetCurrent__c'){
				newRecord.PMD_NetMarginBudgetCurrent__c = this.pmd_NetMarginBudgetCurrent;
			} else if( fieldName == 'PMD_PlannedValue__c'){
				newRecord.PMD_PlannedValue__c = this.pmd_PlannedValue;
			} else if( fieldName == 'PMD_CostAccruals__c'){
				newRecord.PMD_CostAccruals__c = this.pmd_CostAccruals;
			} else if( fieldName == 'PMD_TotalHours__c'){
				newRecord.PMD_TotalHours__c = this.pmd_TotalHours;
			}
			// pmd_CPI NO WRITING
			// pmd_SPI NO WRITING
			// startDate (pse__Start_Date__c') NO WRITING
			// endDate (pse__End_Date__c') NO WRITING
			  else if( fieldName == 'RevisedStartDate__c'){
				newRecord.RevisedStartDate__c = this.forecastStartDate;
			} else if( fieldName == 'RevisedEndDate__c'){
				newRecord.RevisedEndDate__c = this.forecastEndDate;
			}
		}

		return newRecord;
	}
}