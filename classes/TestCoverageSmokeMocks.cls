/*************************************************************************
*
* PURPOSE: Smoke Tests for various classes to ensure code coverage
*
* CREATED: 2015 AECOM
* AUTHOR: Richard Cook
* Tests have been split into multiple files to work around developer console code coverage bug
***************************************************************************/
@isTest
public class TestCoverageSmokeMocks {

    public class ErrorMock implements HttpCalloutMock  {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody('');
            res.setStatus('404');
            return res;
        }
        
    }
    
    
    public static User mockUser(Boolean doInsert)   
    {
        Profile p = [select id from profile where name='AECOM Standard User - APAC'];
        User u = new User(LastName = 'Test User', Alias = 'A' + generateRandomString(5), Username = 'Test@test12343456677.com.' + generateRandomString(10), CommunityNickname = 'n' + generateRandomString(10) , Email='SFDCTestCase@aecom.com', emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', EmployeeNumber = generateRandomString(5) );
        u.NA_GNG_Approver__c = true;
        if(doInsert)
        {
            insert u;   
        }
        
        return u;
    }       

    public static List<User> mockUsers(Integer amount, Boolean setLargeField)
    {
        List<User> userList = new List<User>();
        Profile p = [select id from profile where name='AECOM Standard User - APAC'];
        for(Integer i = 0; i < amount; i += 1)
        {
            User u = new User(LastName = 'Test User', Alias = 'A' + generateRandomString(5), Username = 'Test@test12343456677.com.' + generateRandomString(10), CommunityNickname = 'n' + generateRandomString(10) , Email='SFDCTestCase@aecom.com', emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', EmployeeNumber = generateRandomString(5) );
            u.NA_GNG_Approver__c = true;
            if(setLargeField)
            {
            u.Bio__c = 'a'.repeat('', 32000);
            }
            System.debug(LoggingLevel.Warn, 'HEAP ' +  Limits.getHeapSize());
            userList.add(u);
            
        }
        insert userList;
        System.debug(LoggingLevel.Warn, 'HEAP ' +  Limits.getHeapSize());
        return userList;
        
        
    }
    
    
    public static Contact mockContact(Boolean doInsert, Id userId)
    {
        Contact c = new Contact(FirstName = generateRandomString(5), LastName = generateRandomString(5), Email = 'SFDCTestCase@aecom.com', Department = 'Fake Department',
            User__c = userId, Phone = '123456789');
            if(doInsert)
            {
                insert c;
            }
            return c;
        
    }
    
    public static User mockUser()   
    {
        Profile p = [select id from profile where name='AECOM Standard User - APAC'];
        User u = new User(LastName = 'Test User', Alias = 'A' + generateRandomString(5), Username = 'Test@test12343456677.com.' + generateRandomString(10), CommunityNickname = 'n' + generateRandomString(10) , Email='SFDCTestCase@aecom.com', emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', EmployeeNumber = generateRandomString(5) );
        u.NA_GNG_Approver__c = true;
        insert u;
        return u;
    }   
    
    public static User mockAdmin()  
    {
        Profile p = [select id from profile where name='System Administrator'];
        User u = new User(LastName = 'Test User', Alias = 'A' + generateRandomString(5), Username = 'Test@test12343456677.com.' + generateRandomString(10), CommunityNickname = 'n' + generateRandomString(10) , Email='SFDCTestCase@aecom.com', emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', EmployeeNumber = generateRandomString(5) );
        insert u;
        return u;
    }       
    

    public static Account mockAcc(Boolean doInsert) {
        Country__c country = new Country__c(Name = 'Test Country');
        insert country;
        Account newAccount = new Account(Name = 'TestAccount', Client_Group__c = 'Industrial/Commercial', CountryLookup__c = country.Id);
        if(doInsert)
        {
            insert newAccount;  
        }
        
        return newAccount;
    }           
    
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), 62);
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

    public static Opportunity mockOpp(Boolean doInsert) {
        Geography__c g = new Geography__c(Name = 'Europe');
        insert g;
        Business_Line__c bl = new Business_Line__c(Name = 'Oil & Gas' + generateRandomString(5));
        insert bl;
        AECOM_Primary_Department__c dept = new AECOM_Primary_Department__c(Name = 'Dept', Lead_District__c = 'District', Lead_Region__c = 'Region', Geography_Lookup__c = g.Id, Business_Line_Lookup__c = bl.Id);
        insert dept;
        Profile p = [select id from profile where name='AECOM Standard User - APAC'];
        User u = new User(LastName = 'Test User', Alias = 'A' + generateRandomString(5), Username = 'Test@test12343456677.com.' + generateRandomString(10), CommunityNickname = 'n' + generateRandomString(10) , Email='SFDCTestCase@aecom.com', emailencodingkey='UTF-8', languagelocalekey='en_US', localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', EmployeeNumber = generateRandomString(5) );
        insert u;
        AECOM_Employee__c hrData = new AECOM_Employee__c(Name = 'Test Person', First_Name__c = 'Test', Last_Name__c = 'Person', Employee_ID__c =  generateRandomString(5) );
        insert hrData;
        Country__c country = new Country__c(Name = 'Test Country');
        insert country;
        Account newAccount = new Account(Name = 'TestAccount' + generateRandomString(5), Client_Group__c = 'Industrial/Commercial', CountryLookup__c = country.Id);
        insert newAccount;
        Date d = Date.today();
        RecordType r = [select Id from RecordType where Name = 'Program - APAC' and sObjectType = 'Opportunity'];
        Opportunity newOpp = new Opportunity(Name = 'TestOpp' + generateRandomString(5), StageName = '1 Lead', AccountId = newAccount.Id, Probability_Stage__c = 0.1, Description = 'Desc', Project_City__c = 'Test City', Construction_cost__c = 10000, Project_DirectorUser__c = u.Id, Bid_DirectorUser__c = u.Id, Capture_Manager__c = hrData.Id, Date_RFP_expected__c = d, Estimated_work_start_date__c = d, CloseDate = d, Work_end_date_del__c = d, Subs_Other_Revenue__c = 1000, Go_Probability__c = 1, Amount = 2000, Enterprise_Service__c = 'Architecture');
        newOpp.RecordTypeId = r.Id;
        newOpp.Enterprise_Service__c = 'TEST';
        newOpp.ValidateGo__c = false;
        if(doInsert) {
            insert newOpp;  
            newOpp.AECOM_Primary_Dept_Lookup__c = dept.Id;
            update newOpp;
            
        }
        return newOpp;
    }
    
   public static CFM_Survey_Response__c mockSurveyResponse(Boolean doInsert){
        Country__c country = new Country__c(Name = 'Test Country');
        insert country;
        Account newAccount = new Account(Name = 'TestAccount' + generateRandomString(5), Client_Group__c = 'Industrial/Commercial', CountryLookup__c = country.Id);
        insert newAccount;
        CFM_Survey_Response__c newSurveyResponse = new CFM_Survey_Response__c(Account__c = newAccount.Id);

        if(doInsert){
            insert newSurveyResponse;
        }
        return newSurveyResponse;
    }    
    
    public static Geography__c mockGeo()
    {
        Geography__c geo = new Geography__c();
        geo.Name = 'Test Geo';
        insert geo;
        return geo;
    }
    public static Business_Line__c mockBusLine()
    {
    
        Business_Line__c busline = new Business_Line__c();
        busline.Name = 'Test BusLine';
        insert busline;
        return busline;
    }
    public static Practice_Area__c mockPracArea()
    {
        Practice_Area__c prac = new Practice_Area__c();
        prac.Name = 'Test Prac' + generateRandomString(10);
        prac.Status__c = 'Approved?';
        insert prac;
        return prac;
    }
    
    public static Sub_Practice_Area__c mockSubPrac()
    {
        Sub_Practice_Area__c subprac = new Sub_Practice_Area__c();
        subprac.Name = 'Test subprac' + generateRandomString(10);
        subprac.Status__c = 'Approved also';
        insert subprac;  
        return subprac;
    }
    public static AECOM_Primary_Department__c mockDep(Geography__c geo, Business_Line__c busline)
    {
        AECOM_Primary_Department__c aeDep1 = new AECOM_Primary_Department__c();
        aeDep1.Name = 'Test AE Department';
        aeDep1.Business_Line_Lookup__c = busline.Id;
        aeDep1.Geography_Lookup__c = geo.Id;
        aeDep1.Lead_Region__c = 'Test Region';
        insert aeDep1;
        return aeDep1;
    }   
    
    public static List<Opportunity_Department__c> mockOppDepList(Boolean doInsert, Integer size, Opportunity opp, AECOM_Primary_Department__c aeDep1, Practice_Area__c prac, Sub_Practice_Area__c subprac )
    {
        List<Opportunity_Department__c> returnList = new List<Opportunity_Department__c>();
        for(Integer i = 0; i < size; i += 1)
        {
            Opportunity_Department__c od = new Opportunity_Department__c();
            if(i == 0)
            {
                od.Primary__c = true;
                od.split__c = 100 - (size - 1) ;
            } else {
                od.split__c = 1;
                od.Primary__c = false;
            }
            od.AECOM_Department__c = aeDep1.Id;
            od.Opportunity__c = opp.Id;
            od.Practice_Area__c = mockPracArea().Id; // TODO make these unique for normal case, 
            od.Sub_Practice_Area__c = mockSubPrac().Id;
            
            if(doInsert)
            {
                insert od;  
                
            }
            returnList.add(od);
        }
        
        if(doInsert && size > 1)
        {
            returnList[0].split__c -= 1;
            returnList[1].split__c += 1;
            update returnList;
            
        }
        
        return returnList;
        
    }
    
    
    
    public static List<PR_Team_Employee__c> mockProjectTeam(Integer size, Id ProjectId)
    {
        User u = mockUser();
        System.runAs(u)
        {
            List<PR_Team_Employee__c> returnList = new List<PR_Team_Employee__c>();
            
            for(Integer i = 0; i < size; i += 1)
            {
                PR_Team_Employee__c tm = new PR_Team_Employee__c();
                tm.Project_ID__c = ProjectId;
                tm.EmployeeUser__c = mockUser().Id;
                tm.Group_Sequence__c = i;
                tm.Project_Role__c = generateRandomString(5);
                tm.Output_on_Resume__c = true;

                
                returnList.add(tm);
            }
            insert returnList;
            
            for(Integer e = 1; e < size; e += 1)
            {
                returnList[e].Next_Project_Part__c = returnList[e - 1].Id;
            }
            
            update returnList;
            return returnList;
            
        }
        return null;
    }
    
    public static List<rsPRTeamEmployee> mockRSProjecTeam(Integer size, Id ProjectId)
    {
        List<PR_Team_Employee__c> s_objects = mockProjectTeam(size, ProjectId);
        List<rsPRTeamEmployee> returnList = new List<rsPRTeamEmployee>();
        for( PR_Team_Employee__c item : s_objects)
        {
            returnList.add(new rsPRTeamEmployee(item));
        }
        return returnList;
    }
    
    public static Project__c mockProject()
    {
        User u = mockAdmin();
        system.runAs(u)
        {
            Project__c mock = new Project__c();
            mock.Opportunity__c = mockOpp(true).Id;
            mock.Owner__c = mockAcc(true).Id;
            mock.Name = 'test Name';
            mock.Project_Name__c = 'Test name';
            mock.Project_Description__c = 'Test description';
            insert mock;
            return mock;
        }
        return null;
    }
    
    public static rsProfile mockrsProfile(User u)
    {
        rsProfile testObj = new rsProfile(u);
        return testObj;
        
    }
    
    public static rsProjectGroup mockrsProjectGroup()
    {
        return  new rsProjectGroup('test', mockRSProjecTeam(5, mockProject().Id));
    
    }
    
   public static void mockTeam(Opportunity opp,  User emp, User emp2 )
    {
        
        
        AECOM_Employee__c hrData = new AECOM_Employee__c(Name = 'Test Person', First_Name__c = 'Test', Last_Name__c = 'Person', Employee_ID__c =  generateRandomString(5) );
        insert hrData;
        AECOM_Employee__c hrData2 = new AECOM_Employee__c(Name = 'Test Person2', First_Name__c = 'Test2', Last_Name__c = 'Person2', Employee_ID__c =  generateRandomString(5) );
        insert hrData2;
        
        List<AECOM_team__c> returnList = new List<AECOM_team__c>();
        Schema.sObjectType t = AECOM_team__c.getSObjectType();
        Schema.DescribeSObjectResult objDesc = t.getDescribe();
        Map<String, Schema.SObjectField> fieldsMap = objDesc.fields.getMap();
        List<Schema.PicklistEntry> pickListValues = fieldsMap.get('role__c').getDescribe().getPickListValues();
        for(Schema.PicklistEntry pickVal : pickListValues)
        {
                AECOM_team__c atc = new AECOM_team__c();
                atc.Account__c = opp.AccountId;
                atc.Opportunity__c = opp.Id;
                atc.Employee_User__c = emp.Id;
                atc.Employee__c = hrData.Id;
                atc.Role__c = pickVal.getValue();
                returnList.add(atc);
            
            if(pickVal.getValue() != 'Account Manager' && pickVal.getValue() != 'Capture Manager')
            {

                AECOM_team__c atc2 = new AECOM_team__c();
                atc2.Account__c = opp.AccountId;
                atc2.Opportunity__c = opp.Id;
                atc2.Employee_User__c = emp2.Id;
                atc2.Employee__c = hrData2.Id;
                atc2.Role__c = pickVal.getValue();
                returnList.add(atc2);
                                
            }
            
        }

                        
        insert returnList;              
        return;
        
    }   

    
}