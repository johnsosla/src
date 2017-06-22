/** ------------------------------------------------------------------------------------------------------
* @Description Facilitates locking of defined SObjects when a project is flagged as locked
*
* @Author      NTT Data - Tim Chiang
* @Date        2016
*-----------------------------------------------------------------------------------------------------*/

public with sharing class ECO_ServiceProjectLock {

	public static Boolean run = true;
	public static boolean ignoreProjectLock = false;
	public static string exclusionList = 'LockExclusionList';

    /**
     * Constructor
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
     **/
	public ECO_ServiceProjectLock() {
	}

    /**
     * Checks if a field exists on an sObject
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
	 * @param    fieldName - api name of field to search for
	 * @param    so - Sboject to search on
	 * @return   boolean     
     **/
    public static boolean hasSObjectField(String fieldName, SObject so){
        return so.getSobjectType().getDescribe().fields.getMap().keySet().contains(fieldName.tolowercase());
    }

    /**
     * Checks SObject against an exclusion fieldset in order to determine if its still a candidate for locking
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
	 * @param    lstCheckObjects - list of Sobjects to check
	 * @param    oldMap - oldmap associated with list of objects
	 * @param    objectApiName - api name of the objects
	 * @return   list<SObject>  
     **/
	public static list<SObject> checkFieldExceptions(list<SObject> lstCheckObjects, map<id, SObject> oldMap, string objectApiName){
	
        if (!run || !ECO_TriggerSettings.getIsTriggerEnabled('ECO_SPL_checkFieldExceptions')) {
            return lstCheckObjects;
        }


        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectApiName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
		Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(ExclusionList);

        list<sobject> lstOfCheckableObjects = new list<sobject>();

        if(oldMap != null && fieldSetObj !=null){
	        for(sobject s:lstCheckObjects){

	            boolean foundChange = false;

	            for(Schema.FieldSetMember fieldSetMemberObj : fieldSetObj.getFields()){	

	                if(s.get(fieldSetMemberObj.getFieldPath()) != oldmap.get((id)s.get('id')).get(fieldSetMemberObj.getFieldPath())){
	                    system.debug('Change Found');
	                    foundChange = true;
	                }
	            }

	            if(!foundChange){
	                lstOfCheckableObjects.add(s);
	            }
	        }
    	} else {
    		lstOfCheckableObjects = lstCheckObjects;
    	}

    	return lstOfCheckableObjects;		
	}

    /**
     * Checks if the projects of the submitted SObjects are locked
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
	 * @param    lstCheckObjects - list of Sobjects to check
	 * @param    oldMap - oldmap associated with list of objects
	 * @return     
     **/
	public static void checkProjectLock(list<SObject> lstCheckObjects, map<id, SObject> oldMap){

		List<ECO_SecurityObjectAccessUserExclusions__c> listSoaue = ECO_SecurityObjectAccessUserExclusions__c.getall().values();

		boolean foundUser = false;

		for(ECO_SecurityObjectAccessUserExclusions__c Soaue: listSoaue){
			if(Soaue.User_Name__c == UserInfo.getUserName()){
				foundUser = true;
				break;
			}
		}

        if (!run 
        	|| !ECO_TriggerSettings.getIsTriggerEnabled('ECO_SPL_checkProjectLock')
        	|| lstCheckObjects.size() == 0
        	|| ignoreProjectLock
        	|| foundUser
        	) {
        	system.debug('Validation rule NOT hit due to user exclusion');
        	ignoreProjectLock = true;
            return;
        }

        

		string objectApiName = lstCheckObjects[0].getSObjectType().getDescribe().getName();

		list<sobject> lstOfCheckableObjects = checkFieldExceptions(lstCheckObjects, oldMap, objectApiName);

		if(lstOfCheckableObjects != null && lstOfCheckableObjects.size() > 0){

			set<id> projectIds = new set<id>();
			list<pse__Proj__c> lstProjects;

			boolean isLockFound = false;

			for(SObject checkObject: lstOfCheckableObjects){

				boolean isLocked = false;

				if(hasSObjectField('Eco_Locked__c', checkObject)){
					isLocked = (boolean)checkObject.get('Eco_Locked__c');
				}
				
				id sObjectId = (id)checkObject.get('id');

				if(isLocked){
					isLockFound = true;
					checkObject.addError('Cannot save ' + objectApiName + ' : the parent project has been locked due to submission for execution.');
					system.debug('Validation rule hit');
				}
			}

			if(!isLockFound){
				ignoreProjectLock = true;
			}


		} else {
			return;
		}

	}


}