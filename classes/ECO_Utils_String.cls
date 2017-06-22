public without sharing class ECO_Utils_String {
	public static decimal NullCheck(decimal iValue){
		if(iValue == null)
			return 0;
			
		return iValue;
    }
    
	public static string NullCheck(string sValue){
		if(sValue == null)
			return '';
		return sValue;
	}
}