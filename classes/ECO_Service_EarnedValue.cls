/** ------------------------------------------------------------------------------------------------------
* Service class for Earned Value pages
*
* @Author      NTT Data - Graham MacRobie
* @Date        2015
*-----------------------------------------------------------------------------------------------------*/
global without sharing class ECO_Service_EarnedValue {
	public static boolean nullifyReportingFields = false;

	/**
	 * Process tasks - generate the curve data, 
	 *
	 * @Author  NTT Data - Graham MacRobie
	 * @Date    2015
	 *
	 * @param	soqlTasks - list of tasked to be processed
	 * @return 	
	 **/
	public static void processTasks(List<pse__Project_Task__c> soqlTasks) {
		//System.debug(LoggingLevel.ERROR, 'processtasks' + soqlTasks);

		List<EarnedValueSnapshot__c> evsToUpsert = new List<EarnedValueSnapshot__c>();
		List<EarnedValueSnapshot__c> evsOutsideTaskDates = new List<EarnedValueSnapshot__c>();
		Map<Integer, EarnedValueSnapshot__c> mapEvToUpsertByInt = new Map<Integer, EarnedValueSnapshot__c>();

		List<WeeklyRollupEntry__c> wreToUpsert = new List<WeeklyRollupEntry__c>();
		
		Set<String> projectPhaseOrStageBeforeExecution = new Set<String>{'Approved','Planned','Unapproved','Submitted','Pending Go/No Go','No-Go','Planning','Lost','Canceled by Client'};
		Boolean isProjectInPlanning = false;
		
		for (pse__Project_Task__c pt : soqlTasks) {
			//this has to be done in case the #of EVSS records, ie the number of weeks a task has been running, exceeds 200 or it throws a 
			// 'Aggregate query has too many rows for direct assignment, use FOR loop' error
			List<EarnedValueSnapshot__c> evssList = new List<EarnedValueSnapshot__c>();
			for( EarnedValueSnapshot__c evss : pt.EarnedValueSnapshots__r){
				evssList.add(evss);
			}
			//System.debug('EarnedValueCurve__c:  '+pt.EarnedValueCurve__c);
			isProjectInPlanning = projectPhaseOrStageBeforeExecution.contains( pt.ProjectStage__c);
			//System.debug('___>pt.ProjectStage__c='+pt.ProjectStage__c);
			//System.debug('___>isProjectInPlanning='+isProjectInPlanning);

			Map<String, List<EarnedValueSnapshot__c>> returnedMap;

			//Ironically our S Curve produces a Bell Shape and vice versa
			try {
				if ('S Curve'.equalsIgnoreCase(pt.EarnedValueCurve__c)) {
					returnedMap = ECO_Service_EarnedValue.calculateBellCurveForTask(pt, evssList);
				} else if ('Front Loaded'.equalsIgnoreCase(pt.EarnedValueCurve__c)) {
					returnedMap = ECO_Service_EarnedValue.calculateFrontLoadedCurveForTask(pt, evssList);
				} else if ('Even'.equalsIgnoreCase(pt.EarnedValueCurve__c)) {
					returnedMap = ECO_Service_EarnedValue.calculateEvenCurveForTask(pt, evssList);
				} else if ('Bell Shaped'.equalsIgnoreCase(pt.EarnedValueCurve__c)) {
					returnedMap = ECO_Service_EarnedValue.calculateSCurveForTask(pt, evssList);
				} else if ('Back Loaded'.equalsIgnoreCase(pt.EarnedValueCurve__c)) {
					returnedMap = ECO_Service_EarnedValue.calculateBackLoadedCurveForTask(pt, evssList);
				}
			} catch (Exception ex) {
				//System.debug(LoggingLevel.ERROR, 'ECO_Service_EarnedValue.Error: ' + ex.getMessage());
                //System.debug(LoggingLevel.ERROR, 'ECO_Service_EarnedValue.Stack: ' + ex.getStackTraceString());

                ECO_Service_ErrorLog.logException(ex);
                throw ex;
			}

			if (returnedMap != null && returnedMap.get('Upsert') != null) {
				evsToUpsert.addAll(returnedMap.get('Upsert'));
			}

			if (returnedMap != null && returnedMap.get('Outside') != null) {
				List<EarnedValueSnapshot__c> evsReturned = returnedMap.get('Outside');
				applyThisWeekNumberAll(pt, evsReturned);
				evsOutsideTaskDates.addAll(evsReturned);
			}
		}

		//system.debug(Logginglevel.Info, '___>isProjectInPlanning = ' + isProjectInPlanning);
		//system.debug(Logginglevel.Info, 'evsOutsideTaskDates size: ' + evsOutsideTaskDates.size());
		if (isProjectInPlanning){
			delete evsOutsideTaskDates;
		} else {
			nullifyCostCurvesAll(evsOutsideTaskDates);
			evsToUpsert.addAll(evsOutsideTaskDates);
		}
		uniqueifyCompositeKeyAll(evsToUpsert, true);
			
		/** prep for upsert **/
		Integer rowNum = 0;
		for (EarnedValueSnapshot__c ev : evsToUpsert) {
			++rowNum;

			if(nullifyReportingFields){
				ev.ProjectFunctionalRawCost__c = 0;
				ev.ProjectFunctionalRawCostPLODCEXPS__c = 0;
				ev.ProjectFunctionalRawCostPLODCSUBS__c = 0;
				ev.ProjectFunctionalRawCostPLLabor__c = 0;
				ev.ProjectFunctionalRawCostPLFringe__c = 0;
				ev.ProjectFunctionalRawCostPLOverhead__c = 0;
				ev.ProjectFunctionalRawCostResourceNonLabor__c = 0;
				ev.ProjectFunctionalRawCostResourceLabor__c = 0;
				ev.ProjectHours__c = 0;
				ev.ProjectFunctionalBurdenedCost__c = 0;
				ev.ProjFuncBurdenedCostPLODCEXPS__c = 0;
				ev.ProjFuncBurdenedCostPLODCSUBS__c = 0;
				ev.ProjFuncBurdenedCostPLLabor__c = 0;
				ev.ProjFuncBurdenedCostPLFringe__c = 0;
				ev.ProjFuncBurdenedCostPLOverhead__c = 0;
				ev.ProjFuncBurdenedCostReportNonLabor__c = 0;
				ev.ProjFuncBurdenedCostReportLabor__c = 0;

			}

			mapEvToUpsertByInt.put(rowNum, ev);
		}

		Integer upsertIdx = 0;
		Boolean isDMLErrorFound = false;
		List<EarnedValueSnapshot__c> evsToRetry = new List<EarnedValueSnapshot__c>();
		Map<String, WeeklyRollupEntry__c> rollupsToInsert = new Map<String, WeeklyRollupEntry__c>();
		ECO_ProjectTaskTriggers.run = false;
		Database.UpsertResult[] urListInsert = Database.upsert( evsToUpsert, EarnedValueSnapshot__c.Fields.SnapshotKey__c, false);

		Map <Id, pse__Project_Task__c> mapTasks = new Map <Id, pse__Project_Task__c>(soqlTasks);

		Set<Id> projectIds = new Set<Id>();

		for (pse__Project_Task__c theProjectTask : mapTasks.values()) {
			projectIds.add(theProjectTask.pse__Project__c);
		}

		List<pse__Proj__c> projectList = [select id, ProjectFunctionalCurrencyCode__c from pse__Proj__c where id in :projectIds];

		Map<Id, String> currencyMap = new Map<Id, String>();

		for (pse__Proj__c theProject : projectList) {
			if (theProject.ProjectFunctionalCurrencyCode__c != null) {
				currencyMap.put(theProject.id, theProject.ProjectFunctionalCurrencyCode__c);
			}
		}

		/*** Check if WeeklyRollupEntry__c is missing for any of the earned values ****/
		for (Database.UpsertResult urr : urListInsert) {
			++upsertIdx;
			if (!urr.isSuccess()) {
				isDMLErrorFound = true;

				EarnedValueSnapshot__c failedEV = mapEvToUpsertByInt.get(upsertIdx);
				for(Database.Error objerr : urr.getErrors())
                {
					if (objerr.getStatusCode() != StatusCode.INVALID_FIELD) {

						// If it's not a foreign key lookup error then we want to throw an error and skip everything else
						//System.debug(LoggingLevel.ERROR, 'CompositeKey__c: ' + failedEV.CompositeKey__c);
						//System.debug(LoggingLevel.ERROR, 'SnapshotKey__c: ' + failedEV.SnapshotKey__c);
						throw new EarnedValueException(objerr.getMessage());
					}
				}

				evsToRetry.add(failedEV);

				String wreCompositeKey = failedEV.WeeklyRollupEntry__r.CompositeKey__c;
				Id theProjectId = mapTasks.get(failedEV.ProjectTask__c).pse__Project__c;
				String currencyCode = currencyMap.get(theProjectId);

				if (!rollupsToInsert.containsKey(wreCompositeKey)) {
					rollupsToInsert.put(wreCompositeKey, 
						new WeeklyRollupEntry__c(
							CompositeKey__c = wreCompositeKey, 
							Project__c = theProjectId,
						    PeriodStartDate__c = failedEV.WeekStartDate__c,
						    CurrencyISOCode = currencyCode));
						    

					//rollupsToInsert.put(wreCompositeKey, 
					//	new WeeklyRollupEntry__c(
					//		CompositeKey__c = wreCompositeKey, 
					//		Project__c = theProjectId,
					//	    PeriodStartDate__c = failedEV.WeekStartDate__c));
				}
			}
		}

		if (isDMLErrorFound) {
			//system.debug(Logginglevel.WARN, '~~~ WARNING!!! EarnedValueSnapshots had missing WeeklyRollupEntries on upsert. Inserting: ' + rollupsToInsert.size() + ' rollup(s)');

			insert rollupsToInsert.values();
			upsert evsToRetry SnapshotKey__c;
		}

		uniqueifyCompositeKeyAll(evsToUpsert, false);
		upsert evsToUpsert SnapshotKey__c;
		

		ECO_ProjectTaskTriggers.run = true;
	}

	/**
	 * converts decimal null to "0" otherwise returns original value 
	 *
	 * @Author  NTT Data - Omar Abdel-Latief
	 * @Date    2016
	 *
	 * @param	val - decimal value
	 * @return 	decimal value
	 **/
	public static Decimal ifNull(Decimal val) {
		return val == null ? 0 : val;
	}

	/**
	 * converts decimal to logarithm 
	 *
	 * @Author  NTT Data - Graham MacRobie
	 * @Date    2015
	 *
	 * @param	val - decimal value
	 * @return 	
	 **/
	public static Decimal EVlog(Decimal val) {
		return (val==0 || val == null ? 0 : Math.log(val));
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - Graham MacRobie
	 * @Date    2015
	 *
	 * @param	earnedValueSnapShotId - 
	 * @return 	List<EarnedValueTask__c>
	 **/
	public static List<EarnedValueTask__c> getEarnedValueTasksForEarnedValueSnapShot(Id earnedValueSnapShotId){

		List<EarnedValueTask__c> results = [SELECT Id,
												PercentComplete__c,
												ProjectTask__c,
												NotifyTaskOwner__c,
												Comments__c,
												Committed__c,
												CostAccruals__c
											FROM EarnedValueTask__c
											WHERE EarnedValueSnapshot__c = :earnedValueSnapShotId];

		return results;

	}

	/**
	 * 
	 *
	 * @Author  NTT Data - Graham MacRobie
	 * @Date    2015
	 *
	 * @param	earnedValueSnapShotId - 
	 * @return 	List<EarnedValueTask__c>
	 **/
	public static List<EarnedValueTask__c> getEarnedValueTasksForEarnedValueReport(Id earnedValueHeaderId){
		List<EarnedValueTask__c> results = new List<EarnedValueTask__c>();

		Set<Id> snapshotIds = new Set<Id>();
		List<EarnedValueSnapshot__c> snapshots = getEarnedValueSnapShotsForReport(earnedValueHeaderId);
		if(!snapshots.isEmpty()){
			for(EarnedValueSnapshot__c snapshot : snapshots){
				snapshotIds.add(snapshot.Id);
			}
		}
		
		results = [SELECT Id,
						PercentComplete__c,
						ProjectTask__c,
						NotifyTaskOwner__c,
						Comments__c,
						Committed__c,
						CostAccruals__c,
						EarnedValueSnapshot__c 
					FROM EarnedValueTask__c
					WHERE EarnedValueSnapshot__c IN :snapshotIds
					ORDER BY EarnedValueSnapshot__r.AsOfDate__c ASC];

		return results;

	}


	/**
	 * 
	 *
	 * @Author  NTT Data - Graham MacRobie
	 * @Date    2015
	 *
	 * @param	earnedValueHeaderId - 
	 * @return 	List<EarnedValueSnapshot__c>
	 **/
	public static List<EarnedValueSnapshot__c> getEarnedValueSnapShotsForReport(Id earnedValueHeaderId){

		List<EarnedValueSnapshot__c> results = [SELECT Id
													, AsOfDate__c
													//, EarnedValueHeader__c
													, Comments__c
												FROM EarnedValueSnapshot__c
												//WHERE EarnedValueHeader__c = :earnedValueHeaderId
												ORDER BY AsOfDate__c DESC];

		return results;

	}

	/**
	 * 
	 *
	 * @Author  NTT Data - Graham MacRobie
	 * @Date    2015
	 *
	 * @param	earnedValueHeaderId - 
	 * @return 	List<EarnedValueSnapshot__c>
	 **/
	public static List<EarnedValueSnapshot__c> getEarnedValueSnapShotsForReportAsc(Id earnedValueHeaderId){

		List<EarnedValueSnapshot__c> results = [SELECT Id
													, AsOfDate__c
													//, EarnedValueHeader__c
													, Comments__c
												FROM EarnedValueSnapshot__c
												//WHERE EarnedValueHeader__c = :earnedValueHeaderId
												ORDER BY AsOfDate__c ASC];

		return results;

	}

	/**
	 * 
	 *
	 * @Author  NTT Data - Graham MacRobie
	 * @Date    2015
	 *
	 * @param	earnedValueSnapShotId - 
	 * @return 	EarnedValueTask__c
	 **/
	public static EarnedValueSnapshot__c getLatestEarnedValueSnapshot(Id earnedValueHeaderId){
		
		EarnedValueSnapshot__c result = null;

		List<EarnedValueSnapshot__c> snapshots = getEarnedValueSnapShotsForReport(earnedValueHeaderId);
		if(!snapshots.isEmpty()){
			result = snapshots.get(0);
		}

		return result;
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - Graham MacRobie
	 * @Date    2015
	 *
	 * @param	earnedValueHeaderIds - 
	 * @return 	Map<Id, EarnedValueSnapshot__c>
	 **/
	public static Map<Id, EarnedValueSnapshot__c> getLatestEarnedValueSnapShotsForReports(Set<Id> earnedValueHeaderIds){
		Map<Id, EarnedValueSnapshot__c> results = new Map<Id, EarnedValueSnapshot__c>();

		List<EarnedValueSnapshot__c> snapshots = [SELECT Id
													, AsOfDate__c
													//, EarnedValueHeader__c
													, Comments__c
												FROM EarnedValueSnapshot__c
												//WHERE EarnedValueHeader__c IN :earnedValueHeaderIds
												ORDER BY AsOfDate__c DESC];

		
		for(EarnedValueSnapshot__c snapshot : snapshots){
			//if(!results.containsKey(snapshot.EarnedValueHeader__c)){
				//results.put(snapshot.EarnedValueHeader__c, snapshot);
			//}
		}	

		return results;

	}
	
	/**
	 * 
	 *
	 * @Author  NTT Data - Graham MacRobie
	 * @Date    2015
	 *
	 * @param	projectId - 
	 * @return 	List<EVPoint>
	 **/
	public static List<EVPoint> getAllEVPointsForProject (Id projectId) {
		List<EVPoint> returnList = new List<EVPoint>();
		
		for (AggregateResult ar : [SELECT WeekStartDate__c
										, SUM(ThisWeekAmount__c) totalAmountThisWeek
										, SUM(ThisWeekRunningTotalAmount__c) totalAmountSoFar
									FROM EarnedValueSnapshot__c
									WHERE ProjectTask__r.pse__Project__c = :projectId
									GROUP BY WeekStartDate__c
									ORDER BY WeekStartDate__c]) {
			EVPoint newPoint = new EVPoint();
			newPoint.weekStartDate = (Date)ar.get('WeekStartDate__c');
			newPoint.amountThisWeek = (Decimal)ar.get('totalAmountThisWeek'); 
			newPoint.amountSoFar = (Decimal)ar.get('totalAmountSoFar'); 
			returnList.add(newPoint);
		}
		
		return returnList;
	}
	
	/** ------------------------------------------------------------------------------------------------------
	* Inner class for a point of Earned Value data
	*
	* @Author      NTT Data - Graham MacRobie
	* @Date        2015
	*-----------------------------------------------------------------------------------------------------*/
	public class EVPoint {
		public Date weekStartDate;
		public Decimal amountThisWeek;
		public Decimal amountSoFar;
	}
	
	/**
	 * 
	 *
	 * @Author  NTT Data - Graham MacRobie
	 * @Date    2015
	 *
	 * @param	projTask - 
	 * @param	existingSnaps - 
	 * @return 	Map<String, List<EarnedValueSnapshot__c>>
	 **/
	public static Map<String, List<EarnedValueSnapshot__c>> calculateFrontLoadedCurveForTask (pse__Project_Task__c projTask, List<EarnedValueSnapshot__c> existingSnaps) {
		Decimal TotalApprovedCost = projTask.TotalApprovedCost__c == null ? 0 : projTask.TotalApprovedCost__c;
		
		if (projTask.pse__Start_Date__c == null) {
			throw new EarnedValueException('Start Date cannot be null for task:  '+projTask.Id);
		}
		if (projTask.pse__End_Date__c == null) {
			throw new EarnedValueException('End Date cannot be null for task:  '+projTask.Id);
		}
		/*
		if (projTask.TotalApprovedCost__c == null) {
			throw new EarnedValueException('Total Approved Cost cannot be null for task:  '+projTask.Id);
			return null;
		}
		*/
		if (existingSnaps == null) {
			throw new EarnedValueException('Incoming Project Task must include Earned Value Snapshot Subquery for task:  '+projTask.Id);
		}
		
		Map<String, List<EarnedValueSnapshot__c>> returnMap = new Map<String, List<EarnedValueSnapshot__c>>();
		returnMap.put('Upsert', new List<EarnedValueSnapshot__c>());
		returnMap.put('Outside', new List<EarnedValueSnapshot__c>());
		
		Date startDateWeekStartDay = ECO_Service_Snapshots.getFirstDateOfWeek(projTask.pse__Start_Date__c);
		Date endDateWeekStartDay = ECO_Service_Snapshots.getFirstDateOfWeek(projTask.pse__End_Date__c);
		Integer daysBetween = startDateWeekStartDay.daysBetween(endDateWeekStartDay);
		Integer numOfWeeks = (daysBetween/7)+1;
		
		Decimal averageAmount = TotalApprovedCost / numOfWeeks;
		Decimal runningTotal = 0;
		Decimal averageAmountEstimate = ifNull(projTask.TotalEstimateCost__c) / numOfWeeks;
		Decimal runningTotalEstimate = 0;
		Integer weekNum = 1;
		Date weekStartDateRunning = startDateWeekStartDay;
		
		List<EarnedValueSnapshot__c> evsToUpsert = new List<EarnedValueSnapshot__c>();
		List<EarnedValueSnapshot__c> evsOutsideTaskDates = new List<EarnedValueSnapshot__c>();
		
		for (Decimal i = 0; i < numOfWeeks; i++) {
			
			//system.debug('averageAmount:  '+averageAmount);
			//system.debug('averageAmountEstimate:  '+averageAmountEstimate);
			Decimal taskAmount = EVlog(Math.pow((Double)averageAmount, (Double)i+1));
            Decimal taskAmountEstimate = EVlog(Math.pow((Double)averageAmountEstimate, (Double)i+1));
			
			taskAmount = taskAmount.setScale(2, System.RoundingMode.HALF_UP);
            taskAmountEstimate = taskAmountEstimate.setScale(2, System.RoundingMode.HALF_UP);
			
			//system.debug('taskAmount:  '+taskAmount);
			
			runningTotal += taskAmount;
            runningTotalEstimate += taskAmountEstimate;
			
			EarnedValueSnapshot__c newEVSnap = new EarnedValueSnapshot__c();
			newEVSnap.CurrencyISOCode = projTask.pse__Project__r.ProjectFunctionalCurrencyCode__c;
			newEVSnap.ProjectTask__c = projTask.Id;
			newEVSnap.CompositeKey__c = projTask.Id+'_'+weekNum;
			newEVSnap.SnapshotKey__c = ECO_Service_Snapshots.DateToSnapshotKey(weekStartDateRunning, projTask.pse__Project__c, projTask.Id);
			newEVSnap.WeeklyRollupEntry__r = new WeeklyRollupEntry__c(CompositeKey__c = ECO_Service_Snapshots.DateToSnapshotKey(weekStartDateRunning, projTask.pse__Project__c));
			newEVSnap.WeekStartDate__c = weekStartDateRunning;
			newEVSnap.ThisWeekNumber__c = weekNum;
			newEVSnap.ThisWeekAmount__c = taskAmount;
            newEVSnap.ThisWeekAmountEst__c = taskAmountEstimate;
			
			evsToUpsert.add(newEVSnap);
			
			weekNum++;
			weekStartDateRunning = weekStartDateRunning.addDays(7);
		}
		
		//system.debug('projTask.TotalApprovedCost__c:  '+ TotalApprovedCost);
		//system.debug('runningTotal:  '+runningTotal);
		
		// now we have task amounts that are way too huge to be the final amount, but we have good ratios between them, step it down
		Decimal fixerRatio = runningTotal == 0 ? 0 : TotalApprovedCost / runningTotal;
        Decimal fixerRatioEstimate = runningTotalEstimate == 0 ? 0 : ifNull(projTask.TotalEstimateCost__c) / runningTotalEstimate;
		
		//system.debug('fixerRatio:  '+fixerRatio);
		
		// reset the running total
		runningTotal = 0;
        runningTotalEstimate = 0;
		
		// with the ratio we can fix the amounts
		for (EarnedValueSnapshot__c evs : evsToUpsert) {
			evs.ThisWeekAmount__c = (evs.ThisWeekAmount__c * fixerRatio).setScale(2, System.RoundingMode.HALF_UP);
            evs.ThisWeekAmountEst__c = (evs.ThisWeekAmountEst__c * fixerRatioEstimate).setScale(2, System.RoundingMode.HALF_UP);
			
			//system.debug('fixed evs.ThisWeekAmount__c:  '+evs.ThisWeekAmount__c);
			
			runningTotal += evs.ThisWeekAmount__c;
            runningTotalEstimate += evs.ThisWeekAmountEst__c;
			
			evs.ThisWeekRunningTotalAmount__c = runningTotal;
            evs.ThisWeekAmountCumulativeEst__c = runningTotalEstimate;
			evs.ThisWeekTotalRemaining__c = TotalApprovedCost - runningTotal;
		}
		
		// reset the running total
		runningTotal = 0;
        runningTotalEstimate = 0;
		
		List<Decimal> valuesList = new List<Decimal>(); // We'll use this to hold values in the order we want them
        List<Decimal> valuesListEstimate = new List<Decimal>(); // We'll use this to hold values in the order we want them
		
		// Now we have the curve, let's reverse it for front loaded.
		for (Integer i = evsToUpsert.size()-1 ; i >= 0 ; i--) {
			
			valuesList.add(evsToUpsert[i].ThisWeekAmount__c);
            valuesListEstimate.add(evsToUpsert[i].ThisWeekAmountEst__c);
			
			//system.debug('reverse order:  '+evsToUpsert[i].ThisWeekAmount__c);
		}
		
		// Finally, let's loop once more in the proper order to replace all the values
		Integer listPos = 0;
		for (EarnedValueSnapshot__c evs : evsToUpsert) {
			evs.ThisWeekAmount__c = valuesList[listPos];
            evs.ThisWeekAmountEst__c = valuesListEstimate[listPos];
			
			runningTotal += evs.ThisWeekAmount__c;
            runningTotalEstimate += evs.ThisWeekAmountEst__c;
			
			evs.ThisWeekRunningTotalAmount__c = runningTotal;
            evs.ThisWeekAmountCumulativeEst__c = runningTotalEstimate;
			evs.ThisWeekTotalRemaining__c = TotalApprovedCost - runningTotal;
			
			listPos++;
		}
		
		for (EarnedValueSnapshot__c ev : existingSnaps) {
			Date wkStartDate = ev.WeekStartDate__c; //getFirstDateOfWeekFromKey(ev.SnapshotKey__c); // 
			if (wkStartDate < startDateWeekStartDay || wkStartDate > endDateWeekStartDay )
				evsOutsideTaskDates.add(ev);
			/*
			Integer evWeekIndex = ev.ThisWeekNumber__c.intValue()-1;
			if (ev.ThisWeekNumber__c > numOfWeeks) {
				evsOutsideTaskDates.add(ev);
			} else if(evsToUpsert[evWeekIndex].SnapshotKey__c != ev.SnapshotKey__c) {
				// Handle date range changing
				evsOutsideTaskDates.add(ev);
			}
			*/
		}
		
		returnMap.get('Upsert').addAll(evsToUpsert);
		returnMap.get('Outside').addAll(evsOutsideTaskDates);
		
		return returnMap;
	}
	
	/**
	 * 
	 *
	 * @Author  NTT Data - Graham MacRobie
	 * @Date    2015
	 *
	 * @param	projTask - 
	 * @param	existingSnaps - 
	 * @return 	Map<String, List<EarnedValueSnapshot__c>>
	 **/
	public static Map<String, List<EarnedValueSnapshot__c>> calculateBackLoadedCurveForTask (pse__Project_Task__c projTask, List<EarnedValueSnapshot__c> existingSnaps) {
		Decimal TotalApprovedCost = projTask.TotalApprovedCost__c == null ? 0 : projTask.TotalApprovedCost__c;
		if (projTask.pse__Start_Date__c == null) {
			throw new EarnedValueException('Start Date cannot be null for task:  '+projTask.Id);
		}
		if (projTask.pse__End_Date__c == null) {
			throw new EarnedValueException('End Date cannot be null for task:  '+projTask.Id);
		}
		/*
		if (projTask.TotalApprovedCost__c == null) {
			throw new EarnedValueException('Total Approved Cost cannot be null for task:  '+projTask.Id);
		}
		*/
		if (existingSnaps == null) {
			throw new EarnedValueException('Incoming Project Task must include Earned Value Snapshot Subquery for task:  '+projTask.Id);
		}
		
		Map<String, List<EarnedValueSnapshot__c>> returnMap = new Map<String, List<EarnedValueSnapshot__c>>();
		returnMap.put('Upsert', new List<EarnedValueSnapshot__c>());
		returnMap.put('Outside', new List<EarnedValueSnapshot__c>());
		
		Date startDateWeekStartDay = ECO_Service_Snapshots.getFirstDateOfWeek(projTask.pse__Start_Date__c);
		Date endDateWeekStartDay = ECO_Service_Snapshots.getFirstDateOfWeek(projTask.pse__End_Date__c);
		Integer daysBetween = startDateWeekStartDay.daysBetween(endDateWeekStartDay);
		Integer numOfWeeks = (daysBetween/7)+1;
		
		Decimal averageAmount = TotalApprovedCost / numOfWeeks;
		Decimal runningTotal = 0;
		Decimal averageAmountEstimate = ifNull(projTask.TotalEstimateCost__c) / numOfWeeks;
		Decimal runningTotalEstimate = 0;
		Integer weekNum = 1;
		Date weekStartDateRunning = startDateWeekStartDay;
		
		List<EarnedValueSnapshot__c> evsToUpsert = new List<EarnedValueSnapshot__c>();
		List<EarnedValueSnapshot__c> evsOutsideTaskDates = new List<EarnedValueSnapshot__c>();
		
		for (Decimal i = 0; i < numOfWeeks; i++) {
			
			//system.debug('averageAmount:  '+averageAmount);
			
			Decimal taskAmount = EVlog(Math.pow((Double)averageAmount, (Double)i+1));
            Decimal taskAmountEstimate = EVlog(Math.pow((Double)averageAmountEstimate, (Double)i+1));
			
			taskAmount = taskAmount.setScale(2, System.RoundingMode.HALF_UP);
            taskAmountEstimate = taskAmountEstimate.setScale(2, System.RoundingMode.HALF_UP);
			
			//system.debug('taskAmount:  '+taskAmount);
			
			runningTotal += taskAmount;
            runningTotalEstimate += taskAmountEstimate;
			
			EarnedValueSnapshot__c newEVSnap = new EarnedValueSnapshot__c();
			newEVSnap.CurrencyISOCode = projTask.pse__Project__r.ProjectFunctionalCurrencyCode__c;
			newEVSnap.ProjectTask__c = projTask.Id;
			newEVSnap.CompositeKey__c = projTask.Id+'_'+weekNum;
			newEVSnap.SnapshotKey__c = ECO_Service_Snapshots.DateToSnapshotKey(weekStartDateRunning, projTask.pse__Project__c, projTask.Id);
			newEVSnap.WeeklyRollupEntry__r = new WeeklyRollupEntry__c(CompositeKey__c = ECO_Service_Snapshots.DateToSnapshotKey(weekStartDateRunning, projTask.pse__Project__c));
			newEVSnap.WeekStartDate__c = weekStartDateRunning;
			newEVSnap.ThisWeekNumber__c = weekNum;
			newEVSnap.ThisWeekAmount__c = taskAmount;
            newEVSnap.ThisWeekAmountEst__c = taskAmountEstimate;
			
			evsToUpsert.add(newEVSnap);
			
			weekNum++;
			weekStartDateRunning = weekStartDateRunning.addDays(7);
		}
		
		//system.debug('projTask.TotalApprovedCost__c:  '+TotalApprovedCost);
		//system.debug('runningTotal:  '+runningTotal);
		
		// now we have task amounts that are way too huge to be the final amount, but we have good ratios between them, step it down
		Decimal fixerRatio = runningTotal == 0 ? 0 : TotalApprovedCost/ runningTotal;
        Decimal fixerRatioEstimate = runningTotalEstimate == 0 ? 0 : ifNull(projTask.TotalEstimateCost__c) / runningTotalEstimate;
		
		//system.debug('fixerRatio:  '+fixerRatio);
		
		// reset the running total
		runningTotal = 0;
		runningTotalEstimate = 0;
		
		// with the ratio we can fix the amounts
		for (EarnedValueSnapshot__c evs : evsToUpsert) {
			evs.ThisWeekAmount__c = (evs.ThisWeekAmount__c * fixerRatio).setScale(2, System.RoundingMode.HALF_UP);
            evs.ThisWeekAmountEst__c = (evs.ThisWeekAmountEst__c * fixerRatioEstimate).setScale(2, System.RoundingMode.HALF_UP);
			
			//system.debug('fixed evs.ThisWeekAmount__c:  '+evs.ThisWeekAmount__c);
			
			runningTotal += evs.ThisWeekAmount__c;
            runningTotalEstimate += evs.ThisWeekAmountEst__c;
			
			evs.ThisWeekRunningTotalAmount__c = runningTotal;
            evs.ThisWeekAmountCumulativeEst__c = runningTotalEstimate;
			evs.ThisWeekTotalRemaining__c =  TotalApprovedCost - runningTotal;
		}
		
		for (EarnedValueSnapshot__c ev : existingSnaps) {
			Date wkStartDate = ev.WeekStartDate__c; //getFirstDateOfWeekFromKey(ev.SnapshotKey__c); // 
			if (wkStartDate < startDateWeekStartDay || wkStartDate > endDateWeekStartDay )
				evsOutsideTaskDates.add(ev);
			/*
			Integer evWeekIndex = ev.ThisWeekNumber__c.intValue()-1;
			if (ev.ThisWeekNumber__c > numOfWeeks) {
				evsOutsideTaskDates.add(ev);
			} else if(evsToUpsert[evWeekIndex].SnapshotKey__c != ev.SnapshotKey__c) {
				// Handle date range changing
				evsOutsideTaskDates.add(ev);
			}
			*/
		}
		
		returnMap.get('Upsert').addAll(evsToUpsert);
		returnMap.get('Outside').addAll(evsOutsideTaskDates);
		
		return returnMap;
	}
	
	/**
	 * 
	 *
	 * @Author  NTT Data - Graham MacRobie
	 * @Date    2015
	 *
	 * @param	projTask - 
	 * @param	existingSnaps - 
	 * @return 	Map<String, List<EarnedValueSnapshot__c>>
	 **/
	public static Map<String, List<EarnedValueSnapshot__c>> calculateEvenCurveForTask (pse__Project_Task__c projTask, List<EarnedValueSnapshot__c> existingSnaps) {
		Decimal TotalApprovedCost = projTask.TotalApprovedCost__c == null ? 0 : projTask.TotalApprovedCost__c;

		if (projTask.pse__Start_Date__c == null) {
			throw new EarnedValueException('Start Date cannot be null for task:  '+projTask.Id);
		}
		if (projTask.pse__End_Date__c == null) {
			throw new EarnedValueException('End Date cannot be null for task:  '+projTask.Id);
		}
		/*if (projTask.TotalApprovedCost__c == null) {

			throw new EarnedValueException('Total Approved Cost cannot be null for task:  '+projTask.Id);
		}*/
		if (existingSnaps == null) {
			throw new EarnedValueException('Incoming Project Task must include Earned Value Snapshot Subquery for task:  '+projTask.Id);
		}
		
		Map<String, List<EarnedValueSnapshot__c>> returnMap = new Map<String, List<EarnedValueSnapshot__c>>();
		returnMap.put('Upsert', new List<EarnedValueSnapshot__c>());
		returnMap.put('Outside', new List<EarnedValueSnapshot__c>());
		
		Date startDateWeekStartDay = ECO_Service_Snapshots.getFirstDateOfWeek(projTask.pse__Start_Date__c);
		Date endDateWeekStartDay = ECO_Service_Snapshots.getFirstDateOfWeek(projTask.pse__End_Date__c);
		Integer daysBetween = startDateWeekStartDay.daysBetween(endDateWeekStartDay);
		Integer numOfWeeks = (daysBetween/7)+1;

		//System.debug('project task - ' + projTask.id);
		//System.debug('start date - ' + projTask.pse__Start_Date__c);
		//System.debug('start date fixed - ' + startDateWeekStartDay);
		//System.debug('end date - ' + projTask.pse__End_Date__c);
		//System.debug('end date fixed - ' + endDateWeekStartDay);
		//System.debug('days between - ' + daysBetween);
		
		Decimal averageAmount = TotalApprovedCost / numOfWeeks;
		Decimal averageAmountEstimate = ifNull(projTask.TotalEstimateCost__c) / numOfWeeks;
		Decimal runningTotal = 0;
		Decimal runningTotalEstimate = 0;
		Integer weekNum = 1;
		Date weekStartDateRunning = startDateWeekStartDay;
		
		List<EarnedValueSnapshot__c> evsToUpsert = new List<EarnedValueSnapshot__c>();
		List<EarnedValueSnapshot__c> evsOutsideTaskDates = new List<EarnedValueSnapshot__c>();
		//System.debug('numOfWeeks: ' + numOfWeeks);
		
		for (Decimal i = 0; i < numOfWeeks; i++) {
			
			Decimal taskAmount = averageAmount;
			Decimal taskAmountEstimate = averageAmountEstimate;
			
			taskAmount = taskAmount.setScale(2, System.RoundingMode.HALF_UP);
			taskAmountEstimate = taskAmountEstimate.setScale(2, System.RoundingMode.HALF_UP);
			
			runningTotal += taskAmount;
			runningTotalEstimate += taskAmountEstimate;
			
			EarnedValueSnapshot__c newEVSnap = new EarnedValueSnapshot__c();
			newEVSnap.CurrencyISOCode = projTask.pse__Project__r.ProjectFunctionalCurrencyCode__c;
			newEVSnap.ProjectTask__c = projTask.Id;
			newEVSnap.CompositeKey__c = projTask.Id+'_'+weekNum;
			newEVSnap.SnapshotKey__c = ECO_Service_Snapshots.DateToSnapshotKey(weekStartDateRunning, projTask.pse__Project__c, projTask.Id);
			newEVSnap.WeeklyRollupEntry__r = new WeeklyRollupEntry__c(CompositeKey__c = ECO_Service_Snapshots.DateToSnapshotKey(weekStartDateRunning, projTask.pse__Project__c));
			newEVSnap.WeekStartDate__c = weekStartDateRunning;
			newEVSnap.ThisWeekNumber__c = weekNum;
			newEVSnap.ThisWeekAmount__c = taskAmount;
			newEVSnap.ThisWeekRunningTotalAmount__c = runningTotal;
			newEVSnap.ThisWeekAmountEst__c = taskAmountEstimate;
			newEVSnap.ThisWeekAmountCumulativeEst__c = runningTotalEstimate;
			newEVSnap.ThisWeekTotalRemaining__c = TotalApprovedCost - runningTotal;
			
			evsToUpsert.add(newEVSnap);
			
			weekNum++;
			weekStartDateRunning = weekStartDateRunning.addDays(7);
		}
		
		for (EarnedValueSnapshot__c ev : existingSnaps) {
			Date wkStartDate = ev.WeekStartDate__c; //getFirstDateOfWeekFromKey(ev.SnapshotKey__c); // 
			if (wkStartDate < startDateWeekStartDay || wkStartDate > endDateWeekStartDay )
				evsOutsideTaskDates.add(ev);
			/*
			Integer evWeekIndex = ev.ThisWeekNumber__c.intValue()-1;
			if (ev.ThisWeekNumber__c > numOfWeeks) {
				evsOutsideTaskDates.add(ev);
			} else if(evsToUpsert[evWeekIndex].SnapshotKey__c != ev.SnapshotKey__c) {
				// Handle date range changing
				evsOutsideTaskDates.add(ev);
			}
			*/
		}
		
		returnMap.get('Upsert').addAll(evsToUpsert);
		returnMap.get('Outside').addAll(evsOutsideTaskDates);
		
		return returnMap;
	}

	/**
	 * 
	 *
	 * @Author  NTT Data - Graham MacRobie
	 * @Date    2015
	 *
	 * @param	projTask - 
	 * @param	existingSnaps - 
	 * @return 	Map<String, List<EarnedValueSnapshot__c>>
	 **/
	public static Map<String, List<EarnedValueSnapshot__c>> calculateSCurveForTask (pse__Project_Task__c projTask, List<EarnedValueSnapshot__c> existingSnaps) {
		Decimal TotalApprovedCost = projTask.TotalApprovedCost__c == null ? 0 : projTask.TotalApprovedCost__c;
		if (projTask.pse__Start_Date__c == null) {
			throw new EarnedValueException('Start Date cannot be null for task:  '+projTask.Id);
		}
		if (projTask.pse__End_Date__c == null) {
			throw new EarnedValueException('End Date cannot be null for task:  '+projTask.Id);
		}
		/*
		if (projTask.TotalApprovedCost__c == null) {
			return null;
			throw new EarnedValueException('Total Approved Cost cannot be null for task:  '+projTask.Id);
		}
		*/
		if (existingSnaps == null) {
			throw new EarnedValueException('Incoming Project Task must include Earned Value Snapshot Subquery for task:  '+projTask.Id);
		}
		
		Map<String, List<EarnedValueSnapshot__c>> returnMap = new Map<String, List<EarnedValueSnapshot__c>>();
		returnMap.put('Upsert', new List<EarnedValueSnapshot__c>());
		returnMap.put('Outside', new List<EarnedValueSnapshot__c>());
		
		Date startDateWeekStartDay = ECO_Service_Snapshots.getFirstDateOfWeek(projTask.pse__Start_Date__c);
		Date endDateWeekStartDay = ECO_Service_Snapshots.getFirstDateOfWeek(projTask.pse__End_Date__c);
		Integer daysBetween = startDateWeekStartDay.daysBetween(endDateWeekStartDay);
		Integer numOfWeeks = (daysBetween/7)+1;
		
		Decimal runningTotal = 0;
		Decimal runningTotalEstimate = 0;
		Decimal totalAmount = TotalApprovedCost;
		Decimal totalAmountEstimate = ifNull(projTask.TotalEstimateCost__c);
		Decimal numWeeksTotal = numOfWeeks;
		Decimal halfWeeks = numWeeksTotal/2;
		Decimal negWeekStart = halfWeeks*-1;
		
		List<EarnedValueSnapshot__c> evsToUpsert = new List<EarnedValueSnapshot__c>();
		List<EarnedValueSnapshot__c> evsOutsideTaskDates = new List<EarnedValueSnapshot__c>();
		
		Date weekStartDateRunning = startDateWeekStartDay;
		
		Integer weekNum = 1;
		
		for (Decimal i = negWeekStart; i < halfWeeks; i++) {
			Decimal step = (i/halfWeeks)*3;

			Decimal rawSigmoid = ECO_Utils_Math.sigmoid(step);
			//system.debug('i number:  '+i);
			//system.debug('rawSigmoid:  '+rawSigmoid);
			Decimal taskAmount = ((rawSigmoid*totalAmount));
			Decimal taskAmountEstimate = ((rawSigmoid*totalAmountEstimate));
			
			taskAmount = taskAmount.setScale(2, System.RoundingMode.HALF_UP);
			taskAmountEstimate = taskAmountEstimate.setScale(2, System.RoundingMode.HALF_UP);
			
			runningTotal += taskAmount;
			runningTotalEstimate += taskAmountEstimate;
			
			//system.debug('Task Amount1:  '+taskAmount+', total:  '+runningTotal);
			//system.debug('Week Number:  '+weekNum);
			
			EarnedValueSnapshot__c newEVSnap = new EarnedValueSnapshot__c();
			newEVSnap.CurrencyISOCode = projTask.pse__Project__r.ProjectFunctionalCurrencyCode__c;
			newEVSnap.ProjectTask__c = projTask.Id;
			newEVSnap.CompositeKey__c = projTask.Id+'_'+weekNum;
			newEVSnap.SnapshotKey__c = ECO_Service_Snapshots.DateToSnapshotKey(weekStartDateRunning, projTask.pse__Project__c, projTask.Id);
			newEVSnap.WeeklyRollupEntry__r = new WeeklyRollupEntry__c(CompositeKey__c = ECO_Service_Snapshots.DateToSnapshotKey(weekStartDateRunning, projTask.pse__Project__c));
			newEVSnap.WeekStartDate__c = weekStartDateRunning;
			newEVSnap.ThisWeekNumber__c = weekNum;
			newEVSnap.ThisWeekAmount__c = taskAmount;
			newEVSnap.ThisWeekAmountCumulativeEst__c = runningTotalEstimate;
			newEVSnap.ThisWeekAmountEst__c = taskAmountEstimate;
			
			evsToUpsert.add(newEVSnap);
			
			weekNum++;
			weekStartDateRunning = weekStartDateRunning.addDays(7);
		}
		
		// now we have task amounts that are way too huge to be the final amount, but we have good ratios between them, step it down
		Decimal fixerRatio = runningTotal == 0 ? 0 :totalAmount / runningTotal;
		Decimal fixerRatioEstimate = runningTotalEstimate == 0 ? 0 :totalAmountEstimate / runningTotalEstimate;
		// reset the running total
		runningTotal = 0;
        runningTotalEstimate = 0;
		
		
		// with the ratio we can fix the amounts
		for (EarnedValueSnapshot__c evs : evsToUpsert) {
			evs.ThisWeekAmount__c = (evs.ThisWeekAmount__c * fixerRatio).setScale(2, System.RoundingMode.HALF_UP);
			evs.ThisWeekAmountEst__c = (evs.ThisWeekAmountEst__c * fixerRatioEstimate).setScale(2, System.RoundingMode.HALF_UP);
			
			runningTotal += evs.ThisWeekAmount__c;
            runningTotalEstimate += evs.ThisWeekAmountEst__c;
			
			evs.ThisWeekRunningTotalAmount__c = runningTotal;
			evs.ThisWeekAmountCumulativeEst__c = runningTotalEstimate;
			evs.ThisWeekTotalRemaining__c = totalAmount - runningTotal;
		}
		
		
		for (EarnedValueSnapshot__c ev : existingSnaps) {
			Date wkStartDate = ev.WeekStartDate__c; //getFirstDateOfWeekFromKey(ev.SnapshotKey__c); // 
			if (wkStartDate < startDateWeekStartDay || wkStartDate > endDateWeekStartDay )
				evsOutsideTaskDates.add(ev);
			/*
			Integer evWeekIndex = ev.ThisWeekNumber__c.intValue()-1;
			if (ev.ThisWeekNumber__c > numWeeksTotal) {
				evsOutsideTaskDates.add(ev);
			} else if(evsToUpsert[evWeekIndex].SnapshotKey__c != ev.SnapshotKey__c) {
				// Handle date range changing
				evsOutsideTaskDates.add(ev);
			}
			*/
		}
		
		//system.debug('Total At End:  '+runningTotal);
		//system.debug('totalAmount:  '+totalAmount);
		
		
		returnMap.get('Upsert').addAll(evsToUpsert);
		returnMap.get('Outside').addAll(evsOutsideTaskDates);
		
		return returnMap;
	}
	
	/**
	 * 
	 *
	 * @Author  NTT Data - Graham MacRobie
	 * @Date    2015
	 *
	 * @param	projTask - 
	 * @param	existingSnaps - 
	 * @return 	Map<String, List<EarnedValueSnapshot__c>>
	 **/
	public static Map<String, List<EarnedValueSnapshot__c>> calculateBellCurveForTask (pse__Project_Task__c projTask, List<EarnedValueSnapshot__c> existingSnaps) {
		Decimal TotalApprovedCost = projTask.TotalApprovedCost__c == null ? 0 : projTask.TotalApprovedCost__c;
		if (projTask.pse__Start_Date__c == null) {
			throw new EarnedValueException('Start Date cannot be null for task:  '+projTask.Id);
		}
		if (projTask.pse__End_Date__c == null) {
			throw new EarnedValueException('End Date cannot be null for task:  '+projTask.Id);
		}
		/*
		if (projTask.TotalApprovedCost__c == null) {
			return null;
			throw new EarnedValueException('Total Approved Cost cannot be null for task:  '+projTask.Id);
		}
		*/
		if (existingSnaps == null) {
			throw new EarnedValueException('Incoming Project Task must include Earned Value Snapshot Subquery for task:  '+projTask.Id);
		}
		
		Map<String, List<EarnedValueSnapshot__c>> returnMap = new Map<String, List<EarnedValueSnapshot__c>>();
		returnMap.put('Upsert', new List<EarnedValueSnapshot__c>());
		returnMap.put('Outside', new List<EarnedValueSnapshot__c>());
		
		Date startDateWeekStartDay = ECO_Service_Snapshots.getFirstDateOfWeek(projTask.pse__Start_Date__c);
		Date endDateWeekStartDay = ECO_Service_Snapshots.getFirstDateOfWeek(projTask.pse__End_Date__c);
		Integer daysBetween = startDateWeekStartDay.daysBetween(endDateWeekStartDay);
		Integer numOfWeeks = (daysBetween/7)+1;
		
		Decimal runningTotal = 0;
		Decimal runningTotalEstimate = 0;
		Decimal totalAmount = TotalApprovedCost;
		//System.debug('hey1 - ' + totalAmount);
		//System.debug('hey2 - ' + TotalApprovedCost);
		Decimal totalAmountEstimate = ifNull(projTask.TotalEstimateCost__c);
		Decimal numWeeksTotal = numOfWeeks;
		Decimal meanWeeks = (numWeeksTotal+1)/2;
		
		List<EarnedValueSnapshot__c> evsToUpsert = new List<EarnedValueSnapshot__c>();
		List<EarnedValueSnapshot__c> evsOutsideTaskDates = new List<EarnedValueSnapshot__c>();
		
		Date weekStartDateRunning = startDateWeekStartDay;
		
		Integer weekNum = 1;
		
		Decimal meanValue = totalAmount / numWeeksTotal;
		Decimal meanValueEstimate = totalAmountEstimate / numWeeksTotal;

		for (Decimal i = 0; i < numWeeksTotal; i++) {

			Decimal taskAmount = totalAmount - ((Math.abs(((i+1) - meanWeeks))) * meanValue);
			Decimal taskAmountEstimate = totalAmountEstimate - ((Math.abs(((i+1) - meanWeeks))) * meanValueEstimate);
			
			taskAmount = taskAmount.setScale(2, System.RoundingMode.HALF_UP);
			taskAmountEstimate = taskAmountEstimate.setScale(2, System.RoundingMode.HALF_UP);
			
			//system.debug('Calced Sigma:  '+(totalAmount - (Math.abs(((i+1) - meanWeeks))) * meanValue));
			//system.debug('Calced Sigma:  '+((Math.abs(((i+1) - meanWeeks))) * meanValue));
			
			runningTotal += taskAmount;
			runningTotalEstimate += taskAmountEstimate;
			
			//system.debug('Task Amount2:  '+taskAmount+', total:  '+runningTotal);
			//system.debug('Week Number:  '+weekNum);
			
			EarnedValueSnapshot__c newEVSnap = new EarnedValueSnapshot__c();
			newEVSnap.CurrencyISOCode = projTask.pse__Project__r.ProjectFunctionalCurrencyCode__c;
			newEVSnap.ProjectTask__c = projTask.Id;
			newEVSnap.CompositeKey__c = projTask.Id+'_'+weekNum;
			newEVSnap.SnapshotKey__c = ECO_Service_Snapshots.DateToSnapshotKey(weekStartDateRunning, projTask.pse__Project__c, projTask.Id);
			newEVSnap.WeeklyRollupEntry__r = new WeeklyRollupEntry__c(CompositeKey__c = ECO_Service_Snapshots.DateToSnapshotKey(weekStartDateRunning, projTask.pse__Project__c));
			newEVSnap.WeekStartDate__c = weekStartDateRunning;
			newEVSnap.ThisWeekNumber__c = weekNum;
			newEVSnap.ThisWeekAmount__c = taskAmount;
			newEVSnap.ThisWeekAmountEst__c = taskAmountEstimate;
			newEVSnap.ThisWeekRunningTotalAmount__c = runningTotal;
			newEVSnap.ThisWeekAmountCumulativeEst__c = runningTotalEstimate;
			newEVSnap.ThisWeekTotalRemaining__c = totalAmount - runningTotal;
			
			evsToUpsert.add(newEVSnap);
			
			weekNum++;
			weekStartDateRunning = weekStartDateRunning.addDays(7);
		}
		
		// now we have task amounts that are way too huge to be the final amount, but we have good ratios between them, step it down
		
		Decimal fixerRatio = (runningTotal != 0) ? totalAmount / runningTotal : 0;
		Decimal fixerRatioEstimate = (runningTotalEstimate != 0) ? totalAmountEstimate / runningTotalEstimate : 0;
		
		// reset the running total
		runningTotal = 0;
        runningTotalEstimate = 0;
		
		// with the ratio we can fix the amounts
		for (EarnedValueSnapshot__c evs : evsToUpsert) {
			evs.ThisWeekAmount__c = (evs.ThisWeekAmount__c * fixerRatio).setScale(2, System.RoundingMode.HALF_UP);
            evs.ThisWeekAmountEst__c = (evs.ThisWeekAmountEst__c * fixerRatioEstimate).setScale(2, System.RoundingMode.HALF_UP);
			
			//system.debug('fixed evs.ThisWeekAmount__c :  '+evs.ThisWeekAmount__c );
			
			runningTotal += evs.ThisWeekAmount__c;
			runningTotalEstimate += evs.ThisWeekAmountEst__c;
			
			evs.ThisWeekRunningTotalAmount__c = runningTotal;
            evs.ThisWeekAmountCumulativeEst__c = runningTotalEstimate;
			evs.ThisWeekTotalRemaining__c = totalAmount - runningTotal;
		}

		// At this point, we have all-new evsToUpsert[0..(n-1)] for week 1 to n of the task
		// Because these documents will be upserted based on the SnapshotKey, these "new" EVS will simply merge with existing EVS
		// Here, we mark-for-delete existing snapshots for weeks that do not fall in the range
		// But there may be other data (EV actuals, actual costs) on those EVS, 
		// so we probably need to empty the plan fields instead of deleting them.  (Keys for the snaps are based on calendar date.)
		// AND we need to renumber the "ThisWeekNumber__c"
		// SO, more to the point, we need to find all the evs that AREN'T UPSERTED and update the ThisWeekNumber__c field.
		// It MAY be then that we end up with EVS (and WRE) that "should" be deleted because the task was rescheduled (shortened).
		// But unless we're sure there are no actual costs, we need to leave well enough alone

		// AND I'm not even sure why deleting the existing EV with a mismatched SnapshotKey__c is needed -- the new one will overwrite the values

		for (EarnedValueSnapshot__c ev : existingSnaps) {
			Date wkStartDate = ev.WeekStartDate__c; //getFirstDateOfWeekFromKey(ev.SnapshotKey__c); // 
			if (wkStartDate < startDateWeekStartDay || wkStartDate > endDateWeekStartDay )
				evsOutsideTaskDates.add(ev);
			/*
			Integer evWeekIndex = ev.ThisWeekNumber__c.intValue()-1;
			if (ev.ThisWeekNumber__c > numWeeksTotal) {
				evsOutsideTaskDates.add(ev);
			} else if(evsToUpsert[evWeekIndex].SnapshotKey__c != ev.SnapshotKey__c) {
				// Handle date range changing
				evsOutsideTaskDates.add(ev);
			}
			*/
		}
		
		//system.debug('Total At End:  '+runningTotal);
		//system.debug('totalAmount:  '+totalAmount);
		
		
		returnMap.get('Upsert').addAll(evsToUpsert);
		returnMap.get('Outside').addAll(evsOutsideTaskDates);
		
		return returnMap;
	}

	private class EarnedValueException extends Exception {}

	/**
	 * Nullify Cost Curves - Remove any cost curve data from selected EarnedValueSnapshots 
	 *
	 * @Author  AECOM - Jake White
	 * @Date    2016
	 *
	 * @param	evsToUpdate - list of EarnedValueSnapshot__c to be processed
	 * @return 	
	 **/
	private static void nullifyCostCurvesAll(List<EarnedValueSnapshot__c> evsToUpdate){
		for(EarnedValueSnapshot__c evs:evsToUpdate){
			nullifyCostCurves(evs);
		}
	}
	private static void nullifyCostCurves(EarnedValueSnapshot__c evs){
			//EarnedValueSnapshot__c newEVSnap = new EarnedValueSnapshot__c();
			//evs.CurrencyISOCode = projTask.pse__Project__r.ProjectFunctionalCurrencyCode__c;
			//evs.ProjectTask__c = projTask.Id;
			//evs.CompositeKey__c = projTask.Id+'_'+weekNum;
			//evs.SnapshotKey__c = ECO_Service_Snapshots.DateToSnapshotKey(weekStartDateRunning, projTask.pse__Project__c, projTask.Id);
			//evs.WeeklyRollupEntry__r = new WeeklyRollupEntry__c(CompositeKey__c = ECO_Service_Snapshots.DateToSnapshotKey(weekStartDateRunning, projTask.pse__Project__c));
			//evs.WeekStartDate__c = weekStartDateRunning;
			//evs.ThisWeekNumber__c = weekNum;
			evs.ThisWeekAmount__c = null; // taskAmount;
			evs.ThisWeekAmountEst__c = null; // taskAmountEstimate;
			evs.ThisWeekRunningTotalAmount__c = null; //runningTotal;
			evs.ThisWeekAmountCumulativeEst__c = null; // runningTotalEstimate;
			evs.ThisWeekTotalRemaining__c = null; // totalAmount - runningTotal;
	}

	/**
	 * uniqueifyCompositeKey - Make compositekey__c unique (for calendarweek) 
	 * to avoid collisions when projectTaskStartDate changes 
	 *
	 * @Author  AECOM - Jake White
	 * @Date    2016
	 *
	 * @param	evsToUpdate - list of EarnedValueSnapshot__c to be processed
	 * @param	uniqueify - true to make unique, false to reset to taskId+'_'+weeknumber
	 * @return 	
	 **/
	private static void uniqueifyCompositeKeyAll(List<EarnedValueSnapshot__c> evsToUpdate, Boolean uniqueify){
		for(EarnedValueSnapshot__c evs:evsToUpdate){
			uniqueifyCompositeKey(evs, uniqueify);
		}
	}
	private static void uniqueifyCompositeKey(EarnedValueSnapshot__c evs, Boolean uniqueify){
			if (uniqueify) {
				evs.CompositeKey__c = evs.SnapshotKey__c ;
			} else {
				evs.CompositeKey__c = evs.ProjectTask__c + '_' + evs.ThisWeekNumber__c;
			}
	}

	/**
	 * Appply ThisWeekNumber__c - Compute ThisWeekNumber__c for selected EarnedValueSnapshots based on a ProjectTask
	 *
	 * @Author  AECOM - Jake White
	 * @Date    2016
	 *
	 * @param	evsToUpdate - list of EarnedValueSnapshot__c to be processed
	 * @param	projTask - the pse__Project_Task__c to be used for date ranges
	 * @return 	
	 **/
	private static void applyThisWeekNumberAll(pse__Project_Task__c projTask, List<EarnedValueSnapshot__c> evsToUpdate ){
		for(EarnedValueSnapshot__c evs:evsToUpdate){
			applyThisWeekNumber(projTask, evs);
		}
	}
	private static void applyThisWeekNumber(pse__Project_Task__c projTask, EarnedValueSnapshot__c evs ){
		Date day = evs.WeekStartDate__c; //getFirstDateOfWeekFromKey(evs.SnapshotKey__c); // 
		Date startDateWeekStartDay = ECO_Service_Snapshots.getFirstDateOfWeek(projTask.pse__Start_Date__c);
		Date endDateWeekStartDay = ECO_Service_Snapshots.getFirstDateOfWeek(day);
		Integer daysBetween = startDateWeekStartDay.daysBetween(endDateWeekStartDay);
		Integer numOfWeeks = (daysBetween/7) + ((daysBetween >=0 )?1:-1);
		evs.ThisWeekNumber__c = numOfWeeks;  // can be negative
	}
	
	/*
	private static Date getFirstDateOfWeekFromKey(String snapshotKey){
	    // TODO IN POST NZ WORK, replace this with adding "WeekStartDate__c from EVS__c" to the ECO_ProjectTasksSelector
	    // This is here to localize the impact of fixes to get costs prior to task approved start date working... - Jake 6/13/2016
	    String calendarWeek = ECO_Service_Snapshots.snapshotKeyvalues(snapshotKey).get('calendarWeek'); // '2016-WK1'
	    Integer yr = Integer.valueOf(calendarWeek.SubstringBefore('-WK'));
	    Integer wk = Integer.valueOf(calendarWeek.substringAfter('-WK'));
	    Date firstDayofYear = Date.newInstance(yr, 1, 1);  // January 1st of the year
	    Date firstDayOfCalWk =  ECO_Service_Snapshots.getFirstDateOfWeek(firstDayofYear.addDays(7*(wk-1)));
	    return firstDayOfCalWk;

		/* // PREWRITTEN TEST For getFirstDateOfWeekFromKey ROUTINE
		@TestMethod private static String getCalendarWeek(Date d){
		    Date dFirstDayOfWeek = ECO_Service_Snapshots.getFirstDateOfWeek(d);
		    return ECO_Service_Snapshots.getFirstDateOfWeek(d).year()+'-WK'+ECO_Service_Snapshots.getWeekNumber(dFirstDayOfWeek);
		}
		@TestMethod private static void testWeekStartfromSnapshotKey(){
			Date d0 = Date.newInstance(2015,12,25); // Friday
		    for (integer i=0;i<=16;i++){
		        Date d = d0.addDays(i);
		        System.debug(d);
		        String calWk = getCalendarWeek(d);
		        System.Debug(calWk);
		        Date d1 = ECO_Service_Snapshots.getFirstDateOfWeek(d);
		        Date d2 = getFirstDateOfWeekFromKey('PROJ__'+calWk);
		        System.debug(d1);
		        System.debug(d2);
		        System.debug('--');
		        System.AssertEquals(d1,d2);
			}
		}
		* /
	}
	*/

	
}