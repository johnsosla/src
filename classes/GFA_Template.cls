public with sharing class GFA_Template extends GFA_BaseModel {

    public static Finder find = new Finder('GFA_Template__c');
    public final static String STATUS_PENDING = 'Pending';
    public final static String STATUS_PUBLISHED = 'Published';
    public final static String STATUS_WITHDRAWN = 'Withdrawn';
    private List<GFA_TemplatePhase> templatePhases;

    public GFA_Template__c obj {
        get {
            return (GFA_Template__c)mObj;
        }
    }

    public GFA_Template() {
        this(new GFA_Template__c());
    }

    public GFA_Template(GFA_Template__c template) {
        super(template);
        templatePhases = new List<GFA_TemplatePhase>();
    }

    public void setTemplatePhases(List<GFA_TemplatePhase> phases) {
        templatePhases = phases;
    }
    public List<GFA_TemplatePhase> getTemplatePhases() {
        return templatePhases;
    }

    public String getStatus() {
        return obj.Status__c;
    }
    public void setStatus(String Status) {
        obj.Status__c = Status;
    }

    public void setStatusPending() {
        setStatus(STATUS_PENDING);
    }

    public void setStatusPublished() {
        setStatus(STATUS_PUBLISHED);
        setDatePublished(Date.today());
    }

    public void setStatusWithdrawn() {
        setStatus(STATUS_WITHDRAWN);
        setDatePublished(null);
    }

    public String getTemplateName() {
        return obj.Template_Name__c;
    }
    public void setTemplateName(String templateName) {
        obj.Template_Name__c = templateName;
    }

    public String getGroup() {
        return obj.Group__c;
    }
    public void setGroup(String Groupg) {
        obj.Group__c = Groupg;
    }

    public String getOperatingGroup() {
        return obj.Operating_Group__c;
    }
    public void setOperatingGroup(String OperatingGroup) {
        obj.Operating_Group__c = OperatingGroup;
    }

    public String getBusinessLine() {
        return obj.Business_Line__c;
    }
    public void setBusinessLine(String BusinessLine) {
        obj.Business_Line__c = BusinessLine;
    }

    public String getProjectSponsor() {
        return obj.Project_Sponsor__c;
    }
    public void setProjectSponsor(String ProjectSponsor) {
        obj.Project_Sponsor__c = ProjectSponsor;
    }

    public Date getDatePublished() {
        return obj.Date_Published__c;
    }
    public void setDatePublished(Date DatePublished) {
        obj.Date_Published__c = DatePublished;
    }

    public class Finder extends GFA_BaseFinder {

        public Finder(String sObjectName) {
            super(sObjectName);
        }

        public GFA_Template findById(Id templateId) {
            GFA_Template__c template = (GFA_Template__c)byId(templateId);
            return new GFA_Template(template);
        }

        public List<GFA_Template> findByMatchingProject(GFA_Project project) {
            List<GFA_Template> templates = new List<GFA_Template>();
            if (String.isNotBlank(project.getGroup()) && String.isNotBlank(project.getOperatingGroup())
                    && String.isNotBlank(project.getProjectSponsor())) {
                String whereClause = ' where Group__c = ' + quote(project.getGroup())
                     + ' AND Operating_Group__c = ' + quote(project.getOperatingGroup())
                     + ' AND Project_Sponsor__c = ' + quote(project.getProjectSponsor())
                     + ' AND Status__c =: STATUS_PUBLISHED';

                for (GFA_Template__c template : (List<GFA_Template__c>)Database.query(getSelect() + whereClause) ) {
                    templates.add(new GFA_Template(template));
                }
            }
            return templates;
        }
    }
}