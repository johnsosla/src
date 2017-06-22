/***********************************************************************************************************
PR          :  I-0852
Requester   :  Richard Schwien
Author      :  Steve MunLeeuw
Date        :  Nov 23, 2015
Purpose     :  The trigger does following-
               1. If the Survey Response Account has been merged it uses the OracleCustomerNumber to find the master account and updates to that account 
**********************************************************************************************************/
trigger CFM_SurveyResponseAccountMergeTrigger on CFM_Survey_Response__c (Before Insert) 
{

	//ToDo: Delete this, replaced by CFM_SurveyResponseAccountMergeTrigger.checkForMergedAccountsAndFix
	//our current process is not good with descructive changes

	
	/*
		Get a list of all account Id's, use the ALL ROWS to find the deleted accounts
		See if our trigger contains any surveys with deleted accounts
		Use the OracleCustomerNumber__c to find the master account the deleted account was merged into and associate the survey with that account.
	*/

	/*
	List<Id> allAccounts = new List<Id>();
    for(CFM_Survey_Response__c surveyResponse : Trigger.New)
	{
		try{
			allAccounts.add(surveyResponse.Account__c);
		}
		catch(DmlException ex){}//ignore invalid or empty accounts, they are not active
	}

	Map<Id, Account> activeAccounts = new Map<Id, Account>(
				[select Id
				from Account
				where 
					IsDeleted = false 
					AND Id IN :allAccounts
					ALL ROWS]);


	List<CFM_Survey_Response__c> surveysWithDeletedAccounts = new List<CFM_Survey_Response__c>();
    for(CFM_Survey_Response__c surveyResponse : Trigger.New)
	{
		if(activeAccounts.keySet().contains(surveyResponse.Account__c) == false){
			surveysWithDeletedAccounts.add(surveyResponse);
		}
	}


	Set<String> masterAccountCustNumbers = new Set<String>();
	for(CFM_Survey_Response__c survey: surveysWithDeletedAccounts){
		if(survey.OracleCustomerNumber__c != null){
			masterAccountCustNumbers.add(survey.OracleCustomerNumber__c);
		}
	}

	if(masterAccountCustNumbers.size() > 0){
		Map<Id, Account> masterAccounts =  new Map<Id, Account>(
					[select Id, OracleCustomerNumber__c
					from Account 
					where OracleCustomerNumber__c IN :masterAccountCustNumbers]);


		//I'm still learning the Apex collections, I want to search by OracleCustomerNumber__c
		for(CFM_Survey_Response__c survey: surveysWithDeletedAccounts){
			for(Id masterAccountId : masterAccounts.keySet()){
				if(survey.OracleCustomerNumber__c == masterAccounts.get(masterAccountId).OracleCustomerNumber__c){
					survey.Account__c = masterAccountId;
				}
			}
		}
	}
	*/
}