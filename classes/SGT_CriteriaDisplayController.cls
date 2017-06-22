/**
* @author Nathan Pilkington
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_CriteriaDisplayController
*              PURPOSE: Backend controller class for SGT_CriteriaDisplay visualforce page
*              CREATED: 01/2017 Ethos Solutions - www.ethos.com
**/
public with sharing class SGT_CriteriaDisplayController {

	private final SGT_SalesGoal salesGoal;

    public List<SGT_LogicRow> logicRows { get; set; }

    public Boolean showFilterLogic { get; set; }
    public String filterLogic { get; set; }

    public SGT_CriteriaDisplayController(ApexPages.StandardController sc) {
        this.salesGoal = SGT_SalesGoal.find.findById(sc.getId());

        logicRows = salesGoal.getLogicRows();
        showFilterLogic = salesGoal.obj.Filter_Logic_Enabled__c;
        filterLogic = salesGoal.obj.Filter_Logic__c;
    }

}