public class PMC_ControlPanel_Controller {

	public PMC_ControlPanel_Controller() {
		
	}

	public PageReference startDrawloopBatch() {

		try {
			System.schedule('PMC CertificateGeneration 1', '0 0 * * * ?', new PMC_CertificateGeneration_Job());
			System.schedule('PMC CertificateGeneration 2', '0 15 * * * ?', new PMC_CertificateGeneration_Job());
			System.schedule('PMC CertificateGeneration 3', '0 30 * * * ?', new PMC_CertificateGeneration_Job());
			System.schedule('PMC CertificateGeneration 4', '0 45 * * * ?', new PMC_CertificateGeneration_Job());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Batch jobs started'));
		}
		catch (Exception e) {
			String errMessage = 'Error while starting batch jobs: ' + e.getMessage() + ' -- \n' + e.getStackTraceString();
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errMessage));
		}
	
		return null;
	}	
}