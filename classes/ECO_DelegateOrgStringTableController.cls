public with sharing class ECO_DelegateOrgStringTableController {

	public string delID {get;set;}
	public list<OrganizationString__c> lstOrg {get;set;}
	public Delegate__c oDelegate {get; set;}

	public list<OrganizationString__c> getOrgs(){
		queryData();
		return lstOrg;
	}

	public Delegate__c getrelatedTo(){
		queryData();
		return oDelegate;
	}


	public void queryData(){
		system.debug(delID);
		if(delID != null && oDelegate == null){

			oDelegate = [select id 
								,Delegate__r.firstname
								,Delegate__r.lastname
								,Key_Member_Role__c 
								,Start_Date__c 
								,End_Date__c 
								,Notes__c 
								,Delegate_Business_Title__c 
								,Delegate_Job_Name__c 
								,Agreement_Amount_estimated__c  
								,Agreement_Amount_estimated_Bypass__c
								,Agreement_Amount_estimated_lt__c
								,Agreement_Amount_estimated_Bypass_lt__c 
								,Project_Revenue_Budget__c 
								,Project_Revenue_Budget_Bypass__c 
								,Project_Revenue_Budget_lt__c 
								,Project_Revenue_Budget_Bypass_lt__c 
								,Backlog_Value__c 
								,Backlog_Value_Bypass__c 
								,Backlog_Value_lt__c
								,Backlog_Value_Bypass_lt__c
								,Project_Net_Margin_Value__c 
								,Project_Net_Margin_Value_Bypass__c 
								,Project_Net_Margin_Value_lt__c 
								,Project_Net_Margin_Value_Bypass_lt__c 
								,Project_Net_Margin_of_NSR_Bypass_lt__c
								,Project_Net_Margin_age_of_NSR_Bypass__c
								,Project_Net_Margin_age_of_NSR__c 
								,Project_Net_Margin_age_of_NSR_lt__c 
								,age_Change_in_Forecast_Net_Margin__c 
								,age_Change_in_Forecast_Net_Margin_Bypass__c
								,age_Change_in_Forecast_Net_Margin_lt__c
								,age_Change_in_Forecast_Net_Margin_Byp_lt__c 
								,Value_change_in_Forecast_Net_Margin__c 
								,Value_change_in_Forecast_Net_Margin_Byps__c 
								,Value_change_in_Forecast_Net_Margin_lt__c 
								,Value_change_Forecast_Nt_Margn_Byps_lt__c 
								,Project_Review_Category_C_0__c 
								,Project_Review_Category_C_0_Bypass__c 
								,Project_Review_Category_C_1__c
								,Project_Review_Category_C_1_Bypass__c
								,Project_Review_Category_C_2__c 
								,Project_Review_Category_C_2_Bypass__c 
								,Project_Review_Category_C_3__c 
								,Project_Review_Category_C_3_Bypass__c 
								,Project_Review_Category_C_4__c 
								,Project_Review_Category_C_4_Bypass__c 
								,Allowed_Organizations__c 
								,Delegate_HR_Supervisor__c
								,Recordtype.name

								from Delegate__c where id =: delID];

			system.debug(oDelegate);

			if(oDelegate.Allowed_Organizations__c != null){
				List<String> orgStringIds = oDelegate.Allowed_Organizations__c.split(';');
				Set<String> organizationStringIds = new Set<String>(orgStringIds);

				Set<String> organizationStringFields = ECO_Utils_sObject.getFieldSetMembers('Email_Owning_Organization_Table', 'OrganizationString__c');
				
				if(organizationStringFields.size() > 0){
					String queryFields = '';

					//create the query field string 
					for(String organizationStringField : organizationStringFields){
						queryFields += organizationStringField + ', ';
					}

					//query string
					String query = 'Select Id, LocationName__c, ' + queryFields.removeEnd(', ') + ' From OrganizationString__c where Id IN : organizationStringIds';

					system.debug(query);
					lstOrg = Database.query(query);
					system.debug(lstOrg);
				}
			}

		}		
	}

	public ECO_DelegateOrgStringTableController() {
		lstOrg = new list<OrganizationString__c>();
		oDelegate = null;
	}


}