public with sharing class XNNC_TestCommendationsData {

	public TestCommendationsData__c record { get; set; }

    public Map<String, List<Choice>> choices { get; set; }
    private Map<String, String> values = new Map<String, String>();

    public class Choice {
        public String value { get; set; }
        public boolean checked { get; set; }
    }

	public XNNC_TestCommendationsData(ApexPages.StandardController controller) {
		record = new TestCommendationsData__c();

        dynaGrab('TestCommendationsData__c');
	}

    private void dynaGrab(String objName) {
        choices = new Map<String, List<Choice>>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult dsor = null;
        for (String key : gd.keySet()) {
          if (key.endsWith(objName.toLowerCase())) {
            dsor = gd.get(key).getDescribe();
          }
        }
        if (dsor == null) return;
        Map<String, Schema.SObjectField> mapFields = dsor.fields.getMap();
        for (String key : mapFields.keySet()) {
            Schema.DescribeFieldResult dfr = mapFields.get(key).getDescribe();
            if (dfr.getType() != Schema.DisplayType.Picklist && dfr.getType() != Schema.DisplayType.MultiPicklist) {
                continue;
            }
            List<Choice> items = new List<Choice>();
            String tval = '';
            if (values.containsKey(dfr.getLocalName())) {
                tval = values.get(dfr.getLocalName());
            }
            String[] tvals = tval.split(';');
            List<Schema.PicklistEntry> entries = dfr.getPicklistValues();
            for (Integer i = 0; i < entries.size(); i++) {
                Choice c = new Choice();
                c.value = entries[i].getLabel();
                if (dfr.getType() == Schema.DisplayType.Picklist) {
                    c.checked = c.value == tval;
                } else {
                    c.checked = find(c.value, tvals);
                }
                items.add(c);
            }
            choices.put(dfr.getLocalName(), items);
        }
    }

    private boolean find(String src, List<String> items) {
        for (Integer i = 0; i < items.size(); i++) {
            if (items[i].trim() == src.trim()) return true;
        }
        return false;
    }

	public PageReference save() {
		insert record;
		return new PageReference('/' + record.Id);
	}

    public static testMethod void testNew() {
        Test.setCurrentPage(Page.XNNP_TestCommendationsData);
        TestCommendationsData__c record = new TestCommendationsData__c();
        XNNC_TestCommendationsData controller = new XNNC_TestCommendationsData(new ApexPages.StandardController(record));
        controller.save();
    }

    public static testMethod void testEdit() {
        Test.setCurrentPage(Page.XNEP_TestCommendationsData);
        TestCommendationsData__c record = new TestCommendationsData__c();
        insert record;
        String attachId = createAttachment(record.Id);
        XNEC_TestCommendationsData controller = new XNEC_TestCommendationsData(new ApexPages.StandardController(record));
        controller.selId = attachId;
        controller.deleteAttachment();
        controller.save();
    }

    public static testMethod void testView() {
        Test.setCurrentPage(Page.XNVP_TestCommendationsData);
        TestCommendationsData__c record = new TestCommendationsData__c();
        insert record;
        String attachId = createAttachment(record.Id);
        XNVC_TestCommendationsData controller = new XNVC_TestCommendationsData(new ApexPages.StandardController(record));
        controller.selId = attachId;
        controller.deleteAttachment();
    }

    private static String createAttachment(String id) {
        Attachment at = new Attachment();
        at.ParentId = id;
        at.Description = 'Test';
        at.Name = 'Test';
        at.Body = Blob.valueOf('Test');
        insert at;
        return at.Id;
    }

}