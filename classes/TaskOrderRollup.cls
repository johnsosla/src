/*******************************************************************
  Name        :   TaskOrderRollup
  Author      :   Virendra (Appirio Off)
  Version     :   1.0 
  Purpose     :   Used as support Class for Trigger TaskOrderRollup to calculate Task Order Rollup fields
  Date        :   5-Aug-2010 
  Update      :   27-Oct-2015 Ram Kalagara. Added MS stages 1-2-Solution Development, 
              :   2-3-Pre-proposal, 2-4-Proposal, 3-5-Post-Submittal
              :   4/4/16 Nancy Balaban added stage 0
********************************************************************/
public class TaskOrderRollup {
  Public static List<string> recTypeProgram =null;
  Public static string recTypeTaskOrder ='';
  public static User currentuser = null;
  private static List<ValidState__c> lstStates = null;
  private static Map<string,RecordType> MapOpportunityRecordTypeByName=null;
  private static Map<Id,RecordType> MapOpportunityRecordTypeById=null;
  
  private static Map<Id,RecordType> MapAccountRecordTypeBId=null;
  public static Map<Id,RecordType> getAccountRecordtypeMapById()
  {
      if(MapAccountRecordTypeBId ==null)
      {
            MapAccountRecordTypeBId = new Map<Id,RecordType>();
            for(RecordType recType1:[select id,name,DeveloperName from RecordType where RecordType.SobjectType ='Account'])
            {
                MapAccountRecordTypeBId.put(recType1.id,recType1);
            }
      }
      return MapAccountRecordTypeBId;
  }
  
  public static Map<Id,RecordType> getOpportunityRecordtypeMapById()
  {
    getOpportunityRecordtypeMapByName();
    return MapOpportunityRecordTypeById;
  }
  public static Map<string,RecordType> getOpportunityRecordtypeMapByName()
  {
      if(MapOpportunityRecordTypeByName ==null)
      {
            MapOpportunityRecordTypeByName = new Map<string,RecordType>();
            MapOpportunityRecordTypeById = new Map<Id,RecordType>();
            for(RecordType recType1:[select id,name,DeveloperName from RecordType where RecordType.SobjectType ='Opportunity'])
            {
                MapOpportunityRecordTypeByName.put(recType1.DeveloperName.toLowerCase(),recType1);
                MapOpportunityRecordTypeByName.put(recType1.Name.toLowerCase(),recType1);
                MapOpportunityRecordTypeById.put(recType1.Id,recType1);
            }
      }
      return MapOpportunityRecordTypeByName;
  }
  
  public static List<string> getProgramrecordtype()
  {
      if(recTypeProgram ==null)
      {
            recTypeProgram = new list<string>();
            for(RecordType recType1:[select id,name from RecordType where Name Like 'Program%' and RecordType.SobjectType ='Opportunity'])
            {
                recTypeProgram.add(recType1.Id);
            }
      }
      return recTypeProgram;
  }
  public static User getCurrentUser()
  {
      if(currentuser ==null)
          currentuser=[Select id,Profile.name from User where id=:UserInfo.getUserId()];
      return currentuser ;
  }
  public static List<ValidState__c> getStateList()
  {
      if(lstStates ==null)
      {
            if(LIMITS.getLimitQueryRows() ==500)
                lstStates =[Select Name,Country__c from ValidState__c LIMIT 2];
            else
                lstStates =[Select Name,Country__c from ValidState__c LIMIT 700];
      }
      return lstStates ;
  }
  
  public static void calculateTaskOrderRollupTasks(Set<Id> parentOppList,List<id>childOpp)
  {
    List<String> recType = getProgramrecordtype();
    Double ordersOpenRevenue=0.0;
    Set<String> stageSet1= new Set<String>();
    stageSet1.add('0 Unqualified');
    stageSet1.add('0-0-Planning');
    stageSet1.add('0-1-Qualification');
    stageSet1.add('1 Lead');    
    stageSet1.add('1A Lead - Scout');   
    stageSet1.add('1B Lead - Engage');  
    stageSet1.add('1C Lead - Position');    
    stageSet1.add('2 Capture'); 
    stageSet1.add('2A Capture - LOI');  
    stageSet1.add('2B Capture - EOI');  
    stageSet1.add('2C Capture - SOQ');  
    stageSet1.add('2D Capture - RFI');  
    stageSet1.add('2E Capture - RFP'); 
    //Added new line by sumit for PR:07090 
    stageSet1.add('3 Submitted');   
    //Comment out old stage name and add new Issue I-1007
    stageSet1.add('3A Submitted - Proposal Submitted');
    stageSet1.add('3B Submitted - Shortlist');
    stageSet1.add('3C Submitted - Interview');
  //stageSet1.add('3A Capture - Proposal Submitted');   
    //stageSet1.add('3B Capture - Short List');   
    //stageSet1.add('3C Capture - Interview');    
    stageSet1.add('4 Project on hold'); 
    stageSet1.add('5 SNB/Win/Award');
    stageSet1.add('1-2-Solution Development');
    stageSet1.add('2-3-Pre-proposal');
    stageSet1.add('2-4-Proposal');
    stageSet1.add('3-5-Post-Submittal');
      
    Double ordersBookedRevenue=0.0;
    //Commented Next Line and add next to next
    //String stage6 = '6 Contracted/Booked/Really Won';
    String stage6 = '6 Contracted/Booked/Won';
    Double ordersLostRevenue;
    String stage9 = '9 Lost';
     
    Map<id,Opportunity> ParentOppMap=new Map<id,Opportunity>([select Id,Task_Orders_Open_Revenue__c,Task_Order_Count__c, 
                                          Task_Orders_Booked_Revenue__c,Task_Orders_Lost_Revenue__c,Amount
                                          from Opportunity
                                          where id in :parentOppList and RecordTypeId in :recType]);
    for(opportunity parentOpp:ParentOppMap.values())
    {
       parentOpp.Task_Orders_Open_Revenue__c  =0;
       parentOpp.Task_Orders_Booked_Revenue__c =0;
       parentOpp.Task_Orders_Lost_Revenue__c =0;
       parentOpp.Task_Order_Count__c = 0;
    }
    for(Opportunity opp:[Select id,Master_Contract_lookup__c,StageName,Ceiling_Amount_Total__c ,Amount,Task_Order_Count__c from opportunity where Master_Contract_lookup__c in :parentOppList and id Not In:childOpp])
    {
          Opportunity parentOpp = ParentOppMap.get(opp.Master_Contract_lookup__c);
          if(opp.Amount != null && parentOpp!=null)
          {
              if(parentOpp.Task_Orders_Lost_Revenue__c==null)parentOpp.Task_Orders_Lost_Revenue__c=0;
              if(parentOpp.Task_Orders_Booked_Revenue__c==null)parentOpp.Task_Orders_Booked_Revenue__c=0;
              if(parentOpp.Task_Orders_Lost_Revenue__c==null)parentOpp.Task_Orders_Lost_Revenue__c=0;
              
              if(stageSet1.contains(opp.StageName))
                  //parentOpp.Task_Orders_Open_Revenue__c +=opp.Ceiling_Amount_Total__c;
                  parentOpp.Task_Orders_Open_Revenue__c +=opp.Amount;
              if(opp.StageName == stage6)
                 // parentOpp.Task_Orders_Booked_Revenue__c +=opp.Ceiling_Amount_Total__c;
                  parentOpp.Task_Orders_Booked_Revenue__c +=opp.Amount;
              if(opp.StageName == stage9)
                  //parentOpp.Task_Orders_Lost_Revenue__c +=opp.Ceiling_Amount_Total__c;
                  parentOpp.Task_Orders_Lost_Revenue__c +=opp.Amount;
              parentOpp.Task_Order_Count__c += 1;
          }
    }
    update ParentOppMap.values();
  }
}