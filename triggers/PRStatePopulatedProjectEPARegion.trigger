trigger PRStatePopulatedProjectEPARegion on PRStateProvinceEmirates__c (after delete, after insert, after update) {

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

    List<Project__c> projects = [SELECT ID, Name, EPA_Region__c 
                                    , (SELECT ID, Project_StateProvEmirate__r.EPA_Region__c FROM PR_State_Countries__r)
                                    FROM Project__c WHERE ID IN :ProjectIds];
                                    
                                    
    for (Project__c proj : projects) {
        Set<String> EPARegions = new Set<String>();
        for (PRStateProvinceEmirates__c pr : proj.PR_State_Countries__r) {
            String epa = pr.Project_StateProvEmirate__r.EPA_Region__c;
            if (epa != null && epa.length() > 0) {
                EPARegions.add(epa);
            }
        }
        
        String epaString = '';
        for (String epa : EPARegions) {
            epaString += epa + ';';
        }
        
        proj.EPA_Region__c = epaString;
        
        
    }   
    
    update projects;                            
    */

}