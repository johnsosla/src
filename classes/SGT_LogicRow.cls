public with sharing class SGT_LogicRow {

    
	public static final String OP_EQUALS = 'eq';
    public static final String OP_NOTEQUAL = 'ne';
    public static final String OP_STARTSWITH = 'sw';
    public static final String OP_CONTAINS = 'co';
    public static final String OP_NOTCONTAINS = 'nc';
    public static final String OP_LT = 'lt';
    public static final String OP_GT = 'gt';
    public static final String OP_LTEQUAL = 'le';
    public static final String OP_GTEQUAL = 'ge';
    public static final String OP_INCLUDES = 'in';
    public static final String OP_EXCLUDES = 'ex';

    public static final Map<String, String> OP_LABELS = new Map<String, String> {
        OP_EQUALS       => 'Equals',
        OP_NOTEQUAL     => 'Not equal to',
        OP_STARTSWITH   => 'Starts with',
        OP_CONTAINS     => 'Contains',
        OP_NOTCONTAINS  => 'Does not contain',
        OP_LT           => 'Less than',
        OP_GT           => 'Greater than',
        OP_LTEQUAL      => 'Less than or equal to',
        OP_GTEQUAL      => 'Greater than or equal to',
        OP_INCLUDES     => 'Includes',
        OP_EXCLUDES     => 'Excludes'
    };

    public String field { get; set; }
    public String operand { get; set; }
    public String logicValue { get; set; }
    public Boolean isLastRow { get; set; }
    public Integer position { get; set; }

	public SGT_LogicRow() {
		
	}

	public SGT_LogicRow(Integer pos) {
        position = pos;
    }

    public SGT_LogicRow(Integer pos, String field, String operand, String value) {
        this.position = pos;
        this.field = field;
        this.operand = operand;
        this.logicValue = value;
    }


    public Boolean blankLogicValue() {
        return logicValue == null || String.isEmpty(logicValue) || logicValue == 'blank';
    }

    public String getFieldLabel() {
        Map<String, SGT_Goal_Criteria__mdt> criteriaMap = SGT_GoalCriteriaField.find.getMap();

        if (criteriaMap.containsKey(field) && !String.isBlank(criteriaMap.get(field).Label_Override__c)) {
            return criteriaMap.get(field).Label_Override__c;
        }

        return SGT_ReflectionUtil.getLabel('Opportunity', field);
    }

    public String getOperatorLabel() {
        return OP_LABELS.get(operand);
    }

    public Boolean isEmpty() {
        return SGT_StringUtil.isEmpty(field) || SGT_StringUtil.isEmpty(operand) || SGT_StringUtil.isEmpty(logicValue);
    }

    public Boolean isIncomplete() {
        return !SGT_StringUtil.isEmpty(field) && SGT_StringUtil.isEmpty(operand);
    }

    public Boolean allowsMultipleValues() {
        return operand == OP_EQUALS || operand == OP_NOTEQUAL || operand == OP_INCLUDES || operand == OP_EXCLUDES;
    }

    public Boolean isMultiValue() {
        return !String.isBlank(logicValue) && logicValue.contains(';');
    }

    public static String evaluateAndLogic(List<SGT_LogicRow> queryLogic) {
        String whereClause = '';

        for (SGT_LogicRow row : queryLogic) {
            if (!row.isEmpty()) {
                if (whereClause.length() > 0) whereClause += ' AND ';
                whereClause += ' ( '  + row.evaluate() + ' ) ';
            }
        }

        if (whereClause.length() == 0) {
            throw new InvalidFilterLogicException('You must enter at least one search criteria');
        }

        return '('+ whereClause + ')';
    }

    public static String parseFilterLogic(String filterLogicInput, List<SGT_LogicRow> queryLogic) {
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

            SGT_LogicRow row = queryLogic[qIndex-1]; // User input is 1-indexed

            if (row.isEmpty()) {
                throw new InvalidFilterLogicException('Row ' + qIndex + ' is empty');
            }

            query = query.replaceAll('(?<![0-9])' + qIndex + '(?![0-9])', row.evaluate());
        }

        return '(' + query + ')';
    }


    // Build the SOQL where clause for this logic row
    public String evaluate() {
        String qField = field;
        String qVal = logicValue;

        if (qVal == 'blank') qVal = 'null';

        Schema.DisplayType dispType = SGT_ReflectionUtil.getDisplayType('Opportunity', field);

        if (dispType == Schema.DisplayType.Date || dispType == Schema.DisplayType.DateTime) {
            if (dispType == Schema.DisplayType.DateTime) {
                qField = 'day_only(' + field + ')';    // Only search on date portion for datetime fields
            }

            if (qVal != 'null') qVal = SGT_StringUtil.convertDateStringToSoqlFormat(qVal);
        }
        else if (dispType == Schema.DisplayType.Reference) {
            if (qField.contains('__c')) qField = qField.replace('__c', '__r.Name');
            else qField = qField.replace('Id', '.Name'); // Standard lookup fields end with 'Id' instead of __r
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
            result += ' includes ('  + SGT_StringUtil.parseAndCleanMultiVal(qVal) + ') ';
        }
        else if (operand == OP_EXCLUDES) {
            result += ' excludes (' + SGT_StringUtil.parseAndCleanMultiVal(qVal) + ') ';
        }
        else {

            Boolean isString = false;
            if (dispType == Schema.DisplayType.Reference || dispType == Schema.DisplayType.String || dispType == Schema.DisplayType.Combobox  || dispType == Schema.DisplayType.Picklist  || dispType == Schema.DisplayType.Email || dispType == Schema.DisplayType.Phone) {
                isString = true;
            }

            if (operand == OP_EQUALS) {
                
                if (isString && qVal != 'null') {
                    result += ' IN ' + SGT_StringUtil.inClause(qVal);
                } 
                else {
                    result += ' = ' + qVal;    
                }
                
            }
            else if (operand == OP_NOTEQUAL) {
                if (isString && qVal != 'null') {
                    result += ' NOT IN ' + SGT_StringUtil.inClause(qVal);
                }
                else {
                    result += ' != ' + qVal;    
                }
                
            }           
            
            if (isString && qVal != 'null') {
                qVal = SGT_StringUtil.quote(qVal);
            }

            if (operand == OP_LT) {
                result += ' < ' + qVal;
            }
            else if (operand == OP_GT) {
                result += ' > ' + qVal;
            }
            else if (operand == OP_LTEQUAL) {
                result += ' <= ' + qVal;
            }
            else if (operand == OP_GTEQUAL) {
                result += ' >= ' + qVal;
            }
        }
        
        return result;
    }

    // Check to see if this logic row matches a particular opportunity ("in memory" match)
    public Boolean evaluate(SGT_Opportunity opp) {
        String qField = field;
        String qVal = logicValue;

        if (qVal == 'blank') qVal = null;


        Schema.DisplayType dispType = SGT_ReflectionUtil.getDisplayType('Opportunity', field);

        if (dispType == Schema.DisplayType.Reference) {
            if (qField.contains('__c')) qField = qField.replace('__c', '__r.Name');
            else qField = qField.replace('Id', '.Name');
        }


        Object oppFieldValue = opp.get(qField);


        if (SGT_ReflectionUtil.isFieldDate(dispType)) {
            Date oppFieldValueDate = null;

            if (dispType == Schema.DisplayType.DateTime) {
                DateTime dt = (DateTime)oppFieldValue;
                oppFieldValueDate = Date.newInstance(dt.year(), dt.month(), dt.day());
            }
            else {
                oppFieldValueDate = (Date)oppFieldValue;
            }

            Date matchDate = Date.valueOf(qVal);

            return check(operand, oppFieldValueDate, matchDate);

        }
        else if (SGT_ReflectionUtil.isFieldNumeric(dispType)) {
            // Numeric field (percent, number, currency)

            Decimal dOppFieldValue = (Decimal)oppFieldValue;
            Decimal dQVal = Decimal.valueOf(qVal);
            return check(operand, dOppFieldValue, dQVal);

        }
        else if (SGT_ReflectionUtil.isFieldBoolean(dispType)) {
            Boolean bOppFieldValue = (Boolean)oppFieldValue;
            Boolean bLogicVal = Boolean.valueOf(qVal);
            return check(operand, bOppFieldValue, bLogicVal);
        }
        else {
            // Treat all other field types as text
            String sOppFieldValue = String.valueOf(oppFieldValue);
            return check(operand, sOppFieldValue, qVal);
        }


        return false;
    }

    private Static Boolean check(String operator, Boolean lVal, Boolean rVal) {
        if (operator == OP_EQUALS) return lVal == rVal;
        if (operator == OP_NOTEQUAL) return lVal != rVal;

        System.debug('Unknown Boolean check operator: ' + operator);

        return false;
    }

    private static Boolean check(String operator, Date lVal, Date rVal) {
        if (operator == OP_EQUALS) return lVal == rVal;
        if (operator == OP_NOTEQUAL) return lVal != rVal;

        // The rest of the operators require both values to not be null
        if (lVal == null || rVal == null) return false;

        if (operator == OP_LT) return lVal < rVal;
        if (operator == OP_GT) return lVal > rVal;       
        if (operator == OP_LTEQUAL) return lVal <= rVal;
        if (operator == OP_GTEQUAL) return lVal >= rVal;

        // Unknown operator?
        System.debug('Unknown Decimal check operator: ' + operator);

        return false; 
    }

    private static Boolean check(String operator, Decimal lVal, Decimal rVal) {
        if (operator == OP_EQUALS) return lVal == rVal;
        if (operator == OP_NOTEQUAL) return lVal != rVal;

        // The rest of the operators require both values to not be null
        if (lVal == null || rVal == null) return false;

        if (operator == OP_LT) return lVal < rVal;
        if (operator == OP_GT) return lVal > rVal;       
        if (operator == OP_LTEQUAL) return lVal <= rVal;
        if (operator == OP_GTEQUAL) return lVal >= rVal;

        // Unknown operator?
        System.debug('Unknown Decimal check operator: ' + operator);

        return false; 
    }

    // lVal = opportunity field val
    // rVal = logic row value
    public static Boolean check(String operator, String lVal, String rVal) {

        if (operator == OP_EQUALS || operator == OP_NOTEQUAL) {
            Set<String> values = SGT_StringUtil.multiValToSet(rVal, true);

            if (operator == OP_EQUALS) return values.contains(SGT_StringUtil.toLower(lVal));
            if (operator == OP_NOTEQUAL) return !values.contains(SGT_StringUtil.toLower(lVal));    
        }

        if (operator == OP_INCLUDES || operator == OP_EXCLUDES) {
            Set<String> oppValues = SGT_StringUtil.multiValToSet(lVal, true);
            Set<String> logicValues = SGT_StringUtil.multiValToSet(rVal, true);

            if (operator == OP_INCLUDES) {
                Boolean instersection = oppValues.removeAll(logicValues);
                return instersection;
            }
            if (operator == OP_EXCLUDES) {
                Boolean instersection = oppValues.removeAll(logicValues);
                return !instersection;
            }
        }

        
        // The rest of the operators require both values to not be null
        if (lVal == null || rVal == null) return false;

        if (operator == OP_STARTSWITH) return lVal.startsWithIgnoreCase(rVal);
        if (operator == OP_CONTAINS) return lVal.containsIgnoreCase(rVal);
        if (operator == OP_NOTCONTAINS) return !lVal.containsIgnoreCase(rVal);
        if (operator == OP_LT) return lVal < rVal;
        if (operator == OP_GT) return lVal > rVal;       
        if (operator == OP_LTEQUAL) return lVal <= rVal;
        if (operator == OP_GTEQUAL) return lVal >= rVal;

        // Unknown operator?
        System.debug('Unknown String check operator: ' + operator);

        return false; 
    }


    public class InvalidFilterLogicException extends Exception {  }


    // Given a list of boolean inputs, and an RPN expression, return the overall result of the expression
    public static Boolean evaluateRpnExpr(List<Boolean> inputs, String rpnExpr) {
        List<String> rpn = rpnExpr.split('\\s');
        
        BooleanStack stack = new BooleanStack();

        for (String row : rpn) {

            if (row == 'OR' || row == 'AND') {
                Boolean op2 = stack.pop();
                Boolean op1 = stack.pop();

                Boolean result = false;

                if (row == 'OR') result = op2 || op1;
                if (row == 'AND') result = op2 && op1;

                stack.push(result);
            }
            else {
                Integer index = Integer.valueOf(row);
                stack.push(inputs[index-1]);
            }
        }

        return stack.pop();
    }

    public class BooleanStack {
        private List<Boolean> stack = new List<Boolean>();

        public BooleanStack() {

        }

        public Boolean peek() {
            return stack[stack.size() - 1];
        }

        public Boolean isEmpty() {
            return stack.isEmpty();
        }

        public Boolean pop() {
            Boolean item = peek();
            stack.remove(stack.size() - 1);
            return item;
        }

        public void push(Boolean item) {
            stack.add(item);
        }

        public void dump() {
            System.debug(JSON.serialize(stack));
        }
    }


    // Convert '1 AND 2 OR 3' to RPN (reverse polish notation)
    public static String convertToRpn(String infix)
    {
        infix = infix.trim();

        String output = '';
        StringStack stack  = new StringStack();

        for (String token : infix.split('\\s+')) {
            // operator
            if (ops.containsKey(token)) {
                while (!stack.isEmpty() && isHigherPrecision(token, stack.peek())) {
                    output += stack.pop() + ' ';
                }

                stack.push(token);
            } 
            else if (token.equals('(')) {
                // left parenthesis
                stack.push(token);
            
            } 
            else if (token.equals(')')) {
                // right parenthesis
                while (!stack.peek().equals('(')) {
                    output += stack.pop() + ' ';
                }

                stack.pop();

            // digit
            } else {
                output += token + ' ';
            }
        }

        while ( ! stack.isEmpty()) {
            output += stack.pop() + ' ';
        }

        return output;
    }

    private static Map<String, Integer> ops = new Map<String, Integer> {
        'OR' => 1,
        'AND' => 2
    };

    private static boolean isHigherPrecision(String op, String sub) {
        return (ops.containsKey(sub) && ops.get(sub) >= ops.get(op));
    }
    
    public class StringStack {
        private List<String> stack = new List<String>();

        public StringStack() {

        }

        public String peek() {
            return stack[stack.size() - 1];
        }

        public Boolean isEmpty() {
            return stack.isEmpty();
        }

        public String pop() {
            String item = peek();
            if (stack.size() > 0) stack.remove(stack.size() - 1);
            return item;
        }

        public void push(String item) {
            stack.add(item);
        }


    }
}