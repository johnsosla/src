/* 
 * Name: ECO_ExceptionTest
 * Type: Apex Test Coverage  
 * Description: Test coverage for the ECO_BaseException, ECO_Utils_Date_Exception and ECO_DBExceptionNamespace Apex Controller.         
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti         06/23/2016       1. Initial Version created
 */
@isTest
private class ECO_ExceptionTest {

    static testMethod void ECO_Exception_UnitTest() {
        
        ECO_Utils_Date_Exception dateExp = new ECO_Utils_Date_Exception('TstClass.TstMethod','TstError','Testing Date Exception Message');
        
        String strMsg = dateExp.getCode();
        strMsg = dateExp.toString();
        
        ECO_DBExceptionNamespace.EmptyIDException emptyIDExp = new ECO_DBExceptionNamespace.EmptyIDException('TstClass.TstMethod','TstError','Testing Empty ID Exception Message');
        
        ECO_DBExceptionNamespace.NoDataException noDataExp = new ECO_DBExceptionNamespace.NoDataException('TstClass.TstMethod','TstError','Testing No Data Exception Message');
        
        ECO_DBExceptionNamespace.MoreDataException moreDataExp = new ECO_DBExceptionNamespace.MoreDataException('TstClass.TstMethod','TstError','Testing More Data Exception Message');
        
    }
}