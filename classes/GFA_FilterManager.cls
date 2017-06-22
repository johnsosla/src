public class GFA_FilterManager {

    private GFA_Criteria mCriteria;

    public enum FilterType {
        ProjectSponsors,
        Disciplines,
        RiskLevels,
        ImpactLevels
    }

    public List<SelectOption> ProjectSponsors {get; set;}
    public String ProjectSponsor {get; set;}

    public List<SelectOption> Disciplines {get; set;}
    public String Discipline {get; set;}

    public List<SelectOption> RiskLevels {get; set;}
    public String RiskLevel {get; set;}

    public List<SelectOption> ImpactLevels {get; set;}
    public String ImpactLevel {get; set;}

    public GFA_Library_Subtask__c subtask {get; set;}
    public String OperatingGroup {get; set;}
    public String BusinessLine {get; set;}
    public String ScopeOfService {get; set;}

    public Set<Id> ExcludeIds {get; set;}
    public String ProjectId {get; set;}
    public Boolean ShowMyTasks {get; set;}

    public GFA_FilterManager() {
        subtask = new GFA_Library_Subtask__c();
    }

    public void setupFilter(FilterType type) {
        if (type == FilterType.ProjectSponsors) {
            ProjectSponsors = GFA_LibrarySubtask.find.getProjectSponsorsOptions();
        } else if (type == FilterType.Disciplines) {
            Disciplines = GFA_LibrarySubtask.find.getDisciplineOptions();
        } else if (type == FilterType.RiskLevels) {
            RiskLevels = GFA_LibrarySubtask.find.getRiskLevelOptions();
        } else if (type == FilterType.ImpactLevels) {
            ImpactLevels = GFA_LibrarySubtask.find.getImpactLevelOptions();
        }
    }

    public void setupLibrarySubtaskFilters() {
        setupFilter(FilterType.ProjectSponsors);
        setupFilter(FilterType.Disciplines);
        setupFilter(FilterType.RiskLevels);
        setupFilter(FilterType.ImpactLevels);
    }

    public List<GFA_LibrarySubtask> getLibrarySubtasksByCriteria() {
        mCriteria = new GFA_LibrarySubtaskCriteria();
        mCriteria.ExcludeIds = ExcludeIds;
        mCriteria.ProjectSponsor = ProjectSponsor;
        mCriteria.OperatingGroup = subtask.Operating_Group__c;
        mCriteria.BusinessLine = subtask.Business_Line__c;
        mCriteria.Discipline = Discipline;
        mCriteria.RiskLevel = RiskLevel;
        mCriteria.ImpactLevel = ImpactLevel;
        mCriteria.ScopeOfService = subtask.Scope_of_Service__c;
        return GFA_LibrarySubtask.find.findByCriteria((GFA_LibrarySubtaskCriteria)mCriteria);
    }

    public List<GFA_ProjectSubtask> getProjectSubtasksByCriteria() {
        mCriteria = new GFA_ProjectSubtaskCriteria();
        mCriteria.ExcludeIds = ExcludeIds;
        mCriteria.ProjectSponsor = ProjectSponsor;
        mCriteria.OperatingGroup = subtask.Operating_Group__c;
        mCriteria.BusinessLine = subtask.Business_Line__c;
        mCriteria.Discipline = Discipline;
        mCriteria.RiskLevel = RiskLevel;
        mCriteria.ImpactLevel = ImpactLevel;
        mCriteria.ScopeOfService = subtask.Scope_of_Service__c;
        mCriteria.ProjectId = ProjectId;
        return GFA_ProjectSubtask.find.findByCriteria((GFA_ProjectSubtaskCriteria)mCriteria);
    }

    public Boolean IsFilterBlank() {
        return String.isBlank(ProjectSponsor) &&
               String.isBlank(subtask.Operating_Group__c) &&
               String.isBlank(subtask.Business_Line__c) &&
               String.isBlank(Discipline) &&
               String.isBlank(RiskLevel) &&
               String.isBlank(ImpactLevel) &&
               String.isBlank(subtask.Scope_of_Service__c);
    }

    public String serialize() {
        GFA_FilterManager clone = new GFA_FilterManager();
        clone.ProjectSponsor = ProjectSponsor;
        clone.Discipline = Discipline;
        clone.RiskLevel = RiskLevel;
        clone.ImpactLevel = ImpactLevel;
        clone.OperatingGroup = subtask.Operating_Group__c;
        clone.BusinessLine = subtask.Business_Line__c;
        clone.ScopeOfService = subtask.Scope_of_Service__c;
        clone.ShowMyTasks = ShowMyTasks;
        return JSON.serialize(clone);
    }


}