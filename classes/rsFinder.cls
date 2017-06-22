/*************************************************************************
*
* PURPOSE: This class replaces our old notion of DAOs, essentially it should
* be extended and instans'd as a staic class witin classes that
* extend rsModel. For an example see rsProfile
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public virtual with sharing class rsFinder {

    private Set<String> mFieldSet;
    private String mSObjectName;

    public rsFinder() {}

    public rsFinder(String sObjectName) {
        this.mSObjectName = sObjectName;
        SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
        mFieldSet = new Set<String>(objToken.getDescribe().fields.getmap().keyset());
    }

    public Set<String> getFieldSet() {
        return mFieldSet;
    }

    public void setFieldSet(Set<String> newFieldSet) {
        mFieldSet = newFieldSet;
    }

    protected String getFields() {
        return String.join(
                   new List<String>(mFieldSet), ',');
    }

    protected void addFields(Set<String> newFields) {
        mFieldSet.addAll(newFields);
    }

    protected String createStringInSet(Set<String> values) {
        Set<String> newValues = new Set<String>();
        for (String value : values) {
            newValues.add(rsStringUtil.quote(value));
        }
        return '(' + String.join(new List<String>(newValues), ',') + ')';
    }

    protected String createStringInSet(String values) {
        Set<String> newValues = new Set<String>(values.split(','));
        return createStringInSet(newValues);
    }

    protected String getSelect() {
        return 'select ' + getFields() + ' from ' + mSObjectName + ' ';
    }

    public virtual rsModel byId(Id recId) {
        return new rsModel(Database.query(getSelect() + 'where Id =: recId'));
    }
}