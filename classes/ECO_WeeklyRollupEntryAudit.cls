/**
* Batch job is designed to audit WeeklyRollupEntry__c objects to ensure they are created as intended.  Specifically checks
* to see that the CurrencyISOCode matches the ProjectFunctionalCurrencyCode, and also that the number of WeeklyRollupEntry__c
* objects is close to the number expected by the minimum and maximum project task start/end dates.
*
* Sends email results to the listed email addresses, or to a different set of email addresses listed in the constructor.
* Optionally, can start the ECO_RecalculateEVSBatch job for any projects that fail the tests.
*
* Can be launched with anonymous code like this:
*
* 		ECO_WeeklyRollupEntryAudit batch = new ECO_WeeklyRollupEntryAudit();
*		Database.executeBatch(batch, 10);
*
* Prepared for launching from batch dashboard.
*
* Don't forget to turn on email delivery for the org before running!
*
* @Author NTTDATA, Graham MacRobie (graham.macrobie@nttdata.com)
* @Date July 9, 2016
*/

global class ECO_WeeklyRollupEntryAudit extends ECO_BatchAdminService {
	global boolean startRecalculate = false;

	global String[] toAddresses = new String[] {
		'graham.macrobie@nttdata.com',
		'brian.jacobi@nttdata.com'
	};

	global Set<Id> projectErrorIds;
	global Set<Id> mismatchedIds;
	global Map<Id, String> incorrectWeeks;
	
	global Integer batchSize {
		get { 
			if (batchSize == null) {
				batchSize = 10; 
			}

			return batchSize;
		}

		set;
	}

	global ECO_WeeklyRollupEntryAudit() {
		init();
	}

	global ECO_WeeklyRollupEntryAudit(String[] toAddresses) {
		this.toAddresses = toAddresses;

		init();
	}

	global ECO_WeeklyRollupEntryAudit(boolean startRecalculate) {
		this.startRecalculate = startRecalculate;

		init();
	}

	global ECO_WeeklyRollupEntryAudit(String[] toAddresses, boolean startRecalculate) {
		this.toAddresses = toAddresses;
		this.startRecalculate = startRecalculate;

		init();
	}

	private void init() {
		projectErrorIds = new Set<Id>();
		mismatchedIds = new Set<Id>();
		incorrectWeeks = new Map<Id, String>();
	}
	
	global void execute(SchedulableContext SC) {
		ECO_WeeklyRollupEntryAudit batch = new ECO_WeeklyRollupEntryAudit();
		Database.executeBatch(batch, batchSize);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator('select id from pse__Proj__c');
	}

   	global void execute(Database.BatchableContext BC, List<pse__Proj__c> scope) {
   		doExecute(scope);
   	}

   	global void doExecute(List<pse__Proj__c> scope) {
   		Set<Id> projectIds = new Set<Id>();

   		for (pse__Proj__c project : scope) {
   			projectIds.add(project.id);
   		}

   		Map<Id, Date> projectMinStartDate = new Map<Id, Date>();
   		Map<Id, Date> projectMaxEndDate = new Map<Id, Date>();

   		List<pse__Project_Task__c> projectTasks = [select id, pse__Start_Date__c, pse__End_Date__c, pse__Project__c from pse__Project_Task__c where pse__Project__c in :projectIds];

   		for (pse__Project_Task__c projectTask : projectTasks) {
   			Date minStartDate = projectMinStartDate.get(projectTask.pse__Project__c);
   			Date maxEndDate = projectMaxEndDate.get(projectTask.pse__Project__c);

   			if ((minStartDate == null) || (projectTask.pse__Start_Date__c < minStartDate)) {
	   			projectMinStartDate.put(projectTask.pse__Project__c, projectTask.pse__Start_Date__c);
   			}

   			if ((maxEndDate == null) || (projectTask.pse__End_Date__c > maxEndDate)) {
	   			projectMaxEndDate.put(projectTask.pse__Project__c, projectTask.pse__End_Date__c);
   			}
   		}

   		List<WeeklyRollupEntry__c> wres = [select id, CurrencyISOCode, Project__c, Project__r.ProjectFunctionalCurrencyCode__c from WeeklyRollupEntry__c where Project__c in :projectIds];

   		Map<Id, Integer> wreCount = new Map<Id, Integer>();

   		Set<Id> hasMismatchedCurrency = new Set<Id>();

   		for (WeeklyRollupEntry__c wre : wres) {
   			Integer count = wreCount.get(wre.Project__c);

   			if (count == null) {
   				wreCount.put(wre.Project__c, 1);
   			} else {
   				wreCount.put(wre.Project__c, count + 1);
   			}

   			String wreCurrencyCode = wre.CurrencyISOCode;
   			String projectCurrencyCode = wre.Project__r.ProjectFunctionalCurrencyCode__c;

   			if (!wreCurrencyCode.equalsIgnoreCase(projectCurrencyCode)) {
   				hasMismatchedCurrency.add(wre.Project__c);
   			}
   		}

   		for (Id projectId : hasMismatchedCurrency) {
   			projectErrorIds.add(projectId);
   			mismatchedIds.add(projectId);
   		}

   		for (pse__Proj__c project : scope) {
   			Date minStartDate = projectMinStartDate.get(project.id);

   			if (minStartDate == null) {
   				continue;
   			}

   			Date maxEndDate = projectMaxEndDate.get(project.id);

   			if (maxEndDate == null) {
   				continue;
   			}

			Date startDateWeekStartDay = ECO_Service_Snapshots.getFirstDateOfWeek(minStartDate);
			Date endDateWeekStartDay = ECO_Service_Snapshots.getFirstDateOfWeek(maxEndDate);
			Integer daysBetween = startDateWeekStartDay.daysBetween(endDateWeekStartDay);
			Integer numOfWeeks = (daysBetween / 7) + 1;

			Integer actualNumOfWeeks = wreCount.get(project.id);

			if (actualNumOfWeeks == null) {
				actualNumOfWeeks = 0;
			}

			if (Math.abs(numOfWeeks - actualNumOfWeeks) > 2) {
				projectErrorIds.add(project.id);
				incorrectWeeks.put(project.id, numOfWeeks + ' - ' + actualNumOfWeeks);
			}
   		}
	}
	
	global void finish(Database.BatchableContext BC) {
		doFinish();
	}

	global void doFinish() {
   		if (projectErrorIds.size() == 0 ) {
   			return;
   		}

		String errorMessage = '';

		List<Id> projectIdList = new List<Id>(projectErrorIds);
		projectIdList.sort();

		for (Id projectId : projectIdList) {
			errorMessage += projectId + ',';

			if (mismatchedIds.contains(projectId)) {
				errorMessage += 'mismatched CurrencyISOCode,';
			} else {
				errorMessage += ',';
			}

			if (incorrectWeeks.containsKey(projectId)) {
				errorMessage += incorrectWeeks.get(projectId);
			}

			errorMessage += '\n';
		}

		if (toAddresses != null) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

			mail.setToAddresses(toAddresses);  
			mail.setSubject('WeeklyRollupEntry__c Audit Failures');  
			mail.setPlainTextBody(errorMessage);

			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}

		if (startRecalculate) {
			System.debug('starting ECO_RecalculateEVSBatch');

			ECO_RecalculateEVSBatch batch = new ECO_RecalculateEVSBatch(projectIdList, true);
			Database.executeBatch(batch, 1);  // batch size of 1 for maximum safety (heap size, etc)
		}
	}
}