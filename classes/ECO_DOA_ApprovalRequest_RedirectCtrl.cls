/** ------------------------------------------------------------------------------------------------------
* @Description Redirect page controller for DOA Approval Request
*
* @Author      NTT Data - Priya Parepalli
* @Date        2016
*-----------------------------------------------------------------------------------------------------*/
public without sharing class ECO_DOA_ApprovalRequest_RedirectCtrl {
  public DOAApprovalRequest__c oDOA {get;set;}
    
    /**
     * Contructor for Redirect Controller
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    2016
     *
     * @param   ApexPages.StandardController
     * @return  
     **/
	public ECO_DOA_ApprovalRequest_RedirectCtrl(ApexPages.StandardController stdController) {
	this.oDOA = (DOAApprovalRequest__c)stdController.getRecord();
	}

	/**
	 * Page Reference method to redirect user to DOA Page
	 *
	 * @Author  NTT Data - Priya Parepalli
	 * @Date    2016
	 *
	 * @param   
	 * @return  pagereference
	 **/
  	public pagereference redirectForm(){
        
        return new pagereference('/apex/ECO_DOA_ApprovalRequest_AddApprovers?id=' + oDOA.id);
        //return null;
    }
}