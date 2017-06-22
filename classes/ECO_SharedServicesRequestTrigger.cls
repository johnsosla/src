/** ------------------------------------------------------------------------------------------------------
* @Description Handler for the trigger on the SharedServicesRequest__c or GBS object.
*
* @Author      
* @Date        
*-----------------------------------------------------------------------------------------------------*/
public class ECO_SharedServicesRequestTrigger {

    public SharedServicesRequest__c oSharedServicesRequest {get;set;}
    public account oAccount {get;set;}
    public account oVendor {get;set;}
    public account oSub {get;set;}
    public Site__c oSite {get;set;}
    public Site__c oSiteBilling {get;set;}
    public Site__c oSiteRemit {get;set;}
    
    public contact oPrimaryContact {get;set;}
    public contact oBillingContact {get;set;}
    public contact oContact {get;set;}
    public contact oContact2 {get;set;}
    public boolean bCreateSiteRequest {get; set;}
    private static ECO_SharedServicesRequestMappers mapper = new ECO_SharedServicesRequestMappers();


    public static void updateEntities(list<SharedServicesRequest__c> ssrs){
        List<Account> accountsToUpdate = new List<Account>();

        mapper.cacheOUs(ssrs);

        list<recordtype> listRecType = [SELECT Id, DeveloperName 
                                        FROM recordtype 
                                        WHERE 
                                            sObjectType = 'SharedServicesRequest__c' 
                                            AND (developername = 'CreateVendor' 
                                                OR  developername = 'CreateCustomer' 
                                                OR developername = 'CreateSub'
                                                OR developername = 'UpdateSite') 
                                        ORDER BY developername ASC];

        map<string, id> mapNameToID = new map<string, id>();
        for(recordtype rt: listRecType){
            mapNameToID.put(rt.developername, rt.id);
        }

        set<id> acctID = new set<id>();
        map<id, SharedServicesRequest__c> mapRefToSSR = new map<id, SharedServicesRequest__c>();


        for(SharedServicesRequest__c ssr: ssrs){
            acctID.add(ssr.referenceaccount__c);
            mapRefToSSR.put(ssr.referenceaccount__c, ssr);
        }

        list<account> lstAccts = [SELECT Id,
                                        Account_Name_in_Local_Language__c,
                                        DBNumberDUNS__c,
                                        DesktopCheckAsia__c,
                                        Name,
                                        ParentID,
                                        Client_Group__c,
                                        Client_Subgroup__c,
                                        Reach__c,
                                        Sic,
                                        SicDesc,
                                        MK_Denial__c,
                                        CustomerType__c,
                                        VendorType__c,
                                        Is_MinorityOwned__c,
                                        NonProfit__c,
                                        Is_SmallBusiness__c,
                                        LargeBusiness__c,
                                        Is_VeteranOwned__c,
                                        Is_WomanOwned__c,
                                        Is_DisabledVetOwned__c,
                                        Eight_A_Certified__c,
                                        AbilityOne__c,
                                        AK_Native_Tribally_Owned__c,
                                        ECO_Disadvn_WomanOwned_SB__c,
                                        Hist_BLK_Minority_Inst__c,
                                        SmallDisadvnBusiness__c,
                                        HubZone__c
                                    FROM account WHERE id IN: acctID];

        for(account a: lstAccts){
            SharedServicesRequest__c s = mapRefToSSR.get(a.id);

            if(s.recordtypeid == mapNameToID.get('CreateCustomer')){
                if(mapper.mapGBStoCustomerAccount(s, a)){
                    accountsToUpdate.add(a);
                }
            }
            if(s.recordtypeid == mapNameToID.get('CreateVendor')){
                if(mapper.mapGBStoVendorAccount(s, a)){
                    accountsToUpdate.add(a);
                }
            }
            /*  CreateSub record type is no longer active
            if(s.recordtypeid == mapNameToID.get('CreateSub')){
                if(mapper.mapGBStoSubAccount(s, a)){
                    accountsToUpdate.add(a);
                }
            }
            */
        }

        update accountsToUpdate;

        //UpdateSite works with the Site__c field, so no need to walk collection, or pass in record type set
        mapper.updateSites('ReferenceSite__c', ssrs);
        mapper.updateSites('ReferenceBillingSite__c', ssrs);
        mapper.updateSites('ReferenceRemitSite__c', ssrs);

        mapper.updateContacts('Contact1Lookup__c', ssrs);
        mapper.updateContacts('Contact2Lookup__c', ssrs);
        mapper.updateContacts('PrimaryContactLookup__c', ssrs);
        mapper.updateContacts('BillingContactLookup__c', ssrs);
    }


    public static void HandleValidation(list<SharedServicesRequest__c> targetSSR){}


    public static void HandleGeneration(list<SharedServicesRequest__c> targetSSR){
        mapper.cacheOUs(targetSSR);

        list<recordtype> listRecType = [SELECT id 
                                        FROM recordtype 
                                        WHERE sObjectType = 'SharedServicesRequest__c' 
                                        AND (
                                               developername = 'AddSite' 
                                            OR developername = 'CreateCustomer'
                                            OR developername = 'CreateSub' 
                                            OR developername = 'CreateVendor' 
                                            OR developername = 'UpdateSite' 
                                            ) 
                                        ORDER BY developername ASC];


        list<ECO_SharedServicesRequestTrigger> lstWrapper = new list<ECO_SharedServicesRequestTrigger>();
        List<SharedServicesRequest__c> requestsToUpdate = new List<SharedServicesRequest__c>();


        for(SharedServicesRequest__c ssr: targetSSR){
            if(!ssr.GenerateObjects__c){
                requestsToUpdate.add(ssr);
            }
            //US-03918 : as per decision, remove this condition that was preventing the creation of the SFIDs.
            //if(!SSR.AssigntoSharedServices__c)
            //  continue;

            if((ssr.recordtypeid == listRecType[1].id)      //CreateCustomer
                || (ssr.recordtypeid == listRecType[2].id)  //CreateSub
                || (ssr.recordtypeid == listRecType[3].id)){//CreateVendor
                if(ssr.GenerateObjects__c){
                    lstWrapper.add(new ECO_SharedServicesRequestTrigger(ssr, false));
                }
            }
            //AddSite, UpdateSite --skip creating an account
            if(ssr.recordtypeid == listRecType[0].id
                || ssr.recordtypeid == listRecType[4].id){
                if(ssr.GenerateObjects__c){
                    lstWrapper.add(new ECO_SharedServicesRequestTrigger(ssr, true));
                }
            }
        }

        if(!requestsToUpdate.isEmpty()){
            updateEntities(requestsToUpdate);
        }

        list<account> lstAccountsToInsert = new list<account>();
        list<contact> lstContactsToInsert = new list<contact>();
        list<Site__c> lstSiteToInsert = new list<Site__c>();

        for(ECO_SharedServicesRequestTrigger wrapper: lstWrapper){
            wrapper.CreateAccount();
            wrapper.CreateContact();

            if(!wrapper.bCreateSiteRequest){
                lstAccountsToInsert.add(wrapper.oAccount);
            }

            if(wrapper.oBillingContact != null){
                lstContactsToInsert.add(wrapper.oBillingContact);
            }

            if(wrapper.oPrimaryContact != null){
                lstContactsToInsert.add(wrapper.oPrimaryContact);
            }           
            if(wrapper.oContact != null){
                lstContactsToInsert.add(wrapper.oContact);
            }

            if(wrapper.oContact2 != null){
                lstContactsToInsert.add(wrapper.oContact2);
            }
            if(wrapper.oSite != null){
                lstSiteToInsert.add(wrapper.oSite);
            }

            if(wrapper.oSiteRemit != null){
                lstSiteToInsert.add(wrapper.oSiteRemit);
            }

            if(wrapper.oSiteBilling != null){
                lstSiteToInsert.add(wrapper.oSiteBilling);
            }
        }


        try{
            if(lstAccountsToInsert.size() > 0){
                insert lstAccountsToInsert;

                for(ECO_SharedServicesRequestTrigger wrapper: lstWrapper){
                    wrapper.oSharedServicesRequest.referenceaccount__c = wrapper.oAccount.id;
                }
            }



        } catch (Exception e) {
            targetSSR[0].addError('Error while trying to insert accounts: ' + e);
        }    

        for(ECO_SharedServicesRequestTrigger wrapper: lstWrapper){
            wrapper.AssociateContact();
        }   

        try{
            insert lstContactsToInsert;

        } catch (Exception e) {
            targetSSR[0].addError('Error while trying to insert contacts: ' + e);
        }   

        for(ECO_SharedServicesRequestTrigger wrapper: lstWrapper){
            wrapper.AssociateSite();
        }   

        try{
            if(lstSiteToInsert.size() > 0){
                insert lstSiteToInsert;
            }

            for(ECO_SharedServicesRequestTrigger wrapper: lstWrapper){
                
                if(wrapper.oSite != null){
                    wrapper.oSharedServicesRequest.ReferenceSite__c = wrapper.oSite.id;
                }

                if(wrapper.oSiteRemit != null){
                    wrapper.oSharedServicesRequest.ReferenceRemitSite__c = wrapper.oSiteRemit.id;
                }
                if(wrapper.oSiteBilling != null){
                    wrapper.oSharedServicesRequest.ReferenceBillingSite__c = wrapper.oSiteBilling.id;
                }
                if(wrapper.oBillingContact != null && wrapper.oSite != null && wrapper.oSharedServicesRequest.AddressIsPrimary__c == true){
                    wrapper.oBillingContact.Site__c = wrapper.oSite.id;

                    update wrapper.oBillingContact;
                }
                if(wrapper.oBillingContact != null && wrapper.oSiteBilling != null && wrapper.oSharedServicesRequest.BillingAddress1isPrimary__c == true){
                    wrapper.oBillingContact.Site__c = wrapper.oSiteBilling.id;

                    update wrapper.oBillingContact;
                }
                
                
            }   


        } catch (Exception e) {
            targetSSR[0].addError('Error while trying to insert sites: ' + e);
        }   

        for(ECO_SharedServicesRequestTrigger wrapper: lstWrapper){
            wrapper.AssociateServiceRequest();
        }   
    }

    public void CreateAccount() {

        map<string, id> mapNameToID = new map<string, id>();
        list<recordtype> lstRT = [select id, developername from recordtype where sobjecttype='SharedServicesRequest__c' and (developername='CreateCustomer' OR developername='CreateSub' OR developername='CreateVendor' OR developername='AddSite')];

        for(recordtype rt: lstRT){
            mapNameToID.put(rt.developername, rt.id);
        }

        oAccount = new Account();
        if(!bCreateSiteRequest){

            if(oSharedServicesRequest.recordtypeid == mapNameToID.get('CreateCustomer')){
                mapper.mapGBStoCustomerAccount(oSharedServicesRequest, oAccount);
                oAccount.Type__c = 'Client/Prospect';
                oAccount.Type = 'Client/Prospect';


            } else if(oSharedServicesRequest.recordtypeid == mapNameToID.get('CreateVendor')){
                mapper.mapGBStoVendorAccount(oSharedServicesRequest, oAccount);
                oAccount.Client_Group__c = 'Industrial/Commercial';
                oAccount.Client_Subgroup__c = 'Other Industrial/Commercial';

                oAccount.Type__c = 'Vendor';
                oAccount.Type = 'Vendor';


            } 
            }else{
                oAccount.Id = oSharedServicesRequest.Account__c;
        }

        oSite = new Site__c(SiteStatus__c = 'A');
        mapper.mapGBStoSite(oSharedServicesRequest, oSite);

        if((oSite.Address1__c == null &&
            oSite.Address2__c == null &&
            oSite.Address3__c == null &&
            oSite.Address4__c == null) ||
            oSite.City__c == null ||
            oSite.State__c == null ||
            oSite.Country__c == null
            ){
            oSite = null;
        }

        if(oSharedServicesRequest.recordtypeid == mapNameToID.get('CreateCustomer') || oSharedServicesRequest.recordtypeid == mapNameToID.get('AddSite')){
            oSiteBilling = new Site__c(SiteStatus__c = 'A');
            mapper.mapGBStoBillingSite(oSharedServicesRequest, oSiteBilling);

            if((oSiteBilling.Address1__c == null &&
                oSiteBilling.Address2__c == null &&
                oSiteBilling.Address3__c == null &&
                oSiteBilling.Address4__c == null) ||
                oSiteBilling.City__c == null ||
                oSiteBilling.State__c == null ||
                oSiteBilling.Country__c == null
                ){
                oSiteBilling = null;
            }
        }

        if (oSharedServicesRequest.recordtypeid == mapNameToID.get('CreateVendor') || oSharedServicesRequest.recordtypeid == mapNameToID.get('CreateSub') || oSharedServicesRequest.recordtypeid == mapNameToID.get('AddSite')){
            oSiteRemit = new Site__c(SiteStatus__c = 'A');
            mapper.mapGBStoRemitSite(oSharedServicesRequest, oSiteRemit);

            if((oSiteRemit.Address1__c == null &&
                oSiteRemit.Address2__c == null) ||
                oSiteRemit.City__c == null ||
                oSiteRemit.State__c == null ||
                oSiteRemit.Country__c == null
                ){
                oSiteRemit = null;
            }

        }
    }


    public void CreateContact() {
        
        //The following line was commented out and replaced per US-06951        
        //String cRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Oracle Contact').getRecordTypeId();
        String cRecordTypeId = ECO_Utils_Meta.getRecordTypeId(Contact.sObjectType,'Oracle_Contact');

        if(oSharedServicesRequest.BillingContactLastName__c != null){
            oBillingContact = new contact();
            oBillingContact.RoleType__c = 'Billing';
            oBillingContact.RecordTypeId = cRecordTypeId;
            mapper.mapGBStoBillingContact(oSharedServicesRequest, oBillingContact);

            if(oBillingContact.lastname == null ||
                oBillingContact.lastname == null){
                oBillingContact = null;
            }

        }

        if(oSharedServicesRequest.Contact1LastName__c != null){

            oContact = new contact();
            oContact.RecordTypeId = cRecordTypeId;
            mapper.mapGBStoContact1(oSharedServicesRequest, oContact);

            if(oContact.lastname == null ||
                oContact.lastname == null){
                oContact = null;
            }

        }


        if(oSharedServicesRequest.Contact2LastName__c != null){

            oContact2 = new contact();
            oContact2.RecordTypeId = cRecordTypeId;
            mapper.mapGBStoContact2(oSharedServicesRequest, oContact2);

            if(oContact2.lastname == null ||
                oContact2.lastname == null){
                oContact2 = null;
            }

        }

        if(oSharedServicesRequest.PrimaryContactLastName__c != null){

            oPrimaryContact = new contact();
            oPrimaryContact.RecordTypeId = cRecordTypeId;
            mapper.mapGBStoPrimaryContact(oSharedServicesRequest, oPrimaryContact);

            if(oPrimaryContact.lastname == null ||
                oPrimaryContact.lastname == null){
                oPrimaryContact = null;
            }
        }
    }


    Public void AssociateContact(){
        if(oBillingContact != null){
            oBillingContact.AccountId = oAccount.id;
        }

        if(oContact != null){
            oContact.AccountId = oAccount.id;
        }

        if(oContact2 != null){
            oContact2.AccountId = oAccount.id;
        }
        if(oPrimaryContact != null){
            oPrimaryContact.AccountId = oAccount.id;
        }

    }

    Public void AssociateSite(){
        if(oSite != null){
            if(oAccount == null && oSharedServicesRequest.Account__c != null)
            {
                oSite.Account__c = oSharedServicesRequest.Account__c;
            }
            else{
                oSite.Account__c = oAccount.id;
            }
        }

        if(oSiteRemit != null){
            oSiteRemit.Account__c = oAccount.id;
        }

        if(oSiteBilling != null){
            oSiteBilling.Account__c = oAccount.id;
        }
    }

    Public void AssociateServiceRequest(){
        oSharedServicesRequest.Account__c = oAccount.id;

        if(oBillingContact != null){
            oSharedServicesRequest.BillingContactLookup__c = oBillingContact.id;
        }
        if(oPrimaryContact != null){            
            oSharedServicesRequest.PrimaryContactLookup__c = oPrimaryContact.id;
        }
        if(oContact != null){       
            oSharedServicesRequest.Contact1Lookup__c = oContact.id;
        }
        if(oContact2 != null){      
            oSharedServicesRequest.Contact2Lookup__c = oContact2.id;
        }

        oSharedServicesRequest.GenerateObjects__c = false;
    }

    
    /** ------------------------------------------------------------------------------------------------------
    * @Description 
    *   trigger before update:
    *     If Ownership changes, add 'User in ownerhip chain' sharing reason to grant prior owner read access to the requst
    *
    * @Author Steve MunLeeuw AECOM
    * @Date   Oct 2016
    *-----------------------------------------------------------------------------------------------------*/
    public static void HandleOwnerhipChange(Map<Id, SharedServicesRequest__c> mapNewSSR, Map<Id, SharedServicesRequest__c> mapOldSSR){
        List<SharedServicesRequest__Share> shares = new List<SharedServicesRequest__Share>();

        for(Id newSsrId : mapNewSSR.keyset()){
            SharedServicesRequest__c newSSR = mapNewSSR.Get(newSsrId);
            if(newSSR.OwnerId != mapOldSSR.get(newSSR.Id).OwnerId){
                SharedServicesRequest__Share share = new SharedServicesRequest__Share(
                    ParentID = newSsrId,
                    UserOrGroupId = mapOldSSR.get(newSSR.Id).OwnerId,
                    AccessLevel = 'read',
                    RowCause = Schema.SharedServicesRequest__Share.RowCause.User_in_ownership_chain__c
                    );

                shares.add(share);
            }
        }

        if(!shares.isEmpty()){
            try{
                insert shares;
            } catch(Exception e){
                ECO_Service_ErrorLog.logException(e);
            }
        }
    }

    /** ------------------------------------------------------------------------------------------------------
    * @Description 
    *   trigger after update:
    *     If Status changes to In Approval Process
    *       Grant the requestor read access
    *       If request enters an approval process, add 'Approver Needs Access' sharing reason to grant approver read access to the requst
    *       This is a bit tricky in that the triggers complete prior to the approval process records being created (ProcessInstance, ProcessInstanceWorkItem)
    *       Therefore we grant sharing to the owners manager (approver).  If we include delegates for approval, we'll need to query those users and apply the sharing rule.
    *
    * @Author Steve MunLeeuw AECOM
    * @Date   Nov 2016
    *-----------------------------------------------------------------------------------------------------*/
    public static void HandleInApprovalProcess(Map<Id, SharedServicesRequest__c> mapNewSSR, Map<Id, SharedServicesRequest__c> mapOldSSR){

        List<SharedServicesRequest__Share> shares = new List<SharedServicesRequest__Share>();
        List<Id> owners = new List<Id>();
        List<Id> ssrsInApproval = new List<Id>();

        for(Id newSsrId : mapNewSSR.keyset()){
            SharedServicesRequest__c newSSR = mapNewSSR.Get(newSsrId);
            if(newSSR.Status__c == 'In Approval Process'
                && newSSR.Status__c != mapOldSSR.get(newSSR.Id).Status__c){
                    owners.add(newSSR.OwnerId);
                    ssrsInApproval.add(newSsrId);
            }
        }

        Map<Id, User> managers = new Map<Id, User>([
            SELECT Id, ManagerId 
            FROM User 
            WHERE Id IN :owners]);


        for(Id newSsrId : mapNewSSR.keyset()){
            SharedServicesRequest__c newSSR = mapNewSSR.Get(newSsrId);

            if(newSSR.Status__c == 'In Approval Process'
                && newSSR.Status__c != mapOldSSR.get(newSSR.Id).Status__c){

                //grant manager read access via sharing rule
                SharedServicesRequest__Share share = new SharedServicesRequest__Share(
                    ParentID = newSsrId,
                    UserOrGroupId = ((User)managers.get(newSSR.OwnerId)).ManagerId,
                    AccessLevel = 'read',
                    RowCause = Schema.SharedServicesRequest__Share.RowCause.Approver_Needs_Access__c
                    );

                shares.add(share);
            }
        }

        if(!shares.isEmpty()){
            try{
                insert shares;
            } catch(Exception e){
                ECO_Service_ErrorLog.logException(e);
            }
        }

        grantApproversReadAccessFuture(ssrsInApproval);
    }   

    @future  //GBS record needs to be commited before we can query the approval process records
    public static void grantApproversReadAccessFuture(List<Id> ssrsInApproval){
        List<SharedServicesRequest__Share> shares = new List<SharedServicesRequest__Share>();

        Map<Id, ProcessInstanceWorkitem> approvers = new Map<Id, ProcessInstanceWorkitem>([
            SELECT ProcessInstance.TargetObjectId, ActorId 
            FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObjectId IN :ssrsInApproval
            ORDER BY CreatedDate DESC]);


        //grant approvers read access via sharing rule
        if(approvers.size() > 0){
            for(Id workId : approvers.keySet()){
                SharedServicesRequest__Share share = new SharedServicesRequest__Share(
                    ParentID = ((ProcessInstanceWorkitem)approvers.get(workId)).ProcessInstance.TargetObjectId,
                    UserOrGroupId = ((ProcessInstanceWorkitem)approvers.get(workId)).ActorId,
                    AccessLevel = 'read',
                    RowCause = Schema.SharedServicesRequest__Share.RowCause.Approver_Needs_Access__c
                    );

                shares.add(share);
            }
        }

        if(!shares.isEmpty()){
            try{
                insert shares;
            } catch(Exception e){
                ECO_Service_ErrorLog.logException(e);
            }
        }
    }

    /** ------------------------------------------------------------------------------------------------------
    * @Description 
    *   trigger before update:
    *     If Status changes to On Hold:
    *       scratch: If Owner is a queue, set Owner = Requestor
    *     If Status changes to Pending & AssigntoSharedServices
    *       scratch: Set Owner to Queue
    *       Set Status = In Review  
    *
    *   On Create:
    *       Set Requestor to Owner Aug 2016 -US-05059
    *       Submit for Approval Feb/26/2016 -removed: US-4900 don't submit GBS to approval process
    *
    * @Author Steve MunLeeuw AECOM
    * @Date   Oct 2016
    *-----------------------------------------------------------------------------------------------------*/
    public static void HandleStatusChange(Map<Id, SharedServicesRequest__c> mapNewSSR, Map<Id, SharedServicesRequest__c> mapOldSSR){

        for(Id newSsrId : mapNewSSR.keyset()){
            SharedServicesRequest__c newSSR = mapNewSSR.Get(newSsrId);

            if(newSSR.Requestor__c == null){
                newSSR.Requestor__c = newSSR.OwnerId;
            }

            //Status picklist values not localized
            if(newSSR.Status__c == 'On Hold'
                && newSSR.Status__c != mapOldSSR.get(newSSR.Id).Status__c){
            }

            if(newSSR.Status__c == 'Pending'
                && newSSR.Status__c != mapOldSSR.get(newSSR.Id).Status__c){
                    newSSR.Status__c = 'In Review';
            }
        }
    }   

    public ECO_SharedServicesRequestTrigger(SharedServicesRequest__c oSharedServicesRequest){
        this.oSharedServicesRequest = oSharedServicesRequest;
    }

    public ECO_SharedServicesRequestTrigger(SharedServicesRequest__c oSharedServicesRequest, boolean bCreateSiteRequest){
        this.oSharedServicesRequest = oSharedServicesRequest;
        this.bCreateSiteRequest = bCreateSiteRequest;
    }
}