public without sharing class ProjectOpportunityExtension {
//Note: without sharing so that user can convert Opportunity Partners without View All Data permission.
    private ID opportunityId;
    public Project__c project {get;set;}
    public Opportunity opp {get; set;}
    private Project__c otherProject;
    public List<PRStateProvinceEmirates__c> stateList {get;set;}
    public List<PR_Account__c> prAccounts {get;set;}
    
    private Set<String> preloadFields = new Set<String>{'STAGENAME', 'PROJECT_STATE_PROVINCE__C', 'ACCOUNTID'};
    
    /**
    * Constructor. Immediately query the opportunity and perform translation. (do not save) so that it can be presented to screen
    */
    public ProjectOpportunityExtension(ApexPages.standardController ctl) {
        opportunityId = ctl.getId();
        
        loadOpportunity();      
        if (projectExists == false) {
            if (validOpportunity) {         
                project = new Project__c(Opportunity__c = opportunityId);
                if (opp.Name.length() > 80) {
                project.Name = opp.Name.Substring(0,79);
                }else {
                project.Name = opp.Name;
                }
                translateOpportunityToProject(); //opp to project field map
                translateValidStates(); //states/provinces
                project.Prime__c = opp.AccountId; //overridden by prime in account list
                translateAccounts(); //Partners
                translateRecordType(); //RecordTypes
            } else {
                //Opp is not closed. Cannot convert to project
            }
        } else {
            project = otherProject; //set the project object to the one that already exists so that we can display it and offer redirect
        }
    }
    
    /**
    * Save the project with values converted from opp
    */
    public PageReference saveProject() {
        Savepoint sp = Database.setSavepoint();
        try {
            
            //Set the Prime from the PR Accounts related list
            for (PR_Account__c pr : prAccounts) {
                if (pr.PR_Account_Role__c == 'Prime') {
                    project.Prime__c = pr.PR_Accts__c;  
                }
            }
            
            //Save the project
            insert project;
            
            //Set the States list
            if (stateList != null && stateList.size() > 0) {
                for (PRStateProvinceEmirates__c st: stateList) {
                    st.ProjectRelated__c = project.id;
                }
                
                insert stateList;
            }
            
            //Set the related accounts list
            if (prAccounts != null && prAccounts.size() > 0) {
                List<PR_Account__c> insertPRAccounts = new List<PR_Account__c>();
                for (PR_Account__c pr : prAccounts) {
                    if (pr.PR_Account_Role__c != 'Prime') { //Don't insert the prime record. Set it to the project field instead
                        pr.Project_Subcontractors__c = project.id;
                        insertPRAccounts.add(pr);
                    }
                }
                
                insert insertPRAccounts;
                
                
            }
            
            opp.Project__c = project.ID;
            update opp;
            
            return new ApexPages.standardController(project).view();
        } catch (Exception e) {
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
            
        }
    }
    
    /**
    * Make sure opportunity is stage 5B or 6 before allowing conversion.
    */
    public Boolean validOpportunity {
        get {
            if (opp.StageName.startsWith('5B') || opp.StageName.startsWith('6')) {
                return true;
            } else {
                return false;
            }
        }
    }
    
    /**
    * Use custom settings field map to loop through all fields and match opp value to the new project value.
    */
    private void translateOpportunityToProject() {
        for (Opp_Project_Field_Map__c fld : fieldMap) {
            Object val = opp.get(fld.Name);
            Object existingVal = project.get(fld.Project_Field_Name__c);
            //This section supports multiple opp fields mapped to the same project field. Appends the value separated by ;
            if (existingVal != null && val instanceof String) {
                if (val != null) {
                    String updatedVal = (String)existingVal + '; ' + (String)val;
                    project.put(fld.Project_Field_Name__c, updatedVal);
                }
            } else {
                //if there is no value set on the opportunity, check the field map to see if there is a default value. Only works for strings.
                if (val == null && val instanceof String && fld.Default_Value__c != null) {
                    val = fld.Default_Value__c;
                }
                project.put(fld.Project_Field_Name__c, val);
            }
        }
    }
    
    /**
    * Translate the Opp Project state province field (multi select) to new PRStateProvinceEmirates records
    */
    private void translateValidStates() {
        List<String> stateNames = opp.Project_State_Province__c != null ? opp.Project_State_Province__c.split(';') : null;
        String country = opp.ProjectCountry__c;
        List<ValidState__c> states;
        if (stateNames != null && stateNames.size() > 0) {
            states = [SELECT ID, State__c, Country__c FROM ValidState__c WHERE State__c IN :stateNames];
        } else if (country != null) {
            states = [SELECT ID, State__c, Country__c FROM ValidState__c WHERE Country__c = :country AND State__c = null];
        }
        
        stateList = new List<PRStateProvinceEmirates__c>();
        if (states != null) {
            for (ValidState__c vs : states) {
                stateList.add(new PRStateProvinceEmirates__c(Project_StateProvEmirate__c = vs.ID, Project_StateProvEmirate__r=vs));
            }
        }
        
    }

    /**
    * Translate partners to PR_Account records (except competitors...those are filtered out)
    * Note, this required without sharing on the class since users cannot see the Partners object via API unless they have View All Data (system wide) on their profile
    */
    private void translateAccounts() {
        prAccounts = new List<PR_Account__c>();
    
        if (opp.Partners != null && opp.Partners.size() > 0) {
            for (Partner pr : opp.Partners) {
                if (!pr.Role.contains('Competitor')) {
                    prAccounts.add(new PR_Account__c(PR_Accts__c=pr.AccountToId, PR_Account_Role__c=pr.Role));
                }
            }
        }
    }
    
    /**
    * Interprets opp recordtype to the appropriate project RT (program, project or task Order)
    */
    private void translateRecordType() {
        String recordTypeName = opp.RecordType.Name;
        if (recordTypeName.containsIgnoreCase('Program')) {
            //The following lines were commented out and replaced per US-06951
            //RecordType rt = [SELECT ID, Name FROM RecordType WHERE sObjectType='Project__c' AND DeveloperName='Program'];
            //project.RecordTypeId = rt.ID;
            //project.RecordType = rt;
            project.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(Project__c.sObjectType,'Program');
        } else if (recordTypeName.containsIgnoreCase('Project')) {
            //The following lines were commented out and replaced per US-06951
            //RecordType rt = [SELECT ID, Name FROM RecordType WHERE sObjectType='Project__c' AND DeveloperName='Project'];
            //project.RecordTypeId = rt.ID;
            //project.RecordType = rt;
            project.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(Project__c.sObjectType,'Project');
        } else if (recordTypeName.containsIgnoreCase('Task Order')) {
            //The following lines were commented out and replaced per US-06951
            //RecordType rt = [SELECT ID, Name FROM RecordType WHERE sObjectType='Project__c' AND DeveloperName='Task_Order'];
            //project.RecordTypeId = rt.ID;
            //project.RecordType = rt;
            project.RecordTypeId = ECO_Utils_Meta.getRecordTypeId(Project__c.sObjectType,'Task_Order');
        }
        
        
    }
    
    /**
    * Query the opportunity. Dynamically builds the field query string based on what fields are mapped in custom settings
    */
    private void loadOpportunity() {
        String oppId = opportunityId;
        String competitorFilter = 'Competitor%';
        String oppQuery = 'SELECT ID, Project__c, RecordTypeId, RecordType.Name';
        
        //These fields are required for extension to function
        for (String preloadField : preloadFields) {
            oppQuery += ',' + preloadField;
        }
        
        //These are mapped fields
        for (Opp_Project_Field_Map__c fld : fieldMap) {
            if (!preloadFields.contains(fld.Name.toUpperCase())) { //don't query the same field twice
                oppQuery += ',' + fld.Name;
            }
        }
        oppQuery += ', (SELECT ID, Name FROM Projects__r)';
        oppQuery += ', (SELECT ID, AccountToId, Role FROM Partners WHERE Role != \'Account\')';
        oppQuery += ' FROM Opportunity WHERE ID = :oppId';
        opp = Database.query(oppQuery);
    }
    
    /**
    * Determine if the opportunity has already been converted to a project
    */
    public Boolean projectExists {
        get {
            if (projectExists == null) {
                if (opp.Projects__r.size() > 0) {
                    otherProject = opp.Projects__r[0];
                    projectExists = true;
                } else {
                    String jobNumber = opp.AECOM_Job_Number__c;
                    if (jobNumber != null) {
                        List<Project__c> otherProjects  = [SELECT ID, Name FROM Project__c WHERE Oracle_Project_Number__c = :jobNumber];
                        if (otherProjects.size() > 0) {
                            otherProject = otherProjects[0];
                            projectExists = true;
                        } else {
                            projectExists = false;
                        }
                    } else {
                        projectExists = false;
                    }
                }
            }
            return projectExists;

        }
        private set;
    }
    
    /**
    * query the Opp Project Field map custom settings
    */
    public List<Opp_Project_Field_Map__c> fieldMap {
        get {
            if (fieldMap == null) {
                fieldMap = [SELECT ID, Name, Project_Field_Name__c, Sort_Order__c, Inactive__c, Default_Value__c FROM Opp_Project_Field_Map__c WHERE Inactive__c = false ORDER BY Sort_Order__c];//Opp_Project_Field_Map__c.getAll().values();
            }
            return fieldMap;
        } 
        private set;
    }
}