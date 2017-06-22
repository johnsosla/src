global class ECO_PiwWrapper implements Comparable {
    // @Author: Scott Mantei
    // @Created: Sep 21, 2016
    // This is a wrapper class used by ECO_ItemsToApproveController which basically mimics the
    // Items to Approve list on the Home Page, but without the Reassign Links and the
    // Manage All button.

    public ProcessInstanceWorkitem piw {get; set;}
    public Id targetId {get; set;}
    public String keyPrefix {get; set;}
    public String objectLabel {get; set;}
    public String objectAPI {get; set;}
    public String targetName {get; set;}

    public ECO_PiwWrapper(ProcessInstanceWorkitem p) {
        piw = p;
    }

    
    // Sort by CreatedDate, descending
    global Integer compareTo(Object compareTo) {

        ECO_PiwWrapper compareToPIW = (ECO_PiwWrapper)compareTo;
        
        Integer returnValue = 0;
        if (piw.CreatedDate < compareToPIW.piw.CreatedDate) {
            returnValue = 1;
        } else if (piw.CreatedDate > compareToPIW.piw.CreatedDate) {
            returnValue = -1;
        }
        
        return returnValue;       
    }    
}