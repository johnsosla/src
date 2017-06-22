global class INC_IncentiveProjectCreateEnrollment {


	webservice static boolean createEnrollmentForm(ID sIncentiveID){
		System.Debug(logginglevel.error,'create enrollment form start.');
		boolean bReturn = INC_Service_EnrollmentPlan.EnrollmentProcesses(new set<id>{sIncentiveID});
		return bReturn;
	}

	webservice static boolean reviveEnrollmentForm(ID sIncentiveID){
		System.Debug(logginglevel.error,'create enrollment form start.');
		boolean bReturn = INC_Service_EnrollmentPlan.EnrollmentProcesses(new set<id>{sIncentiveID},true);
		return bReturn;
	}
/*
	webservice static string cloneEnrollmentForm(ID CurrentEnrollmentApp){
		return INC_Service_EnrollmentPlan.cloneEnrollment(CurrentEnrollmentApp);
	}
*/	
}