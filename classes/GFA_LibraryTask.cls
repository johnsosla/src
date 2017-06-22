/*******************************************************************************
*
* PURPOSE: Decorator for GFA_Library_Task__c object
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
*******************************************************************************/
public with sharing class GFA_LibraryTask extends GFA_BaseModel {

    public static Finder find = new Finder('GFA_Library_Task__c');

    public GFA_Library_Task__c obj {
        get {
            return (GFA_Library_Task__c)mObj;
        }
    }

    public GFA_LibraryTask() {
        this(new GFA_Library_Task__c());
    }

    public GFA_LibraryTask(GFA_Library_Task__c libTask) {
        super(libTask);
    }

    public String getName() {
        return obj.Name;
    }
    public void setName(String Name) {
        obj.Name = Name;
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

        public GFA_LibraryTask findById(Id libTaskId) {
            GFA_Library_Task__c task = (GFA_Library_Task__c)byId(libTaskId);
            return new GFA_LibraryTask(task);
        }

        /**
        * @param libtaskIds, These are the Ids to exclude from the search
        * @return libtasks, all Library tasks that were not a part of libtaskIds
        **/
        public List<GFA_LibraryTask> findByNotInIds(Set<Id> libtaskIds) {
            List<GFA_LibraryTask> libtasks = new List<GFA_LibraryTask>();
            for (GFA_Library_Task__c task : (List<GFA_Library_Task__c>)Database.query(getSelect() +
                    ' where Id NOT IN: libtaskIds ORDER BY Name ASC')) {
                libtasks.add(new GFA_LibraryTask(task));
            }
            return libtasks;
        }
    }
}