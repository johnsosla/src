public with sharing class GFA_TemplatePhase extends GFA_BaseModel {

    public static Finder find = new Finder('GFA_Template_Phase__c');

    public GFA_Template_Phase__c obj {
        get {
            return (GFA_Template_Phase__c)mObj;
        }
    }

    private List<GFA_TemplateTask> templateTasks;

    public GFA_TemplatePhase() {
        this(new GFA_Template_Phase__c());
    }

    public GFA_TemplatePhase(GFA_Template_Phase__c tempPhase) {
        super(tempPhase);
        templateTasks = new List<GFA_TemplateTask>();
    }

    public GFA_TemplatePhase(GFA_LibraryPhase libPhase) {
        this(new GFA_Template_Phase__c());
        mObj.putSObject('Library_Phase__r', libPhase.obj);
        setLibraryPhaseId(libPhase.getId());
    }

    public Id getTemplateId() {
        return obj.Template__c;
    }
    public void setTemplateId(Id Template) {
        obj.Template__c = Template;
    }

    public void setTemplateTasks(List<GFA_TemplateTask> tasks) {
        templateTasks = tasks;
    }
    public List<GFA_TemplateTask> getTemplateTasks() {
        return templateTasks;
    }

    public String getLibraryPhaseName() {
        return obj.Library_Phase__r.Name;
    }

    public Decimal getSequence() {
        return (Decimal)mObj.get('Sequence__c');
    }
    public void setSequence(Decimal Sequence) {
        mObj.put('Sequence__c', Sequence);
    }

    public Id getLibraryPhaseId() {
        return obj.Library_Phase__c;
    }
    public void setLibraryPhaseId(Id LibraryPhase) {
        obj.Library_Phase__c = LibraryPhase;
    }

    public String getLibraryPhaseDescription() {
        return obj.Library_Phase__r.Description__c;
    }

    public String getName() {
        return obj.Name;
    }

    public class Finder extends GFA_BaseFinder {

        public Finder(String sObjectName) {
            super(sObjectName);
            Set<String> libraryPhaseFields = GFA_LibraryPhase.find.getFieldSet();
            Set<String> additionalFields = new Set<String>();
            for (String libField : libraryPhaseFields) {
                additionalFields.add('Library_Phase__r.' + libField);
            }
            addFields(additionalFields);
        }

        public List<GFA_TemplatePhase> findByTemplateId(Id templateId) {
            List<GFA_TemplatePhase> phases = new List<GFA_TemplatePhase>();
            for (GFA_Template_Phase__c phase : (List<GFA_Template_Phase__c>)Database.query(getSelect()
                    + ' where Template__c =: templateId ORDER BY Sequence__c ASC')) {
                phases.add(new GFA_TemplatePhase(phase));
            }
            return phases;
        }

        public GFA_TemplatePhase findById(Id templatePhaseId) {
            GFA_Template_Phase__c templatePhase = (GFA_Template_Phase__c)byId(templatePhaseId);
            return new GFA_TemplatePhase(templatePhase);
        }
    }
}