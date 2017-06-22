/** ------------------------------------------------------------------------------------------------------
 *	The mapper class for the pse__Project_Task__c sObject
 * 
 * @Author      NTT Data - Deborah Orth
 * @Date        August 2016
 *-----------------------------------------------------------------------------------------------------*/
public class ECO_Mapper_ProjectTask extends ECO_BaseMapper {
	//key fields
	public Id  id 									{ get; set; }
	public String  name 							{ get; set; }
	public String  projectId 						{ get; set; }
	public String  projectTaskNumber 				{ get; set; }
	public String  parentTaskId 					{ get; set; }
	//data fields (in alphabetic order)
	public Decimal costAccruals 					{ get; set; }
	public Decimal costBudgetOriginal				{ get; set; }
	public Decimal costITD3FiscalMonthEndsAgo		{ get; set; }
	public Decimal costMTD							{ get; set; }
	public Decimal costPrevMTD						{ get; set; }
	public Decimal cpi								{ get; set; }
	public Decimal earnedValue						{ get; set; }
	public String  endDateFiscalMonth				{ get; set; }
	public String  endDatePreviousFiscalMonth 		{ get; set; }
	public Boolean isWorkPlanTask					{ get; set; }
	public Date    metricsDate 						{ get; set; }
	public Date    monthEndDate3FiscalMonthsAgo		{ get; set; }
	public Decimal netMarginBudgetCurrent 			{ get; set; }
	public Decimal netMarginBudgetOriginal 			{ get; set; }
	public Decimal percentComplete 					{ get; set; }
	public Decimal plannedCost						{ get; set; }
	public Decimal plannedValue						{ get; set; }
	public Decimal pmd_CostAccruals 				{ get; set; }
	public Decimal pmd_CostBudgetOriginal			{ get; set; }
	public Decimal pmd_CostITD3FiscalMonthEndsAgo 	{ get; set; }
	public Decimal pmd_CostMTD 						{ get; set; }
	public Decimal pmd_CostPrevMTD 					{ get; set; }
	public Decimal pmd_EarnedValue 					{ get; set; }
	public Decimal pmd_NetMarginBudgetCurrent		{ get; set; }
	public Decimal pmd_NetMarginBudgetOriginal 		{ get; set; }
	public Decimal pmd_PlannedCost 					{ get; set; }
	public Decimal pmd_PlannedValue 				{ get; set; }
	public Decimal pmd_RevenueBudgetCurrent 		{ get; set; }
	public Decimal pmd_RevenueBudgetOriginal 		{ get; set; }
	public Decimal pmd_TotalActualCost 				{ get; set; }
	public Decimal pmd_TotalApprovedCost 			{ get; set; }
	public Decimal pmd_TotalEstimateCost 			{ get; set; }
	public Decimal pmd_TotalForecastCostPrevME 		{ get; set; }
	public Decimal pmd_TotalHours 					{ get; set; }
	public Decimal revenueBudgetOriginal 			{ get; set; }
	public Decimal revenueBudgetCurrent 			{ get; set; }
	public Decimal spi								{ get; set; }
	public Decimal totalActualCost					{ get; set; }
	public Decimal totalApprovedCost				{ get; set; }
	public Decimal totalEstimateCost				{ get; set; }
	public Decimal totalForecastCostPrevME			{ get; set; }
	public Decimal totalHours 						{ get; set; }
	public Decimal pmd_CPI 							{ get; set; }
	public Decimal pmd_SPI 							{ get; set; }
	public Date startDate                           { get; set; }
	public Date endDate                             { get; set; }
	public Date forecastStartDate                   { get; set; }
	public Date forecastEndDate                     { get; set; }

	/**
	 * @Description empty contructor is used when this class is a child of another mapper class
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    Aug 2016
	 *
	 * @param	
	 * @return 	
	 **/
	public ECO_Mapper_ProjectTask(){}

	/**
	 * @Description this contructor is used when accessing data from the DB
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    Aug 2016
	 *
	 * @param	record
	 * @return 	
	 **/
	public ECO_Mapper_ProjectTask( pse__Project_Task__c record){
		Map<String, Object> fieldsInRecord = record.getPopulatedFieldsAsMap();

		for( String fieldName : fieldsInRecord.keySet()) {
			if( fieldName == 'Id'){
				this.id = record.Id;
			} else if( fieldName == 'Name'){
				this.name = record.Name;
			} else if( fieldName == 'pse__Project__c'){
				this.projectId = record.pse__Project__c;				
			} else if( fieldName == 'ProjectTaskNumber__c'){
				this.projectTaskNumber = record.ProjectTaskNumber__c;
			} else if( fieldName == 'MetricsDate__c'){
				this.metricsDate = record.MetricsDate__c;
			} else if( fieldName == 'RevenueBudgetOriginal__c'){
				this.revenueBudgetOriginal = record.RevenueBudgetOriginal__c;
			} else if( fieldName == 'RevenueBudgetCurrent__c'){
				this.revenueBudgetCurrent = record.RevenueBudgetCurrent__c;
			} else if( fieldName == 'CostBudgetOriginal__c'){
				this.costBudgetOriginal = record.CostBudgetOriginal__c;
			} else if( fieldName == 'CostPrevMTD__c'){
				this.costPrevMTD = record.CostPrevMTD__c;
			} else if( fieldName == 'CostMTD__c'){
				this.costMTD = record.CostMTD__c;
			} else if( fieldName == 'TotalEstimateCost__c'){
				this.totalEstimateCost = record.TotalEstimateCost__c;
			} else if( fieldName == 'TotalApprovedCost__c'){
				this.totalApprovedCost = record.TotalApprovedCost__c;
			} else if( fieldName == 'TotalForecastCostPrevME__c'){
				this.totalForecastCostPrevME = record.TotalForecastCostPrevME__c;
			} else if( fieldName == 'EarnedValue__c'){
				this.earnedValue = record.EarnedValue__c;
			} else if( fieldName == 'CPI__c'){
				this.cpi = record.CPI__c;
			} else if( fieldName == 'SPI__c'){
				this.spi = record.SPI__c;
			} else if( fieldName == 'CostAccruals__c'){
				this.costAccruals = record.CostAccruals__c;
			} else if( fieldName == 'MonthEndDate3FiscalMonthsAgo__c'){
				this.monthEndDate3FiscalMonthsAgo = record.MonthEndDate3FiscalMonthsAgo__c;
			} else if( fieldName == 'CostITD3FiscalMonthEndsAgo__c'){
				this.costITD3FiscalMonthEndsAgo = record.CostITD3FiscalMonthEndsAgo__c;
			} else if( fieldName == 'EndDateFiscalMonth__c'){
				this.endDateFiscalMonth = record.EndDateFiscalMonth__c;
			} else if( fieldName == 'EndDatePreviousFiscalMonth__c'){
				this.endDatePreviousFiscalMonth = record.EndDatePreviousFiscalMonth__c;
			} else if( fieldName == 'TotalActualCost__c'){
				this.totalActualCost = record.TotalActualCost__c;
			} else if( fieldName == 'PlannedCost__c'){
				this.plannedCost = record.PlannedCost__c;
			} else if( fieldName == 'PlannedValue__c'){
				this.plannedValue = record.PlannedValue__c;
			} else if( fieldName == 'pse__Parent_Task__c'){
				this.parentTaskId = record.pse__Parent_Task__c;
			} else if( fieldName == 'PercentComplete__c'){
				this.percentComplete = record.PercentComplete__c;
			} else if( fieldName == 'TotalHours__c'){
				this.totalHours = record.TotalHours__c;
			} else if( fieldName == 'PMD_TotalHours__c'){
				this.pmd_TotalHours = record.PMD_TotalHours__c;
			} else if( fieldName == 'NetMarginBudgetCurrent__c'){
				this.netMarginBudgetCurrent = record.NetMarginBudgetCurrent__c;
			} else if( fieldName == 'NetMarginBudgetOriginal__c'){
				this.netMarginBudgetOriginal = record.NetMarginBudgetOriginal__c;
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
			} else if( fieldName == 'IsWorkPlanTask__c'){
				this.isWorkPlanTask = record.IsWorkPlanTask__c;
			} else if( fieldName == 'PMD_CPI__c'){
				this.pmd_CPI = record.PMD_CPI__c;
			} else if( fieldName == 'PMD_SPI__c'){
				this.pmd_SPI = record.PMD_SPI__c;
			} else if( fieldName == 'pse__Start_Date__c'){
				Datetime d = record.pse__Start_Date__c;
				this.startDate = d.dateGmt();
				system.debug('____this.startDate='+this.startDate);
			} else if( fieldName == 'pse__End_Date__c'){
				Datetime d = record.pse__End_Date__c;
				this.endDate = d.dateGmt();
				system.debug('____this.endDate='+this.endDate);
			} else if( fieldName == 'ForecastStartDate__c'){
				this.forecastStartDate = record.ForecastStartDate__c;
				system.debug('____this.forecastStartDate='+this.forecastStartDate);
			} else if( fieldName == 'ForecastEndDate__c'){
				this.forecastEndDate = record.ForecastEndDate__c;
				system.debug('____this.forecastEndDate='+this.forecastEndDate);
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
	public ECO_Mapper_ProjectTask( String jsonRecord){
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
	public ECO_Mapper_ProjectTask( JSONParser parser) {
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
					} else if( token == 'pse__Project__c'){
						this.projectId = parser.getText();
					} else if( token == 'ProjectTaskNumber__c'){
						this.projectTaskNumber = parser.getText();
					} else if (token == 'MetricsDate__c') {
						this.metricsDate = parser.getDateValue();
					} else if (token == 'RevenueBudgetOriginal__c') {
						this.revenueBudgetOriginal = parser.getDecimalValue();
					} else if (token == 'RevenueBudgetCurrent__c') {
						this.revenueBudgetCurrent = parser.getDecimalValue();
					} else if (token == 'CostBudgetOriginal__c') {
						this.costBudgetOriginal = parser.getDecimalValue();
					} else if (token == 'CostPrevMTD__c') {
						this.costPrevMTD = parser.getDecimalValue();
					} else if (token == 'CostMTD__c') {
						this.costMTD = parser.getDecimalValue();
					} else if (token == 'TotalEstimateCost__c') {
						this.totalEstimateCost = parser.getDecimalValue();
					} else if (token == 'TotalApprovedCost__c') {
						this.totalApprovedCost = parser.getDecimalValue();
					} else if (token == 'TotalForecastCostPrevME__c') {
						this.totalForecastCostPrevME = parser.getDecimalValue();
					} else if (token == 'EarnedValue__c') {
						this.earnedValue = parser.getDecimalValue();
					} else if (token == 'CPI__c') {
						this.cpi = parser.getDecimalValue();
					} else if (token == 'SPI__c') {
						this.spi = parser.getDecimalValue();
					} else if( token == 'CostAccruals__c'){
						this.costAccruals = parser.getDecimalValue();
					} else if (token == 'MonthEndDate3FiscalMonthsAgo__c') {
						this.monthEndDate3FiscalMonthsAgo = parser.getDateValue();
					} else if (token == 'CostITD3FiscalMonthEndsAgo__c') {
						this.costITD3FiscalMonthEndsAgo = parser.getDecimalValue();
					} else if (token == 'EndDateFiscalMonth__c') {
						this.endDateFiscalMonth = parser.getText();
					} else if (token == 'EndDatePreviousFiscalMonth__c') {
						this.endDatePreviousFiscalMonth = parser.getText();
					} else if (token == 'TotalActualCost__c') {
						this.totalActualCost = parser.getDecimalValue();
					} else if (token == 'PlannedCost__c') {
						this.plannedCost = parser.getDecimalValue();
					} else if (token == 'PlannedValue__c') {
						this.plannedValue = parser.getDecimalValue();
					} else if (token == 'pse__Parent_Task__c') {
						this.parentTaskId = parser.getText();
					} else if( token == 'PercentComplete__c'){
						this.percentComplete = parser.getDecimalValue();
					} else if( token == 'TotalHours__c'){
						this.totalHours = parser.getDecimalValue();
					} else if( token == 'PMD_TotalHours__c'){
						this.pmd_TotalHours = parser.getDecimalValue();
					} else if( token == 'NetMarginBudgetCurrent__c'){
						this.netMarginBudgetCurrent = parser.getDecimalValue();
					} else if( token == 'NetMarginBudgetOriginal__c'){
						this.netMarginBudgetOriginal = parser.getDecimalValue();
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
					} else if( token == 'IsWorkPlanTask__c'){
						this.isWorkPlanTask = parser.getBooleanValue();
					} else if( token == 'PMD_CPI__c'){
						this.pmd_CPI = parser.getDecimalValue();
					} else if( token == 'PMD_SPI__c'){
						this.pmd_SPI = parser.getDecimalValue();
					} else if( token == 'pse__Start_Date__c'){
						this.startDate = parser.getDateValue();
					} else if( token == 'pse__End_Date__c'){
						this.endDate = parser.getDateValue();
					} else if( token == 'ForecastStartDate__c'){
						this.forecastStartDate = parser.getDateValue();
					} else if( token == 'ForecastEndDate__c'){
						this.forecastEndDate = parser.getDateValue();
					} else {
						//System.debug(LoggingLevel.WARN, '*****Error in ECO_Mapper_ProjectTask mock constructor - Root consuming unrecognized property: ' + token);
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
	 * @return 	pse__Project_Task__c
	 **/
	public pse__Project_Task__c unmapToSOject( List<String> fieldToPopulate){
		pse__Project_Task__c newRecord = new pse__Project_Task__c();

		for( String fieldName : fieldToPopulate) {
			if( fieldName == 'Id'){
				newRecord.Id = this.Id;
			} else if( fieldName == 'Name'){
				newRecord.Name = this.Name;
			} else if( fieldName == 'pse__Project__c'){
				newRecord.pse__Project__c = this.projectId;				
			} else if( fieldName == 'ProjectTaskNumber__c'){
				newRecord.ProjectTaskNumber__c = this.projectTaskNumber;
			} else if( fieldName == 'MetricsDate__c'){
				newRecord.MetricsDate__c = this.metricsDate;
			} else if( fieldName == 'RevenueBudgetOriginal__c'){
				newRecord.RevenueBudgetOriginal__c = this.revenueBudgetOriginal;
			} else if( fieldName == 'RevenueBudgetCurrent__c'){
				newRecord.RevenueBudgetCurrent__c = this.revenueBudgetCurrent;
			} else if( fieldName == 'CostBudgetOriginal__c'){
				newRecord.CostBudgetOriginal__c = this.costBudgetOriginal;
			} else if( fieldName == 'CostPrevMTD__c'){
				newRecord.CostPrevMTD__c = this.costPrevMTD;
			} else if( fieldName == 'CostMTD__c'){
				newRecord.CostMTD__c = this.costMTD;
			} else if( fieldName == 'TotalEstimateCost__c'){
				newRecord.TotalEstimateCost__c = this.totalEstimateCost;
			} else if( fieldName == 'TotalApprovedCost__c'){
				newRecord.TotalApprovedCost__c = this.totalApprovedCost;
			} else if( fieldName == 'TotalForecastCostPrevME__c'){
				newRecord.TotalForecastCostPrevME__c = this.totalForecastCostPrevME;
			} else if( fieldName == 'EarnedValue__c'){
				newRecord.EarnedValue__c = this.earnedValue;
			//formula, rollup summary or auto-number fields, no writing allowed
			//} else if( fieldName == 'CPI__c'){
			//	newRecord.CPI__c = this.cpi;
			//} else if( fieldName == 'SPI__c'){
			//	newRecord.SPI__c = this.spi;
			} else if( fieldName == 'CostAccruals__c'){
				newRecord.CostAccruals__c = this.costAccruals;
			} else if( fieldName == 'MonthEndDate3FiscalMonthsAgo__c'){
				newRecord.MonthEndDate3FiscalMonthsAgo__c = this.monthEndDate3FiscalMonthsAgo;
			} else if( fieldName == 'CostITD3FiscalMonthEndsAgo__c'){
				newRecord.CostITD3FiscalMonthEndsAgo__c = this.costITD3FiscalMonthEndsAgo;
			} else if( fieldName == 'EndDateFiscalMonth__c'){
				newRecord.EndDateFiscalMonth__c = this.endDateFiscalMonth;
			} else if( fieldName == 'EndDatePreviousFiscalMonth__c'){
				newRecord.EndDatePreviousFiscalMonth__c = this.endDatePreviousFiscalMonth;
			} else if( fieldName == 'TotalActualCost__c'){
				newRecord.TotalActualCost__c = this.totalActualCost;
			} else if( fieldName == 'PlannedCost__c'){
				newRecord.PlannedCost__c = this.plannedCost;
			} else if( fieldName == 'PlannedValue__c'){
				newRecord.PlannedValue__c = this.plannedValue;
			} else if( fieldName == 'pse__Parent_Task__c'){
				newRecord.pse__Parent_Task__c = this.parentTaskId;
			} else if( fieldName == 'PercentComplete__c'){
				newRecord.PercentComplete__c = this.percentComplete;
			//formula, rollup summary or auto-number fields, no writing allowed
			//} else if( fieldName == 'TotalHours__c'){
			//	newRecord.TotalHours__c = this.totalHours;
			} else if( fieldName == 'PMD_TotalHours__c'){
				newRecord.PMD_TotalHours__c = this.pmd_TotalHours;
			//formula, rollup summary or auto-number fields, no writing allowed
			//} else if( fieldName == 'NetMarginBudgetCurrent__c'){
			//	newRecord.NetMarginBudgetCurrent__c = this.netMarginBudgetCurrent;
			//} else if( fieldName == 'NetMarginBudgetOriginal__c'){
			//	newRecord.NetMarginBudgetOriginal__c = this.netMarginBudgetOriginal;
			} else if( fieldName == 'PMD_RevenueBudgetOriginal__c'){
				newRecord.PMD_RevenueBudgetOriginal__c = this.pmd_RevenueBudgetOriginal;
			} else if( fieldName == 'PMD_CostBudgetOriginal__c'){
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
			} else if( fieldName == 'IsWorkPlanTask__c'){
				newRecord.IsWorkPlanTask__c = this.isWorkPlanTask;
			} 
			// pmd_CPI NO WRITING
			// pmd_SPI NO WRITING
			// startDate (pse__Start_Date__c') NO WRITING
			// endDate (pse__End_Date__c') NO WRITING
			  else if( fieldName == 'ForecastStartDate__c'){
				newRecord.ForecastStartDate__c = this.forecastStartDate;
			} else if( fieldName == 'ForecastEndDate__c'){
				newRecord.ForecastEndDate__c = this.forecastEndDate;
			}
		}
		return newRecord;
	}
}