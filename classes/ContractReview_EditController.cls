public with sharing class ContractReview_EditController {

    ApexPages.StandardController ctr;

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public ContractReview_EditController(ApexPages.StandardController stdController) {
        this.ctr = stdController;
    }

     public Pagereference Next()
    {
        try
        {
            Contract_Review__c crs = (Contract_Review__c)ctr.getRecord();

            if(ctr.save() != null) {
                
                //return new PageReference('/' + ctr.getId() + '/e?retURL=%2F' + ctr.getId() );
               
                return new PageReference('/p/attach/NoteAttach?pid=' + (String)crs.get('Id') + '&parentname=' + crs.get('Name') + '&retURL=%2F' + crs.get('Id')  );
           
            }
            return null;
        }
        catch(Exception ex)
        {
            return null;    
        }
    }

   
}