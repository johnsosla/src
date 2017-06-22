public without sharing class CFM_SurveyBatchProjectCSVGenerator extends CFM_CSVGenerator {

    public static List<String>        COLUMN_HEADERS;
    public static Map<String, String> COLUMNS_TO_FIELDS;
    public static String              HEADER_EMAIL;
    public static String              HEADER_LANGUAGE;
    public static Set<String>         CUSTOM_FIELDS;

    private Map<String, String>       mSignatoriesByDepartmentName;
    private String                    mDefaultSignatoryName;
    
    static {
        setupHeadersAndFields();
    }

    public CFM_SurveyBatchProjectCSVGenerator(List<CFM_SurveyBatchProject> rows) {
        super(rows);
        if (rows.isEmpty()) {
            throw new NoRowsFoundException('Need at least one row to find attachment parent id');
        }

        setupDepartmentNames(rows);
    }

    public static List<String> getAllFields() {
        return COLUMNS_TO_FIELDS.values();
    }

    public static Integer getLanguageColumnIndex() {
        for (Integer i = 0; i < COLUMN_HEADERS.size(); i++) {
            if (COLUMN_HEADERS[i] == HEADER_LANGUAGE) {
                return i;
            }
        }
        return -1;
    }

    public static Integer getEmailColumnIndex() {
        for (Integer i = 0; i < COLUMN_HEADERS.size(); i++) {
            if (COLUMN_HEADERS[i] == HEADER_EMAIL) {
                return i;
            }
        }
        return -1;
    }

    protected override List<String> getColumnHeaders() {
        return COLUMN_HEADERS;
    }

    protected override Map<String, String> getColumnNamesToFields() {
        return COLUMNS_TO_FIELDS;
    }

    protected override Set<String> getCustomFields() {
        return CUSTOM_FIELDS;
    }

    protected override String getAttachmentName(Boolean isPreview) {
        return 'Survey-batch-projects-' + DateTime.now().format('yyyy-MM-dd-hh:mma') + (isPreview ? '-preview' : '') + '.csv';
    }

    private static void setupHeadersAndFields() {
        COLUMN_HEADERS = new List<String>();
        COLUMNS_TO_FIELDS = new Map<String, String>();
        CUSTOM_FIELDS = new Set<String>();
        for (CFM_SurveyBatchCSVColumn column : CFM_SurveyBatchCSVColumn.find.allSorted()) {
            COLUMN_HEADERS.add(column.getColumnLabel());

            if (column.getIsEmailColumn()) {
                HEADER_EMAIL = column.getColumnLabel();
            }
            if (column.getIsLanguageColumn()) {
                HEADER_LANGUAGE = column.getColumnLabel();
            }

            if (column.getIsCustomImplementation()) {
                CUSTOM_FIELDS.add(column.getColumnLabel());
            }
            else {
                COLUMNS_TO_FIELDS.put(column.getColumnLabel(), column.getColumnField());
            }
        }
    }

    protected override Id getAttachmentParentId() {
        return ((CFM_SurveyBatchProject)mRows[0]).getSurveyBatchId();
    }

    protected override String getCustomValue(String customHeader, CFM_BaseModel row) {
        CFM_SurveyBatchProject batchProject = (CFM_SurveyBatchProject)row;
        if (customHeader == CFM_SurveyBatchCSVColumn.find.columnLabelByName(CFM_SurveyBatchCSVColumn.COL_SIGNATORY_NAME)) {
            return getSignatoryName(batchProject);
        }
        else {
            throw new CFM_CSVGenerator.UnknownCustomImplementationHeaderException('Unknown custom header requested: ' + customHeader);
        }
        return null;
    }

    private String getSignatoryName(CFM_SurveyBatchProject batchProject) {
        String signatory = mSignatoriesByDepartmentName.get(batchProject.getOracleDepartment());
        if (String.isBlank(signatory)) {
            return mDefaultSignatoryName;
        }
        else {
            return signatory;
        }
    }

    private void setupDepartmentNames(List<CFM_SurveyBatchProject> rows) {
        mDefaultSignatoryName = CFM_Survey_Settings__c.getInstance(UserInfo.getUserId()).Default_Signatory_Name__c;

        mSignatoriesByDepartmentName = new Map<String, String>();
        List<String> deptNames = new List<String>();
        for (CFM_SurveyBatchProject row : rows) {
            deptNames.add(row.getOracleDepartment());
        }

        for (CFM_AECOMPrimaryDepartment dept : CFM_AECOMPrimaryDepartment.find.byNames(deptNames)) {
            mSignatoriesByDepartmentName.put(dept.getName(), dept.getRegionExecutiveName());
        }
    }

    public class NoRowsFoundException extends Exception{}
}