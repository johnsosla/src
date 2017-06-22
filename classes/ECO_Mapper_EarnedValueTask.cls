/** ------------------------------------------------------------------------------------------------------
 *	The mapper class for the EarnedValueTask__c sObject
 * 
 * @Author      NTT Data - Deborah Orth
 * @Date        August 2016
 *-----------------------------------------------------------------------------------------------------*/
public with sharing class ECO_Mapper_EarnedValueTask extends ECO_BaseMapper {
	public Id id 									{ get; set; }
	public String name 								{ get; set; }
	public String projectTaskId						{ get; set; }
	public Decimal taskTotalApprovedCostSnapshot	{ get; set; }
	public Decimal earnedValue						{ get; set; }
	public Decimal costAccruals						{ get; set; }
	public Date snapshotDate						{ get; set; }

	/**
	 * @Description Empty constructor for when this is a child of another mapper class
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    date
	 *
	 * @param	
	 * @return 	
	 **/
	public ECO_Mapper_EarnedValueTask(){}

	/**
	 * @Description this contructor is used when accessing data from the DB
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    Aug 2016
	 *
	 * @param	record
	 * @return 	
	 **/
	public ECO_Mapper_EarnedValueTask( EarnedValueTask__c record){
		Map<String, Object> fieldsInRecord = record.getPopulatedFieldsAsMap();

		for( String fieldName : fieldsInRecord.keySet()) {
			if( fieldName == 'Id'){
				this.id = record.Id;
			} else if( fieldName == 'Name'){
				this.name = record.Name;
			} else if( fieldName == 'ProjectTask__c'){
				this.projectTaskId = record.ProjectTask__c;
			} else if( fieldName == 'TaskTotalApprovedCostSnapshot__c'){
				this.taskTotalApprovedCostSnapshot = record.TaskTotalApprovedCostSnapshot__c;
			} else if( fieldName == 'EarnedValue__c'){
				this.earnedValue = record.EarnedValue__c;
			} else if( fieldName == 'CostAccruals__c'){
				this.costAccruals = record.CostAccruals__c;
			} else if( fieldName == 'SnapshotDate__c'){
				this.snapshotDate = record.SnapshotDate__c;
			}
		}
	}

	/**
	 * @Description this contructor is used when accessing data from JSON for testing but user just wants to pass a string in
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    Sept 2016
	 *
	 * @param	parser
	 * @return 	
	 **/
	public ECO_Mapper_EarnedValueTask( String jsonRecord){
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
	public ECO_Mapper_EarnedValueTask( JSONParser parser) {
		while( parser.nextToken() != JSONToken.END_OBJECT) {
			if( parser.getCurrentToken() == JSONToken.FIELD_NAME) {
				String token = parser.getText();
				if (parser.nextToken() != JSONToken.VALUE_NULL) {
					if( token == 'attributes'){
						attributes = new Attributes(parser);
					} else if( token == 'Id'){
						this.id = parser.getText();
					} else if( token == 'Name'){
						this.name = parser.getText();
					} else if( token == 'ProjectTask__c'){
						this.projectTaskId = parser.getText();
					} else if( token == 'TaskTotalApprovedCostSnapshot__c'){
						this.taskTotalApprovedCostSnapshot = parser.getDecimalValue();
					} else if( token == 'EarnedValue__c'){
						this.earnedValue = parser.getDecimalValue();
					} else if( token == 'CostAccruals__c'){
						this.costAccruals = parser.getDecimalValue();
					} else if( token == 'SnapshotDate__c'){
						this.snapshotDate = parser.getDateValue();
					} else {
						//System.debug(LoggingLevel.WARN, '*****Error in ECO_Mapper_EarnedValueTask mock constructor - Root consuming unrecognized property: ' + token);
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
	 * @return 	EarnedValueTask__c
	 **/
	public EarnedValueTask__c unmapToSOject( List<String> fieldToPopulate){
		EarnedValueTask__c newRecord = new EarnedValueTask__c();

		for( String fieldName : fieldToPopulate) {
			if( fieldName == 'Id'){
				newRecord.Id = this.Id;
			//formula, rollup summary or auto-number fields, no writing allowed
			//} else if( fieldName == 'Name'){
			//	newRecord.Name = this.name;
			} else if( fieldName == 'ProjectTask__c'){
				newRecord.ProjectTask__c = this.projectTaskId;
			} else if( fieldName == 'TaskTotalApprovedCostSnapshot__c'){
				newRecord.TaskTotalApprovedCostSnapshot__c = this.taskTotalApprovedCostSnapshot;
			//formula, rollup summary or auto-number fields, no writing allowed
			//} else if( fieldName == 'EarnedValue__c'){
			//	newRecord.EarnedValue__c = this.earnedValue;
			} else if( fieldName == 'CostAccruals__c'){
				newRecord.CostAccruals__c = this.costAccruals;
			} else if( fieldName == 'SnapshotDate__c'){
				newRecord.SnapshotDate__c = this.snapshotDate;
			}
		}

		return newRecord;
	}
}