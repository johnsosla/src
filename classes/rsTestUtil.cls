/*************************************************************************
*
* PURPOSE: Util methods for testing resume system classes
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
@isTest
public class rsTestUtil {

    //Used to make sure we have unique usernames in calls to this class' methods
    private Static Integer userCount = 0;

    public static void createTestProfileParts(Integer numUsers, Integer numPartsPerUser) {
        createTestProfileParts(numUsers, numPartsPerUser, 0);
    }
    public static void createTestProfileParts(Integer numUsers, Integer numPartsPerUser, Integer numProjectsPerUser) {
        createTestProfileParts(numUsers, numPartsPerUser, numProjectsPerUser, rsProfilePart.RT_TRAINING,  rsPRTeamEmployee.RT_AECOMPROJECT);
    }

    //Util method to insert some test data parts and users
    public static void createTestProfileParts(Integer numUsers, Integer numPartsPerUser, Integer numProjectsPerUser, String profilePartRecordType, String projectRecordType) {
        List<User> userList = createTestUsers(false, numUsers);

        List<rs_Profile_Part__c> userParts = new List<rs_Profile_Part__c>();
        List<PR_Team_Employee__c> userProjects = new List<PR_Team_Employee__c>();
        for (User currUser : userList) {
            for (Integer j = 0; j < numPartsPerUser; j++) {
                rsProfilePart currPart = new rsProfilePart(currUser.Id, profilePartRecordType);
                setProfilePartFieldsByRecordType(currPart,profilePartRecordType);
                currPart.getObj().put('Status__c',rsProfilePart.S_PENDING);
                userParts.add((rs_Profile_Part__c)currPart.getObj());
            }
            for (Integer k = 0; k < numProjectsPerUser; k++) {
                rsPRTeamEmployee currProject = new rsPRTeamEmployee(currUser.Id, projectRecordType);
                currProject.setProjectNameEditable('Test Project Name');
                currProject.setDateInvolvementStarted('09/10/11');
                currProject.setDateInvolvementEnded('01/02/13');
                currProject.setProjectRole('This is a test role');
                currProject.setRoleDescription('This is a test description of my test role');
                currProject.setClientNameEditable('Test Client Name');
                currProject.setProjectGroup('Test Project Group');
                currProject.setLocationCountryEditable('Test Location Country');
                currProject.setLocationCityEditable('Test Location City');
                currProject.setOutputOnResume(true);
                currProject.setStatus(rsPRTeamEmployee.S_PENDING);
                currProject.setGroupSequence(0);
                currProject.setProjectSequence(k);
                userProjects.add(currProject.getPRObj());
            }
        }
        insert userParts;
        insert userProjects;
    }

    private static void setProfilePartFieldsByRecordType(rsProfilePart part, String partRecordType) {
        if(partRecordType == rsProfilePart.RT_AWARD) {
            part.setAwardTitle('Test Award Title');
            part.setAwardAgency('Test Award Agency');
            part.setAwardDate('10/23/1996');
        } else if(partRecordType == rsProfilePart.RT_CERTIFICATION) {
            part.setCertificationTitle('Test Certification Title');
            part.setCertificationDescription('Test Certification Description');
            part.setDateCertified('10/31/1997');
        } else if(partRecordType == rsProfilePart.RT_EDUCATION) {
            part.setDegree('Test Degree');
            part.setDegreeSpecialty('Test Degree Specialty');
            part.setInstitution('Test Institution');
            part.setInstitutionCountry('Test Institution Country');
            part.setYearObtained(1998);
        } else if(partRecordType == rsProfilePart.RT_LANGUAGES) {
            part.setLanguage('Test Language');
            part.setLanguageSkill('Test Language Skill');
            part.setLanguageLevel('Test Language Level');
        } else if(partRecordType == rsProfilePart.RT_PROF_AFFILIATION) {
            part.setAssociationName('Test Association Name');
            part.setMemberSince('12/12/1990');
            part.setPosition('Test Position');
        } else if(partRecordType == rsProfilePart.RT_PUBLICATION) {
            part.setPublicationTitle('Test Publication Title');
            part.setPublicationDate('10/10/2004');
            part.setPublication('Test Publication');
            part.setPublicationAuthor('Test Publication Author');
        } else if(partRecordType == rsProfilePart.RT_REGISTRATION) {
            part.setLicenseRegistrationCountry('Test Country');
            part.setLicenseRegistrationName('Test License/Registration Name');
            part.setStateProvince('Test State/Province');
            part.setCountry('Test Country');
            part.setRegistrationNumber('Test Registration Number');
            part.setIssuedDate('10/10/1998');
            part.setExpirationDate('10/10/1999');
        } else if(partRecordType == rsProfilePart.RT_SF254) {
            part.setSF254Discipline('Test SF254 Discipline');
            part.setIsSF254Primary(true);
        } else if(partRecordType == rsProfilePart.RT_SF330) {
            part.setSF330Discipline('Test SF330 Discipline');
            part.setIsSF330Primary(true);
        } else if(partRecordType == rsProfilePart.RT_SKILL_INDEX) {
            part.setSkillArea('Test Skill Area');
            part.setSkill('Test Skill');
            part.setSpecialty('Test Specialty');
            part.setSkillLevel('Test Skill Level');
        } else if(partRecordType == rsProfilePart.RT_TRAINING) {
            part.setTrainingName('Test Training');
            part.setTrainingDate('10/23/1995');
            part.setVendor('Training Vendor Test');
            part.setOutputOnResume(true);
        } else if(partRecordType == rsProfilePart.RT_TRANSLATIONS) {
            part.setTranslateFrom('Test Translate From');
            part.setTranslateTo('Test Translate To');
        } else if(partRecordType == rsProfilePart.RT_WORK_HISTORY) {
            part.setCompanyName('Test Company Name');
            part.setJobTitle('Test Job Title');
            part.setStartDate('10/13/1999');
            part.setEndDate('10/13/2000');
            part.setCity('Test City');
            part.setWorkHistoryCountry('Test Work History Country');
            part.setWorkHistoryState('Test Work Hisotry State');
            part.setCurrent(true);
        } else if(partRecordType == rsProfilePart.RT_REFERENCE) {
            part.setReferenceCompanyName('Test Company Name');
            part.setReferenceEmail('test@email.com');
            part.setReferenceFirstName('TestName');
            part.setReferenceLastName('TestLastName');
            part.setReferencePhone('555-444-5555');
            part.setReferenceTitle('Test Title');
        } else if(partRecordType == rsProfilePart.RT_PERSONAL) {
            part.setResumeName('Test Resume Name');
            part.setResumeTitle('Test Resume Title');
            part.setYearsWithOtherFirms(10);
            part.setBio('Test Bio');
        }
    }

    //Create profile parts specifically for a user
    public static void createTestProfilePartForUserId(Id userId, String profilePartRecordType, Integer numParts) {
        List<rs_Profile_Part__c> parts = new List<rs_Profile_Part__c>();
        for(Integer i = 0; i < numParts; i++) {
            rsProfilePart currPart = new rsProfilePart(userId, profilePartRecordType);
            setProfilePartFieldsByRecordType(currPart,profilePartRecordType);
            currPart.getObj().put('Status__c',rsProfilePart.S_PENDING);
            parts.add((rs_Profile_Part__c)currPart.getObj());
        }
        insert parts;
    }


    //Create project parts specifically for a user
    public static List<rsPRTeamEmployee> createTestProjectPartForUserId(Id userId, String projectRecordType, Integer numProjects) {
        List<PR_Team_Employee__c> projs = new List<PR_Team_Employee__c>();
        List<rsPRTeamEmployee> projDec = new List<rsPRTeamEmployee>();
        for(Integer i = 0; i < numProjects; i++) {
            rsPRTeamEmployee currProject = new rsPRTeamEmployee(userId, projectRecordType);
            currProject.setProjectNameEditable('Test Project Name');
            currProject.setDateInvolvementStarted('09/10/11');
            currProject.setDateInvolvementEnded('01/02/13');
            currProject.setProjectRole('This is a test role');
            currProject.setRoleDescription('This is a test description of my test role');
            currProject.setClientNameEditable('Test Client Name');
            currProject.setProjectGroup('Test Project Group');
            currProject.setLocationCountryEditable('Test Location Country');
            currProject.setLocationCityEditable('Test Location City');
            currProject.setOutputOnResume(true);
            currProject.setProjectGroup('Test Project Group');
            currProject.setGroupSequence(0);
            currProject.setProjectSequence(i);
            currProject.setStatus(rsPRTeamEmployee.S_PENDING);
            projDec.add(currProject);
            projs.add((PR_Team_Employee__c)currProject.getObj());
        }
        insert projs;
        return projDec;
    }


    public static rs_Search__c basicSearch() {
        rs_Search__c savedSearch = new rs_Search__c(Name='BasicSearch');
        savedSearch.Search_Fields__c = '[ {"value" : "%test%","operator" : "LIKE","field" : "Publication_Title__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Translate_From__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Language_Level__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Specialty__c"}, {"value" : "%test%","operator" : "LIKE","field" : "License_Registration_Name__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Degree__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Skill__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Company_Name__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Country__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Award_Title__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Skill_Level__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Job_Title__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Vendor__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Language_Skill__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Degree_Specialty__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Skill_Area__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Work_History_Country__c"}, {"value" : "%test%","operator" : "LIKE","field" : "SF254_Discipline__c"}, {"value" : "%test%","operator" : "LIKE","field" : "State_Province__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Publication__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Award_Agency__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Certification_Description__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Registration_Number__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Language__c"}, {"value" : "%test%","operator" : "LIKE","field" : "SF330_Discipline__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Skill_Language__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Institution__c"}, {"value" : "%test%","operator" : "LIKE","field" : "State__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Name"}, {"value" : "%test%","operator" : "LIKE","field" : "Training_Name__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Publication_Author__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Association_Name__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Position__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Certification_Title__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Name__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Institution_Country__c"}, {"value" : "%test%","operator" : "LIKE","field" : "City__c"}, {"value" : "%test%","operator" : "LIKE","field" : "Translate_To__c"}]';
        savedSearch.Result_Fields__c = '[]';
        savedSearch.User_Fields__c = '{' +
                                    '"firstName" : {' +
                                    '"value" : "%%",' +
                                    '"operator" : " LIKE ",' +
                                    '"field" : "FirstName"' +
                                    '},' +
                                    '"active" : {' +
                                    '"value" : "false",' +
                                    '"operator" : "=",' +
                                    '"field" : "IsActive"' +
                                    '},' +
                                    '"lastName" : {' +
                                    '"value" : "%%",' +
                                    '"operator" : " LIKE ",' +
                                    '"field" : "LastName"' +
                                    '}' +
                                    '}';
        savedSearch.PR_Team_Employee_Fields__c = '[]';
        savedSearch.Search_Type__c = 'Basic';
        savedSearch.User__c = UserInfo.getUserId();
        insert savedSearch;
        return savedSearch;
    }

    public static rs_Search__c advancedSearch() {
        rs_Search__c savedSearch = new rs_Search__c(Name='AdvancedSearch');
        savedSearch.Search_Fields__c = '[ {' +
                                        '"value" : "Sales",' +
                                        '"operator" : "c",' +
                                        '"field" : "rs_Profile_Part__c|Certification_Description__c"' +
                                        '}, {' +
                                        '"value" : "Micro",' +
                                        '"operator" : "c",' +
                                        '"field" : "rs_Profile_Part__c|Company_Name__c"' +
                                        '}, {' +
                                        '"value" : "asss",' +
                                        '"operator" : "c",' +
                                        '"field" : "rs_Profile_Part__c|Degree__c"' +
                                        '}, {' +
                                        '"value" : "",' +
                                        '"operator" : "",' +
                                        '"field" : ""' +
                                        '}, {' +
                                        '"value" : "",' +
                                        '"operator" : "",' +
                                        '"field" : ""' +
                                        '}, {' +
                                        '"value" : "",' +
                                        '"operator" : "",' +
                                        '"field" : ""' +
                                        '} ]' ;
        savedSearch.Result_Fields__c = '[]';
        savedSearch.User_Fields__c = '{' +
                                    '"firstName" : {' +
                                    '"value" : "%%",' +
                                    '"operator" : " LIKE ",' +
                                    '"field" : "FirstName"' +
                                    '},' +
                                    '"active" : {' +
                                    '"value" : "false",' +
                                    '"operator" : "=",' +
                                    '"field" : "IsActive"' +
                                    '},' +
                                    '"lastName" : {' +
                                    '"value" : "%%",' +
                                    '"operator" : " LIKE ",' +
                                    '"field" : "LastName"' +
                                    '}' +
                                    '}';
        savedSearch.PR_Team_Employee_Fields__c = '[]';
        savedSearch.Search_Type__c = 'Advanced';
        savedSearch.Filter_Logic__c = '1 OR 2 OR 3';
        savedSearch.User__c = UserInfo.getUserId();
        insert savedSearch;
        return savedSearch;
    }

    public static List<User> createTestUsers(Boolean isCM, Integer numUsers) {
        Profile adminProfile = [Select Id, Name from Profile where Name = 'System Administrator'];
        if (isCM) {
            Profile_Info__c testProfInfo = new Profile_Info__c();
            testProfInfo.SetupOwnerId = adminProfile.Id;
            testProfInfo.Is_Content_Manager__c = true;
            insert testProfInfo;
        }

        List<User> userList = new List<User>();
        for (Integer i = 0; i < numUsers; i++) {
            
            Integer rand = Math.round(Math.random()*10000);
            
            User tempUser = new User();
            tempUser.FirstName = 'test';
            tempUser.LastName = 'lastName' + String.ValueOf(userCount + i);
            tempUser.Alias = 'test'+String.ValueOf(userCount + i);
            tempUser.Email = 'SFDCTestCase' + String.ValueOf(userCount + i) + '@consultant.aecom.com';
            tempUser.Username ='rMaG2470@test.com'+String.ValueOf(userCount + i)+rand;
            tempUser.CommunityNickname = 'testNick'+String.ValueOf(userCount + i);
            tempUser.ProfileId = adminProfile.Id;
            tempUser.EmailEncodingKey='UTF-8';
            tempUser.LanguageLocaleKey='en_US';
            tempUser.LocaleSidKey='en_US';
            tempUser.TimeZoneSidKey='America/Los_Angeles';
            tempUser.Status__c = rsProfile.S_PENDING;
            tempUser.IsActive = true;
            tempUser.AboutMe = 'test test test';
            tempUser.Bio__c = 'test';
            tempUser.Geography__c = '0xDEADBEEF';
            tempUser.Supergeography__c = 'Americas';
            userList.add(tempUser);
        }
        userCount += numUsers;
        insert userList;
        return userList;
    }

    public static List<User> createTestUsers(Boolean isCM, Integer numUsers, Id managerId) {
        Profile adminProfile = [Select Id, Name from Profile where Name = 'System Administrator'];
        if (isCM) {
            Profile_Info__c testProfInfo = new Profile_Info__c();
            testProfInfo.SetupOwnerId = adminProfile.Id;
            testProfInfo.Is_Content_Manager__c = true;
            insert testProfInfo;
        }

        List<User> userList = new List<User>();
        for (Integer i = 0; i < numUsers; i++) {
            
            Integer rand = Math.round(Math.random()*10000);
            
            User tempUser = new User();
            tempUser.FirstName = 'test';
            tempUser.LastName = 'lastName' + String.ValueOf(userCount + i);
            tempUser.Alias = 'test'+String.ValueOf(userCount + i);
            tempUser.Email = 'SFDCTestCase' + String.ValueOf(userCount + i) + '@consultant.aecom.com';
            tempUser.Username ='rMaG2470@test.com'+String.ValueOf(userCount + i)+rand;
            tempUser.CommunityNickname = 'testNick'+String.ValueOf(userCount + i);
            tempUser.ProfileId = adminProfile.Id;
            tempUser.EmailEncodingKey='UTF-8';
            tempUser.LanguageLocaleKey='en_US';
            tempUser.LocaleSidKey='en_US';
            tempUser.TimeZoneSidKey='America/Los_Angeles';
            tempUser.Status__c = rsProfile.S_PENDING;
            tempUser.IsActive = true;
            tempUser.AboutMe = 'test test test';
            tempUser.Bio__c = 'test';
            tempUser.Geography__c = '0xDEADBEEF';
            tempUser.Supergeography__c = 'Americas';
            tempUser.ManagerId = managerId;
            userList.add(tempUser);
        }
        userCount += numUsers;
        insert userList;
        return userList;
    }
    public static List<User> createTestUsers(Boolean isCM) {
        return createTestUsers(isCM, 1);
    }

    public static List<User> createReadOnlyTestUsers(Boolean isRO, Integer numUsers) {
        Profile adminProfile = [Select Id, Name from Profile where Name = 'System Administrator'];
        if (isRO) {
            Profile_Info__c testProfInfo = new Profile_Info__c();
            testProfInfo.SetupOwnerId = adminProfile.Id;
            testProfInfo.Is_Read_Only__c = true;
            insert testProfInfo;
        }

        List<User> userList = new List<User>();
        for (Integer i = 0; i < numUsers; i++) {
            
            Integer rand = Math.round(Math.random()*10000);
            
            User tempUser = new User();
            tempUser.FirstName = 'test';
            tempUser.LastName = 'lastName' + String.ValueOf(userCount + i);
            tempUser.Alias = 'test'+String.ValueOf(userCount + i);
            tempUser.Email = 'SFDCTestCase' + String.ValueOf(userCount + i) + '@consultant.aecom.com';
            tempUser.Username ='rMaG2470@test.com'+String.ValueOf(userCount + i)+rand;
            tempUser.CommunityNickname = 'testNick'+String.ValueOf(userCount + i);
            tempUser.ProfileId = adminProfile.Id;
            tempUser.EmailEncodingKey='UTF-8';
            tempUser.LanguageLocaleKey='en_US';
            tempUser.LocaleSidKey='en_US';
            tempUser.TimeZoneSidKey='America/Los_Angeles';
            tempUser.Status__c = rsProfile.S_PENDING;
            tempUser.IsActive = true;
            tempUser.AboutMe = 'test test test';
            tempUser.Bio__c = 'test';
            tempUser.Geography__c = '0xDEADBEEF';
            tempUser.Supergeography__c = 'Americas';
            userList.add(tempUser);
        }
        userCount += numUsers;
        insert userList;
        return userList;
    }

    public static List<User> createReadOnlyTestUsers(Boolean isRO) {
        return createReadOnlyTestUsers(isRO,1);
    }

    public static void setupResumeAreaPoints() {
        delete [Select Id from rs_Resume_Area_Points__c];
        List<rs_Resume_Area_Points__c> rtTypes = new List<rs_Resume_Area_Points__c>();
        rs_Resume_Area_Points__c award;
        rs_Resume_Area_Points__c certi;
        rs_Resume_Area_Points__c assoc;
        rs_Resume_Area_Points__c educa;
        rs_Resume_Area_Points__c langs;
        rs_Resume_Area_Points__c publi;
        rs_Resume_Area_Points__c regis;
        rs_Resume_Area_Points__c skill;
        rs_Resume_Area_Points__c train;
        rs_Resume_Area_Points__c trans;
        rs_Resume_Area_Points__c workh;
        rs_Resume_Area_Points__c persl;
        rs_Resume_Area_Points__c refer;
        rs_Resume_Area_Points__c aecom;
        rs_Resume_Area_Points__c naeco;
        if(rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_AWARD) == null) {
            award = new rs_Resume_Area_Points__c(Name=rsProfilePart.RT_AWARD,Total__c=1);
        } else {
            award = rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_AWARD);
            award.Total__c = 1;
        }
        if(rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_CERTIFICATION) == null) {
            certi = new rs_Resume_Area_Points__c(Name=rsProfilePart.RT_CERTIFICATION,Total__c=1);
        } else {
            certi = rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_CERTIFICATION);
            certi.Total__c = 1;
        }
        if(rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_PROF_AFFILIATION) == null) {
            assoc = new rs_Resume_Area_Points__c(Name=rsProfilePart.RT_PROF_AFFILIATION,Total__c=1);
        } else {
            assoc = rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_PROF_AFFILIATION);
            assoc.Total__c = 1;
        }
        if (rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_EDUCATION) == null) {
            educa = new rs_Resume_Area_Points__c(Name=rsProfilePart.RT_EDUCATION,Total__c=1);
        } else {
            educa = rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_EDUCATION);
            educa.Total__c = 1;
        }
        if (rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_LANGUAGES) == null) {
            langs = new rs_Resume_Area_Points__c(Name=rsProfilePart.RT_LANGUAGES,Total__c=1);
        } else {
            langs = rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_LANGUAGES);
            langs.Total__c = 1;
        }
        if (rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_PUBLICATION) == null) {
            publi = new rs_Resume_Area_Points__c(Name=rsProfilePart.RT_PUBLICATION,Total__c=1);
        } else {
            publi = rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_PUBLICATION);
            publi.Total__c = 1;
        }
        if (rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_REGISTRATION) == null) {
            regis = new rs_Resume_Area_Points__c(Name=rsProfilePart.RT_REGISTRATION,Total__c=1);
        } else {
            regis = rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_REGISTRATION);
            regis.Total__c = 1;
        }
        if (rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_SKILL_INDEX) == null) {
            skill = new rs_Resume_Area_Points__c(Name=rsProfilePart.RT_SKILL_INDEX,Total__c=1);
        } else {
            skill = rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_SKILL_INDEX);
            skill.Total__c = 1;
        }
        if (rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_TRAINING) == null) {
            train = new rs_Resume_Area_Points__c(Name=rsProfilePart.RT_TRAINING,Total__c=1);
        } else {
            train = rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_TRAINING);
            train.Total__c = 1;
        }
        if (rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_TRANSLATIONS) == null) {
            trans = new rs_Resume_Area_Points__c(Name=rsProfilePart.RT_TRANSLATIONS,Total__c=1);
        } else {
            trans = rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_TRANSLATIONS);
            trans.Total__c = 1;
        }
        if (rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_WORK_HISTORY) == null) {
            workh = new rs_Resume_Area_Points__c(Name=rsProfilePart.RT_WORK_HISTORY,Total__c=1);
        } else {
            workh = rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_WORK_HISTORY);
            workh.Total__c = 1;
        }
        if (rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_PERSONAL) == null) {
            persl = new rs_Resume_Area_Points__c(Name=rsProfilePart.RT_PERSONAL,Total__c=1);
        } else {
            persl = rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_PERSONAL);
            persl.Total__c = 1;
        }
        if (rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_REFERENCE) == null) {
            refer = new rs_Resume_Area_Points__c(Name=rsProfilePart.RT_REFERENCE,Total__c=1);
        } else {
            refer = rs_Resume_Area_Points__c.getValues(rsProfilePart.RT_REFERENCE);
            refer.Total__c = 1;
        }
        if (rs_Resume_Area_Points__c.getValues(rsPRTeamEmployee.RT_AECOMPROJECT) == null) {
            aecom = new rs_Resume_Area_Points__c(Name=rsPRTeamEmployee.RT_AECOMPROJECT,Total__c=1);
        } else {
            aecom = rs_Resume_Area_Points__c.getValues(rsPRTeamEmployee.RT_AECOMPROJECT);
            aecom.Total__c = 1;
        }
        if (rs_Resume_Area_Points__c.getValues(rsPRTeamEmployee.RT_NONAECOMPROJECT) == null) {
            naeco = new rs_Resume_Area_Points__c(Name=rsPRTeamEmployee.RT_NONAECOMPROJECT,Total__c=1);
        } else {
            naeco = rs_Resume_Area_Points__c.getValues(rsPRTeamEmployee.RT_NONAECOMPROJECT);
            naeco.Total__c = 1;
        }

        rtTypes.add(award);
        rtTypes.add(certi);
        rtTypes.add(assoc);
        rtTypes.add(educa);
        rtTypes.add(langs);
        rtTypes.add(publi);
        rtTypes.add(regis);
        rtTypes.add(skill);
        rtTypes.add(train);
        rtTypes.add(trans);
        rtTypes.add(workh);
        rtTypes.add(persl);
        rtTypes.add(refer);
        rtTypes.add(aecom);
        rtTypes.add(naeco);

        upsert rtTypes;
    }
}