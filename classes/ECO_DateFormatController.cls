public with sharing class ECO_DateFormatController {
	public Date theDate {get; set;}

	public String formattedDate {
		get {
			return (theDate == null) ? null : theDate.format().replace('/', '-');
		}

		private set;
	}
}