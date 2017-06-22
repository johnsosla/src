public class PMC_AttachmentsList_Controller {

	public Id parentId { get; set; }
	public String attachmentId { get; set; }

	public PMC_AttachmentsList_Controller(ApexPages.StandardController sc) {
		parentId = sc.getId();
	}

	public PageReference deleteAttachment() {
		Attachment a = new Attachment(Id=attachmentId);
		delete a;

		return null;
	}

	public List<Attachment> getAttachments() {
		return [Select Id, Name, LastModifiedDate, CreatedById from Attachment where ParentId = :parentId];
	}
}