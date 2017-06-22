public class menuItemController
{
    //public string getGeographyDesc()
    //{
        //Schema.DescribeSObjectResult describeSObjectResult = Schema.SObjectType.Geography__c;
        //string res = describeSObjectResult.getDescription();
        //return res;

    //}
    public string Typ{get;set;}
    public menuItemController()
    {
         Typ = ApexPages.currentPage().getParameters().get('typ');
         if(Typ=='' || Typ == null)
             Typ='ALL';         
    }
}