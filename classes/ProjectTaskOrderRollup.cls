/* ******************************************************************
  Name        :   ProjectTaskOrderRollup
  Author      :   copied from code written by Virendra (Appirio Off)
  Version     :   1.0 
  Purpose     :   Used as support Class for Trigger ProjectTaskOrderRollup to calculate Task Order Rollup fields
  Date        :   July 23, 2012
  *******************************************************************  */
  public class ProjectTaskOrderRollup {
  Public static List<string> recTypeProgram =null;
  Public static string recTypeTaskOrder ='';
  public static User currentuser = null;
  //private static List<ValidState__c> lstStates = null;
  private static Map<string,RecordType> MapProjectRecordTypeByName=null;
  private static Map<Id,RecordType> MapProjectRecordTypeById=null;
   public static List<string> getProgramrecordtype()
  {
  /*  Test for record type Program or Project and end classs    */
      if(recTypeProgram ==null)
      {
            recTypeProgram = new list<string>();
            for(RecordType recType1:[select id,name from RecordType where Name Like 'Program%' and RecordType.SobjectType ='Project__c'])
            {
                recTypeProgram.add(recType1.Id);
            }
      }
      return recTypeProgram;
  }
public static void calculateTaskOrderRollupTasks (set<Id> parentProjectIds,List<id>childOpp) {
    List<String> recType = getProgramrecordtype();
    List<Project__c> parentProjects = [select Id
                                        , Sum_of_Task_Order_Fees__c
                                        , Sum_of_Task_Order_Subcontracted_Cost__c
                                        , (Select id
                                            , SearchFee__c
                                            , subcontracted_amount__c 
                                            FROM TaskOrder__r WHERE id Not In:childOpp)
                                        from Project__c
                                        where id in :parentProjectIds 
                                        and RecordTypeId in :recType];
                                        
    for (Project__c parentProj: parentProjects) {
       //parentProj.Owners_Total_Cost__c  = 0;
       parentProj.Sum_of_Task_Order_Subcontracted_Cost__c = 0;
       parentProj.Sum_of_Task_Order_Fees__c = 0;
       
       for (Project__c projTaskOrder : parentProj.TaskOrder__r) {
            parentProj.Sum_of_Task_Order_Fees__c += (projTaskOrder.SearchFee__c != null) ? projTaskOrder.SearchFee__c : 0;          
            parentProj.Sum_of_Task_Order_Subcontracted_Cost__c += (projTaskOrder.Subcontracted_amount__c != null) ? projTaskOrder.Subcontracted_amount__c : 0;
            
       }
    }   
    
    update parentProjects;                                 
    
}
}