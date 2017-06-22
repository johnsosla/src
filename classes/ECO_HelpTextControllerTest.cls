/* 
 * Name: ECO_HelpTextControllerTest
 * Type: Apex Test Coverage  
 * Description: Test coverage for the ECO_CreateHelpTextController and ECO_HelpTextController Apex Controller.         
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti         06/22/2016       1. Initial Version created
 */
@isTest
private class ECO_HelpTextControllerTest {

    static testMethod void ECO_CreateHelpTextController_UnitTest() {
       HelpText__c testHT = new HelpText__c(name='testHelpText', Message__c='This is test value');
       insert testHT;
        
       Test.startTest();
       PageReference pageRef = Page.ECO_CreateHelpText;
       Test.setCurrentPage(pageRef);
       ECO_CreateHelpTextController ECcontroller = new ECO_CreateHelpTextController();
       ApexPages.CurrentPage().getParameters().put('helpName', 'testHelpTextDummy');
       PageReference tstRef = ECcontroller.go();
       ApexPages.CurrentPage().getParameters().put('helpName', 'testHelpText');       
       tstRef = ECcontroller.go();
       Test.stopTest(); 
        
    }
    
    static testMethod void ECO_HelpTextController_UnitTest() {
       
       HelpText__c testHT = new HelpText__c(name='testHelpText', Message__c='This is test value');
       insert testHT;
       Test.startTest();
       PageReference pageRef = Page.ECO_HelpTextTest;
       Test.setCurrentPage(pageRef);
       ECO_HelpTextController ECcontroller = new ECO_HelpTextController();
       ECcontroller.theHelpId = testHT.id;
       ECcontroller.render = '';
       //Explicitly invoke getter of helpValue property
       String tstStr = ECcontroller.helpValue;
       //Explicitly invoke getter of helpEditId property
       tstStr = ECcontroller.helpEditId;
       Test.stopTest();
        
    }
}