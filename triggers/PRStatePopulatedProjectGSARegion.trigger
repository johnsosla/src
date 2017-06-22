trigger PRStatePopulatedProjectGSARegion on PRStateProvinceEmirates__c (after delete, after insert, after update) {

    /*
    Set<ID> projectIds = new Set<ID>();
    
    if (Trigger.isDelete) {
        for (PRStateProvinceEmirates__c pr : Trigger.OLD) {
            projectIds.add(pr.ProjectRelated__c);
        }
    } else {
        for (PRStateProvinceEmirates__c pr : Trigger.NEW) {
            projectIds.add(pr.ProjectRelated__c);
        }
    }

    List<Project__c> projects = [SELECT ID, Name, GSA_Region__c 
                                    , (SELECT ID, Project_StateProvEmirate__r.GSA_Region__c FROM PR_State_Countries__r)
                                    FROM Project__c WHERE ID IN :ProjectIds];
                                    
                                    
    for (Project__c proj : projects) {
        Set<String> GSARegions = new Set<String>();
        for (PRStateProvinceEmirates__c pr : proj.PR_State_Countries__r) {
            String gsa = pr.Project_StateProvEmirate__r.GSA_Region__c;
            if (gsa != null && gsa.length() > 0) {
                GSARegions.add(gsa);
            }
        }
        
        String gsaString = '';
        for (String gsa : GSARegions) {
            gsaString += gsa + ';';
        }
        
        proj.GSA_Region__c = gsaString;
        
        
    }   
    
    update projects;    
    */                        

}