@isTest
public class ECO_SiteControllerBaseTest {
    static testmethod void controllerTestMethod(){
        ECO_SiteControllerBase con = new ECO_SiteControllerBase();
        ECO_SiteControllerBase con1 = con.getThis();
        con.PrimarySelected();
        con.oProject = new pse__Proj__c();
    }
}