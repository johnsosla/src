/*******************************************************************************
*
* PURPOSE: Base finder class for model for sObjects
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
*******************************************************************************/
public virtual class GFA_BaseFinder {

    public static final Integer SOQL_LIMIT = 30000;

    protected Set<String> mFieldSet;
    protected String mSObjectName;

    public GFA_BaseFinder(String sObjectName)  {
        this.mSObjectName = sObjectName;
        SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
        mFieldSet = new Set<String>(objToken.getDescribe().fields.getmap().keyset());
    }

    public GFA_BaseFinder(String sObjectName, Set<String> fieldSet) {
        mSObjectName = sObjectName;
        mFieldSet = fieldSet;
    }

    public Set<String> getFieldSet()  {
        return mFieldSet;
    }
    public void setFieldSet(Set<String> newFieldSet)  {
        mFieldSet = newFieldSet;
    }

    protected String getFields() {
        return String.join(new List<String>(mFieldSet), ',');
    }

    /**
    *   @param newFields set of Strings that should be included in SOQL query
    **/
    protected void addFields(Set<String> newFields) {
        mFieldSet.addAll(newFields);
    }
    /**
    *   @param newField String that should be included in SOQL query
    **/
    protected void addField(String newField) {
        mFieldSet.add(newField);
    }

    /**
    *   @return Select string with all fields for this sObj
    **/
    protected String getSelect() {
        return 'select ' + getFields() + ' from ' + mSObjectName + ' ';
    }

    /**
    *   @param field Object field SOQL statement will check against
    *   @param whereClause value to check against the field
    *   @return List of sObjects matching where clause
    **/
    protected List<SObject> getSelectWhere(String field, String whereClause) {
        return Database.query(getSelect() + 'where ' + field + ' =: whereClause');
    }

    /**
    *   @param field Object field SOQL statement will check against
    *   @param whereIn Set of Strings to check field against
    *   @return List of sObjects that matched where clause
    **/
    protected List<SObject> getSelectIn(String field, Set<String> whereIn) {
        return Database.query(getSelect() + 'where ' + field + ' in: whereIn');
    }

    /**
    * @param recId Id of record to search for
    * @return Record that matches recId
    **/
    public virtual sObject byId(Id recId) {
        return Database.query(getSelect() + 'where Id =: recId');
    }

    /**
    * @param param String that will be quoted
    * @return String of param that will be single quoted
    **/
    public static String quote (String param) {
        return '\'' + String.escapeSingleQuotes(param) + '\'';
    }

    /**
    * @param param Strings that will be quoted
    * @return String of param that will be single quoted within parantheses
    **/
    public static String quote(List<String> params) {
        String res = '(';
        for (String param : params) {
            res += '\'' + String.escapeSingleQuotes(param) + '\',';
        }
        //---Remove trailing comma
        res = res.removeEnd(',');
        return res + ')';
    }

    /**
    * @param param Strings that will be quoted
    * @return String of param that will be single quoted within parantheses
    **/
    public static String quote(Set<String> params) {
        String res = '(';
        for (String param : params) {
            res += '\'' + String.escapeSingleQuotes(param) + '\',';
        }
        //---Remove trailing comma
        res = res.removeEnd(',');
        return res + ')';
    }

    /**
    * @param field Schema field to get pick list values from
    * @return List of String for each of the pick list values from field
    **/
    public static List<String> getPicklistOptions(Schema.sObjectField field) {
        List<Schema.PicklistEntry> ple = field.getDescribe().getPicklistValues();

        List<String> options = new List<String>();
        for ( Schema.PicklistEntry f : ple) {
            options.add(f.getValue());
        }
        return options;
    }
}