public class newAccountRedirect
{
    public newAccountRedirect(ApexPages.StandardController controller)
    {
    }
    public Pagereference redirectNow()
    {
        //https://aecom--anzmigrate.cs15.my.salesforce.com/001/e?retURL=%2F001%2Fo
        string retURL = ApexPages.currentPage().getParameters().get('retURL');
        //string RecordType = ApexPages.currentPage().getParameters().get('RecordType');
        string saveurl= EncodingUtil.urlEncode('/apex/AccountCreated','UTF-8');
        string accid = ApexPages.currentPage().getParameters().get('accid');
        string str = '/001/e?nooverride=1&retURL='+retURL+'&saveURL='+saveurl;
        if(accid!='' && accid!=null)
            str = str+'&accid='+accid;
        return new PageReference(str);
    }
}