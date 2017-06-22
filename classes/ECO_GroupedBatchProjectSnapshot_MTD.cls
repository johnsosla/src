/** ------------------------------------------------------------------------------------------------------------
* @Description This class runs the Batch job for the "Project Snapshot MonthToDate" process, based on the
*              job Location and can also be rerun for failed jobs.
*
* @Author      Jake White, NTT Data - Arman Shah
* @Date        September 2016
*--------------------------------------------------------------------------------------------------------------*/
global class ECO_GroupedBatchProjectSnapshot_MTD extends ECO_BatchAdminService {
	public static final Integer DEFAULT_BATCH_SIZE = 10;
	private static final ECO_Service_ProjectSnapshots.SnapshotKeyRule DEFAULT_SNAPSHOT_KEY_RULE =
		ECO_Service_ProjectSnapshots.SnapshotKeyRule.MTD;

	String query;
	List<Id> projectIds {get; set;}
	Set<Id> projectIdSet {get; set;}
	ECO_Service_ProjectSnapshots.SnapshotKeyRule snapshotKeyRule {get; set;}
	Date asOfDate {get; set;}

	/**
	 *  constructor
	 *
	 * @Author  NTT Data - Tim Chiang
	 * @Date    Oct 2016
	 *
	 * @param
	 **/
	global ECO_GroupedBatchProjectSnapshot_MTD() {
		// Creates MTD snapshots for all active projects
		initialize(null, Date.today(), DEFAULT_SNAPSHOT_KEY_RULE, DEFAULT_BATCH_SIZE);
	}

	/**
	 *  constructor overload
	 *
	 * @Author  NTT Data - Tim Chiang
	 * @Date    Oct 2016
	 *
	 * @param
	 **/
	global ECO_GroupedBatchProjectSnapshot_MTD(List<Id> projectIds, Date asOfDate, ECO_Service_ProjectSnapshots.SnapshotKeyRule snapshotKeyRuleOverride,
		Integer batchSize) {
		// Runs on selected projects for the asOfDate -- requires specifying key rule, PROBABLY MONTH_END
		initialize(projectIds, asOfDate, snapshotKeyRuleOverride, batchSize);
	}

	/**
	 *  setup the query to run the batch against
	 *
	 * @Author  Jake White, NTT Data - Arman Shah
	 * @Date    query changed in August 2016
	 *
	 **/
	global void initialize(List<Id> projectIds, Date asOfDate,
		ECO_Service_ProjectSnapshots.SnapshotKeyRule snapshotKeyRule, Integer batchSize) {

		this.projectIds = projectIds;
		if (projectIds != null) {
			projectIdSet = new Set<Id>(projectIds);
		}
		System.debug('___projectIdSet='+projectIdSet);

		if (snapshotKeyRule == null) {
			this.snapshotKeyRule = DEFAULT_SNAPSHOT_KEY_RULE;
		}
		else {
			this.snapshotKeyRule = snapshotKeyRule;
		}

		if (asOfDate == null) {
			this.asOfDate = Date.today();
		}
		else {
			this.asOfDate = asOfDate;
		}

		if (batchSize != null) {
			this.batchSize = batchSize;
		}

		// *** MAINTAIN THIS CODE IN PARALLEL WITH ECO_Project_SnapshotBatch_MonthEnd initialize!!!


		/*List<String> regionOuIds = new list<string>();
		regionOuIds = ECO_GroupedBatchHelper.getListOfRegions();

		// Cleanse the projectIds list -- the project has to exist and have start and end dates in the fiscal month of the asOf
		pse__Time_Period__c month = ECO_Utils_Date.calcTimePeriods(new List<Date>{asOfDate},'Month')[0];
		String projectDateWindow = ' AND pse__Start_Date__c <= '+DateTime.newInstance(month.pse__End_Date__c,Time.newInstance(0,0,0,0)).format('yyyy-MM-dd')
								 + ' AND pse__End_Date__c >= '+DateTime.newInstance(month.pse__Start_Date__c,Time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
		if (projectIds == null) {
			query = 'SELECT Id FROM pse__Proj__c WHERE isActive__c = true' +
					' AND pse__Stage__c=\'Execution\' AND ouid__c IN: regionOuIds ' + projectDateWindow;
		}
		else {
			query = 'SELECT Id FROM pse__Proj__c WHERE isActive__c = true' +
					' AND pse__Stage__c=\'Execution\' ' + ' AND Id IN :projectIdSet AND ouid__c IN: regionOuIds ' + projectDateWindow;
		}*/

	}

	/**
	 *  batch start
	 *
	 * @Author  NTT Data - Tim Chiang
	 * @Date    Oct 2016
	 *
	 * @param
	 **/
	global Database.QueryLocator start(Database.BatchableContext BC) {
		//log the job start
		this.logId = ECO_Service_BatchLog.logJobStart('ECO_GroupedBatchProjectSnapshot_MTD', this.batchStream, this.regionOuIds, BC.getJobId(), this.jobName);

		if( this.isProcessingBlock){
			query = 'SELECT Id, PriorityRequestBy__c, SObjectID__c ' +
					'FROM BatchedObject__c ' +
					'WHERE ChildrenComplete__c=false ' +
					'   AND PriorityRequestBy__c != null' +
					'   AND BatchJob__c=\'Setup - Snapshot MTD\'';
		} else {
			query = 'SELECT Id, SObjectID__c ' +
					'FROM BatchedObject__c ' +
					'WHERE ChildrenComplete__c=false ' +
					'   AND BatchJob__c=\'Setup - Snapshot MTD\'';
		}

	   System.debug('__query='+query);
	   return Database.getQueryLocator(query);
	}

	/**
	 *  batch execute
	 *
	 * @Author  NTT Data - Tim Chiang
	 * @Date    Oct 2016
	 *
	 * @param
	 **/
	global void execute(Database.BatchableContext BC, List<BatchedObject__c> scope) {
		// convert pse__Proj__c records (a subset of the original requested list) to a list of Ids
		String jsonBO = '';
		jsonBO = '\n' + JSON.serialize(scope, true);

		try{

			// convert pse__Proj__c records (a subset of the original requested list) to a list of Ids
			List<Id> projectIds = new List<Id>();
			set<Id> boID = new set<Id>();
			for (BatchedObject__c ps : scope) {
				projectIds.add((id)ps.SObjectID__c);
				boID.add(ps.id);
			}

			ECO_Service_ProjectSnapshots.generateAndUpsertProjectSnapshots(asOfDate, projectIds, snapshotKeyRule);


			list<BatchedChildObject__c> lstBco = new list<BatchedChildObject__c>();

			for(BatchedChildObject__c oBatchChild : [select id, SObjectID__c from BatchedChildObject__c where BatchedObject__c IN: boID]){
				System.debug('@@@GOT HERE FOR oBatchChild: ' + oBatchChild.sObjectId__c);

				BatchedChildObject__c boc = new BatchedChildObject__c(id=oBatchChild.id, ChildStatus__c = 'Completed');
				//oBatchChild.ChildStatus__c = 'Completed';
				lstBco.add(boc);
			}

			try{
				update lstBco;
			} catch (Exception ex) {
				ECO_Service_ErrorLog.logException(ex, jsonBO);
			}

		} catch (Exception ex) {
			ECO_Service_ErrorLog.logException(ex, jsonBO);
		}

	}


	/**
	 *  batch finish
	 *
	 * @Author  NTT Data - Tim Chiang
	 * @Date    Oct 2016
	 *
	 * @param
	 **/
	global void finish(Database.BatchableContext BC) {
		//log the end of the job and possible call the next job in the stream
		runNextBatchInStream( BC.getJobId(), 'ECO_GroupedBatchProjectSnapshot_MTD');

	}

	/**
	 *  This should NOT be run in a scheduled context
	 *
	 * @Author  NTT Data - Tim Chiang
	 * @Date    Oct 2016
	 *
	 * @param
	 **/
	global void execute(SchedulableContext sc)
	{
		  //ECO_GroupedBatchProjectSnapshot_MTD b =
		  //    new ECO_GroupedBatchProjectSnapshot_MTD(projectIds, asOfDate, snapshotKeyRule, batchSize);
		  //System.debug('___Batch size='+batchSize);
		  //Database.executeBatch(b, batchSize);
	}
}