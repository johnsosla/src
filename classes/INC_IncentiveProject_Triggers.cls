public with sharing class INC_IncentiveProject_Triggers {

	public INC_IncentiveProject_Triggers() {
		
	}

	public void checkForKeyMetricChanges(map<id,IncentiveProject__c>mapNew, map<id,IncentiveProject__c> mapOld){
		System.Debug(logginglevel.error,'check for changes');
		set<id> setIncentivesChanges = INC_Service_EnrollmentPlan.checkMetricChanges(mapNew,mapOld);
		List<EnrollmentPlan__c> listChangedEnroll = new list<EnrollmentPlan__c>();
		
		Map<id,map<id,date>> mapIncDateChanged = checkDateChanges(mapNew,mapOld);
		set<id> setAllIncentiveProjects = new set<id>();
		setAllIncentiveProjects.addAll(setIncentivesChanges);
		setAllIncentiveProjects.addAll(mapIncDateChanged.keySet());

		System.debug(logginglevel.error,'setIncentivesChanges: ' + setAllIncentiveProjects);
		if(setAllIncentiveProjects != null && setAllIncentiveProjects.size() > 0){
			System.debug(logginglevel.error,'before select: ');
			
			for(EnrollmentPlan__c Enroll: [Select id
														   , MetricWarningActive__c
														   , ScheduledFinishDateStamp__c
														   , EnrollmentStatus__c
														   , IncentiveProject__c
												  From EnrollmentPlan__c
												  Where IncentiveProject__c =: setAllIncentiveProjects]){
				boolean bChanged = false;
				if(setIncentivesChanges.Contains(Enroll.IncentiveProject__c)){
					Enroll.MetricWarningActive__c = 'Yes';
					bChanged = true;
				}

				System.debug(logginglevel.error,'mapIncDateChanged: ' + mapIncDateChanged.containsKey(Enroll.IncentiveProject__c) + ' ' + Enroll.IncentiveProject__c);
				
				if(mapIncDateChanged.containsKey(Enroll.IncentiveProject__c)){
					System.debug(logginglevel.error,'status: ' + Enroll.EnrollmentStatus__c);
					if(Enroll.EnrollmentStatus__c == 'Enrolled'){
						Enroll.ScheduledFinishDateStamp__c = mapIncDateChanged.get(Enroll.IncentiveProject__c).get(Enroll.ID);
						bChanged = true;
					}
				}

				if(bChanged){
					listChangedEnroll.add(Enroll);
				}
			
			}

			if(listChangedEnroll != null && listChangedEnroll.size() > 0){
				INC_Service_EnrollmentPlan.updateEnrollmentApplications(listChangedEnroll);
			}
		}
	}
	
	public void checkForBaselineChanges(map<id,IncentiveProject__c>mapNew, map<id,IncentiveProject__c> mapOld){
		System.debug(logginglevel.error,'checking for baseline: ');
			
		set<id> setEnrollmentPlans = new set<id>();
		for(IncentiveProject__c ip: mapNew.Values()){
			System.debug(logginglevel.error,'approved old: ' + mapOld.get(ip.id).ApprovedGrossMarginBudget__c);
			System.debug(logginglevel.error,'approved new: ' + ip.ApprovedGrossMarginBudget__c);
			
			if((ip.ApprovedGrossMarginBudget__c != mapOld.get(ip.id).ApprovedGrossMarginBudget__c) ||
			   (ip.ApprovedNetMarginBudget__c != mapOld.get(ip.id).ApprovedNetMarginBudget__c)){
			   	if(ip.EnrollmentPlan__c != null){
					setEnrollmentPlans.add(ip.EnrollmentPlan__c);
				}
			}
		}
		System.Debug(logginglevel.error,'setEnrollmentplans: ' + setEnrollmentplans);
		INC_Service_EnrollmentPlan.updateBaselineChangedFlagforParticipants(setEnrollmentplans);
	}
	public map<id,map<id,Date>> checkDateChanges(map<id,IncentiveProject__c>mapNew, map<id,IncentiveProject__c>mapOld){

		map<id,map<id,Date>> mapReturn = new map<id,map<id,Date>>();
		map<id,Date> mapTemp = new map<id,Date>();

		for(IncentiveProject__c IP: mapNew.Values()){
			System.debug(logginglevel.error,'ScheduledFinishDate__c: ' + IP.ScheduledFinishDate__c + ' / ' + mapOld.get(IP.ID).ScheduledFinishDate__c);
			if(IP.ScheduledFinishDate__c != mapOld.get(IP.ID).ScheduledFinishDate__c){
				mapTemp = new map<id,Date>();
				mapTemp.put(IP.EnrollmentPlan__c,ip.ScheduledFinishDate__c);
				mapReturn.put(IP.ID,mapTemp);
			}
		}
		System.debug(logginglevel.error,'check Date Changes ' + mapReturn);
		return mapReturn;

	}

}