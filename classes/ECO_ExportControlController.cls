public with sharing class ECO_ExportControlController {

    public ExportControl__c oExportControl {get; set;}
    public ApexPages.StandardController oStandardController {get; set;}
    public list<SelectOption> lAnswerValues {get; set;}
    public Id sQuestionnaireSetId {get; set;}
    public Id sProjectId {get; set;}
    public Id endClientAccountId {get;set;}
    public Id billClientAccountId {get;set;}
    public list<Project_Site__c> lProjectSites {get; set;}
    public Project_Site__c oUltimateEndUser {get; set;}
    public Project_Site__c oClient {get; set;}
    //public list<SelectOption> lCities {get; set;}
    public boolean bShowUltimateEndUserAddress {get; set;}
    public boolean bShowClientAddress {get; set;}
    public boolean bReadOnly {get; set;}
    public Account endClientAccount {get;set;}
    public Account billingClientAccount {get;set;}
    
    public ECO_ExportControlController(ApexPages.StandardController oStandardController)
    {
        list<string> lFields = new list<string>();
        lFields.add('QuestionnaireSet__c');
        lFields.add('Project__c');
        lFields.add('SubmitforReview__c');
        lFields.add('Project__r.ProjectDescription__c');
        lFields.add('ExistingJointVentureInput__c');
        lFields.add('End_Client_Website__c');
        lFields.add('Billing_Client_Website__c');
        lFields.add('SubmittedDate__c');
        //oStandardController.addFields(lFields);
        //addFileds method has issue while running test, so bypassing this
        if(!Test.isRunningTest()) {
            oStandardController.addFields(lFields);
        }
        
        this.oExportControl = (ExportControl__c)oStandardController.getRecord();
        this.oStandardController = oStandardController;
        this.sQuestionnaireSetId = oExportControl.QuestionnaireSet__c;
        this.sProjectId = oExportControl.Project__c;
        bShowUltimateEndUserAddress = false;
        bShowClientAddress = false;
        //3417: If Project has been submitted, lockdown the Export Control
        bReadOnly = (this.oExportControl.Project__r.pse__Stage__c == 'Execution' || this.oExportControl.Project__r.pse__Stage__c == 'Closure');
        
        
        lAnswerValues = new list<SelectOption>{
            new SelectOption('Yes', 'Yes'),
            new SelectOption('No', 'No')
        };
        
        if(sQuestionnaireSetId == null)
        {
            ApexPages.Message oPageMessage = new ApexPages.Message(ApexPages.Severity.WARNING,'You have reached this page improperly, please access it from the Project screen.');
            ApexPages.addMessage(oPageMessage);
            return;
        }
        
        if(sProjectId != null)
        {
            System.debug('oExportControl.Project__r.ProjectDescription__c:   '+oExportControl.Project__r.ProjectDescription__c);
            lProjectSites = new list<Project_Site__c>([Select Is_Primary_End__c, 
                                                            Is_Billing__c, 
                                                            AccountID__c ,
                                                            Site__r.Account__r.Id,
                                                            Site__r.Account__r.Website, 
                                                            Site__r.Account__r.Name, 
                                                            Site__r.Account__r.BillingStreet, 
                                                            Site__r.Account__r.BillingState, 
                                                            Site__r.Account__r.BillingPostalCode, 
                                                            Site__r.Account__r.BillingCountry, 
                                                            Site__r.Account__r.BillingCity 
                                                        From Project_Site__c
                                                        Where Project__c = :sProjectId
                                                        And (Is_Primary_End__c = true
                                                            Or Is_Billing__c = true)
                                                        Order By Account_Name__c]);
            //check Primary End Client in project
            for(Project_Site__c p : lProjectSites)
            {
                if(p.Is_Primary_End__c)
                {
                    oUltimateEndUser = p;
                    endClientAccountId = p.AccountID__c;
                    if(oExportControl.End_Client_Website__c == '' || oExportControl.End_Client_Website__c == null)
                        oExportControl.End_Client_Website__c = oUltimateEndUser.Site__r.Account__r.Website;
                    bShowUltimateEndUserAddress = true;
                    break;
                }
            }
            //check primary billing in project
            for(Project_Site__c p : lProjectSites)
            {
                //if(p.Is_Billing__c && p.Site__r.Account__r.Id != oUltimateEndUser.Site__r.Account__r.Id){}
                if(p.Is_Billing__c ){
                    oClient = p;
                    billClientAccountId = p.AccountID__c;
                    if(oExportControl.Billing_Client_Website__c == '' || oExportControl.Billing_Client_Website__c == null)
                        oExportControl.Billing_Client_Website__c = oClient.Site__r.Account__r.Website;
                    bShowClientAddress = true;
                    break;
                }
            }
            
            if(endClientAccountId != null || endClientAccountId != '')
                endClientAccount = [Select Id, Name, BillingStreet, BillingCity, BillingCountry, Website, BillingState, BillingPostalCode From Account Where Id = :endClientAccountId];
            if(billClientAccountId != null || billClientAccountId != '')
                billingClientAccount = [Select Id, Name, BillingStreet, BillingCity, BillingCountry, Website, BillingState, BillingPostalCode From Account Where Id = :billClientAccountId];
            /*lCities = new list<SelectOption>();
            lCities.add(new SelectOption('', 'Please Choose'));


            for(ProjectCity__c c : [Select Id, CityName__c From ProjectCity__c Where Project__c = :sProjectId Order By CityName__c])
            {
                lCities.add(new SelectOption(c.Id, c.CityName__c));
            }*/
        }
    }
    
    public PageReference SaveRecord()
    {
        oStandardController.save();
        return null;
    }
    
    public PageReference ReturnToSummary()
    {
        PageReference oPageReference = Page.ECO_RMSummary;

        oPageReference.getParameters().put('Id', oExportControl.QuestionnaireSet__c);
        oPageReference.setRedirect(true);

        return oPageReference;
    }
    
    public PageReference SubmitForReview(){
        try{
            oExportControl.SubmitforReview__c = true;
            //oExportControl.SubmittedDate__c = date.today();
            update oExportControl;
            return null;
        }catch(Exception e){
            System.debug('System exception ' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        }
        
    }
}