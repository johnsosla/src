public with sharing class CFM_CSVRow {

    private static List<String>         mHeaderValues;
    private static Map<String, Integer> mHeaderIndexes;

    private List<String> mValues;

	public CFM_CSVRow() {
        if (mHeaderValues == null) {
            throw new HeadersNotSetupException('Headers were not setup. Please call the CFM_CSVRow.setupHeaders() method and pass in a list of ordered header values');
        }
        mValues = new String[mHeaderValues.size()];
	}

    public static void setupHeaders(List<String> headers) {
        mHeaderValues = headers;

        mHeaderIndexes = new Map<String, Integer>();
        for (Integer i = 0; i < headers.size(); i++) {
            mHeaderIndexes.put(headers[i], i);
        }
    }

    public String get(String header) {
        if (!mHeaderIndexes.containsKey(header)) {
            throw new HeaderNotFoundException('Unknown header while getting value: ' + header);
        }
        return mValues[mHeaderIndexes.get(header)];
    }

    public void put(String header, Object value) {
        if (!mHeaderIndexes.containsKey(header)) {
            throw new HeaderNotFoundException('Unknown header while putting value: ' + header);
        }
        String val = String.valueOf(value);
        if (String.isBlank(val)) {
            mValues[mHeaderIndexes.get(header)] = '';    
        }
        else {
            mValues[mHeaderIndexes.get(header)] = val.replaceAll('"', '\\"');
        }
    }

    public override String toString() {
        return toEscapedCSVString(mValues);
    }

    public static String headersToString() {
        return toEscapedCSVString(mHeaderValues);
    }

    private static String toEscapedCSVString(List<String> values) {
        String result = '';
        for (String val : values) {
            result += val.escapeCsv() + ',';
        }
        return result.removeEnd(',');
    }


    public class HeadersNotSetupException extends Exception {}
    public class HeaderNotFoundException extends Exception {}
}