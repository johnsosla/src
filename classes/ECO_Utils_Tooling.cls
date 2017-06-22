public with sharing class ECO_Utils_Tooling {
	public ECO_Utils_Tooling() {
		
	}

	public static map<string, string> getFieldIDMap(string objName){
       /* // Constructs the Tooling API wrapper (default constructor uses user session Id)
        ToolingAPI toolingAPI = new ToolingAPI();
         
        // Query CustomObject object by DeveloperName (note no __c suffix required)
        List<ToolingAPI.CustomObject> customObjects = (List<ToolingAPI.CustomObject>)
             toolingAPI.query('Select Id, DeveloperName, NamespacePrefix From CustomObject Where DeveloperName = \'' + objName + '\'').records;
         
        // Query CustomField object by TableEnumOrId (use CustomObject Id not name for Custom Objects)
        ToolingAPI.CustomObject customObject = customObjects[0];
        Id customObjectId = customObject.Id;
        List<ToolingAPI.CustomField> customFields = (List<ToolingAPI.CustomField>)
             toolingAPI.query('Select Id, DeveloperName, NamespacePrefix, TableEnumOrId From CustomField Where TableEnumOrId = \'' + customObjectId + '\'').records;
         
        // Dump field names (reapply the __c suffix) and their Id's
        System.debug(customObject.DeveloperName + '__c : ' + customObject.Id);

        map<string, string> mNameToID = new map<string, string>();

        for(ToolingAPI.CustomField customField : customFields){
             System.debug(
                  customObject.DeveloperName + '__c.' +
                  customField.DeveloperName + '__c : ' +
                  customField.Id);

             mNameToID.put(customField.DeveloperName + '__c', customField.Id);
         }		

         return mNameToID;*/

         return null;
	}
}