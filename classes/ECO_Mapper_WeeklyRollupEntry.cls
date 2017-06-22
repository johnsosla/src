/** ------------------------------------------------------------------------------------------------------
 * @Description 
 *
 * @Author      NTT Data - Deborah Orth
 * @Date        Aug 2016
 *-----------------------------------------------------------------------------------------------------*/
public with sharing class ECO_Mapper_WeeklyRollupEntry extends ECO_BaseMapper {
	public String id 										{ get; set; }
	public String name 										{ get; set; }
	public String fiscalMonth								{ get; set; }
	public Date periodStartDate 							{ get; set; }

	/**
	 * @Description empty contructor is used when this class is a child of another mapper class
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    Aug 2016
	 *
	 * @param   
	 * @return  
	**/
	public ECO_Mapper_WeeklyRollupEntry() {}

	/**
	 * @Description this contructor is used when accessing data from the DB
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    Aug 2016
	 *
	 * @param	
	 * @return 	
	 **/
	public ECO_Mapper_WeeklyRollupEntry( WeeklyRollupEntry__c record){
		Map<String, Object> fieldsInRecord = record.getPopulatedFieldsAsMap();

		for( String fieldName : fieldsInRecord.keySet()) {
			if( fieldName == 'Id'){
				this.id = record.Id;
			} else if( fieldName == 'Name'){
				this.name = record.Name;
			} else if( fieldName == 'FiscalMonth__c'){
				this.fiscalMonth = record.FiscalMonth__c;
			} else if( fieldName == 'PeriodStartDate__c'){
				this.periodStartDate = record.PeriodStartDate__c;
			}
		}
	}

	/**
	 * @Description this contructor is used when accessing data from JSON for testing but user just wants to pass a string in
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    September 2016
	 *
	 * @param	jsonRecord
	 * @return 	
	 **/
	public ECO_Mapper_WeeklyRollupEntry( String jsonRecord){
		this(System.JSON.createParser( jsonRecord));
	}

	/**
	 * @Description this contructor is used when accessing data from JSON for testing
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    Aug 2016
	 *
	 * @param	
	 * @return 	
	 **/
	public ECO_Mapper_WeeklyRollupEntry( JSONParser parser) {

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
					} else if (token == 'FiscalMonth__c') {
						this.fiscalMonth = parser.getText();
					} else if (token == 'PeriodStartDate__c') {
						this.periodStartDate = parser.getDateValue();
					} else {
						//System.debug(LoggingLevel.WARN, '*****Error in ECO_Mapper_WeeklyRollupEntry mock constructor - Root consuming unrecognized property: ' + token);
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
	 * @return 	WeeklyRollupEntry__c
	 **/
	public WeeklyRollupEntry__c unmapToSOject( List<String> fieldToPopulate){
		WeeklyRollupEntry__c newRecord = new WeeklyRollupEntry__c();

		for( String fieldName : fieldToPopulate) {
			if( fieldName == 'Id'){
				newRecord.Id = this.Id;
			//formula, rollup summary or auto-number fields, no writing allowed
			//} else if( fieldName == 'Name'){
			//	newRecord.name = this.Name;
			} else if( fieldName == 'FiscalMonth__c'){
				newRecord.FiscalMonth__c = this.fiscalMonth;				
			} else if( fieldName == 'PeriodStartDate__c'){
				newRecord.PeriodStartDate__c = this.periodStartDate;				
			}
		}

		return newRecord;
	}
}