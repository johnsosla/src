/*************************************************************************
* 
* PURPOSE: The base data access object class. This class provides convenience 
*			methods for retrieving and storing data with dynamic SOQL.
*
* CLASS: gng_BaseDao
* CREATED: 12/15/2014 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
***************************************************************************/

public virtual class gng_BaseDao {

	private static final String MAX_RECORDS = '49999';
	private static String fieldList;
	private String objectName;
	private Set<String> objectFields;

	public gng_BaseDao(String objName) {
		objectName = objName;
    	objectFields = new Set<String>();
    	SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
    	DescribeSObjectResult objDef = objToken.getDescribe();
    	addFields(objDef.fields.getMap().keySet());
	}

	public void addFields(Set<String> objFields) {
        objectFields.addAll(objFields);
        fieldList = String.join(new List<String>(objectFields), ',').toLowerCase();
    }

    public Set<String> getFields() {
        return objectFields;
    }

    /**
    * This method gets the dynamic SOQL based on the input parameters
    *
    * @param  whereClause  the where clause of the SOQL statement  e.g. Name = 'Some Name'
    * @param  orderClause  the order clause of the SOQL statement, e.g. Name Desc
    * @param  limitSize  upper bound of how many records to return
    *
    * @returns a String representing the dynamic SOQL
    */

    public String getSelect(String whereClause, String orderClause, Integer limitSize) {
        String query = 'select ' + fieldList + ' from ' + String.escapeSingleQuotes(objectName);
        if (String.isNotBlank(whereClause)) query += ' where ' + whereClause;
        if (String.isNotBlank(orderClause)) query += ' order by ' + String.escapeSingleQuotes(orderClause);
        if (limitSize != null) query += ' limit ' + String.valueOf(limitSize);
        else query += ' limit ' + MAX_RECORDS;
        
        return query;
    }

    /**
    * This method gets an sObject with the given Id
    *
    * @param  recordId the Id of the record
    *
    * @returns an sObject with the given Id
    */
    public sObject getSObjectById(String recordId) {
    	
    	if (recordId == null) return null;		//---Prevent null error if no records returned;
    	
        String query = 'select ' + fieldList + ' from ' + objectName + ' where id = ' + quote(recordId);
        return (SObject)Database.query(query);
    }

    /**
    * This method gets an sObject with the given Id and field list
    *
    * @param  recordId the Id of the record
    * 
    * @param fields set of fields that will be returned
    *
    * @returns an sObject with the given Id
    */
    public sObject getSObjectById(String recordId,Set<String> fields) {
        
        if (recordId == null) return null;      //---Prevent null error if no records returned;
        
        String query = 'select ' + String.join(new List<String>(fields), ',').toLowerCase() + ' from ' + objectName + ' where id = ' + quote(recordId);
        return (SObject)Database.query(query);
    }

    /**
    * This method executes a dynamic SOQL query and returns a list of sObjects
    *
    * @param  whereClause  the where clause of the SOQL statement
    *
    * @returns a List<sObject> based on the given parameters
    */
    public List<sObject> getSObjects(String whereClause) {
        return getSObjects(whereClause, null, null);
    }

    /**
    * This method executes a dynamic SOQL query and returns a list of sObjects
    *
    * @param  whereClause  the where clause of the SOQL statement  e.g. Name = 'Some Name'
    * @param  orderClause  the order clause of the SOQL statement, e.g. Name Desc
    *
    * @returns a List<sObject> based on the given parameters
    */
    public List<SObject> getSObjects(String whereClause, String orderClause) {
        String query = getSelect(whereClause, orderClause, Integer.valueOf(MAX_RECORDS));
        return (List<SObject>)Database.query(query);
    }

    /**
    * This method executes a dynamic SOQL query and returns a list of sObjects
    *
    * @param  whereClause  the where clause of the SOQL statement  e.g. Name = 'Some Name'
    * @param  orderClause  the order clause of the SOQL statement, e.g. Name Desc
    * @param  limitSize  upper bound of how many records to return
    *
    * @returns a List<sObject> based on the given parameters
    */
    public List<SObject> getSObjects(String whereClause, String orderClause, Integer limitSize) {
        String query = getSelect(whereClause, orderClause, limitSize);
        return (List<SObject>)Database.query(query);
    }
    
    /**
    * This method returns a quoted and escaped version of the string
    *
    * @param inStr the input string
    *
    * @returns a quoted and escaped version of the input string
    */
    public static String quote(String inStr) {
    	if(inStr == null) inStr = '';
        return '\'' + String.escapeSingleQuotes(inStr) + '\'';
    } 

}