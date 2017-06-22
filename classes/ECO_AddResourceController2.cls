public without sharing class ECO_AddResourceController2 {
  public IBudgetSave parentController { get; set;}
  public Id contactId {get;set;}
  public String budgetHeaderId {
    get;

    set {
      if (budgetHeaderId == null) {
        budgetHeaderId = value;

        if (refresh != null)
          init();
      }
    }
  }

  public String refresh {
    get;

    set {
      if (refresh == null) {
        refresh = value;

        if (budgetHeaderId != null)
          init();
      }
    }
  }

  public BudgetHeader__c budgetHeader {get; set;}
  public pse__Proj__c theProject {get; set;}

  public List<SelectOption> allProjectTeamMembers {get; set;}

  public String selectedProjectTeamMember {get; set;}

  public List<ECO_DTO_ProjectTeamMember> members {get; set;}

  public String jobNameSelections {get; set;}
  public transient String jobNameJSON {get; set;}

  public List<SelectOption> businessLineChoices {get; set;}
  public List<SelectOption> regionChoices {get; set;}

  public String businessLineSelection {get; set;}
  public String regionSelection {get; set;}
  public String businessLine {get; set;}
  public String region {get; set;}

  public String searchFirstName {get; set;}
  public String searchLastName {get; set;}
  public String searchRole {get; set;}
  public String searchPhone {get; set;}
  public String searchEmail {get; set;}

  public String thesoql {get; set;}

  public String memberids {get; set;}

  public List<ProjectTeamMember__c> memberList {get; set;}

  public List<Contact> contacts {get; set;}
  public Boolean isNoJobs {get; set;}

  public ECO_AddResourceController2() {
  }

  public void init() {
    budgetHeader = [select id, Project__c from BudgetHeader__c where id = :budgetHeaderId];

    System.debug(LoggingLevel.ERROR, 'budget header id - ' + budgetHeader.id);

    if (budgetHeader.id == null)
      return;

    theProject = [select id, DefaultBillRate__c, DefaultUpliftLabor__c from pse__Proj__c where id = :budgetHeader.Project__c];

    populateProjectTeam();
    populateOrganizationStrings();
    populateJobNameChoices();

    contacts = new List<Contact>();
  }

  private String notNull(String value1, String value2, String value3) {
    if (value1 != null)
      return value1;

    if (value2 != null)
      return value2;

    return value3;
  }

  public void populateProjectTeam () {
    Id projid = theProject.id;

    memberList = [select id, role__c, projectrole__r.name, name__c, name, startdate__c, enddate__c, Phone__c, Email__c from projectteammember__c where project__c = :projid order by name, projectrole__r.name];
  }

  public void findResource() {
    String soql = 'select id, firstname, lastname, phone, email from Contact where Person_ID__c != null and AcctName__c = \'AECOM INC\'';

    Boolean added = false;

    if ((searchFirstName != null) && (!searchFirstName.trim().equals(''))) {
      added = true;
      soql += ' and firstname like \'%' + searchFirstName.trim() + '%\'';
    }

    if ((searchLastName != null) && (!searchLastName.trim().equals(''))) {
      added = true;
      soql += ' and lastname like \'%' + searchLastName.trim() + '%\'';
    }

    if ((searchPhone != null) && (!searchPhone.trim().equals(''))) {
      added = true;
      soql += ' and Phone like \'%' + searchPhone.trim() + '%\'';
    }

    if ((searchEmail != null) && (!searchEmail.trim().equals(''))) {
      added = true;
      soql += ' and Email like \'%' + searchEmail.trim() + '%\'';
    }

    soql += ' order by lastname, firstname limit 200';

    System.debug(LoggingLevel.ERROR, 'the soql - ' + soql);
    
    if (added)
      contacts = Database.query(soql);
    else
      contacts = new List<Contact>();
  }

/*
  public void populateProjectTeam () {
    members = new List<ECO_DTO_ProjectTeamMember>();

    allProjectTeamMembers = new List<SelectOption>();

    allProjectTeamMembers.add(new SelectOption('', '--- Choose a Team Member ---'));

    List<String> names = new List<String>();
    Map<String, Id> nameMap = new Map<String, Id>();

    Id projid = theProject.id;

    String soql = 'select id, role__c, projectrole__r.name, name__c, name, startdate__c, enddate__c, Phone__c, Email__c from projectteammember__c where project__c = :projid';

    if ((searchName != null) && (!searchName.trim().equals(''))) {
      soql += ' and name like \'%' + searchName.trim() + '%\'';
    }

    if ((searchRole != null) && (!searchRole.trim().equals(''))) {
      soql += ' and ProjectRole__r.name like \'%' + searchRole.trim() + '%\'';
    }

    if ((searchPhone != null) && (!searchPhone.trim().equals(''))) {
      soql += ' and Phone__c like \'%' + searchPhone.trim() + '%\'';
    }

    if ((searchEmail != null) && (!searchEmail.trim().equals(''))) {
      soql += ' and Email__c like \'%' + searchEmail.trim() + '%\'';
    }

    soql += ' order by name, projectrole__r.name';

    System.debug(LoggingLevel.ERROR, 'the soql - ' + soql);

    thesoql = soql;

    List<ProjectTeamMember__c> memberList = Database.query(soql);
    
    for (ProjectTeamMember__c ptm : memberList) {
      String roleName = notNull(ptm.ProjectRole__r.name, ptm.Role__c, 'no role');

      String name = notNull(ptm.name__c, ptm.name, 'no name');

      name += ' (' + roleName + ')';

      names.add(name);
      nameMap.put(name, ptm.Id);

      members.add(new ECO_DTO_ProjectTeamMember(ptm));
    }

    names.sort();

    for (String name : names) {
      allProjectTeamMembers.add(new SelectOption(nameMap.get(name), name));
    }
  }
*/  

  public void populateOrganizationStrings() {

    Map<String, String> businessLineMap = new Map<String, String>();
    Map<String, String> regionMap = new Map<String, String>();

    // List<String> businessLineList = new List<String>(businessLineMap.keySet());
    // List<String> regionList =  new List<String>();
    System.debug('Heap - before populateOrganizationStrings(): ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());
    if ((jobNameSelections == null) || (jobNameSelections.trim().equals(''))) {
      // List<OrganizationString__c> orgStrings = 

      for (OrganizationString__c orgString : 
        [select id, BusinessLineName__c, Region__c from OrganizationString__c where (BusinessLineName__c != null) or (Region__c != null)]) 
      {
        if (orgString.BusinessLineName__c != null) {
          businessLineMap.put(orgString.BusinessLineName__c, orgString.id);
        }

        if (orgString.Region__c != null) {
          regionMap.put(orgString.Region__c, orgString.id);  
        }
      }
    } else {
      // List<Contact> contacts = 
      String bl;
      String region;

      for (Contact con :
        [select id,  pse__Salesforce_User__r.Business_Line__c, pse__Salesforce_User__r.JobName__c, pse__Salesforce_User__r.Region__c from Contact where pse__Salesforce_User__r.JobName__c = :jobNameSelections and ((pse__Salesforce_User__r.Business_Line__c != null) or (pse__Salesforce_User__r.Region__c != null))]) 
      {
        bl = con.pse__Salesforce_User__r.Business_Line__c;
        region = con.pse__Salesforce_User__r.Region__c;

        if (bl != null) {
          businessLineMap.put(bl, bl);
        }

        if (region != null){
          regionMap.put(region, region);  
        }
      }
    }

    System.debug('Heap - after query - populateOrganizationStrings(): ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());
    List<String> businessLineList = new List<String>(businessLineMap.keySet());
    List<String> regionList = new List<String>(regionMap.keySet());

    businessLineList.sort();
    regionList.sort();
    System.debug('Heap - after sort - populateOrganizationStrings(): ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());
    
    businessLineChoices = new List<SelectOption>();

    businessLineChoices.add(new SelectOption('', System.Label.ECO_Select_Business_Line )); // 'Select Business Line (optional)'

    for (String s : businessLineList) {
      businessLineChoices.add(new SelectOption(businessLineMap.get(s), s));
    }
    System.debug('Heap - after businessLineChoices - populateOrganizationStrings(): ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());
    
    regionChoices = new List<SelectOption>();

    regionChoices.add(new SelectOption('', System.Label.ECO_Select_Region )); // 'Select Region (optional)'

    for (String s : regionList) {
      regionChoices.add(new SelectOption(regionMap.get(s), s));
    }
    System.debug('Heap - after regionChoices - populateOrganizationStrings(): ' + Limits.getHeapSize() + '\t - ' + Limits.getCpuTime());
    
  }

  public void populateJobNameChoices() {
    // Map<String, ECO_Job_Name__c> jobNames = ECO_Job_Name__c.getAll();

    List<String> listt = new List<String>();

        // Fix for US-04172.  Filter the Job Name List based on Business Line and Region    
    String query;

    if(businessLineSelection==null && regionSelection==null) {
      query = 'Select Name__c From ECO_Job_Name__c';
      for (ECO_Job_Name__c jobName : [Select Name__c From ECO_Job_Name__c]) {
        listt.add(jobName.name__c);
      }  
       businessLine = null;
       region = null;    
    }
    else {
      query = 'SELECT Count(Id), JobName__c FROM User Where JobName__c != null';
      if (businessLineSelection != null) {
        businessLine = [Select BusinessLineName__c From OrganizationString__c Where Id = :businessLineSelection ].BusinessLineName__c;
        query += ' And Business_Line__c = \'' + businessLine + '\'';
      }  
      if (regionSelection != null) {
        region = [Select Region__c From OrganizationString__c Where Id = :regionSelection ].Region__c;        
        query += ' And Region__c = \'' + region + '\'';
      }
        
      query += ' Group By JobName__c';

      for (AggregateResult u : Database.query(query)) {
        listt.add((string) u.get('JobName__c'));
      }
    }

    isNoJobs = false;
    if(listt.size() == 0) {
      isNoJobs = true;
      listt.add(Label.No_jobs_found);
    }

    listt.sort();

    jobNameJSON = '[';

    Boolean first = true;

    for (String s : listt) {
      if (s.indexOf('"') != -1)
        continue;  // TODO - probably shouldn't skip, maybe escape is a better option

      if (!first)
        jobNameJSON += ',';

      jobNameJSON += '"' + s + '"';

      first = false;

      //jobNameChoices.add(new SelectOption(s, s));
    }

    jobNameJSON += ']';
      populateOrganizationStrings();
     }

  public PageReference addExistingResource() {
    List<String> memberidsList = memberids.split(',');

    System.debug('memberlist - ' + memberids);

    List<ProjectTeamMember__c> membersTemp = [select id, Contact__c from ProjectTeamMember__c where id in :memberidsList];

    Map<Id, Id> membersMap = new Map<Id, Id>();

    for (ProjectTeamMember__c member : membersTemp) {
      membersMap.put(member.id, member.Contact__c);
      System.debug('mapped -  ' + member.id + ' - ' + member.Contact__c);
    }

    List<BudgetResource__c> toAdd = new List<BudgetResource__c>();

    System.debug(LoggingLevel.ERROR, 'here 1');

/*
    for (ECO_DTO_ProjectTeamMember member : members) {
      if (!member.selected)
        continue;
*/

    for (String memberid : memberidsList) {
//      System.debug(LoggingLevel.ERROR, 'here 2 - ' + member.member.id);  

      BudgetResource__c newBudgetColumn = initNewResource();

      newBudgetColumn.BudgetHeader__c = budgetHeader.id;
      newBudgetColumn.OverrideRatesOnLines__c = true;
      newBudgetColumn.ResourceType__c = 'Labor/Person';

      newBudgetColumn.OverrideBillRate__c = theProject.DefaultBillRate__c;
      newBudgetColumn.OverrideUplift__c = theProject.DefaultUpliftLabor__c;
      newBudgetColumn.JobName__c = null;
      newBudgetColumn.Resource__c = membersMap.get(memberid);
      System.debug('resource - ' + membersMap.get(memberid));

//      newBudgetColumn.ProjectTeamMember__c = member.member.id;
      newBudgetColumn.ProjectTeamMember__c = memberid;

      toAdd.add(newBudgetColumn);
    }

    // parentController.save();
//    insert newBudgetColumn;
    insert toAdd;

    System.debug(LoggingLevel.ERROR, 'here 3 - ' + toAdd.size());

    PageReference pr = new PageReference('/apex/' + refresh + '?id=' + budgetHeader.id);
    pr.setRedirect(true);

    return parentController.hardRefresh();
  }

  public PageReference addFoundResource() {
    return null;
  }

  public Double computeAverageCostRate() {
    populateOrganizationStrings();

    String soql = 'select id, pse__Default_Cost_Rate__c from Contact where JobName__c = \'' + jobNameSelections + '\'';

    /*if ((businessLineSelection != null) && (businessLineSelection != '')) {
      soql += ' and OrganizationBusinessLine__c = :businessLineSelection';
    }

    if ((regionSelection != null) && (regionSelection != '')) {
      soql += ' and OrganizationRegion__c = :regionSelection';
    }*/
    if ((businessLine != null) && (businessLine != '')) {
      soql += ' and OrganizationBusinessLine__c = \'' + businessLine + '\'';
    }

    if ((region != null) && (region != '')) {
      soql += ' and OrganizationRegion__c = \'' + region + '\'';
    }

    List<Contact> contacts = null;

    try {
      contacts = Database.query(soql);
    } catch (Exception ex) {

    }

    Double acc = 0;
    Double ct = 0;

    for (Contact con : contacts) {
      if (con.pse__Default_Cost_Rate__c > 0) {
        acc += con.pse__Default_Cost_Rate__c;
        ct++;
      }
    }

    if (ct > 0)
      return acc / ct;

    return 0.0;  
  }

  public BudgetResource__c initNewResource() {
    BudgetResource__c newBudgetColumn = new BudgetResource__c();

    if (theProject.DefaultBillRate__c != null && theProject.DefaultBillRate__c != 0 ) {
      newBudgetColumn.OverrideBillRate__c = theProject.DefaultBillRate__c;
      newBudgetColumn.MarginType__c = 'Amount';
    }
    
    return newBudgetColumn;
  }

  public PageReference addGenericResourceTitle() {
  
    BudgetResource__c newBudgetColumn = initNewResource();

    newBudgetColumn.BudgetHeader__c = budgetHeader.id;
    newBudgetColumn.OverrideRatesOnLines__c = true;
    newBudgetColumn.ResourceType__c = 'Labor/Person';
    newBudgetColumn.ExpenditureType__c = 'LAB - Professional';
    newBudgetColumn.ResourceName__c = null;
    newBudgetColumn.ProjectTeamMember__c = null;
    newBudgetColumn.OverrideRawCost__c = computeAverageCostRate();
    newBudgetColumn.JobName__c = jobNameSelections;
    newBudgetColumn.OverrideUplift__c = theProject.DefaultUpliftLabor__c;

    // parentController.save();
    insert newBudgetColumn;

    PageReference pr = new PageReference('/apex/' + refresh + '?id=' + budgetHeader.id);
    pr.setRedirect(true);

    return parentController.hardRefresh();
  }

  public PageReference addGenericResource() {
    BudgetResource__c newBudgetColumn = initNewResource();

    newBudgetColumn.BudgetHeader__c = budgetHeader.id;
    newBudgetColumn.OverrideRatesOnLines__c = true;
    newBudgetColumn.ResourceType__c = 'Labor/Person';

    newBudgetColumn.ResourceName__c = null;
    newBudgetColumn.ProjectTeamMember__c = null;
    newBudgetColumn.OverrideRawCost__c = 0; //theProject.DefaultBillRate__c;
    newBudgetColumn.OverrideBillRate__c = theProject.DefaultBillRate__c;

    newBudgetColumn.JobName__c = null;
    newBudgetColumn.OverrideUplift__c = theProject.DefaultUpliftLabor__c;

    // parentController.save();
    insert newBudgetColumn;

    PageReference pr = new PageReference('/apex/' + refresh + '?id=' + budgetHeader.id);
    pr.setRedirect(true);

    return parentController.hardRefresh();
  }

  public PageReference addNew() {
//    ProjectRole__c prl = [select id from ProjectRole__c where Name = 'Task Manager'];
    ProjectRole__c prl = [select id from ProjectRole__c where Name = 'Other'];

    ProjectTeamMember__c ptm = new ProjectTeamMember__c();
    ptm.contact__c = contactId;
    ptm.project__c = theProject.id;
    ptm.ProjectRole__c = prl.id;

    insert ptm;

    BudgetResource__c newBudgetColumn = new BudgetResource__c();

    newBudgetColumn.Resource__c = contactId;
    newBudgetColumn.BudgetHeader__c = budgetHeaderId;
    newBudgetColumn.OverrideRatesOnLines__c = true;
    newBudgetColumn.ResourceType__c = 'Labor/Person';

    newBudgetColumn.OverrideBillRate__c = theProject.DefaultBillRate__c;
    newBudgetColumn.OverrideUplift__c = theProject.DefaultUpliftLabor__c;
    newBudgetColumn.JobName__c = null;

    newBudgetColumn.ProjectTeamMember__c = ptm.id;

    if (theProject.DefaultBillRate__c != null && theProject.DefaultBillRate__c != 0 ) {
      newBudgetColumn.MarginType__c = 'Amount';
    }
    
    // parentController.save();
    insert newBudgetColumn;

    PageReference pr = new PageReference('/apex/' + refresh + '?id=' + budgetHeader.id);
    pr.setRedirect(true);

    return parentController.hardRefresh();
  }
}