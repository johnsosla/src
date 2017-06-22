/*******************************************************************
  Name        :   GNG_ANZ_WhyGo_Update_Opp
  Requester   :   ANZ Requirements GAP 
  Author      :   AECOM - Luke Farbotko
  Version     :   1.0 
  Purpose     :   Trigger to update oppertunity from anz why go GNG
  Date        :   31 Oct, 2014 
********************************************************************/
trigger GNG_ANZ_WhyGo_Update_Opp on Go_No_Go_Conversation__c (after update) {
     
     /*
     //ON update only, 
     
     map<Id, Schema.RecordTypeInfo> rt_map = Schema.getGlobalDescribe().get('Go_No_Go_Conversation__c').getDescribe().getRecordTypeInfosById();
     
     Map<ID, Opportunity> opps = new Map<ID, Opportunity>(); //Making it a map instead of list for easier lookup
     List<Id> listIds = new List<Id>();


     //if GNG is of type 'ANZ why go' add it to the list
     for (Go_No_Go_Conversation__c gng: Trigger.new) {
          
          try{
	          if(rt_map.get(gng.recordTypeID).getName().containsIgnoreCase('ANZ Why Go')){
	                 listIds.add(gng.Opportunity__c);
	          }
     	  }
     	  catch(Exception ex){
     	  	// this try catch is to solve issue with missing record type on older gngs
     	  }
         
      }
    
      //Populate the map with ANZ GNGs.
      opps = new Map<Id, Opportunity>([SELECT id,Go_Probability__c,Probability 
                                  FROM Opportunity WHERE ID IN :listIds]);

     for (Go_No_Go_Conversation__c gng: Trigger.new) {
     	
     	try{
     		
	     	Opportunity myParentOpp = opps.get(gng.Opportunity__c);
            if (myParentOpp != null)
            {          
            	if (gng.Market_Position_Q11__c != null && gng.Market_Position_Q11__c != 0)       
                	myParentOpp.Go_Probability__c = gng.Market_Position_Q11__c ;
                if (gng.Market_Position_Q12__c != null && gng.Market_Position_Q12__c != 0)    
                	myParentOpp.Probability_Stage__c = gng.Market_Position_Q12__c ;
                
                
                //myParentOpp.Amount = 1000;
                if (gng.Total_Fee__c != null && gng.Total_Fee__c != 0)    
                	myParentOpp.Amount = gng.Total_Fee__c ;
               
                if (gng.Total_Bid_Cost__c != null && gng.Total_Bid_Cost__c != 0)    
                	myParentOpp.B_P_Budget__c = gng.Total_Bid_Cost__c ;
               
                Decimal  subFee = 0;
                Decimal  expenseFee = 0;
                
                if (gng.Subs_Fee__c != null)    
                	subFee = gng.Subs_Fee__c ;
                if (gng.Expenses_Fee__c != null)    
                	expenseFee = gng.Expenses_Fee__c ;
                if (gng.Capital_Value__c != null)    
                	myParentOpp.Construction_cost__c = gng.Capital_Value__c ;
                
                if (subFee + expenseFee > 0 )
                	myParentOpp.Subs_Other_Revenue__c = subFee + expenseFee;
                
            }             
     	}
     	catch(Exception ex){}
     }

     update opps.values();
     */

}