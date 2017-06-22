/*  
 * This Class contains utility methods to create a SOQL query based on Fields in a FieldSet. 
 * @See  http://blogforce9.blogspot.in/2012/10/generate-query-from-fieldsets.html
 * (Generate Query From Fieldsets)
 *
 * @Author  Arman Shah - NTT Data
 * @Date 	November 2016
 **/
public class FieldSetSOQLUtil {  
   Map<String, Schema.SObjectType> globalDescribe;
   public Map<String, String> fieldLabelToFieldApiNameMap {get; set;}

   public FieldSetSOQLUtil() {  
     globalDescribe = Schema.getGlobalDescribe();
     fieldLabelToFieldApiNameMap = new Map<String, String>();
   }  

   /*  
   * This method generates query according to passed in object and fieldsets(plural) name  
   **/  
   public String generateQueryFromFieldSets(String sObjectName, Set<String> fieldSets, 
   		Set<String> additionalFields, String whereClause) {  

     Set<String> fields = new Set<String>{'Id'};  
     String query='SELECT Id';  //initial query  

     if (additionalFields!=null) {
	     for ( String fs : additionalFields ) {            
	       //add only unique fields  
	       if (!fields.contains(fs)) {  
	         //maintain a set of fields so that only unique fields are added in query  
	         fields.add(fs);  
	         query = query+','+fs;  
	       }      
	     }  
	   }

     //describe the provided sObject  
     Schema.DescribeSObjectResult res=globalDescribe.get(sObjectName).getDescribe(); 

     //get the fields set map  
     Map<String, Schema.FieldSet> fieldSetMap= res.fieldSets.getMap();  
     
     //iterate through provided fieldsets and generate query  
     for (String fieldSetName : fieldSets) {  
       Schema.FieldSet fs = fieldSetMap.get(fieldSetName);  
       for ( Schema.FieldSetMember fsm : fs.getFields() ) {            
         //add only unique fields  
         if (!fields.contains(fsm.getFieldPath())) {  
           //maintain a set of fields so that only unique fields are added in query  
           fields.add(fsm.getFieldPath());  
           query = query+','+fsm.getFieldPath();  

           // Keep a Map of field label to API name
           fieldLabelToFieldApiNameMap.put(fsm.getLabel(), fsm.getFieldPath());
         }      
       }  
     }  
     query = (whereClause == '' || whereClause == null)   
             ? (query + ' FROM '+sObjectName)   
             : (query + ' FROM '+sObjectName + ' WHERE ' + whereClause);  

     System.debug('___FieldSet query='+query);

     return query;  
   }  
 }