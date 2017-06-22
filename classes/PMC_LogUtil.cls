public without sharing class PMC_LogUtil {

	public static final String LEVEL_DEBUG = 'Debug';
	public static final String LEVEL_WARNING = 'Warning';
	public static final String LEVEL_ERROR = 'Error';

	public static List<PMC_Integration_Log__c> logBuffer = new List<PMC_Integration_Log__c>();

	public static String transactionId = PMC_LogUtil.newGuid(); // Since static variables are initialized for each transaction, this will be unique for each transaction

	public static void insertError(String source, String logMsg) {
		insertLog(LEVEL_ERROR, source, logMsg, false);
        flush();
	}

	public static void insertWarning(String source, String logMsg, Boolean buffer) {
		PMC_Settings__c ps = PMC_Settings__c.getOrgDefaults();

		if (ps.Logging_Level__c == null || ps.Logging_Level__c == LEVEL_DEBUG || ps.Logging_Level__c == LEVEL_WARNING) {
			insertLog(LEVEL_WARNING, source, logMsg, buffer);
		}
	}

	public static void insertDebug(String source, String logMsg, Boolean buffer) {
		PMC_Settings__c ps = PMC_Settings__c.getOrgDefaults();
		
		if (ps.Logging_Level__c == null || ps.Logging_Level__c == LEVEL_DEBUG) {
			insertLog(LEVEL_DEBUG, source, logMsg, buffer);
		}
	}

	public static void insertLog(String logLevel, String source, String logMsg, Boolean buffer) {
		PMC_Integration_Log__c log = new PMC_Integration_Log__c();
        log.Log_Message__c = logMsg;
        log.Log_Level__c = logLevel;
        log.Source__c = source;
        log.Transaction_ID__c = transactionId;

        System.debug(LoggingLevel.DEBUG, logMsg);

        if (buffer) {
        	logBuffer.add(log);
        }
        else {
        	insert log;	
        }
        
	}

	public static void flush() {
		if (logBuffer.size() > 0) insert logBuffer;
		logBuffer = new List<PMC_Integration_Log__c>();
	}

	public static String newGuid() {
        String kHexChars = '0123456789abcdef';

        String returnValue = '';
        Integer nextByte = 0;

        for (Integer i=0; i<16; i++) {

            if (i==4 || i==6 || i==8 || i==10)
                returnValue += '-';

            nextByte = (Math.round(Math.random() * 255)-128) & 255;

            if (i==6) {
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }

            if (i==8) {
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }

            returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
            returnValue += getCharAtIndex(kHexChars, nextByte & 15);
        }

        return returnValue;
    }

    public static String getCharAtIndex(String str, Integer index) {
        if (str == null) return null;
        if (str.length() <= 0) return str;
        if (index == str.length()) return null;
        return str.substring(index, index+1);
    }
}