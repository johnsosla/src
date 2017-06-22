public with sharing class CFM_PageUtil {
    public static void addError(String msg) {
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
    }

    public static void addConfirm(String msg) {
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, msg));
    }

    public static void addInfo(String msg) {
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, msg));
    }

    public static String getParam(String pName) {
        return ApexPages.currentPage().getParameters().get(pName);
    }

    public static void putParam(String pName, String pValue) { 
        ApexPages.currentPage().getParameters().put(pName, pValue);
    }
}