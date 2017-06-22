public class CFM_QualtricsImportPanelResponse {
    public CFM_Meta Meta;
    public CFM_Result Result;

    public class CFM_Meta {
        public String Status;  
        public String Debug;   
    }

    public class CFM_Result {
        public String PanelID; 
        public Integer Count;  
        public Integer IgnoredCount;   
        public CFM_Recipients Recipients;
    }

    public class CFM_Recipients {
        public Integer CreatedContacts;
        public Integer UpdatedContacts;
        public List<CFM_FailedContacts> FailedContacts;
    }

    public class CFM_FailedContacts {

    }

    public String getPanelId() {
        return Result.PanelID;
    }

    public static CFM_QualtricsImportPanelResponse parse(String json){
        return (CFM_QualtricsImportPanelResponse) System.JSON.deserialize(json, CFM_QualtricsImportPanelResponse.class);
    }
}