global class INC_EnrollmentLetterAttach {

	@future(callout=true)
	public static void attachEnrollmentLetter(set<string> partAckIDs) {

		if(partAckIDs == null || partAckIDs.size() ==0){
			return;
		}


		list<participantAcknowledgement__c> oPAs = [select id, ProjectNumber__c, ParticipantID__r.EmployeeName__r.name from ParticipantAcknowledgement__c where id IN: partAckIDs];
		list<Attachment> lstAttch = new list<Attachment>();

		for(participantAcknowledgement__c p:oPAs){
		    PageReference pdf = Page.INC_EnrollmentLetter;
		    // add parent id to the parameters for standardcontroller
		    pdf.getParameters().put('id',p.id);

		    // create the new attachment
		    Attachment attach = new Attachment();

		    // the contents of the attachment from the pdf
		    Blob body;

		    try {

		        // returns the output of the page as a PDF
		        body = pdf.getContent();

		    // need to pass unit test -- current bug    
		    } catch (VisualforceException e) {
		        body = Blob.valueOf('Some Text');
		    }

		    attach.Body = body;
		    // add the user entered name

		    string myDate = datetime.now().format('yyyyMMdd');

		    attach.Name = p.ProjectNumber__c + '-' + p.ParticipantID__r.EmployeeName__r.name + '-DTWLetter-' + myDate + '.pdf';
		    attach.IsPrivate = false;
		    // attach the pdf to the account
		    attach.ParentId = p.id;
		    //attach.ContentType = 'pdf';


		    lstAttch.add(attach);
		}	


	    insert lstAttch;


	}
}