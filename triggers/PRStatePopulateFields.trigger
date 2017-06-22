trigger PRStatePopulateFields on PRStateProvinceEmirates__c (after delete, after insert, after update) {
    
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
                                    , (SELECT ID, Project_StateProvEmirate__r.GSA_Region__c, Project_StateProvEmirate__r.EPA_Region__c, Project_StateProvEmirate__r.Country__c, Project_StateProvEmirate__r.AECOM_Region__c, Project_StateProvEmirate__r.Name, Project_StateProvEmirate__r.State__c, Project_StateProvEmirate__r.Project_Geography__c, Project_StateProvEmirate__r.Super__c FROM PR_State_Countries__r)
                                    FROM Project__c WHERE ID IN :ProjectIds];
                                    
   //GSA Region                                 
    for (Project__c proj : projects) {
        Set<String> GSARegions = new Set<String>();
        Set<String> EPARegions = new Set<String>();
        Set<String> AECOMRegions = new Set<String>();
        Set<String> CountryRegions = new Set<String>();
        Set<String> stateRegions = new Set<String>();
        Set<String> GeoRegions = new Set<String>();
        Set<String> SuperGeoRegions = new Set<String>();
        
        for (PRStateProvinceEmirates__c pr : proj.PR_State_Countries__r) {
            String gsa = pr.Project_StateProvEmirate__r.GSA_Region__c;
            if (gsa != null && gsa.length() > 0) {
                GSARegions.add(gsa);
            }
            //Epa region
            String epa = pr.Project_StateProvEmirate__r.EPA_Region__c;
            if (epa != null && epa.length() > 0) {
                EPARegions.add(epa);
            }
            //aecomRegion
           String aecom = pr.Project_StateProvEmirate__r.AECOM_Region__c;
            if (aecom != null && aecom.length() > 0) {
                AECOMRegions.add(aecom);
            }
            //country
            String country = pr.Project_StateProvEmirate__r.Country__c;
            if (country != null && country.length() > 0) {
                CountryRegions.add(country);
            }

            //state
            //String state = pr.Project_StateProvEmirate__r.Name;
            String state = pr.Project_StateProvEmirate__r.State__c;
            if (state != null && state.length() > 0) {
                stateRegions.add(state);
            }

            //geography
                          String Geo = pr.Project_StateProvEmirate__r.Project_Geography__c;
            if (Geo != null && Geo.length() > 0) {
                GeoRegions.add(Geo);
            }


            //supergeography
            
            String SuperGeog = pr.Project_StateProvEmirate__r.Super__c;
            if (SuperGeog != null && SuperGeog.length() > 0) {
                SuperGeoRegions.add(SuperGeog);
            }



        }
 
        
        
        //GSA
        String gsaString = '';
        for (String gsa : GSARegions) {
            gsaString += gsa + '; ';
        }
         if (gsaString.length() > 2) {
        
        gsaString = gsaString.substring(0,(gsaString.length() - 2));       
        }
        proj.GSA_Region__c = gsaString;
        
        //EPA
         String epaString = '';
        for (String epa : EPARegions) {
            epaString += epa + '; ';
        }
         if (epaString.length() > 2) {
        epaString = epaString.substring(0,(epaString.length() - 2)); 
        }
        proj.EPA_Region__c = epaString;
        
        //Aecom Region
       String aecomString = '';
        for (String aecom : AECOMRegions) {
            aecomString += aecom + '; ';
        }
         if (aecomString.length() > 2) {
        aecomString = aecomString.substring(0,(aecomString.length() - 2)); 
        }

        proj.AECOM_Region__c = aecomString;
        
        //country
        String countryString = '';
        for (String country : CountryRegions) {
            countryString += country + '; ';
        }
         if (countryString.length() > 2) {
        countryString = countryString.substring(0,(countryString.length() - 2)); 
        }   
        proj.Project_Country__c = countryString;       
      
        //state
        String StateString = '';
        for (String state : stateRegions) {
        stateString += state + '; ';
         }
        if (stateString.length() > 2) {
       stateString = stateString.substring(0,(stateString.length() - 2));
 } 
          proj.Project_StateProvinceEmirate__c = stateString; 
                    
        //geography
        
        String GeoString = '';
        for (String Geo : GeoRegions) {
            GeoString += Geo + '; ';
        }
         if (GeoString.length() > 2) {

        GeoString = GeoString.substring(0,(GeoString.length() - 2)); 
        }
        proj.Project_Geography__c = GeoString;        
         
          //SuperGeography
        String SuperGeoString = '';
        for (String SuperGeog : SuperGeoRegions) {
            SuperGeoString += SuperGeog + '; ';
        }
         if (SuperGeoString.length() > 2) {
         SuperGeoString = SuperGeoString.substring(0,(SuperGeoString.length() - 2)); 
         }
        proj.Project_Supergeography__c = SuperGeoString;  
         
    }   
        
    update projects;                            

}