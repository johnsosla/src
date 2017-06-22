/******************************************************************************************************************************
Created By :    Sumit
Date       :    27 Sep 2010
Reason     :    This class is controller for the Opportunity report.
*******************************************************************************************************************************/
public class opportunityCustomDepartmentReport
{
    private static final string BaseSOQL = 'Select Contract_duration_in_Months__c,Name,AccountId,Account.Name,RecordType.Name,StageName,Opportunity_ID__c,Ceiling_Amount_Total__c ,CloseDate, Estimated_work_start_date__c, AECOM_Role__c, Go_Probability__c, Probability, Subs_Other_Revenue__c, Task_Order_Number__c, Primary_Business_Line__c, Market_Segment__c, Practice_Area__c, Multiple_Geographies__c, Bid_Proposal_Charge__c, B_P_Budget__c, B_P_Actual_to_date__c, BL_Distribution__c, Book_date__c, Client_Solicitation_ID_number__c, Competitive_Bid_or_Sole_source__c, Construction_cost__c, Contract_Type__c, Date_lost_cancelled_no_go__c, Date_RFP_expected__c, Date_RFP_received__c, Date_RFQ_expected__c, Date_RFQ_received__c, Project_City__c, Project_State_Province__c, ProjectCountry__c, Submittal_Date_Proposal__c, Go_No_Go_Request_submitted_date__c, Hub_Approval_required__c, Internal_proposal_ID_number__c, Market_Sector_Priority__c, MPRC_Approval_required__c, Project_Delivery_Method__c, Proposal_Location__c, Reason_Won_or_Lost__c, Report_comments__c, Strategic_Pursuit__c, Transportation_Initiatives__c, PDD_D_P_E_Primary_Global_Practice_Line__c, PDD_D_P_E_Secondary_Global_Practice_Line__c, PDD_General_Market_Sector__c, PDD_Practice_Line__c, PDD_Services__c, Services__c, Stimulus_Funding__c, Id,Amount ,(Select AECOM_Department__r.Name, split__c,Primary__c From Opportunity_Departments__r),(Select Employee__r.Name,role__c FROM AECOM_Team1__r) FROM Opportunity Where Id != null ';
    private static final Integer MAX_RECORDS = 1000;
    public boolean isForTesting = false;
    public string limitrec = '200';
    //for multi select stage
    public string []selectedStage{get;set;}  
    public string getContentType()
    {
        if(isExport)
            return 'application/vnd.ms-excel#Opportunity.xls';
        return '';
    }
    public boolean isExport{get;set;}
    //Need picklist values of stage
    public static List<SelectOption> getStagePicklistValues() 
    {
        Schema.sObjectType t = Opportunity.getSObjectType();
        Schema.DescribeSObjectResult objDesc = t.getDescribe();
        Map<String, Schema.SObjectField> fieldsMap = objDesc.fields.getMap();
        List<Schema.PicklistEntry> pickListValues = fieldsMap.get('stagename').getDescribe().getPickListValues();
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new SelectOption('','--None--'));
        for(Schema.PicklistEntry val:pickListValues)
            options.add(new SelectOption(val.getValue(),val.getValue()));
        return options;
    }
    //Common class to contain header Names for Role and department both. We are asuming there are max 16 roles or departments
    public class MyHeaders
    {
        public string head1{get;set;}
        public string head2{get;set;}
        public string head3{get;set;}
        public string head4{get;set;}
        public string head5{get;set;}
        public string head6{get;set;}
        public string head7{get;set;}
        public string head8{get;set;}
        public string head9{get;set;}
        public string head10{get;set;}
        public string head11{get;set;}
        public string head12{get;set;}
        public string head13{get;set;}
        public string head14{get;set;}
        public string head15{get;set;}
        public string head16{get;set;}
        public MyHeaders()
        {
            head1='';head2='';head3='';head4='';head5='';head6='';head7='';head8='';head9='';head10='';head11='';
            head12='';head13='';head14='';head15='';head16='';
        }
    }
    //We are asuming max 6 Departments we have to show
    public class MyDepartments
    {
        public transient string dept1Name{get;set;}
        public transient Double dept1Per{get;set;}
        public transient string dept2Name{get;set;}
        public transient Double dept2Per{get;set;}
        public transient string dept3Name{get;set;}
        public transient Double dept3Per{get;set;}
        public transient string dept4Name{get;set;}
        public transient Double dept4Per{get;set;}
        public transient string dept5Name{get;set;}
        public transient Double dept5Per{get;set;}
        public transient string dept6Name{get;set;}
        public transient Double dept6Per{get;set;}
    }
    //Actual Coma seprated employee names wil be here corresponding to each role. here role1 contacin employee names of Head1 for roles
    public class MyRoles
    {
        public transient string role1{get;set;}
        public transient string role2{get;set;}
        public transient string role3{get;set;}
        public transient string role4{get;set;}
        public transient string role5{get;set;}
        public transient string role6{get;set;}
        public transient string role7{get;set;}
        public transient string role8{get;set;}
        public transient string role9{get;set;}
        public transient string role10{get;set;}
        public transient string role11{get;set;}
        public transient string role12{get;set;}
        public transient string role13{get;set;}
        public transient string role14{get;set;}
        public transient string role15{get;set;}
        public transient string role16{get;set;}
    }
    //Heart of the requirement. Each row contain opportunity, And concatenated strings for roles departments
    public class MyOpportunityRow
    {
        public transient Opportunity Opp{get;set;}
        public transient MyDepartments depts{get;set;}
        public transient MyRoles roles{get;set;}
        public MyOpportunityRow(Opportunity op,MyHeaders RoleHeaders,MyHeaders DeptHeaders)
        {
            Opp = op;
            depts = new MyDepartments();
            roles = new MyRoles();
            integer iCnt=2;
            //Enter department names 
            for(Opportunity_Department__c od : Opp.Opportunity_Departments__r)
            {
                if(od.Primary__c) {depts.dept1Name = od.AECOM_Department__r.Name;depts.Dept1Per = od.split__c;Continue;}
                if(iCnt==2) {depts.dept2Name = od.AECOM_Department__r.Name;depts.Dept2Per = od.split__c;}
                if(iCnt==3) {depts.dept3Name = od.AECOM_Department__r.Name;depts.Dept3Per = od.split__c;}
                if(iCnt==4) {depts.dept4Name = od.AECOM_Department__r.Name;depts.Dept4Per = od.split__c;}
                if(iCnt==5) {depts.dept5Name = od.AECOM_Department__r.Name;depts.Dept5Per = od.split__c;}
                if(iCnt==6) {depts.dept6Name = od.AECOM_Department__r.Name;depts.Dept6Per = od.split__c;}
                iCnt++;
            }
            //Enter employeenames concatenation string depending on hearde name
            for(AECOM_team__c ateam : Opp.AECOM_Team1__r)
            {
               if(ateam.Role__c ==  RoleHeaders.head1)
               {
                   string str = roles.role1;

                   if(str==null || str=='') 
                       str = ateam.Employee__r.Name; 
                   else
                       str = str+'; ' + ateam.Employee__r.Name; 
                   roles.role1 = str;
               }
               if(ateam.Role__c ==  RoleHeaders.head2)
               {
                   string str = roles.role2;
                   if(str==null || str=='') 
                       str = ateam.Employee__r.Name; 
                   else
                       str = str+'; ' + ateam.Employee__r.Name; 
                   roles.role2 = str;
               }
               if(ateam.Role__c ==  RoleHeaders.head3)
               {
                   string str = roles.role3;
                   if(str==null || str=='') 
                       str = ateam.Employee__r.Name; 
                   else
                       str = str+'; ' + ateam.Employee__r.Name; 
                   roles.role3 = str;
               }
               if(ateam.Role__c ==  RoleHeaders.head4)
               {
                   string str = roles.role4;
                   if(str==null || str=='') 
                       str = ateam.Employee__r.Name; 
                   else
                       str = str+'; ' + ateam.Employee__r.Name; 
                   roles.role4 = str;
               }
               if(ateam.Role__c ==  RoleHeaders.head5)
               {
                   string str = roles.role5;
                   if(str==null || str=='') 
                       str = ateam.Employee__r.Name; 
                   else
                       str = str+'; ' + ateam.Employee__r.Name; 
                   roles.role5 = str;
               }
               if(ateam.Role__c ==  RoleHeaders.head6)
               {
                   string str = roles.role6;
                   if(str==null || str=='') 
                       str = ateam.Employee__r.Name; 
                   else
                       str = str+'; ' + ateam.Employee__r.Name; 
                   roles.role6 = str;
               }
               if(ateam.Role__c ==  RoleHeaders.head7)
               {
                   string str = roles.role7;
                   if(str==null || str=='') 
                       str = ateam.Employee__r.Name; 
                   else
                       str = str+'; ' + ateam.Employee__r.Name; 
                   roles.role7 = str;
               }
               if(ateam.Role__c ==  RoleHeaders.head8)
               {
                   string str = roles.role8;
                   if(str==null || str=='') 
                       str = ateam.Employee__r.Name; 
                   else
                       str = str+'; ' + ateam.Employee__r.Name; 
                   roles.role8 = str;
               }
               if(ateam.Role__c ==  RoleHeaders.head9)
               {
                   string str = roles.role9;
                   if(str==null || str=='') 
                       str = ateam.Employee__r.Name; 
                   else
                       str = str+'; ' + ateam.Employee__r.Name; 
                   roles.role9 = str;
               }
               if(ateam.Role__c ==  RoleHeaders.head10)
               {
                   string str = roles.role10;
                   if(str==null || str=='') 
                       str = ateam.Employee__r.Name; 
                   else
                       str = str+'; ' + ateam.Employee__r.Name; 
                   roles.role10 = str;
               }
               if(ateam.Role__c ==  RoleHeaders.head11)
               {
                   string str = roles.role11;
                   if(str==null || str=='') 
                       str = ateam.Employee__r.Name; 
                   else
                       str = str+'; ' + ateam.Employee__r.Name; 
                   roles.role11 = str;
               }
               if(ateam.Role__c ==  RoleHeaders.head12)
               {
                   string str = roles.role12;
                   if(str==null || str=='') 
                       str = ateam.Employee__r.Name; 
                   else
                       str = str+'; ' + ateam.Employee__r.Name; 
                   roles.role12 = str;
               }
               if(ateam.Role__c ==  RoleHeaders.head13)
               {
                   string str = roles.role13;
                   if(str==null || str=='') 
                       str = ateam.Employee__r.Name; 
                   else
                       str = str+'; ' + ateam.Employee__r.Name; 
                   roles.role13 = str;
               }
               if(ateam.Role__c ==  RoleHeaders.head14)
               {
                   string str = roles.role14;
                   if(str==null || str=='') 
                       str = ateam.Employee__r.Name; 
                   else
                       str = str+'; ' + ateam.Employee__r.Name; 
                   roles.role14 = str;
               }
               if(ateam.Role__c ==  RoleHeaders.head15)
               {
                   string str = roles.role15;
                   if(str==null || str=='') 
                       str = ateam.Employee__r.Name; 
                   else
                       str = str+'; ' + ateam.Employee__r.Name; 
                   roles.role15 = str;
               }
               if(ateam.Role__c ==  RoleHeaders.head16)
               {
                   string str = roles.role16;
                   if(str==null || str=='') 
                       str = ateam.Employee__r.Name; 
                   else
                       str = str+'; ' + ateam.Employee__r.Name; 
                   roles.role16 = str;
               }
            }
        }
    }
    public MyHeaders RoleHeaders{get;set;}
    public MyHeaders DeptHeaders{get;set;}
    public transient List<MyOpportunityRow> lstMyOpportunities{get;set;}
    
    public Opportunity forFrom{get;set;}
    public Opportunity forTo{get;set;}
    public boolean ShowReport{get;set;}
    public boolean IsNoRow{get;set;}
    public void Cancel()
    {
        ShowReport = false;
        isNoRow = true;
        forFrom = new Opportunity();
        forTo = new Opportunity();
        selectedStage =new List<String>();
    }
    //constructor
    public void initializeSet()
    {
        isExport = false;
        ShowReport = false;
        IsNoRow = true;
        forFrom = new Opportunity();
        forTo = new Opportunity();
        selectedStage =new List<String>();
        DeptHeaders = new MyHeaders();
        DeptHeaders.head1 = 'Primary Department';
        DeptHeaders.head2 = 'Department 2';
        DeptHeaders.head3 = 'Department 3';
        DeptHeaders.head4 = 'Department 4';
        DeptHeaders.head5 = 'Department 5';
        RoleHeaders = new MyHeaders();
        RoleHeaders.head1 = 'Capture Manager';
        integer iCnt = 2;
        Schema.sObjectType t = AECOM_team__c.getSObjectType();
        Schema.DescribeSObjectResult objDesc = t.getDescribe();
        Map<String, Schema.SObjectField> fieldsMap = objDesc.fields.getMap();
        List<Schema.PicklistEntry> pickListValues = fieldsMap.get('role__c').getDescribe().getPickListValues();
        //get all possible roles
        for(Schema.PicklistEntry val:pickListValues)
        {
            if(val.getValue()=='Capture Manager') Continue;
            if(iCnt == 2) RoleHeaders.head2 = val.getValue();
            if(iCnt == 3) RoleHeaders.head3 = val.getValue();
            if(iCnt == 4) RoleHeaders.head4 = val.getValue();
            if(iCnt == 5) RoleHeaders.head5 = val.getValue();
            if(iCnt == 6) RoleHeaders.head6 = val.getValue();
            if(iCnt == 7) RoleHeaders.head7 = val.getValue();
            if(iCnt == 8) RoleHeaders.head8 = val.getValue();
            if(iCnt == 9) RoleHeaders.head9 = val.getValue();
            if(iCnt == 10) RoleHeaders.head10 = val.getValue();
            if(iCnt == 11) RoleHeaders.head11 = val.getValue();
            if(iCnt == 12) RoleHeaders.head12 = val.getValue();
            if(iCnt == 13) RoleHeaders.head13 = val.getValue();
            if(iCnt == 14) RoleHeaders.head14 = val.getValue();
            if(iCnt == 15) RoleHeaders.head15 = val.getValue();
            if(iCnt == 16) RoleHeaders.head16 = val.getValue();
            iCnt++;
        }
    }
    //This constructor will called only when click on export button by any view
    private List<id> lstIdOfOpportunities;
    public opportunityCustomDepartmentReport(ApexPages.StandardSetController stdSetCtrl)
    {
        initializeSet();
        if(ApexPages.currentPage().getParameters().get('export')=='1')
        {
            isExport=true;
            string soql = ApexPages.currentPage().getParameters().get('soql');
            
            soql = EncodingUtil.base64Decode(soql).toString();
            soql = BaseSOQL + soql;
            //soql = soql.replace('GREATER_THEN_EQUAL_TO','>=');
            //soql = soql.replace('LESS_THEN_EQUAL_TO','<=');
            
            
            forF = Date.NewInstance(integer.valueOf(ApexPages.currentPage().getParameters().get('fyy')),
                                    integer.valueOf(ApexPages.currentPage().getParameters().get('fmm')),
                                    integer.valueOf(ApexPages.currentPage().getParameters().get('fdd')));
            forT = Date.NewInstance(integer.valueOf(ApexPages.currentPage().getParameters().get('tyy')),
                                    integer.valueOf(ApexPages.currentPage().getParameters().get('tmm')),
                                    integer.valueOf(ApexPages.currentPage().getParameters().get('tdd')));                        
           soql = soql + ' LIMIT 1000';
           runreport(soql); 
           return;            
        }
        if(ApexPages.currentPage().getParameters().get('export')=='0' || stdSetCtrl ==null)
            return;
        lstIdOfOpportunities = new List<id>();
        while (true) 
        {
            Opportunity[] opps = (Opportunity[])stdSetCtrl.getRecords();
            for (Integer i = 0; ((i < opps.size()) && (lstIdOfOpportunities.size() < MAX_RECORDS)); i++) 
                lstIdOfOpportunities.add(opps[i].Id);    
            if (lstIdOfOpportunities.size() >= MAX_RECORDS) 
                break;    
            if (!stdSetCtrl.getHasNext())
                break;
            stdSetCtrl.next();             
        }
        isExport=true;
        string soql = baseSoql + ' and ID in :lstIdOfOpportunities';
        runreport(soql);             
    }
    public string forExportURL{get;set;}
    //when use click on filter button
    public void ClickedOnRunreport()
    {
        if(forFrom.Closedate!=null && forTo.Closedate!=null)
        {
            if(forFrom.Closedate>forTo.Closedate)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'From Date must be less than or equals to To date.'));
                return;
            }
            for(Organization  org: [Select UsesStartDateAsFiscalYearName, FiscalYearStartMonth From Organization LIMIT 1])
            {
                if(org.UsesStartDateAsFiscalYearName!=null)
                {
                   integer sfiscal =  forFrom.Closedate.year();
                   integer ffiscal =  forTo.Closedate.year();
                   if(org.UsesStartDateAsFiscalYearName)
                   {
                       if(forFrom.Closedate.month()<org.FiscalYearStartMonth)
                           sfiscal--;
                       if(forTo.Closedate.month()<org.FiscalYearStartMonth)
                           ffiscal--;
                   }
                   else
                   {
                       if(forFrom.Closedate.month()>=org.FiscalYearStartMonth)
                           sfiscal++;
                       if(forTo.Closedate.month()>=org.FiscalYearStartMonth)
                           ffiscal++;
                   }
                   if(sfiscal!=ffiscal)
                   {
                       ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Dates should be in same fiscal year.'));
                       return;
                   }
                }
            }
        }
        if((forFrom.Amount==null && forTo.Amount!=null) || (forFrom.Amount!=null && forTo.Amount==null))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Range of Amount is invalid. Fill both or none.'));
            return;
        }
        
        if(forFrom.Amount!=null && forTo.Amount!=null)
        {
            if(forFrom.Amount>forTo.Amount)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Range of Amount is invalid.'));
                return;
            }
        }
        string soql = getSoql();
        soql = soql + ' LIMIT '+limitrec;
        runreport(soql);
    }
    Date forF;
    Date forT;
    //main logic to create soql
    private string getSoql()
    {
        forF = forFrom.Closedate;
        forT = forTo.Closedate;
        string soql = ' ';// = BaseSOQL;
         if(!isForTesting)
         {
             if(forFrom.Closedate!=null)
                   soql  = soql +' AND CloseDate >= :forF'; 
             if(forTo.Closedate!=null)
                   soql  = soql +' AND CloseDate <= :forT';
             
             if(forFrom.Amount!=null && forTo.Amount!=null)
             {
                 string soql1 = ' AND ((RecordType.Name in (\'Project - North America\',\'Task Order - North America\',\'Project - Asia\',\'Task Order - Asia\') AND Amount >= ' + forFrom.Amount +' AND Amount <= ' + forTo.Amount +') OR ';
                 soql1 += '(RecordType.Name in (\'Program - North America\',\'Program - Asia\') AND Ceiling_Amount_Total__c >= ' + forFrom.Amount +' AND Ceiling_Amount_Total__c <= ' + forTo.Amount +')) ';
                 soql  = soql + soql1;
                 
                 //if(forFrom.Amount!=null)
                 //      soql  = soql +' AND Amount>=' + forFrom.Amount;
                 //if(forTo.Amount!=null)
                 //      soql  = soql +' AND Amount<=' + forTo.Amount;
             }
             //if(forFrom.StageName!=null)
             //      soql  = soql +' AND Stagename =\'' + String.escapeSingleQuotes(forFrom.StageName) +'\'';
             if(selectedStage.size()>0)
             {
                 string stages = '';
                 for(string str:selectedStage)
                 {
                     string st = '\'' + String.escapeSingleQuotes(str) +'\'';
                     if(stages =='')
                         stages = st;
                     else
                         stages = stages +',' + st;
                 }
                  soql  = soql +' AND Stagename IN (' + stages +')';
             }
             if(forFrom.Primary_Business_Line__c!=null)
                   soql  = soql +' AND Primary_Business_Line__c=\'' + String.escapeSingleQuotes(forFrom.Primary_Business_Line__c) +'\'';
             if(forFrom.Market_Segment__c!=null)
                   soql  = soql +' AND Market_Segment__c=\'' + String.escapeSingleQuotes(forFrom.Market_Segment__c) +'\'';
         }
         string encsoql = EncodingUtil.base64Encode(Blob.valueof(soql));
         //encsoql = encsoql.replace('>=','GREATER_THEN_EQUAL_TO');
         //encsoql = encsoql.replace('<=','LESS_THEN_EQUAL_TO');
         
         forExportURL = '/apex/opportunityCustomDepartmentReport?export=1&soql='+encsoql;
         forExportURL=forExportURL + '&fyy=' + forF.Year();
         forExportURL=forExportURL + '&fmm=' + forF.Month();
         forExportURL=forExportURL + '&fdd=' + forF.Day();
         forExportURL=forExportURL + '&tyy=' + fort.Year();
         forExportURL=forExportURL + '&tmm=' + fort.Month();
         forExportURL=forExportURL + '&tdd=' + fort.Day();
         
         return BaseSOQL + soql;
    }
    public void runreport(string soql)
    {
        system.debug('*******************************************************************');
        system.debug(soql);
        system.debug('*******************************************************************');
        ShowReport = true;
        IsNoRow = true;
        lstMyOpportunities = new List<MyOpportunityRow>();
        for(Opportunity opp:Database.Query(soql))
        {
            lstMyOpportunities.add(new MyOpportunityRow(opp,RoleHeaders,DeptHeaders));
            IsNoRow = false;
        }
    }
}