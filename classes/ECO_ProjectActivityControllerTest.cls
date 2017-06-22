/* 
 * Name: ECO_ProjectActivityControllerTest
 * Type: Apex Test Coverage  
 * Description: Test coverage for the ECO_ProjectActivityController Apex Controller.         
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti         06/22/2016       1. Initial Version created
 */
@isTest
private class ECO_ProjectActivityControllerTest {

    static testMethod void ECO_ProjectActivityController_UnitTest() {
       //Create the test project
       pse__Proj__c testProj = ECO_Utils_Testing.createProject();
       testProj.ProjectDescription__c = 'Test Project';
       testProj.pse__Stage__c = 'Execution';
       update testProj;
       
       Test.startTest();
       PageReference pageRef = Page.ECO_ProjectActivity;
       Test.setCurrentPage(pageRef);
       
       ApexPages.CurrentPage().getParameters().put('ProjectID', testProj.id);
       ECO_ProjectActivityController EAcontroller = new ECO_ProjectActivityController();
              
       PageReference tstRef = EAcontroller.cancel();
       
       tstRef = EAcontroller.saveandnew();
       
       tstRef = EAcontroller.save();
       
       Test.stopTest();
       
    }
}