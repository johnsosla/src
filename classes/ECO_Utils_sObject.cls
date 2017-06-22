public without sharing class ECO_Utils_sObject {

    private static Map<String, String> prefixObjectNameMap;

	// This method takes a string and returns an un-typed field value in the form of an object.  One must cast this back to the type they expect when using.
	public static Object objectFieldEval(String pathToField, SObject o){
		if(null == pathToField || null == o){
			return null;
		}
        // This splits up the fields.... so Account.Contact.name becomes Account, Contact, Name in an ordered list.
        List<String> hierarchy = pathToField.split('\\.');
        
        // This iterates up through the hiearchy and ends on the next to final level
        for(Integer i = 0;i<hierarchy.size()-1;i++){
            String s = hierarchy.get(i);
            o = o.getSObject(s); 
            if (o == null) break;
        }
        
        // This gets the field name attached to the sobject
        String fieldName = hierarchy[hierarchy.size()-1];
        
        // Finally, return the value as a primitive using dynamic DML
        if(o != null){
            return (Object)o.get(fieldName);
        } else {
            return null;
        }
    }

    public static String getSobjectName(Id sObjectId){
        
        String sObjectPrefix = ((String)sObjectId).subString(0, 3);

        if (prefixObjectNameMap == null) {
            prefixObjectNameMap = new Map<String, String>();

            Schema.sObjectType sot = sObjectId.getSobjectType();
            String sObjectName = sot.getDescribe().getName();

            prefixObjectNameMap.put(sObjectPrefix, sObjectName);
        } else if (!prefixObjectNameMap.keySet().contains(sObjectPrefix)) {
            Schema.sObjectType sot = sObjectId.getSobjectType();
            String sObjectName = sot.getDescribe().getName();

            prefixObjectNameMap.put(sObjectPrefix, sObjectName);
        }

        return prefixObjectNameMap.get(sObjectPrefix);
    }

    public static Set<String> getFieldSetMembers(String fieldSetName, String ObjectName)
    {
        Set<String> results = new Set<String>();
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();

        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);

        List<Schema.FieldSetMember> fieldSetMembers = fieldSetObj.getFields(); 

        for(Schema.FieldSetMember fieldSetMember : fieldSetMembers){                    
            results.add(fieldSetMember.getFieldPath());
        }

        return results;
    } 

     //FIND RECORD TYPE
    public static Id getRecordTypeId(SObjectType so, String recordTypeName) {
        
        Id result = null;

        Map<String,Map<String,Schema.RecordTypeInfo>> sObjectRecordTypes = new Map<String,Map<String,Schema.RecordTypeInfo>>();
        
        if (so != null && recordTypeName != null && recordTypeName != '') {
            Schema.DescribeSObjectResult r = so.getDescribe();
            if (r != null && !sObjectRecordTypes.containsKey(r.getName())) {
                sObjectRecordTypes.put(r.getName(), r.getRecordTypeInfosByName());
            }
                
            Map<String, Schema.RecordTypeInfo> recTypeInfos = sObjectRecordTypes.get(r.getName());
            Schema.RecordTypeInfo recTypeInfo = recTypeInfos.get(recordTypeName);
            //System.debug('recTypeInfo=' + recTypeInfo);
            if (recTypeInfo != null) {
                result = recTypeInfo.getRecordTypeId();
            }
        }

        return result;
    }

    public static String saveResultReturnErrors(SObject sObj){

        Database.SaveResult result = Database.update(sObj,false);
        String e = '';
        if (!result.isSuccess()) {
            Database.Error[] errs = result.getErrors();
        
            for(Database.Error err: errs){
                e += err.getMessage() + '<br/>';
            }
        }
        return e;
    }  
        
    public static String saveInsertReturnErrors(SObject sObj){

        Database.SaveResult resultInsert = Database.insert(sObj,false);
        
        String eInsert = '';
        
        if (!resultInsert.isSuccess()) {
            Database.Error[] errsInsert = resultInsert.getErrors();
            for(Database.Error errInsert: errsInsert){
                eInsert += errInsert.getMessage();
            }
        }
        return eInsert;
    }     
}