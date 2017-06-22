global class ECO_AgreementControllerPdf extends ECO_AgreementController {

	public String pdfFileName  {get;set;}
	
    public ECO_AgreementControllerPdf(ApexPages.standardController sc)
    {
        super(sc);

		Datetime myDatetime = Datetime.now();
		String myDatetimeStr = myDatetime.format('yyyyMMdd');
		
		agreement = ECO_Service_Agreement.getAgreementFromId(agreement.Id);  

        project = ECO_Service_Agreement.getProjectFromId(agreement.Project__c); 

		pdfFileName = project.ProjectNumber__c + '_Agreement_' + agreement.Name + '_' + myDatetimeStr + '.pdf';
		
		if (!Test.isRunningTest()) {
			Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=' + pdfFileName);
		}		
    }
    
}