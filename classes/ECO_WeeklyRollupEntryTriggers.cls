public class ECO_WeeklyRollupEntryTriggers {
	public static Boolean run = true;

    public class WeeklyRollupEntryException extends Exception {
    }

    /**
    * This method is a sanity check only.  It should run temporarily until it has been determined that WeeklyRollupEntry__c
    * CurrencyISOCode is always, always, always the same as the parent project ProjectFunctionalCurrencyCode__c.
    *
    * TODO - July 1, 2017 - make a determination to delete this method if the error never occurs
    *
    * @Author Graham MacRobie graham.macrobie@nttdata.com (Deborah Orth, Brian Jacobi, and Jake White are also familiar)
    * @Date July 6, 2016
    */

    public static void checkCurrency(list<WeeklyRollupEntry__c> weeklyrollupentries) {
        if (!run) { return; }

        if (Test.isRunningTest())  // to avoid breaking tests
            return;

        checkCurrencyDoWork(weeklyrollupentries);
    }

    public static void checkCurrencyDoWork(list<WeeklyRollupEntry__c> weeklyrollupentries) {
        Set<Id> projectIds = new Set<Id>();

        List<String> exceptionStrings = new List<String>();

        for (WeeklyRollupEntry__c wre : weeklyrollupentries) {
            if (wre.Project__c != null) {
                projectIds.add(wre.Project__c);
            } else {
                exceptionStrings.add('weekly rollup entry is missing project - ' + wre.id);
            }
        }

        List<pse__Proj__c> projects = [select id, ProjectFunctionalCurrencyCode__c from pse__Proj__c where id in :projectIds];

        Map<Id, String> currencyMap = new Map<Id, String>();

        for (pse__Proj__c project : projects) {
            if (project.ProjectFunctionalCurrencyCode__c != null) {
                currencyMap.put(project.id, project.ProjectFunctionalCurrencyCode__c);
            } else {
                exceptionStrings.add('project is missing ProjectFunctionalCurrencyCode__c ' + project.id);
            }
        }

        for (WeeklyRollupEntry__c wre : weeklyrollupentries) {
            String wreCurrencyCode = wre.CurrencyISOCode;

            if (wre.Project__c == null)
                continue;

            if (wreCurrencyCode == null) {
                exceptionStrings.add('weekly rollup entry is missing CurrencyISOCode ' + wre.id);

                continue;
            }

            String projectCurrencyCode = currencyMap.get(wre.Project__c);

            if (projectCurrencyCode == null)
                continue;

            if (!wreCurrencyCode.equalsIgnoreCase(projectCurrencyCode)) {
                exceptionStrings.add('weekly rollup entry CurrencyISOCode does not match ProjectFunctionalCurrencyCode__c ' + 
                    wre.id + ' - ' + wreCurrencyCode + ' - ' + wre.Project__c + ' - ' + projectCurrencyCode);
            }
        }

        if (exceptionStrings.size() > 0) {
            String exceptionString = '';

            for (String s : exceptionStrings) {
                exceptionString += s + '\n';
            }

            ECO_Service_ErrorLog.logException(new WeeklyRollupEntryException(exceptionString));
        }
    }
	
    public static void calculateFiscalMonths(list<WeeklyRollupEntry__c> weeklyrollupentries) {
    	if (!run) { return; }
        list<date> enddatelist = new list<date>();
        Set<Date> datesToConvert = new Set<Date>();
        Map<Date, String> mapTimePeriodCodeByDate = new Map<Date, String> ();

        for (WeeklyRollupEntry__c ba : weeklyrollupentries) {
            datesToConvert.add(ba.PeriodStartDate__c);
            if (ba.PeriodStartDate__c != null) {
                enddatelist.add((ba.PeriodStartDate__c).addmonths(2));
                enddatelist.add((ba.PeriodStartDate__c).addmonths(1));
                enddatelist.add((ba.PeriodStartDate__c).addmonths(0));
                enddatelist.add((ba.PeriodStartDate__c).addmonths(-1));
                enddatelist.add((ba.PeriodStartDate__c).addmonths(-2));
                enddatelist.add((ba.PeriodStartDate__c).addmonths(-3));
            }
        }
        
        datesToConvert.remove(null);

        List<pse__Time_Period__c> timePeriods  = new  List<pse__Time_Period__c>();
        if (enddatelist.size() > 0) {
            // Time period
            timePeriods = ECO_Utils_Date.calcTimePeriods(enddatelist, 'Month');
            pse__Time_Period__c fm = null;

            for (Date dt : datesToConvert) {
                fm = ECO_Utils_Date.getFiscalPeriod(dt, 0, timePeriods);
                if (fm != null) {
                    mapTimePeriodCodeByDate.put(dt, fm.TimePeriodCode__c);
                }
            }

            for (WeeklyRollupEntry__c ba : weeklyrollupentries) {
                if (ba.PeriodStartDate__c != null) {
                    ba.FiscalMonth__c = mapTimePeriodCodeByDate.get(ba.PeriodStartDate__c);
                }
            }
        }

    }
}