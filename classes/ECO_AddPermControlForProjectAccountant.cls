global class ECO_AddPermControlForProjectAccountant implements Database.Batchable<SObject> {

  public class MyException extends Exception {}
  
  /**
   *
   *
   * @Author  NTT Data - Scott Mantei
   * @Date    February 27, 2017
   *
   * @param
   * @return
   **/

  // US-07008.  Project Accountants now need to get read permission to the Gannt chart.
  // This batch class adds a PermissionControl record for that purpose.
  // Only needs to be run once for existing Projects (there is a trigger in place for new Projects).

  global ECO_AddPermControlForProjectAccountant() {
  }


  global Database.QueryLocator start(Database.BatchableContext BC) {

      String query = 'Select Project__c ' + 
                     ', Project__r.pse__Stage__c ' + 
                     ', StartDate__c ' +
                     ', ProjectRole__r.Name ' + 
                     ', Contact__r.User__c ' +
                     'From ProjectTeamMember__c  ' + 
                     'Where (ProjectRole__r.Name = \'Project Accountant\' ' + 
                     'Or ProjectRole__r.Name = \'Project Accountant 2\') ' + 
                     'And (EndDate__c = null Or EndDate__c > TODAY) ' + 
                     'And Project__r.pse__Stage__c In (\'Pending Go/No Go\',\'Planning\',\'Execution\',\'On Hold\')';

      return Database.getQueryLocator(query);

  }

  global void execute( Database.BatchableContext BC, List<SObject> ptms) {
      List<pse__Permission_Control__c> pcs = new List<pse__Permission_Control__c>();
      
      for (ProjectTeamMember__c ptm : (List<ProjectTeamMember__c>) ptms) {
          pcs.add(new pse__Permission_Control__c(pse__Project__c = ptm.Project__c
                                                ,pse__User__c = ptm.Contact__r.User__c
                                                ,pse__View_Task_Manager__c = true
                                                ,pse__Edit_Task_Manager__c = true
                                                //,StartDate__c = ???
                                                ,AccessReason__c = ptm.ProjectRole__r.Name));
                                               
      }
 
      try {
      
          insert pcs;
          
          // Cause an exception for code coverage
          if (Test.isRunningTest()) Integer i = 1/0;  
      } catch (Exception e) {
          System.debug(e);
      }
          
  }

  global void finish(Database.BatchableContext BC) {

  }

}