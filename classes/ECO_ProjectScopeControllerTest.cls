@isTest
private class ECO_ProjectScopeControllerTest
{
	static void initializeSites(){



		String description = 'testDescription';
		AECOM_Primary_Department__c primaryDept = new AECOM_Primary_Department__c(Lead_Region__c = 'test Lead Region');
		insert primaryDept;


		Opportunity opp = new Opportunity(Name = 'source', StageName = 'Open', CloseDate = Date.today(), AECOM_Primary_Dept_Lookup__c = primaryDept.Id, ValidateGo__c = false);
		insert opp;

		ProjectRole__c role = new ProjectRole__c(Name = 'Deliverable Approver', Active__c = true);
		insert role;

		//pse__Proj__c testProject1 = new ECO_Utils_Testing.ProjectBuilder().build(false);

		//testProject1.pse__Opportunity__c = opp.Id;

		//insert testProject;

		ECO_Service_Delegation.run = false;
		ECO_ProjectTaskTriggers.run = false;
		ECO_ProjectTriggers.run = false;
		ECO_Utils_Testing.createTestDataForProjectSync(3, 3);


		pse__Proj__c testProject = [select Id from pse__Proj__c limit 1];

		testProject.pse__Opportunity__c = opp.Id;
		update testProject;

		ECO_ProjectTaskTriggers.run = true;		
		ECO_ProjectTriggers.run = true;		


        Deliverable__C oDeliver = new Deliverable__C();
        oDeliver.Project__c = testProject.id;
        oDeliver.Name = 'New Deliverable';
		insert oDeliver;

		ProjectReviewTemplate__c prt = new ProjectReviewTemplate__c(TemplateType__c = 'BIM Healthy Start');
		insert prt;
	}


	// Auto creation of package test
	@isTest
	static void testAutoCreate()
	{
		initializeSites();
		//user u = [select id from user where Alias = 'myuser'];

		pse__Proj__c projectOne = [select id from pse__Proj__c limit 1];
		test.startTest();

		//System.runAs(u) {

			PageReference myVfPage = Page.ECO_ProjectScope;
		    Test.setCurrentPageReference(myVfPage); // use setCurrentPageReference, 
		   
		    ApexPages.currentPage().getParameters().put('projectId',projectOne.Id);

			// Create standard controller for a new project and pass to the ext. Start the real test.
			ECO_ProjectScopeController ctr = new ECO_ProjectScopeController();
			ctr.AddScopePackage();
			ctr.AddScopePackage();
			ctr.AddScopePackage();

			ctr.lstPackages[1].Utilize_BMI_Technology__c = true;

			//ctr.savePackageAttachment();

			ctr.AttachFile();
			ctr.deleteAttachment();

			ctr.SavePackages();

			list<Packages__c> lstScope = [select id from Packages__c where Scope__c =: projectOne.id];
			system.assertEquals(lstScope.size(), 4);

			ctr = new ECO_ProjectScopeController();

			ctr.getYesNo();
			ctr.getYesNoBIM();

			ctr.sSelectedPackageId = ctr.lstPackages[1].id;
			ctr.AddSelectedDeliverables();

			ctr.sSelectedPackageId = ctr.lstPackages[1].id;
			ctr.DeleteSelectedScope();
			
			lstScope = [select id from Packages__c where Scope__c =: projectOne.id];
			system.assertEquals(lstScope.size(), 3);
			ctr.lstAssignedDeliverables = new list<ECO_ProjectScopeController.DeliverableWrapper>();
			ctr.lstUnAssignedDeliverables = new list<ECO_ProjectScopeController.DeliverableWrapper>();
			ctr.errorLevel = 'testing';
			ctr.messageName = 'testing';
			//ctr.savePackageAttachment();

			//system.assertEquals(ext.lstSitesSearchResults.size(), 2); 
		//}
		//test.stopTest();

	}
}