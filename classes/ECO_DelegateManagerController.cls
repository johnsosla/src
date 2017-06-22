/** ------------------------------------------------------------------------------------------------------
* @Description Controller for the ECO_DelegateManager Visualforce Page
*
* @Author      NTT Data - Aaron Pettitt
* @Date        2015
*-----------------------------------------------------------------------------------------------------*/
public class ECO_DelegateManagerController {
    public Contact contact {get; set;} //contact details for the selected contact
    public Boolean isError {get; set;} //if the page is in an error condition
    public Delegate__c delegate {get; set;} //the new delegate record to be added
    public Map<String, Id> delegateRecordTypeMap {get; set;}//map to store the record type name to the id for the delegate object
    public ECODelegateCurrLimit__c delegateLimitSettings{get; set;}//the delegate limit setting amounts for the current contact
    public List<RecordType> recordTypes{get; set;}//the list of recordTypes for the Delegate object
    public String agreementAmountBypass{get; set;}
    public String agreementAmountBypassLT{get; set;}
    public String projectRevenueBudgetBypass{get; set;}
    public String projectRevenueBudgetBypassLT{get; set;}
    public String backlogValueBypass{get; set;}
    public String backlogValueBypassLT{get; set;}
    public String projectNetMarginValueBypass{get; set;}
    public String projectNetMarginValueBypassLT{get; set;}
    public String projectNetMarginNSRBypass{get; set;}
    public String projectNetMarginNSRBypassLT{get; set;}
    public String percentageChangeInForecastBypass{get; set;}
    public String percentageChangeInForecastBypassLT{get; set;}
    public String valueChangeInForecastNetMarginBypass{get; set;}
    public String valueChangeInForecastNetMarginBypassLT{get; set;}
    public List<owningOrganization> owningOrganizations{get; set;}
    public String c0Bypass{get; set;}
    public String c1Bypass{get; set;}
    public String c2Bypass{get; set;}
    public String c3Bypass{get; set;}
    public String c4Bypass{get; set;}
    public Boolean canEdit{get; set;}
    public Boolean isAdmin{get; set;}
    public Attachment attachment{get; set;}
    public ECO_Delegate_User_Preferences__c userPreferences{get; set;}
    public List<Delegate__c> delegates{get; set;}
    private ApexPages.StandardController controller;
    private Id keyRolesRecordType;
    private String redirectUrl;  //stores the url of the page to return to
    private String contactId; //stores the contactId from the query parameter
    private String query; //stores the contact query text
    private Id alternateRecordType;
    private List<PermissionSetAssignment> currentUserPermissionSets = new List<PermissionSetAssignment>(); //a list of the current logged in user permission sets
    private List<GroupMember> currentUserGroups = new List<GroupMember>(); //a list of the current logged in user groups
    public Set<String> sGroupNames = new Set<String>();
    public List<ECO_DelegationAdminOUCheck__c> lCustomSettings = new List<ECO_DelegationAdminOUCheck__c>();
    public Contact oContact;

    /**
     * Constructor
     *   
     * @Author  NTT Data
     * @Date    July 2016
     *
     **/
    public ECO_DelegateManagerController(ApexPages.StandardController standardController){
        isError = false;
        canEdit = false;
        isAdmin = false;
        this.controller = standardController; 

        //contact oContact = (contact)standardController.getRecord();


        recordTypes = [Select Id, Name, DeveloperName from RecordType where SobjectType = 'Delegate__c'];
        for(RecordType recordType : recordTypes){
            if(recordType.DeveloperName == 'Key_Roles'){
                keyRolesRecordType = recordType.Id;
            }
            else if(recordType.DeveloperName == 'Alternate'){
                alternateRecordType = recordType.Id;
            }
        }
        currentRecordType = 'Key Roles';

        if(ApexPages.currentPage().getParameters().get('retUrl') != null){
            redirectUrl = ApexPages.currentPage().getParameters().get('retUrl');
        }

        if(ApexPages.currentPage().getParameters().get('contactId') != null){
            contactId = ApexPages.currentPage().getParameters().get('contactId');
        }
        
        //retrieve the record types for the tab panel
        delegateRecordTypeMap = new Map<String, Id>();
        
        for(RecordType recordType : recordTypes){
            delegateRecordTypeMap.put(recordType.Name, recordType.Id);
        }


        //look to see if the current user is in the appropriate permission set
        try{

            oContact = [select id, pse__Salesforce_User__r.DefaultCurrencyIsoCode, pse__Salesforce_User__r.ECO_OUID__c from contact where id=: contactId];

            currentUserPermissionSets = [select PermissionSet.Name from PermissionSetAssignment where Assignee.Id =: UserInfo.getUserId() AND PermissionSet.Name = 'ECO_Delegations_Adminstrator'];
            currentUserGroups = [SELECT GroupId, Id, UserOrGroupId, Group.Name  FROM GroupMember where UserOrGroupId =:UserInfo.getUserId() AND Group.Name LIKE 'ECODelegate%' ];
            if(currentUserGroups != null && currentUserGroups.size()>0){
                for(GroupMember gm : currentUserGroups){
                    sGroupNames.add(gm.Group.Name);
                }
                if(sGroupNames != null && sGroupNames.size() >0 && oContact.pse__Salesforce_User__r.ECO_OUID__c != null){
                    lCustomSettings = [Select Id From ECO_DelegationAdminOUCheck__c Where Group__c IN :sGroupNames AND OU_Id__c = :oContact.pse__Salesforce_User__r.ECO_OUID__c];
                    
                }
            }

            if((currentUserPermissionSets != null && currentUserPermissionSets.size() > 0) || (lCustomSettings != null && lCustomSettings.size()>0)){
                canEdit = true;
                isAdmin = true;
            }
        }
        catch(Exception ex){
            //this user doesn't have the required permission set
        }

        if(canCreateAlternate){
            canEdit = true;
        }

        if(!canEdit && contactId != null){
            checkIfAlternate();
        }

        //retrieve contact and delegates info
        try{
            //retrieve the delegate amount limits
            /*if(contact.pse__Salesforce_User__c != null && ECO_DelegateManagerLimits__c.getInstance(contact.pse__Salesforce_User__c) != null){
                delegateLimitSettings = ECO_DelegateManagerLimits__c.getInstance(contact.pse__Salesforce_User__c);
            }
            else{
                delegateLimitSettings = ECO_DelegateManagerLimits__c.getOrgDefaults();
            }*/

            //contact oContact = [select id, pse__Salesforce_User__r.DefaultCurrencyIsoCode from contact where id=: contactId];
            delegateLimitSettings = ECODelegateCurrLimit__c.getValues(oContact.pse__Salesforce_User__r.DefaultCurrencyIsoCode);
        }
        catch(Exception ex){
            isError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The contact Id is either null or invalid. ' + ex.getMessage()));
            system.debug(ex.getMessage());
        }
    }

    /**
     *   
     * @Author  NTT Data
     * @Date    July 2016
     *
     **/
    public pagereference ConfirmDelegationReview(){
        contact.ReviewedDelegation__c = true;

        try{
            update contact;
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error while trying to update contact. ' + ex.getMessage()));
        }


        return null;
    }

    /**
     * the current record type selected on the tab
     *   
     * @Author  NTT Data
     * @Date    July 2016
     *
     **/
    public String currentRecordType {
        get;
        set{
            currentRecordType = value;
            Id recordTypeId;
            if(delegateRecordTypeMap == null){
                RecordType recordType = [Select Id, Name, DeveloperName 
                                            from RecordType 
                                            where SobjectType = 'Delegate__c' 
                                            AND Name =: currentRecordType];
                recordTypeId = recordType.Id;
            }
            else{
                recordTypeId = delegateRecordTypeMap.get(currentRecordType);
            }
            if(ApexPages.currentPage().getParameters().get('contactId') != null){
                contactId = ApexPages.currentPage().getParameters().get('contactId');
            }
            queryContact(recordTypeId);
        }
    }


    /**
     * returns the current user's currency format
     *   
     * @Author  NTT Data
     * @Date    July 2016
     *
     **/
    public String currentCurrency{
        get{
            return UserInfo.getDefaultCurrency();
        }
        set;
    }

    /**
     * returns the select options for the yes/no radio buttons
     *   
     * @Author  NTT Data
     * @Date    July 2016
     *
     **/
    public List<SelectOption> yesNoOptions{
        get{
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('Yes', 'Yes'));
            options.add(new SelectOption('No', 'No'));
            return options;
        }
        set;
    }

    /**
     * if the current user can create an alternate delegate for themself
     *   
     * @Author  NTT Data
     * @Date    July 2016
     *
     **/
    public Boolean canCreateAlternate{
        get{
            if(contact != null && UserInfo.getUserId() == contact.pse__Salesforce_User__c){
                return true;
            }
            return false;
        }
        set;
    }

    /**
     * button function to return to contact 
     *   
     * @Author  NTT Data
     * @Date    July 2016
     *
     **/
    public PageReference backToContact(){
        if(contactId != null){
            return new PageReference('/' + contactId);
        }
        return new PageReference('/' + UserInfo.getUserId());
    }

    /**
     * sets the currentRecordType viewstate variable to the proper recordtype for the tab panel.
     *   
     * @Author  NTT Data
     * @Date    July 2016
     *
     **/
    public PageReference changeTabFields(){
        String recordTypeId = ApexPages.currentPage().getParameters().get('recordTypeId');
        for(String delegateRecordType : delegateRecordTypeMap.keySet()){
            if(delegateRecordTypeMap.get(delegateRecordType) == recordTypeId){
                currentRecordType = delegateRecordType;
            }
        }
        queryContact(recordTypeId);
        return null;
    }


    /**
     * stores the setting of the user's preferences for the bypass defaults
     *   
     * @Author  NTT Data
     * @Date    July 2016
     *
     **/
    public PageReference setDefaultBypassDefaults(){
        if(userPreferences == null){
            userPreferences = new ECO_Delegate_User_Preferences__c(Name = UserInfo.getUserId(), Default_Delegate_Bypass_to_No__c = true);
        }
        else{
            if(userPreferences.Default_Delegate_Bypass_to_No__c){
                userPreferences.Default_Delegate_Bypass_to_No__c = false;
            }
            else{
                userPreferences.Default_Delegate_Bypass_to_No__c = true;
            }
        }
        upsert userPreferences;
        resetBypassYesNoFields();
        return null;
    }

    /**
     * adds a new delegate entry for the contact
     *   
     * @Author  NTT Data
     * @Date    July 2016
     *
     **/
    public PageReference addNewDelegate(){
        Savepoint savePoint = Database.setSavepoint();
        try{
            setYesNoFieldValues();
            delegate.recordTypeId = delegateRecordTypeMap.get(currentRecordType);

            if(isValid()){
                Boolean anyOrgChecked = false;
                //save all of the selected organizations
                if(delegate.recordTypeId == keyRolesRecordType && owningOrganizations.size() > 0){
                    delegate.Allowed_Organizations__c = '';
                    
                    for(owningOrganization organization : owningOrganizations){
                        if(organization.checked){
                            delegate.Allowed_Organizations__c += organization.organization.Id + ';';
                            anyOrgChecked = true;
                        }
                    }
                }
                else{
                    anyOrgChecked = true;
                }

                if(anyOrgChecked){

                    if(isAdmin){
                        delegate.CreatedbyAdmin__c = true;
                    }

                    insert delegate;
                    /*if(currentRecordType == 'Administrator Override' && attachment.body != null){
                        attachment.OwnerId = UserInfo.getUserId();
                        attachment.ParentId = delegate.Id;
                        attachment.IsPrivate = true;
                        insert attachment;
                    }*/
                    sendApprovalProcess(delegate);
                    queryContact(delegateRecordTypeMap.get(currentRecordType));
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least one organization for the key member'));
                }
            }
        }
        catch(Exception ex){
            //we don't want to have duplicate error messages on the page
            if(!ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error Inserting Delegate: ' + ex.getMessage()));
            }
            Database.rollback(savePoint);
        }

        try{
            if(currentRecordType == 'Key Roles'){
                contact.ContactHasDelegates__c = true;
                update contact;
            }
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error Updating Contact: ' + ex.getMessage()));
            Database.rollback(savePoint);
        }

        return null;
    }

    /**
     * look to see if the current user is an alternate delegate for the selected contact
     *   
     * @Author  NTT Data
     * @Date    July 2016
     *
     **/
    @TestVisible
    private void checkIfAlternate(){
        try{
            List<Delegate__c> delegates = [Select Id, name, Delegate__c, Delegate__r.pse__Salesforce_User__c, Approval_Status__c from Delegate__c where Delegator__c =: contactId AND RecordType.Name = 'Administrator Override'];
            for(Delegate__c delegate : delegates){
                if(delegate.Delegate__r.pse__Salesforce_User__c == UserInfo.getUserId()){
                    canEdit = true;
                }
            }
        }
        catch(Exception ex){
            //this person doesn't have any alternates defined
        }
    }


    /**
     * sends the approval process for a new Delegate record
     *   
     * @Author  NTT Data
     * @Date    July 2016
     *
     **/
    @TestVisible 
    private void sendApprovalProcess(Delegate__c delegate){
        Approval.ProcessSubmitRequest newPendingRequest = new Approval.ProcessSubmitRequest();
        newPendingRequest.setObjectId(delegate.Id);
        if(isAdmin){
            newPendingRequest.setProcessDefinitionNameOrId('ECODelegateDelegationApprovalAdmin');
        } else {
            //newPendingRequest.setProcessDefinitionNameOrId('ECO_Delegate_Delegation_Approval2');
            newPendingRequest.setProcessDefinitionNameOrId('ECODelegateApproval5');
            newPendingRequest.setSkipEntryCriteria(true);
        }
        Approval.ProcessResult processResult = Approval.process(newPendingRequest);
    }


    /**
     * sets the delegate limits to the settings custom settings limits
     *   
     * @Author  NTT Data
     * @Date    July 2016
     *
     **/
    public PageReference setLimitsToSettingsLimits(){
        delegate.Agreement_Amount_estimated__c = delegateLimitSettings.Agreement_Amount__c;
        return null;
    }

    /**
     * verifies the limit values are less than the maximum amount
     *   
     * @Author  NTT Data
     * @Date    July 2016
     *
     **/
    @TestVisible
    private Boolean isValid(){
        Boolean valid = true;

        list<contact> lstContact = [select id from contact where pse__Salesforce_User__c =: userinfo.getUserId() limit 1];
        if(!lstContact.isempty()){
            if(delegate.Delegate__c == lstContact[0].id){
                valid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot add yourself as a delegate'));
            }
        }
        
        if(currentRecordType == 'Key Roles'){

            if(delegate.Agreement_Amount_estimated__c == null){
                delegate.Agreement_Amount_estimated__c.addError('Required');
                valid = false;
            }
            else if(delegate.Agreement_Amount_estimated__c.longValue() > delegateLimitSettings.Agreement_Amount__c.longValue()){
                valid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Agreement Amount is greater than allowed Maximum'));
            }
            if(delegate.Agreement_Amount_estimated_lt__c == null){
                delegate.Agreement_Amount_estimated_lt__c.addError('Required');
                valid = false;
            }
            else if(delegate.Agreement_Amount_estimated_lt__c.longValue() < delegateLimitSettings.Agreement_Amount_lt__c.longValue()){
                valid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Agreement Amount is less than allowed Minimum'));
            }
            if(delegate.Project_Revenue_Budget__c == null){
                delegate.Project_Revenue_Budget__c.addError('Required');
                valid = false;
            }
            else if(delegate.Project_Revenue_Budget__c.longValue() > delegateLimitSettings.Project_Revenue_Budget__c.longValue()){
                valid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Project Revenue Budget is greater than allowed Maximum'));
            }
            if(delegate.Project_Revenue_Budget_lt__c == null){
                delegate.Project_Revenue_Budget_lt__c.addError('Required');
                valid = false;
            }
            else if(delegate.Project_Revenue_Budget_lt__c.longValue() < delegateLimitSettings.Project_Revenue_Budget_lt__c.longValue()){
                valid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Project Revenue Budget is less than allowed Minimum'));
            }
            if(delegate.Backlog_Value__c == null){
                delegate.Backlog_Value__c.addError('Required');
                valid = false;
            }
            else if(delegate.Backlog_Value__c.longValue() > delegateLimitSettings.Backlog_Value__c.longValue()){
                valid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Backlog Value is greater than allowed Maximum'));
            }
            if(delegate.Backlog_Value_lt__c == null){
                delegate.Backlog_Value_lt__c.addError('Required');
                valid = false;
            }
            else if(delegate.Backlog_Value_lt__c.longValue() < delegateLimitSettings.Backlog_Value_lt__c.longValue()){
                valid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Backlog Value is less than allowed Minimum'));
            }
            if(delegate.Project_Net_Margin_Value__c == null){
                delegate.Project_Net_Margin_Value__c.addError('Required');
                valid = false;
            }
            else if(delegate.Project_Net_Margin_Value__c.longValue() > delegateLimitSettings.Project_Net_Margin_Value__c.longValue()){
                valid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Project Net Margin Value is greater than allowed Maximum'));
            }
            if(delegate.Project_Net_Margin_Value_lt__c == null){
                delegate.Project_Net_Margin_Value_lt__c.addError('Required');
                valid = false;
            }
            else if(delegate.Project_Net_Margin_Value_lt__c.longValue() < delegateLimitSettings.Project_Net_Margin_Value_lt__c.longValue()){
                valid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Project Net Margin Value is less than allowed Minimum'));
            }
            if(delegate.Project_Net_Margin_age_of_NSR__c == null){
                delegate.Project_Net_Margin_age_of_NSR__c.addError('Required');
                valid = false;
            }
            else if(delegate.Project_Net_Margin_age_of_NSR__c > delegateLimitSettings.Project_Net_Margin_age_of_NSR__c){
                valid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Project Net Margin Percentage of NSR is greater than allowed Maximum'));
            }
            if(delegate.Project_Net_Margin_age_of_NSR_lt__c == null){
                delegate.Project_Net_Margin_age_of_NSR_lt__c.addError('Required');
            }
            else if(delegate.Project_Net_Margin_age_of_NSR_lt__c < delegateLimitSettings.Project_Net_Margin_age_of_NSR_lt__c){
                valid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Project Net Margin Percentage of NSR is less than allowed Minimum'));
            }
            if(delegate.age_Change_in_Forecast_Net_Margin__c == null){
                delegate.age_Change_in_Forecast_Net_Margin__c.addError('Required');
                valid = false;
            }
            else if(delegate.age_Change_in_Forecast_Net_Margin__c.longValue() > delegateLimitSettings.age_Change_in_Forecast_Net_Margin__c.longValue()){
                valid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Percentage Change in Forecast Net Margin is greater than allowed Maximum'));
            }
            if(delegate.age_Change_in_Forecast_Net_Margin_lt__c == null){
                delegate.age_Change_in_Forecast_Net_Margin_lt__c.addError('Required');
                valid = false;
            }
            else if(delegate.age_Change_in_Forecast_Net_Margin_lt__c.longValue() < delegateLimitSettings.age_Change_in_Forecast_Net_Margin_lt__c.longValue()){
                valid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Percentage Change in Forecast Net Margin is less than allowed Minimum'));
            }
            if(delegate.Value_change_in_Forecast_Net_Margin__c == null){
                delegate.Value_change_in_Forecast_Net_Margin__c.addError('Required');
                valid = false;
            }
            else if(delegate.Value_change_in_Forecast_Net_Margin__c.longValue() > delegateLimitSettings.Value_change_in_Forecast_Net_Margin__c.longValue()){
                valid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Value Change in Forecast Net Margin is greater than allowed Maximum'));
            }
            if(delegate.Value_change_in_Forecast_Net_Margin_lt__c == null){
                delegate.Value_change_in_Forecast_Net_Margin_lt__c.addError('Required');
                valid = false;
            }
            else if(delegate.Value_change_in_Forecast_Net_Margin_lt__c.longValue() < delegateLimitSettings.Value_change_in_Forecast_Net_Margin_lt__c.longValue()){
                valid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Value Change in Forecast Net Margin is less than allowed Minimum'));
            }
            if(delegate.Value_change_in_Forecast_Net_Margin__c == null){
                delegate.Value_change_in_Forecast_Net_Margin__c.addError('Required');
                valid = false;
            }
            else if(delegate.Value_change_in_Forecast_Net_Margin__c.longValue() > delegateLimitSettings.Value_change_in_Forecast_Net_Margin__c.longValue()){
                valid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Value Change in Forecast Net Margin is greater than allowed Maximum'));
            }
            if(delegate.Value_change_in_Forecast_Net_Margin_lt__c == null){
                delegate.Value_change_in_Forecast_Net_Margin_lt__c.addError('Required');
                valid = false;
            }
            else if(delegate.Value_change_in_Forecast_Net_Margin_lt__c.longValue() < delegateLimitSettings.Value_change_in_Forecast_Net_Margin_lt__c.longValue()){
                valid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Value Change in Forecast Net Margin is less than allowed Minimum'));
            }
        }
        else if(currentRecordType == 'Vacation'){
            if(delegate.Start_Date__c > delegate.End_Date__c){
                valid = false;
                delegate.End_Date__c.addError('End Date cannot be less than Start Date');
            }
            else if(delegate.Start_Date__c.daysBetween(delegate.End_Date__c) > 60){
                valid = false;
                delegate.End_Date__c.addError('Vacation Duration cannot exceed 60 days');
            }
        }
        return valid;
    }

    /**
     * converts the yes/no field questions to the associated delegate field checkbox
     *   
     * @Author  NTT Data
     * @Date    July 2016
     *
     **/
    private void setYesNoFieldValues(){
        if(agreementAmountBypass == 'Yes'){
            delegate.Agreement_Amount_estimated_Bypass__c = true;
        }
        else{
            delegate.Agreement_Amount_estimated_Bypass__c = false;
        }

        if(agreementAmountBypassLT == 'Yes'){
            delegate.Agreement_Amount_estimated_Bypass_lt__c = true;
        }
        else{
            delegate.Agreement_Amount_estimated_Bypass_lt__c = false;
        }

        if(projectRevenueBudgetBypass == 'Yes'){
            delegate.Project_Revenue_Budget_Bypass__c = true;
        }
        else{
            delegate.Project_Revenue_Budget_Bypass__c = false;
        }

        if(projectRevenueBudgetBypassLT == 'Yes'){
            delegate.Project_Revenue_Budget_Bypass_lt__c = true;
        }
        else{
            delegate.Project_Revenue_Budget_Bypass_lt__c = false;
        }

        if(backlogValueBypass == 'Yes'){
            delegate.Backlog_Value_Bypass__c = true;
        }
        else{
            delegate.Backlog_Value_Bypass__c = false;
        }

        if(backlogValueBypassLT == 'Yes'){
            delegate.Backlog_Value_Bypass_lt__c = true;
        }
        else{
            delegate.Backlog_Value_Bypass_lt__c = false;
        }


        if(projectNetMarginValueBypass == 'Yes'){
            delegate.Project_Net_Margin_Value_Bypass__c = true;
        }
        else{
            delegate.Project_Net_Margin_Value_Bypass__c = false;
        }

        if(projectNetMarginValueBypassLT == 'Yes'){
            delegate.Project_Net_Margin_Value_Bypass_lt__c = true;
        }
        else{
            delegate.Project_Net_Margin_Value_Bypass_lt__c = false;
        }

        if(projectNetMarginNSRBypass == 'Yes'){
            delegate.Project_Net_Margin_age_of_NSR_Bypass__c = true;
        }
        else{
            delegate.Project_Net_Margin_age_of_NSR_Bypass__c = false;
        }

        if(projectNetMarginNSRBypassLT == 'Yes'){
            delegate.Project_Net_Margin_of_NSR_Bypass_lt__c = true;
        }
        else{
            delegate.Project_Net_Margin_of_NSR_Bypass_lt__c = false;
        }

        if(percentageChangeInForecastBypass == 'Yes'){
            delegate.age_Change_in_Forecast_Net_Margin_Bypass__c = true;
        }
        else{
            delegate.age_Change_in_Forecast_Net_Margin_Bypass__c = false;
        }

        if(percentageChangeInForecastBypassLT == 'Yes'){
            delegate.age_Change_in_Forecast_Net_Margin_Byp_lt__c = true;
        }
        else{
            delegate.age_Change_in_Forecast_Net_Margin_Byp_lt__c = false;
        }

        if(valueChangeInForecastNetMarginBypass == 'Yes'){
            delegate.Value_change_in_Forecast_Net_Margin_Byps__c = true;
        }
        else{
            delegate.Value_change_in_Forecast_Net_Margin_Byps__c = false;
        }

        if(valueChangeInForecastNetMarginBypassLT == 'Yes'){
            delegate.Value_change_Forecast_Nt_Margn_Byps_lt__c = true;
        }
        else{
            delegate.Value_change_Forecast_Nt_Margn_Byps_lt__c = false;
        }

        if(c0Bypass == 'Yes'){
            delegate.Project_Review_Category_C_0_Bypass__c = true;
        }
        else{
            delegate.Project_Review_Category_C_0_Bypass__c = false;
        }

        if(c1Bypass == 'Yes'){
            delegate.Project_Review_Category_C_1_Bypass__c = true;
        }
        else{
            delegate.Project_Review_Category_C_1_Bypass__c = false;
        }


        if(c2Bypass == 'Yes'){
            delegate.Project_Review_Category_C_2_Bypass__c = true;
        }
        else{
            delegate.Project_Review_Category_C_2_Bypass__c = false;
        }

        if(c3Bypass == 'Yes'){
            delegate.Project_Review_Category_C_3_Bypass__c = true;
        }
        else{
            delegate.Project_Review_Category_C_3_Bypass__c = false;
        }

        if(c4Bypass == 'Yes'){
            delegate.Project_Review_Category_C_4_Bypass__c = true;
        }
        else{
            delegate.Project_Review_Category_C_4_Bypass__c = false;
        }


    }

    /**
     * runs the query for the contact and delegates.  Initializes the delegate so a new one can be added
     *   
     * @Author  NTT Data
     * @Date    July 2016
     *
     **/
    private void queryContact(String recordTypeId){
        try{
            contact = Database.query(buildSOQL(recordTypeId));
            delegate = new Delegate__c(Delegator__c = contact.Id, 
                                        RecordTypeId = recordTypeId,
                                        DelegatorsManager__c = contact.ReportsTo.pse__Salesforce_User__c,
                                        CurrencyIsoCode = contact.pse__Salesforce_User__r.DefaultCurrencyIsoCode);
            delegates = new List<Delegate__c>();

            if(keyRolesRecordType == null){
                for(RecordType recordType : recordTypes){
                    if(recordType.DeveloperName == 'Key_Roles'){
                        keyRolesRecordType = recordType.Id;
                    }
                }
            }

            if(recordTypeId == keyRolesRecordType){
                delegate.Project_Review_Category_C_0__c = true;
                delegate.Project_Review_Category_C_1__c = true;
                delegate.Project_Review_Category_C_2__c = true;
                delegate.Project_Review_Category_C_3__c = true;
                delegate.Project_Review_Category_C_4__c = true;
                resetBypassYesNoFields();
                populateOwningOrganizations();
            }
            else if(recordTypeId == alternateRecordType){
                /*if(contact.ReportsToId != null){
                    Delegate__c managerDelegate = new Delegate__c(Delegate__c = contact.ReportsToId, Delegator__c = contactId, RecordTypeId = alternateRecordType);
                    delegates.add(managerDelegate);
                }*/
            }


            delegates.addAll(contact.Delegates1__r);
            attachment = new Attachment();
        }
        catch(Exception ex){
            //no contact record found
        }
    }

    /**
     * loads the list owningOrganization wrapper for the owning organization table
     *   
     * @Author  NTT Data
     * @Date    July 2016
     *
     **/
    /*private void populateOwningOrganizations(){
        //retrieve field string from fieldset
        owningOrganizations = new List<owningOrganization>();
        List<ProjectTeamMember__c> projectTeamMembers = new List<ProjectTeamMember__c>();
        if(contactId != null){
            projectTeamMembers = [Select Id, Project__c from ProjectTeamMember__c where Contact__c =: contactId and (ProjectRole__r.Name = 'Project Approver 2' OR ProjectRole__r.Name = 'Finance Lead')];
        }
        else{
            projectTeamMembers = [Select Id, Project__c from ProjectTeamMember__c where Contact__r.pse__Salesforce_User__c =: UserInfo.getUserId() and (ProjectRole__r.Name = 'Project Approver 2' OR ProjectRole__r.Name = 'Finance Lead')];
        }
        Set<Id> projectIds = new Set<Id>();
        for(ProjectTeamMember__c projectTeamMember : projectTeamMembers){
            projectIds.add(projectTeamMember.Project__c);
        }
        if(projectIds.size() > 0){
            Set<String> organizationStringFields = ECO_Utils_sObject.getFieldSetMembers('Delegate_Owning_Organization_Table', 'OrganizationString__c');
            
            if(organizationStringFields.size() > 0){
                String queryFields = '';

                //create the query field string 
                for(String organizationStringField : organizationStringFields){
                    queryFields += 'CarryingOutOrganization__r.' + organizationStringField + ', ';
                }

                //query string
                String query = 'Select Id, CarryingOutOrganization__c, CarryingOutOrganization__r.LocationName__c, ' + queryFields.removeEnd(', ') + ' From pse__Proj__c where Id IN : projectIds';
                List<pse__Proj__c> projects = Database.query(query);
                Set<Id> organizationIdsUsed = new Set<Id>();

                //load the owningOrganizations wrapper from query results
                for(pse__Proj__c project : projects){
                    if(!organizationIdsUsed.contains(project.CarryingOutOrganization__c)){
                        organizationIdsUsed.add(project.CarryingOutOrganization__c);
                        owningOrganizations.add(new owningOrganization(project.CarryingOutOrganization__r));
                    }
                }
            }
        }
    }*/

    /**
     * loads the list owningOrganization wrapper for the owning organization table
     *   
     * @Author  NTT Data
     * @Date    July 2016
     *
     **/
    private void populateOwningOrganizations(){

        Set<String> organizationStringFields = ECO_Utils_sObject.getFieldSetMembers('Delegate_Owning_Organization_Table', 'OrganizationString__c');
        owningOrganizations = new List<owningOrganization>();
        
        if(organizationStringFields.size() > 0){

            String queryFields = '';

            //create the query field string 
            for(String organizationStringField : organizationStringFields){
                queryFields += organizationStringField + ', ';
            }

            //query string
            String query = 'Select LocationName__c, ' + queryFields.removeEnd(', ') + ' From OrganizationString__c where FinanceandAccountingManagerContact__c = \'' + contactId + '\' or PLManagerContact__c = \'' + contactId+ '\' ';

            system.debug(query);
            List<OrganizationString__c> orgs = Database.query(query);

            Set<Id> organizationIdsUsed = new Set<Id>();

            //load the owningOrganizations wrapper from query results
            for(OrganizationString__c o : orgs){
                organizationIdsUsed.add(o.id);
                owningOrganizations.add(new owningOrganization(o));

            }
        }

    }

    /**
     * resets all of the yes/no bypass delegate fields to yes
     *   
     * @Author  NTT Data
     * @Date    July 2016
     *
     **/
    private void resetBypassYesNoFields(){
        String yesOrNo = 'Yes';
        userPreferences = ECO_Delegate_User_Preferences__c.getInstance(UserInfo.getUserId());
        if(userPreferences != null && userPreferences.Default_Delegate_Bypass_to_No__c){
            yesOrNo = 'No';
        }

        system.debug('***yesOrNo ' + yesOrNo);
        agreementAmountBypass = yesOrNo;
        agreementAmountBypassLT = yesOrNo;
        projectRevenueBudgetBypass = yesOrNo;
        projectRevenueBudgetBypassLT = yesOrNo;
        backlogValueBypass = yesOrNo;
        backlogValueBypassLT = yesOrNo;
        projectNetMarginValueBypass = yesOrNo;
        projectNetMarginValueBypassLT = yesOrNo;
        projectNetMarginNSRBypass = yesOrNo;
        projectNetMarginNSRBypassLT = yesOrNo;
        percentageChangeInForecastBypass = yesOrNo;
        percentageChangeInForecastBypassLT = yesOrNo;
        valueChangeInForecastNetMarginBypass = yesOrNo;
        valueChangeInForecastNetMarginBypassLT = yesOrNo;
        c0Bypass = yesOrNo;
        c1Bypass = yesOrNo;
        c2Bypass = yesOrNo;
        c3Bypass = yesOrNo;
        c4Bypass = yesOrNo;
    }


    /**
     * returns the query string for the delegate table
     *   
     * @Author  NTT Data
     * @Date    July 2016
     *
     **/
    private String buildSOQL(String recordTypeId){
        //retrieve all of the fieldset fields to define the contact query
        Set<String> fieldSetFields = ECO_Utils_sObject.getFieldSetMembers('DelegationModuleContactDetails', 'Contact');
        String queryFields = '';
        Boolean foundName = false;
        Boolean foundUser = false;
        Boolean foundReportsTo = false;

        //create a soql compatible string of field names to select
        for(String fieldSetField : fieldSetFields){
            if(fieldSetField == 'Name'){
                foundName = true;
            }
            if(fieldSetField == 'pse__Salesforce_User__c'){
                foundUser = true;
            }
            if(fieldSetField == 'ReportsToId'){
                foundReportsTo = true;
            }
            queryFields += fieldSetField + ', ';
        }

        //remove the last comma so we don't receive a SOQL error
        queryFields = queryFields.removeEnd(', ');

        //the name field was not found in the field set but we need it anyway
        if(!foundName){
            queryFields += ', Name';
        }
        if(!foundUser){
            queryFields += ', pse__Salesforce_User__c';
        }

        if(!foundReportsTo){
            queryFields += ', ReportsToId';
        }

        query = 'Select pse__Salesforce_User__r.DefaultCurrencyIsoCode, ReportsTo.Name, ReportsTo.pse__Salesforce_User__c, DateDelegationEmailSent__c, ' + queryFields + ', (Select Delegate_Name__c, name, DelegatorsManager__c, Delegate__c, End_Date__c, RecordType.Name, Key_Member_Role__c, Notes__c, Start_Date__c, Approval_Status__c, CreatedBy.Name, LastModifiedDate From Delegates1__r where Approval_Status__c != \'Rejected\' and RecordTypeId = \'' + recordTypeId + '\') From Contact Where ';
        
        //if the contactId is passed in the query parameter             
        if(contactId != null){
            query += 'Id = \'' + contactId + '\'';
        }
        //instead, get the current user's contact info
        else{
            query += 'pse__Salesforce_User__c = \'' + UserInfo.getUserId() + '\'';
        }
        System.debug('query:::'+query);
        return query;
    }


    /**
     * wrapper that holds the information for the owning organization table
     *   
     * @Author  NTT Data
     * @Date    July 2016
     *
     **/
    public class owningOrganization{
        public Boolean checked{get; set;}
        public OrganizationString__c organization{get; set;}

        public owningOrganization(OrganizationString__c org){
            checked = false;
            organization = org;
        }
    }

}