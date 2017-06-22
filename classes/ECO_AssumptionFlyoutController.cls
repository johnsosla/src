public with sharing class ECO_AssumptionFlyoutController {
	public Assumption__c oAssumption {
        get{
            if(bInitialDefault){
                oAssumption.PlanElement__c = sPlanElement;
                sFilterCriteria = sPlanElement;

                bInitialDefault = false;
            }

            return oAssumption;
        }

        set;}
    private boolean bInitialDefault;

    public string sFilterCriteria { get; set;}

    public string sPlanElement {get; set;}
    public list<SelectOption> lPlanElements {get{
        List<SelectOption> optionlist = new List<SelectOption>();

        //optionlist.add(new SelectOption('', 'No Filter'));
        optionlist.addAll(ECO_Utils_Meta.getPickListValues(new Risk__c(), 'PlanElement__c'));

        return optionlist;
    }

    set;}

	public id sProjectId {get;set;}

    public list<Assumption__c> lAssumptions {
        get{
            return ECO_Service_Assumptions.getAssumtionsForProject(sProjectId, sFilterCriteria);
        }

        set;}

	public ECO_AssumptionFlyoutController() {
        bInitialDefault = true;
		oAssumption = new Assumption__c();
	}

	public pagereference saveAssumption(){
        try {
        	oAssumption.Project__c = sProjectId;
            insert oAssumption;
        } catch (Exception e) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attmpting to save risk: ' + e);
            ApexPages.addMessage(oMsg);
            return null;
        }   	

        oAssumption = new Assumption__c();
        oAssumption.PlanElement__c = sPlanElement;

        return null;
	}

    public PageReference viewRegister(){
        return new PageReference('/apex/ECO_AssumptionRegister?projectId=' + sProjectId);
    }

    public PageReference refresh(){

        return null;
    }
}