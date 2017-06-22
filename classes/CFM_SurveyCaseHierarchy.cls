public class CFM_SurveyCaseHierarchy extends CFM_BaseModel {

    public static Finder find = new Finder('CFM_Survey_Case_Hierarchy__c');

    public static final String DEFAULT_KEY = 'DEFAULT';
 
    public CFM_Survey_Case_Hierarchy__c obj { get { return (CFM_Survey_Case_Hierarchy__c)mObj; } }

    public CFM_SurveyCaseHierarchy(CFM_Survey_Case_Hierarchy__c caseHierarchy) {
        super(caseHierarchy);
    }

    public String getKey() {
        String key = obj.Operating_Group_txt__c + '|';
        if (obj.Lead_District__c != null) key += obj.Lead_District__c;
        key += '|';
        if (obj.Business_Line_txt__c != null) key += obj.Business_Line_txt__c;
        return key;
    }

    public String getStep1EmailTemplate() {
        return obj.Step_1_Email__c;
    }  

    //public static CFM_SurveyCaseHierarchy findRoutingForProject(Map<String, CFM_SurveyCaseHierarchy> routings, Map<String, AECOM_Primary_Department__c> departments, Project__c project) {

    //    if (project.OracleDepartment__c != null && departments.containsKey(project.OracleDepartment__c)) {
    //        AECOM_Primary_Department__c department = departments.get(project.OracleDepartment__c);
    //        String operatingGroup = department.Operating_Group__c;
    //        String leadDistrict = department.Lead_District__c;
    //        String businessLine = department.Business_Line_Lookup__c;

    //        String olb = operatingGroup + '|' + leadDistrict + '|' + businessLine;
    //        String ol = operatingGroup + '|' + leadDistrict + '|';
    //        String o = operatingGroup + '||';

    //        List<String> keyCombinations = new List<String> { olb, ol, o};

    //        for (String keyCombination : keyCombinations) {
    //            if (routings.containsKey(keyCombination)) {
    //                return routings.get(keyCombination);
    //            }
    //        }
    //    }
        

    //    if (routings.containsKey(DEFAULT_KEY)) {
    //        return routings.get(DEFAULT_KEY);
    //    }


    //    return null;
    //}

        public static CFM_SurveyCaseHierarchy findRoutingForProject(Map<String, CFM_SurveyCaseHierarchy> routings, Project__c project) {

        if (project.OracleBusinessLine__c != null && project.OracleAECOMDistrict__c != null && project.Oracle_Super_Geography__c != null) {
            String operatingGroup = project.Oracle_Super_Geography__c;
            String leadDistrict = project.OracleAECOMDistrict__c;
            String businessLine = project.OracleBusinessLine__c;

            String olb = operatingGroup + '|' + leadDistrict + '|' + businessLine;
            String ol = operatingGroup + '|' + leadDistrict + '|';
            String o = operatingGroup + '||';

            List<String> keyCombinations = new List<String> { olb, ol, o};

            for (String keyCombination : keyCombinations) {
                if (routings.containsKey(keyCombination)) {
                    return routings.get(keyCombination);
                }
            }
        }
        

        if (routings.containsKey(DEFAULT_KEY)) {
            return routings.get(DEFAULT_KEY);
        }


        return null;
    }

    public static List<CFM_SurveyCaseHierarchy> decorate(List<CFM_Survey_Case_Hierarchy__c> sList) {
        List<CFM_SurveyCaseHierarchy> mList = new List<CFM_SurveyCaseHierarchy>();
        for (CFM_Survey_Case_Hierarchy__c sRow : sList) mList.add(new CFM_SurveyCaseHierarchy(sRow));
        return mList;
    }


    public class Finder extends CFM_BaseFinder {
        public Finder(String sObjectName) {
            super(sObjectName); 
        }


        public Map<String, CFM_SurveyCaseHierarchy> forProjects(List<Project__c> projects) {
            Map<String, CFM_SurveyCaseHierarchy> keyToHierarchyMap = new Map<String, CFM_SurveyCaseHierarchy>();
            
            Set<String> operatingGroups = new Set<String>();
            Set<String> leadDistricts = new Set<String>();
            Set<String> businessLines = new Set<String>();

            for (Project__c project : projects) {
                if (project.Oracle_Super_Geography__c != null) operatingGroups.add(project.Oracle_Super_Geography__c);
                if (project.OracleAECOMDistrict__c != null) leadDistricts.add(project.OracleAECOMDistrict__c);
                if (project.OracleBusinessLine__c != null) businessLines.add(project.OracleBusinessLine__c);
            }

             List<CFM_SurveyCaseHierarchy> searchResults = CFM_SurveyCaseHierarchy.decorate(Database.query(getSelect() + ' WHERE (Is_Default_Rule__c = true OR Operating_Group_txt__c in :operatingGroups OR Lead_District__c in :leadDistricts OR Business_Line_txt__c in :businessLines) AND Inactive__c = false'));

            for (CFM_SurveyCaseHierarchy row : searchResults) {
                if (row.obj.Is_Default_Rule__c) {
                    keyToHierarchyMap.put(CFM_SurveyCaseHierarchy.DEFAULT_KEY, row);
                }
                else {
                    keyToHierarchyMap.put(row.getKey(), row);
                }
            }

            return keyToHierarchyMap;
        }
        
        //public Map<String, CFM_SurveyCaseHierarchy> forDepartments(List<AECOM_Primary_Department__c> departments) {
        //    Map<String, CFM_SurveyCaseHierarchy> keyToHierarchyMap = new Map<String, CFM_SurveyCaseHierarchy>();
            
        //    Set<String> operatingGroups = new Set<String>();
        //    Set<String> leadDistricts = new Set<String>();
        //    Set<String> businessLines = new Set<String>();

        //    for (AECOM_Primary_Department__c department : departments) {
        //        if (department.Operating_Group__c != null) operatingGroups.add(department.Operating_Group__c);
        //        if (department.Lead_District__c != null) leadDistricts.add(department.Lead_District__c);
        //        if (department.Business_Line_Lookup__c != null) businessLines.add(department.Business_Line_Lookup__c);
        //    }

        //    List<CFM_SurveyCaseHierarchy> searchResults = CFM_SurveyCaseHierarchy.decorate(Database.query(getSelect() + ' WHERE Is_Default_Rule__c = true OR Operating_Group__c in :operatingGroups OR Lead_District__c in :leadDistricts OR Business_Line__c in :businessLines'));

        //    for (CFM_SurveyCaseHierarchy row : searchResults) {
        //        if (row.obj.Is_Default_Rule__c) {
        //            keyToHierarchyMap.put(CFM_SurveyCaseHierarchy.DEFAULT_KEY, row);
        //        }
        //        else {
        //            keyToHierarchyMap.put(row.getKey(), row);
        //        }
        //    }

        //    return keyToHierarchyMap;
        //}
    }
}