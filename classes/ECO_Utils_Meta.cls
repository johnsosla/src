public without sharing class ECO_Utils_Meta {
  
  public class RecordTypeNotFoundException extends Exception {} 
  public class InvalidPicklistValueException extends Exception {}
  
  //Record types cache
  private static Map<Schema.SObjectType,Map<String,Id>> rtypesCache;
  private static List<sObject> results;
  static {
      rtypesCache = new Map<Schema.SObjectType,Map<String,Id>>();//convenient map, formatted from results.
      results = new List<sObject>();//contains all recordtypes retrieved via SOQL
  }

  private static final Map<String,Map<String,Schema.RecordTypeInfo>> sObjectRecordTypes = new Map<String,Map<String,Schema.RecordTypeInfo>>();
  
    public static Blob getHash(SObject obj) {
        Blob ret = Blob.valueOf(String.valueOf(obj));
        /* OAL 1.25.2017 : Changed from SHA512 to SHA1 to hopefully help with CPU limits on Budget Detail pages
        /* Ideally we benchmark SHA1 vs MD5 since it's slightly CPU dependent which one is faster but should be close enough to not worry about */
        /* For more details see http://automationrhapsody.com/md5-sha-1-sha-256-sha-512-speed-performance/ */
        /* and:                 http://stackoverflow.com/questions/2722943/is-calculating-an-md5-hash-less-cpu-intensive-than-sha-family-functions */
        /* https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_restful_crypto.htm */
        return Crypto.generateDigest('SHA1', ret);
    }

  public static Id getRecordTypeId(SObjectType so, String recordTypeName) {
    if (so != null 
      && recordTypeName != null 
      && recordTypeName != '') {

      //Check if we already queried all recordtypes.
          if (results == null || results.isEmpty()) {
          // Obtain ALL Active Record Types
          // (We will filter out the Record Types that are unavailable
          // to the Running User using Schema information)
              String soql = 'SELECT Id, Name, DeveloperName, sObjectType FROM RecordType WHERE IsActive = TRUE';
              try {
                  results = Database.query(soql);
              } catch (Exception ex) {
                  results = new List<SObject>();
              }
          }

          for(sObject rt : results){
            if(rt.get('DeveloperName') == recordTypeName && rt.get('sObjectType') == so.getDescribe().getName()){
              return rt.Id;
            }
          }

          //perform the lookup in the non-localization safe manner, some record types vary
          //example:Execution Approval vs. ExecutionApproval
          Schema.DescribeSObjectResult r = so.getDescribe();
        if (r != null && !sObjectRecordTypes.containsKey(r.getName())) {
          sObjectRecordTypes.put(r.getName(), r.getRecordTypeInfosByName());
        }

        Map<String, Schema.RecordTypeInfo> recTypeInfos = sObjectRecordTypes.get(r.getName());
        Schema.RecordTypeInfo recTypeInfo = recTypeInfos.get(recordTypeName);
        //System.debug('recTypeInfo=' + recTypeInfo);
        if (recTypeInfo != null) {
          return recTypeInfo.getRecordTypeId();
        }
    }

    throw new RecordTypeNotFoundException('RecordType \'' + recordTypeName + '\' was not found for SObjectType \'' + so + '\'.');
  }
  
  // runs before insert/update
  public static void setRecordTypeId (List<sObject> sObjectsToSet) {
    
    Schema.sObjectType sot = sObjectsToSet.getSObjectType();

    for (sObject so : sObjectsToSet) {
      Id recordTypeId = getRecordTypeId(sot, (String)so.get('RecordTypeName__c'));
      
      if (recordTypeId != null) {
        so.put('RecordTypeId', recordTypeId);
      }
    }
  }  
  
  // These will return a profile Id given a name and is coded to minimize number of Soql queries.
  private static Map<String, Id> profileNameToIdMap;
  private class ProfileNotFoundException extends Exception {}
  public static Id getProfileId (String profileName) {
    if (null == profileNameToIdMap) {
      profileNameToIdMap = new Map<String, Id>();
      
      for (Profile p : [SELECT Id
                  , Name 
              FROM Profile 
              LIMIT 10000]){
        profileNameToIdMap.put(p.Name, p.Id);
      }
    }
    
    Id profileId = profileNameToIdMap.get(profileName); 
    if(null == profileId){
      throw new ProfileNotFoundException('Profile \''+profileName+'\' not found.');
    } else {
      return profileId;
    }
  }
  
  public class SelectAll{
        public string allfields;
        public string SOQL;
        
        public Map<string, schema.sobjecttype> allSObjects {get; set;}
        
        public SelectAll(){
            allSObjects = schema.getglobaldescribe();
        }
        
        public string GetFields(string sfo){
            schema.sobjecttype q = allSObjects.get(sfo);
            schema.describesobjectresult d = q.getdescribe();
            map<string, schema.sobjectfield> m = d.fields.getmap();
            set<string> s = m.keyset();
            string query = '';
            for(string f : s){
                query = query+f+', ';
            }
            query = query.substring(0,query.length()-2);
            this.allfields = query;
            this.SOQL = 'SELECT ' + query + ' FROM ' + sfo;
            
            return this.allfields;
        }
    }
    
    public static list<SelectOption> getPicklistValues(SObject obj, String fld)
    {
    list<SelectOption> options = new list<SelectOption>();
    // Get the object type of the SObject.
    Schema.sObjectType objType = obj.getSObjectType(); 
    // Describe the SObject using its object type.
    Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
    // Get a map of fields for the SObject
    map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
    // Get the list of picklist values for this field.
    list<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
    // Add these values to the selectoption list.
    for (Schema.PicklistEntry a : values)
    { 
      options.add(new SelectOption(a.getValue(), a.getLabel())); 
    }
    return options;
   }

  // Returns a List of all RecordTypes
  // available to the running user for a given SOBject type
    public static Id defaultRecordTypeId;
  public static List<RecordType> GetAvailableRecordTypesForSObject(Schema.SObjectType objType) {
      List<Id> rtIds = new List<Id>();
      List<RecordTypeInfo> infos = objType.getDescribe().getRecordTypeInfos();

      // If there are 2 or more RecordTypes...
      if (infos.size() > 1) {
          for (RecordTypeInfo i : infos) {
             if (i.isAvailable() 
             // Ignore the Master Record Type
             // We check the Id because Name can change depending on the user's language.
              && !i.isMaster()) {
                  rtIds.add(i.getRecordTypeId());
              }
        if (i.DefaultRecordTypeMapping) {
            defaultRecordTypeId = i.getRecordTypeId();
        }

          }
      } 
      // Otherwise there's just the Master record type,
      // so add it in, since it MUST always be available
      else rtIds.add(infos[0].getRecordTypeId());
      return [Select Id, toLabel(Name), DeveloperName From RecordType 
            Where sObjectType = :string.valueOf(objType) And IsActive = true And Id in :rtIds 
            Order By Name];
                                
  }


}