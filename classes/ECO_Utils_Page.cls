public with sharing class ECO_Utils_Page {

    public static Id checkForUrlIdParam(String param){
		Id result = null;
        if(ApexPages.currentPage().getParameters().containsKey(param)){
            result = Id.valueOf(ApexPages.currentPage().getParameters().get(param));          
        }
        return result;
    }

    public static String checkForUrlParam(String param){
        String result = null;
        if(ApexPages.currentPage().getParameters().containsKey(param)){
            result = ApexPages.currentPage().getParameters().get(param);          
        }
        return result;
    }
}