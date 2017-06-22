public with sharing class ECO_PMD_RevenueDetails_Controller {
    private final pse__Proj__c project;

    public ECO_PMD_RevenueDetails_Controller(ApexPages.StandardController stdController) {
        //stdController.addFields(new List<string>{'OracleProjectNumber__c', 'Name'});
        this.project = (pse__Proj__c)stdController.getRecord();
    }

    public String getProjectName() {
        return project.Name;
    }

    public String getProjectId() {
        return project.Id;
    }

    @RemoteAction @ReadOnly
    public static List<Revenue__c> GetRevenueData(String projectId) {
        return [select Id
            , TaskNumber__r.Name
            , TaskNumber__r.ProjectTaskNumber__c
            , PAPeriodName__c
            , GLPeriodName__c
            , CurrencyIsoCode
            , Amount__c
            , AdjustingRevenueFlag__c
            , AgreementNumber__c
            , DraftRevenueNum__c
            , DraftRevenueNumCredited__c
            , RevenueSource__c
            , ProjectNumber__c
            , LineNum__c
            , PADate__c
            , PADateFiscalMonth__c
            , PADatePreviousFiscalMonth__c
            , GLDate__c
            , GLDateFiscalMonth__c
            , GLDatePreviousFiscalMonth__c
            , AccrueThroughDate__c
            , ProjFunCurrencyCode__c
        from Revenue__c
        where ProjectNumber__c = :projectId];
    }
}