// Nancy Balaban 5/1/2012 Used to pick Profile 300 codes
public with sharing class Code330Pick {

// Variables to store     
    public String CodeP { get; set; }
    
    // Generates  dropdown from custom settings 
    
    public List<SelectOption> getProfileCodeSelectList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- Select One --'));        

        // Find all the countries in the custom setting 
    
        Map<String, Code330__c> ProfileCode = Code330__c.getAll();
        
        // Sort them by name 
    
        List<String> CodePNames = new List<String>();
        CodePNames.addAll(ProfileCode.keySet());
        CodePNames.sort();
        
        // Create the Select Options. 
   
        for (String CodePName : CodePNames) {
            Code330__c CodeP = ProfileCode.get(CodePName);
            options.add(new SelectOption(CodeP.Code_330__c, CodeP.Code_330__c));
        }
        return options;
    }
    }