/** ---------------------------------------------------------------------------------------
* @Description When GBS logic pertains to more than one activity that code should be located in this class.
*
* Stakeholders:
* Jessica Fan, Stephanie Sun-Clark<br/>
* @Author AECOM - Steve MunLeeuw, Duke Ames
* @Date Oct 2016
*----------------------------------------------------------------------------------------*/
public class ECO_GBSCore{
    Boolean m_isUserGBSAdmin = null;
    Boolean m_isEditButtonEnabled = null;
    String m_requestType = null;

    SharedServicesRequest__c syncSsr = null;
	SharedServicesRequest__c ssr {get; set;}

	public ECO_GBSCore(SharedServicesRequest__c ssr){
		this.ssr = ssr;
        List<SharedServicesRequest__c> syncSsrs = [SELECT Account__r.OracleCustomerNumber__c, ReferenceSite__r.OracleCustomerNumber__c FROM SharedServicesRequest__c WHERE Id = :ssr.Id LIMIT 1];
        if(syncSsrs.size() > 0){ 
        	syncSsr = syncSsrs[0]; 
        }
	}

    public Boolean isUserGBSAdmin { get{
            if(m_isUserGBSAdmin != null){ return m_isUserGBSAdmin; } //backed by a local variable so we don't execute soql queries more than once per page flip.

            m_isUserGBSAdmin = false;

            String permSetName = 'EcoGBSAdmin';
            List<PermissionSet> permSetList = Database.query('SELECT Id FROM PermissionSet WHERE Name = :permSetName LIMIT 1');

            if (permSetList.Size() > 0) {
                String permSetId = permSetList[0].Id;
                String userId = UserInfo.getUserId();
        
                Integer recCount = database.countQuery('SELECT count() FROM PermissionSetAssignment WHERE AssigneeId = \'' + userId + '\' AND PermissionSetId = \'' + permSetId + '\'');
        
                m_isUserGBSAdmin = (recCount > 0);
            }
            return m_isUserGBSAdmin;
        }}


    /** ---------------------------------------------------------------------------------------
    * @Description addSite, updateSite are required to create a reference site, if this has been syncronized with Oracle the OracleCustomerNumber__c field is populated, 
    for all other request types we can inspect the Account__c for OracleCustomerNumber__c
    General requests don't create entities, so the answer is always false.
    *----------------------------------------------------------------------------------------*/
    public Boolean isRequestInSyncRelationship { get {
            if(requestType == 'addSite' || requestType == 'updateSite'){
                return (syncSsr == null || syncSsr.ReferenceSite__r == null) ? false : syncSsr.ReferenceSite__r.OracleCustomerNumber__c != null;
            }
            return (syncSsr == null || syncSsr.Account__r == null) ? false : syncSsr.Account__r.OracleCustomerNumber__c != null;
        }}

    public String requestType { get {
            if(m_requestType != null){ return m_requestType; } 

            if(ssr.RecordTypeId == null){ return null; }
            
            m_requestType = [SELECT DeveloperName FROM RecordType WHERE Id = :ssr.RecordTypeId LIMIT 1].DeveloperName;
            return m_requestType;
        }}

    // Edit button is enabled if status = On Hold, Pending, In-Review
    // OR
    // If status = Processing and user is GBS Team Member
    // additional criteria, not in an approval process
    public Boolean isEditButtonEnabled { get { 
            if(m_isEditButtonEnabled != null){ return m_isEditButtonEnabled; } //backed by a local variable so we don't execute soql queries more than once per page flip.

            m_isEditButtonEnabled = false;
            String status = ssr.Status__c;

            if (status == 'Pending')
            {
                m_isEditButtonEnabled = true;
            }
            else if (status == 'On Hold'
                && !isRequestInSyncRelationship)
            {
                m_isEditButtonEnabled = true;
            }
            else if (status == 'In Review'
                && !isRequestInSyncRelationship
                && !isInApprovalProcess)
            {
                m_isEditButtonEnabled = true;
            }
            else if (isUserGBSAdmin)
            {
                m_isEditButtonEnabled = true;
            }

            return m_isEditButtonEnabled;
        }}

    public String editButtonHoverText { get {
            return isEditButtonEnabled ? 
	            'Edit' : 
	            'To Edit one of the following conditions must apply:' +
	            '\\n  1) Status = Pending' +
	            '\\n  2) Status = (On Hold, In Review) and not be in a sync relationship with Oracle' + 
	            '\\n  3) You need to be a GBS Admin' +
                '\\n  4) If Status = In Review the request cannot be in an approval process' +
                '\\n  5) General Requests are only editable after submission by GBS Admins.';
        }}

    public Boolean isEditProcessingOnly { get {
                return ssr.Status__c == 'Processing'   
                    || ssr.Status__c == 'Cancelled' 
                    || isRequestInSyncRelationship 
                    || isInApprovalProcess;
    	}}

    public Boolean isInApprovalProcess { get {
            Integer count = [SELECT count() FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :ssr.Id];
            return count > 0;
        }}
}