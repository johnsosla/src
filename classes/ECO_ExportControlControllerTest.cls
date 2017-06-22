/* 
 * Name: ECO_ExportControlControllerTest
 * Type: Apex Test Coverage  
 * Description: Test coverage for the ECO_ExportControlController Apex Controller.         
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti         06/20/2016       1. Initial Version created
 */
@isTest
private class ECO_ExportControlControllerTest {

    static testMethod void ECO_ExportControlController_UnitTest() {
       
       //Create test account
       Account recAcc = ECO_Utils_Testing.createAccount();
       
       //Create test site
       Site__c recSite =  ECO_Utils_Testing.createSite(recAcc.Id);

       recAcc.Website = 'http://www.test.com';
       update recAcc;

       //Create Secondary Site
       Site__c recSite1 =  ECO_Utils_Testing.createSite(recAcc.Id);


       //Create test project
       pse__Proj__c recProj = ECO_Utils_Testing.createProject();
       recProj.ProjectDescription__c = 'Test Project';
       recProj.pse__Stage__c = 'Execution';
       update recProj;

       //Create primary test project site
       Project_Site__c recPPS = ECO_Utils_Testing.createProjectSite(recProj.Id, recSite.Id);
       recPPS.Is_Primary_End__c = true;
       update recPPS;

       //Create Billing test project site
       Project_Site__c recBPS = ECO_Utils_Testing.createProjectSite(recProj.Id, recSite1.Id);
       recBPS.Is_Billing__c = true;
       update recBPS;

       //Create Questionaire Set
       QuestionnaireSet__c recQS = ECO_Utils_Testing.createQuestionnaireSet(recProj.Id);
    

       ExportControl__c recEC = new ExportControl__c(QuestionnaireSet__c=recQS.Id,Project__c=recProj.Id);

       
       Test.startTest();
       PageReference pageRef = Page.ECO_ExportControl;
       Test.setCurrentPage(pageRef);
       
       ApexPages.StandardController sc = new ApexPages.StandardController(recEC);
       ECO_ExportControlController EEcontroller = new ECO_ExportControlController(sc);
       
       EEcontroller.SubmitForReview();
       EEcontroller.SaveRecord();

       PageReference tstRef = EEcontroller.ReturnToSummary();
       
       Test.stopTest();
        
    }
}