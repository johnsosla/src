/*************************************************************************
*
* PURPOSE: Smoke Tests for various classes to ensure code coverage
*
* CREATED: 2015 AECOM
* AUTHOR: Richard Cook
* Tests have been split into multiple files to work around developer console code coverage bug
***************************************************************************/
@isTest
private class TestCoverageSmokeTests8 {

    @istest private static void test_rsProjectViewModel()
    {
        rsProjectViewModel.SortField = 'Id';
        
        rsPRTeamEmployee mock = TestCoverageSmokeMocks.mockRSProjecTeam(1, TestCoverageSmokeMocks.mockProject().Id).get(0);
        
        
        rsProjectViewModel testClass = new rsProjectViewModel(mock);
        
        testClass.setObj(testClass.getObj());
        
        rsProjectViewModel testClass2 = new rsProjectViewModel(mock);
        testClass.compareTo(testClass2);
        
        rsProjectViewModel testClass3 = new rsProjectViewModel(mock);
        rsPRTeamEmployee tmp = testClass3.getObj();
        tmp.setProjectSequence(999);
        testClass3.setObj(tmp);
        testClass.compareTo(testClass3);
        
        tmp.setProjectSequence(-1);
        testClass3.setObj(tmp);
        testClass.compareTo(testClass3);
        
        rsProjectViewModel testClass4 = new rsProjectViewModel(mock);
        tmp = testClass4.getObj();
        testClass4.setObj(tmp);
        testClass.compareTo(testClass4);

        rsProjectViewModel testClass5 = new rsProjectViewModel(mock);
        tmp = testClass5.getObj();
        
        testClass5.setObj(tmp);     
        testClass5.setObj(testClass5.getObj());
        
        testClass.compareTo(testClass5);
        
        rsProjectViewModel testClass6 = new rsProjectViewModel(mock);
        testClass.compareTo(testClass6);
        
        rsProjectViewModel testClass7 = new rsProjectViewModel(mock);
        testClass7.getObj().setProjectGroup(null);
        testClass.compareTo(testClass7);
            

    
    }   
    

    @istest private static void test_rsAssignProfileReviewController2()
    {
        User u = TestCoverageSmokeMocks.mockUser();
        User u2 = TestCoverageSmokeMocks.mockUser(false);
        u2.Email = 'SFDCTestCase_consultant@aecom.com';
        insert u2;
        
        System.runAs(u)
        {
        ApexPages.currentPage().getParameters().put('UserId', u2.Id);
        ApexPages.currentPage().getParameters().put('type', '');
            
        rsAssignProfileReviewController testClass = new rsAssignProfileReviewController();
        testClass.getReviewee().EmployeeNumber = 'xyz';
        testClass.getReviewee().Profile_Reviewer__c = null;
        
        testClass.save();
            
        }
    }    
     
    @istest private static void test_rsAutoCompleteTestController()
    {
        rsTestUtil.createTestProfileParts(1,1);
        rs_Profile_Part__c pp = [Select Name, Skill_Area__c, Skill__c, Skill_Level__c, Specialty__c from rs_Profile_Part__c limit 1];
        // insert testObj2;
        
        rsAutoCompleteTestController.getValues(pp.Name);
        
        rsSysInfoController rsys = new rsSysInfoController();
        rsys.getEndpoint();
        rsSysInfoController.getStatus();
        
    }
    
    
    @isTest private static void test_rsSearchResultExcelExportController()
    {
        User mock = TestCoverageSmokeMocks.mockUser();
        // String j3 = '[{"userId": ' +  mock.Id+ ', "userName": "' + mock.Username +'"}]';
        rsSearchResult sr = new rsSearchResult();
        sr.userId = mock.Id;
        sr.userName = mock.Username;
        sr.cells = new List<string>();
        sr.cells.add('Id');
        sr.cells.add('Name');
        
        List<rsSearchResult> srlist = new List<rsSearchResult>();
        srlist.add(sr);
        
        List<string> slist = new List<string>();
        slist.add('Id');
        for(Integer e = 0; e < 12; e += 1)
        {
            slist.add('Name');
        }
        
        String j3 = JSON.serialize(srlist);
        rs_Search__c testObj = new rs_Search__c();
        
        testObj.Result_Fields__c = j3;
        testObj.User_Fields__c = j3;
        testObj.PR_Team_Employee_Fields__c = j3;
        testObj.Search_Fields__c = JSON.serialize( slist );
        testObj.Overflow_Fields__c = j3;
        testObj.Overflow_Fields_2__c = j3;
        testObj.Overflow_Fields_3__c =  j3;
        testObj.Overflow_Fields_4__c =  j3;
        testObj.Overflow_Fields_5__c =  j3;
        testObj.Overflow_Fields_6__c =  j3;
        testObj.Overflow_Fields_7__c =  j3;
        testObj.Overflow_Fields_8__c =  j3;
        testObj.Overflow_Fields_9__c =  j3;
        insert testObj;
        
        ApexPages.currentPage().getParameters().put('id', testObj.Id);
        
        Test.startTest();
        rsSearchResultExcelExportController c = new rsSearchResultExcelExportController();
        String placeHolder = c.xlsHeader;
        
        rsSavedSearch testObj2 = new rsSavedSearch(testObj);
        c.deleteSearchRecord();
        Test.stopTest();
        
    }
    
    
    
}