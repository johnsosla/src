public class newOpportunityDepartmentRedirect
{
    public string myURL;
    public newOpportunityDepartmentRedirect(ApexPages.StandardController std)
    {
        Opportunity_Department__c opd1 = (Opportunity_Department__c)std.getRecord();
        for(Opportunity_Department__c opd:[Select Opportunity__c from Opportunity_Department__c where id=:opd1.id])
        myURL='/apex/modifyDepartment?oppid='+opd.Opportunity__c;
    }
    public Pagereference runModify()
    {
        return new Pagereference(myURL);
    }
}