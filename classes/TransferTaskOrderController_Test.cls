/*****************************************
PR          ::  PR-05787
Requester   ::  Karishma Sharma
Purpose     ::  Test functionality and coverage of TransferTaskOrderController apex class
Author      ::  Appirio Offshore(Shailendra Singh)
Date        ::  11/08/2010  
*****************************************/
@isTest
private class TransferTaskOrderController_Test {
    
    static testMethod void TestTransferTaskOrderController() {
        // Account
       Map<String,ID> recordTypesMap = new Map<String,ID>();
       for(RecordType r:[select id,Name from RecordType where sObjectType='Opportunity' and isActive=true]){
           recordTypesMap.put(r.Name,r.Id);
           system.debug('###' + r.Name);
       }
        
        
	    ExecuteTrigger__c ext = ExecuteTrigger__c.getInstance('OpportunityBeforeInsertBeforeUpdate');
        if(ext == null)
        {
            ext = new ExecuteTrigger__c(Name='OpportunityBeforeInsertBeforeUpdate');
            ext.NotRunTrigger__c = true;
            insert ext;
        } else {
            ext.NotRunTrigger__c = true;
            update ext;
        }
        
		AECOM_Primary_Department__c primaryDept = new AECOM_Primary_Department__c(Lead_Region__c = 'test Lead Region');
        primaryDept.Status__c = 'Active';
		insert primaryDept;      
        
	    Test.startTest();
        Account acc=new Account();
        acc.Name='Test Account';
        acc.Type__c='Client';
        acc.Client_Group__c='Industrial/Commercial';
        acc.Client_Subgroup__c='Small - population under 500K';
        acc.Legacy_AccountID__c='12212';
        insert acc;
        
        // Master Contract
        Opportunity masterContract=new Opportunity(Legacy_OpportunityID__c='101');
        masterContract.AccountId=acc.id;
        masterContract.Name='Test';
        //masterContract.Primary_Business_Line__c='Water';
        masterContract.AECOM_Primary_Dept_Lookup__c= primaryDept.ID;
        masterContract.CloseDate=Date.today();
        masterContract.StageName='1 Lead';
        masterContract.RecordTypeId=recordTypesMap.get('Program - APAC');
        masterContract.Estimated_work_start_date__c = Date.today();
        masterContract.Enterprise_Service__c = 'None';
        masterContract.ProjectCountry__c = 'Test';

        // added to pass validation rule
        masterContract.CS_Gross_Margin_Percent__c = 15;        
        
        insert masterContract;      
        
        // Second Master Contract
        Opportunity masterContract2=new Opportunity(Legacy_OpportunityID__c='102');
        masterContract2.AccountId=acc.id;
        masterContract2.Name='Test';
        //masterContract2.Primary_Business_Line__c='Water';
        masterContract2.AECOM_Primary_Dept_Lookup__c=primaryDept.ID;
        masterContract2.CloseDate=Date.today();
        masterContract2.StageName='1 Lead';
        masterContract2.RecordTypeId=recordTypesMap.get('Program - APAC');
        masterContract2.Estimated_work_start_date__c = Date.today();
        masterContract2.Enterprise_Service__c = 'None';
        masterContract2.ProjectCountry__c = 'Test';

        // added to pass validation rule
        masterContract2.CS_Gross_Margin_Percent__c = 15;        

        insert masterContract2;
        
        
        // Task Order
        Opportunity taskOrder=new Opportunity(Legacy_OpportunityID__c='103');
        taskOrder.Name='Test';
        //taskOrder.Primary_Business_Line__c='Water';
        taskOrder.AECOM_Primary_Dept_Lookup__c=primaryDept.ID;
        taskOrder.CloseDate=Date.today();
        taskOrder.StageName='1 Lead';
        taskOrder.AccountId=acc.ID;
        taskOrder.Master_Contract_lookup__c=masterContract.id;
        taskOrder.RecordTypeId=recordTypesMap.get('Task Order - APAC');
        taskOrder.Estimated_work_start_date__c = Date.today();
        taskOrder.Enterprise_Service__c = 'None';
        taskOrder.ProjectCountry__c = 'Test';
        taskOrder.Reason_Won_or_Lost__c = 'Test';

        // added to pass validation rule
        taskOrder.CS_Gross_Margin_Percent__c = 15;        

        insert taskOrder;
        Test.stopTest();

        PageReference pageRef = Page.TransferTaskOrder;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('taskOrderID', taskOrder.ID);
        TransferTaskOrderController controller=new TransferTaskOrderController();


        controller.opportunityName='';
        controller.searchOpportunities();
        System.assertEquals(null,controller.masterContracts); // validation 
        
        controller.opportunityName='sdfsdfsdofjsdofjsdo';
        controller.searchOpportunities();      
        System.assertEquals(null,controller.masterContracts); // validation


        
        
        controller.opportunityName='Test';
        controller.searchOpportunities();
        
        System.assertNotEquals(null,controller.masterContracts); 
        
        taskOrder=controller.taskOrder;
        taskOrder.Master_Contract_lookup__c=masterContract2.id;
        controller.updateTaskOrder();
        
        
        System.assertEquals(controller.taskOrder.Master_Contract_lookup__c,masterContract2.id);
        controller.cancel();

    }
}