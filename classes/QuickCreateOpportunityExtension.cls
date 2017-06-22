/*******************************************************************
  Name        :   QuickCreateOpportunityExtension
  Author      :   Deshraj(Appirio Off)
  Version     :   1.0 
  Purpose     :   Extension for QuickCreateOpportunity Page, This page act as 'Quick Create' page so that user does 
				  not need to enter all the numerous fields if he/she has to enter through the standard new oppty page.
  Date        :   03 Aug, 2010 
********************************************************************/
public class QuickCreateOpportunityExtension {
 	//private String save_new_url = null;
	public String recordTypeStr {get;set;}
	public Opportunity pOpportunity {get;set;}
	public String oppId {get;set;}
	
	//-----------------------------------------------------------------//
	//Constructor
	//-----------------------------------------------------------------//
	public QuickCreateOpportunityExtension(ApexPages.StandardController controller) {
		pOpportunity = (Opportunity) controller.getRecord();
		if(Apexpages.currentPage().getParameters().get('oppid') != null) {
			oppId = Apexpages.currentPage().getParameters().get('oppid');
			List<Opportunity> pOpportunityList=[Select id, AccountId, Account.Name, Name from Opportunity where id=:oppId];
			if(pOpportunityList != null && pOpportunityList.size() > 0) {
				pOpportunity.AccountId = pOpportunityList[0].AccountId;
				pOpportunity.Master_Contract_lookup__c = pOpportunityList[0].Id;
			}
		}
		pOpportunity.Probability = 0;
		if(Apexpages.currentPage().getParameters().get('RecordType') != null) {
			String recordTypeIdStr = Apexpages.currentPage().getParameters().get('RecordType');
			List<RecordType> oppRecordType = [Select Id, Name from RecordType Where sObjectType = 'Opportunity' AND Id =: recordTypeIdStr];
			if(oppRecordType.size() > 0) {
				pOpportunity.RecordTypeID = oppRecordType[0].Id;
				recordTypeStr = oppRecordType[0].Name;
			}
		}	
		
		/*
		if(Apexpages.currentPage().getParameters().get('save_new_url') != null) {
			save_new_url = Apexpages.currentPage().getParameters().get('save_new_url');
		}
		*/
		System.debug('Opportunity ::::::: ' + pOpportunity);
	}
	
	public PageReference saveAndNew(){
		try{
			insert pOpportunity;
		}catch(DmlException ex) {
	    ApexPages.addMessages(ex);          
	    return null;
		}	
		String preFix = Opportunity.SObjectType.getDescribe().getKeyPrefix();
		//return new Pagereference('/' + preFix + '/e');
		return new Pagereference('/setup/ui/recordtypeselect.jsp?ent=Opportunity&retURL=/' +  preFix + '/o&save_new_url=/' + preFix + '/e?retURL=%2F' + preFix + '%2Fo');
	}
	
}