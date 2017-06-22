/*******************************************************************
  Name        :   ContractReviewSharing
  Requester   :   CRS Requirments
  Author      :   AECOM - Luke Farbotko
  Version     :   1.0 
  Purpose     :   share contract reviews for individual or group
  				  through automated manual sharing rules.
  				  Access level sharing Options
  				  	- Read 
  				  	- Edit
  				  	- All
  Date        :   12 Feb, 2015 

********************************************************************/
public class ContractReviewSharing {
	public static boolean manualShareRead(Id recordId, Id userOrGroupId, String accessLevel){
	      // Create new sharing object for the custom object Job.
	      Contract_Review__Share jobShr  = new Contract_Review__Share();
	   
	      // Set the ID of record being shared.
	      jobShr.ParentId = recordId;
	        
	      jobShr.UserOrGroupId = userOrGroupId;
	        
	      // Set the access level.
	      jobShr.AccessLevel = accessLevel;
	        
	      // Set rowCause to 'manual' for manual sharing.
	      // This line can be omitted as 'manual' is the default value for sharing objects.
	      jobShr.RowCause = Schema.Contract_Review__Share.RowCause.Manual;
	        
	      // Insert the sharing record and capture the save result. 
	      // The false parameter allows for partial processing if multiple records passed 
	      // into the operation.
	      Database.SaveResult sr = Database.insert(jobShr,false);
	
	      // Process the save results.
	      if(sr.isSuccess()){
	         // Indicates success
	         return true;
	      }
	      else {
	         // Get first save result error.
	         Database.Error err = sr.getErrors()[0];
	         
	         // Check if the error is related to trival access level.
	         // Access levels equal or more permissive than the object's default 
	         // access level are not allowed. 
	         // These sharing records are not required and thus an insert exception is acceptable. 
	         if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
	                  err.getMessage().contains('AccessLevel')){
	            // Indicates success.
	            return true;
	         }
	         else{
	            // Indicates failure.
	            return false;
	         }
	       }
	   }

}