/**
* @author Nathan Pilkington
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_StringUtil
*              PURPOSE: Utility class for string logic
*              CREATED: 06/2016 Ethos Solutions - www.ethos.com
**/
public class SGT_StringUtil {

	public static String formatDateForSoql(Date d) {
		// SOQL requires month and date to have a leading zero, HOWEVER, the Date class does not have a .format(String) method...
		// Also, there is no "Pad" function for apex strings
		return d.year() + '-' + (d.month() < 10 ? '0' + d.month() : String.valueOf(d.month())) + '-' + (d.day() < 10 ? '0' + d.day() : String.valueOf(d.day()));
	}

	public static String quote(String stringToQuote) {
		return '\'' + String.escapeSingleQuotes(stringToQuote) + '\'';
	}

	public static Boolean isEmpty(String str) {
		return str == null || str.length() == 0 || str.trim().length() == 0;
	}


	public static String parseAndCleanMultiVal(String inputStr) {
        String[] vals = inputStr.split(';');

        for (Integer i = 0; i < vals.size(); i++) {
            vals[i] = SGT_BaseFinder.quote(vals[i].trim());
        }

        return String.join(vals, ',');
    }

    public static Set<String> multiValToSet(String inputStr, Boolean toLowerCase) {
    	if (inputStr == null) return new Set<String>();

        String[] vals = inputStr.split(';');

        for (Integer i = 0; i < vals.size(); i++) {
            vals[i] = toLowerCase ? vals[i].trim().toLowerCase() : vals[i].trim();
        }

        return new Set<String>(vals);
    }

    public static String toLower(String inputStr) {
    	return inputStr == null ? null : inputStr.toLowerCase();
    }

    public static String inClause(String inputStr) {
    	String[] vals = inputStr.split(';');

        for (Integer i = 0; i < vals.size(); i++) {
            vals[i] = quote(vals[i].trim());
        }

        return '(' + String.join(vals, ',') + ')';
    }

    // This method takes in a date string in either MM/DD/YYYY or YYYY-MM-DD and returns a string that is usable as a soql date literal (e.g. 2015-07-08)
	// Throws: InvalidDateFormatException if the input is in an invalid format
	public static String convertDateStringToSoqlFormat(String sVal) {
		Date dateValue = getDateFromString(sVal);
		return DateTime.newInstance(dateValue.year(), dateValue.month(), dateValue.day()).format('yyyy-MM-dd'); // Must convert to DateTime first as Date does not have format(String)
	}

		// This method takes in a date in either MM/DD/YYYY or YYYY-MM-DD and returns a date object.
	// Throws: InvalidDateFormatException if the input is in an invalid format
	public static Date getDateFromString(String sVal) {
		Date result;

		if (sVal == null) throw new InvalidDateFormatException();

		sVal = sVal.trim();

		try {
			result = Date.parse(sVal); // DateTime.parse checks for MM/DD/YYYY, or whatever the user's local format is
		}
		catch (Exception e) { } // Non-MM/DD/YYYY format

		if (result == null) {
			try {
				result = Date.valueOf(sVal); // DateTime.valueOf checks for YYYY-MM-DD
			} 
			catch (Exception e) {
				// We've exhausted our format options, so an invalid format was passed in.
				throw new InvalidDateFormatException();
			}
		}

		return result;
	}

	public static String shortId(String longId) {
		if (String.isBlank(String.valueOf(longId)) || String.valueOf(longId).length() == 15) return longId;
		return String.valueOf(longId).substring(0, 15);
	}

	public class InvalidDateFormatException extends Exception { } 

}