/**
 *  @Author: Sujit Kumar
 *  @Created: 7 Aug, 2015
 */
@isTest
private class ECO_Utils_DateTest {

	/*
	 *   Given 2 dates: today and 5 weeks from now
	 *   When: invoke getStartOfWeekDatesBetweenTwoDates
	 *   Then: return a list of start of week dates between the given 2 dates
	 */
    static testMethod void given2Dates_whenGetStartOfWeekDatesBetweenTwoDates_thenReturnListOfStartOfWeekDates() {
    	Date startDate = Date.newInstance(2015, 8, 7); // 7 Aug, 2015
    	Date endDate = startDate.addDays(35); // 8 weeks
    	List<String> listOfDates = ECO_Utils_Date.getStartOfWeekDatesBetweenTwoDates(startDate, endDate);
    	System.debug('listOfDates:' + listOfDates);
    	System.assert(listOfDates.size() == 6);
        // ECO_Utils_Date uses Sunday (.toStartOfWeek), where ECO_Service_Snapshots uses Saturday
        // Also, ECO_Utils_Date.getStartOfWeekDatesBetweenTwoDates is UNUSED and can be removed in next release
        Date startOfWeekOfStartDate = startDate.toStartofWeek();
        // Date startOfWeekOfStartDate = ECO_Service_Snapshots.getFirstDateOfWeek(startDate);
    	System.assertEquals(listOfDates.get(0), ECO_Utils_Date.formatDateAsMMSlashDDSlashYYYY(startOfWeekOfStartDate));
    	System.assertEquals(listOfDates.get(1), ECO_Utils_Date.formatDateAsMMSlashDDSlashYYYY(startOfWeekOfStartDate.addDays(7)));
    	System.assertEquals(listOfDates.get(2), ECO_Utils_Date.formatDateAsMMSlashDDSlashYYYY(startOfWeekOfStartDate.addDays(14)));
    	System.assertEquals(listOfDates.get(3), ECO_Utils_Date.formatDateAsMMSlashDDSlashYYYY(startOfWeekOfStartDate.addDays(21)));
    	System.assertEquals(listOfDates.get(4), ECO_Utils_Date.formatDateAsMMSlashDDSlashYYYY(startOfWeekOfStartDate.addDays(28)));
    	System.assertEquals(listOfDates.get(5), ECO_Utils_Date.formatDateAsMMSlashDDSlashYYYY(startOfWeekOfStartDate.addDays(35)));
    }
}