@isTest
private class rsSkillIndexControllerTest {

    @isTest static void testController() {
        User u = [Select Id from User where Id =: UserInfo.getUserId()];
        rsProfile profile = new rsProfile(u);
        rsSkillIndexController cont = new rsSkillIndexController();
        cont.profile = profile;
        cont.newPart();
        cont.CurrentPart.setSkillArea('SkillArea');
        cont.CurrentPart.setSkill('Skill');
        cont.CurrentPart.setSkillLevel('SkillLevel');
        cont.CurrentPart.setSpecialty('Specialty');

        Test.startTest();
        PageReference pf = cont.savePart();
        Test.stopTest();

        rs_Profile_Part__c pp = [Select Skill_Area__c, Skill__c, Skill_Level__c, Specialty__c from rs_Profile_Part__c];
        System.assertEquals( null, pf );
        System.assertEquals( pp.Skill_Area__c, cont.CurrentPart.getSkillArea());
        System.assertEquals( pp.Skill__c, cont.CurrentPart.getSkill());
        System.assertEquals( pp.Skill_Level__c, cont.CurrentPart.getSkillLevel());
        System.assertEquals( pp.Specialty__c, cont.CurrentPart.getSpecialty());
    }

}