public class newOpportunityRedirect
{
    public newOpportunityRedirect(ApexPages.StandardController controller)
    {
    }
    public Pagereference redirectNow()
    {
        string retURL = ApexPages.currentPage().getParameters().get('retURL');
        string RecordType = ApexPages.currentPage().getParameters().get('RecordType');
        string saveurl= EncodingUtil.urlEncode('/apex/ModifyDepartment','UTF-8');
        string accid = ApexPages.currentPage().getParameters().get('accid');
        string str = '/006/e?nooverride=1&retURL='+retURL+'&RecordType='+RecordType+'&saveURL='+saveurl;
        if(accid!='' && accid!=null)
            str = str+'&accid='+accid;
        return new PageReference(str);
    }
}