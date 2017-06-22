public without sharing class rsDataUtils {

    public static list<SelectOption> getPicklistValues(SObject obj, String fld){
      list<SelectOption> options = new list<SelectOption>();
      // Get the object type of the SObject.
      Schema.sObjectType objType = obj.getSObjectType();
      // Describe the SObject using its object type.
      Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
      // Get a map of fields for the SObject
      map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
      // Get the list of picklist values for this field.
      list<Schema.PicklistEntry> values =
         fieldMap.get(fld).getDescribe().getPickListValues();
      // Add these values to the selectoption list.
      for (Schema.PicklistEntry a : values)
      {
         options.add(new SelectOption(a.getLabel(), a.getValue()));
      }
      return options;
    }

    public static void save(SObject mObj) {
        upsert mObj;
    }

    public static void save(List<sObject> objs) {
        List<sObject> updateList = new List<sObject>();
        List<sObject> insertList = new List<sObject>();
        for (sObject obj : objs) {
            if(obj.Id != null) {
                updateList.add(obj);
            } else {
                insertList.add(obj);
            }
        }
        if(!insertList.isEmpty()) {
            insert insertList;
        }
        if(!updateList.isEmpty()) {
            update updateList;
        }
    }

}