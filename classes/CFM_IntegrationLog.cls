public with sharing class CFM_IntegrationLog extends CFM_BaseModel {

    public static Finder find = new Finder('CFM_Integration_Log__c');


    public CFM_Integration_Log__c obj { get { return (CFM_Integration_Log__c)mObj; } }

    public static final String STATUS_SENDING               = 'Sending';
    public static final String STATUS_CONN_EXCEPTION        = 'Connection Exception';
    public static final String STATUS_PROC_EXCEPTION        = 'Processing Exception';
    public static final String STATUS_COMPLETE              = 'Complete';

    public static final String METHOD_IMPORT_PANEL          = 'importPanel';
    public static final String METHOD_SEND_SURVEY           = 'sendSurveyToPanel';


    public CFM_IntegrationLog() {
        this(new CFM_Integration_Log__c());
    }

    public CFM_IntegrationLog(CFM_Integration_Log__c log) {
        super(log);
    }

    public String getName() {
        return obj.Name;
    }

    public String getMethodCalled() {
        return obj.Method_Called__c;
    }
    public void setMethodCalled(String methodCalled) {
        obj.Method_Called__c = methodCalled;
    }

    public void setResult(String s) {
        obj.Result__c = s;
    }

    public void setStatus(String s) {
        obj.Status__c = s;
    }

    public static List<CFM_IntegrationLog> decorate(List<CFM_Integration_Log__c> sList) {
        List<CFM_IntegrationLog> result = new List<CFM_IntegrationLog>();
        for (CFM_Integration_Log__c row : sList) result.add(new CFM_IntegrationLog(row));
        return result;
    }

    public class Finder extends CFM_BaseFinder {

        public Finder(String sObjectName) {
            super(sObjectName);
        }

        public List<CFM_IntegrationLog> bySurveyBatchId(Id batchId) {
            return decorate((List<CFM_Integration_Log__c>)getSelectWhere('Survey_Batch__c', batchId));
        }
    }
}