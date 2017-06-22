public with sharing class ECO_PDFViewerController {
	public String path {get; set;}
	public String bookmarkPrefix {get; set;}

	public ECO_PDFViewerController() {
		path = ApexPages.currentPage().getParameters().get('path');
		bookmarkPrefix = ApexPages.currentPage().getParameters().get('bmpx');
	}
}