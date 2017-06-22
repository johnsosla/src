global with sharing class ECO_PMD_ProjectDashboard_Controller extends ECO_Financial_Security{

	private final pse__Proj__c oProject ;
	public String queueMessage 						{ get; set; }
	public Boolean isNotRolledOut					{ get; set; }
	public Boolean canSubmitPriorityRollout 		{ get; set; }

	public ECO_PMD_ProjectWrapper wrapper { get; set; }

	/**
	 * Constructor - checks to see if the project has been rollout out completely or not, if not, then checks to see if the user has permission to submit
	 * the proejct for priority rollout status.
	 *
	 * @Author  NTT Data - Jake White & Deborah Orth
	 * @Date    November 2016
	 *
	 * @param	oStandardController
	 * @return 	
	 **/
	public ECO_PMD_ProjectDashboard_Controller(ApexPages.StandardController oStandardController) {
		Set<String> regionOuIds = new Set<String>();

		//which regions are we currently in the middle of rolling out?
		Map<String, ECO_BatchSetupRegions__c> rolloutRegionMap = ECO_BatchSetupRegions__c.getAll();
		for( String key : rolloutRegionMap.keySet()){
			regionOuIds.add( String.valueOf(rolloutRegionMap.get(key).RegionOuId__c));
		}

		oStandardController.addFields(new List<String>{'OuIdText__c'});
		this.oProject = (pse__Proj__c)oStandardController.getRecord();
		this.wrapper = new ECO_PMD_ProjectWrapper(this.oProject);

		//had this project been fully rollout out?
		this.isNotRolledOut = false;
		this.canSubmitPriorityRollout = false;
		if( regionOuIds.contains(this.oProject.OuIdText__c )){
			List<BatchedObject__c> boRecords = [SELECT Id, ChildrenComplete__c 
														FROM BatchedObject__c
														WHERE SObjectId__c = :this.oProject.Id
														   AND BatchJob__c LIKE '%MTD'];
			if( !boRecords.isEmpty()){
				if( !boRecords[0].ChildrenComplete__c)
					this.isNotRolledOut = true;
			} else {
				return; //no records, can't do anything so must assume it'a a new project, not a converted project in the current region
			}

			//does the user have the rights to request a priority rollout
			List<ProjectTeamMember__c> teamMember = [SELECT Id, ProjectRole__r.Type__c 
													FROM ProjectTeamMember__c 
													WHERE Project__c = :this.oProject.Id 
														AND Contact__r.pse__Salesforce_User__c = :userinfo.getuserId()];
			if( !teamMember.isEmpty()){
				if( teamMember[0].ProjectRole__r.Type__c == 'Key Member'){
					this.canSubmitPriorityRollout = true;
				}
			}							   
		}
	}

	public string locale { get {return UserInfo.getLocale().replace('_', '-');} }

	/**
	 * Allows a key member of the team to submit the project to the priority rollout queue if it hasn't been fully rolled out yet
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    November 2016
	 *
	 * @param	
	 * @return 	PageReference
	 **/
	public PageReference queueProjectForPriorityRollout(){
		this.queueMessage = ECO_Service_BatchSchedule.logProjectPriorityRolloutRequest(this.oProject.Id);
		return null;
	}

}