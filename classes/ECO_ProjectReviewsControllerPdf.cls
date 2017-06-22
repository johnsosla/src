public with sharing class ECO_ProjectReviewsControllerPdf extends ECO_ProjectReviewsController {
	
	public String pdfFileName { get; set; }
	
	public ECO_ProjectReviewsControllerPdf(ApexPages.StandardController oStandardController) {
		super(oStandardController);
		Datetime myDatetime = Datetime.now();
		String myDatetimeStr = myDatetime.format('yyyyMMdd');
		pdfFileName = theProject.ProjectNumber__c + '_ProjectReview_' + oProjectReview.Name + '_' +  myDatetimeStr + '.pdf';
			
		if (!Test.isRunningTest()) {
			Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=' + pdfFileName);
		}		
	}
	
	public override String getProjectSnapshotRecord()
	{
		list<ProjectSnapshot__c> projectSnapshotRecords = [select Id from ProjectSnapshot__c where ProjectReview__c = :oProjectReview.Id order by Id desc];
		
		if(projectSnapshotRecords.size() > 0) {
			if (!Test.isRunningTest()) {
				return(new PageReference('/apex/ECO_ProjectSnapshot?Id='+ projectSnapshotRecords[0].Id).getContent().toString());
			} else {
				return '';
			}
		}
		
		return '';
	}
}