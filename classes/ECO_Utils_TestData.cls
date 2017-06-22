/*
 *  @Author: Sujit Kumar
 *  @Created: Aug 10, 2015
 *  This is a utility class that provides data for test classes.
 *  All the builder nested classes are based on the Builder GoF design pattern.
 *  Advantages: 1) Prevent proliferation of constructors - telescoping constructor anti-pattern
                2) Reduced coupling on constructors.
                3) Defaults provided for most common attribute values
 */
 
public class ECO_Utils_TestData {

	public class AccountBuilder {
		
		public AccountBuilder() {
			name = 'test account';
		}
		
		public String name { get; set; }
		 
		public AccountBuilder withName(String name) {
	        this.name = name;
	        return this;
	    }
	    
		public Account build() {
	    	Account myAccount = new Account(name = this.name);
	    	insert myAccount;
	    	return myAccount;
	    }
	}
	
	public class ProjectBuilder {
		public Account acct { get; set; }
		public Date startDate { get; set; }
		public Date endDate { get; set; }
		public List<pse__Project_Task__c> projectTasks { get; set; }
		Map<String, ProjectRole__c> projectRoles { get; set; }
		public String projectName { get; set; }
		public Opportunity opportunity { get; set; }
		
		public ProjectBuilder() {
	        this.acct = new AccountBuilder().build();
	        this.startDate = Date.today();
	        this.endDate = startDate.addDays(56); // 8 weeks
	        this.projectTasks = new List<pse__Project_Task__c>();
	        this.projectName = 'testProject_' + TestCoverageSmokeMocks.generateRandomString(68);

			projectRoles = new Map<String, ProjectRole__c>();
			List<ProjectRole__c> insertProjectRoles = new List<ProjectRole__c>();

			for(ProjectRole__c role : [SELECT Name FROM ProjectRole__c WHERE Name IN(
										'Resilience Director', 
										'Project Owner', 
										'Capture Manager')])
			{
				projectRoles.put(role.Name, role);
			}

			if(!projectRoles.containsKey('Resilience Director')){
				ProjectRole__c rd = new ProjectRole__c(Name = 'Resilience Director', Type__c = 'Key Member', Active__c = true);
				insertProjectRoles.add(rd);
				projectRoles.put(rd.Name, rd);
			}

			if(!projectRoles.containsKey('Project Owner')){
				ProjectRole__c po = new ProjectRole__c(Name = 'Project Owner', Type__c = 'Key Member', Active__c = true);
				insertProjectRoles.add(po);
				projectRoles.put(po.Name, po);
			}

			if(!projectRoles.containsKey('Capture Manager')){
				ProjectRole__c cm = new ProjectRole__c(Name = 'Capture Manager', Type__c = 'Key Member', Active__c = true);
				insertProjectRoles.add(cm);
				projectRoles.put(cm.Name, cm);
			}
	    }
	    
		 
		public ProjectBuilder withAccount(Account acct) {
	        this.acct = acct;
	        return this;
	    }
	    
	    public ProjectBuilder withStartDate(Date startDate) {
	        this.startDate = startDate;
	        return this;
	    }
	    
	    public ProjectBuilder withEndDate(Date endDate) {
	        this.endDate = endDate;
	        return this;
	    }
	    
	    public ProjectBuilder withProjectTask(pse__Project_Task__c myTask) {
	        this.projectTasks.add(myTask);
	        return this;
	    }

	    //Creating the Opportunity after the Project results in 101 SOQL error
	    public ProjectBuilder withOpportunity(){
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

			opportunity = new Opportunity(Name = 'projectName', StageName = 'Open', CloseDate = Date.today(), AECOM_Primary_Dept_Lookup__c = primaryDept.Id);
			insert opportunity;

			return this;
	    }

		public pse__Proj__c build(Boolean doInsert) {
			Contact captureManager = new Contact(
					FirstName='cm First', 
					LastName='cm Last', 
					Email='cm@nowhere.com'
				);
			insert captureManager;

	        pse__Proj__c myProj = new pse__Proj__c	(
	        											pse__Account__c = this.acct.Id, 
	        											pse__Start_Date__c = this.startDate,
	        											pse__End_Date__c = this.endDate,
	        											CaptureManager__c = captureManager.Id,
	        											EstAwardDate__c = this.startDate == null ? Date.today() : this.startDate,
	        											ProjectFunctionalCurrencyCode__c = 'USD'
	        											//pse__Opportunity__c = opportunity == null ? null : opportunity.Id  //Running into 101 SOQL error in triggers
	        										);
	        if(doInsert)
	        {
	        	insert myProj;
	        	ProjectTeamMember__c teamMember = new ProjectTeamMember__c(
	        		Contact__c = captureManager.Id, 
	        		ProjectRole__c = projectRoles.get('Capture Manager').Id, 
	        		Project__c = myProj.Id, 
	        		StartDate__c = myProj.EstimatedStartDate__c);
	        	insert teamMember;
	        }

	        return myProj;
	    }
	}


	public class ProjectTaskBuilder {
		
		public ProjectTaskBuilder() {
	        this.earnedValueCurve = 'Even';
	        this.totalApprovedCost = 10000; // 8 weeks
	    }
	    
	    public String taskName { get; set; }
	    public Id projectId { get; set; }
	    public String earnedValueCurve { get; set; }
	    public Integer totalApprovedCost { get; set; }
	    
		public ProjectTaskBuilder withTaskName(String taskName) {
	        this.taskName = taskName;
	        return this;
	    }
	    
	    public ProjectTaskBuilder withprojectId(Id projectId) {
	        this.projectId = projectId;
	        return this;
	    }
	    
	    public ProjectTaskBuilder withTotalApprovedCost(Integer totalApprovedCost) {
	        this.totalApprovedCost = totalApprovedCost;
	        return this;
	    }
	    
	    public ProjectTaskBuilder withEarnedValueCurve(String earnedValueCurve) {
	        this.earnedValueCurve = earnedValueCurve;
	        return this;
	    }
	    
		 public pse__Project_Task__c build() {
	        pse__Project_Task__c myProjTask = new pse__Project_Task__c	
	        										(
	        											Name = this.taskName, 
	        											pse__Project__c = this.projectId,
	        											EarnedValueCurve__c = this.earnedValueCurve,
	        											TotalApprovedCost__c = this.totalApprovedCost
	        										);
	        return myProjTask;
	    }
	}


	public class EarnedValueReportBuilder {

		public EarnedValueReportBuilder() {
			// Add defaults here if any
			this.committed = false;
	    }
	    
	    public String reportName { get; set; }
	    public Id projectId { get; set; }
	    public Date snapshotDate { get; set; }
	    public Boolean committed { get; set; }
	    
		public EarnedValueReportBuilder withReportName(String reportName) {
	        this.reportName = reportName;
	        return this;
	    }
	    
	    public EarnedValueReportBuilder withprojectId(Id projectId) {
	        this.projectId = projectId;
	        return this;
	    }
	    
	    public EarnedValueReportBuilder withSnapshotDate(Date snapshotDate) {
	        this.snapshotDate = snapshotDate;
	        return this;
	    }
	    
	    public EarnedValueReportBuilder withCommitted(Boolean committed) {
	        this.committed = committed;
	        return this;
	    }
	    
		 public EarnedValueHeader__c build() {
	        EarnedValueHeader__c myReport = new EarnedValueHeader__c	
	        										(
	        											ReportName__c = this.reportName, 
	        											Project__c = this.projectId,
	        											SnapshotDate__c = this.snapshotDate,
	        											Committed__c = this.committed
	        										);
	        insert myReport;
	        return myReport;
	    }
	}
	
	
	public class EarnedValueTaskBuilder {

		public EarnedValueTaskBuilder() {
			// Add defaults here if any
			this.committed = false;
			this.notifyTaskOwner = false;
			this.percentComplete = 0.00;
	    }

	    public Id taskId { get; set; }
	    public Id reportId { get; set; }
	    public Date snapshotDate { get; set; }
	    public Boolean committed { get; set; }
	    public Boolean notifyTaskOwner { get; set; }
	    public Decimal percentComplete { get; set; }
	    
		public EarnedValueTaskBuilder withTaskId(Id taskId) {
	        this.taskId = taskId;
	        return this;
	    }
	    
	    public EarnedValueTaskBuilder withReportId(Id reportId) {
	        this.reportId = reportId;
	        return this;
	    }
	    
	    public EarnedValueTaskBuilder withSnapshotDate(Date snapshotDate) {
	        this.snapshotDate = snapshotDate;
	        return this;
	    }
	    
	    public EarnedValueTaskBuilder withCommitted(Boolean committed) {
	        this.committed = committed;
	        return this;
	    }
	    
	    public EarnedValueTaskBuilder withNotifyTaskOwner(Boolean notifyTaskOwner) {
	        this.notifyTaskOwner = notifyTaskOwner;
	        return this;
	    }
	    
		public EarnedValueTaskBuilder withPercentComplete(Decimal percentComplete) {
	        this.percentComplete = percentComplete;
	        return this;
	    }	    
	    
		 public EarnedValueTask__c build() {
	        EarnedValueTask__c myEVT = new EarnedValueTask__c	
	        										(
	        											ProjectTask__c = this.taskId, 
	        											EarnedValueHeader__c = this.reportId,
	        											SnapshotDate__c = this.snapshotDate,
	        											Committed__c = committed,
	        											NotifyTaskOwner__c = notifyTaskOwner,
	        											PercentComplete__c = percentComplete
	        										);
	        return myEVT;
	    }
	}

	public virtual class ProjectWrapper {
		
		public pse__Proj__c project { get; set; }
		public List<pse__Project_Task__c> listOfTasks { get; set; }
		
		public ProjectWrapper(pse__Proj__c project, List<pse__Project_Task__c> listOfTasks) {
			this.project = project;
			this.listOfTasks = listOfTasks;
		}
	}
	
	
	public class ReportWrapper extends ProjectWrapper {
		
		public EarnedValueHeader__c report { get; set; }
		public List<EarnedValueTask__c> listOfEVTs { get; set; }
		
		public ReportWrapper(ProjectWrapper pw, EarnedValueHeader__c report, List<EarnedValueTask__c> listOfEVTs) {
			super(pw.project, pw.listOfTasks);
			this.report = report;
			this.listOfEVTs = listOfEVTs;
		}
	}


	public static pse__Proj__c createProject() {
		pse__Proj__c testProject = new ProjectBuilder().build(true);
		return testProject;
	}
	
	public static pse__Proj__c createProject(Date startDate, Date endDate) {
		pse__Proj__c testProject = new ProjectBuilder().withStartDate(startDate).withEndDate(endDate).build(true);
		return testProject;
	}
	
	public static ProjectWrapper createProjectWithTasks(String prefix, Integer nTasks, Integer nWeeks) {
		Date endDate = Date.today().addDays(7 * nWeeks); // nWeeks
		pse__Proj__c testProject = new ProjectBuilder().withEndDate(endDate).build(true);
		
		List<pse__Project_Task__c> listOfTasks = new List<pse__Project_Task__c>();
		for (Integer i = 1; i <= nTasks; ++i) {
			pse__Project_Task__c projTask = new ProjectTaskBuilder().withTaskName(prefix + '-' + i)
																	.withProjectId(testProject.Id)
																	.build();
			listOfTasks.add(projTask);
		}

		System.debug('listOfTasks: ' + listOfTasks);
		insert listOfTasks;
		return new ProjectWrapper(testProject, listOfTasks);
	}
	
	public static EarnedValueHeader__c createReport(ProjectWrapper myProjWrapper, Integer reportForNthWeek) {
		return createReport(myProjWrapper, reportForNthWeek, false);
	}
	
	public static EarnedValueHeader__c createReport(ProjectWrapper myProjWrapper, Integer reportForNthWeek, Boolean committed) {
//		Date startOfWeekOfStartDate = myProjWrapper.project.pse__Start_Date__c.toStartofWeek();
		Date startOfWeekOfStartDate = ECO_Service_Snapshots.getFirstDateOfWeek(myProjWrapper.project.pse__Start_Date__c);
		if (reportForNthWeek > 1) {
			startOfWeekOfStartDate = startOfWeekOfStartDate.addDays(7 * (reportForNthWeek - 1));
		}
		EarnedValueHeader__c myReport = new EarnedValueReportBuilder()
												.withProjectId(myProjWrapper.project.Id)
												.withSnapshotDate(startOfWeekOfStartDate)
												.withReportName(ECO_Utils_Date.formatDateAsMMSlashDDSlashYYYY(startOfWeekOfStartDate))
												.withCommitted(committed)
												.build();
    	return myReport;
	}
	
	public static List<EarnedValueTask__c> createEarnedValueTasks(ProjectWrapper myProjWrapper, EarnedValueHeader__c myReport, Integer basePercentComplete) {
		return 	createEarnedValueTasks(myProjWrapper, myReport, basePercentComplete, false);
	}
	
	
	public static List<EarnedValueTask__c> createEarnedValueTasks(ProjectWrapper myProjWrapper, EarnedValueHeader__c myReport, Integer basePercentComplete, Boolean committed) {
		List<EarnedValueTask__c> listOfEVTs = new List<EarnedValueTask__c>();
		Integer i = 1;
		for (pse__Project_Task__c eachTask : myProjWrapper.listOfTasks) {
	    	EarnedValueTask__c evt = new EarnedValueTaskBuilder()
												.withTaskId(eachTask.Id)
												.withReportId(myReport.Id)
												.withSnapshotDate(ECO_Service_Snapshots.getFirstDateOfWeek(myProjWrapper.project.pse__Start_Date__c))
//												.withSnapshotDate(myProjWrapper.project.pse__Start_Date__c.toStartofWeek())
												.withCommitted(committed)
												.withPercentComplete(basePercentComplete + i)
												.build();
	   		listOfEVTs.add(evt);
	   		i = i + 1;
		}
		insert listOfEVTs;
		return listOfEVTs;
	}
	
	public static ReportWrapper createReportAndEarnedValueTasks(ProjectWrapper pw, Integer reportForNthWeek, Integer basePercentComplete, Boolean committed) {
		EarnedValueHeader__c evReport = createReport(pw, reportForNthWeek);
		List<EarnedValueTask__c> listOfEVTs = createEarnedValueTasks(pw, evReport, basePercentComplete);
		ReportWrapper rw = new ReportWrapper(pw, evReport, listOfEVTs);
		return rw;
	}
	
	public static ReportWrapper createProjectWithTasksAndEVReportAndEVTasks(Integer nTasks, Integer nWeeks, Integer reportForNthWeek, Integer basePercentComplete) {
		ProjectWrapper pw = createProjectWithTasks('A', nTasks, nWeeks);
		return createReportAndEarnedValueTasks(pw, reportForNthWeek, basePercentComplete, false);
	}

	public static SharedServicesRequest__c createSharedServicesRequest(Id recordTypeId){
		User approver = TestCoverageSmokeMocks.mockUser(true);
		
		Account testAccount = new Account(
			Name = 'test account');
		insert testAccount;

		Country__c c = new Country__c(
			Name = 'test');
		insert c;

		State_Province_Emirate__c p  = new State_Province_Emirate__c(
			Name = 'test',
			Country__c = c.id);
		insert p;

		SharedServicesRequest__c ssr = new SharedServicesRequest__c(
			Approver__c = approver.id,
			SkipValidation__c = true,
			GenerateObjects__c= true,
			AssigntoSharedServices__c = true,
			RecordTypeId = recordTypeId,
			CustomerName__c = 'test',
			ParentAccount__c = testAccount.id,
			ClientGroup__c = 'test',
			ClientSubgroup__c = 'test',
			Reach__c = 'test',
			SicCode__c = 'test',
			SicDescription__c = 'test',
			MKDenialStatus__c = 'test',
			IntercompanyCustomer__c = 'test',
			DBNumberDUNS__c = 'duns',
			DesktopCheckAsia__c = true,

			//vendor fields
			VendorType__c = 'test',
			SocioMinorityOwned__c = true,
			SocioNonProfit__c = true,

			SocioSmallBusinessSB__c = true,
			SocioLargeBusiness__c = true,
			SocioVeteranOwnedVO__c = true,
			SocioWomenOwnedWO__c = true,
			SocioServiceDisabledVeteranOwnedSDVO__c = true,
			Socio8aCertifiedFirms8a__c = true,
			SocioAbilityOne__c = true,
			SocioAlaskaNativeCorpandTriballyOwned__c = true,
			EcoEconomicallyDisadvantagedWomanOwned__c = true,
			SocioHistoricallyBlackCollegesandUniv__c = true,
			SocioSmallDisadvantagedBusinessSDB__c = true,
			SocioHUBZone__c = true,

			//Sites
			Address1StreetPOBox__c = 'test',
			City__c = 'test',
			Country__c = 'Afghanistan',	
			AddressIsPrimary__c = true,
			StateProvinceEmirate__c = p.id,

			BillingStreetPOBox__c = 'test',
			BillingAddressCity__c = 'test',
			BillingAddressCountry__c = 'Afghanistan',	
			BillingAddress1isPrimary__c = false,
			BillingStateProvinceEmirate__c = p.id,


			RemitToAddressLine1__c = 'test',
			RemitToCity__c = 'test',
			RemitToCountry__c = 'Afghanistan',
			RemitIsPrimaryAddress__c = false,
			RemitToStateProvinceEmirate__c = p.id,


			//contacts
			BillingContactLastName__c = 'test',
			BillingContactFirstName__c = 'test',
			BillingContactEmail_1__c = 'test@test.com',
			BillingContactPhone__c = '1111111',

			Contact1LastName__c = 'test1',
			Contact1FirstName__c = 'test1',
			Contact1EmailAddress__c = 'test@test2.com',
			Contact1Phone__c = '2222222',		

			Contact2LastName__c = 'test2',
			Contact2FirstName__c = 'test2',
			Contact2Email__c = 'test@test3.com',
			Contact2Phone__c = '3333333'
			);

		return ssr;
	}
}