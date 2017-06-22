public class ECO_MSAProjectSnapshotController {
	
	public ProjectSnapshot__c projectSnapshot {get; set;}
	public list<Agreement__c> relatedAgreements {get; set;}
	private String msaId {get; set;}
	
	public ECO_MSAProjectSnapshotController()
	{
		
	}

	public void init()
	{
		msaId = Apexpages.currentPage().getParameters().get('MSAId');
		
		relatedAgreements = [select Id, Name, Project__r.Id, Project__r.pse__Project_Status__c, Project__r.OracleProjectnumber__c, Amount__c,
            						Project__r.pse__Billing_Eligible_Last_Updated__c, Project__r.EstimatedContractValue__c, 
            						Project__r.pse__Project_Manager__c, Project__r.Task_number__c, Project__r.ProjectNumber__c, 
            						Project__r.Name, project__r.TotalApprovedCost__c, project__r.CostComplete__c, project__r.GoProbability__c, project__r.GetProbability__c
            						from Agreement__c where MSAReference__c = :msaId];

		list<Id> projectIds = new list<Id>();
		for(Agreement__c agreement:relatedAgreements)
			projectIds.add(agreement.Project__c);
		
		ECO_Service_ProjectSnapshots snapshotService = new ECO_Service_ProjectSnapshots(projectIds);
		projectSnapshot =  snapshotService.getProjectSnapshot(Datetime.Now());	
        if(projectSnapshot == null)
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error generating an MSA Snapshot');
            ApexPages.addMessage(msg);	
        }
	}	
	
	public PageReference ReturnToMSA()
    {
    	PageReference pageRef = new PageReference('/' + msaId);
    	return pageRef;
    }
	
 	public class FutureSpendOrg
    {
    	public list<String> orgFutureSpendStrings {get; set;} 
    }
	
	public list<FutureSpendOrg> getFutureSpendByOrg()
    {
    	list<String> futureSpendOrgs = new list<String>();
    	list<FutureSpendOrg> primaryFutureSpends = new list<FutureSpendOrg>();
    	FutureSpendOrg primaryFutureSpend;
    	
    	if(projectSnapshot.PrimaryFutureSpend__c != null && projectSnapshot.PrimaryFutureSpend__c != '')         
            futureSpendOrgs = projectSnapshot.PrimaryFutureSpend__c.split(';;');
            
        for(String futureSpendOrg:futureSpendOrgs)
        {
        	primaryFutureSpend = new FutureSpendOrg();
        	primaryFutureSpend.orgFutureSpendStrings = futureSpendOrg.split('::');	
        	primaryFutureSpends.add(primaryFutureSpend);
        }
    	
    	return primaryFutureSpends;
    }

}