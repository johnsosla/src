public with sharing class CFM_LogicRow {

    public static final String OP_EQUALS = 'EQ';
    public static final String OP_NOTEQUAL = 'NE';
    public static final String OP_STARTSWITH = 'SW';
    public static final String OP_CONTAINS = 'CNT';
    public static final String OP_NOTCONTAINS = 'NCNT';
    public static final String OP_LT = 'LT';
    public static final String OP_GT = 'GT';
    public static final String OP_LTEQUAL = 'LTE';
    public static final String OP_GTEQUAL = 'GTE';
    public static final String OP_INCLUDES = 'INC';
    public static final String OP_EXCLUDES = 'EXC';
    //public static final String OP_WITHIN = 'WI';

    public String field { get; set; }
    public String operand { get; set; }
    public String logicValue { get; set; }
    public Boolean isLastRow { get; set; }
    public Integer position { get; set; }

    public CFM_LogicRow() {
    }

    public CFM_LogicRow(Integer pos) {
        position = pos;
    }

    public Boolean isEmpty() {
        return CFM_StringUtil.isEmpty(field) || CFM_StringUtil.isEmpty(operand) || CFM_StringUtil.isEmpty(logicValue);
    }

    public class InvalidFilterLogicException extends Exception {  }

    public static String getDefaultInclusionCriteriaClause(CFM_SavedSearch defaultInclusionCriteria) {
        String result = ' AND ( ';

        if (defaultInclusionCriteria.enableFilterLogic) {
            result += parseFilterLogic(defaultInclusionCriteria.filterLogic, defaultInclusionCriteria.logicRowList);
        }
        else {
            result += evaluateAndLogic(defaultInclusionCriteria.logicRowList);
        }

        result += ' )';

        return result;
    }


    public static String evaluateAndLogic(List<CFM_LogicRow> queryLogic) {
        String whereClause = '';

        for (CFM_LogicRow row : queryLogic) {
            if (!row.isEmpty()) {
                if (whereClause.length() > 0) whereClause += ' AND ';
                whereClause += row.evaluate();
            }
        }

        if (whereClause.length() == 0) {
            throw new InvalidFilterLogicException('You must enter at least one search criteria');
        }

        return '('+ whereClause + ')';
    }

    public static String parseFilterLogic(String filterLogicInput, List<CFM_LogicRow> queryLogic) {
        Pattern queryPartPattern = Pattern.compile('[0-9]+');
        Matcher qMatcher = queryPartPattern.matcher(filterLogicInput);

        String cleaned = filterLogicInput.replaceAll('(AND|OR|and|or|\\(|\\)|\\d|\\s)', '');

        if (cleaned.length() > 0) {
            // Something was found in the input that is not AND, OR, number, whitespace, or paren.
            throw new InvalidFilterLogicException('Invalid input in filter logic');
        }

        String query = filterLogicInput;

        while (qMatcher.find())
        {
            Integer qIndex = Integer.valueOf(qMatcher.group());

            if (queryLogic.size() < qIndex) {
                throw new InvalidFilterLogicException('Row ' + qIndex + ' does not exist');
            }

            CFM_LogicRow row = queryLogic[qIndex-1]; // User input is 1-indexed

            if (row.isEmpty()) {
                throw new InvalidFilterLogicException('Row ' + qIndex + ' is empty');
            }

            query = query.replaceAll('(?<![0-9])' + qIndex + '(?![0-9])', row.evaluate());
        }

        return '(' + query + ')';
    }

    public String evaluate() {
        String qField = field;
        String qVal = logicValue;

        if (qVal == 'blank') qVal = 'null';

        Schema.DisplayType dispType = CFM_LogicRow.getDisplayType(CFM_Project.OBJ_NAME, field);

        if (dispType == Schema.DisplayType.Date || dispType == Schema.DisplayType.DateTime) {
            if (dispType == Schema.DisplayType.DateTime) {
                qField = 'day_only(' + field + ')';    // Only search on date portion for datetime fields
            }

            if (qVal != 'null') qVal = CFM_StringUtil.convertDateStringToSoqlFormat(qVal);
        }
        else if (dispType == Schema.DisplayType.Reference) {
            qField = qField.replace('__c', '__r.Name');
        }

        String result = null;
        if (operand == OP_NOTCONTAINS) {
            result = ' (NOT ' + qField + ' ';
        }
        else {
            result = ' ' + qField + ' ';
        }

        if (operand == OP_STARTSWITH) {
            result += ' like \'' + String.escapeSingleQuotes(qVal) + '%\' ';
        }
        else if (operand == OP_CONTAINS) {
            result += ' like \'%' + String.escapeSingleQuotes(qVal) + '%\' ';
        }
        else if (operand == OP_NOTCONTAINS) {
            result += ' like \'%' + String.escapeSingleQuotes(qVal) + '%\') ';
        }
        else if (operand == OP_INCLUDES) {
            result += ' includes (\'' + CFM_StringUtil.parseAndCleanMultiVal(qVal) + '\') ';
        }
        else if (operand == OP_EXCLUDES) {
            result += ' excludes (\'' + CFM_StringUtil.parseAndCleanMultiVal(qVal) + '\') ';
        }
        else {
            if (dispType == Schema.DisplayType.Reference || dispType == Schema.DisplayType.String || dispType == Schema.DisplayType.Combobox  || dispType == Schema.DisplayType.Picklist  || dispType == Schema.DisplayType.Email || dispType == Schema.DisplayType.Phone) {
                if (qVal != 'null') qVal = CFM_StringUtil.quote(qVal);
            }

            if (operand == OP_EQUALS) {
             result += ' = ' + qVal;
            }
            if (operand == OP_NOTEQUAL) {
                result += ' != ' + qVal;
            }           
            if (operand == OP_LT) {
                result += ' < ' + qVal;
            }
            if (operand == OP_GT) {
                result += ' > ' + qVal;
            }
            if (operand == OP_LTEQUAL) {
                result += ' <= ' + qVal;
            }
            if (operand == OP_GTEQUAL) {
                result += ' >= ' + qVal;
            }
        }
        
        return result;
    }


    public static Schema.DisplayType getDisplayType(String objectName, String fieldName) {
        Schema.DisplayType dispType = null;

        SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> objectFields = objToken.getDescribe().fields.getMap();
        dispType = objectFields.get(fieldName).getDescribe().getType();
        
        return dispType;
    }
}