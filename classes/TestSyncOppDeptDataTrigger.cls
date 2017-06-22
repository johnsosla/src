@isTest
private class TestSyncOppDeptDataTrigger {

    private static Account createAccount() {
        Account acc = new Account(Name='Test Account');
        insert acc;
        return acc;
    }
    
    private static Opportunity createOpportunity(Account act) {
        //Primary Department
        AECOM_Primary_Department__c primaryDept;
        List<AECOM_Primary_Department__c> departments;

        departments = [SELECT Lead_Region__c FROM AECOM_Primary_Department__c WHERE Name = 'test Lead Region' LIMIT 1];
        if(departments.size() == 0){
            primaryDept = new AECOM_Primary_Department__c(Lead_Region__c = 'test Lead Region');
            insert primaryDept;
        }
        else{
            primaryDept = departments[0];
        }

        // AECOM Employee
        AECOM_Employee__c aecomEmp = new AECOM_Employee__c(First_Name__c='test', Last_Name__c='emp', Employee_ID__c='1234$321');
        insert aecomEmp;
        Map<String,ID> recordTypesMap = new Map<String,ID>();
        for(RecordType r:[select id,Name from RecordType where sObjectType='Opportunity' and isActive=true]){
            recordTypesMap.put(r.Name,r.Id);
            system.debug('###' + r.Name);
        }
        
        Opportunity opp = new Opportunity(Name='test opp', 
                                          StageName='1 Lead', 
                                          CloseDate=Date.newInstance(2010, 9, 25), 
                                          RecordTypeId = recordTypesMap.get('Project - APAC'),
                                          Amount = 10000,
                                          Legacy_OpportunityID__c='1002', 
                                          ProjectCountry__c='United States',
                                          Estimated_work_start_date__c = Date.today().addDays(90),
                                          TO_Procurement_Method__c = 'Competitive Task Orders',
                                          Enterprise_Service__c = 'Engineering',
                                          AECOM_Primary_Dept_Lookup__c = primaryDept.Id,
                                          CS_Gross_Margin_Percent__c = 15
                                          );
        insert opp;
        return opp;
    }

    private static AECOM_Primary_Department__c createAECOMDept(String name, String region) {
        AECOM_Primary_Department__c aeDept = new AECOM_Primary_Department__c();
        if(name != null) {
            aeDept.Name = name;    
        } else {
            aeDept.Name = 'Test Dept Name';
        }

        if(region != null) {
            aeDept.Lead_Region__c = region;    
        } else {
            aeDept.Lead_Region__c = 'Test Region';    
        }
        
        
        insert aeDept;
        return aeDept;
    }


    //create AECOM Practice Area and Sub Practice Area
    private static Practice_Area__c createPracticeArea(String name) {
        Practice_Area__c pArea = new Practice_Area__c();
        if(name != null) {
            pArea.name = name;
        } else {
            pArea.name = 'Test Practice Area';    
        }
        
        insert pArea;
        return pArea;
    }

    private static Sub_Practice_Area__c createSubPracticeArea(String name) {
        Sub_Practice_Area__c spArea = new Sub_Practice_Area__c();
        if(name != null) {
            spArea.name = name;
        } else {
            spArea.name = 'Test Sub Practice Area';    
        }
        
        insert spArea;
        return spArea;
    }

    private static Opportunity_Department__c createOppDept(Opportunity opp
                                                           , AECOM_Primary_Department__c aeDept
                                                           , Practice_Area__c pArea
                                                           , Sub_Practice_Area__c spArea) {
        Opportunity_Department__c dept = new Opportunity_Department__c();
        dept.Opportunity__c = opp.id;
        dept.AECOM_Department__c = aeDept.ID;
        dept.Practice_Area__c = pArea.ID;
        dept.Sub_Practice_Area__c = spArea.ID;
        dept.split__c = 100;
        insert dept;
        return dept;
    }

    //does NOT persist on its own like the createOppDept (single record) method does!!!
    //feels like better control over the test case if I do that part manually when working
    //with multiple records -- dunno why -- its a feeling.
    private static List<Opportunity_Department__c> createMultiOppDepts(Opportunity opp
                                                           , List<AECOM_Primary_Department__c> aeDepts
                                                           , List<Practice_Area__c> pAreas
                                                           , List<Sub_Practice_Area__c> spAreas
                                                           , Integer numberToCreate) {

        List<Opportunity_Department__c> depts = new List<Opportunity_Department__c>();
        
        for(Integer i=0; i< numberToCreate; i++) {
            Opportunity_Department__c dept = new Opportunity_Department__c();
            dept.Opportunity__c = opp.id;
            dept.AECOM_Department__c = aeDepts[i].ID;
            dept.Practice_Area__c = pAreas[i].ID;
            dept.Sub_Practice_Area__c = spAreas[i].ID;
            dept.split__c = 100/numberToCreate;  
            depts.add(dept);
        }
        return depts;
    }

    private static List<ExecuteTrigger__c> createCustomSettings() {
        List<ExecuteTrigger__c> settings = new List<ExecuteTrigger__c>();
        ExecuteTrigger__c noActTrigger = new ExecuteTrigger__c(Name='taskRelatedtoAccountmanager', NotRunTrigger__c=true);
        settings.add(noActTrigger);
        ExecuteTrigger__c noOppTrigger = new ExecuteTrigger__c(Name='OpportunityBeforeInsertBeforeUpdate', NotRunTrigger__c=true);
        settings.add(noOppTrigger);
        ExecuteTrigger__c noTaskTrigger = new ExecuteTrigger__c(Name='TaskrelatedtoPrimaryDepartment', NotRunTrigger__c=true);
        settings.add(noTaskTrigger);
        ExecuteTrigger__c noRollUpTrigger = new ExecuteTrigger__c(Name='TaskOrderRollup', NotRunTrigger__c=true);
        settings.add(noRollUpTrigger);
        ExecuteTrigger__c noSyncTrigger = new ExecuteTrigger__c(Name='SyncOppDepartmentDataTrigger', NotRunTrigger__c=false);
        settings.add(noSyncTrigger);
        upsert settings;
        return settings; 
    }

    @isTest static void test_trigger_updates_opp() {
        List<ExecuteTrigger__c> sets = createCustomSettings();
        System.debug('*********** SETS: ' + sets + '*************');
        Account acc = createAccount();
        Opportunity opp = createOpportunity(acc);
        AECOM_Primary_Department__c aeDept = createAECOMDept(null, null);
        Practice_Area__c pArea = createPracticeArea(null);
        Sub_Practice_Area__c spArea = createSubPracticeArea(null);
        Opportunity_Department__c oppDept = createOppDept(opp, aeDept, pArea, spArea);
        
        oppDept.Primary__c = true;
        update oppDept;

        List<Opportunity_Department__c> updatedDepts = [SELECT ID
                                                       , Opportunity__c
                                                       , AECOM_Department__c
                                                       , Practice_Area__c
                                                       , Sub_Practice_Area__c
                                                       FROM Opportunity_Department__c
                                                       WHERE ID = :oppDept.ID];
        List<Opportunity> updatedOpps = [SELECT ID
                                        , AECOM_Primary_Dept_Lookup__c
                                        FROM Opportunity
                                        WHERE ID = :opp.ID];

        System.assertEquals(1, updatedDepts.size());
        System.assertEquals(1, updatedOpps.size());
        //System.assertEquals(updatedDepts[0].AECOM_Department__c, updatedOpps[0].AECOM_Primary_Dept_Lookup__c);
    }

    @isTest static void test_multiple_opp_depts() {
        List<ExecuteTrigger__c> sets = createCustomSettings();
        System.debug('*********** SETS: ' + sets + '*************');
        Account acc = createAccount();
        Opportunity opp = createOpportunity(acc);
        
        List<AECOM_Primary_Department__c> aeDepts = new List<AECOM_Primary_Department__c>();
        AECOM_Primary_Department__c aeDept1 = createAECOMDept(null, null);
        aeDepts.add(aeDept1);
        AECOM_Primary_Department__c aeDept2 = createAECOMDept('Test Dept 2', 'Test Region 2');
        aeDepts.add(aeDept2);
        AECOM_Primary_Department__c aeDept3 = createAECOMDept('Test Dept 3', 'Test Region 3');
        aeDepts.add(aeDept3);
        AECOM_Primary_Department__c aeDept4 = createAECOMDept('Test Dept 4', 'Test Region 4');
        aeDepts.add(aeDept4);
        AECOM_Primary_Department__c aeDept5 = createAECOMDept('Test Dept 5', 'Test Region 5');
        aeDepts.add(aeDept5);
        AECOM_Primary_Department__c aeDept6 = createAECOMDept('Test Dept 6', 'Test Region 6');
        aeDepts.add(aeDept6);

        List<Practice_Area__c> pAreas = new List<Practice_Area__c>();
        Practice_Area__c pArea1 = createPracticeArea(null);
        pAreas.add(pArea1);
        Practice_Area__c pArea2 = createPracticeArea('Test Practice Area 2');
        pAreas.add(pArea2);
        Practice_Area__c pArea3 = createPracticeArea('Test Practice Area 3');
        pAreas.add(pArea3);
        Practice_Area__c pArea4 = createPracticeArea('Test Practice Area 4');
        pAreas.add(pArea4);
        Practice_Area__c pArea5 = createPracticeArea('Test Practice Area 5');
        pAreas.add(pArea5);
        Practice_Area__c pArea6 = createPracticeArea('Test Practice Area 6');
        pAreas.add(pArea6);

        List<Sub_Practice_Area__c> spAreas = new List<Sub_Practice_Area__c>();
        Sub_Practice_Area__c spArea1 = createSubPracticeArea(null);
        spAreas.add(spArea1);
        Sub_Practice_Area__c spArea2 = createSubPracticeArea('Test Sub Practice Area 2');
        spAreas.add(spArea2);
        Sub_Practice_Area__c spArea3 = createSubPracticeArea('Test Sub Practice Area 3');
        spAreas.add(spArea3);
        Sub_Practice_Area__c spArea4 = createSubPracticeArea('Test Sub Practice Area 4');
        spAreas.add(spArea4);
        Sub_Practice_Area__c spArea5 = createSubPracticeArea('Test Sub Practice Area 5');
        spAreas.add(spArea5);
        Sub_Practice_Area__c spArea6 = createSubPracticeArea('Test Sub Practice Area 6');
        spAreas.add(spArea6);
        
        List<Opportunity_Department__c> oppDepts = createMultiOppDepts(opp, aeDepts, pAreas, spAreas, 6);
        System.assertEquals(6, oppDepts.size());
        oppDepts[0].Primary__c = true;
        //noRunOppDeptTrigger(true); //disable the trigger for initial insertion
        insert oppDepts;
        Set<ID> oppDeptIds = new Set<ID>();
        for(Opportunity_Department__c dpt : oppDepts) {
            oppDeptIds.add(dpt.ID);
        }

        List<Opportunity_Department__c> addedDepts = [SELECT ID
                                                       , Opportunity__c
                                                       , AECOM_Department__c
                                                       , Practice_Area__c
                                                       , Sub_Practice_Area__c
                                                       , Practice_Area__r.Name
                                                       , Sub_Practice_Area__r.Name
                                                       , split__c
                                                       FROM Opportunity_Department__c
                                                       WHERE ID in :oppDeptIds];
        System.assertEquals(6, addedDepts.size());

        Integer count = 1;
        for(Opportunity_Department__c d : addedDepts) {
            d.ordinal__c = count;
            count++; 
        }

        upsert addedDepts;

        List<Opportunity> updatedOpps = [SELECT ID
                                         , AECOM_Primary_Dept_Lookup__c
                                         , AECOM_Primary_Department_Percent__c
                                         , Practice_Area_of_Primary_AECOM_Dept__c
                                         , Sub_Practice_Area_of_Primary_AECOM_Dept__c
                                         , AECOM_Department_2__c
                                         , AECOM_Department_2_Practice_Area__c
                                         , AECOM_Department_2_Percent__c
                                         , AECOM_Department_2_Sub_Practice_Area__c
                                         , AECOM_Department_3__c
                                         , AECOM_Department_3_Practice_Area__c
                                         , AECOM_Department_3_Percent__c
                                         , AECOM_Department_3_Sub_Practice_Area__c
                                         , AECOM_Department_4__c
                                         , AECOM_Department_4_Practice_Area__c
                                         , AECOM_Department_4_Percent__c
                                         , AECOM_Department_4_Sub_Practice_Area__c
                                         , AECOM_Department_5__c
                                         , AECOM_Department_5_Practice_Area__c
                                         , AECOM_Department_5_Percent__c
                                         , AECOM_Department_5_Sub_Practice_Area__c
                                         , AECOM_Department_6__c
                                         , AECOM_Department_6_Practice_Area__c
                                         , AECOM_Department_6_Percent__c
                                         , AECOM_Department_6_Sub_Practice_Area__c
                                         , Backup_Processed__c 
                                         FROM Opportunity
                                         WHERE ID = :opp.ID];


        //assumes, perhaps dangerously so, that I'm getting these back in the order
        //I created them "/me crosses fingers"
        System.assertEquals(1, updatedOpps.size());
        System.assertEquals(true, updatedOpps[0].Backup_Processed__c);
        //System.assertEquals(addedDepts[0].AECOM_Department__c, updatedOpps[0].AECOM_Primary_Dept_Lookup__c);
        //System.assertEquals(addedDepts[0].Practice_Area__c, updatedOpps[0].Practice_Area_of_Primary_AECOM_Dept__c);
        /*
        System.assertEquals(addedDepts[0].Sub_Practice_Area__c, updatedOpps[0].Sub_Practice_Area_of_Primary_AECOM_Dept__c);
        System.assertEquals(addedDepts[0].split__c, updatedOpps[0].AECOM_Primary_Department_Percent__c);

        System.assertEquals(addedDepts[1].AECOM_Department__c, updatedOpps[0].AECOM_Department_2__c);
        System.assertEquals(addedDepts[1].Practice_Area__r.Name, updatedOpps[0].AECOM_Department_2_Practice_Area__c);
        System.assertEquals(addedDepts[1].Sub_Practice_Area__r.Name, updatedOpps[0].AECOM_Department_2_Sub_Practice_Area__c);
        System.assertEquals(addedDepts[1].split__c, updatedOpps[0].AECOM_Department_2_Percent__c);

        System.assertEquals(addedDepts[1].AECOM_Department__c, updatedOpps[0].AECOM_Department_2__c);
        System.assertEquals(addedDepts[1].Practice_Area__r.Name, updatedOpps[0].AECOM_Department_2_Practice_Area__c);
        System.assertEquals(addedDepts[1].Sub_Practice_Area__r.Name, updatedOpps[0].AECOM_Department_2_Sub_Practice_Area__c);
        System.assertEquals(addedDepts[1].split__c, updatedOpps[0].AECOM_Department_2_Percent__c);

        System.assertEquals(addedDepts[2].AECOM_Department__c, updatedOpps[0].AECOM_Department_3__c);
        System.assertEquals(addedDepts[2].Practice_Area__r.Name, updatedOpps[0].AECOM_Department_3_Practice_Area__c);
        System.assertEquals(addedDepts[2].Sub_Practice_Area__r.Name, updatedOpps[0].AECOM_Department_3_Sub_Practice_Area__c);
        System.assertEquals(addedDepts[2].split__c, updatedOpps[0].AECOM_Department_3_Percent__c);

        System.assertEquals(addedDepts[3].AECOM_Department__c, updatedOpps[0].AECOM_Department_4__c);
        System.assertEquals(addedDepts[3].Practice_Area__r.Name, updatedOpps[0].AECOM_Department_4_Practice_Area__c);
        System.assertEquals(addedDepts[3].Sub_Practice_Area__r.Name, updatedOpps[0].AECOM_Department_4_Sub_Practice_Area__c);
        System.assertEquals(addedDepts[3].split__c, updatedOpps[0].AECOM_Department_4_Percent__c);

        System.assertEquals(addedDepts[4].AECOM_Department__c, updatedOpps[0].AECOM_Department_5__c);
        System.assertEquals(addedDepts[4].Practice_Area__r.Name, updatedOpps[0].AECOM_Department_5_Practice_Area__c);
        System.assertEquals(addedDepts[4].Sub_Practice_Area__r.Name, updatedOpps[0].AECOM_Department_5_Sub_Practice_Area__c);
        System.assertEquals(addedDepts[4].split__c, updatedOpps[0].AECOM_Department_5_Percent__c);

        System.assertEquals(addedDepts[5].AECOM_Department__c, updatedOpps[0].AECOM_Department_6__c);
        System.assertEquals(addedDepts[5].Practice_Area__r.Name, updatedOpps[0].AECOM_Department_6_Practice_Area__c);
        System.assertEquals(addedDepts[5].Sub_Practice_Area__r.Name, updatedOpps[0].AECOM_Department_6_Sub_Practice_Area__c);
        System.assertEquals(addedDepts[5].split__c, updatedOpps[0].AECOM_Department_6_Percent__c);
        */
    }
}