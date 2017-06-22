/***
Author: NTT Centerstance
Purpose: To provide extended controller capabilities for the city and country risk finder page
1.0 - Tim C - 02/06/2015 - Created
***/
public with sharing class ECO_CityCountryFinderController extends ECO_PageControllerBase {

	/*public pse__Proj__c oProject {get;set;}

	public list<Project_Site__c> lstProjectSites {get;set;}
	public list<ProjectCity__c> lstProjectCities {get;set;}
	public list<ProjectCountry_Risk__c> lstProjectCountryRisks {get;set;}

	public id idCityID {get;set;}
	public id idCountryRiskID {get;set;}

	public string strSearchResults {get;set;}
	public string strNoRecords {get;set;}


	public class EcoControllerException extends Exception {}

	// Re-Usable Method for Querying Project Country Risk 
	private void UpdateProjectCountryRisks(){
		lstProjectCountryRisks = [SELECT ID, NAME, Project__c, CountryRisk__c, Type__c, Safety_Rating__c FROM ProjectCountry_Risk__c  WHERE Project__c =: oProject.id];
	} 

	// Re-Usable Method for Querying Project Cities 
	private void UpdateProjectCities(){
		lstProjectCities = [SELECT ID, NAME, Project__c, City__c, ClassCategory__c, Type__c FROM ProjectCity__c WHERE Project__c =: oProject.id];
	}*/


	// Constructor 
	public ECO_CityCountryFinderController (ApexPages.StandardController oStandardController) {

		/*this.oProject = (pse__Proj__c)oStandardController.getRecord();

		// retrieve all junction objects
		UpdateProjectCities();
		UpdateProjectCountryRisks();*/
	}


	/*public PageReference SelectPrimaryCountryRisk(){
		Savepoint oSavePoint = Database.setSavepoint();

		//Check if primary already exists
		list<ProjectCountry_Risk__c> lstCountryRiskToMakeSecondary = new list<ProjectCountry_Risk__c>([SELECT Id
															FROM ProjectCountry_Risk__c
															WHERE Project__c = :oProject.Id and Type__c = 'Primary']);

		if (lstCountryRiskToMakeSecondary.size() > 0) {
			for (ProjectCountry_Risk__c oProjectCountryRisk : lstCountryRiskToMakeSecondary) {
				oProjectCountryRisk.Type__c = 'Secondary';
			}

			try{
				update lstCountryRiskToMakeSecondary;
			}catch(EcoControllerException oException){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
				Database.rollback(oSavePoint);

				return null;
			}
		}

		//Check if entry already exists
		list<ProjectCountry_Risk__c> lstCountryRiskToMakePrimary = new list<ProjectCountry_Risk__c>([SELECT Id
																	, Type__c
															FROM ProjectCountry_Risk__c
															WHERE Project__c = :oProject.Id and CountryRisk__c=: idCountryRiskID]);

		if (lstCountryRiskToMakePrimary.size() > 0) {
			for (ProjectCountry_Risk__c oProjectCountryRisk : lstCountryRiskToMakePrimary) {
				oProjectCountryRisk.Type__c = 'Primary';
			}

			try{
				update lstCountryRiskToMakePrimary;
			}catch(EcoControllerException oException){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
				Database.rollback(oSavePoint);

				return null;
			}
		}else{
			ProjectCountry_Risk__c oProjectCityToInsert = new ProjectCountry_Risk__c(Project__c = oProject.Id, CountryRisk__c =idCountryRiskID, Type__c = 'Primary');

			try{
				insert oProjectCityToInsert;
			}catch(EcoControllerException oException){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
				Database.rollback(oSavePoint);

				return null;
			}
		}

		oProject.PrimaryCountry__c = idCountryRiskID;

		try{
			update oProject;
		}catch(EcoControllerException oException){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
			Database.rollback(oSavePoint);

			return null;
		}

		UpdateProjectCountryRisks();
		return null;
	}


	public PageReference SelectSecondaryCountryRisk(){
		Savepoint oSavePoint = Database.setSavepoint();

		//Check if entry already exists
		list<ProjectCountry_Risk__c> lstCountryRiskToMakeSecondary = new list<ProjectCountry_Risk__c>([SELECT Id
															FROM ProjectCountry_Risk__c
															WHERE Project__c = :oProject.Id and CountryRisk__c = :idCountryRiskID]);

		if (lstCountryRiskToMakeSecondary.size() > 0) {
			for(ProjectCountry_Risk__c oProjectCountyRisk : lstCountryRiskToMakeSecondary){
				oProjectCountyRisk.Type__c = 'Secondary';
			}

			try{
				update lstCountryRiskToMakeSecondary;
			}catch(EcoControllerException oException){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
				Database.rollback(oSavePoint);

				return null;
			}
		}else{
			ProjectCountry_Risk__c oProjectCountyRiskToInsert = new ProjectCountry_Risk__c(Project__c = oProject.Id, CountryRisk__c = idCountryRiskID, Type__c = 'Secondary');

			try{
				insert oProjectCountyRiskToInsert;
			}catch(EcoControllerException oException){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
				Database.rollback(oSavePoint);

				return null;
			}
		}

		//Update project to reflect if organization is currently primary
		if(oProject.PrimaryCountry__c == idCountryRiskID){
			oProject.PrimaryCountry__c = null;

			try{
				update oProject;
			}catch(EcoControllerException oException){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
				Database.rollback(oSavePoint);

				return null;
			}
		}

		UpdateProjectCountryRisks();
		return null;
	}

	public PageReference RemoveEntryCountryRisk(){

		Savepoint oSavePoint = Database.setSavepoint();

		//Check if entry already exists
		list<ProjectCountry_Risk__c> lstCountryRiskToRemove = new list<ProjectCountry_Risk__c>([SELECT Id
															FROM ProjectCountry_Risk__c
															WHERE Project__c = :oProject.Id and CountryRisk__c = :idCountryRiskID]);

		//Update project to reflect if organization is currently primary
		if(oProject.PrimaryCountry__c == idCityID){
			oProject.PrimaryCountry__c = null;

			try{
				update oProject;
			}catch(EcoControllerException oException){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
				Database.rollback(oSavePoint);

				return null;
			}
		}

		try{
			delete lstCountryRiskToRemove;
		}catch(EcoControllerException oException){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
			Database.rollback(oSavePoint);
			return null;
		}

		UpdateProjectCountryRisks();
		return null;
	}




	public PageReference SelectPrimaryCity(){
		Savepoint oSavePoint = Database.setSavepoint();

		//Check if primary already exists
		list<ProjectCity__c> lstCitiesToMakeSecondary = new list<ProjectCity__c>([SELECT Id
															FROM ProjectCity__c
															WHERE Project__c = :oProject.Id and Type__c = 'Primary']);

		if(lstCitiesToMakeSecondary.size() > 0){
			for(ProjectCity__c oProjectCity : lstCitiesToMakeSecondary){
				oProjectCity.Type__c = 'Secondary';
			}

			try{
				update lstCitiesToMakeSecondary;
			}catch(EcoControllerException oException){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
				Database.rollback(oSavePoint);

				return null;
			}
		}

		//Check if entry already exists
		list<ProjectCity__c> lstCitiesToMakePrimary = new list<ProjectCity__c>([SELECT Id
																	, Type__c
															FROM ProjectCity__c
															WHERE Project__c = :oProject.Id and City__c=: idCityID]);

		if(lstCitiesToMakePrimary.size() > 0){
			for(ProjectCity__c oProjectCity : lstCitiesToMakePrimary){
				oProjectCity.Type__c = 'Primary';
			}

			try{
				update lstCitiesToMakePrimary;
			}catch(EcoControllerException oException){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
				Database.rollback(oSavePoint);

				return null;
			}
		}else{
			ProjectCity__c oProjectCityToInsert = new ProjectCity__c(Project__c = oProject.Id, City__c =idCityID, Type__c = 'Primary');

			try{
				insert oProjectCityToInsert;
			}catch(EcoControllerException oException){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
				Database.rollback(oSavePoint);

				return null;
			}
		}

		//Update project to reflect
		//pse__Proj__c oProjectToUpdate = new pse__Proj__c(Id = oProject.Id, PrimaryCity__c = idCityID);
		oProject.PrimaryCity__c = idCityID;

		try{
			update oProject;
		}catch(EcoControllerException oException){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
			Database.rollback(oSavePoint);

			return null;
		}

		UpdateProjectCities();
		return null;
	}

	public PageReference SelectSecondaryCity(){
		Savepoint oSavePoint = Database.setSavepoint();

		//Check if entry already exists
		list<ProjectCity__c> lstCitiesToMakeSecondary = new list<ProjectCity__c>([SELECT Id
															FROM ProjectCity__c
															WHERE Project__c = :oProject.Id and City__c = :idCityID]);

		if(lstCitiesToMakeSecondary.size() > 0){
			for(ProjectCity__c oProjectCity : lstCitiesToMakeSecondary){
				oProjectCity.Type__c = 'Secondary';
			}

			try{
				update lstCitiesToMakeSecondary;
			}catch(EcoControllerException oException){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
				Database.rollback(oSavePoint);

				return null;
			}
		}else{
			ProjectCity__c oProjectCityToInsert = new ProjectCity__c(Project__c = oProject.Id, City__c = idCityID, Type__c = 'Secondary');

			try{
				insert oProjectCityToInsert;
			}catch(EcoControllerException oException){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
				Database.rollback(oSavePoint);

				return null;
			}
		}

		//Update project to reflect if organization is currently primary
		if(oProject.PrimaryCity__c == idCityID){
			oProject.PrimaryCity__c = null;

			try{
				update oProject;
			}catch(EcoControllerException oException){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
				Database.rollback(oSavePoint);

				return null;
			}
		}

		UpdateProjectCities();
		return null;
	}

	public PageReference RemoveEntryCity(){

		Savepoint oSavePoint = Database.setSavepoint();

		//Check if entry already exists
		list<ProjectCity__c> lstCitiesToRemove = new list<ProjectCity__c>([SELECT Id
															FROM ProjectCity__c
															WHERE Project__c = :oProject.Id and City__c = :idCityID]);

		//Update project to reflect if organization is currently primary
		if(oProject.PrimaryCity__c == idCityID){
			oProject.PrimaryCity__c = null;

			try{
				update oProject;
			}catch(EcoControllerException oException){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
				Database.rollback(oSavePoint);

				return null;
			}
		}

		try{
			delete lstCitiesToRemove;
		}catch(EcoControllerException oException){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
			Database.rollback(oSavePoint);
			return null;
		}

		UpdateProjectCities();
		return null;
	}*/



}