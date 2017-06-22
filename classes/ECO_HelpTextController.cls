public with sharing class ECO_HelpTextController {
	private static transient Set<String> helpIds;
	private static transient Map<String, HelpText__c> helpValues {get; set;}

	public static Boolean editMode {get; set;}

	static {
		helpIds = new Set<String>();

		Schema.DescribeSObjectResult helpTextDescribe = HelpText__c.sObjectType.getDescribe();
		editMode = helpTextDescribe.isUpdateable();
	}

	public String render {
		get;

		set {
			if (helpValues == null) {
				helpValues = new Map<String, HelpText__c>();

				List<HelpText__c> messages = [select id, name, Message__c, FrMessage__c from HelpText__c where name in :helpIds];

				for (HelpText__c message : messages) {
					helpValues.put(message.name, message);
				}
			}
		}
	}

	public String theHelpId {
		get;

		set {
			theHelpId = value;

			helpIds.add(value);
		}
	}

	public String helpValue {
		get {
			if (helpValues == null)
				return null;

			HelpText__c helpText = helpValues.get(theHelpId);
			if (helpText == null)
				return null;
			String sField = ECO_Service_MasterDataTranslation.translatedField('HelpText__c', 'Message__c');
			//return helpText.Message__c;
			if(String.valueOf(helpText.get(sField)) != null){
				return String.valueOf(helpText.get(sField));
			}else{
				return helpText.Message__c;	
			}
			
		}
	}

	public String helpEditId {
		get {
			if (helpValues == null)
				return null;

			HelpText__c helpText = helpValues.get(theHelpId);
			if (helpText == null)
				return null;

			return helpText.id;
		}
	}

	public ECO_HelpTextController() {
	}
}