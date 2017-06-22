/** ------------------------------------------------------------------------------------------------------
 *	The mapper class for the BudgetHeader__c sObject
 * 
 * @Author      NTT Data - Deborah Orth
 * @Date        August 2016
 *-----------------------------------------------------------------------------------------------------*/
public with sharing class ECO_Mapper_BudgetHeader extends ECO_BaseMapper {
	public Id id 									{ get; set; }
	public String name 								{ get; set; }
	public Id projectId								{ get; set; }
	public Datetime createdDate						{ get; set; }
	public Date submittedForForecastStatusDate		{ get; set; }
	public Decimal totalCost						{ get; set; }
	public Decimal appliedTotalRevenue				{ get; set; }
	public Boolean isWorkAtRisk 					{ get; set; }

	/**
	 * @Description empty contructor is used when this class is a child of another mapper class
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    Aug 2016
	 *
	 * @param	record
	 * @return 	
	 **/
	public ECO_Mapper_BudgetHeader(){}

	/**
	 * @Description this contructor is used when accessing data from the DB
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    Aug 2016
	 *
	 * @param	
	 * @return 	
	 **/
	public ECO_Mapper_BudgetHeader( BudgetHeader__c record){
		Map<String, Object> fieldsInRecord = record.getPopulatedFieldsAsMap();

		for( String fieldName : fieldsInRecord.keySet()) {
			if( fieldName == 'Id'){
				this.id = record.Id;
			} else if( fieldName == 'Project__c'){
				this.projectId = record.Project__c;
			} else if( fieldName == 'Name'){
				this.name = record.Name;
			} else if( fieldName == 'CreatedDate'){
				this.createdDate = record.CreatedDate;
			} else if( fieldName == 'SubmittedForForecastStatusDate__c'){
				this.submittedForForecastStatusDate = record.SubmittedForForecastStatusDate__c;
			} else if( fieldName == 'TotalCost__c'){
				this.totalCost = record.TotalCost__c;
			} else if( fieldName == 'AppliedTotalRevenue__c'){
				this.appliedTotalRevenue = record.AppliedTotalRevenue__c;
			} else if( fieldName == 'IsWorkAtRisk__c'){
				this.isWorkAtRisk = record.IsWorkAtRisk__c;				
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
	public ECO_Mapper_BudgetHeader( String jsonRecord){
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
	public ECO_Mapper_BudgetHeader( JSONParser parser){
		while (parser.nextToken() != JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
				String token = parser.getText();
				if (parser.nextToken() != JSONToken.VALUE_NULL) {
					if( token == 'attributes'){
						attributes = new Attributes(parser);
					} else if( token == 'Id'){
						this.id = parser.getText();
					} else if( token == 'Project__c'){
						this.projectId = parser.getText();
					} else if (token == 'Name') {
						this.name = parser.getText();
					} else if (token == 'CreatedDate') {
						this.createdDate = parser.getDateTimeValue();
					} else if (token == 'SubmittedForForecastStatusDate__c') {
						this.submittedForForecastStatusDate = parser.getDateValue();
					} else if( token == 'TotalCost__c'){
						this.totalCost = parser.getDecimalValue();
					} else if( token == 'AppliedTotalRevenue__c'){
						this.appliedTotalRevenue = parser.getDecimalValue();
					} else if( token == 'IsWorkAtRisk__c'){
						this.isWorkAtRisk = parser.getBooleanValue();				
					} else {
						//System.debug(LoggingLevel.WARN, '*****Error in ECO_Mapper_BudgetHeader mock constructor - Root consuming unrecognized property: ' + token);
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
	 * @return 	BudgetHeader__c
	 **/
	public BudgetHeader__c unmapToSOject( List<String> fieldToPopulate){
		BudgetHeader__c newRecord = new BudgetHeader__c();

		for( String fieldName : fieldToPopulate) {
			if( fieldName == 'Id'){
				newRecord.Id = this.Id;
			} else if( fieldName == 'Project__c'){
				newRecord.Project__c = this.projectId;
			//formula, rollup summary or auto-number fields, no writing allowed
			//} else if( fieldName == 'Name'){
			//	newRecord.name = this.Name;
			} else if( fieldName == 'SubmittedForForecastStatusDate__c'){
				newRecord.SubmittedForForecastStatusDate__c = this.submittedForForecastStatusDate;				
			//formula, rollup summary or auto-number fields, no writing allowed
			//} else if( fieldName == 'TotalCost__c'){
			//	newRecord.TotalCost__c = this.totalCost;
			//} else if( token == 'AppliedTotalRevenue__c'){
			//	newRecord.AppliedTotalRevenue__c = this.appliedTotalRevenue;
			//} else if( token == 'IsWorkAtRisk__c'){
			//	newRecord.IsWorkAtRisk__c = this.isWorkAtRisk;				
			}
		}

		return newRecord;
	}
}