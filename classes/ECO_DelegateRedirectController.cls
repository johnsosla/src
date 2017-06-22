/** ------------------------------------------------------------------------------------------------------
* @Description Redirect controller to ensure that user will be routed to standard pages when
*   a default delegate is encountered
*
* @Author      NTT Data - Tim Chiang
* @Date        2016
*-----------------------------------------------------------------------------------------------------*/
public with sharing class ECO_DelegateRedirectController {

	public Delegate__c extensionDelegate{get; set;}
	private ApexPages.StandardController controller;

	public ECO_DelegateRedirectController(ApexPages.StandardController standardController) {
		this.controller = standardController;
        this.extensionDelegate = (Delegate__c)standardController.getRecord();
	}

    /**
     * Redirects user to standard page if the recordtype is default
     *
     * @Author  Tim Chiang
     * @Date    Oct 2016
     *
     **/
    public PageReference redirectIfDefaultEdit(){

	    Schema.DescribeSObjectResult result = Delegate__c.SObjectType.getDescribe(); 
        string retURL = 'retURL=/' + result.getKeyPrefix() + '/o';
        string cancelURL = 'cancelURL=/' + result.getKeyPrefix() + '/o';

        if(this.extensionDelegate.RecordType.DeveloperName == 'Default'){
            return new PageReference('/' + this.extensionDelegate.id + '/e?nooverride=1&' + retURL + '&' + cancelURL);
        } else {
        	return new PageReference('/apex/ECO_DelegateManagerEdit?id=' + this.extensionDelegate.id + '&' + retURL + '&' + cancelURL);
        }

    }

    /**
     * Redirects user to standard page if the recordtype is default
     *
     * @Author  Tim Chiang
     * @Date    Oct 2016
     *
     **/
    public PageReference redirectIfDefaultView(){

	    Schema.DescribeSObjectResult result = Delegate__c.SObjectType.getDescribe(); 
        string retURL = 'retURL=/' + result.getKeyPrefix() + '/o';
        string cancelURL = 'cancelURL=/' + result.getKeyPrefix() + '/o';

        if(this.extensionDelegate.RecordType.DeveloperName == 'Default'){
            return new PageReference('/' + this.extensionDelegate.id + '?nooverride=1&' + retURL + '&' + cancelURL);
        } else {
        	return new PageReference('/apex/ECO_DelegateManagerEdit?id=' + this.extensionDelegate.id + '&' + retURL + '&' + cancelURL);
    	}
    }
}