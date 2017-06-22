public with sharing class CFM_AECOMPrimaryDepartment extends CFM_BaseModel {

    public static Finder find = new Finder();

    public AECOM_Primary_Department__c obj { 
        get {
            return (AECOM_Primary_Department__c)mObj; 
        }
    }

    public CFM_AECOMPrimaryDepartment() {
        this(new AECOM_Primary_Department__c());
    }

    public CFM_AECOMPrimaryDepartment(AECOM_Primary_Department__c sObj) {
        super(sObj);
    }

    public String getName() {
        return obj.Name;
    }

    public String getRegionExecutiveName() {
        return obj.CFM_Region_Executive__r.Name;
    }

    public static List<CFM_AECOMPrimaryDepartment> decorate(List<AECOM_Primary_Department__c> sList) {
        List<CFM_AECOMPrimaryDepartment> result = new List<CFM_AECOMPrimaryDepartment>();
        for (AECOM_Primary_Department__c row : sList) result.add(new CFM_AECOMPrimaryDepartment(row));
        return result;
    }

    public class Finder extends CFM_BaseFinder {
        public Finder() {
            super('AECOM_Primary_Department__c');
            addField('CFM_Region_Executive__r.Name');
        }

        public List<CFM_AECOMPrimaryDepartment> byNames(List<String> deptNames) {
            List<AECOM_Primary_Department__c> result = (List<AECOM_Primary_Department__c>)getSelectIn('Name', deptNames);
            return decorate(result);
        }

    }
}