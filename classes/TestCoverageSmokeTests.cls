/*************************************************************************
*
* PURPOSE: Smoke Tests for various classes to ensure code coverage
*
* CREATED: 2015 AECOM
* AUTHOR: Richard Cook
* Tests have been split into multiple files to work around developer console code coverage bug
***************************************************************************/

@isTest public class TestCoverageSmokeTests {

	
	@isTest private static void test_ModifyDepartmentController3()
    {
    	// calling save without any related Opp Deps
    	Opportunity testObj = TestCoverageSmokeMocks.mockOpp(true);
    	Geography__c geo = TestCoverageSmokeMocks.mockGeo();
    	Business_Line__c busline = TestCoverageSmokeMocks.mockBusLine();
    	Practice_Area__c prac = TestCoverageSmokeMocks.mockPracArea();
    	Sub_Practice_Area__c subprac = TestCoverageSmokeMocks.mockSubPrac();
    	AECOM_Primary_Department__c aeDep1  = TestCoverageSmokeMocks.mockDep(geo, busline);        

    	System.currentPageReference().getParameters().put('step', '2');
    	
    	Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
		ModifyDepartmentController xc = new ModifyDepartmentController(sc);
    	xc.Save();
    	Test.stopTest();
    }
    
	@isTest private static void test_ModifyDepartmentController_normal()
    {
    	// calling default constructor with a primary department
    	Opportunity testObj = TestCoverageSmokeMocks.mockOpp(true);
    	Geography__c geo = TestCoverageSmokeMocks.mockGeo();
    	Business_Line__c busline = TestCoverageSmokeMocks.mockBusLine();
    	Practice_Area__c prac = TestCoverageSmokeMocks.mockPracArea();
    	Sub_Practice_Area__c subprac = TestCoverageSmokeMocks.mockSubPrac();

    	AECOM_Primary_Department__c aeDep1  = TestCoverageSmokeMocks.mockDep(geo, busline);
		List<Opportunity_Department__c> oppDep = TestCoverageSmokeMocks.mockOppDepList(false, 6, testObj, aeDep1, prac, subprac);
		oppDep[0].Primary__c = true;
		insert oppDep;
		System.currentPageReference().getParameters().put('step', '2');
		
		Test.startTest();    	
    	ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
		ModifyDepartmentController xc = new ModifyDepartmentController(sc);
    	xc.Save();
    	xc.Save();
    	Test.stopTest();
    }    
	@isTest private static void test_ModifyDepartmentController_multiprinary()
    {
    	// calling default constructor with a primary department
    	Opportunity testObj = TestCoverageSmokeMocks.mockOpp(true);
    	Geography__c geo = TestCoverageSmokeMocks.mockGeo();
    	Business_Line__c busline = TestCoverageSmokeMocks.mockBusLine();
    	Practice_Area__c prac = TestCoverageSmokeMocks.mockPracArea();
    	Sub_Practice_Area__c subprac = TestCoverageSmokeMocks.mockSubPrac();
    	AECOM_Primary_Department__c aeDep1  = TestCoverageSmokeMocks.mockDep(geo, busline);
		List<Opportunity_Department__c> oppDep = TestCoverageSmokeMocks.mockOppDepList(false, 6, testObj, aeDep1, prac, subprac);
		oppDep[0].Primary__c = true;
		oppDep[1].Primary__c = true;
		oppDep[2].Primary__c = true;
		oppDep[3].Primary__c = true;
		insert oppDep;
		
		Test.startTest();    	
    	ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
		ModifyDepartmentController xc = new ModifyDepartmentController(sc);
    	xc.Save();
    	Test.stopTest();
    }
    
    @isTest private static void test_ModifyDepartmentController_noprimary()
    {
    	// test case no primary oppDep
    	Opportunity testObj = TestCoverageSmokeMocks.mockOpp(true);
    	Geography__c geo = TestCoverageSmokeMocks.mockGeo();
    	Business_Line__c busline = TestCoverageSmokeMocks.mockBusLine();
    	Practice_Area__c prac = TestCoverageSmokeMocks.mockPracArea();
    	Sub_Practice_Area__c subprac = TestCoverageSmokeMocks.mockSubPrac();
    	AECOM_Primary_Department__c aeDep1  = TestCoverageSmokeMocks.mockDep(geo, busline);
		List<Opportunity_Department__c> oppDep = TestCoverageSmokeMocks.mockOppDepList(false, 6, testObj, aeDep1, prac, subprac);
		oppDep[0].Primary__c = false;
		insert oppDep;
		
		Test.startTest();    	
		System.currentPageReference().getParameters().put('step', '2');		    	
    	ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
		ModifyDepartmentController xc = new ModifyDepartmentController(sc);
    	xc.Save();
    	Test.stopTest();
    }  
    
    @isTest private static void test_ModifyDepartmentController_split()
    {
    	// test case split <> 100
    	Opportunity testObj = TestCoverageSmokeMocks.mockOpp(true);
    	Geography__c geo = TestCoverageSmokeMocks.mockGeo();
    	Business_Line__c busline = TestCoverageSmokeMocks.mockBusLine();
    	Practice_Area__c prac = TestCoverageSmokeMocks.mockPracArea();
    	Sub_Practice_Area__c subprac = TestCoverageSmokeMocks.mockSubPrac();
    	AECOM_Primary_Department__c aeDep1  = TestCoverageSmokeMocks.mockDep(geo, busline);
		List<Opportunity_Department__c> oppDep = TestCoverageSmokeMocks.mockOppDepList(false, 6, testObj, aeDep1, prac, subprac);
		oppDep[0].split__c = 100;
		insert oppDep;
		
		Test.startTest();    	
    	ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
		ModifyDepartmentController xc = new ModifyDepartmentController(sc);
    	xc.Save();
    	Test.stopTest();
    }  
    
    @isTest private static void test_ModifyDepartmentController_primary_noprac()
    {
    	// test case split <> 100
    	Opportunity testObj = TestCoverageSmokeMocks.mockOpp(true);
    	Geography__c geo = TestCoverageSmokeMocks.mockGeo();
    	Business_Line__c busline = TestCoverageSmokeMocks.mockBusLine();
    	Practice_Area__c prac = TestCoverageSmokeMocks.mockPracArea();
    	Sub_Practice_Area__c subprac = TestCoverageSmokeMocks.mockSubPrac();
    	AECOM_Primary_Department__c aeDep1  = TestCoverageSmokeMocks.mockDep(geo, busline);
		List<Opportunity_Department__c> oppDep = TestCoverageSmokeMocks.mockOppDepList(false, 6, testObj, aeDep1, prac, subprac);
		oppDep[0].Practice_Area__c = null;
		insert oppDep;
		
		Test.startTest();    	
		System.currentPageReference().getParameters().put('step', '2');		    	
    	ApexPages.StandardController sc = new ApexPages.StandardController(testObj);
		ModifyDepartmentController xc = new ModifyDepartmentController(sc);
    	xc.Save();
    	Test.stopTest();
    }      
    

	
	
	@isTest private static void test_ModifyDepartmentController2()
    {
    	
    	Opportunity testObj = TestCoverageSmokeMocks.mockOpp(true);
    	System.currentPageReference().getParameters().put('newid', testObj.Id);
    	System.currentPageReference().getParameters().put('step', '2');
    	
    	Geography__c geo = new Geography__c();
    	geo.Name = 'Test Geo';
    	insert geo;
    	Business_Line__c busline = new Business_Line__c();
    	busline.Name = 'Test BusLine';
    	insert busline;
    	
    	Practice_Area__c prac = new Practice_Area__c();
    	prac.Name = 'Test Prac';
    	prac.Status__c = 'Approved?';
    	insert prac;
    	Sub_Practice_Area__c subprac = new Sub_Practice_Area__c();
    	subprac.Name = 'Test subprac';
    	subprac.Status__c = 'Approved also';
    	insert subprac;    	
    	
    	AECOM_Primary_Department__c aeDep1 = new AECOM_Primary_Department__c();
    	aeDep1.Name = 'Test AE Department';
    	aeDep1.Business_Line_Lookup__c = busline.Id;
    	aeDep1.Geography_Lookup__c = geo.Id;
        aeDep1.Lead_Region__c = 'Test Region';
    	insert aeDep1;


    	Test.startTest();
    	ModifyDepartmentController c = new ModifyDepartmentController();
    	c.Previous();
    	Test.stopTest();
    	
    	    	
    }
    
	@isTest private static void test_ModifyDepartmentController()
    {
    	Opportunity testObj = TestCoverageSmokeMocks.mockOpp(true);
    	System.currentPageReference().getParameters().put('oppid', testObj.Id);
    	ModifyDepartmentController c = new ModifyDepartmentController();

		// step == 2 && sub_prac == nulll
		// same department twice?

		Geography__c geo = TestCoverageSmokeMocks.mockGeo();
    	Business_Line__c busline = TestCoverageSmokeMocks.mockBusLine();
		Geography__c geo2 = TestCoverageSmokeMocks.mockGeo();
    	Business_Line__c busline2 = TestCoverageSmokeMocks.mockBusLine();
    	
    	Practice_Area__c prac = TestCoverageSmokeMocks.mockPracArea();
    	Sub_Practice_Area__c subprac = TestCoverageSmokeMocks.mockSubPrac();

		Practice_Area_Collection__c pac = new Practice_Area_Collection__c();    	
    	pac.Business_Line__c = busline.Id;
    	pac.Geography__c = geo.Id;
    	pac.Practice_Area__c = prac.Id;
    	pac.Sub_Practice_Area__c = subprac.Id;
    	insert pac;
    	
    	pac = [select id,name, Practice_Area__r.Id, Practice_Area__r.Name,
    	 	   Business_Line__r.Id, Business_Line__r.Name,
 	    	 Geography__r.Id, Geography__r.Name,
	    	 Sub_Practice_Area__r.Id, Sub_Practice_Area__r.Name
    	 from Practice_Area_Collection__c where id= :pac.id];
    	
    	Test.startTest(); 
    	ModifyDepartmentController.Geography mGeo = new ModifyDepartmentController.Geography(pac);

    	ModifyDepartmentController.PracticeArea mPrac = new ModifyDepartmentController.PracticeArea(pac);
    	System.assert(prac.Name != null);
    	System.assert(pac.practice_area__r.Name != null);
    	System.assert(mPrac.Name != null);
    	
    	ModifyDepartmentController.SubPracticeArea mSubprac = new ModifyDepartmentController.SubPracticeArea(pac);

    	Set<Id> BusinessLineSet = new Set<Id>{ busline.Id, busline2.Id };
    	Set<Id> geoGraphySet = new Set<Id>{ geo.Id, geo2.Id };
    	c.fillPracticeAreaAll(BusinessLineSet, geoGraphySet);

		
    	
    	AECOM_Primary_Department__c aeDep1  = TestCoverageSmokeMocks.mockDep(geo, busline);
    	List<Opportunity_Department__c> oppDep = TestCoverageSmokeMocks.mockOppDepList(false, 1, testObj, aeDep1, prac, subprac);
    	
    	
    	Map<Id,ModifyDepartmentController.SubPracticeArea> mySPa = new Map<Id,ModifyDepartmentController.SubPracticeArea>();
    	mySPa.put(mSubprac.Id, mSubprac);
//    	mySPa.put(subprac.Id, mSubprac);
    	
    	mPrac.mapSPA = mySPa;
        Map<Id,ModifyDepartmentController.PracticeArea> myPa = new Map<Id,ModifyDepartmentController.PracticeArea>();
        myPa.put(mPrac.Id, mPrac);
        Map<string,ModifyDepartmentController.Geography> myMap = new Map<string,ModifyDepartmentController.Geography>();
        mGeo.mapPA = myPa;
    	myMap.put('Test Geo', mGeo);
 	    myMap.put('z Test Geo', mGeo);

    	ModifyDepartmentController.MyDepartment dep = new  ModifyDepartmentController.MyDepartment(oppDep[0], myMap, 0);
    	dep.Geography = 'Test Geo';

    	
    	dep.getisSubAreaDisabled();
    	dep.getPracticeAreas();
    	dep.getSubPracticeAreas();
        Test.stopTest();
    	
    
    }    
    	
		
	
}