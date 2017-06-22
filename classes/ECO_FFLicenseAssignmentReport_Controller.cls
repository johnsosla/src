public class ECO_FFLicenseAssignmentReport_Controller 
{
	public List<User> ffList {get; set;}

	public ECO_FFLicenseAssignmentReport_Controller()
	{
		prepareReport();
	}

	private void prepareReport()
	{
		List<UserPackageLicense> lstBase = new List<UserPackageLicense>();
		lstBase = [SELECT UserId FROM UserPackageLicense Where PackageLicense.Namespaceprefix LIKE 'pse%'];

		Set<Id> ffSet = new Set<Id>();

		for (UserPackageLicense uid: lstBase)
		{
			ffSet.add(uid.UserId);
		}	

		ffList = [SELECT Id, frm_Name__c, ECO_OrganizationName__c, IsActive, Manager_Name__c FROM User Where Id IN :ffSet];
		//AggregateResult[] countlstId = [SELECT COUNT(Id) FROM User Where Id IN :ffSet];
	}
}