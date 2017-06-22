//public with sharing class ECO_DeliverableTriggers {
public class ECO_DeliverableTriggers {

    public static Boolean run = true;

    public ECO_DeliverableTriggers() {
        
    }

    public void attachRevision(list<Deliverable__c> listNew){

        if(!run){
            return;
        }
        
        list<DeliverableRevision__c> listRevisionToInsert = new list<DeliverableRevision__c>();

        for(Deliverable__c oDeliverable: listNew){
            listRevisionToInsert.add(new DeliverableRevision__c(name='Draft', Approver__c = oDeliverable.Approver__c, Deliverable__c = oDeliverable.id, RevisionDate__c = date.today(), RevisionNum__c=1 ));
        }
        
        Savepoint sp = Database.setSavepoint();
        try{
            insert listRevisionToInsert;
        }catch(Exception e){
            System.Debug(logginglevel.error,' error: ' + e.getMessage() + ' : ' + e.getStackTraceString());
            Database.rollback(sp);
            listNew[0].addError('Failure to create revision for deliverables');
        }       

    }
    
    public void setChangeManagerIsChanged(map<Id, Deliverable__c> oldMap, list<Deliverable__c> updatedDeliverables)
    {
        if(!run){
            return;
        }

        if(UserInfo.getUserName().toLowerCase().contains('integration@aecom.com'))
            return;

        for(Deliverable__c deliverable:updatedDeliverables)
            if(!oldMap.get(deliverable.Id).ChangeManagerIsChanged__c )
                deliverable.ChangeManagerIsChanged__c = true;
    }


    public void attachParentDeliverable(list<Deliverable__c> listNew){

        if(!run){
            return;
        }
        
        set<id> lstProjectID = new set<id>();
        map<id, Packages__c> mapProjectIDtoPackage = new map<id, Packages__c>();
        set<id> lstProjectIDsWithoutPackages = new set<id>();
        list<Deliverable__c> lstDeliverablesThatStillNeedPackages = new list<Deliverable__c>();

        for(Deliverable__c oDeliverable: listNew){
            if(oDeliverable.Project_Scope__c==null){
                lstProjectID.add(oDeliverable.Project__c);
            }
        }

        list<Packages__c> lstSearch = [select id, Scope__c from Packages__c where Type__c = 'Project' AND Scope__c IN: lstProjectID];

        for(Packages__c oPackage: lstSearch){
            mapProjectIDtoPackage.put(oPackage.Scope__c, oPackage);
        }

        for(Deliverable__c oDeliverable: listNew){
            if( (oDeliverable.Project_Scope__c==null) && mapProjectIDtoPackage.containsKey(oDeliverable.Project__c) ){
                oDeliverable.Project_Scope__c = mapProjectIDtoPackage.get(oDeliverable.Project__c).id;
            } else {
                lstProjectIDsWithoutPackages.add(oDeliverable.Project__c);
                lstDeliverablesThatStillNeedPackages.add(oDeliverable);
            }
        }

        map<id, Packages__c> mapProjectIDtoNewPackages = new map<id, Packages__c>();

        for(id projectID: lstProjectIDsWithoutPackages){
            mapProjectIDtoNewPackages.put(projectID, new Packages__c( PackageTitle__c = 'Project Scope', Status__c = 'Draft', Scope__c = projectID, Type__c = 'Project' ));
        }

        Savepoint sp = Database.setSavepoint();

        try{
            insert mapProjectIDtoNewPackages.Values();
        }catch(Exception e){
            System.Debug(logginglevel.error,' error: ' + e.getMessage() + ' : ' + e.getStackTraceString());
            Database.rollback(sp);
            listNew[0].addError('Failure to create packages for deliverables without packages');
        }

        for(Deliverable__c oDeliverable :lstDeliverablesThatStillNeedPackages){
            oDeliverable.Project_Scope__c = mapProjectIDtoNewPackages.get(oDeliverable.Project__c).id;
        }

    }



    public void autoApprove(map<id,Deliverable__c> mapOld,map<id,Deliverable__c> mapNew){

        if(!run){
            return;
        }

        set<ID> setDevsToApprove = new set<ID>();

        for(Deliverable__c oDeliverable : mapNew.Values()){
            if(oDeliverable.PercentApproved__c == 100){
                if(mapOld.get(oDeliverable.ID).PercentApproved__c != 100){
                    setDevsToApprove.add(oDeliverable.ID);
                }
            }
        }
        if(setDevsToApprove != null && setDevsToApprove.size() > 0){
            ECO_Service_Deliverable.submitApprovalforDeliverables(setDevsToApprove);
        }

    }

    public void createInitialTechnicalQualityTeamMember(list<Deliverable__c> listNew){

        if(!run){
            return;
        }

        //System.Debug(logginglevel.error,'Starting the process to add pm to team.');
        list<ProjectTeamMember__c> ListTeam = new list<ProjectTeamMember__c>();
        map<id,id> mapProjectIdByDeliverable = new map<id,id>();
        map<id,set<Deliverable__c>> mapDeliverablebyProject = new map<id,set<Deliverable__c>>();
        set<Deliverable__c> setDevs = new set<Deliverable__c>();
        
        for(Deliverable__c oDeliverable: listNew){
            mapProjectIdByDeliverable.put(oDeliverable.id,oDeliverable.Project__c);
            if(mapDeliverableByProject.containsKey(oDeliverable.Project__c)){
                setDevs = mapDeliverableByProject.get(oDeliverable.Project__c);
            }else{
                setDevs = new set<Deliverable__c>();
            } 
            setDevs.Add(oDeliverable);
            mapDeliverablebyProject.put(oDeliverable.Project__c,setDevs);
        }
        //System.Debug(logginglevel.error,'mapDeliverablebyProject: ' + mapDeliverablebyProject);
        set<id> setProjects = new set<id>();
        setProjects.addAll(mapProjectIdByDeliverable.Values());
        
        list<pse__Proj__c> listProjects = ECO_Service_Projects.getProjectByIDs(setProjects);
        
        list<TechnicalQualityTeam__c> lAddMembers = new list<TechnicalQualityTeam__c>();
        List<ProjectTeamMember__c> lProjectTeam = new List<ProjectTeamMember__c>();

        //System.Debug(logginglevel.error,'ListProjects: ' + listProjects);
        set<id> setContactID = new set<id>();
        
        for(pse__Proj__c oProject : listProjects){
            setContactID.add(oProject.pse__Project_Manager__c);
        }

        map<id,id> mapUserIdByContact = new map<id,id>();

        for(Contact c: [select ID, pse__Salesforce_User__c from Contact where id =: setContactID]){
            mapUserIdByContact.put(c.id,c.pse__Salesforce_User__c);
        }

        ProjectRole__c role = [Select Id, Name From ProjectRole__c Where Name = 'Deliverable Approver'];
        ProjectTeamMember__c[] lPTM = [Select Id, Contact__c, Project__c From ProjectTeamMember__c Where Contact__c IN :mapUserIdByContact.keySet() AND Project__c IN :listProjects AND ProjectRole__c = :role.Id];

        Set <String> ptmCombi = new Set<String>();

        for(ProjectTeamMember__c oPTM :  lPTM){
            ptmCombi.add(oPTM.Project__c+'-'+oPTM.Contact__c);
        }

        
        for(pse__Proj__c oProject : listProjects){
           //System.Debug(logginglevel.error,'oProject: ' + oProject);
           if(oProject.pse__Project_Manager__c != null){
                for(Deliverable__c oDev : mapDeliverableByProject.get(oProject.Id)){
                    //System.Debug(logginglevel.error,'adding member: ');
                    lAddMembers.add(New TechnicalQualityTeam__c(Role__c = 'Deliverable Approver',
                                                            TechnicalQualityTeamMember__c = mapUserIdByContact.get(oProject.pse__Project_Manager__c),
                                                            RequiredDate__c = System.Today(),
                                                            Deliverable__c = oDev.ID));
                    //System.debug('oDev.Project__c+ mapUserIdByContact.get(oProject.pse__Project_Manager__c)::'+oDev.Project__c + '-' + mapUserIdByContact.get(oProject.pse__Project_Manager__c));
                    if( (ptmCombi == null || !ptmCombi.contains(oDev.Project__c + '-' + oProject.pse__Project_Manager__c)) 
                            && oProject.pse__Project_Manager__c != null){
                        
                        lProjectTeam.add(new ProjectTeamMember__c(Project__c = oDev.Project__c,
                                                                    Contact__c = oProject.pse__Project_Manager__c,
                                                                    ProjectRole__c = role.Id,
                                                                    RecordTypeID = ECO_Utils_Meta.getRecordTypeId(ProjectTeamMember__c.sObjectType,'TeamMember')));
                    }
                }

                
            }
        }
        
        if(lAddMembers != null && lAddMembers.size() > 0){
            Savepoint sp = Database.setSavepoint();
            try{
                insert lAddMembers;
            }catch(Exception e){
                System.Debug(logginglevel.error,' error: ' + e.getMessage() + ' : ' + e.getStackTraceString());
                Database.rollback(sp);
                
            }
        }

        if(lProjectTeam != null && lProjectTeam.size()>0){
            Savepoint sp = Database.setSavepoint();
            try{
                insert lProjectTeam;
            }catch(Exception e){
                System.Debug(logginglevel.error,' error: ' + e.getMessage() + ' : ' + e.getStackTraceString());
                Database.rollback(sp);
                
            }
        }

    }
    
    public void createDeliverableOwnerTeamMember(map<id,Deliverable__c> mapOld, map<id,Deliverable__c> mapNew){
        if(!run){
            return;
        }
        list<ProjectTeamMember__c> ListTeam = new list<ProjectTeamMember__c>();
        map<id,id> mapProjectIdByDeliverable = new map<id,id>();
        map<id,set<Deliverable__c>> mapDeliverablebyProject = new map<id,set<Deliverable__c>>();
        set<Deliverable__c> setDevs = new set<Deliverable__c>();
        set<id> setContactID = new set<id>();
        Boolean proceed = false;
        Id devOwner = null;
        list<ProjectTeamMember__c> lAddTeamMembers = new list<ProjectTeamMember__c>();
        list<ProjectTeamMember__c> lUpdateTeamMembers = new list<ProjectTeamMember__c>();
        list<TechnicalQualityTeam__c> lUpdateMembers = new list<TechnicalQualityTeam__c>();
        list<TechnicalQualityTeam__c> lAddMembers = new list<TechnicalQualityTeam__c>();
        
        for(Deliverable__c oDeliverable: mapNew.values()){
            
            if((oDeliverable.DeliverablesOwner__c != null || oDeliverable.DeliverablesOwner__c != '')
               && mapOld.get(oDeliverable.Id).DeliverablesOwner__c != oDeliverable.DeliverablesOwner__c ){
                proceed = true;
                mapProjectIdByDeliverable.put(oDeliverable.id,oDeliverable.Project__c);
                setContactID.add(oDeliverable.DeliverablesOwner__c);
                if(mapDeliverableByProject.containsKey(oDeliverable.Project__c)){
                    setDevs = mapDeliverableByProject.get(oDeliverable.Project__c);
                }else{
                    setDevs = new set<Deliverable__c>();
                } 
                setDevs.Add(oDeliverable);
                mapDeliverablebyProject.put(oDeliverable.Project__c,setDevs);
            }
        }
        if(proceed){
            set<id> setProjects = new set<id>();
            map<String, ProjectTeamMember__c> mAllPTMs = new map<String,ProjectTeamMember__c>();
            setProjects.addAll(mapProjectIdByDeliverable.Values());
            list<pse__Proj__c> listProjects = new List<pse__Proj__c> ( ECO_Service_Projects.getProjectByIDs(setProjects));  
            map<id,id> mapUserIdByContact = new map<id,id>();
            for(Contact c: [select ID, pse__Salesforce_User__c from Contact where id =: setContactID]){
                mapUserIdByContact.put(c.id,c.pse__Salesforce_User__c);
            }
            ProjectRole__c role = [Select Id, Name From ProjectRole__c Where Name = 'Deliverable Originator'];
            for(Deliverable__c oDev : mapNew.values()){
                devOwner = oDev.DeliverablesOwner__c;
                if(devOwner != null || devOwner != ''){
                   ProjectTeamMember__c[] pTM = [Select Id, Contact__c From ProjectTeamMember__c Where Contact__c = :mapOld.get(oDev.Id).DeliverablesOwner__c AND Project__c = :oDev.Project__c AND ProjectRole__c = :role.Id];
                   TechnicalQualityTeam__c[] tqt = [Select Id, TechnicalQualityTeamMember__c From TechnicalQualityTeam__c Where Deliverable__c = :oDev.ID AND Role__c = 'Deliverable Originator'];
                   
                   //Commented for US-06512
                   /*lAddMembers.add(New TechnicalQualityTeam__c(Role__c = 'Deliverable Originator',
                                                                   //TechnicalQualityTeamMember__c = oDev.DeliverablesOwner__c,
                                                                   TechnicalQualityTeamMember__c = mapUserIdByContact.get(oDev.DeliverablesOwner__c),
                                                                   RequiredDate__c = System.Today(),
                                                                   Deliverable__c = oDev.ID));
                    if(tqt.size() > 0){
                        for(TechnicalQualityTeam__c oTQT : tqt){
                           oTQT.Role__c = 'Inactive Deliverable Owner';
                           
                           lUpdateMembers.add(oTQT);
                        }
                    }*/
                       
                    lAddTeamMembers.add(new ProjectTeamMember__c(Project__c = oDev.Project__c,
                                                                    Contact__c = oDev.DeliverablesOwner__c,
                                                                    ProjectRole__c = role.Id,
                                                                    RecordTypeID = ECO_Utils_Meta.getRecordTypeId(ProjectTeamMember__c.sObjectType,'TeamMember')));
                   
                    if(pTM.size() >= 0){
                        for(ProjectTeamMember__c oPTM : pTM){
                           oPTM.EndDate__c = Date.today();
                           oPTM.Is_Active__c = false;
                           lUpdateTeamMembers.add(oPTM);
                        }
                   }
                       
               }    
            }
           
            Savepoint sp = Database.setSavepoint();
            try{
                /*if(lAddMembers != null && lAddMembers.size() > 0)
                    insert lAddMembers;*/
                if(lAddTeamMembers != null && lAddTeamMembers.size() > 0)
                    insert lAddTeamMembers;
                if(lUpdateTeamMembers != null && lUpdateTeamMembers.size()>0)
                    update lUpdateTeamMembers;
                /*if(lUpdateMembers != null && lUpdateMembers.size()>0)
                    update lUpdateMembers;*/
            }catch(Exception e){
                System.Debug(logginglevel.error,' error: ' + e.getMessage() + ' : ' + e.getStackTraceString());
                Database.rollback(sp);
                
            }
            
    
        }
    }
    
}