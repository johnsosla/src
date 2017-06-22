/*******************************************************************************************
PR          :  PR-06193
Requester   :  Karishma Sharma
Author      :  Appirio Offshore (Sumit)
Date        :  Sept 15, 2010
Purpose     :  This trigger is used to
               1. Create AECOM Team for the inserted accounts
               2. Update AECOM Team records for the updated accoutns...
                  ....only if Account Manager changes
Update      :  Ram Kalagara, Oct 23rd, 2015
               Replaced Account_Manager__c with Account_Manager_User__c         
               Replaced Employee__c with Employee_User__c              
*********************************************************************************************/
trigger taskRelatedtoAccountmanager on Account (after Insert,after Update) 
{
    // check if we not need to run trigger if data loading operation is performed
    ExecuteTrigger__c ext = ExecuteTrigger__c.getAll().get('taskRelatedtoAccountmanager');
    if(ext != null) {
        if(ext.NotRunTrigger__c) {
            return;
        }  
    }
    
    if(ModifyDepartmentController.NotRunOpportunityUpdateTrigger)
        return;
    // Insert
    if(Trigger.isInsert)
    {
        List<AECOM_team__c> lstTeam = new list<AECOM_team__c>();
        List<recordType> recLst=[Select id from recordtype where DeveloperName='AECOM_Team_Account'];
        for(Account act:Trigger.new)
        {
           if(act.Account_Manager_User__c==null)
               continue;
           
           AECOM_team__c ot = new AECOM_team__c(Account__c = act.Id,Employee_User__c = act.Account_Manager_User__c);
           ot.Role__c = 'Account Manager';
           if(recLst.size()>0)
               ot.RecordTypeId= reclst[0].id;
           lstTeam.add(ot);
        }
        ModifyDepartmentController.NotRunOpportunityUpdateTrigger = true;
        // insert AECOM Team
        insert lstTeam;
        ModifyDepartmentController.NotRunOpportunityUpdateTrigger = false;
    }
    
    //Code for CaptureManager Change---------------------------------------------------
    if(Trigger.isUpdate && !ModifyDepartmentController.NotRunOpportunityUpdateTrigger)
    {
        List<AECOM_team__c> lstDept = new list<AECOM_team__c>();
        List<AECOM_team__c> lstDeptToDelete = new list<AECOM_team__c>();
        Map<id,Id> ActDeptNew = new Map<id,Id>();
        Map<id,Id> ActDeptOld = new Map<id,Id>();
        Map<id,AECOM_team__c> actDeptNew1 = new Map<id,AECOM_team__c>();
        
        for(Account actNew : Trigger.new)
        {
            // check if Account Manager is updated
            if(actNew.Account_Manager_User__c != Trigger.OldMap.get(actNew.Id).Account_Manager_User__c)
            {
                actDeptNew.put(actNew.id,actNew.Account_Manager_User__c);
                actDeptOld.put(actNew.id,Trigger.OldMap.get(actNew.Id).Account_Manager_User__c);
                actDeptNew1.put(actNew.Id,new AECOM_team__c(Account__c = actNew.Id,Employee_User__c = actNew.Account_Manager_User__c,Role__c = 'Account Manager'));
            }
        }
        if(actDeptOld.keyset().size()>0)
        {
            for(AECOM_team__c opd:[Select id,Account__c,Employee_User__c,Status__c, Role__c 
                                               from AECOM_team__c 
                                               Where Account__c in :actDeptOld.Keyset() and 
                                               (
                                                //Employee_User__c in :OppDeptNew.Values() OR
                                                Employee_User__c in :actDeptOld.Values()
                                               )
                                               AND Role__c = 'Account Manager'
                                               ])
            {
                    opd.Employee_User__c = actDeptNew.get(opd.Account__c) ;
                    actDeptNew1.put(opd.Account__c,null);
                    if(opd.Employee_User__c !=null)
                        lstDept.add(opd);
                    else
                       lstDeptToDelete.add(opd);
            }
            for(id id1:actDeptNew1.keyset())
            {
                AECOM_team__c opd = actDeptNew1.get(id1);
                if(opd!=null)
                {
                    if(opd.Employee_User__c !=null)
                       lstDept.add(opd); 
                }
            }
            ModifyDepartmentController.NotRunOpportunityUpdateTrigger = true;
            upsert lstDept;
            delete lstDeptToDelete;
            ModifyDepartmentController.NotRunOpportunityUpdateTrigger = false;
         }
    }
}