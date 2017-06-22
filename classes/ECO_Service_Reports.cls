public without sharing class ECO_Service_Reports {
	public static List<Configuration__c> getReportsForUser (Id userId) {
		return [SELECT Id
						, ReportId__c
						, ReportName__c 
						, User__c
						, RecordTypeId
						, UserSortOrder__c
						, RecordType.DeveloperName
				FROM Configuration__c
				WHERE User__c = :userId
					AND RecordType.DeveloperName = 'Report'
					ORDER BY UserSortOrder__c ASC];
	}
}