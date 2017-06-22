public with sharing class ProjectMergeExtension {
    
    private Set<ID> projectIds {get;set;}
    
    /**
    * Constructor grabs all selected project ids
    */
    public ProjectMergeExtension(ApexPages.standardSetController setCtl) {
        this.projectIds = new Map<ID, sObject>(setCtl.getSelected()).keySet();
    }
    
    /**
    * Constructor grabs a singler project id
    */
    public ProjectMergeExtension(ApexPages.standardController ctl) {
        this.projectIds = new Set<ID>();
        projectIds.add(ctl.getId());
    }
    

    /**
    * returns reference to the single project
    */
    public Project__c singleProject {
        get {
            if (singleProject == null && selectedProjects.size() > 0) {
                singleProject = selectedProjects[0];
            }
            return singleProject;
        }
        private set;
    }
        
    /**
    *   query all projects selected including PR Contacts, PR Team Employees, and Awards
    */
    public List<Project__c> selectedProjects {
        get {
            if (selectedProjects == null) {
                selectedProjects = [SELECT ID, Name
                                        , Project_Name__c
                                        , Project_Description__c
                                        , Date_Actual_Completion__c
                                        , Owners_Total_cost__c
                                        , Search_Construction_Cost__c
                                        , SearchFee__c
                                        , Date_Started__c
                                        , Search_Completion_Date__c
                                        , Project_Manager_User__r.Name
                                        , Project_Manager_User__r.IsActive
                                        , Project_Manager_Status__c
                                        , RecordType.Name
                                        , Image__c 
                                        , Owner_Client_Output__c
                                        , Location_Output__c
                                        , Program_Master_Contract_Name__r.Client_contract__c
                                        , DO_TO_Number__c
                                        , Client_contract__c
                                                                                                                       
                                        , (SELECT ID
                                            , EmployeeUser__r.Name
                                            , User_Status__c 
                                            FROM PR_Team_Employees__r 
                                           ORDER BY EmployeeUser__r.LastName, EmployeeUser__r.FirstName)
                                            
                                        , (SELECT ID
                                            , Contact__r.Name 
                                            , Contact__r.MailingStreet
                                            , Contact__r.MailingCity
                                            , Contact__r.MailingState
                                            , Contact__r.MailingCountry
                                            , Contact__r.MailingPostalCode
                                            , Contact__r.OtherStreet
                                            , Contact__r.OtherCity
                                            , Contact__r.OtherState
                                            , Contact__r.OtherCountry
                                            , Contact__r.OtherPostalCode
                                            , Contact__r.Other_Street__c
                                            , Contact__r.Other_City__c
                                            , Contact__r.Other_State__c
                                            , Contact__r.OtherState__c
                                            , Contact__r.Other_State_Province_Emerate__r.Name
                                            , Contact__r.Other_Country__c
                                            , Contact__r.Other_Zip__c
                                            , Contact__r.Phone
                                            , Contact__r.Fax
                                            , Contact__r.Email                                          
                                            FROM PR_Contacts__r WHERE Contact_Reference_Quality__c IN ('Unknown','Good','Excellent') ORDER BY Contact_Project_Seq__c, Contact__r.LastName, Contact__r.FirstName)
                                            
                                        , (SELECT ID
                                            , Name
                                            , Award_Status__c
                                            , Date_Award_Won__c
                                            , Internal_Award__c
                                            , Presenting_Sponsoring_Organizaton__c
                                            , Presenting_Sponsoring_Organizaton__r.Name
                                            , RecordType.DeveloperName 
                                            FROM Awards__r ORDER BY Name)
                                            
                                        FROM Project__c 
                                        WHERE ID IN :projectIds
                                        ORDER BY Name];
            }
            return selectedProjects;
        
        }
        set;
    }
    
    @isTest (seeAllData=false)
    static void testProjectMerge() {
        Account acct = new Account(Name='Test Account');
        insert acct; 
        Project__c proj = new Project__c();
        proj.Name='Test';
        proj.Owner__c=acct.Id;
        proj.Project_Description__c = 'Test';
        insert proj;
        
        List<Project__c> projList = new List<Project__c>();
        projList.add(proj);
        ApexPages.standardSetController setCtl = new ApexPages.standardSetController(projList);
        setCtl.setSelected(projList);
        
        ProjectMergeExtension ext = new ProjectMergeExtension(setCtl);
        System.assertEquals(1, ext.selectedProjects.size());
        
        ApexPages.Standardcontroller ctl = new ApexPages.Standardcontroller(proj);
        ProjectMergeExtension ext2 = new ProjectMergeExtension(ctl);
        System.assertEquals(proj.id, ext.singleProject.ID);
    }
}