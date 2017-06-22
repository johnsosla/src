public virtual class CFM_BaseFinder {

	public static final Integer SOQL_LIMIT = 30000;

	protected Set<String> mFieldSet;
	protected String mSObjectName;

	public CFM_BaseFinder(String sObjectName)  {
		this.mSObjectName = sObjectName;
		SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
    	mFieldSet = new Set<String>(objToken.getDescribe().fields.getmap().keyset());		
	}

	public CFM_BaseFinder(String sObjectName, Set<String> fieldSet) {
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
		return String.join(new List<String>(mFieldSet),',');
	}

	protected void addFields(Set<String> newFields) {
		mFieldSet.addAll(newFields);
	}

	protected void addField(String newField) {
		mFieldSet.add(newField);
	}
 
	protected String getSelect() {
		return 'select ' + getFields() + ' from ' + mSObjectName + ' ';
	}

	protected List<SObject> getSelectWhere(String field, String whereClause) {
		return Database.query(getSelect() + 'where ' + field + ' =: whereClause');
	}

    protected List<SObject> getSelectIn(String field, List<String> whereIn) {
        return Database.query(getSelect() + 'where ' + field + ' in: whereIn');
    }
 
	public virtual sObject byId(Id recId) {
		return Database.query(getSelect() + 'where Id =: recId');
	}

	public static String quote (String param) {
		return '\'' + String.escapeSingleQuotes(param) + '\'';
	}
}