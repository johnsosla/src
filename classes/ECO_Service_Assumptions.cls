public with sharing class ECO_Service_Assumptions {

	public static list<Assumption__c> getAssumtionsForProject(Id sProjectId, string sPlanElement){
		string sSOQL = 'SELECT Id, Name, PlanElement__c, Assumption__c FROM Assumption__c WHERE Project__c =\'' + sProjectId + '\'';
            
        if(ECO_Utils_String.NullCheck(sPlanElement) != ''){
            sSOQL += ' and PlanElement__c = \'' + sPlanElement + '\'';
        }

        sSOQL += ' ORDER BY PlanElement__c';

         return (list<Assumption__c>)Database.query(sSOQL);
	}

	public static list<Assumption__c> getAssumtionsForProject(Id sProjectId){
		return ECO_Service_Assumptions.getAssumtionsForProject(sProjectId, null);
	}
}