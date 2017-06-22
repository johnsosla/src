Global class OpportunityDeptUpdate implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
      return Database.getQueryLocator('Select Id from Opportunity Order By Name');
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        Set<id> idSet =new Set<id>();
        for(sobject s:scope)
            idSet.add(s.id);
        updateNow(idSet);
    }
    global void finish(Database.BatchableContext BC){}
    public testMethod static void testMe()
    {
        Sub_Practice_Area__c spa = new Sub_Practice_Area__c(Name='subP1');
        insert spa;
        Practice_Area__c pa = new Practice_Area__c(name='pa1');
        insert pa;
        Geography__c geog = new Geography__c(name='pa1');
        insert geog;
        Business_Line__c bl = new Business_Line__c(name='bl');
        insert bl;
        Practice_Area_Collection__c pac= new Practice_Area_Collection__c(Business_Line__c=bl.id,Geography__c=geog.id,Practice_Area__c=pa.id,Sub_Practice_Area__c=spa.id);
        insert pac;     
        List<AECOM_Primary_Department__c> lstap = new List<AECOM_Primary_Department__c>();
        
        AECOM_Primary_Department__c apd = new AECOM_Primary_Department__c();
        apd.Geography_Lookup__c = geog.Id;
        apd.Business_Line_Lookup__c = bl.id;
        apd.Geography__c = 'Test geo';
        apd.Lead_Region__c = 'Test lead';
        lstap.add(apd);
        apd = new AECOM_Primary_Department__c();
        apd.Geography_Lookup__c = geog.Id;
        apd.Business_Line_Lookup__c = bl.id;
        apd.Geography__c = 'Test geo';
        apd.Lead_Region__c = 'Test lead';
        lstap.add(apd);
        apd = new AECOM_Primary_Department__c();
        apd.Geography_Lookup__c = geog.Id;
        apd.Business_Line_Lookup__c = bl.id;
        apd.Geography__c = 'Test geo';
        apd.Lead_Region__c = 'Test lead';
        lstap.add(apd);
        apd = new AECOM_Primary_Department__c();
        apd.Geography_Lookup__c = geog.Id;
        apd.Business_Line_Lookup__c = bl.id;
        apd.Geography__c = 'Test geo';
        apd.Lead_Region__c = 'Test lead';
        lstap.add(apd);
        apd = new AECOM_Primary_Department__c();
        apd.Geography_Lookup__c = geog.Id;
        apd.Business_Line_Lookup__c = bl.id;
        apd.Geography__c = 'Test geo';
        apd.Lead_Region__c = 'Test lead';
        lstap.add(apd);
        apd = new AECOM_Primary_Department__c();
        apd.Geography_Lookup__c = geog.Id;
        apd.Business_Line_Lookup__c = bl.id;
        apd.Geography__c = 'Test geo';
        apd.Lead_Region__c = 'Test lead';
        lstap.add(apd);
        insert lstap;
        Opportunity op=new Opportunity(Legacy_OpportunityID__c='100');
        op.Name='Test case opportunity';
        op.CloseDate=Date.today().addDays(30);
        op.StageName='Prospecting';
        op.Amount=100;
        op.Win_Probability__c=10;
        op.CloseDate = Date.today().addDays(5);
        op.Book_date__c=Date.today().addDays(-1);
        op.AECOM_Primary_Dept_Lookup__c=lstap[0].Id;
        op.Enterprise_Service__c = 'Engineering';
        insert op;        
        List<Opportunity_Department__c> lstDepartMent = New List<Opportunity_Department__c>(); 
        Opportunity_Department__c oppDept = new Opportunity_Department__c(Opportunity__c =op.Id,split__c   = 50, AECOM_Department__c = lstap[0].id,Primary__c = true);
        lstDepartMent.add(oppDept);
        oppDept = new Opportunity_Department__c(Opportunity__c =op.Id,split__c   = 50, AECOM_Department__c = lstap[1].id);
        lstDepartMent.add(oppDept);
        oppDept = new Opportunity_Department__c(Opportunity__c =op.Id,split__c   = 50, AECOM_Department__c = lstap[2].id);
        lstDepartMent.add(oppDept);
        oppDept = new Opportunity_Department__c(Opportunity__c =op.Id,split__c   = 50, AECOM_Department__c = lstap[3].id);
        lstDepartMent.add(oppDept);
        oppDept = new Opportunity_Department__c(Opportunity__c =op.Id,split__c   = 50, AECOM_Department__c = lstap[4].id);
        lstDepartMent.add(oppDept);
        oppDept = new Opportunity_Department__c(Opportunity__c =op.Id,split__c   = 50, AECOM_Department__c = lstap[5].id);
        lstDepartMent.add(oppDept);
        insert lstDepartMent ;
        set<Id> OpportunitySet = new Set<id>();
        OpportunitySet.add(op.id);
        updateNow(OpportunitySet);
    }
    public static void updateNow(set<Id> OpportunitySet)
    {
        List<Opportunity> lst = new List<Opportunity>();
        system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>'+OpportunitySet);
        
        for(Opportunity opp1:[Select id,Name,(Select id,AECOM_Department__c,split__c,Business_Line__c
                                        ,Geography__c,Sub_Practice_Area__r.name,Practice_Area__r.name,Primary__c 
                                        ,Sub_Practice_Area__c,Practice_Area__c
                                        from
                                        Opportunity_Departments__r) from Opportunity where id in :OpportunitySet])
        {
            Opportunity opp = new Opportunity(id=opp1.Id);
            lst.add(opp);
            integer dept=2;
            system.debug('<<<<<<<<<<<<<'+Opp1.Name+'--'+opp1.Id);
            for(Opportunity_Department__c od:opp1.Opportunity_Departments__r)
            {
                if(od.Primary__c)
                {
                    opp.AECOM_Primary_Dept_Lookup__c = od.AECOM_Department__c;
                    opp.Practice_Area_of_Primary_AECOM_Dept__c =od.Practice_Area__c;
                    opp.Sub_Practice_Area_of_Primary_AECOM_Dept__c=od.Sub_Practice_Area__c;
                    opp.AECOM_Primary_Department_Percent__c = od.split__c;
                }
                else
                {
                    if(dept==2)
                    {
                        opp.AECOM_Department_2__c = od.AECOM_Department__c;
                        opp.AECOM_Department_2_Practice_Area__c =od.Practice_Area__r.name;
                        opp.AECOM_Department_2_Sub_Practice_Area__c=od.Sub_Practice_Area__r.name;
                        opp.AECOM_Department_2_Percent__c = od.split__c;
                    }
                    if(dept==3)
                    {
                        opp.AECOM_Department_3__c = od.AECOM_Department__c;
                        opp.AECOM_Department_3_Practice_Area__c =od.Practice_Area__r.name;
                        opp.AECOM_Department_3_Sub_Practice_Area__c=od.Sub_Practice_Area__r.name;
                        opp.AECOM_Department_3_Percent__c = od.split__c;
                    }
                    if(dept==4)
                    {
                        opp.AECOM_Department_4__c = od.AECOM_Department__c;
                        opp.AECOM_Department_4_Practice_Area__c =od.Practice_Area__r.name;
                        opp.AECOM_Department_4_Sub_Practice_Area__c=od.Sub_Practice_Area__r.name;
                        opp.AECOM_Department_4_Percent__c = od.split__c;
                    }
                    if(dept==5)
                    {
                        opp.AECOM_Department_5__c = od.AECOM_Department__c;
                        opp.AECOM_Department_5_Practice_Area__c =od.Practice_Area__r.name;
                        opp.AECOM_Department_5_Sub_Practice_Area__c=od.Sub_Practice_Area__r.name;
                        opp.AECOM_Department_5_Percent__c = od.split__c;
                    }
                    if(dept==6)
                    {
                        opp.AECOM_Department_6__c = od.AECOM_Department__c;
                        opp.AECOM_Department_6_Practice_Area__c =od.Practice_Area__r.name;
                        opp.AECOM_Department_6_Sub_Practice_Area__c=od.Sub_Practice_Area__r.name;
                        opp.AECOM_Department_6_Percent__c = od.split__c;
                    }
                    dept++;
                }
            }
        }
        List<Database.SaveResult> lstRes=Database.Update(lst,false);
        for(Database.SaveResult sr:lstRes)
        {
            if(!sr.isSuccess())
            {
                system.debug('--------------------'+sr.getId());
            }
        }
    }
}