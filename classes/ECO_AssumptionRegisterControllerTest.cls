/* 
 * Name: ECO_AssumptionRegisterControllerTest
 * Type: Apex Test Coverage  
 * Description: Test coverage for the ECO_AssumptionRegisterController Apex Controller.         
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti         06/22/2016       1. Initial Version created
 */
@isTest
private class ECO_AssumptionRegisterControllerTest {

    static testMethod void ECO_AssumptionRegisterController_UnitTest() {
       //Create the test project
       pse__Proj__c testProj = ECO_Utils_Testing.createProject();
       testProj.ProjectDescription__c = 'Test Project';
       testProj.pse__Stage__c = 'Execution';
       update testProj;
       
       //Create test Assumptions
       Assumption__c testAssumption = ECO_Utils_Testing.createAssumption(testProj.Id);
         
       Test.startTest();
       PageReference pageRef = Page.ECO_AssumptionRegister;
       Test.setCurrentPage(pageRef);
              
       ApexPages.StandardController sc = new ApexPages.StandardController(testProj);
       
       ECO_AssumptionRegisterController EAcontroller = new ECO_AssumptionRegisterController(sc);
       
       ApexPages.CurrentPage().getParameters().put('projectId', testProj.id);
       ApexPages.CurrentPage().getParameters().put('Id', testAssumption.id);
       EAcontroller = new ECO_AssumptionRegisterController(sc);
       EAcontroller.addAssumption();
       
       EAcontroller.lAssumptions.add(testAssumption);
       
       //EAcontroller.removeAssumption();
       //Test the exception flow of removal      
       EAcontroller.removeAssumption();
       
       EAcontroller.save();

       PageReference tstRef = EAcontroller.backToProject();
       
       Test.stopTest();         
    }
}