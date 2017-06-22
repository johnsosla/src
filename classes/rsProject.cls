/*************************************************************************
*
* PURPOSE: Decorator for Project object
*
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
public class rsProject extends rsModel {

    public static Finder find = new Finder('Project__c');

    private static final Map<String,Schema.RecordTypeInfo> mRtInfo;
    static {
        mRtInfo = Project__c.SObjectType.getDescribe().getRecordTypeInfosByName();
    }

    public rsProject() {
        super(new Project__c());
    }

    public rsProject(Project__c proj) {
        super(proj);
    }

    public String getProjectName() {
        return (String)mObj.get('Project_Name__c');
    }

    public String getProjectNumber() {
        return (String)mObj.get('Oracle_Project_Number__c');
    }

    public String getLocation() {
        return (String)mObj.get('Location_Output__c');
    }

    public String getClientName() {
        return (String)mObj.get('Owner_Client_Output__c');
    }

    public class Finder extends rsFinder {

        public Finder(String sObjectName) {
            super(sObjectName);
        }

        public List<rsProject> getLookupResults(String searchName, String searchProjectNumber, String searchLocation, String searchClient) {
            Boolean isFirstAdded = false;
            String whereStr = '';

            if(String.isNotBlank(searchName) ) {
                if(!isFirstAdded) {
                    isFirstAdded = true;
                }
                whereStr += 'Project_Name__c LIKE ' + rsStringUtil.likeQueryQuote(searchName);
            }
            if(String.isNotBlank(searchProjectNumber) ) {
                if(!isFirstAdded) {
                    isFirstAdded = true;
                } else {
                    whereStr += ' AND ';
                }
                whereStr += 'Oracle_Project_Number__c LIKE ' + rsStringUtil.likeQueryQuote(searchProjectNumber);
            }
            if(String.isNotBlank(searchLocation) ) {
                if(!isFirstAdded) {
                    isFirstAdded = true;
                } else {
                    whereStr += ' AND ';
                }
                whereStr += 'Location_Output__c LIKE ' + rsStringUtil.likeQueryQuote(searchLocation);
            }
            if(String.isNotBlank(searchClient) ) {
                if(!isFirstAdded) {
                    isFirstAdded = true;
                } else {
                    whereStr += ' AND ';
                }
                whereStr += 'Owner_Client_Output__c LIKE ' + rsStringUtil.likeQueryQuote(searchClient);
            }
            return getByWhere(whereStr);
        }

        public List<rsProject> getByWhere(String whereStr) {
            System.debug('###' + whereStr);
            List<rsProject> returnList = new List<rsProject>();
            List<Project__c> queryProjects = (List<Project__c>)Database.query('select Id,Project_Name__c,Oracle_Project_Number__c,Location_Output__c,Owner_Client_Output__c from Project__c where ' + whereStr + ' LIMIT 200');
            for(Project__c proj : queryProjects) {
                returnList.add(new rsProject(proj));
            }
            return returnList;
        }
    }
}