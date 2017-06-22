/*************************************************************************
*
* PURPOSE: Controller for GNG_CommercialAnalysis
*
* AUTHOR: Luke Farbotko
***************************************************************************/
public class GNG_CommercialAnalysisController {
    
	public boolean editMode{get;set;}
	public boolean saveMode{get;set;}
	private  Go_No_Go_Conversation__c gng;
	
	private ApexPages.StandardController myController ;
    
	  public GNG_CommercialAnalysisController(ApexPages.StandardController controller) {
	  
	      	this.myController = controller;
	     	
	        gng = (Go_No_Go_Conversation__c)controller.getRecord();
	      	string param;
	      	try{
	      		 param = ApexPages.currentPage().getParameters().get('EditMode');
	        }
	      catch(Exception ex){}
	        if (param == '1')
	        {
	            saveMode = true;
	            editMode = false;  
	        }
	      	else
	        {
	            saveMode = false;
	            editMode = true;       
	        }
	  }
	
	  public void EditIt()
	  {
	        saveMode = true;
	        editMode = false;
	  		
	  }
	
	 
	  public Pagereference SaveIt()
	  {
	      try{
	            update this.gng;
	           
	            saveMode = false;
	            editMode = true;
	            
	        }
			catch(DmlException ex){
	    		ApexPages.addMessages(ex);
	            return null;
	   		}
	  		return this.myController.Save();
	  }
}