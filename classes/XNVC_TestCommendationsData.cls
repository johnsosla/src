public with sharing class XNVC_TestCommendationsData {

	public TestCommendationsData__c record { get; set; }
	public List<AttachEntry> attachments { get; set; }
	public String selId { get; set; }
	public String backUrl { get; set; }
	
    public Map<String, List<Choice>> choices { get; set; }
    private Map<String, String> values = new Map<String, String>();

    public class Choice {
        public String value { get; set; }
        public boolean checked { get; set; }
    }
	
	public XNVC_TestCommendationsData(ApexPages.StandardController controller) {
		record = (TestCommendationsData__c)controller.getRecord();
		String id = record.Id;
		for (TestCommendationsData__c[] results : [select Id,UniqueDocNumber__c,TimesModified__c,PastAuthors__c,PastEditDates__c,EditDates__c,Form__c,ValCheck__c,SaveOptions__c,StateProvCode__c,Note__c,Client__c,ClientContractNo__c,ProjectNumber__c,DoNumber__c,DOTOContractNum__c,Label__c,CommDate__c,AttachmentXNRTF__c,StateProv__c,ETName__c,SName__c,AuthorFirstName__c,AuthorLastName__c,AuthorTitle__c,Code330__c,Comments__c,LetterText__c,DocAuthor__c,ComposeDate__c,ETEmpNo__c from TestCommendationsData__c where Id = :id]) {
			if (results.size() > 0) {
				record = results[0];
			}
		}
		backUrl = EncodingUtil.urlEncode(ApexPages.currentPage().getUrl(), 'UTF-8');
		attachments = loadAttachments(record.Id);


        values.put('UniqueDocNumber__c', record.UniqueDocNumber__c + '');
        values.put('TimesModified__c', record.TimesModified__c + '');
        values.put('PastAuthors__c', record.PastAuthors__c + '');
        values.put('PastEditDates__c', record.PastEditDates__c + '');
        values.put('EditDates__c', record.EditDates__c + '');
        values.put('Form__c', record.Form__c + '');
        values.put('ValCheck__c', record.ValCheck__c + '');
        values.put('SaveOptions__c', record.SaveOptions__c + '');
        values.put('StateProvCode__c', record.StateProvCode__c + '');
        values.put('Note__c', record.Note__c + '');
        values.put('Client__c', record.Client__c + '');
        values.put('ClientContractNo__c', record.ClientContractNo__c + '');
        values.put('ProjectNumber__c', record.ProjectNumber__c + '');
        values.put('DoNumber__c', record.DoNumber__c + '');
        values.put('DOTOContractNum__c', record.DOTOContractNum__c + '');
        values.put('Label__c', record.Label__c + '');
        values.put('CommDate__c', record.CommDate__c + '');
        values.put('AttachmentXNRTF__c', record.AttachmentXNRTF__c + '');
        values.put('StateProv__c', record.StateProv__c + '');
        values.put('ETName__c', record.ETName__c + '');
        values.put('SName__c', record.SName__c + '');
        values.put('AuthorFirstName__c', record.AuthorFirstName__c + '');
        values.put('AuthorLastName__c', record.AuthorLastName__c + '');
        values.put('AuthorTitle__c', record.AuthorTitle__c + '');
        values.put('Code330__c', record.Code330__c + '');
        values.put('Comments__c', record.Comments__c + '');
        values.put('LetterText__c', record.LetterText__c + '');
        values.put('DocAuthor__c', record.DocAuthor__c + '');
        values.put('ComposeDate__c', record.ComposeDate__c + '');
        values.put('ETEmpNo__c', record.ETEmpNo__c + '');
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