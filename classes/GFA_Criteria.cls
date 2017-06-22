/*******************************************************************************
*
* PURPOSE: Base Criteria class used for inheritance and GFA_FilterManager class
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
*******************************************************************************/
public abstract class GFA_Criteria {

    public String ProjectSponsor {get; set;}
    public String OperatingGroup {get; set;}
    public String BusinessLine {get; set;}
    public String Discipline {get; set;}
    public String RiskLevel {get; set;}
    public String ImpactLevel {get; set;}
    public String ScopeOfService {get; set;}
    public Set<Id> ExcludeIds {get; set;}
    public String ProjectId {get; set;}

    public final String PROJECT_SPONSOR_PATH;
    public final String OPERATING_GROUP_PATH;
    public final String BUSINESS_LINE_PATH;
    public final String DISCIPLINE_PATH;
    public final String RISK_LEVEL_PATH;
    public final String IMPACT_LEVEL_PATH;
    public final String SCOPE_OF_SERVICE_PATH;
    public final String CRITICAL_OVERRIDE_PATH;
    public final String PROJECT_PATH;

    public GFA_Criteria() {}

    public String getWhereClause() {
        List<String> args = new List<String>();
        addWhereForExclude(args);
        addWhereForScopeofService(args);
        addWhereForImpactLevel(args);
        addWhereArg(args, ProjectSponsor, PROJECT_SPONSOR_PATH);
        addWhereArg(args, OperatingGroup, OPERATING_GROUP_PATH);
        addWhereArg(args, BusinessLine, BUSINESS_LINE_PATH);
        addWhereArg(args, Discipline, DISCIPLINE_PATH);
        addWhereArg(args, RiskLevel, RISK_LEVEL_PATH);
        addWhereArg(args, ProjectId, PROJECT_PATH);

        return !args.isEmpty() ? ' where ' + String.join(args, ' AND ') : '';
    }

    private void addWhereArg(List<String> args, String value, String path) {
        if (String.isNotBlank(value) && String.isNotBlank(path)) {
            args.add(path + ' = ' + GFA_BaseFinder.quote(value));
        }
    }

    private void addWhereForExclude(List<String> args) {
        if (ExcludeIds != null && !ExcludeIds.isEmpty()) {
            Set<String> ids = new Set<String>();
            for (Id excludedId : ExcludeIds) {
                ids.add(excludedId);
            }
            args.add('Id NOT IN ' + GFA_BaseFinder.quote(ids));
        }
    }

    private void addWhereForScopeofService(List<String> args) {
        if (String.isNotBlank(ScopeOfService) && String.isNotBlank(SCOPE_OF_SERVICE_PATH)) {
            List<String> values = ScopeOfService.split(';');
            args.add(SCOPE_OF_SERVICE_PATH + ' INCLUDES ' + GFA_BaseFinder.quote(values));
        }
    }

    private void addWhereForImpactLevel(List<String> args) {
        if (String.isNotBlank(CRITICAL_OVERRIDE_PATH) && String.isNotBlank(ImpactLevel)
                && String.isNotBlank(IMPACT_LEVEL_PATH)) {
            if (ImpactLevel == GFA_ProjectSubtask.IMPACT_LEVEL_CRITICAL) {
                args.add('(' + IMPACT_LEVEL_PATH + ' = ' + GFA_BaseFinder.quote(ImpactLevel) + ' OR '
                         + CRITICAL_OVERRIDE_PATH + ' = true)');
            } else {
                args.add('(' + IMPACT_LEVEL_PATH + ' = ' + GFA_BaseFinder.quote(ImpactLevel) + ' AND '
                         + CRITICAL_OVERRIDE_PATH + ' = false)');
            }
        } else {
            addWhereArg(args, ImpactLevel, IMPACT_LEVEL_PATH);
        }
    }
}