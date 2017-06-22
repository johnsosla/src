@isTest
private class ECO_AddInductedProjTeamMemberTest
{
	@isTest
	static void testMethods()
	{
		test.starttest();
		ECO_Utils_Testing.createTestDataForOrgFinder();
		test.stoptest();

		pse__Proj__c testProject = [select id from pse__Proj__c limit 1];
		list<contact> lstCon = [select id from contact limit 2];


		list<ProjectTeamMember__c> lstPTM = new list<ProjectTeamMember__c>();
		contact con1 = lstCon[0];
		ProjectRole__c projectRole1 = [select id from ProjectRole__c where Name = 'Project Manager'];

		ProjectTeamMember__c ptm1 = new ProjectTeamMember__c(Contact__c = con1.id, Project__c = testProject.id, ProjectRole__c = projectRole1.id, StartDate__c = Date.today());
		lstPTM.add(ptm1);


		contact con = lstCon[1];
		ProjectRole__c projectRole = [select id from ProjectRole__c where Name = 'Resilience Director'];

		ProjectTeamMember__c ptm = new ProjectTeamMember__c(Contact__c = con.id, Project__c = testProject.id, ProjectRole__c = projectRole.id, StartDate__c = Date.today());
		lstPTM.add(ptm);

		insert lstPTM;		

		induction__c ind = new induction__c(name='test', Project__c = testProject.id);
		insert ind;


		ApexPages.currentPage().getParameters().put('projectId', testProject.id);
		ApexPages.currentPage().getParameters().put('inductionId', ind.id);
		//ApexPages.currentPage().getParameters().put('Id', ptm.id);


		ApexPages.StandardController sc = new ApexPages.StandardController(new InductedProjectTeamMembers__c());
		ECO_AddInductedProjTeamMemberCtrl ctr = new ECO_AddInductedProjTeamMemberCtrl(sc);

		ctr.init();		
		ctr.saveInductionTeamMember();
		ctr.saveAndNew();
		ctr.returnToInduction();

	}
}