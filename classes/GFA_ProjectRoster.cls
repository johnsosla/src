/*******************************************************************************
*
* PURPOSE: Decorator for GFA_Project_Roster__c object
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR:
*******************************************************************************/
public with sharing class GFA_ProjectRoster extends GFA_BaseModel {

    public static Finder find = new Finder('GFA_Project_Roster__c');

    public GFA_Project_Roster__c obj {
        get {
            return (GFA_Project_Roster__c)mObj;
        }
    }

    public GFA_ProjectRoster() {
        this(new GFA_Project_Roster__c());
    }

    public GFA_ProjectRoster(GFA_Project_Roster__c projectRoster) {
        super(projectRoster);
    }

    public String getName() {
        return obj.Name;
    }

    public Id getProjectId() {
        return obj.GFA_Project__c;
    }
    public void setProjectId(Id Project) {
        obj.GFA_Project__c = Project;
    }

    public String getRole() {
        return obj.Role__c;
    }
    public void setRole(String role) {
        obj.Role__c = role;
    }

    public Boolean getIsActingPM() {
        return obj.Is_Acting_Project_Manager__c;
    }

    public void setIsActingPM(Boolean isActingPM) {
        obj.Is_Acting_Project_Manager__c = isActingPM;
    }

    public String getTeamMemberUserId() {
        return obj.Team_Member_Name__r.User__c;
    }

    public Id getTeamMemberNameId() {
        return obj.Team_Member_Name__c;
    }
    public void setTeamMemberNameId(Id TeamMemberName) {
        obj.Team_Member_Name__c = TeamMemberName;
    }

    public String getTeamMemberEmail() {
        return obj.Team_Member_Name__r.Email;
    }

    public class Finder extends GFA_BaseFinder {

        public Finder(String sObjectName) {
            super(sObjectName);
            Set<String> additionalFields = new Set<String> {
                'Team_Member_Name__r.Email',
                'Team_Member_Name__r.Phone',
                'Team_Member_Name__r.User__c',
                'GFA_Project__r.Project_Name__c'
            };
            addFields(additionalFields);
        }

        public GFA_ProjectRoster findById(Id projRosterId) {
            GFA_Project_Roster__c projRoster = (GFA_Project_Roster__c)byId(projRosterId);
            return new GFA_ProjectRoster(projRoster);
        }

        public List<GFA_ProjectRoster> findByProjectId(Id projectId) {
            List<GFA_ProjectRoster> rosters = new List<GFA_ProjectRoster>();
            for (GFA_Project_Roster__c roster : (List<GFA_Project_Roster__c>)Database.query(
                        getSelect() + ' where GFA_Project__c =: projectId')) {
                rosters.add(new GFA_ProjectRoster(roster));
            }
            return rosters;
        }

        public Map<Id, List<GFA_ProjectRoster>> findByProjectIds(Set<Id> projectIds) {
            Map<Id, List<GFA_ProjectRoster>> rosterMap = new Map<Id, List<GFA_ProjectRoster>>();
            for (Id key : projectIds) {
                rosterMap.put(key, new List<GFA_ProjectRoster>());
            }
            for (GFA_Project_Roster__c roster : Database.query(getSelect() + ' where GFA_Project__c IN: projectIds')) {
                rosterMap.get(roster.GFA_Project__c).add(new GFA_ProjectRoster(roster));
            }
            return rosterMap;
        }
    }
}