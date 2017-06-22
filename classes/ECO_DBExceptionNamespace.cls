/*
 * Author : Sujit Kumar
 * Custom exception class for handling database related problems in ECOSystem
 *
 */
public class ECO_DBExceptionNamespace {
    
    // ID is empty
    public class EmptyIDException extends ECO_BaseException
    {
        public EmptyIDException(String errorContext, String errorCode, String errorMessage) {
            super(errorContext, errorCode, errorMessage);
        }
    }
    
    // No data exist where we expect at least one row
    public class NoDataException extends ECO_BaseException
    {
        public NoDataException(String errorContext, String errorCode, String errorMessage) {
            super(errorContext, errorCode, errorMessage);
        }
    }
    
    // Multiple rows exist where we expect only single row
    public class MoreDataException extends ECO_BaseException
    {
        public MoreDataException(String errorContext, String errorCode, String errorMessage) {
            super(errorContext, errorCode, errorMessage);
        }
    }
    
}