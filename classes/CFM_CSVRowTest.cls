@isTest
public with sharing class CFM_CSVRowTest {

    private static String COL_1 = 'Col 1';
    private static String COL_2 = 'Col 2';
    private static String COL_3 = 'Col 3';
    private static String COL_4 = 'Col 4';
    private static String COL_5 = 'Col 5';

    private static List<String> mHeaders = new List<String> {
        COL_1,
        COL_2,
        COL_3,
        COL_4,
        COL_5
    };

    private static testMethod void testSetupHeaders() {
        Boolean threwException = false;
        try {
            CFM_CSVRow row = new CFM_CSVRow();
        }
        catch (CFM_CSVRow.HeadersNotSetupException e) {
            threwException = true;
        }
        System.assert(threwException, 'Should have thrown exception that headers were not setup');

        CFM_CSVRow.setupHeaders(mHeaders);

        threwException = false;
        try {
            CFM_CSVRow row = new CFM_CSVRow();
        }
        catch (CFM_CSVRow.HeadersNotSetupException e) {
            threwException = true;
        }
        System.assert(!threwException, 'Should not have thrown exception that headers were not setup since they were setup');
    }

    private static testMethod void testAccessors() {
        CFM_CSVRow.setupHeaders(mHeaders);
        CFM_CSVRow row = new CFM_CSVRow();

        row.put(COL_1, 'test');
        System.assertEquals(row.get(COL_1), 'test', 'Did not get out what was put in for first column');

        row.put(COL_2, 'test2');
        System.assertEquals(row.get(COL_2), 'test2', 'Did not get out what was put in for second column');

        Boolean unknownHeaderPut = false;
        try {
            row.put('Unknown Header Put', 'test3');
        }
        catch (CFM_CSVRow.HeaderNotFoundException e) {
            unknownHeaderPut = true;
            System.assert(e.getMessage().contains('Unknown Header Put'), 'Should have included the unknown header in exception: ' + e.getMessage());
        }
        System.assert(unknownHeaderPut, 'Should have threw an exception for unknown header');

        Boolean unknownHeaderGet = false;
        try {
            row.get('Unknown Header Get');
        }
        catch (CFM_CSVRow.HeaderNotFoundException e) {
            unknownHeaderGet = true;
            System.assert(e.getMessage().contains('Unknown Header Get'), 'Should have included the unknown header in exception: ' + e.getMessage());
        }
        System.assert(unknownHeaderGet, 'Should have threw an exception for unknown header');
    }

    private static testMethod void testToStringPlain() {
        CFM_CSVRow.setupHeaders(mHeaders);
        CFM_CSVRow row = new CFM_CSVRow();
        row.put(COL_1, 'test');
        row.put(COL_2, 'test2');
        row.put(COL_3, 'test3');
        row.put(COL_4, 'test4');
        row.put(COL_5, 'test5');
        String result = row.toString();
        System.assertEquals(result, 'test,test2,test3,test4,test5');
    }

    private static testMethod void testToStringUnordered() {
        CFM_CSVRow.setupHeaders(mHeaders);
        CFM_CSVRow row = new CFM_CSVRow();
        row.put(COL_2, 'test2');
        row.put(COL_5, 'test5');
        row.put(COL_4, 'test4');
        row.put(COL_1, 'test');
        row.put(COL_3, 'test3');
        String result = row.toString();
        System.assertEquals(result, 'test,test2,test3,test4,test5', 'Should have preserved order of initial headers');
    }

    private static testMethod void testToStringWithCommas() {
        CFM_CSVRow.setupHeaders(mHeaders);
        CFM_CSVRow row = new CFM_CSVRow();
        row.put(COL_1, 'test');   //---test
        row.put(COL_2, 'test2,'); //---"test2,"
        row.put(COL_3, 'test3');  //---test3
        row.put(COL_4, 'test4');  //---test4
        row.put(COL_5, 'test5');  //---test5
        String result = row.toString();
        System.assertEquals(result, 'test,"test2,",test3,test4,test5', 'Should have surrounded a column containing a comma with double quotes');
    }

    private static testMethod void testToStringWithQuotes() {
        CFM_CSVRow.setupHeaders(mHeaders);
        CFM_CSVRow row = new CFM_CSVRow();
        row.put(COL_1, 'test');    //---test
        row.put(COL_2, '"test2"'); //---"""test2"""
        row.put(COL_3, 'test3');   //---test3
        row.put(COL_4, '"test4');  //---"""test4"
        row.put(COL_5, 'test5');   //---test5
        String result = row.toString();
        System.assertEquals(result, 'test,"""test2""",test3,"""test4",test5', 'Should have surrounded a column containing a double quote with double quotes, and changed each internal double quote to two double quotes');
    }

    private static testMethod void testToStringWithQuotesAndCommas() {
        CFM_CSVRow.setupHeaders(mHeaders);
        CFM_CSVRow row = new CFM_CSVRow();
        row.put(COL_1, ',test,');    //---",test,"
        row.put(COL_2, '"test2"');   //---"""test2"""
        row.put(COL_3, '"test3,",'); //---"""test3,"","
        row.put(COL_4, '"test4');    //---"""test4"
        row.put(COL_5, 'test5');     //---test5
        String result = row.toString();
        System.assertEquals(result, '",test,","""test2""","""test3,"",","""test4",test5', 'Should have surrounded a column containing a double quote with double quotes, and changed each internal double quote to two double quotes');
    }

}