@isTest
private class rsSearchResultTest {

    @isTest static void testConstructor() {
        Test.startTest();
        rsSearchResult sResult = new rsSearchResult();
        Test.stopTest();

        System.assertEquals(false, sResult.Selected);
    }

    @isTest static void testConstructorWithUserAndProfilePart() {
        rsTestUtil.createTestProfileParts(1, 1);
        User tempUser = [Select Id, FirstName,SmallPhotoURL,Name,HR_Full_Name__c,LastName from User where LastName =: 'lastName0'];
        rs_Profile_Part__c part = [Select Vendor__c from rs_Profile_Part__c LIMIT 1];

        List<SelectOption> testOptions = new List<SelectOption>();
        testOptions.add(new SelectOption('User|FirstName','First Name'));
        testOptions.add(new SelectOption('User|Name','Name'));
        testOptions.add(new SelectOption('rs_Profile_Part__c|Vendor__c','Vendor'));
        testOptions.add(new SelectOption('rssrsrs|gibberish','rubbish'));

        Test.startTest();
        rsSearchResult sResult = new rsSearchResult(part,tempUser,testOptions);
        Test.stopTest();

        System.assertEquals(false, sResult.Selected);
        System.assertEquals(sResult.userName, 'lastName0, test');
        System.assertEquals(sResult.userId, tempUser.Id);
        System.assertEquals(sResult.cells.get(0),'test');
        System.assertEquals(sResult.cells.get(1),'DONTUSE');
        System.assertEquals(sResult.cells.get(2),'Training Vendor Test');
    }

    @isTest static void testConstructorWithUserAndPRTeam() {
        rsTestUtil.createTestProfileParts(1, 0, 5);
        User tempUser = [Select Id, FirstName,SmallPhotoURL,Name,HR_Full_Name__c,LastName from User where LastName =: 'lastName0'];
        PR_Team_Employee__c pr = [Select Project_Role__c from PR_Team_Employee__c LIMIT 1];

        List<SelectOption> testOptions = new List<SelectOption>();
        testOptions.add(new SelectOption('User|FirstName','First Name'));
        testOptions.add(new SelectOption('User|Name','Name'));
        testOptions.add(new SelectOption('PR_Team_Employee__c|Project_Role__c','Role Description'));
        testOptions.add(new SelectOption('rssrsrs|gibberish','rubbish'));

        System.debug('####' + pr.Project_Role__c);
        Test.startTest();
        rsSearchResult sResult = new rsSearchResult(pr,tempUser,testOptions);

        System.assertEquals(false, sResult.Selected);
        System.assertEquals(sResult.userName, 'lastName0, test');
        System.assertEquals(sResult.userId, tempUser.Id);
        System.assertEquals(sResult.cells.get(0),'test');
        System.assertEquals(sResult.cells.get(1),'DONTUSE');
        System.assertEquals(sResult.cells.get(2),'This is a test role');

    }

    @isTest static void testCompare() {
        rsTestUtil.createTestProfileParts(2, 1);
        User tempUser = [Select Id, FirstName,SmallPhotoURL,Name,HR_Full_Name__c,LastName from User where LastName =: 'lastName0'];
        tempUser.FirstName = 'zzzz';
        update tempUser;
        User tempUser2 = [Select Id, FirstName,SmallPhotoURL,Name,HR_Full_Name__c,LastName from User where LastName =: 'lastName1'];

        List<rs_Profile_Part__c> parts = [Select Vendor__c from rs_Profile_Part__c];

        List<SelectOption> testOptions = new List<SelectOption>();
        testOptions.add(new SelectOption('User|FirstName','First Name'));
        testOptions.add(new SelectOption('User|Name','Name'));
        testOptions.add(new SelectOption('rs_Profile_Part__c|Vendor__c','Vendor'));
        testOptions.add(new SelectOption('rssrsrs|gibberish','rubbish'));

        List<rsSearchResult> results = new List<rsSearchResult>();
        tempUser = [Select Id, FirstName,SmallPhotoURL,Name,HR_Full_Name__c,LastName from User where Id =: tempUser.Id];
        results.add(new rsSearchResult(parts.get(0),tempUser2,testOptions));
        results.add(new rsSearchResult(parts.get(1),tempUser,testOptions));

        Test.startTest();
        results.sort();
        Test.stopTest();

        System.assertEquals(tempUser.Id, results.get(0).userId);
        System.assertEquals(tempUser2.Id, results.get(1).userId);
    }


}