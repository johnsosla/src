public with sharing class ECO_Service_Snapshots {
    
    private static Date epoch;

    static {
        epoch = Date.newInstance(1900, 1, 6);  // a known Saturday, definitely in the past
    }

    public static Integer getDayOfWeek(Date dDate) {
        return Math.mod(epoch.daysBetween(dDate), 7);
    }

    public static String getWeekNumber(Date dDate) {
        Date firstDay = Date.newInstance(dDate.year(), 1, 1);  // January 1st of current year
        Integer offset = getDayOfWeek(firstDay);
        return String.valueOf((firstDay.daysBetween(dDate) + offset) / 7 + 1);
    }

    public static Date getFirstDateOfWeek(Date dDate) {
        Integer offset = getDayOfWeek(dDate);
        return dDate.addDays(-offset);
    }

	public static String DateToSnapshotKey(Date dDate, Id sProjectId){
        return DateToSnapshotKey(dDate, sProjectId, null);
    }
    
    public static String DateToSnapshotKey(Date dDate, Id sProjectId, Id sTaskId){
        string sSnapshotKey = '';
        string taskId = '';
        if (sTaskId != null) { taskId = sTaskId; }

        // Get Saturday of the week -- keys always based on the start date (avoid calendar year rollover issues)
        Date dFirstDayOfWeek = getFirstDateOfWeek(dDate);
        sSnapshotKey = sProjectId + '_' + taskId + '_' + dFirstDayOfWeek.year() + '-WK' + getWeekNumber(dFirstDayOfWeek);
        return sSnapshotKey;
    }
   
    public static Map<String, String> snapshotKeyValues(String snapshotKey) {
    	List<String> values = snapshotKey.split('_', -1);
    	Map<String, String> snapshotKeysMap = new Map<String, String>();
        snapshotKeysMap.put('projectId', values[0]);
        snapshotKeysMap.put('taskId', values[1]);
        snapshotKeysMap.put('calendarWeek', values[2]);
    	// Take calendar Week and reverse to get Date for FirstDayOfWeek
    	return snapshotKeysMap;
    }
}