/**
* @author Nathan Pilkington
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_LogicRowController
*              PURPOSE: Backend controller class for SGT_LogicRow apex component
*              CREATED: 01/2017 Ethos Solutions - www.ethos.com
**/
public with sharing class SGT_LogicRowController {
	public SGT_LogicRowController() {
		
	}

    public SGT_LogicRow LRow {get; set;}


    public Boolean getShowLookup() {
        Map<String, SGT_Goal_Criteria__mdt> criteriaFields = SGT_GoalCriteriaField.find.getMap();

        if (!String.isBlank(LRow.field) && criteriaFields.containsKey(LRow.field)) {
            SGT_Goal_Criteria__mdt criteriaField = criteriaFields.get(LRow.field);
            return !String.isBlank(criteriaField.Picklist_Value_Source__c);
        }
        
        return false;
    }

    public String getAvailableValues() {
        Map<String, SGT_Goal_Criteria__mdt> criteriaFields = SGT_GoalCriteriaField.find.getMap();

        if (!String.isBlank(LRow.field) && criteriaFields.containsKey(LRow.field)) {
            SGT_Goal_Criteria__mdt criteriaField = criteriaFields.get(LRow.field);
            List<String> availableOptions = SGT_ReflectionUtil.getPicklistOptions(criteriaField.Picklist_Value_Source__c);
            return String.escapeSingleQuotes(String.join(availableOptions, ';'));
        }

        return '';
    }

    public List<SelectOption> getFieldList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));

        for (SGT_Goal_Criteria__mdt criteriaField : SGT_GoalCriteriaField.find.getAll()) {
            String label = '';
            if (!String.isBlank(criteriaField.Label_Override__c)) label = criteriaField.Label_Override__c;
            else label = SGT_ReflectionUtil.getLabel('Opportunity', criteriaField.Opportunity_Field_API__c);

            options.add(new SelectOption(criteriaField.Opportunity_Field_API__c, label));
        }        
        
        return options;
    }

    public List<SelectOption> getOperandList() {
        List<SelectOption> operators = new List<SelectOption>();

        if (LRow.field == null || LRow.field.length() == 0) {
            operators.add(new SelectOption('', ' -- Select Field -- '));
        }
        else {
            operators.add(new SelectOption('', ' -- Select -- '));

            Schema.DisplayType dispType = SGT_ReflectionUtil.getDisplayType('Opportunity', LRow.field);

            System.debug(LoggingLevel.DEBUG, 'DisplayType: ' + dispType);

            if (dispType == Schema.DisplayType.TextArea) {
                operators.add(new SelectOption(SGT_LogicRow.OP_CONTAINS,'contains'));
                operators.add(new SelectOption(SGT_LogicRow.OP_NOTCONTAINS,'does not contain'));
            } 
            else if (dispType == Schema.DisplayType.Reference) {
                operators.add(new SelectOption(SGT_LogicRow.OP_EQUALS,'equals'));
                operators.add(new SelectOption(SGT_LogicRow.OP_NOTEQUAL,'not equal to'));
                operators.add(new SelectOption(SGT_LogicRow.OP_CONTAINS,'contains'));
                operators.add(new SelectOption(SGT_LogicRow.OP_NOTCONTAINS,'does not contain'));
                operators.add(new SelectOption(SGT_LogicRow.OP_STARTSWITH,'starts with'));
            }
            else if (dispType == Schema.DisplayType.Currency || dispType == Schema.DisplayType.Double || dispType == Schema.DisplayType.Integer || dispType == Schema.DisplayType.Percent) {
                operators.add(new SelectOption(SGT_LogicRow.OP_EQUALS,'equals'));
                operators.add(new SelectOption(SGT_LogicRow.OP_NOTEQUAL,'not equal to'));
                operators.add(new SelectOption(SGT_LogicRow.OP_LT,'less than'));
                operators.add(new SelectOption(SGT_LogicRow.OP_GT,'greater than'));
                operators.add(new SelectOption(SGT_LogicRow.OP_LTEQUAL,'less or equal'));
                operators.add(new SelectOption(SGT_LogicRow.OP_GTEQUAL,'greater or equal'));
            }
            else if (dispType == Schema.DisplayType.Date || dispType == Schema.DisplayType.DateTime) {
                operators.add(new SelectOption(SGT_LogicRow.OP_EQUALS,'equals'));
                operators.add(new SelectOption(SGT_LogicRow.OP_NOTEQUAL,'not equal to'));
                operators.add(new SelectOption(SGT_LogicRow.OP_LT,'less than'));
                operators.add(new SelectOption(SGT_LogicRow.OP_GT,'greater than'));
                operators.add(new SelectOption(SGT_LogicRow.OP_LTEQUAL,'less or equal'));
                operators.add(new SelectOption(SGT_LogicRow.OP_GTEQUAL,'greater or equal'));
            }
            else if (dispType == Schema.DisplayType.String || dispType == Schema.DisplayType.Picklist  || dispType == Schema.DisplayType.Email || dispType == Schema.DisplayType.Phone) {
                operators.add(new SelectOption(SGT_LogicRow.OP_EQUALS,'equals'));
                operators.add(new SelectOption(SGT_LogicRow.OP_NOTEQUAL,'not equal to'));
                operators.add(new SelectOption(SGT_LogicRow.OP_LT,'less than'));
                operators.add(new SelectOption(SGT_LogicRow.OP_GT,'greater than'));
                operators.add(new SelectOption(SGT_LogicRow.OP_LTEQUAL,'less or equal'));
                operators.add(new SelectOption(SGT_LogicRow.OP_GTEQUAL,'greater or equal'));
                operators.add(new SelectOption(SGT_LogicRow.OP_CONTAINS,'contains'));
                operators.add(new SelectOption(SGT_LogicRow.OP_NOTCONTAINS,'does not contain'));
                operators.add(new SelectOption(SGT_LogicRow.OP_STARTSWITH,'starts with'));
                
            } 
            else if (dispType == Schema.DisplayType.MultiPicklist) {
                operators.add(new SelectOption(SGT_LogicRow.OP_INCLUDES,'includes'));
                operators.add(new SelectOption(SGT_LogicRow.OP_EXCLUDES,'excludes'));
            }
            else {
                operators.add(new SelectOption(SGT_LogicRow.OP_EQUALS,'equals'));
                operators.add(new SelectOption(SGT_LogicRow.OP_NOTEQUAL,'not equal to'));
                operators.add(new SelectOption(SGT_LogicRow.OP_CONTAINS,'contains'));
                operators.add(new SelectOption(SGT_LogicRow.OP_STARTSWITH,'starts with'));
                operators.add(new SelectOption(SGT_LogicRow.OP_NOTCONTAINS,'does not contain'));
                operators.add(new SelectOption(SGT_LogicRow.OP_LT,'less than'));
                operators.add(new SelectOption(SGT_LogicRow.OP_GT,'greater than'));
                operators.add(new SelectOption(SGT_LogicRow.OP_LTEQUAL,'less or equal'));
                operators.add(new SelectOption(SGT_LogicRow.OP_GTEQUAL,'greater or equal'));
                operators.add(new SelectOption(SGT_LogicRow.OP_INCLUDES,'includes'));
                operators.add(new SelectOption(SGT_LogicRow.OP_EXCLUDES,'excludes'));
                //operators.add(new SelectOption(CFM_LogicRow.OP_WITHIN,'within'));
            }
        }

        return operators;
    }
}