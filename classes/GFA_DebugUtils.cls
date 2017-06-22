/*******************************************************************************
*
* PURPOSE: Debug Utility class
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
*******************************************************************************/
public class GFA_DebugUtils {

    private static final Decimal LIMIT_TOLERANCE = 0.9;

    private static Boolean debugMode = UserInfo.getUserName().contains('gpdsdev');
    //IMPORTANT: set this to false if going to customer
    static Integer count = 0;
    private static Integer indentLevel = 0;

    private static GFA_DebugUtils singleton = new GFA_DebugUtils();
    private static Map<String, List<Integer>> mMethodCpuTimes = new Map<String, List<Integer>>();

    public List<String> debugLogs = new List<String>();

    private GFA_DebugUtils() {
        debugLogs = new List<String>();
    }

    public static Boolean getDebugMode() {
        return debugMode;
    }
    public static void setDebugMode(Boolean mDebugMode) {
        debugMode = mDebugMode;
    }

    public static void log(Object message) {
        System.debug(LoggingLevel.ERROR, '###' + message);
        checkLimits(message);
        if (System.currentPageReference() != null && debugMode) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, ++count + '. ' + ('-'.repeat(indentLevel)) + (String)message) );
        }

    }

    public static void log(String field, Object value) {
        log(field, value, true);
    }


    public static void log(String field, Object value, Boolean addPageMessage) {
        System.debug(LoggingLevel.ERROR, '###' + field + ': ' + value);
        checkLimits(field + ': ' + value);
        if (System.currentPageReference() != null && debugMode && addPageMessage) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, ++count + '. ' + ('-'.repeat(indentLevel)) + field + ': ' + value) );
        }
    }

    public static void log() {
        log(true);
    }
    public static void log(Boolean addPageMessage) {
        System.debug(LoggingLevel.ERROR, '###========================');
        checkLimits('========================');
        if (System.currentPageReference() != null && debugMode && addPageMessage) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, ++count + '. ' + '###' + ('-'.repeat(indentLevel)) + '========================') );
        }
    }

    private static void checkLimits(Object msg) {
        if (debugMode) {
            //---Storing in singleton so that messages are stored in view state
            //---So they can be inspected even if the message is added after things will still
            //---Be added to the pageMessages and if the log is full
            singleton.debugLogs.add('-'.repeat(indentLevel) + msg);
            if (Limits.getQueries() > (LIMIT_TOLERANCE * Limits.getLimitQueries())) {
                System.assert(false, 'SOQL Limits - ' + JSON.serialize(singleton.debugLogs));
            }
            if (Limits.getCpuTime() > (LIMIT_TOLERANCE * Limits.getLimitCpuTime())) {
                System.assert(false, 'CPU Timeout - ' + JSON.serialize(singleton.debugLogs));
            }
        }
    }

    public static void startMethod(String methodName) {
        indentLevel += 4;
        addToCpuTimes(methodName);
        //log('start: ' + methodName);
    }
    public static void stopMethod(String methodName) {
        Integer startTime = removeFromCpuTimes(methodName);
        Integer endTime = Limits.getCpuTime();
        Integer methodRuntime = endTime - startTime;
        //log('end: ' + methodName + ', runtime (ms): ' + methodRuntime + ', total (ms): ' + endTime + (methodRuntime >= 5 ? '*********' : ''));
        indentLevel -= 4;
    }

    private static void addToCpuTimes(String methodName) {
        if (mMethodCpuTimes.containsKey(methodName)) {
            mMethodCpuTimes.get(methodName).add(Limits.getCpuTime());
        } else {
            mMethodCpuTimes.put(methodName, new List<Integer> {Limits.getCpuTime()});
        }
    }

    private static Integer removeFromCpuTimes(String methodName) {
        List<Integer> cpuTimes = mMethodCpuTimes.get(methodName);
        return cpuTimes.remove(cpuTimes.size() - 1);
    }

}