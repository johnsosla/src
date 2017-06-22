public with sharing class CFM_SurveyBatchCSVColumn extends CFM_BaseModel implements Comparable {

    public static final String COL_SIGNATORY_NAME = 'Signatory Name';

    private static Map<String, CFM_SurveyBatchCSVColumn> mAllRecords;

    public static Finder find = new Finder();

    public CFM_Survey_Batch_CSV_Columns__c obj { 
        get { 
            return (CFM_Survey_Batch_CSV_Columns__c)mObj; 
        }
    }

    public CFM_SurveyBatchCSVColumn(CFM_Survey_Batch_CSV_Columns__c sObj) {
        super(sObj);
    }

    public String getColumnLabel() {
        return obj.Column_Label__c;
    }

    public String getColumnField() {
        return obj.Column_Field__c;
    }

    public Boolean getIsEmailColumn() {
        return obj.Is_Email_Column__c;
    }

    public Boolean getIsLanguageColumn() {
        return obj.Is_Language_Column__c;
    }

    public Boolean getIsCustomImplementation() {
        return obj.Is_Custom_Implementation__c;
    }

    public Integer compareTo(Object other) {
        return Integer.valueOf(obj.Index__c - ((CFM_SurveyBatchCSVColumn)other).obj.Index__c);
    }

    public class Finder extends CFM_BaseFinder {
        public Finder() {
            super('CFM_Survey_Batch_CSV_Columns__c');
            mAllRecords = new Map<String, CFM_SurveyBatchCSVColumn>();
            Map<String, CFM_Survey_Batch_CSV_Columns__c> all = CFM_Survey_Batch_CSV_Columns__c.getAll();
            for (String key : all.keyset()) {
                mAllRecords.put(key, new CFM_SurveyBatchCSVColumn(all.get(key)));
            }
        }

        public List<CFM_SurveyBatchCSVColumn> allSorted() {
            List<CFM_SurveyBatchCSVColumn> all = mAllRecords.values();
            all.sort();
            return all;
        }

        public CFM_SurveyBatchCSVColumn byName(String name) {
            return mAllRecords.get(name);
        }

        public String columnLabelByName(String name) {
            return byName(name).getColumnLabel();
        }
    }
}