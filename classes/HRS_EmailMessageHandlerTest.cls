/**
* @author Brian Lau
* @version 1.0
* @description COMPONENT: HRS eConnect (HRS)
*              CLASS: HRS_EmailMessageHandlerTest
*              PURPOSE: Test class for HRS_EmailMessageTrigger
*              CREATED: 02/2017 Ethos Solutions - www.ethos.com
**/
@isTest
private class HRS_EmailMessageHandlerTest {
	
	@isTest static void testBeforeInsert() {
		sshCustomSettings.CaseTriggerSettings settings = sshCustomSettings.getCaseTriggerSettings();
		ECO_IntegrationEndpoints__c endpoint = new ECO_IntegrationEndpoints__c();
		endpoint.Name = 'HRS_EMPLOYEE';
		endpoint.EndPointUrl__c = 'test';
		insert endpoint;
		Contact con = new Contact(FirstName='test', LastName='Test', Email='test@aecom.com');
		insert con;
		Case cs = new Case(RecordTypeId = sshUserContactUtils.getRecordTypeIdByName('HR_Exit_Management'), ContactId=con.Id);
		insert cs;

		EmailMessage message = new EmailMessage(ToAddress='test@aecom.com', ParentId = cs.Id);
		try {
			insert message;
		} catch(Exception e) {
			System.assert(e.getMessage().containsIgnoreCase('Recipient is employee to be terminated'));
		}
	}
	
	
}