trigger PRStatePopulateFieldsSave on PRStateProvinceEmirates__c (after delete, after insert, after update) {
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

    List<Project__c> projects = [SELECT ID, Name, GSA_Region__c, EPA_Region__c, AECOM_Region__c, Project_Country__c, Project_StateProvinceEmirate__c  
                                    , (SELECT ID, Project_StateProvEmirate__r.GSA_Region__c, Project_StateProvEmirate__r.EPA_Region__c, Project_StateProvEmirate__r.Country__c, Project_StateProvEmirate__r.AECOM_Region__c, Project_StateProvEmirate__r.Name FROM PR_State_Countries__r)
                                    FROM Project__c WHERE ID IN :ProjectIds];
                                    
   //GSA Region                                 
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
    //EPA Region                                 
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
  //AECOM Region                                 
    for (Project__c proj : projects) {
        Set<String> AECOMRegions = new Set<String>();
        for (PRStateProvinceEmirates__c pr : proj.PR_State_Countries__r) {
            String aecom = pr.Project_StateProvEmirate__r.AECOM_Region__c;
            if (aecom != null && aecom.length() > 0) {
                AECOMRegions.add(aecom);
            }
        }
        
        String aecomString = '';
        for (String aecom : AECOMRegions) {
            aecomString += aecom + ';';
        }
        
        proj.AECOM_Region__c = aecomString;
        
        
    } 

 //Country                                
    for (Project__c proj : projects) {
        Set<String> CountryRegions = new Set<String>();
        for (PRStateProvinceEmirates__c pr : proj.PR_State_Countries__r) {
            String country = pr.Project_StateProvEmirate__r.Country__c;
            if (country != null && country.length() > 0) {
                CountryRegions.add(country);
            }
        }
        
        String countryString = '';
        for (String country : CountryRegions) {
            countryString += country + ';';
        }
        
        proj.Project_Country__c = countryString;
        
        
    } 
//State                                 
    for (Project__c proj : projects) {
        Set<String> stateRegions = new Set<String>();
        for (PRStateProvinceEmirates__c pr : proj.PR_State_Countries__r) {
            String state = pr.Project_StateProvEmirate__r.Name;
            if (state != null && state.length() > 0) {
                stateRegions.add(state);
            }
        }
        
        String StateString = '';
        for (String state : stateRegions) {
            stateString += state + ';';
        }
        
        proj.Project_StateProvinceEmirate__c = stateString;
        
        
    } 

     
    
    
    
    update projects;   
    */                         

}