/**
* @author Nathan Pilkington
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_ReflectionUtil
*              PURPOSE: Utility class for reflection logic
*              CREATED: 06/2016 Ethos Solutions - www.ethos.com
**/
public class SGT_ReflectionUtil {

	// Returns the display type of a field
	// Input: Name of the field, in ObjectName.FieldName format
	// Output: Display type of the supplied field
	public static Schema.DisplayType getDisplayType(String objectFieldName) {
        List<String> parts = objectFieldName.split('\\.');
        return getDisplayType(parts[0], parts[1]);
    }
	
	// Returns the display type of a field
	// Input: Object and field API name of the field
	// Output: Display type of the supplied field
    private static Map<String, Schema.DisplayType> typeCache = new Map<String, Schema.DisplayType>();

	public static Schema.DisplayType getDisplayType(String objectName, String fieldName) {
        String objectFieldName = objectName + '.' + fieldName;
        if (typeCache.containsKey(objectFieldName)) {
            return typeCache.get(objectFieldName);
        }

        SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> objectFields = objToken.getDescribe().fields.getMap();
        Schema.DisplayType dispType = null;

        if (fieldName.contains('.')) {
            List<String> objectParts = fieldName.split('[.]');
            String nextFieldName = objectParts.remove(0);

            if (nextFieldName.contains('__r')) nextFieldName = nextFieldName.replace('__r', '__c');
            else nextFieldName = nextFieldName + 'Id'; // Standard Lookup fields end with 'ID' in the API name

            SObjectType referenceTo = objectFields.get(nextFieldName).getDescribe().getReferenceTo()[0];
            String lookupObjName = referenceTo.getDescribe().getName();

            dispType = getDisplayType(lookupObjName, String.join(objectParts, '.'));
            typeCache.put(objectFieldName, dispType);
            return dispType;
        }

        dispType = objectFields.get(fieldName).getDescribe().getType();
        typeCache.put(objectFieldName, dispType);
        
        return dispType;
    }

    // Returns the label of a field
    // Input: Object and field API name of the field
    // Output: Label of the supplied field
    public static String getLabel(String objectName, String fieldName) {
        SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> objectFields = objToken.getDescribe().fields.getMap();

        if (fieldName.contains('.')) {
            List<String> objectParts = fieldName.split('[.]');
            String nextFieldName = objectParts.remove(0);

            if (nextFieldName.contains('__r')) nextFieldName = nextFieldName.replace('__r', '__c');
            else nextFieldName = nextFieldName + 'Id'; // Standard Lookup fields end with 'ID' in the API name

            SObjectType referenceTo = objectFields.get(nextFieldName).getDescribe().getReferenceTo()[0];
            String lookupObjName = referenceTo.getDescribe().getName();

            return getLabel(lookupObjName, String.join(objectParts, '.'));
        }

        return objectFields.containsKey(fieldName) ? objectFields.get(fieldName).getDescribe().getLabel() : '';
    }

    // Returns the picklist options for a field
	// Input: Name of the field, in ObjectName.FieldName format
	// Output: Picklist values for the supplied field
    public static List<String> getPicklistOptions(String objectFieldName) {
    	List<String> parts = objectFieldName.split('\\.');
        return getPicklistOptions(parts[0], parts[1]);
    }

    // Returns the picklist options for a field
	// Input: Object name and field API name for the field
	// Output: Picklist values for the supplied field
    public static List<String> getPicklistOptions(String objectName, String fieldName) {
        Schema.DisplayType dispType = null;

        SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> objectFields = objToken.getDescribe().fields.getMap();
        Schema.DescribeFieldResult fieldDescribe = objectFields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldDescribe.getPicklistValues();

        List<String> options = new List<String>();

        for (Schema.PicklistEntry f : ple){
        	options.add(f.getValue());
        }

        return options;
    }

    public static Boolean isFieldNumeric(Schema.DisplayType displayType) {
        return displayType == Schema.DisplayType.Currency || displayType == Schema.DisplayType.Double 
                || displayType == Schema.DisplayType.Integer || displayType == SChema.DisplayType.Percent;
    }

    public static Boolean isFieldDate(Schema.DisplayType displayType) {
        return displayType == Schema.DisplayType.Date || displayType == Schema.DisplayType.DateTime;
    }

    public static Boolean isFieldBoolean(Schema.DisplayType displayType) {
        return displayType == Schema.DisplayType.Boolean;
    }
}