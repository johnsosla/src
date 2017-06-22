/*******************************************************************************
*
* PURPOSE: Decorator for GFA_Library_Phase__c object
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
*******************************************************************************/
public with sharing class GFA_LibraryPhase extends GFA_BaseModel {

    public static Finder find = new Finder('GFA_Library_Phase__c');

    public GFA_Library_Phase__c obj {
        get {
            return (GFA_Library_Phase__c)mObj;
        }
    }

    public GFA_LibraryPhase() {
        this(new GFA_Library_Phase__c());
    }

    public GFA_LibraryPhase(GFA_Library_Phase__c libPhase) {
        super(libPhase);
    }

    public String getName() {
        return obj.Name;
    }
    public void setName(String Name) {
        obj.Name = Name;
    }

    public String getDescription() {
        return obj.Description__c;
    }
    public void setDescription(String description) {
        obj.Description__c = description;
    }

    public String getProjectSponsor() {
        return obj.Project_Sponsor__c;
    }
    public void setProjectSponsor(String ProjectSponsor) {
        obj.Project_Sponsor__c = ProjectSponsor;
    }

    public class Finder extends GFA_BaseFinder {

        public Finder(String sObjectName) {
            super(sObjectName);
        }

        public GFA_LibraryPhase findById(Id libPhaseId) {
            GFA_Library_Phase__c phase = (GFA_Library_Phase__c)byId(libPhaseId);
            return new GFA_LibraryPhase(phase);
        }

        /**
        * @param libPhaseIds, These are the Ids to exclude from the search
        * @return libPhases, all Library Phases that were not a part of libPhaseIds
        **/
        public List<GFA_LibraryPhase> findByNotInIds(Set<Id> libPhaseIds) {
            List<GFA_LibraryPhase> libPhases = new List<GFA_LibraryPhase>();
            for (GFA_Library_Phase__c phase : (List<GFA_Library_Phase__c>)Database.query(getSelect() +
                    ' where Id NOT IN: libPhaseIds ORDER BY Name ASC')) {
                libPhases.add(new GFA_LibraryPhase(phase));
            }
            return libPhases;
        }
    }
}