public with sharing class ECO_CreateHelpTextController {
	public ECO_CreateHelpTextController() {
	}

	public PageReference go() {
		String helpName = ApexPages.currentPage().getParameters().get('helpName');
		helpName = EncodingUtil.urlDecode(helpName, 'UTF-8');

		List<HelpText__c> messages = [select id from HelpText__c where name = :helpName limit 1];
		if ((messages != null) && (messages.size() > 0))
			return new PageReference('/' + messages[0].id + '/e');

		HelpText__c message = new HelpText__c();
		message.name = helpName;
		message.Message__c = '*** UNDEFINED ***';

		insert message;

		return new PageReference('/' + message.id + '/e');
	}
}