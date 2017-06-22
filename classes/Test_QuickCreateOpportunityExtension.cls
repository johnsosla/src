/*******************************************************************
  Name        :   Test_QuickCreateOpportunityExtension
  Author      :   Appirio Off
  Version     :   1.0 
  Purpose     :   Test Class for QuickCreateOpportunityExtension Class
  Date        :   20 Aug, 2010 
********************************************************************/
@isTest
private class Test_QuickCreateOpportunityExtension {
    static testMethod void testQuickCreateOpportunityExtension(){
        RecordType oppRecordType = [Select Id, Name from RecordType Where sObjectType = 'Opportunity'  limit 1];
        Opportunity op=new Opportunity(Legacy_OpportunityID__c='101');
        op.Name='Test case opportunity';
        op.CloseDate=Date.today().addDays(30);
        op.StageName='Prospecting';
        op.Amount=100;
        op.Win_Probability__c=10;
        op.CloseDate = Date.today().addDays(5);
        op.Book_date__c=Date.today().addDays(-1);
        op.Enterprise_Service__c = 'Engineering';
        //op.Contract_duration_in_Months__c=2.0;
        string strRecordType = '';
        if(oppRecordType  != null){
             strRecordType = oppRecordType.ID;
             op.RecordTypeID = oppRecordType.ID;
         }
         
        Opportunity op1=new Opportunity(Legacy_OpportunityID__c='102');
        op1.Name='Test case opportunity';
        op1.CloseDate=Date.today().addDays(30);
        op1.StageName='Prospecting';
        op1.Amount=100;
        op1.Win_Probability__c=10;
        op1.CloseDate = Date.today().addDays(5);
        op1.Book_date__c=Date.today().addDays(-1);
        op1.Enterprise_Service__c = 'Engineering';
        //op.Contract_duration_in_Months__c=2.0;
              
        insert op;
        ApexPages.currentPage().getParameters().put('oppid',op.Id);              
        ApexPages.currentPage().getParameters().put('RecordType',strRecordType); 
        ApexPages.StandardController stdc= new ApexPages.StandardController(op1);      
        QuickCreateOpportunityExtension qcopp = new QuickCreateOpportunityExtension(stdc);       
        qcopp.saveAndNew();
    }
}