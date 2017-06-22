public with sharing class ECO_CreateRiskController {
	public ApexPages.StandardController stdController {get; set;}
    public Id projectId {get;set;}
    public Id riskId {get;set;}
    public Risk__c oRisk {get; set;}
    public pse__Proj__c theProject {get; set;}
    public String preRating {get;set;}
    public String postRating {get;set;}
    public Integer preScore {get;set;}
    public Integer postScore {get;set;}
    public Boolean bPreRatingChanged {get;set;}
    public Boolean bPostRatingChanged {get;set;}
    public Boolean bPreScoreChanged {get;set;}
    public Boolean bPostScoreChanged {get;set;}
    public Boolean isNewRisk {get;set;}
    public ECO_CreateRiskController(ApexPages.StandardController stdController) {
		oRisk = (Risk__c)stdcontroller.getRecord();
        bPreRatingChanged = false;
        bPostRatingChanged = false;
        bPreScoreChanged = false;
        bPostScoreChanged = false;
    }
    
    public void init(){
        System.debug('oRisk::::::'+oRisk);
        projectId = ApexPages.currentPage().getParameters().get('projectId');
        riskId = ApexPages.currentPage().getParameters().get('Id');
        System.debug('projectId::::'+projectId);
        
        if(oRisk.Id == null && projectId != null){
            theProject = [Select Id From pse__Proj__c Where Id = :projectId];
            oRisk.Project__c = theProject.Id;
            oRisk.CurrentStatus__c = 'Potential';
            oRisk.Name=Label.New_Risk;
            isNewRisk = true;
        }
        else if(riskId != null || riskId != ''){
            isNewRisk = false;
            System.debug('oRisk:::'+oRisk+'   projectId::::'+projectId);
            Map<String, Schema.SObjectField> objfieldMap = Risk__c.sObjectType.getDescribe().fields.getMap();
     
            String strfieldName = '';
            
            for(Schema.SObjectField Field : objfieldMap.Values()){
                 Schema.DescribeFieldResult fieldResult = Field.getDescribe();
                 strfieldName += fieldResult.getName() + ',';
            }
            strfieldName = strfieldName.substring(0, strfieldName.length()-1);
            List<Risk__c> lrisks = Database.query('Select ' + strfieldName + ' From Risk__c Where Id = :riskId');
            if(lrisks.size() > 0)
                oRisk = lrisks[0];
            //oRisk = [Select Id, Name, Project__c From Risk__c Where Id = :riskId];
        }
        else{
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You have reached this page incorrectly.' );
	        ApexPages.addMessage(oMsg);
            return;
        }
        try{
            if(oRisk.Id == null)
            	insert oRisk;
            Map<String, Schema.SObjectField> objfieldMap = Risk__c.sObjectType.getDescribe().fields.getMap();
     
            String strfieldName = '';
            
            for(Schema.SObjectField Field : objfieldMap.Values()){
                 Schema.DescribeFieldResult fieldResult = Field.getDescribe();
                 strfieldName += fieldResult.getName() + ',';
            }
            strfieldName = strfieldName.substring(0, strfieldName.length()-1);
            List<Risk__c> lrisks = Database.query('Select ' + strfieldName + ' From Risk__c Where Id = :riskId');
            if(lrisks.size() > 0)
                oRisk = lrisks[0];
            System.debug('oRisk id:::'+oRisk.Id);
        }catch(Exception e){
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An error occured while saving record:'+e );
            ApexPages.addMessage(oMsg);
            
        }
    }
    
    public PageReference cancelRisk(){
        try{
            delete oRisk;
            pageReference page = new pageReference('/apex/ECO_RiskRegisterList?id='+projectId);
            page.setRedirect(true);
            return page;
        }catch(Exception e){
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An error occured while cancelling record:'+e );
            ApexPages.addMessage(oMsg);
            return null;
        }
        
    }
    
    public PageReference saveRisk(){
        
        try{
            if(bPreRatingChanged)
                oRisk.Premitigationrating__c = preRating;
            if(bPostRatingChanged)
                oRisk.Postmitigationrating__c = postRating;
            if(bPreScoreChanged)
                oRisk.PreMitigationScore__c = preScore;
            if(bPostScoreChanged)
                oRisk.PostMitigationScore__c = postScore;
            update oRisk;
            PageReference pageRef = new PageReference('/apex/ECO_CreateRisk?Id='+oRisk.Id); 
            pageref.setRedirect(true);
			return pageRef;
            //return null;
        }catch(Exception e){
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An error occured while saving record:'+e );
	        ApexPages.addMessage(oMsg);
            return null;
        }
    }
    public PageReference saveAndNew(){
        try{
            if(bPreRatingChanged)
                oRisk.Premitigationrating__c = preRating;
            if(bPostRatingChanged)
                oRisk.Postmitigationrating__c = postRating;
            if(bPreScoreChanged)
                oRisk.PreMitigationScore__c = preScore;
            if(bPostScoreChanged)
                oRisk.PostMitigationScore__c = postScore;
            update oRisk;
            theProject = [Select Id From pse__Proj__c Where Id = :oRisk.Project__c];
            System.debug('projectId='+projectId);
            PageReference pageRef = new PageReference('/apex/ECO_CreateRisk?projectId='+theProject.Id); 
            pageref.setRedirect(true);
            return pageRef;
        }catch(Exception e){
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An error occured while saving record:'+e );
	        ApexPages.addMessage(oMsg);
            return null;
        }
        
    }
    public PageReference returnToRiskRegister(){
        PageReference pageRef = new PageReference('/apex/ECO_RiskRegisterList?id='+oRisk.Project__c); 
        pageref.setRedirect(true);
		return pageRef;
    }

}