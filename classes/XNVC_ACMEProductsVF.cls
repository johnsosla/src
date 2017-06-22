public with sharing class XNVC_ACMEProductsVF {

	public ACMEProductsVF__c record { get; set; }
	public List<AttachEntry> attachments { get; set; }
	public String selId { get; set; }
	public String backUrl { get; set; }
	
    public Map<String, List<Choice>> choices { get; set; }
    private Map<String, String> values = new Map<String, String>();

    public class Choice {
        public String value { get; set; }
        public boolean checked { get; set; }
    }
	
	public XNVC_ACMEProductsVF(ApexPages.StandardController controller) {
		record = (ACMEProductsVF__c)controller.getRecord();
		String id = record.Id;
		for (ACMEProductsVF__c[] results : [select Id,Name__c,ProductCode__c,SecondProductCode__c,Market__c,DescriptionXNRTF__c from ACMEProductsVF__c where Id = :id]) {
			if (results.size() > 0) {
				record = results[0];
			}
		}
		backUrl = EncodingUtil.urlEncode(ApexPages.currentPage().getUrl(), 'UTF-8');
		attachments = loadAttachments(record.Id);


        values.put('Name__c', record.Name__c + '');
        values.put('ProductCode__c', record.ProductCode__c + '');
        values.put('SecondProductCode__c', record.SecondProductCode__c + '');
        values.put('Market__c', record.Market__c + '');
        values.put('DescriptionXNRTF__c', record.DescriptionXNRTF__c + '');
        dynaGrab('ACMEProductsVF__c');
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

	public PageReference deleteAttachment() {
		if (selId == null || selId == '') return null;
		try {
			for (Attachment[] results : [select Id from Attachment where Id = :selId]) {
				if (results.size() > 0) {
					delete results;
					attachments = loadAttachments(record.Id);
				}
			}
		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
		}
		return null;
	}
        
	private List<AttachEntry> loadAttachments(String parent) {
		List<AttachEntry> tag = new List<AttachEntry>();
		String urlBase = System.URL.getSalesforceBaseUrl().toExternalForm();
		for (Attachment[] results : [select Id, Name, LastModifiedDate, CreatedById, CreatedBy.Name from Attachment where ParentId = :parent]) {
			for (Integer i = 0; i < results.size(); i++) {
				AttachEntry entry = new AttachEntry();
				entry.id = results[i].Id;
				entry.title = results[i].Name;
				entry.urlView = urlBase + '/' + entry.id;
				entry.urlEdit = urlBase + '/' + entry.id + '/e';
				entry.lastModified = results[i].LastModifiedDate.format();
				entry.createdByName = results[i].CreatedBy.Name;
				entry.createdByUrl = urlBase + '/' + results[i].CreatedById;
				tag.add(entry);
			}
		}
		return tag;
	}
        
	public class AttachEntry {
		public String id { get; set; }
		public String title { get; set; }
		public String urlView { get; set;}
		public String urlEdit { get; set; }
		public String lastModified { get; set; }
		public String createdByName { get; set; }
		public String createdByUrl { get; set; }
	}
	
}