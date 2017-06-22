/*******************************************************************
  Name        :   User_UpdatePermissionSets Previously User_ContractReviewPermissionSet
  Requester   :   CRS Requirments
  Author      :   AECOM - Luke Farbotko
  Version     :   1.0 
  Purpose     :   1. Add 'Contract_Reviewer' permision set if 'legal' flag is 
  					checked on the user
  				  2. remove 'Contract_Reviewer' permision set if 'legal' flag is 
  					unchecked on the user
  					
  				  3. Give all users access via 	'Contract Reviewer General User (SF)' 
  				     or 'Contract Reviewer General User' Permission set

  				  4. Give all users 'ECO Portal access' Permission set
  				     
  Date        :   17 Feb, 2015 

  Update : 5 May 2015 - add eco permissions sets.
  Update : 31 Jul 2015 - eco permissions and other future permissions sets to be maintained fro,
						 a custom settings list.CRS to be excluded due to being bound to 
						 licence types and additional logic.
********************************************************************/
trigger User_UpdatePermissionSets on User (after insert, after update) {
	if(StaticHelper.runME==true ){
		// prevent test limmits
		if (Test.isRunningTest())
		{
			StaticHelper.runME = !StaticHelper.excludeIt;
		}
		
		UserPermissionAssignmentUpdateHelper.processPermissionSets(trigger.new);
	}
}