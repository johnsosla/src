@isTest
public class CFM_QualtricsImportPanelResponseTest {

    static testMethod void testParse() {
        String json = '{"Meta":{"Status":"Success","Debug":""},"Result":{"PanelID":"CG_cBiy32Uj0l7sIlv","Count":3,"IgnoredCount":-1,"Recipients":{"CreatedContacts":0,"UpdatedContacts":2,"FailedContacts":[]}}}';
        CFM_QualtricsImportPanelResponse obj = CFM_QualtricsImportPanelResponse.parse(json);
        System.assert(obj != null);
        System.assert(obj.Meta.Status == 'Success');
        System.assert(obj.Result.Count == 3);
    }

}