/*
 * Custom exception classes for handling pse_Fiscal_Period__crelated problems in ECOSystem
 *
 */

 public class ECO_Utils_Date_Exception extends ECO_BaseException {
	public ECO_Utils_Date_Exception(String errorContext, String errorCode, String errorMessage) {
		super(errorContext, errorCode, errorMessage);
	}
}