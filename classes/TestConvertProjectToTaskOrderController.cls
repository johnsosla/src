/*************************************************************************
//Name                : TestConvertProjectToTaskOrderController
//Author              : Aslam Bari
//Description         : For coverage ConvertProjectToTaskOrderController
//Date                : Aug 17, 2010
*************************************************************************/
@istest private  class TestConvertProjectToTaskOrderController{
@isTest private static void testController(){

    //Primary Department
    AECOM_Primary_Department__c primaryDept;
    List<AECOM_Primary_Department__c> departments;

    departments = [SELECT Lead_Region__c FROM AECOM_Primary_Department__c WHERE Name = 'test Lead Region' LIMIT 1];
    if(departments.size() == 0){
        primaryDept = new AECOM_Primary_Department__c(Lead_Region__c = 'test Lead Region');
        insert primaryDept;
    }
    else{
        primaryDept = departments[0];
    }


    Map<String,ID> recordTypesMap = new Map<String,ID>();
    for(RecordType r:[select id,Name from RecordType where sObjectType='Opportunity' and isActive=true]){
        recordTypesMap.put(r.Name,r.Id);
        system.debug('###' + r.Name);
    }
    Opportunity newOpp = new Opportunity(Legacy_OpportunityID__c='101');
    newOpp.RecordTypeId = recordTypesMap.get('Program - APAC');
    newOpp.Name = 'test';
    newOpp.StageName = '1 Lead';
    newOpp.CloseDate = System.today().addDays(30);

    newOpp.Estimated_work_start_date__c = Date.today().addDays(90);
    newOpp.TO_Procurement_Method__c = 'Competitive Task Orders';
    newOpp.Enterprise_Service__c = 'Engineering';
    newOpp.AECOM_Primary_Dept_Lookup__c = primaryDept.Id;


    insert newOpp;
    
    Opportunity newOpp2 = new Opportunity(Legacy_OpportunityID__c='102');
    newOpp2.RecordTypeId = recordTypesMap.get('Task Order - APAC');
    newOpp2.Name = 'test';
    newOpp2.StageName = '1 Lead';
    newOpp2.CloseDate = System.today().addDays(30);

    newOpp2.Estimated_work_start_date__c = Date.today().addDays(90);
    newOpp2.TO_Procurement_Method__c = 'Competitive Task Orders';
    newOpp2.Enterprise_Service__c = 'Engineering';
    newOpp2.AECOM_Primary_Dept_Lookup__c = primaryDept.Id;
    newOpp2.ProjectCountry__c = 'Australia';

    insert newOpp2;
    
    ApexPages.StandardController sc = new ApexPages.StandardController(newOpp);
    ConvertProjectToTaskOrderController pToTController = new ConvertProjectToTaskOrderController(sc);
    pToTController.newTask.Master_Contract_lookup__c = newOpp2.Id;
    pToTController.searchOpportunities();
    pToTController.opportunityName = 'test';
    pToTController.searchOpportunities();
    pToTController.opportunityName = '&&&&';
    pToTController.searchOpportunities();
    pToTController.createNewTaskOrder();
    pToTController.getShowMoreThen100();
    pToTController.cancel();
    
    pToTController.opportunityName = null;
    pToTController.searchOpportunities1();
        
    pToTController.opportunityName = 'test';
    pToTController.masterContracts =null;
    pToTController.searchOpportunities1();
    
    pToTController.selectedOption = '';
    pToTController.searchOpportunities1();
    
    
    pToTController.masterId = newOpp2.Id;
    pToTController.opportunityName = null;
    pToTController.createNewTaskOrder();
    
    System.assertEquals(pToTController.newTask.Master_Contract_lookup__c,newOpp2.Id );
    pToTController.getOptions();
    
    pToTController.goNext();
    pToTController.goPrevious();
}
}