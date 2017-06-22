public with sharing class ECO_PMD_Chrome_Controller extends ECO_Financial_Security{

	private final sObject mysObject;
    public User theHeaderUser { get; set; }
    public String photoUrl                              { get; set; }
    public String awanJSPath                            { get; set; }
 
    public ECO_PMD_Chrome_Controller() {
        init();
    }

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public ECO_PMD_Chrome_Controller(ApexPages.StandardController stdController) {
        //stdController.addFields(new List<string>{'OracleProjectNumber__c', 'Name'});
        init();
        this.mysObject = (sObject)stdController.getRecord();
    }
    
    public string locale { get {return UserInfo.getLocale().replace('_', '-');} }

    private void init() {
        theHeaderUser = ECO_Service_Users.getUserInfoById(UserInfo.getUserId());
        awanJSPath = ECO_PortalSettings__c.getInstance().OnAWANJavascriptPath__c;
        
        if (!Test.isRunningTest()) {
            photoUrl = ConnectApi.ChatterUsers.getPhoto(null, theHeaderUser.Id).smallPhotoUrl;
        }
    } 
    
}