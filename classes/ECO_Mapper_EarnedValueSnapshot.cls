/** ------------------------------------------------------------------------------------------------------
 *	The mapper class for the EarnedValueSnapshot__c sObject
 * 
 * @Author      NTT Data - Deborah Orth
 * @Date        August 2016
 *-----------------------------------------------------------------------------------------------------*/
public with sharing class ECO_Mapper_EarnedValueSnapshot extends ECO_BaseMapper{
	public String id 										{ get; set; }
	public String name 										{ get; set; }
	public String projectTaskId								{ get; set; }
	public Decimal thisWeekRunningTotalAmount				{ get; set; }
	public Date weekStartDate								{ get; set; }
	public Decimal projectFunctionalBurdenedCost 			{ get; set; }
	public ECO_Mapper_ProjectTask projectTask 				{ get; set; } 
	public ECO_Mapper_WeeklyRollupEntry weeklyRollupEntry	{ get; set; } 

	/**
	 * @Description Used when this class is a child of another mapper class
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    August
	 *
	 * @param	
	 * @return 	
	 **/
	 public ECO_Mapper_EarnedValueSnapshot(){}

	/**
	 * @Description this contructor is used when accessing data from the DB
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    Aug 2016
	 *
	 * @param	record
	 * @return 	
	 **/
	public ECO_Mapper_EarnedValueSnapshot( EarnedValueSnapshot__c record){
		Map<String, Object> fieldsInRecord = record.getPopulatedFieldsAsMap();

		//init the child relationships
		this.projectTask = new ECO_Mapper_ProjectTask();
		this.weeklyRollupEntry = new ECO_Mapper_WeeklyRollupEntry();

		for( String fieldName : fieldsInRecord.keySet()) {
			if( fieldName == 'Id'){
				this.id = record.Id;
			} else if( fieldName == 'Name'){
				this.name = record.Name;
			} else if( fieldName == 'ProjectTask__c'){
				this.projectTaskId = record.ProjectTask__c;
			} else if( fieldName == 'ThisWeekRunningTotalAmount__c'){
				this.thisWeekRunningTotalAmount = record.ThisWeekRunningTotalAmount__c;
			} else if( fieldName == 'ProjectFunctionalBurdenedCost__c'){
				this.projectFunctionalBurdenedCost = record.ProjectFunctionalBurdenedCost__c;
			} else if( fieldName == 'WeekStartDate__c'){
				this.weekStartDate = record.WeekStartDate__c;
			} else if( fieldName == 'ProjectTask__r'){
				this.projectTask = new ECO_Mapper_ProjectTask((pse__Project_Task__c)record.ProjectTask__r);
			} else if( fieldName == 'WeeklyRollupEntry__r') {
				this.weeklyRollupEntry = new ECO_Mapper_WeeklyRollupEntry((WeeklyRollupEntry__c)record.WeeklyRollupEntry__r);
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
	public ECO_Mapper_EarnedValueSnapshot( String jsonRecord){
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
	public ECO_Mapper_EarnedValueSnapshot( JSONParser parser) {
		this.projectTask = new ECO_Mapper_ProjectTask();
		this.weeklyRollupEntry = new ECO_Mapper_WeeklyRollupEntry();

		while (parser.nextToken() != JSONToken.END_OBJECT) {
			if( parser.getCurrentToken() == JSONToken.FIELD_NAME) {
				String token = parser.getText();
				if( parser.nextToken() != JSONToken.VALUE_NULL) {
					if( token == 'attributes'){
						attributes = new Attributes(parser);
					} else if( token == 'Id') {
						this.id = parser.getText();
					} else if( token == 'Name') {
						this.name = parser.getText();
					} else if( token == 'ProjectTask__c') {
						this.projectTaskId = parser.getText();
					} else if( token == 'ThisWeekRunningTotalAmount__c') {
						this.thisWeekRunningTotalAmount = parser.getDecimalValue();
					} else if( token == 'ProjectFunctionalBurdenedCost__c') {
						this.projectFunctionalBurdenedCost = parser.getDecimalValue();
					} else if( token == 'WeekStartDate__c') {
						this.weekStartDate = parser.getDateValue();
					} else if( token == 'ProjectTask__r') {
						this.projectTask = new ECO_Mapper_ProjectTask(parser);
					} else if( token == 'WeeklyRollupEntry__r') {
						this.weeklyRollupEntry = new ECO_Mapper_WeeklyRollupEntry(parser);
					} else {
						//System.debug(LoggingLevel.WARN, '*****Error in ECO_Mapper_EarnedValueSnapshot mock constructor - Root consuming unrecognized property: ' + token);
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
	 * @return 	EarnedValueSnapshot__c
	 **/
	public EarnedValueSnapshot__c unmapToSOject( List<String> fieldToPopulate){
		EarnedValueSnapshot__c newRecord = new EarnedValueSnapshot__c();

		for( String fieldName : fieldToPopulate) {
			if( fieldName == 'Id'){
				newRecord.id = this.Id;
			//formula, rollup summary or auto-number fields, no writing allowed
			//} else if( fieldName == 'Name'){
			//	newRecord.name = this.Name;
			} else if( fieldName == 'ProjectTask__c'){
				newRecord.ProjectTask__c = this.projectTaskId;				
			} else if( fieldName == 'ThisWeekRunningTotalAmount__c'){
				newRecord.ThisWeekRunningTotalAmount__c = this.thisWeekRunningTotalAmount;
			} else if( fieldName == 'ProjectFunctionalBurdenedCost__c'){
				newRecord.ProjectFunctionalBurdenedCost__c = this.projectFunctionalBurdenedCost;
			} else if( fieldName == 'WeekStartDate__c'){
				newRecord.WeekStartDate__c = this.weekStartDate;
			}
		}

		return newRecord;
	}
}