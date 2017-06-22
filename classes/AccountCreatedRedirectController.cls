/*************************************************************************
*
* PURPOSE: Controller for AccountCreated page used to workout if accounts country 
* 		   is australia. If it is then redirect to the ABNSearch page
*
* AUTHOR: Luke Farbotko
***************************************************************************/
public class AccountCreatedRedirectController {
    
    
    public AccountCreatedRedirectController(ApexPages.StandardController controller)
    {
    }
    
     public Pagereference redirectNow()
    {
        //return null;
  		string newid = '';
            
       	try
        {
            newid = ApexPages.currentPage().getParameters().get('newid');
        }
       	catch(System.Exception ev){}
        
        Account acc;


		acc = [SELECT Id, CountryLookup__c FROM Account WHERE Id = :newid];
        
        Country__c ctry ;
        
        
        ctry = [SELECT Id, name FROM Country__c WHERE Id = :acc.CountryLookup__c];
        
        if (newid != '' && ctry.Name == 'Australia')
        {
            	return new PageReference('/apex/ABNSearch?id='+ newid);
         
        }
       	return new PageReference('/'+ newid );
    }

    

}