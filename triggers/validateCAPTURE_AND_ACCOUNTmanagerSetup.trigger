/*****************************************************************************************************
PR          :  PR-06193
Requester   :  Karishma Sharma
Author      :  Appirio Offshore (Sumit)
Date        :  Sept 15, 2010
Purpose     :  Validate Capture Manager/ Account Manager setup. Show related error on record page.
               The trigger only runs if user created AECOM records from UI.
Last Modified: Sumit(8 March 2011)- Removing functionility of capture manager. Check Comments :SumitComm     
****************************************************************************************************/
trigger validateCAPTURE_AND_ACCOUNTmanagerSetup on AECOM_team__c (Before Insert, Before Update,Before Delete) 
{
    // check if we not need to run trigger if data loading operation is performed
    ExecuteTrigger__c ext = ExecuteTrigger__c.getAll().get('validateCAPTUREmanagerSetup');
    if(ext != null) {
        if(ext.NotRunTrigger__c) {
            return;
        }    
    }
    
    List<AECOM_team__c> lstteamForError = new List<AECOM_team__c>();
    // No need to run id AECOM Team record is created from Opportunity trigger
    if(ModifyDepartmentController.NotRunOpportunityUpdateTrigger)
        return;
    Set<Id> accountList = new Set<Id>();
    // Case - Insert/Update
    Map<id,Account> AccountMap=new Map<id,Account>();
    if(Trigger.isInsert || Trigger.IsUpdate)
    {
        
        for(AECOM_team__c ac:Trigger.New)
        {
            // Checking Insert Case
            if(Trigger.isInsert)
            {
                // if Role is 'Capture Manager' throw error
                //SumitComm:if(ac.Role__c == 'Capture Manager')
                //SumitComm:    ac.addError(System.label.ONECAPTUREWITHOPP);
                // if Role is 'Account Manager' throw error
                //if(ac.Role__c == 'Account Manager')
                //    ac.addError(System.label.ONLYONEMANWITHACT);
                if(ac.Role__c == 'Account Manager')
                {
                    accountList.add(ac.Account__c);
                    lstteamForError.add(ac);
                }
            }
            // check for Update case... compare with old Role and throw appropriate error
            else
            {
                // updating Role from anything to 'Capture Manager'... throw error
                /*SumitComm:
                if(ac.Role__c == 'Capture Manager' && Trigger.OldMap.get(ac.Id).Role__c != 'Capture Manager')
                    ac.addError(System.label.ONECAPTUREWITHOPP);
                // updating Role from 'Capture Manager' to any other role... throw error
                if(ac.Role__c != 'Capture Manager' && Trigger.OldMap.get(ac.Id).Role__c == 'Capture Manager')
                    ac.addError(System.label.CAPREQ);
                */
                // updating Role from anything to 'Account Manager'... throw error
                //if(ac.Role__c == 'Account Manager' && Trigger.OldMap.get(ac.Id).Role__c != 'Account Manager')
                //    ac.addError(System.label.ONLYONEMANWITHACT);
                // updating Role from 'Account Manager' to any other role... throw error
                //if(ac.Role__c != 'Account Manager' && Trigger.OldMap.get(ac.Id).Role__c == 'Account Manager')
                //    ac.addError(System.label.MANREQ);
                AECOM_team__c oldAC =  Trigger.OldMap.get(ac.Id);
                if(ac.Role__c == 'Account Manager' && oldAC.Role__c != 'Account Manager')
                {
                    accountList.add(ac.Account__c);
                    lstteamForError.add(ac);
                }
                if(ac.Role__c != 'Account Manager' && oldAC.Role__c == 'Account Manager' && oldAc.Account__c!=null)
                {
                    AccountMap.put(oldAc.Account__c,new Account(id=oldAc.Account__c,Account_Manager__c = null));  
                }
                if(ac.Role__c == 'Account Manager' && oldAC.Role__c == 'Account Manager' && ac.Account__c !=oldAc.Account__c)
                {
                    accountList.add(ac.Account__c);
                    lstteamForError.add(ac);
                    AccountMap.put(oldAc.Account__c,new Account(id=oldAc.Account__c,Account_Manager__c = null)); 
                }
            }
        }
        //Sumit add this extra logic after change in requirement that Account manager is optional
        if(accountList.size()>0)
        {
            Map<id,AECOM_team__c> TeamList = new Map<id,AECOM_team__c>();
            for(AECOM_team__c team:[Select id, Account__c from AECOM_team__c where Role__c = 'Account Manager' and Account__c in :AccountList])
                TeamList.put(team.Account__c,team);
            for(AECOM_team__c ac:lstteamForError)
            {
                if(TeamList.get(ac.Account__c)!=null)
                {
                    ac.addError(System.label.ONLYONEMANWITHACT);
                }
            }
        }
    }
    // If delete case
    if(Trigger.isDelete)
    {
       
        for(AECOM_team__c ac : Trigger.Old)
        {
            // do not allow delete if AECOM Team has Opportunity specified and Role is 'Capture Manager'
            //SumitComm:if(ac.Role__c == 'Capture Manager' && ac.Opportunity__c!=null)
            //SumitComm:    ac.addError(System.label.NOTDELCAPM);
            
            // do not allow delete if AECOM Team has Opportunity specified and Role is 'Account Manager'
            //if(ac.Role__c == 'Account Manager'  && ac.Account__c!=null)
            //    ac.addError(System.label.NOTDELACTM);
            if(ac.Role__c == 'Account Manager'  && ac.Account__c!=null)
                AccountMap.put(ac.Account__c,new Account(id=ac.Account__c,Account_Manager__c = null));
        }
        
    }
    if(AccountMap.keyset().size()>0)
    {
        ModifyDepartmentController.NotRunOpportunityUpdateTrigger = true;
        update AccountMap.values();
        ModifyDepartmentController.NotRunOpportunityUpdateTrigger = false;
    }
    
}