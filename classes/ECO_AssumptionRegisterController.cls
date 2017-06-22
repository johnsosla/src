public with sharing virtual class ECO_AssumptionRegisterController extends ECO_PageControllerBase  {
	public pse__Proj__c oProject			{ get; set; }
	public list<Assumption__c> lAssumptions { get; set; }
	public string sSelectedAssumptionId		{ get; set; }

	public ECO_AssumptionRegisterController(ApexPages.StandardController oStandardController) {
		Id sProjectId = ApexPages.currentPage().getParameters().get('projectId');
        
        Id assumptionId = ApexPages.currentPage().getParameters().get('Id');
        System.debug('assumptionId: ' + assumptionId);
        if(assumptionId != Null) {
            Assumption__c assumption = [SELECT Id, Project__c FROM Assumption__c WHERE Id =: assumptionId];
            sProjectId = assumption.Project__c;
        }
        

		if (ECO_Utils_String.NullCheck(sProjectId) == '') {
			ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.WARNING, 'You have reached this page improperly, please access it from the Project screen.');
            ApexPages.addMessage(oPageMessage);
            return;
		}

		oProject = ECO_Service_Projects.getProjectById(sProjectId);
		lAssumptions = ECO_Service_Assumptions.getAssumtionsForProject(sProjectId);

		sSelectedAssumptionId = '';
	}

	public PageReference addAssumption() {
		System.debug('inside addassumption');
		Assumption__c oNewAssumption = new Assumption__c();
		oNewAssumption.Project__c = oProject.Id;

		lAssumptions.add(oNewAssumption);

		return null;
	}

	public PageReference backToProject() {
		return new PageReference('/' + oProject.Id);
	}

	public PageReference save() {
		try { 
			upsert lAssumptions;
		} catch (Exception e) {
			ApexPages.addMessages(e);
		}

		lAssumptions = ECO_Service_Assumptions.getAssumtionsForProject(oProject.Id);
		
		PageReference pgRef = new PageReference('/apex/ECO_AssumptionRegister?projectId=' + oProject.Id);
		pgRef.setRedirect(true);
		return pgRef;
		//return null;
	}

	public void removeAssumption(){
		Savepoint oSavePoint = Database.setSavepoint();

		try { 
			upsert lAssumptions;
		} catch (Exception e) {
			ApexPages.addMessages(e);
			Database.rollback(oSavePoint);

			return;
		}

		Assumption__c oAssumption = new Assumption__c(Id = sSelectedAssumptionId);

		try { 
			delete oAssumption;
		} catch (Exception e) {
			ApexPages.addMessages(e);
			Database.rollback(oSavePoint);

			return;
		}

		lAssumptions = ECO_Service_Assumptions.getAssumtionsForProject(oProject.Id);

		return;
	}
}