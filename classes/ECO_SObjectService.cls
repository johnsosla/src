public with sharing class ECO_SObjectService {

	public static String saveResultReturnErrors(SObject sObj){

    	Database.SaveResult result = Database.update(sObj,false);
        String e = '';
        if (!result.isSuccess()) {
        	Database.Error[] errs = result.getErrors();
            for(Database.Error err: errs){
            	e += err.getMessage();
            }
		}
        return e;
	}  
        
    public static String saveInsertReturnErrors(SObject sObj){

    	Database.SaveResult resultInsert = Database.insert(sObj,false);
        //System.Debug('Brent Result Inserts', resultInsert);
        String eInsert = '';
        if (!resultInsert.isSuccess()) {
        	Database.Error[] errsInsert = resultInsert.getErrors();
            for(Database.Error errInsert: errsInsert){
            	eInsert += errInsert.getMessage();
            }
        }
        //System.Debug('Brent Result Inserts' + eInsert);
       	return eInsert;
	}         
}