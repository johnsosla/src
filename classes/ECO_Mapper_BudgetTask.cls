/** ------------------------------------------------------------------------------------------------------
 *	The mapper class for the BudgetTask__c sObject
 * 
 * @Author      NTT Data - Deborah Orth
 * @Date        August 2016
 *-----------------------------------------------------------------------------------------------------*/
public with sharing class ECO_Mapper_BudgetTask extends ECO_BaseMapper {
	public Id id 									{ get; set; }
	public String name 								{ get; set; }
	public String projectTaskId						{ get; set; }
	public Decimal totalForecastCost				{ get; set; }
	public Decimal totalRevenue						{ get; set; }
	public Decimal overrideTotalRevenue				{ get; set; }
	public Decimal totalCost						{ get; set; }
	public ECO_Mapper_BudgetHeader budgetHeader 	{ get; set; }

	/**
	 * @Description empty contructor is used when this class is a child of another mapper class
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    Aug 2016
	 *
	 * @param	
	 * @return 	
	 **/
	public ECO_Mapper_BudgetTask(){}

	/**
	 * @Description this contructor is used when accessing data from the DB
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    Aug 2016
	 *
	 * @param	record
	 * @return 	
	 **/
	public ECO_Mapper_BudgetTask( BudgetTask__c record){
		Map<String, Object> fieldsInRecord = record.getPopulatedFieldsAsMap();
		this.budgetHeader = new ECO_Mapper_BudgetHeader();

		for( String fieldName : fieldsInRecord.keySet()) {
			if( fieldName == 'Id'){
				this.id = record.Id;
			} else if( fieldName == 'Name'){
				this.name = record.Name;
			} else if( fieldName == 'ProjectTask__c'){
				this.projectTaskId = record.ProjectTask__c;
			} else if( fieldName == 'TotalForecastCost__c'){
				this.totalForecastCost = record.TotalForecastCost__c;
			} else if( fieldName == 'TotalRevenue__c'){
				this.totalRevenue = record.TotalRevenue__c;
			} else if( fieldName == 'OverrideTotalRevenue__c'){
				this.overrideTotalRevenue = record.OverrideTotalRevenue__c;
			} else if( fieldName == 'TotalCost__c'){
				this.totalCost = record.TotalCost__c;
			} else if( fieldName == 'BudgetHeader__r'){
				this.budgetHeader = new ECO_Mapper_BudgetHeader((BudgetHeader__c)record.BudgetHeader__r);
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
	public ECO_Mapper_BudgetTask( String jsonRecord){
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
	public ECO_Mapper_BudgetTask( JSONParser parser) {
		this.budgetHeader = new ECO_Mapper_BudgetHeader();

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
					} else if (token == 'ProjectTask__c') {
						this.projectTaskId = parser.getText();
					} else if (token == 'TotalForecastCost__c') {
						this.totalForecastCost = parser.getDecimalValue();
					} else if (token == 'TotalRevenue__c') {
						this.totalRevenue = parser.getDecimalValue();
					} else if( token == 'OverrideTotalRevenue__c'){
						this.overrideTotalRevenue = parser.getDecimalValue();
					} else if (token == 'TotalCost__c') {
						this.totalCost = parser.getDecimalValue();
					} else if (token == 'BudgetHeader__r') {
						this.budgetHeader = new ECO_Mapper_BudgetHeader(parser);
					} else {
						//System.debug(LoggingLevel.WARN, '*****Error in ECO_Mapper_BudgetTask mock constructor - Root consuming unrecognized property: ' + token);
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
	 * @return 	BudgetTask__c
	 **/
	public BudgetTask__c unmapToSOject( List<String> fieldToPopulate){
		BudgetTask__c newRecord = new BudgetTask__c();

		for( String fieldName : fieldToPopulate) {
			if( fieldName == 'Id'){
				newRecord.id = this.Id;
			//formula, rollup summary or auto-number fields, no writing allowed
			//} else if( fieldName == 'Name'){
			//	newRecord.name = this.Name;
			} else if( fieldName == 'ProjectTask__c'){
				newRecord.ProjectTask__c = this.projectTaskId;				
			//formula, rollup summary or auto-number fields, no writing allowed
			//} else if( fieldName == 'TotalForecastCost__c'){
			//	newRecord.TotalForecastCost__c = this.totalForecastCost;
			//} else if( fieldName == 'TotalRevenue__c'){
			//	newRecord.TotalRevenue__c = this.totalRevenue;
			} else if( fieldName == 'OverrideTotalRevenue__c'){
				newRecord.OverrideTotalRevenue__c = this.overrideTotalRevenue;
			//} else if( fieldName == 'TotalCost__c'){
			//	newRecord.TotalCost__c = this.totalCost;
			}
		}

		return newRecord;
	}
}