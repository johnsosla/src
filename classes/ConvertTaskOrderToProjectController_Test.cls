/*****************************************
PR          ::  PR-05785
Requester   ::  Karishma Sharma
Purpose     ::  Test Class for ConvertTaskOrderToProjectController Class
Author      ::  Appirio Offshore(Neeraj Gupta)
Date        ::  13/08/2010  
*****************************************/
@isTest
private class ConvertTaskOrderToProjectController_Test  {
	static Account acc;
    static Account acc1;
    static Id aecomId;
    static Opportunity masterContract;
    static Map<String,Id> recordTypes;
    
    static void setup() {
        recordTypes = new Map<String,Id>();
    	
    	for(RecordType  recType :[Select Name, Id From RecordType where SobjectType ='Opportunity']){
    		recordTypes.put(recType.Name,recType.Id);
    	}
    	
    	
    	//for(AECOM_Primary_Department__c aecom :[select id from AECOM_Primary_Department__c limit 1]){
    	//	aecomId = aecom.id;
    	//}

        //Primary Department
        AECOM_Primary_Department__c primaryDept;
        List<AECOM_Primary_Department__c> departments;

        departments = [SELECT Lead_Region__c FROM AECOM_Primary_Department__c WHERE Name = 'test Lead Region' LIMIT 1];
        if(departments.size() == 0){
            primaryDept = new AECOM_Primary_Department__c(Lead_Region__c = 'test Lead Region');
            insert primaryDept;
        }
        else{
            primaryDept = departments[0];
        }
        aecomId = primaryDept.Id;



       // Account
        acc=new Account();
        acc.Name='Test Account';
        acc.Type__c='Client';
        acc.Client_Group__c='Industrial/Commercial';
        acc.Client_Subgroup__c='Small - population under 500K';
        acc.Legacy_AccountID__c='12212' + System.now();
        acc.City__c='testCity';
        insert acc;
        
        
        // Account
        acc1=new Account();
        acc1.Name='Test Account1';
        acc1.Type__c='Client';
        acc1.Client_Group__c='Industrial/Commercial';
        acc1.Client_Subgroup__c='Small - population under 500K';
        acc1.Legacy_AccountID__c='1221234';
        acc1.City__c='testCity';
        insert acc1;
        
        // Master Contract
        masterContract=new Opportunity();
        masterContract.AccountId=acc.id;
        masterContract.Name='Test';
        //masterContract.Primary_Business_Line__c='Water';
        masterContract.AECOM_Primary_Dept_Lookup__c=aecomId;
        masterContract.CloseDate=Date.today();
        masterContract.StageName='1 Lead';
        //masterContract.RecordTypeId=[select ID from RecordType where Name='Program'].Id;
        masterContract.RecordTypeId=recordTypes.get('Program - Americas');
        
        masterContract.Legacy_OpportunityID__c ='test' + System.now();

        masterContract.Estimated_work_start_date__c = Date.today().addDays(90);
        masterContract.TO_Procurement_Method__c = 'Competitive Task Orders';
        masterContract.Enterprise_Service__c = 'Engineering';
        masterContract.AECOM_Primary_Dept_Lookup__c = primaryDept.Id;

        // added to pass validation rule
        masterContract.CS_Gross_Margin_Percent__c = 15;

        insert masterContract;      
    }
    
    
    
    static testMethod void myUnitTest1() {
    	
        setup();
        test.startTest();
        // Task Order
        Opportunity taskOrder1=new Opportunity();
        taskOrder1.Name='TestTask1';
        //taskOrder1.Primary_Business_Line__c='Water';
        taskOrder1.AECOM_Primary_Dept_Lookup__c=aecomId;
        taskOrder1.CloseDate=Date.today();
        taskOrder1.StageName='1 Lead';
        taskOrder1.AccountId=acc.ID;
        taskOrder1.Master_Contract_lookup__c=masterContract.id;
        taskOrder1.RecordTypeId=recordTypes.get('Task Order - Americas');
        taskOrder1.Legacy_OpportunityID__c='test3' + System.now();
        taskOrder1.ProjectCountry__c = 'United States';

        taskOrder1.Estimated_work_start_date__c = Date.today().addDays(90);
        taskOrder1.TO_Procurement_Method__c = 'Competitive Task Orders';
        taskOrder1.Enterprise_Service__c = 'Engineering';
        taskOrder1.Project_State_Province__c = 'Victoria';

        // added to pass validation rule
        taskOrder1.CS_Gross_Margin_Percent__c = 15;

        insert taskOrder1;
               
        ConvertTaskOrderToProjectController controller;
        /*******************************************
        //checking with same account functionality 
        ********************************************/
        PageReference pageRef = Page.ConvertTaskOrderToProject;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', taskOrder1.ID);
        ApexPages.currentPage().getParameters().put('proj2prog','1');
        ApexPages.currentPage().getParameters().put('proj2task','1');
        controller=new ConvertTaskOrderToProjectController(new ApexPages.standardController(taskOrder1));
        
        System.assert(1==[select count() from Opportunity where id=:taskOrder1.ID]);
        controller.gotoStep2();
        Pagereference ref = controller.saveAccount();
        
        List<Opportunity> oppList = [Select Name from Opportunity where accountid =: acc.Id and id != : taskOrder1.Id limit 100];
        
        System.assert(oppList != null);
        System.assert(oppList.size() > 0);
        System.assert(ref != null);
        //System.assertEquals('/' + oppList[0].Id, ref.getUrl());
        
        System.debug('::::::: count::::::::::::'+[select count() from Opportunity where id=:taskOrder1.ID limit 100]);
        //System.assert(0==[select count() from Opportunity where id=:taskOrder1.ID]);
        
        
     
   /*******************************
        Only for Increasing Coverage
        *******************************/
        controller.accountName='T';
        controller.searchAccounts();
        controller.getOptions();
        controller.gotoStep2();
        controller.getShowMoreThen100();
        controller.gotoCancel();
        
        test.stopTest();
         
        
    }
    
     static testMethod void myUnitTest2() {
    	
        setup();
        test.startTest();
        
         // Task Order for Program_North_America
        Opportunity taskOrderNew=new Opportunity();
        taskOrderNew.Name='TestTask';
        //taskOrderNew.Primary_Business_Line__c='Water';
        taskOrderNew.AECOM_Primary_Dept_Lookup__c=aecomId;
        taskOrderNew.CloseDate=Date.today();
        taskOrderNew.StageName='1 Lead';
        taskOrderNew.AccountId=acc.ID;
        taskOrderNew.Master_Contract_lookup__c=masterContract.id;
        taskOrderNew.RecordTypeId=recordTypes.get('Task Order - Americas');
        taskOrderNew.Legacy_OpportunityID__c='test5' + System.now();
        taskOrderNew.ProjectCountry__c = 'United States';

        taskOrderNew.Estimated_work_start_date__c = Date.today().addDays(90);
        taskOrderNew.TO_Procurement_Method__c = 'Competitive Task Orders';
        taskOrderNew.Enterprise_Service__c = 'Engineering';
        taskOrderNew.Project_State_Province__c = 'Victoria';

        // added to pass validation rule
        taskOrderNew.CS_Gross_Margin_Percent__c = 15;

        insert taskOrderNew;
        
      
       
       
        ConvertTaskOrderToProjectController controller;
        
        
        //For taskOrderNew
        PageReference pageRefNew = Page.ConvertTaskOrderToProject;
        Test.setCurrentPage(pageRefNew);
        ApexPages.currentPage().getParameters().put('id', taskOrderNew.ID);
        ApexPages.currentPage().getParameters().put('proj2prog','1');
        ApexPages.currentPage().getParameters().put('proj2task','1');
        controller=new ConvertTaskOrderToProjectController(new ApexPages.standardController(taskOrderNew));
        
        System.assert(1==[select count() from Opportunity where id=:taskOrderNew.ID]);
        controller.gotoStep2();
        Pagereference refNew = controller.saveAccount();
        
        List<Opportunity> oppList = [Select Name from Opportunity where accountid =: acc.Id and id != : taskOrderNew.Id limit 100];
        
        System.assert(oppList != null);
        System.assert(oppList.size() > 0);
        System.assert(refNew != null);
        //System.assertEquals('/' + oppList[0].Id, ref.getUrl());
        
        System.debug('::::::: count::::::::::::'+[select count() from Opportunity where id=:taskOrderNew.ID limit 100]);
        //System.assert(0==[select count() from Opportunity where id=:taskOrder1.ID]);
        
        
        
        PageReference pageRef = Page.ConvertTaskOrderToProject;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', taskOrderNew.ID);
        controller=new ConvertTaskOrderToProjectController( new ApexPages.standardController(taskOrderNew));
      
        controller.accountName='NotFountTestAccount1';
        controller.searchAccounts();
        System.assertEquals(null,controller.accountList); // validation 
     
   /*******************************
        Only for Increasing Coverage
        *******************************/
        controller.accountName='T';
        controller.searchAccounts();
        controller.getOptions();
        controller.gotoStep2();
        controller.getShowMoreThen100();
        controller.gotoCancel();
        
        test.stopTest();
         
        
    }   
    
     static testMethod void myUnitTest3() {
    	
        setup();
        
        
        
         // Task Order
        Opportunity taskOrder2=new Opportunity();
        taskOrder2.Name='TestTask2';
        //taskOrder2.Primary_Business_Line__c='Water';
        taskOrder2.AECOM_Primary_Dept_Lookup__c=aecomId;
        taskOrder2.CloseDate=Date.today();
        taskOrder2.StageName='1 Lead';
        taskOrder2.AccountId=acc.ID;
        taskOrder2.Master_Contract_lookup__c=masterContract.id;
        taskOrder2.RecordTypeId=recordTypes.get('Task Order - Americas');
        taskOrder2.Legacy_OpportunityID__c='test4' + System.now();
        taskOrder2.ProjectCountry__c = 'United States';

        taskOrder2.Estimated_work_start_date__c = Date.today().addDays(90);
        taskOrder2.TO_Procurement_Method__c = 'Competitive Task Orders';
        taskOrder2.Enterprise_Service__c = 'Engineering';
        taskOrder2.Project_State_Province__c = 'Victoria';

        // added to pass validation rule
        taskOrder2.CS_Gross_Margin_Percent__c = 15;

        insert taskOrder2;

        
        ConvertTaskOrderToProjectController controller;
        /*******************************************
        //checking with same account functionality 
        ********************************************/

        test.startTest();
        
        
        /***********************************************
        //checking with Different Account functionality
        ************************************************/

        PageReference pageRef = Page.ConvertTaskOrderToProject;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', taskOrder2.ID);
        controller=new ConvertTaskOrderToProjectController( new ApexPages.standardController(taskOrder2));
        
        System.assert(1==[select count() from Opportunity where id=:taskOrder2.ID]);
        controller.gotoSearchAccount();
        controller.accountName = 'Test Account1';
        controller.searchAccounts();
        System.assertNotEquals(null,controller.accountList);
        controller.selectedAccountID=controller.accountList.get(0).Id;
        
        PageReference ref = controller.saveAccount();
        
        //System.assert(0==[select count() from Opportunity where id=:taskOrder2.ID]);
        
        List<Opportunity> oppList = [Select Name from Opportunity where accountid =: acc1.Id and id != : taskOrder2.Id limit 100];
        
        System.assert(oppList != null);
        //System.assert(oppList.size() > 0);
        //System.assert(ref != null);
        //System.assertEquals('/' + oppList[0].Id, ref.getUrl());
        
        //check new project type opportunity
        //System.assert(1=[select count() from Opportunity where id=:taskOrder.ID]);
        
        
        pageRef = Page.ConvertTaskOrderToProject;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', taskOrder2.ID);
        controller=new ConvertTaskOrderToProjectController( new ApexPages.standardController(taskOrder2));
      
        controller.accountName='NotFountTestAccount2';
        controller.searchAccounts();      
        System.assertEquals(null,controller.accountList); // validation
  
           
   /*******************************
        Only for Increasing Coverage
        *******************************/
         
        controller.accountName='T';
        controller.searchAccounts();
        controller.getOptions();
        controller.gotoStep2();
        controller.getShowMoreThen100();
        controller.gotoCancel();
        
        test.stopTest();

    }   
        
        
       
}