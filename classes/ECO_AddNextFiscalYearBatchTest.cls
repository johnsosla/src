@isTest
public class ECO_AddNextFiscalYearBatchTest {

    static testMethod void test(){

        ECO_ProjectTriggers.run = false;
        pse__Proj__c p = new ECO_Utils_Testing.ProjectBuilder().withOpportunity().build(true);
    
        insert new WeeklyRollupEntry__c (PeriodStartDate__c = date.newInstance(2018, 1, 1)
                                         , Project__c = p.Id
                                         , CompositeKey__c = 'test');

        Test.startTest();
        Database.executeBatch(new ECO_AddNextFiscalYearBatch()); 
        Test.stopTest();
      
        system.assert([Select Id From pse__Time_Period__c].size() > 0);
    }
    
    static testMethod void testSchedule(){
        
        String jobId = System.schedule('ScheduleApexClassTest',
                        '0 0 0 15 3 ? 2022', 
                        new ECO_AddNextFiscalYearBatch());           
    }    
}