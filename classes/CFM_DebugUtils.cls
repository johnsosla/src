public class CFM_DebugUtils {

    private static Boolean debugMode = UserInfo.getUserName().toLowerCase().contains('ethos.com.npssurvey');

    static Integer count = 0;

    public static void log(Object message) {
        System.debug(LoggingLevel.ERROR, '###' + message);
        if (System.currentPageReference() != null && debugMode) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, ++count + '. ' + (String)message) );
        }

    }

    public static void log(String field, Object value) {
        log(field, value, true);
    }


    public static void log(String field, Object value, Boolean addPageMessage) {
        System.debug(LoggingLevel.ERROR, '###' + field + ': ' + value);
        if (System.currentPageReference() != null && debugMode && addPageMessage) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, ++count + '. ' + field + ': ' + value) );
        }
    }

    public static void log() {
        log(true);
    }
    public static void log(Boolean addPageMessage) {
        System.debug(LoggingLevel.ERROR, '###========================');
        if (System.currentPageReference() != null && debugMode && addPageMessage) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, ++count + '. ' + '###========================') );
        }
    }

}