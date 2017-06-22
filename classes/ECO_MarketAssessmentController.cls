public with sharing class ECO_MarketAssessmentController {

	public MarketAssessment__c oMarketAssessment {get; set;}
	public ApexPages.StandardController oStandardController {get; set;}
	public list<SelectOption> lAnswerValuesBoolean {get; set;}
	
	public ECO_MarketAssessmentController(ApexPages.StandardController oStandardController)
	{
		list<string> lFields = new list<string>();
        lFields.add('QuestionnaireSet__c');

        if (!Test.isRunningTest()) {
          oStandardController.addFields(lFields);
        }
        
        lAnswerValuesBoolean = new list<SelectOption>{
            new SelectOption('True', 'Yes'),
            new SelectOption('False', 'No')
        };
        
        this.oMarketAssessment = (MarketAssessment__c)oStandardController.getRecord();
        this.oStandardController = oStandardController;
        
        if(oMarketAssessment.QuestionnaireSet__c == null)
        {
			ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.WARNING,'You have reached this page improperly, please access it from the Project screen.');
            ApexPages.addMessage(oPageMessage);
            return;
		}
        
		
	}
	public PageReference SaveRecord()
	{
    	oStandardController.save();
    	RefreshData();
    	return null;
    }
    
    public void RefreshData()
    {
    	
    }

    //public PageReference Cancel(){
    //    PageReference oPageReference = Page.ECO_RMASummary;

    //    oPageReference.getParameters().put('Id', oMarketAssessment.QuestionnaireSet__c);
    //    oPageReference.setRedirect(true);
        
    //    return oPageReference;
    //}

    public PageReference SaveNext()
    {
        oStandardController.save();
        //RefreshData();
        PageReference oPageReference = Page.ECO_RMASummary;

        oPageReference.getParameters().put('id', oMarketAssessment.QuestionnaireSet__c);
        oPageReference.setRedirect(true);
        
        return oPageReference;
    }
    
	public PageReference ReturnToSummary()
	{
    	PageReference oPageReference = Page.ECO_RMASummary;

    	oPageReference.getParameters().put('id', oMarketAssessment.QuestionnaireSet__c);
    	oPageReference.setRedirect(true);
		
    	return oPageReference;
    }
    public PageReference DefaultChildToNo(){
        if(oMarketAssessment.Potentialconflictofinterestissues__c == 'False'){
            if(oMarketAssessment.ExpertWitnessorLitigationSupport__c != 'False')
            	oMarketAssessment.ExpertWitnessorLitigationSupport__c = 'False';
            if(oMarketAssessment.JVinvolvement__c != 'False')
            	oMarketAssessment.JVinvolvement__c = 'False';
            if(oMarketAssessment.ProgramManagementServices__c != 'False')
            	oMarketAssessment.ProgramManagementServices__c = 'False';
            if(oMarketAssessment.RFPDevelopmentServices__c != 'False')
            	oMarketAssessment.RFPDevelopmentServices__c = 'False';
            if(oMarketAssessment.StaffAugmentationorembeddedworkforce__c != 'False')
            	oMarketAssessment.StaffAugmentationorembeddedworkforce__c = 'False';
			    
        }
        return null;
    }
}