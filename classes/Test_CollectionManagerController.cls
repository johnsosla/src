/*******************************************************************
  Name        :   Test_CollectionManagerController
  Author      :   Appirio Off
  Version     :   1.0 
  Purpose     :   Test Class for CollectionManagerController Class
  Date        :   10/12/2011 
********************************************************************/
@isTest
private class Test_CollectionManagerController {
    static testMethod void TestCollectionManager(){
        
        Business_Line__c BL = new Business_Line__c(Name='BL1');
        insert BL;
        Geography__c Geog = new Geography__c(Name='Geog1');
        insert Geog;
        Practice_Area__c Practice_Area = new Practice_Area__c(Name='BL1');
        insert Practice_Area;
        Sub_Practice_Area__c SpA= new Sub_Practice_Area__c(Name='BL1');
        insert Spa;
        Practice_Area_Collection__c PAC= new Practice_Area_Collection__c(Business_Line__c=BL.id,
                                                                        geography__c=Geog.Id,
                                                                        Practice_Area__c = Practice_Area.Id,
                                                                        Sub_Practice_Area__c=SPA.ID);
        insert PAC;
        CollectionManagerController controller = new CollectionManagerController();
        controller.filterRec.Business_Line__c = bl.id;
        controller.filterRec.Geography__c = geog.id;
        controller.filterRec.Practice_Area__c = Practice_Area.id;
        controller.filterRec.Sub_Practice_Area__c=spa.id;
        controller.Filter();
        controller.DeleteSelected();
        controller.NewcollectionList[0].rec.Business_Line__c=BL.id;
        controller.NewcollectionList[0].rec.geography__c=Geog.Id;
        controller.NewcollectionList[0].rec.Practice_Area__c = Practice_Area.Id;
        controller.NewcollectionList[0].rec.Sub_Practice_Area__c=SPA.ID;
        controller.Save();
        //
        
        
    }
}