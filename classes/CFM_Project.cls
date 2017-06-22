public with sharing class CFM_Project extends CFM_BaseModel {

    public static final String OBJ_NAME = 'Project__c';
    public Static Finder find = new Finder(OBJ_NAME, getProjectQueryFields());
    public static Finder findAllFields = new Finder(OBJ_NAME);

    public Project__c obj { get { return (Project__c)mObj; } }

     public Boolean selected { get; set; }

    public CFM_Project(sObject pObj) {
        super(pObj);
        selected = false;
    }

   public static List<CFM_Project> decorate(List<Project__c> projects) {
        List<CFM_Project> result = new List<CFM_Project>();
        for (Project__c row : projects) result.add(new CFM_Project(row));
        return result;
   }


    public static Integer getRandomProject(List<Id> sourceList) {
        Integer randomIndex = (Integer) Math.floor(Math.random() * sourceList.size()); 
        return randomIndex;
    }

   
    public class Finder extends CFM_BaseFinder {
        public Finder(String sObjectName) {
            // Use all fields
            super(sObjectName);
        }

        public Finder(String sObjectName, Set<String> fields) {
            // Use only fields specified (for performance)
            super(sObjectName, fields);
            System.debug('Total fields being used: ' + fields.size());
        }


        public List<Id> findIdByWhere(String whereClause) {
            // Assumes that SOQL has already been cleaned and is safe

            String soql = 'Select Id from ' + mSObjectName + ' where ' + whereClause + ' limit ' + CFM_BaseFinder.SOQL_LIMIT;

            List<sObject> queryResult = Database.query(soql);

            List<Id> result = new List<Id>();
            for (sObject row : queryResult) result.add(row.Id);

            return result;
        }

        public List<CFM_Project> findByIds(List<Id> projectIds) {
            String soql = getSelect() + ' WHERE Id in :projectIds limit ' + CFM_BaseFinder.SOQL_LIMIT;
            List<Project__c> projectList = Database.query(soql);
            return CFM_Project.decorate(projectList);
        }

        public CFM_Project findById(Id projectId) {
            Project__c project = (Project__c)byId(projectId);
            return new CFM_Project(project);
        }
    }

    
    // List of fields used in SOQL queries
    public static Set<String> getProjectQueryFields() {
        return new Set<String>
        {
            'Id',
            'Name',
            'Project_Name__c',
            'OraclePercentComplete__c',
            'CFM_Last_Survey_Date__c',
            'Oracle_Region__c',
            'CFM_Survey_Contact__c',
            'OracleStatus__c',
            'Owner__c',
            'CFM_Survey_Contact__c',
            'CFM_Survey_Contact__r.Email',
            'Oracle_Project_Number__c',
            'Oracle_Project_Manager_lookup__c',
            'OracleContractType__c',
            'OracleDateStarted__c',
            'OracleClientNumber__c',
            'OracleClientName__c',
            'Oracle_Completion_Date_edit__c',
            'OracleOffice__c',
            'OracleDepartment__c',
            'OracleAECOMDistrict__c',
            'OracleBusinessLine__c',
            'Oracle_Super_Geography__c',
            'Oracle_Geography__c',
            'OracleProjectCity__c',
            'Oracle_Group_Customer_Name__c'
        };
    }

    // List of fields that the user is able to filter on from the project search screen
    public static Set<String> getProjectFilterFields() {
        return new Set<String>
        {
            'Project_Name__c',
            'OraclePercentComplete__c',
            'OracleStatus__c',
            'Oracle_Project_Number__c',
            'OracleContractType__c',
            'OracleDateStarted__c',
            'Oracle_Completion_Date_edit__c',
            'OracleClientNumber__c',
            'OracleClientName__c',
            'Oracle_Project_Director__c',
            'Oracle_Project_Manager_lookup__c',
            'OracleOffice__c',
            'OracleDepartment__c',
            'OracleBusinessLine__c',
            'Oracle_Super_Geography__c',
            'Oracle_Geography__c',
            'OracleProjectCity__c',
            'OracleProjectCountryState__c',
            'OracleAecomRole__c',
            'Oracle_Region__c',
            'OracleAECOMDistrict__c',
            'Oracle_Group_Customer_Name__c',
            'CFM_Is_DTW_Project__c',
            'CFM_Is_CAM_Account__c'
        };
    }

    // List of fields that the user is able to filter on from the default inclusion criteria
    public static Set<String> getDefaultInclusionCriteriaFields() {
        return new Set<String>
        {
            'CFM_Last_Survey_Date__c',
            'CFM_Contact_Last_Survey_Date_Sent__c',
            'CFM_Last_Survey_Complete__c',
            'OraclePercentComplete__c',
            'OracleStatus__c',
            'CFM_Do_Not_Survey__c',
            'CFM_Account_Do_Not_Survey__c',
            'CFM_Survey_Contact_Do_Not_Survey__c',
            'CFM_Days_Since_Last_Survey__c',
            'CFM_Contact_Days_Since_Last_Survey__c',
            'CFM_PM_Is_Active__c',
            'CFM_Is_DTW_Project__c',
            'CFM_Is_CAM_Account__c'
        };
    }

    
}