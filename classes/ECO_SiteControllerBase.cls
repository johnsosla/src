public with sharing virtual class ECO_SiteControllerBase extends ECO_PageControllerBase {
	
	public pse__Proj__c oProject {get;set;}

	//Used for component to controller communication
	//public ECO_SiteFinderComponentController myComponentController {get; set;}	

	/* To be implemented if required in extenstion. Used for Comonpent-->Controller communication when a Primary Site has been selected */
	public virtual void PrimarySelected(){
		return;
	}

	/* Used for passing the Controller to the Component for Commponent to Controller communication */
	public virtual ECO_SiteControllerBase getThis() {
    	return this;
  	}
}