public with sharing class ECO_PackageTriggerHelper {
    public ECO_PackageTriggerHelper() {
        
    }
    
    public static void setChangeManagerIsChanged(map<Id, Packages__c> oldMap, list<Packages__c> updatedScope)
    {
        if(UserInfo.getUserName().toLowerCase().contains('integration@aecom.com'))
            return;
        
        for(Packages__c scope:updatedScope)
            if(!oldMap.get(scope.Id).ChangeManagerIsChanged__c)
                scope.ChangeManagerIsChanged__c = true;     
    }

    public static void attachHealthStart(list<Packages__c> newList, map<id, Packages__c> oldMap){
        
        list<ProjectReviewTemplate__c> lstPRT = [select id from ProjectReviewTemplate__c where TemplateType__c = 'BIM Healthy Start'];
        //The following line was commented out and replaced per US-06951
        //id RTid = Schema.Sobjecttype.ProjectReview__c.getRecordTypeInfosByName().get('BIM Healthy Start').getRecordTypeId();
        id RTid = ECO_Utils_Meta.getRecordTypeId(ProjectReview__c.sObjectType,'BIMHealthyStart');

        list<ProjectReview__c> prToInsert = new list<ProjectReview__c>();

        for(Packages__c p: newList){
            if(p.Utilize_BMI_Technology__c && (oldMap == null || p.Utilize_BMI_Technology__c != oldMap.get(p.id).Utilize_BMI_Technology__c)){

                if(lstPRT.size() == 0){
                    p.adderror('Cannot find BIM Healthy Start/Restart Project Review Template to create BIM Project Review');
                    return;
                }

                ProjectReview__c newPR = new ProjectReview__c();
                newPR.name = 'BIM Healthy Start Review';
                newPR.Project__c = p.Scope__c;
                newPR.ProjectReviewTemplate__c = lstPRT[0].id;
                newPR.recordtypeid = RTid;
                prToInsert.add(newPR);
            }

        }

        try{
            insert prToInsert;
        } catch (Exception e) {
            newList[0].adderror('Error while trying to insert BIM Healthy Start review');
            return;
        }     

    }
}