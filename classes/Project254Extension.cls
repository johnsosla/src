public with sharing class Project254Extension {

    public Project__c proj;
    public List<String> jquerySelected { get; set; }
    
    
    public Project254Extension(ApexPages.standardController ctl) {
        proj = (Project__c)ctl.getRecord();

        if (proj.Code_254_Text__c != null) {
            String sel = proj.Code_254_Text__c.replaceAll('\r','\n');           
            jquerySelected = sel.split('\n');
        }else {

           jquerySelected = new List<String>();

        }


    }
   
    public List<SelectOption> availableValues {
        get {
            if (availableValues == null) {
                availableValues = new List<SelectOption>();
                Map<String, Code254__c> codeMap = Code254__c.getAll(); 
                List<String> codes = new List<String>();
                codes.addAll(codeMap.keySet());
                codes.sort();
                    
                for (String codeName : codes) {
                    Code254__c code = codeMap.get(codeName);
                    availableValues.add(new SelectOption(code.Code_254__c, code.Code_254__c));               
                }
            }
            return availableValues;
        }
        private set;
    }
    
     public List<SelectOption> selectedValues {
        get {
            selectedValues = new List<SelectOption>();   
            selectedValues.add(new SelectOption('', '-Select a Primary Code-'));                                 
            for (String codeName : jquerySelected) {
                selectedValues.add(new SelectOption(codeName.trim(), codeName.trim()));               
            }

            return selectedValues;
        }
        private set;
    }
    
    public PageReference saveCode() {
        
        String codes = '';
        String Acode = '';
        String codeText = '';
        
        for (String cd : jquerySelected) {
            Acode += cd.substring(0,3) + ';';

            //codes += cd + ';';
            codeText += cd + '\n';
        }
        proj.Code_254_Text__c = codeText;
        proj.Code_254__c = Acode;
        
        
        update proj;
        
        return null;
        
        
    }
    
    @istest (SeeAllData=false)
    static void testProject254() {
        Account acct = new Account(Name='Test Account');
        insert acct; 
        Project__c proj = new Project__c();
        proj.Name = 'Test Project';
        proj.Code_254_Text__c = 'X01 Test 1\nX02 Test 2';
        proj.Code_254__c = 'X01;X02';
        proj.Owner__c=acct.Id;
        proj.project_description__c = 'Test';
        insert proj;
        
        ApexPages.standardController ctl = new ApexPages.standardController(proj);
        
        Project254Extension ext = new Project254Extension(ctl);
        
        List<SelectOption> avail = ext.availableValues;
        List<SelectOption> selected = ext.selectedValues;
        
        ext.saveCode();
    
        ValidState__c state = new ValidState__c();
        state.Name = 'Test';
        state.State__c = 'Test';
        state.EPA_Region__c = 'Region Test';
        insert state;
        
        
        PRStateProvinceEmirates__c prState = new PRStateProvinceEmirates__c();
        prState.Project_StateProvEmirate__c = state.id;
        prState.ProjectRelated__c = proj.id;
        insert prState;
        
        delete prState;
        
    }
}