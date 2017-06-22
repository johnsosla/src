public with sharing class ECO_RiskFlyoutController {
	public id sProjectId            { get; set;}
    public string sPlanElement      { get; set;}
    public string sFilterCriteria   { get; set;}
   
    public Risk__c oRisk {
        get{
            if(bInitialDefault){
                oRisk.PlanElement__c = sPlanElement;
                sFilterCriteria = sPlanElement;

                bInitialDefault = false;
            }

            return oRisk;
        }

        set;}
    private boolean bInitialDefault;

    public list<SelectOption> lPlanElements {get{
        List<SelectOption> optionlist = new List<SelectOption>();

        optionlist.add(new SelectOption('', 'No Filter'));
        optionlist.addAll(ECO_Utils_Meta.getPickListValues(new Risk__c(), 'PlanElement__c'));

        return optionlist;
    }

    set;}

    public list<Risk__c> lRisks {
        get{
            string sSOQL = 'SELECT ';
            if(sFilterCriteria != 'DOA'){
                for (Schema.FieldSetMember fsmField: SObjectType.Risk__c.FieldSets.RiskFlyoutDisplayFields.getFields()) {
                    sSOQL += fsmField.getFieldPath() + ', ';
                }

                sSOQL += ' Id, PlanElement__c FROM Risk__c WHERE Project__c =\'' + sProjectId + '\'';
                
                if(ECO_Utils_String.NullCheck(sFilterCriteria) != '' && sFilterCriteria != 'DOA'){
                    sSOQL += ' and PlanElement__c = \'' + sFilterCriteria + '\'';
                }

                sSOQL += ' ORDER BY PlanElement__c';

                try{
                    return (list<Risk__c>)Database.query(sSOQL);
                } catch( Exception e){
                    ECO_Service_ErrorLog.formatPageError(e, 'Error while searching for Risk: ' + e.getMessage());
                }

                return null;
            }   
            else{
                return null;
            }
        }

        set;
    }

    public List<DOARegister__c> lDOARegisters {
        get{
            if(sFilterCriteria == 'DOA'){
                String sSOQL = 'SELECT ';
                for (Schema.FieldSetMember fsmField: SObjectType.DOARegister__c.FieldSets.RiskFlyoutDisplayFields.getFields()) {
                    sSOQL += fsmField.getFieldPath() + ', ';
                }

                sSOQL += 'Id ';

                sSOQL += ' FROM DOARegister__c WHERE Project__c =\'' + sProjectId + '\'';
                return(list<DOARegister__c>) Database.query(sSOQL);
            }
            else{
                return null;
            }
        } 
        set;
    }

	public ECO_RiskFlyoutController() {
		oRisk = new Risk__c();
        bInitialDefault = true;
	}

	public PageReference saveRisk(){
        try {
            oRisk.Project__c = sProjectId;
            insert oRisk;
        } catch (Exception e) {
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attmpting to save risk: ' + e);
            ApexPages.addMessage(oMsg);
            return null;
        }       

        oRisk = new Risk__c();
        return null;
	}

    public PageReference refresh(){

        return null;
    }

    public PageReference viewRegister(){
        return new PageReference('/apex/ECO_RiskRegisterList?Id=' + sProjectId);
    }
}