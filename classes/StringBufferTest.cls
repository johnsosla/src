/* 
 * Name: StringBufferTest
 * Type: Apex Test Coverage  
 * Description: Test coverage for the StringBuffer Apex class.         
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti         06/23/2016       1. Initial Version created
 */
@IsTest
private class StringBufferTest {
    
    private static testmethod void testDecimal(){
        Decimal value = 3.14159;
        System.assertEquals((new StringBuffer(value)).append(value).toStr(), ''+value+''+value);
        System.assertEquals((new StringBuffer(value)).append(value).append(value).toStr(), ''+value+''+value+''+value);
    }

    private static testmethod void testDouble(){
        Double value = 3.14159;
        System.assertEquals((new StringBuffer(value)).append(value).toStr(), ''+value+''+value);
        System.assertEquals((new StringBuffer(value)).append(value).append(value).toStr(), ''+value+''+value+''+value);
    }

    private static testmethod void testInteger(){
        Integer value = 792392;
        System.assertEquals((new StringBuffer(value)).append(value).toStr(), ''+value+''+value);
        System.assertEquals((new StringBuffer(value)).append(value).append(value).toStr(), ''+value+''+value+''+value);
    }

    private static testmethod void testLong(){
        Long value = 792392;
        System.assertEquals((new StringBuffer(value)).append(value).toStr(), ''+value+''+value);
        System.assertEquals((new StringBuffer(value)).append(value).append(value).toStr(), ''+value+''+value+''+value);
    }

    private static testmethod void testID(){
        Account foo = new Account(name='test');
        insert foo;
        Id value = foo.id;
        System.assertEquals((new StringBuffer(value)).append(value).toStr(), ''+value+''+value);
        System.assertEquals((new StringBuffer(value)).append(value).append(value).toStr(), ''+value+''+value+''+value);
    }

    private static testmethod void testBoolean(){
        Boolean value = true;
        System.assertEquals((new StringBuffer(value)).append(value).toStr(), ''+value+''+value);
        System.assertEquals((new StringBuffer(value)).append(value).append(!value).toStr(), ''+value+''+value+''+(!value));
    }

    private static testmethod void testString(){
        String value = 'rwkrfkdekf';
        System.assertEquals((new StringBuffer()).append(value).toStr(), ''+value);
        System.assertEquals((new StringBuffer()).append(value).append(value).toStr(), ''+value+''+value);
        System.assertEquals((new StringBuffer(value)).append(value).toStr(), ''+value+''+value);
        System.assertEquals((new StringBuffer(value)).append(value).append(value).toStr(), ''+value+''+value+''+value);
    }
 
    private static testmethod void testDate(){
        Date value = date.newinstance(1960, 2, 17);
        System.assertEquals((new StringBuffer(value)).append(value).toStr(), ''+value+''+value);
        System.assertEquals((new StringBuffer(value)).append(value).append(value).toStr(), ''+value+''+value+''+value);
    }

    private static testmethod void testDatetime(){
        Datetime value = datetime.newInstance(2008, 12, 1);
        System.assertEquals((new StringBuffer(value)).append(value).toStr(), ''+value+''+value);
        System.assertEquals((new StringBuffer(value)).append(value).append(value).toStr(), ''+value+''+value+''+value);
    }

    private static testmethod void testTime(){
        Time value = Time.newInstance(18, 30, 2, 20);
        System.assertEquals((new StringBuffer(value)).append(value).toStr(), ''+value+''+value);
        System.assertEquals((new StringBuffer(value)).append(value).append(value).toStr(), ''+value+''+value+''+value);
    }

    private static testmethod void testBlob(){
        Blob value = Blob.valueOf('test123');
        System.assertEquals((new StringBuffer(value)).append(value).toStr(), ''+value+''+value);
        System.assertEquals((new StringBuffer(value)).append(value).append(value).toStr(), ''+value+''+value+''+value);
    }
}