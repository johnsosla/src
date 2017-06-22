/************************************************************************************************************
Created By    :    Sumit Mishra(Appirio offshore)
Date          :    20 Aug 2010
Reason        :    This Trigger will create department or update department of opportunity depending on updates on Opportunity field
Last Modified  :   Sumit(8 March 2011)-Note:All comments started with keyword "SumitComm" Indicate that the comment is done to remove Capture manager functionility
**************************************************************************************************************/
trigger TaskrelatedtoPrimaryDepartment on Opportunity (After Insert, After Update) 
{
	/*
    // check if we not need to run trigger if data loading operation is performed
    ExecuteTrigger__c ext = ExecuteTrigger__c.getAll().get('TaskrelatedtoPrimaryDepartment');
    if(ext != null) {
        if(ext.NotRunTrigger__c) {
            return;  
        }
    }
    
    
    system.debug('*********SUMIT In OpportunityPrimary Dept Trigger*******************'+Trigger.IsInsert+'***'+Trigger.IsBefore );
    if(Trigger.isInsert)
    {
        List<Opportunity_Department__c> lstDept = new list<Opportunity_Department__c>();
        //SumitComm:List<AECOM_team__c> lstTeam = new list<AECOM_team__c>();
        //SumitComm:List<recordType> recLst=[Select id from recordtype where DeveloperName='AECOM_Team_Opportunity'];
        for(Opportunity opp:Trigger.new)
        {
           //SumitComm:if(opp.Capture_Manager__c==null)
           //SumitComm:    continue;
           if(opp.AECOM_Primary_Dept_Lookup__c!=null)
           {
           Opportunity_Department__c od = new Opportunity_Department__c(Opportunity__c = opp.Id,Split__c=100);
           od.AECOM_Department__c = opp.AECOM_Primary_Dept_Lookup__c;
           od.Primary__c = true;
           od.CurrencyISOCode = opp.CurrencyISOCode;
           lstDept.add(od);
           }
           */
           /*SumitComm:
           (2015-03-18 Existing comment)
           AECOM_team__c ot = new AECOM_team__c(Opportunity__c = opp.Id,Employee__c = opp.Capture_Manager__c);
           ot.Role__c = 'Capture Manager';
           if(recLst.size()>0)
               ot.RecordTypeId= reclst[0].id;
           lstTeam.add(ot);
           */
        /*}
        if(lstDept.size()>0)
            insert lstDept;
            */
        /*SumitComm:
        (2015-03-18 Existing comment)
        ModifyDepartmentController.NotRunOpportunityUpdateTrigger = true;
        insert lstTeam;
        ModifyDepartmentController.NotRunOpportunityUpdateTrigger = false;
        */
    /*}
    if(Trigger.isUpdate && !ModifyDepartmentController.NotRunOpportunityUpdateTrigger)
    {
        List<Opportunity_Department__c> lstDept = new list<Opportunity_Department__c>();
        Map<id,Id> OppDeptNew = new Map<id,Id>();
        Map<id,Id> OppDeptOld = new Map<id,Id>();
        Map<id,Opportunity_Department__c> OppDeptNew1 = new Map<id,Opportunity_Department__c>();
        for(Opportunity oppNew:Trigger.new)
        {
        */
            /*SumitComm:
           (2015-03-18 Existing comment)
            if(oppNew.Capture_Manager__c==null)
               continue;
            */
            /*
            if(oppNew.AECOM_Primary_Dept_Lookup__c!=Trigger.OldMap.get(oppNew.Id).AECOM_Primary_Dept_Lookup__c)
            {
                OppDeptNew.put(oppNew.id,oppNew.AECOM_Primary_Dept_Lookup__c);
                OppDeptOld.put(oppNew.id,Trigger.OldMap.get(oppNew.Id).AECOM_Primary_Dept_Lookup__c);
                OppDeptNew1.put(oppNew.Id,new Opportunity_Department__c(CurrencyISOCode = oppNew.CurrencyISOCode,Opportunity__c = oppNew.Id,Split__c=0,AECOM_Department__c=oppNew.AECOM_Primary_Dept_Lookup__c,Primary__c = true));
            }
        }
        if(OppDeptNew.keyset().size()>0)
        {
            for(Opportunity_Department__c opd:[Select id,Primary__c, AECOM_Department__c,Opportunity__c 
                                               from Opportunity_Department__c 
                                               Where Opportunity__c in :OppDeptNew.Keyset() and 
                                               (AECOM_Department__c in :OppDeptNew.Values() OR AECOM_Department__c in :OppDeptOld.Values())])
            {
                if(OppDeptNew.get(opd.Opportunity__c) == opd.AECOM_Department__c)
                {
                    opd.Primary__c = true;
                    OppDeptNew1.put(opd.Opportunity__c,opd);
                }
                if(OppDeptold.get(opd.Opportunity__c) == opd.AECOM_Department__c)
                {
                    opd.Primary__c = false;
                    lstDept.add(opd);
                }
            }
            for(id id1:OppDeptNew1.keyset())
            {
               lstDept.add(OppDeptNew1.get(id1)); 
            }
            upsert lstDept;
       }
    }
    */
    /*SumitComm:
     (2015-03-18 Existing comment)
    //Code for CaptureManager Change---------------------------------------------------
    if(Trigger.isUpdate && !ModifyDepartmentController.NotRunOpportunityUpdateTrigger)
    {
        List<AECOM_team__c> lstDept = new list<AECOM_team__c>();
        List<AECOM_Employee__c> lstEmpToUpdate = new List<AECOM_Employee__c>();
        Map<id,Id> OppDeptNew = new Map<id,Id>();
        Map<id,Id> OppDeptOld = new Map<id,Id>();
        Map<id,AECOM_team__c> OppDeptNew1 = new Map<id,AECOM_team__c>();
        for(Opportunity oppNew:Trigger.new)
        {
            if(oppNew.Capture_Manager__c!=Trigger.OldMap.get(oppNew.Id).Capture_Manager__c)
            {
                OppDeptNew.put(oppNew.id,oppNew.Capture_Manager__c);
                OppDeptOld.put(oppNew.id,Trigger.OldMap.get(oppNew.Id).Capture_Manager__c);
                OppDeptNew1.put(oppNew.Id,new AECOM_team__c(Opportunity__c = oppNew.Id,Employee__c = oppNew.Capture_Manager__c,Role__c = 'Capture Manager'));
            }
        }
        if(OppDeptOld.keyset().size()>0)
        {
            for(AECOM_team__c opd:[Select id,Opportunity__c,Employee__c,Status__c, Role__c 
                                               from AECOM_team__c 
                                               Where Opportunity__c in :OppDeptOld.Keyset() and 
                                               (
                                                //Employee__c in :OppDeptNew.Values() OR
                                                Employee__c in :OppDeptOld.Values()
                                               )
                                               AND Role__c = 'Capture Manager'
                                               ])
            {
                    opd.Employee__c = OppDeptNew.get(opd.Opportunity__c) ;
                    OppDeptNew1.put(opd.Opportunity__c,null);
                    lstDept.add(opd);
            }
            for(id id1:OppDeptNew1.keyset())
            {
                if(OppDeptNew1.get(id1)!=null)
                   lstDept.add(OppDeptNew1.get(id1)); 
            }
            ModifyDepartmentController.NotRunOpportunityUpdateTrigger = true;
            upsert lstDept;
            ModifyDepartmentController.NotRunOpportunityUpdateTrigger = false;
         }
    }
    */
   // system.debug('*********SUMIT Out OpportunityPrimary Dept Trigger*******************'+Trigger.IsInsert+'***'+Trigger.IsBefore );
}