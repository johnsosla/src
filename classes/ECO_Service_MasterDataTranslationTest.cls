@isTest
private class ECO_Service_MasterDataTranslationTest {
	public static testMethod void testMasterDataTranslation(){
		String sTranslatedField;
        Test.startTest();
        sTranslatedField = ECO_Service_MasterDataTranslation.translatedField ('ProjectRole__c', 'Name');
        sTranslatedField = ECO_Service_MasterDataTranslation.translatedField ('TemplateQuestion', 'RiskTitle__c');
        Test.stopTest();
        
        System.assert(sTranslatedField != null);
	}
}