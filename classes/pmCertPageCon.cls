public class pmCertPageCon {
      private List<PMCertReq__c> pmcert;
    public pmCertPageCon(ApexPages.StandardController controller) {
     p = (PMCertReq__c) controller.getRecord(); 
    }
    
    public List<PMCertReq__c> getpmcert() {
        pmcert = [Select Id, Name, Candidate__c, PM_certification_Application_Link__c, Candidate_Supervisor__c, CertificationRequestStatus__c, Current_Approval_Process_Step__c From PMCertReq__c where Candidate__r.Id = :UserInfo.getUserId()];
        return pmcert;
    }
    
    public Boolean getInactiveOrBlankSupervisor() {
        User u = [Select Id, ManagerId, Manager.IsActive from User where Id = :UserInfo.getUserId()];
        return String.isBlank(u.ManagerId) || !u.Manager.IsActive;
    }

    PMCertReq__c p;
    
    public string searchValue
    {
        get
        {
            if(searchValue == null)
                searchValue = '';
            return searchValue;
        }
        set;
    }
    public Id recordId { get; set; }
   
    public List<PMCertReq__c> searchResults
    {
        get
        {
            if(searchResults == null)
                searchResults = new List<PMCertReq__c>();
            return searchResults;
        }
        set;
    }
       
   
    public void searchApplications()
    {
        if(searchValue == '')
            return;
        // Output the search value for debugging
        System.Debug('Initializing search, keyword is : ' + searchValue);       
        String finalSearchValue = '%' + searchValue + '%';
        List<PMCertReq__c> applications = new List<PMCertReq__c>();
        applications = [select Id, Name, Provisional_Status_Approved__c, PM_certification_Application_Link__c, Application_Date__c, Candidate__r.Name, Candidate__r.ECO_OrganizationName__c, Candidate_Region__c, Candidate_Geography__c, CandidateTrackingID__c, CertificationRequestStatus__c from PMCertReq__c where 
                    Candidate__r.Name like :finalSearchValue
                    OR
                    CertificationRequestStatus__c like :finalSearchValue
                    OR
                    Name like :finalSearchValue
                    OR
                    Candidate_Region__c like :finalSearchValue
                    OR
                    Candidate_Geography__c like :finalSearchValue
                    OR
                    CandidateTrackingID__c like :finalSearchValue
                    OR
                    Provisional_Status_Approved__c like :finalSearchValue
                    OR
                    Candidate__r.ECO_OrganizationName__c like :finalSearchValue];
        searchResults = applications;
    }

  //Delete Application Method 
  public PageReference deleteRow() {
  PMCertReq__c record = [Select Id from PMCertReq__c where Id = :recordId];
  delete record;

  searchApplications();

  return null;
}

}