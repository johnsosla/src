/*******************************************************************************************
PR          :  PR-06193
Requester   :  Karishma Sharma
Author      :  Appirio Offshore (Sumit)
Date        :  Sept 15, 2010
Purpose     :  Update Manager of Opportunity and Account. Do update only if 
               AECOM Team Role is 'Capture Manager' or 'Account Manager'
Last Modified: Sumit(8 March 2011)- Removing functionility of capture manager. Check Comments :SumitComm               
*********************************************************************************************/
trigger updateOpportunity_And_AccountMANAGER on AECOM_team__c (after insert, after update) 
{
    // check if we not need to run trigger if data loading operation is performed
    ExecuteTrigger__c ext = ExecuteTrigger__c.getAll().get('updateOpportunityMANAGER');
    if(ext != null) {
        if(ext.NotRunTrigger__c) {
            return;    
        }
    }
    
    Map<id,Id> mapOppManager = new Map<id,Id>();    // Key => Opportunity Id, Value => Employee Id(Capture Manager)
    Map<id,Id> mapActManager = new Map<id,Id>();    // Key => Account Id, Value => Employee Id(Account Manager)
    List<Opportunity> lstOpp = new List<Opportunity>(); // list of Opportunities to update
    List<Account> lstAct = new List<Account>(); // list of Accounts to update
    
    // No need to run id AECOM Team record is created from Opportunity trigger
    if(ModifyDepartmentController.NotRunOpportunityUpdateTrigger)
        return;
    
    // Insert/Update
    for(AECOM_team__c ac: Trigger.New)
    {
        // check for Role... Run trigger only if Role is Capture Manager/Account Manager
        //SumitComm:if(ac.Role__c == 'Capture Manager' || ac.Role__c == 'Account Manager')
        if(ac.Role__c == 'Account Manager')
        {
            // Update 
            if(Trigger.isUpdate)
            {
                AECOM_team__c acOld = Trigger.OldMap.get(ac.id);
                // Check if Role or Employee is changes
                if(acold.Role__c != ac.Role__c || acold.Employee__c != ac.Employee__c || acold.Account__c != ac.Account__c)
                {
                    // If Opportunity exists... update Capture Manager
                    /*SumitComm:if(ac.Opportunity__c != null)
                    {
                        mapOppManager.put(ac.Opportunity__c,ac.Employee__c);
                        lstOpp.add(new Opportunity(id = ac.Opportunity__c, Capture_Manager__c = ac.Employee__c));
                    }
                    */
                    // If Account exists... update Account Manager
                    if(ac.Account__c!=null)
                    {
                        mapActManager.put(ac.Account__c,ac.Employee__c);
                        lstAct.add(new Account(id = ac.Account__c, Account_Manager__c = ac.Employee__c));
                    }
                }
            }
            // Insert 
            else if(Trigger.isInsert)
            {
                // If Opportunity exists... update Capture Manager
                /*SumitComm:
                if(ac.Opportunity__c!=null)
                {
                     mapOppManager.put(ac.Opportunity__c,ac.Employee__c);
                     lstOpp.add(new Opportunity(id=ac.Opportunity__c,Capture_Manager__c = ac.Employee__c));
                }
                */
                // If Account exists... update Account Manager
                if(ac.Account__c!=null)
                {
                     mapActManager.put(ac.Account__c,ac.Employee__c);
                     lstAct.add(new Account(id=ac.Account__c,Account_Manager__c = ac.Employee__c));
                }
            }
        }
    }
    
    // If have Opportunities to update... do update
    /*SumitComm:
    if(lstOpp.size()>0)
    {
        ModifyDepartmentController.NotRunOpportunityUpdateTrigger = true;
        update lstOpp;
        ModifyDepartmentController.NotRunOpportunityUpdateTrigger = false;
    }
    */
    // If have Accounts to update... do update
    if(lstAct.size()>0)
    {
        ModifyDepartmentController.NotRunOpportunityUpdateTrigger = true;
        update lstAct;
        ModifyDepartmentController.NotRunOpportunityUpdateTrigger = false;
    }
}