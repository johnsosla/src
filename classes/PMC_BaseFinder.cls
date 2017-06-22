public virtual class PMC_BaseFinder {

	private Set<String> mFieldSet;
	private String mSObjectName;

	public PMC_BaseFinder() { }

	public PMC_BaseFinder(String sObjectName) 
	{
		this.mSObjectName = sObjectName;
		SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
    	mFieldSet = new Set<String>(objToken.getDescribe().fields.getmap().keyset());		
	}

	public Set<String> getFieldSet() 
	{
		return mFieldSet; 
	}

	public void setFieldSet(Set<String> newFieldSet) 
	{
		mFieldSet = newFieldSet;
	}

	protected String getFields() 
	{
		return String.join(
			new List<String>(mFieldSet),',');
	}

	protected void addFields(Set<String> newFields) 
	{
		mFieldSet.addAll(newFields);
	}

	protected void addField(String newField)
	{
		mFieldSet.add(newField);
	}
 
	protected String getSelect() 
	{
		return 'select ' + getFields() + ' from ' + mSObjectName + ' ';
	}

	protected List<SObject> getSelectWhere(String field, String whereClause) 
	{
		return Database.query(getSelect() + 'where ' + field + ' =: whereClause');
	}

 
	public virtual sObject byId(Id recId) 
	{
		return Database.query(getSelect() + 'where Id =: recId');
	}

	public virtual List<sObject> findAll()
	{
		return (List<sObject>)Database.query(getSelect());		
	}

	public static String quote (String param) 
	{
		return '\'' + String.escapeSingleQuotes(param) + '\'';
	}
}