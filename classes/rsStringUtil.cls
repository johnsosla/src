// --------------------------------------------------------------------------------
// COMPONENT: Utility
// CLASS: rsStringUtil
// PURPOSE: Utility methods for String operations
// CREATED: 03/26/13 Ethos Solutions - www.ethos.com
// Author: Various
//--------------------------------------------------------------------------------
global class rsStringUtil {

    public static Boolean isNullOrEmpty(String value) {
        return value == null || value == '' || value.equalsIgnoreCase('null');
    }

    public static String cleanFieldName(String dirtyString,String findChar) {
        String cleanString = dirtyString.substring(dirtyString.indexOf(findChar)+1,dirtyString.length());
        return cleanString;
    }

    public static String quote(String stringToQuote)
    {
        return '\'' + String.escapeSingleQuotes(stringToQuote) + '\'';
    }

    public static String likeQueryQuote(String stringToQuote)
    {
        return '\'%' + String.escapeSingleQuotes(stringToQuote) + '%\'';
    }

    public static String toTitleCase(String phrase) {
        String titlePhrase = '';

        if(phrase != null && phrase.length() > 0) {
            String[] splitPhrase = phrase.trim().normalizeSpace().split(' ');

            for(integer i = 0; i < splitPhrase.size(); i++){
                titlePhrase += (splitPhrase[i].substring(0,1).toUpperCase())+(splitPhrase[i].substring(1).toLowerCase())+' ';
            }
        }
        return titlePhrase.trim();
    }
    public static String listJoin(List<String> stringToJoin) {
        return '(\'' + String.join(stringToJoin, '\',\'') + '\')';
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


    public class InvalidDateFormatException extends Exception { }

}