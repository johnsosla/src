/* 
 * Name: ECO_AssumptionFlyoutControllerTest
 * Type: Apex Test Coverage  
 * Description: Test coverage for the ECO_AssumptionFlyoutController Apex Controller.         
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti         06/22/2016       1. Initial Version created
 */
@isTest
private class ECO_AssumptionFlyoutControllerTest {

    static testMethod void ECO_AssumptionFlyoutController_UnitTest() {
        
       //Create the test project
       pse__Proj__c recProj = ECO_Utils_Testing.createProject();
       recProj.ProjectDescription__c = 'Test Project';
       recProj.pse__Stage__c = 'Execution';
       update recProj;
       
       ECO_AssumptionFlyoutController EAcontroller = new ECO_AssumptionFlyoutController();
       list<SelectOption> lstPlanElements = EAcontroller.lPlanElements;
       
       EAcontroller.sProjectId = recProj.id;
       EAcontroller.saveAssumption();
       
       EAcontroller.refresh();  
       
       PageReference tstRef = EAcontroller.viewRegister();    
       
        
    }
}