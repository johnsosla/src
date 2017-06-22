public with sharing class CFM_LogicRowController {

    public Boolean isDefaultInclusionCriteria { get; set; }

    public CFM_LogicRowController() {
        
    }

    public CFM_LogicRow LRow {get; set;}

    public List<SelectOption> getFieldList() {
        Map<String,Schema.SObjectField> fields = Schema.getGlobalDescribe().get(CFM_Project.OBJ_NAME).getDescribe().fields.getmap();

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));

        if (isDefaultInclusionCriteria) {
            for (String fieldName : CFM_Project.getDefaultInclusionCriteriaFields()) {
                options.add(new SelectOption(fieldName, fields.get(fieldName).getDescribe().getLabel()));
            }
        }
        else {
            for (String fieldName : CFM_Project.getProjectFilterFields()) {
                options.add(new SelectOption(fieldName, fields.get(fieldName).getDescribe().getLabel()));
            }
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

            Schema.DisplayType dispType = CFM_LogicRow.getDisplayType(CFM_Project.OBJ_NAME,LRow.field);

            if (dispType == Schema.DisplayType.TextArea) {
                operators.add(new SelectOption(CFM_LogicRow.OP_CONTAINS,'contains'));
                operators.add(new SelectOption(CFM_LogicRow.OP_NOTCONTAINS,'does not contain'));
            } 
            else if (dispType == Schema.DisplayType.Reference) {
                operators.add(new SelectOption(CFM_LogicRow.OP_EQUALS,'equals'));
                operators.add(new SelectOption(CFM_LogicRow.OP_NOTEQUAL,'not equal to'));
                operators.add(new SelectOption(CFM_LogicRow.OP_CONTAINS,'contains'));
                operators.add(new SelectOption(CFM_LogicRow.OP_NOTCONTAINS,'does not contain'));
                operators.add(new SelectOption(CFM_LogicRow.OP_STARTSWITH,'starts with'));
            }
            else if (dispType == Schema.DisplayType.Currency || dispType == Schema.DisplayType.Double || dispType == Schema.DisplayType.Integer || dispType == Schema.DisplayType.Percent) {
                operators.add(new SelectOption(CFM_LogicRow.OP_EQUALS,'equals'));
                operators.add(new SelectOption(CFM_LogicRow.OP_NOTEQUAL,'not equal to'));
                operators.add(new SelectOption(CFM_LogicRow.OP_LT,'less than'));
                operators.add(new SelectOption(CFM_LogicRow.OP_GT,'greater than'));
                operators.add(new SelectOption(CFM_LogicRow.OP_LTEQUAL,'less or equal'));
                operators.add(new SelectOption(CFM_LogicRow.OP_GTEQUAL,'greater or equal'));
            }
            else if (dispType == Schema.DisplayType.Date || dispType == Schema.DisplayType.DateTime) {
                operators.add(new SelectOption(CFM_LogicRow.OP_EQUALS,'equals'));
                operators.add(new SelectOption(CFM_LogicRow.OP_NOTEQUAL,'not equal to'));
                operators.add(new SelectOption(CFM_LogicRow.OP_LT,'less than'));
                operators.add(new SelectOption(CFM_LogicRow.OP_GT,'greater than'));
                operators.add(new SelectOption(CFM_LogicRow.OP_LTEQUAL,'less or equal'));
                operators.add(new SelectOption(CFM_LogicRow.OP_GTEQUAL,'greater or equal'));
            }
            else if (dispType == Schema.DisplayType.String || dispType == Schema.DisplayType.Picklist  || dispType == Schema.DisplayType.Email || dispType == Schema.DisplayType.Phone) {
                operators.add(new SelectOption(CFM_LogicRow.OP_EQUALS,'equals'));
                operators.add(new SelectOption(CFM_LogicRow.OP_NOTEQUAL,'not equal to'));
                operators.add(new SelectOption(CFM_LogicRow.OP_LT,'less than'));
                operators.add(new SelectOption(CFM_LogicRow.OP_GT,'greater than'));
                operators.add(new SelectOption(CFM_LogicRow.OP_LTEQUAL,'less or equal'));
                operators.add(new SelectOption(CFM_LogicRow.OP_GTEQUAL,'greater or equal'));
                operators.add(new SelectOption(CFM_LogicRow.OP_CONTAINS,'contains'));
                operators.add(new SelectOption(CFM_LogicRow.OP_NOTCONTAINS,'does not contain'));
                operators.add(new SelectOption(CFM_LogicRow.OP_STARTSWITH,'starts with'));
                
            } 
            else if (dispType == Schema.DisplayType.MultiPicklist) {
                operators.add(new SelectOption(CFM_LogicRow.OP_INCLUDES,'includes'));
                operators.add(new SelectOption(CFM_LogicRow.OP_EXCLUDES,'excludes'));
            }
            else {
                operators.add(new SelectOption(CFM_LogicRow.OP_EQUALS,'equals'));
                operators.add(new SelectOption(CFM_LogicRow.OP_NOTEQUAL,'not equal to'));
                operators.add(new SelectOption(CFM_LogicRow.OP_CONTAINS,'contains'));
                operators.add(new SelectOption(CFM_LogicRow.OP_STARTSWITH,'starts with'));
                operators.add(new SelectOption(CFM_LogicRow.OP_NOTCONTAINS,'does not contain'));
                operators.add(new SelectOption(CFM_LogicRow.OP_LT,'less than'));
                operators.add(new SelectOption(CFM_LogicRow.OP_GT,'greater than'));
                operators.add(new SelectOption(CFM_LogicRow.OP_LTEQUAL,'less or equal'));
                operators.add(new SelectOption(CFM_LogicRow.OP_GTEQUAL,'greater or equal'));
                operators.add(new SelectOption(CFM_LogicRow.OP_INCLUDES,'includes'));
                operators.add(new SelectOption(CFM_LogicRow.OP_EXCLUDES,'excludes'));
                //operators.add(new SelectOption(CFM_LogicRow.OP_WITHIN,'within'));
            }
        }

        return operators;
    }

    
}