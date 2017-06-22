global with sharing class ECO_PMD_CostDetail_Controller {

	public ECO_PMD_CostDetail_Controller() {
    }

    public ECO_PMD_CostDetail_Controller(ApexPages.StandardController stdController) {
    }

    private final pse__Proj__c oProject ;

    public string locale { get {return UserInfo.getLocale().replace('_', '-');} }

    public ECO_PMD_ProjectWrapper wrapper { get; set; }

    public string projectName;

    public string getProjectName() {
        return projectName;
    }

    public void setProjectName(string prjId) {
        pse__Proj__c project = [select Name, OracleProjectNumber__c
                                from pse__Proj__c where Id = :prjId];
        projectName = project.OracleProjectNumber__c + ' - ' + project.Name;
    }

    @RemoteAction @ReadOnly
    global static List<CostDist> GetCostDistLines(String projectId, Id offsetId, String layout) // projectNum)
    {
        //projectNum like '60214130'
        //String projectId = 'a32e00000002t8x'; //
        String offsetIdSearch = (offsetId==null)?'0':offsetId;

        String layoutClause;

        if (layout == 'LabourHours' || layout == 'LabourCost') {
            layoutClause = ' and ExpenditureItem__r.ExpenditureType__c like \'LAB%\'';
        } else if (layout == 'ODCExpenses') {
            layoutClause = ' and (not ExpenditureItem__r.ExpenditureType__c like \'LAB%\')'
                + ' and (not ExpenditureItem__r.ExpenditureType__c like \'CON%\')'
                + ' and (not ExpenditureItem__r.ExpenditureType__c like \'SUBC%\')';
        } else if (layout == 'ODCSubs') {
            layoutClause = ' and (ExpenditureItem__r.ExpenditureType__c like \'CON%\''
                + ' or ExpenditureItem__r.ExpenditureType__c like \'SUBC%\')';
        } else {
            layoutClause = '';
        }

        List<CostDistLine__c> costDistLines = Database.query(
                'SELECT Id'
                +', PAPeriodName__c'
                +', PADate__c'
                +'  , PAFiscalMonth__c'
                +', GLPeriodName__c'
                +'  , GLDate__c'
                +'  , GLFiscalMonth__c'
                +', ProjectFunctionalCurrencyCode__c'
                +', ProjectFunctionalBurdenedCost__c'
                +'  , ProjectFunctionalRawCost__c'
                +', ProjectCurrencyCode__c'
                +', ProjectBurdenedCost__c'
                +'  , ProjectRawCost__c'
                +'  , DenomCurrencyCode__c'
                +'  , DenomBurdenedCost__c'
                +'  , DenomRawCost__c'
                +', PLReportCategory__c'
                +'  , PLLaborHours__c'
                +'  , LineNumber__c'
                +'  , Quantity__c'
                +'  , UOM__c'
                +'  , ExpenditureItem__c'
                +'  , ExpenditureItem__r.ExpenditureItemID__c'
                +', ExpenditureItem__r.PersonId__c'
                +', ExpenditureItem__r.EmployeeName__c'
                +', ExpenditureItem__r.EmployeeJobTitle__c'
                +', ExpenditureItem__r.ExpenditureType__c'
                +', ExpenditureItem__r.ExpenditureItemDate__c'
                +', ExpenditureItem__r.VendorId__c'
                +', ExpenditureItem__r.ExpenditureOrgId__c'
                +', ExpenditureItem__r.Quantity__c'
                +', ExpenditureItem__r.BillRateNum__c'
                +', ExpenditureItem__r.BillAmountNum__c'
                +', ExpenditureItem__r.BillableFlag__c'
                +', ExpenditureItem__r.AP_InvoiceImageFileURL__c'
                +', ExpenditureItem__r.InvoiceNumber__c'
                +', ExpenditureItem__r.VoucherNumber__c'
                +', ExpenditureItem__r.ProjectTask__r.Name'
                +', ExpenditureItem__r.ProjectTask__r.ProjectTaskNumber__c'
                +' FROM  CostDistLine__c'
                +' WHERE ExpenditureItem__r.ProjectTask__r.pse__Project__c = :projectId'
                + layoutClause
                +' AND   Id > :offsetIdSearch ORDER BY Id ASC LIMIT '+'2500'
        );


        //EMPLOYEE DETAILS
        List<AggregateResult> groupedPeople = [select ExpenditureItem__r.PersonId__c
                from CostDistLine__c
                where ExpenditureItem__r.ProjectTask__r.pse__Project__r.Id = :projectId
                group by ExpenditureItem__r.PersonId__c
                limit 500];

        List<string> personIds = new List<string>();
        for (AggregateResult ar : groupedPeople)
        {
            personIds.add((string)ar.get('PersonId__c'));
        }
        System.debug(personIds);

        Map<string, Contact> employees = new Map<string,Contact>();
        for(Contact e : [SELECT Person_ID__c, psa_report__Resource_Name__c, JobName__c , OracleContactID__c
                    FROM Contact WHERE Person_ID__c != '' and Person_ID__c IN :personIds])
        {
            employees.put(e.Person_ID__c, e);
        }
        System.debug('lfxxxx' +  employees);


        //VENDER/ACCOUNT DETAILS
        List<AggregateResult> groupedVendors = [select ExpenditureItem__r.VendorId__c
                from CostDistLine__c
                where ExpenditureItem__r.ProjectTask__r.pse__Project__r.Id = :projectId
                group by ExpenditureItem__r.VendorId__c
                limit 500];

        List<string> vendorIds = new List<string>();
        for (AggregateResult ar : groupedVendors)
        {
            vendorIds.add((string)ar.get('VendorId__c'));
        }
        System.debug(vendorIds);

        Map<string, Account> vendors = new Map<string,Account>();
        for(Account c : [SELECT OracleVendorID__c, name
                    FROM Account WHERE OracleVendorID__c != '' and OracleVendorID__c IN :vendorIds])
        {
            vendors.put(c.OracleVendorID__c, c);
        }
        System.debug('lfxxxx' +  vendors);

        // ORGANISATION DETAILS
         List<AggregateResult> groupedOrgs = [select ExpenditureItem__r.ExpenditureOrgId__c
                from CostDistLine__c
                where ExpenditureItem__r.ProjectTask__r.pse__Project__r.Id = :projectId
                group by ExpenditureItem__r.ExpenditureOrgId__c
                limit 500];

        List<string> orgIds = new List<string>();
        for (AggregateResult ar : groupedOrgs)
        {
            orgIds.add((string)ar.get('ExpenditureOrgId__c'));
        }
        System.debug(orgIds);

        Map<string, OrganizationString__c> orgs = new Map<string,OrganizationString__c>();
        for(OrganizationString__c o : [SELECT OperatingGroup__c, OrgID__c, GeographyName__c, Region__c
                        , District__c, BusinessLineName__c, SubBusinessLineName__c
                        FROM OrganizationString__c WHERE OrgID__c IN :orgIds])
        {
            orgs.put(o.OrgID__c, o);
        }
        System.debug('lfxxxx' +  orgs);



        // Assemble the joins

        List<CostDist> costdists = new List<CostDist>();
        for(CostDistLine__c item : costDistLines) {

            CostDist costdist = new CostDist();

            try
            {
                if (item.ExpenditureItem__r.PersonId__c <> '' )
                {
                    if ( employees.containsKey(item.ExpenditureItem__r.PersonId__c) ){
                        Contact employee = employees.get(item.ExpenditureItem__r.PersonId__c);
                        costdist.EmployeeNumber = employee.OracleContactID__c ;
                        costdist.EmployeeName = item.ExpenditureItem__r.EmployeeName__c; // for a consistent format
                        // costdist.EmployeeName = employee.psa_report__Resource_Name__c;
                        costdist.EmployeeClassification = employee.JobName__c;
                    } else {
                        // Use data from Expenditure Item
                        costdist.EmployeeNumber = item.ExpenditureItem__r.PersonId__c;
                        costdist.EmployeeName = item.ExpenditureItem__r.EmployeeName__c;
                        costdist.EmployeeClassification = item.ExpenditureItem__r.EmployeeJobTitle__c;
                    }
                 }
            }catch(Exception ex){}

            try
            {
                if (item.ExpenditureItem__r.VendorId__c <> '')
                {
                    Account vendor = vendors.get(item.ExpenditureItem__r.VendorId__c);
                    costdist.VenderName = vendor.Name ;
                    System.debug('VendorName::::' + vendor.Name);
                 }
            }catch(Exception ex){}

            try
            {
                if (item.ExpenditureItem__r.ExpenditureOrgId__c <> '')
                {
                    OrganizationString__c orgstr = orgs.get(item.ExpenditureItem__r.ExpenditureOrgId__c);
                    costdist.OperatingGroup = orgstr.OperatingGroup__c ;
                    costdist.GeographyName = orgstr.GeographyName__c ;
                    costdist.Region = orgstr.Region__c ;
                    costdist.District = orgstr.District__c ;
                    costdist.BusinessLineName = orgstr.BusinessLineName__c ;
                    costdist.SubBusinessLineName = orgstr.SubBusinessLineName__c ;
                 }
            }catch(Exception ex){}


            costdist.CostDistLine_Id = item.Id;
              costdist.CostDistLine_LineNumber = item.LineNumber__c;

            costdist.CostDistLine_PAPeriodName =item.PAPeriodName__c;
            costdist.CostDistLine_PADate = item.PADate__c;
              costdist.CostDistLine_PAFiscalMonth = item.PAFiscalMonth__c;
            costdist.CostDistLine_GLPeriodName =item.GLPeriodName__c;
              costdist.CostDistLine_GLDate = item.GLDate__c;
              costdist.CostDistLine_GLFiscalMonth = item.GLFiscalMonth__c;
            costdist.CostDistLine_ProjectFunctionalCurrencyCode =item.ProjectFunctionalCurrencyCode__c;
            costdist.CostDistLine_ProjectFunctionalBurdenedCost =item.ProjectFunctionalBurdenedCost__c;
              costdist.CostDistLine_ProjectFunctionalRawCost =item.ProjectFunctionalRawCost__c;

            costdist.CostDistLine_ProjectCurrencyCode =item.ProjectCurrencyCode__c;
            costdist.CostDistLine_ProjectBurdenedCost =item.ProjectBurdenedCost__c;
              costdist.CostDistLine_ProjectRawCost =item.ProjectRawCost__c;

              costdist.CostDistLine_DenomCurrencyCode =item.DenomCurrencyCode__c;
              costdist.CostDistLine_DenomBurdenedCost =item.DenomBurdenedCost__c;
              costdist.CostDistLine_DenomRawCost =item.DenomRawCost__c;

            costdist.CostDistLine_PLReportCategory =item.PLReportCategory__c;
              costdist.CostDistLine_Quantity  =item.Quantity__c;
              costdist.CostDistLine_UOM  =item.UOM__c;
              costdist.CostDistLine_PLLaborHours  =item.PLLaborHours__c;

              costdist.ExpenditureItem_Id = item.ExpenditureItem__c;
              costdist.ExpenditureItem_ExpenditureItemID = item.ExpenditureItem__r.ExpenditureItemID__c;
            costdist.ExpenditureItem_PersonId =item.ExpenditureItem__r.PersonId__c;
            costdist.ExpenditureItem_ExpenditureType =item.ExpenditureItem__r.ExpenditureType__c;
            costdist.ExpenditureItem_ExpenditureItemDate  =item.ExpenditureItem__r.ExpenditureItemDate__c;
            costdist.ExpenditureItem_VendorId  =item.ExpenditureItem__r.VendorId__c;
            costdist.ExpenditureItem_ExpenditureOrgId  =item.ExpenditureItem__r.ExpenditureOrgId__c;
            //costdist.ExpenditureItem_Quantity  =item.ExpenditureItem__r.Quantity__c;
            costdist.ExpenditureItem_BillRate  =item.ExpenditureItem__r.BillRateNum__c;
            costdist.ExpenditureItem_BillAmount  =item.ExpenditureItem__r.BillAmountNum__c;
            costdist.ExpenditureItem_BillableFlag  =item.ExpenditureItem__r.BillableFlag__c;
            costdist.ExpenditureItem_AP_InvoiceImageFileURL  =item.ExpenditureItem__r.AP_InvoiceImageFileURL__c;
            costdist.ExpenditureItem_InvoiceNumber  =item.ExpenditureItem__r.InvoiceNumber__c;
            costdist.ExpenditureItem_VoucherNumber  =item.ExpenditureItem__r.VoucherNumber__c;
            costdist.ExpenditureItem_ProjectTaskName  =item.ExpenditureItem__r.ProjectTask__r.Name;
            costdist.ExpenditureItem_ProjectTaskNumber  =item.ExpenditureItem__r.ProjectTask__r.ProjectTaskNumber__c;
            costdists.add(costdist);
        }

        return costdists;
    }



     global class CostDist{

        public id      CostDistLine_Id {get; set;}
          public decimal CostDistLine_LineNumber {get; set;}

        public string  CostDistLine_PAPeriodName {get; set;}
        public date    CostDistLine_PADate {get; set;}
          public string  CostDistLine_PAFiscalMonth {get; set;}
        public string  CostDistLine_GLPeriodName {get; set;}
          public date    CostDistLine_GLDate {get; set;}
          public string  CostDistLine_GLFiscalMonth {get; set;}
        public string  CostDistLine_ProjectFunctionalCurrencyCode {get; set;}
        public decimal CostDistLine_ProjectFunctionalBurdenedCost {get; set;}
          public decimal CostDistLine_ProjectFunctionalRawCost {get; set;}
        public string  CostDistLine_ProjectCurrencyCode {get; set;}
        public decimal CostDistLine_ProjectBurdenedCost {get; set;}
          public decimal CostDistLine_ProjectRawCost {get; set;}
          public string  CostDistLine_DenomCurrencyCode {get; set;}
          public decimal CostDistLine_DenomBurdenedCost {get; set;}
          public decimal CostDistLine_DenomRawCost {get; set;}
        public string  CostDistLine_PLReportCategory {get; set;}
          public string  CostDistLine_UOM  {get; set;}
          public decimal CostDistLine_PLLaborHours  {get; set;}
          public decimal CostDistLine_Quantity  {get; set;}

          public id    ExpenditureItem_Id  {get; set;}
          public string  ExpenditureItem_ExpenditureItemID {get; set;}
        public string  ExpenditureItem_PersonId {get; set;}
        public string  ExpenditureItem_ExpenditureType  {get; set;}
        public date    ExpenditureItem_ExpenditureItemDate  {get; set;}
        public string  ExpenditureItem_VendorId  {get; set;}
        public string  ExpenditureItem_ExpenditureOrgId  {get; set;}
        public decimal ExpenditureItem_BillRate  {get; set;}
        public decimal ExpenditureItem_BillAmount  {get; set;}
        public string  ExpenditureItem_BillableFlag  {get; set;}
        public string  ExpenditureItem_AP_InvoiceImageFileURL  {get; set;}
        public string  ExpenditureItem_InvoiceNumber  {get; set;}
        public string  ExpenditureItem_VoucherNumber  {get; set;}
        public string  ExpenditureItem_DenomTaskName  {get; set;}
        public string  ExpenditureItem_ProjectTaskName  {get; set;}
        public string  ExpenditureItem_ProjectTaskNumber  {get; set;}

        public string  EmployeeNumber {get; set;}
        public string  EmployeeName {get; set;}
        public string  EmployeeClassification {get; set;}

        public string  VenderName  {get; set;}

        public string  OperatingGroup {get; set;}
        public string  GeographyName {get; set;}
        public string  Region {get; set;}
        public string  District {get; set;}
        public string  BusinessLineName {get; set;}
        public string  SubBusinessLineName {get; set;}

        public id  ExpenditureItem_ProjectId {get; set;}
        public string  ExpenditureItem_ProjectNumber {get; set;}
        public string  ExpenditureItem_ProjectName {get; set;}

        /*public id userId {get; set;}
        public string userName {get; set;}
        public string personId {get; set;}
        public id expendItemId {get; set;}
        public string expendItemName {get; set;}
        */

    }

    @RemoteAction @ReadOnly
    global static List<CostDist> GetCostDistLinesViaExpendItems(String projectId, Id offsetId1, Id offsetId2, String layout) // projectNum)
    {
        //projectNum like '60214130'
        //String projectId = 'a32e00000002t8x'; //
        String offsetProjectId = (offsetId1==null)?'0':offsetId1;
        String offsetExpItemId = (offsetId2==null)?'0':offsetId2;

        String layoutClause;

        if (layout == 'LabourHours' || layout == 'LabourCost') {
            layoutClause = ' and ExpenditureType__c like \'LAB%\'';
        } else if (layout == 'ODCExpenses') {
            layoutClause = ' and (not ExpenditureType__c like \'LAB%\')'
                + ' and (not ExpenditureType__c like \'CON%\')'
                + ' and (not ExpenditureType__c like \'SUBC%\')';
        } else if (layout == 'ODCSubs') {
            layoutClause = ' and (ExpenditureType__c like \'CON%\''
                + ' or ExpenditureType__c like \'SUBC%\')';
        } else {
            layoutClause = '';
        }

        Date sinceDate;
        String sinceClauseCDL = '';
        String sinceClauseExpItem = '';
        Id currentUserId = UserInfo.getUserId();
        if (Test.isRunningTest()) {
            User testUser = [SELECT Id from User LIMIT 1];
            currentUserId = testUser.Id;
        }
        //currentUserId = '005a0000009JdGt'; //'005a0000008M3Rp';//'005a0000008k4lr';

        List<Id> currentUserProjectIds = new List<Id>();
        if (projectId !=null) {
            currentUserProjectIds.add(projectId);
        } else {
            Date asOf = Date.today(); // Date.NewInstance(2016,6,1);
            if(Test.isRunningTest()) asOf = Date.newInstance(2015,12,3);
            Date fiscalWeekStart = (asOf.daysBetween(asOf.toStartOfWeek())<=-6)?asOf:asOf.toStartOfWeek().addDays(-1); // toStartOfWeek is sunday, fiscal week starts on Saturday
            sinceDate = fiscalWeekStart.addDays(-5*7);  // this week partial plus five fiscal weeks prior makes entire fiscal month available (up to 6 weeks in leap year)
            // System.debug('____sinceDate='+sinceDate);
            sinceClauseCDL     = '  WHERE PADate__c >= :sinceDate';
            sinceClauseExpItem = '    AND CurrentPADate__c >= :sinceDate';

            for(ProjectTeamMember__c ptm : [
              SELECT Project__c
              FROM ProjectTeamMember__c
              WHERE Is_Active__c = true
              AND Contact__c != null
              AND Contact__r.pse__Salesforce_User__c = :currentUserId
              AND ProjectRoleName__c = 'Project Manager'
              ORDER BY Project__c DESC
              LIMIT 500
            ]){
                currentUserProjectIds.add(ptm.Project__c);
            } // Arbitrary limit to help avoid 20,000 character SOQL limit
        }

        String query =
          'SELECT Project__c'
          + ', Id'
          + ', ExpenditureItemID__c'
          + ', PersonId__c'
          + ', EmployeeName__c'
          + ', EmployeeJobTitle__c'
          + ', ExpenditureType__c'
          + ', ExpenditureItemDate__c'
          + ', VendorId__c'
          + ', ExpenditureOrgId__c'
          + ', Quantity__c'
          + ', BillRateNum__c'
          + ', BillAmountNum__c'
          + ', BillableFlag__c'
          + ', AP_InvoiceImageFileURL__c'
          + ', InvoiceNumber__c'
          + ', VoucherNumber__c'
          + ', ProjectTask__r.Name'
          + ', ProjectTask__r.ProjectTaskNumber__c'
          + ', Project__r.Name'
          + ', Project__r.OracleProjectNumber__c'
          + ',(SELECT Id'
          + '  , PAPeriodName__c'
          + '  , PADate__c'
          + '  , PAFiscalMonth__c'
          + '  , GLPeriodName__c'
          + '  , GLDate__c'
          + '  , GLFiscalMonth__c'
          + '  , ProjectFunctionalCurrencyCode__c'
          + '  , ProjectFunctionalBurdenedCost__c'
          + '  , ProjectFunctionalRawCost__c'
          + '  , ProjectCurrencyCode__c'
          + '  , ProjectBurdenedCost__c'
          + '  , ProjectRawCost__c'
          + '  , DenomCurrencyCode__c'
          + '  , DenomBurdenedCost__c'
          + '  , DenomRawCost__c'
          + '  , PLReportCategory__c'
          + '  , PLLaborHours__c'
          + '  , LineNumber__c'
          + '  , Quantity__c'
          + '  , UOM__c '
          + '  FROM CostDistributionLinesExpenditureItem__r'
          + sinceClauseCDL
          + ')'
          + ' FROM  ExpendItem__c'
          + ' WHERE Project__c in :currentUserProjectIds'
          + sinceClauseExpItem
          + layoutClause
          + '   AND ( (Project__c = :offsetProjectId AND Id > :offsetExpItemId) '
          + '          OR Project__c > :offsetProjectId )'
          + ' ORDER BY Project__c ASC, Id ASC'
          + ' LIMIT 2500';

        List<ExpendItem__c> expendItems = Database.query(query);

        for(Integer i=0;i<expendItems.size();i++){ System.debug('_____project+id='+expendItems[i].project__c+'/'+expendItems[i].id);}


        //EMPLOYEE DETAILS
        List<AggregateResult> groupedPeople = [select ExpenditureItem__r.PersonId__c
                from CostDistLine__c
                where ExpenditureItem__r.ProjectTask__r.pse__Project__r.Id in :currentUserProjectIds
                group by ExpenditureItem__r.PersonId__c
                limit 500];

        List<string> personIds = new List<string>();
        for (AggregateResult ar : groupedPeople)
        {
            personIds.add((string)ar.get('PersonId__c'));
        }
        System.debug(personIds);

        Map<string, Contact> employees = new Map<string,Contact>();
        for(Contact e : [SELECT Person_ID__c, psa_report__Resource_Name__c, JobName__c , OracleContactID__c
                    FROM Contact WHERE Person_ID__c != '' and Person_ID__c IN :personIds])
        {
            employees.put(e.Person_ID__c, e);
        }
        System.debug('lfxxxx' +  employees);


        //VENDER/ACCOUNT DETAILS
        List<AggregateResult> groupedVendors = [select ExpenditureItem__r.VendorId__c
                from CostDistLine__c
                where ExpenditureItem__r.ProjectTask__r.pse__Project__r.Id IN :currentUserProjectIds
                group by ExpenditureItem__r.VendorId__c
                limit 500];

        List<string> vendorIds = new List<string>();
        for (AggregateResult ar : groupedVendors)
        {
            vendorIds.add((string)ar.get('VendorId__c'));
        }
        System.debug(vendorIds);

        Map<string, Account> vendors = new Map<string,Account>();
        for(Account c : [SELECT OracleVendorID__c, name
                    FROM Account WHERE OracleVendorID__c != '' and OracleVendorID__c IN :vendorIds])
        {
            vendors.put(c.OracleVendorID__c, c);
        }
        System.debug('lfxxxx' +  vendors);

        // ORGANISATION DETAILS
         List<AggregateResult> groupedOrgs = [select ExpenditureItem__r.ExpenditureOrgId__c
                from CostDistLine__c
                where ExpenditureItem__r.ProjectTask__r.pse__Project__r.Id IN :currentUserProjectIds
                group by ExpenditureItem__r.ExpenditureOrgId__c
                limit 500];

        List<string> orgIds = new List<string>();
        for (AggregateResult ar : groupedOrgs)
        {
            orgIds.add((string)ar.get('ExpenditureOrgId__c'));
        }
        System.debug(orgIds);

        Map<string, OrganizationString__c> orgs = new Map<string,OrganizationString__c>();
        for(OrganizationString__c o : [SELECT OperatingGroup__c, OrgID__c, GeographyName__c, Region__c
                        , District__c, BusinessLineName__c, SubBusinessLineName__c
                        FROM OrganizationString__c WHERE OrgID__c IN :orgIds])
        {
            orgs.put(o.OrgID__c, o);
        }
        System.debug('lfxxxx' +  orgs);



        // Assemble the joins

        List<CostDist> costdists = new List<CostDist>();
        for(ExpendItem__c expendItem : expendItems) {
          for (CostDistLine__c cdl : expendItem.CostDistributionLinesExpenditureItem__r) {

            CostDist costdist = new CostDist();

            try
            {
                if (expendItem.PersonId__c <> '' )
                {
                    if ( employees.containsKey(expendItem.PersonId__c) ){
                        Contact employee = employees.get(expendItem.PersonId__c);
                        costdist.EmployeeNumber = employee.OracleContactID__c ;
                        costdist.EmployeeName = expendItem.EmployeeName__c; // for a consistent format
                        // costdist.EmployeeName = employee.psa_report__Resource_Name__c;
                        costdist.EmployeeClassification = employee.JobName__c;
                    } else {
                        // Use data from Expenditure Item
                        costdist.EmployeeNumber = expendItem.PersonId__c;
                        costdist.EmployeeName = expendItem.EmployeeName__c;
                        costdist.EmployeeClassification = expendItem.EmployeeJobTitle__c;
                    }
                 }
            }catch(Exception ex){}

            try
            {
                if (expendItem.VendorId__c <> '')
                {
                    Account vendor = vendors.get(expendItem.VendorId__c);
                    costdist.VenderName = vendor.Name ;
                    System.debug('VendorName::::' + vendor.Name);
                 }
            }catch(Exception ex){}

            try
            {
                if (expendItem.ExpenditureOrgId__c <> '')
                {
                    OrganizationString__c orgstr = orgs.get(expendItem.ExpenditureOrgId__c);
                    costdist.OperatingGroup = orgstr.OperatingGroup__c ;
                    costdist.GeographyName = orgstr.GeographyName__c ;
                    costdist.Region = orgstr.Region__c ;
                    costdist.District = orgstr.District__c ;
                    costdist.BusinessLineName = orgstr.BusinessLineName__c ;
                    costdist.SubBusinessLineName = orgstr.SubBusinessLineName__c ;
                 }
            }catch(Exception ex){}


            costdist.CostDistLine_Id = cdl.Id;
            costdist.CostDistLine_LineNumber = cdl.LineNumber__c;

            costdist.CostDistLine_PAPeriodName =cdl.PAPeriodName__c;
            costdist.CostDistLine_PADate = cdl.PADate__c;
            costdist.CostDistLine_PAFiscalMonth = cdl.PAFiscalMonth__c;
            costdist.CostDistLine_GLPeriodName =cdl.GLPeriodName__c;
            costdist.CostDistLine_GLDate = cdl.GLDate__c;
            costdist.CostDistLine_GLFiscalMonth = cdl.GLFiscalMonth__c;
            costdist.CostDistLine_ProjectFunctionalCurrencyCode =cdl.ProjectFunctionalCurrencyCode__c;
            costdist.CostDistLine_ProjectFunctionalBurdenedCost =cdl.ProjectFunctionalBurdenedCost__c;
            costdist.CostDistLine_ProjectFunctionalRawCost =cdl.ProjectFunctionalRawCost__c;

            costdist.CostDistLine_ProjectCurrencyCode =cdl.ProjectCurrencyCode__c;
            costdist.CostDistLine_ProjectBurdenedCost =cdl.ProjectBurdenedCost__c;
            costdist.CostDistLine_ProjectRawCost =cdl.ProjectRawCost__c;

            costdist.CostDistLine_DenomCurrencyCode =cdl.DenomCurrencyCode__c;
            costdist.CostDistLine_DenomBurdenedCost =cdl.DenomBurdenedCost__c;
            costdist.CostDistLine_DenomRawCost =cdl.DenomRawCost__c;

            costdist.CostDistLine_PLReportCategory =cdl.PLReportCategory__c;
            costdist.CostDistLine_Quantity  =cdl.Quantity__c;
            costdist.CostDistLine_UOM  =cdl.UOM__c;
            costdist.CostDistLine_PLLaborHours  =cdl.PLLaborHours__c;

            costdist.ExpenditureItem_Id = expendItem.Id;
            costdist.ExpenditureItem_ExpenditureItemID = expendItem.ExpenditureItemID__c;
            costdist.ExpenditureItem_PersonId =expendItem.PersonId__c;
            costdist.ExpenditureItem_ExpenditureType =expendItem.ExpenditureType__c;
            costdist.ExpenditureItem_ExpenditureItemDate  =expendItem.ExpenditureItemDate__c;
            costdist.ExpenditureItem_VendorId  =expendItem.VendorId__c;
            costdist.ExpenditureItem_ExpenditureOrgId  =expendItem.ExpenditureOrgId__c;
            //costdist.ExpenditureItem_Quantity  =expendItem.Quantity__c;
            costdist.ExpenditureItem_BillRate  =expendItem.BillRateNum__c;
            costdist.ExpenditureItem_BillAmount  =expendItem.BillAmountNum__c;
            costdist.ExpenditureItem_BillableFlag  =expendItem.BillableFlag__c;
            costdist.ExpenditureItem_AP_InvoiceImageFileURL  =expendItem.AP_InvoiceImageFileURL__c;
            costdist.ExpenditureItem_InvoiceNumber  =expendItem.InvoiceNumber__c;
            costdist.ExpenditureItem_VoucherNumber  =expendItem.VoucherNumber__c;
            costdist.ExpenditureItem_ProjectTaskName  =expendItem.ProjectTask__r.Name;
            costdist.ExpenditureItem_ProjectTaskNumber  =expendItem.ProjectTask__r.ProjectTaskNumber__c;

            costdist.ExpenditureItem_ProjectId  =expendItem.Project__c;
            costdist.ExpenditureItem_ProjectName  =expendItem.Project__r.Name;
            costdist.ExpenditureItem_ProjectNumber  =expendItem.Project__r.OracleProjectNumber__c;

            costdists.add(costdist);
          }
        }

        return costdists;
    }

}