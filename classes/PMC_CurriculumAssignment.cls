public class PMC_CurriculumAssignment extends PMC_BaseModel {

	public PMC_Curriculum_Assignment__c obj { get { return (PMC_Curriculum_Assignment__c)mObj; } }

	public PMC_CurriculumAssignment(PMC_Curriculum_Assignment__c sobj) {
		super(sobj);
	}


	public String getKey() {
		String result = '';

		if (obj.Super_Geo__c != null) result += obj.Super_Geo__c;
		if (obj.Geo__c != null) result += '|' + obj.Geo__c;
		if (obj.Country__c != null) result += '|' + obj.Country__c;

		return result;
	}

	public static Boolean jobIdMatchesCurriculumMapping(String jobId) {
		List<PMC_CurriculumAssignment> assignments = decorate(PMC_Curriculum_Assignment__c.getAll().values());

		Boolean foundMatch = false;

		for (PMC_CurriculumAssignment row : assignments) {
			if (row.obj.Job_Id__c  == jobId || row.obj.Renewal_Job_ID__c == jobId) {
				foundMatch = true;
			}
		}

		return foundMatch;
	}


	public static PMC_Curriculum_Assignment__c getAssignmentForCandidate(User u) {
		List<PMC_CurriculumAssignment> assignments = decorate(PMC_Curriculum_Assignment__c.getAll().values());

		PMC_Curriculum_Assignment__c result = null;

		PMC_CurriculumAssignment superGeoMatch = null;
		PMC_CurriculumAssignment geoMatch = null;
		PMC_CurriculumAssignment countryMatch = null;

		// Match on the most specific geography combination that we can find.
		for (PMC_CurriculumAssignment assignment : assignments) {
			List<String> superGeos =  assignment.obj.Super_Geo__c == null ? new List<String>() : assignment.obj.Super_Geo__c.split(',');
			List<String> geos = assignment.obj.Geo__c == null ? new List<String>() : assignment.obj.Geo__c.split(',');
			List<String> countries = assignment.obj.Country__c == null ? new List<String>() : assignment.obj.Country__c.split(',');

			if (countries.size() > 0) {
				for (String country : countries) {
					if (PMC_StringUtils.stringIContains(u.Country, country)) {
						countryMatch = assignment;
					}
				}
			}
			if (countryMatch == null && geos.size() > 0 && countries.size() == 0) {
				// Only try to match on geo if this mapping does not have any countries
				for (String geo : geos) {
					if (PMC_StringUtils.stringIContains(u.Geography__c, geo)) {
						System.debug('Found geo match: ' + assignment.obj.Geo__c);
						geoMatch = assignment;
					}
				}
			}
			if (countryMatch == null && geoMatch == null && superGeos.size() > 0 && geos.size() == 0 && countries.size() == 0) {
				// Only try to match on supergeo if this mapping does not have any geos/countries
				for (String superGeo : superGeos) {
					if (PMC_StringUtils.stringIContains(u.Supergeography__c, superGeo)) {
						superGeoMatch = assignment;
					}
				}
			}
		}


		if (superGeoMatch != null) {
			result = superGeoMatch.obj;
		}
		if (geoMatch != null) {
			result = geoMatch.obj;
		}
		if (countryMatch != null) {
			result = countryMatch.obj;
		}

		return result;
	}

	public static List<PMC_CurriculumAssignment> decorate(List<PMC_Curriculum_Assignment__c> sList) {
		List<PMC_CurriculumAssignment> result = new List<PMC_CurriculumAssignment>();
		for (PMC_Curriculum_Assignment__c row : sList) result.add(new PMC_CurriculumAssignment(row));
		return result;
	}
}