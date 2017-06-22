global with sharing class ECO_PMD_Top10EmployeesByHours_Controller {

  private final pse__Proj__c oProject ;

  public string locale { get {return UserInfo.getLocale().replace('_', '-');} }
  
  public ECO_PMD_ProjectWrapper wrapper { get; set; }
  
  public ECO_PMD_Top10EmployeesByHours_Controller (ApexPages.StandardController oStandardController) {
        this.oProject = (pse__Proj__c)oStandardController.getRecord();
    this.wrapper = new ECO_PMD_ProjectWrapper(this.oProject);
  }

   public ECO_PMD_Top10EmployeesByHours_Controller () {

  }


    @RemoteAction
    global static EmployeeHoursDetails getTop10EmployeesByHours(String projectNum, string periodType, Date fromDate, Date toDate )
    {
        Id projectId = projectNum;

        EmployeeHoursDetails employeeHourDetails = new EmployeeHoursDetails();
        
        try
        {
            // GET THE LATEST TWO SNAPSHOTS FOR THE PROJECT
            AggregateResult[] groupedResults ;


            if (periodType == 'ITD' || periodType == null || periodType == '')
            {
                 groupedResults = [SELECT  SUM(Quantity__c) hours, PersonId__c, ExpenditureOrgId__c
                        FROM ExpendItem__c
                        where Project__c = :projectId and PersonId__c <> 'null' and PersonId__c <> '' and PLReportCategory__c = 'Labor'
                        GROUP BY PersonId__c , ExpenditureOrgId__c
                        ORDER BY SUM(Quantity__c) DESC];
            }

            if (periodType == 'YTD' )
            {
                 groupedResults = [SELECT  SUM(Quantity__c) hours, PersonId__c, ExpenditureOrgId__c
                        FROM ExpendItem__c
                        where Project__c = :projectId and PersonId__c <> 'null' and PersonId__c <> '' and PLReportCategory__c = 'Labor'
                            and ExpenditureItemDate__c = THIS_FISCAL_YEAR
                        GROUP BY PersonId__c , ExpenditureOrgId__c
                        ORDER BY SUM(Quantity__c) DESC];
            }

            if (periodType == 'MTD' )
            {
                 groupedResults = [SELECT  SUM(Quantity__c) hours, PersonId__c, ExpenditureOrgId__c
                        FROM ExpendItem__c
                        where Project__c = :projectId and PersonId__c <> 'null' and PersonId__c <> '' and PLReportCategory__c = 'Labor'
                            and ExpenditureItemDate__c = THIS_MONTH
                        GROUP BY PersonId__c , ExpenditureOrgId__c
                        ORDER BY SUM(Quantity__c) DESC];
            }

            if (periodType == 'CUSTOM' )
            {
                 groupedResults = [SELECT  SUM(Quantity__c) hours, PersonId__c, ExpenditureOrgId__c
                        FROM ExpendItem__c
                        where Project__c = :projectId and PersonId__c <> 'null' and PersonId__c <> '' and PLReportCategory__c = 'Labor'
                            and (ExpenditureItemDate__c >= :fromDate and ExpenditureItemDate__c <=:toDate)
                        GROUP BY PersonId__c , ExpenditureOrgId__c
                        ORDER BY SUM(Quantity__c) DESC];
            }

           //EMPLOYEE DETAILS
            List<AggregateResult> groupedPeople = [select PersonId__c
                    from ExpendItem__c
                    where ProjectTask__r.pse__Project__r.Id = :projectId
                    group by PersonId__c
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


            // ORGANISATION DETAILS
             List<AggregateResult> groupedOrgs = [select ExpenditureOrgId__c
                    from ExpendItem__c
                    where ProjectTask__r.pse__Project__r.Id = :projectId
                    group by ExpenditureOrgId__c
                    limit 500];

            List<string> orgIds = new List<string>();
            for (AggregateResult ar : groupedOrgs)
            {
                orgIds.add((string)ar.get('ExpenditureOrgId__c'));
            }
            System.debug(orgIds);

            Map<string, OrganizationString__c> orgs = new Map<string,OrganizationString__c>();
            for(OrganizationString__c o : [SELECT  OrgID__c,  Department__c FROM OrganizationString__c 
                            WHERE OrgID__c IN :orgIds])
            {
                orgs.put(o.OrgID__c, o);
            }
            System.debug('lfxxxx' +  orgs);
           

            
            List<EmployeeHours> employeeHours = new List<EmployeeHours>();
            Integer i = 0;

            for (AggregateResult result : groupedResults)
            {
                 if (i < 10)
                 {
                    string employeeName = '';
                    try{
                        if ((string)result.get('PersonId__c') <> '')
                        {
                            Contact contact = employees.get((string)result.get('PersonId__c') );
                             employeeName = contact.psa_report__Resource_Name__c;
                        }
                    }
                    catch(Exception ex){}


                    string department = '';
                    try{
                        if ((string)result.get('ExpenditureOrgId__c') <> '')
                        {
                            OrganizationString__c org = orgs.get((string)result.get('ExpenditureOrgId__c') );
                             department = org.Department__c;
                        }
                    }
                    catch(Exception ex){}
                     employeeHours.add(
                        new EmployeeHours(
                            (string)result.get('PersonId__c')
                            , employeeName
                            , department
                            , (Decimal)result.get('hours')
                        ));
                 }
                 else
                 {
                    employeeHourDetails.other += (Decimal)result.get('hours');
                 } 
                 employeeHourDetails.total += (Decimal)result.get('hours');
                 i++;
            }

            

            employeeHourDetails.employeeHours = employeeHours;
       
        }
        catch (Exception ex){

            employeeHourDetails.error = ex.getMessage() + ' ' + ex.getLineNumber();
            employeeHourDetails.nodata = true;
        }

        return employeeHourDetails;
    }



    global class EmployeeHours
    {
        public EmployeeHours(string lemployeeNo , string lemployeeName,string lemployeeDept, Decimal lhours )
        {
            employeeNo = lemployeeNo;
            employeeName = lemployeeName;
            employeeDept = lemployeeDept;
            hours = lhours;
        }


        public String employeeNo;
        public String employeeName;
        public String employeeDept;
        public Decimal hours;
    }



    global class EmployeeHoursDetails
    {
        public EmployeeHoursDetails()
        {
            error = '';
            nodata = false;

            total = 0;
            other = 0;

            employeeHours = null;
        }

        public String error;
        public Boolean nodata;
        Decimal total;
        Decimal other;
        public List<EmployeeHours> employeeHours;

    }

}