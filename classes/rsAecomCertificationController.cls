/*************************************************************************
*
* PURPOSE: Controller for AECOM Certification Section
*
* CREATED: 2015 Ethos Solutions - www.ethos.com
* AUTHOR: Nathan Pilkington
***************************************************************************/
public with sharing class rsAecomCertificationController extends rsSectionController {

	private Boolean fetchedCertification = false;
	private PMC_CertificationRequest certificationRequest;

	//private Boolean fetchedCertificateDocument = false;
	//private Attachment certificateDocument = null;

	public rsAecomCertificationController() {
		super();
	}

	//public Boolean getHasCertificate() {
	//	Attachment a = getCertificateDocument();
	//	return a != null;
	//}

	//public String getDownloadCertificateUrl() {
	//	Attachment a = getCertificateDocument();

	//	if (a != null) {
	//		return '/servlet/servlet.FileDownload?file=' + a.Id;
	//	}

	//	return null;
	//}

	//private Attachment getCertificateDocument() {
	//	if (!fetchedCertificateDocument) {
	//		PMC_CertificationRequest req = getCertRequest();
	//		if (req != null) {
	//			String fileName = PMC_Settings__c.getOrgDefaults().Certificate_File_Name__c;
	//			List<Attachment> childAttachments = [Select Id from Attachment where ParentId = :req.obj.Id and Name = :fileName];
	//			if (childAttachments.size() > 0) certificateDocument = childAttachments.get(0);
	//		}
			
	//		fetchedCertificateDocument = true;
	//	}

	//	return certificateDocument;
	//}

	private PMC_CertificationRequest getCertRequest() {
		if (!fetchedCertification) {
			User u = profile.getUser();

			if (getIsCertified()) {
				certificationRequest = PMC_CertificationRequest.find.findApprovedRequestByUser(u.Id);
			}
			else if (getIsProvisionallyCertified()) {
				certificationRequest = PMC_CertificationRequest.find.findProvisionalRequestByUser(u.Id);
			}

			fetchedCertification = true;
		}

		return certificationRequest;
	}

	public Boolean getIsCertified() {
		User u = profile.getUser();
		return u.Certified_PM__c == 'Yes';
	}

	public Boolean getIsProvisionallyCertified() {
		User u = profile.getUser();
		return u.Certified_PM__c == 'Provisional';
	}

	public String getCertificationDate() {
		PMC_CertificationRequest certRequest = getCertRequest();

		if (certRequest != null) {
			Date certDate = null;

			if (getIsCertified()) certDate = certRequest.obj.Certification_Award_Approval_Date__c;
			else certDate = certRequest.obj.Provisional_PM_Approval_Date__c;

			return certDate == null ? null : certDate.format();
		}

		return null;
	}

	public String getExpirationDate() {
		if (getIsCertified()) {
			return ''; // Per Sharon no expiration date for certified PMs.
		}
		else if (getIsProvisionallyCertified()) {
			PMC_CertificationRequest certRequest = getCertRequest();

			if (certRequest != null) {
				Date approvalDate = certRequest.obj.Provisional_PM_Approval_Date__c;
				return approvalDate == null ? null : approvalDate.addMonths(6).format();
			}
		}
		
		return null;
	}
}