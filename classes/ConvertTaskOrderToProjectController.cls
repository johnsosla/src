/*****************************************
PR          ::  PR-05785
Requester   ::  Karishma Sharma
Purpose     ::  Convert a Task Order Type Opportunity to a Project Type Opportunity 
Author      ::  Appirio Offshore(Neeraj Gupta)
Date        ::  13/08/2010  
*****************************************/
public with sharing class ConvertTaskOrderToProjectController {
    public string selectedOption{get;set;}
    public Boolean step1{get;set;}
    public Boolean step2{get;set;}
    public Boolean searchAccount{get;set;}
    public String accountName{get;set;}
    private Opportunity opp;
    public List<Account> accountList{get;set;}
    public String selectedAccountID{get;set;}
    public String What2What{get;set;}

    public string headerString{get;set;}
    public string sectionString{get;set;}
    public string convertString{get;set;}
    /****************************************************
        Constructor
    ****************************************************/
    public ConvertTaskOrderToProjectController (Apexpages.Standardcontroller sc) {

         /* The first 5 lines of code here seem to default this operation to
          * conversion of Task Order to a Project. However, this is invoked
          * from a button labeled: Convert to Project that *should* be accessed
          * from an opportunity that is a 'Program'
          */
         What2What = 'TASK2PROJ'; 
         selectedOption = 'sameAccount';
         headerString = 'Convert Task Order to a Project';
         sectionString = 'Associate the new converted Project:';
         convertString = 'Task Order to a stand-alone Project';
         
         if(ApexPages.currentPage().getParameters().get('proj2prog')=='1') {
             What2What = 'PROJ2PROG';
             headerString = 'Convert Project to Program';
             sectionString = 'Associate the new converted Program:';
             convertString = 'Project to a Program';
         }

         if(ApexPages.currentPage().getParameters().get('proj2task')=='1') {
             What2What = 'PROJ2TASK';
             headerString = 'Convert Project to Task Order';
             sectionString = 'Associate the new converted Task Order:';
             convertString = 'Project to a Task Order';
         }
         /* Radial added code to check for converting 
          * a program to a project -- 11/13/2013, 8:53am -- RLH
          */
         if(ApexPages.currentPage().getParameters().get('prog2proj') == '1') {
             What2What = 'PROG2PROJ';
             headerString = 'Convert Program to Project';
             sectionString = 'Associate the new converted Program:';
             convertString = 'Program to a Project';  
         }

         opp = (Opportunity)sc.getRecord();
         step1=true;
         step2=false;
         selectedAccountID=null;
    }   
    
    /****************************************************
        Cancel
    ****************************************************/
    public PageReference gotoCancel(){
        return(new PageReference('/'+opp.Id));
    }
    
    /****************************************************
        Showing Step2
    ****************************************************/
    public void gotoStep2() {
         step1=false;
         step2=true;
        
    }

    /****************************************************
        Account OptionList
    ****************************************************/
    public List<SelectOption> getOptions() {
        List<SelectOption> options = new List<SelectOption>();
        if(WHAT2WHAT=='PROJ2TASK' || WHAT2WHAT=='PROJ2PROG') {
            options.add(new SelectOption('sameAccount','To the same Account (where Project is currently associated)'));
        } else if(What2What == 'PROG2PROJ') {
            options.add(new SelectOption('sameAccount','To the same Account (where Program is currently associated)'));
        } else {
            options.add(new SelectOption('sameAccount','To the same Account (where Task Order is currently associated)'));
        }
        options.add(new SelectOption('differentAccount','To a different Account'));
        return options;
    }
    
    /****************************************************
        Save with Same Account
    ****************************************************/
    public PageReference saveAccount() {
        
        /* Radial added code-style and some extra fields
         * including subquery to get count of Task Orders
         * which are also Opportunities (that belong to an 
         * opportunity)
         */    
        opp=[Select AccountId
                    , Id
                    , RecordTypeId
                    , RecordType.Name
                    , Master_Contract_lookup__c
                    , Name
                    , Ceiling_Amount_Total__c
                    , Amount
                    , Book_date__c
                    , Program_Estimated_Revenue__c
                    , (SELECT ID FROM Opportunities__r)
                    From Opportunity WHERE id=:opp.Id];
        
        RecordType recordType;
        //----- Sumit Added code for more recordtypes....
        string sArea = '';
        if(opp.RecordType.name.indexOf('APAC')>=0)
            sArea = 'APAC';
        if(opp.RecordType.name.indexOf('EMEA')>=0)
            sArea = 'EMEA&I';
            
        if(opp.RecordType.name.indexOf('Americas')>=0)
            sArea = 'Americas';
        if(opp.RecordType.name.indexOf('CS')>=0)
            sArea = 'CS';
        if(opp.RecordType.name.indexOf('MS')>=0)
            sArea = 'MS';
        string sProj='Project - ' + sArea;
        string sProg ='Program - ' + sArea;
        string sTO ='Task Order - ' + sArea;
        
        if(WHAT2WHAT=='TASK2PROJ')
            recordType=[Select r.Name From RecordType r where name =:sProj limit 1];
        else if(WHAT2WHAT=='PROJ2PROG')
            recordType=[Select r.Name From RecordType r where name =:sProg limit 1];
        /* Radial Web added following 'else if' clause, 11/13/2013, 10:37am -- RLH */
        else if(What2What == 'PROG2PROJ') {
            recordType = [Select r.Name From RecordType r where name =:sProj limit 1];
        } else
            recordType=[Select r.Name From RecordType r where name =:sTO limit 1];
        //------------------------------------------------------------------------
        /*
        if(opp.RecordType.name.indexOf('Asia')>=0)
        {
            if(WHAT2WHAT=='TASK2PROJ')
                recordType=[Select r.Name From RecordType r where name ='Project - Asia' limit 1];
            else if(WHAT2WHAT=='PROJ2PROG')
                recordType=[Select r.Name From RecordType r where name ='Program - Asia' limit 1];
            else
                recordType=[Select r.Name From RecordType r where name ='Task Order - Asia' limit 1];
        }
        else
        {
            if(WHAT2WHAT=='TASK2PROJ')
                recordType=[Select r.Name From RecordType r where name ='Project - North America' limit 1];
            else if(WHAT2WHAT=='PROJ2PROG')
                recordType=[Select r.Name From RecordType r where name ='Program - North America' limit 1];
            else
                recordType=[Select r.Name From RecordType r where name ='Task Order - North America' limit 1];
        }
        */
        
        Opportunity newOpp;
        //newOpp = opp.clone(false, true);

        newOpp = opp;

        newOpp.RecordTypeId = RecordType.Id;
        newOpp.RecordTypeText__c = RecordType.Name; //Radial - Make this change to satisfy validation rule.
        
        if(selectedAccountID!=null&&selectedAccountID!='') {
            newOpp.AccountId=selectedAccountID;
        }
            
        if(What2What == 'TASK2PROJ') {
            newOpp.Master_Contract_lookup__c=null;
        } else if(What2What == 'PROJ2PROG') {
           newOpp.Ceiling_Amount_Total__c = newOpp.Amount;
           newOpp.Amount = 0;
           newOpp.Book_date__c = null;
           //newOpp.RecordTypeText__c = 'Program'; 
           /* Radial Added Code 11/13/2013, 8:51am -- RLH */
        } else if(What2What == 'PROG2PROJ') {
            if(newOpp.Opportunities__r.size() > 0) {
                String error = 'Cannot convert program to project: There are existing Task Orders for this Program.';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
                return null;
            } else {
                newOpp.Ceiling_Amount_Total__c = 0;
                newOpp.Amount = newOpp.Program_Estimated_Revenue__c;
                newOpp.Program_Estimated_Revenue__c = 0;
            }
            /* end Radial Added Code */
        }
        //delete opp;
        upsert newOpp;
        return (new PageReference('/'+newOpp.Id)); 
    }
    
    
    /****************************************************
        Show Search Accounts
    ****************************************************/
    public void gotoSearchAccount() {
         step1=false;
         step2=false;
         searchAccount=true;
        
    }
     
    /****************************************************
        Search Accounts
    ****************************************************/
    public boolean getShowMoreThen100()
    {
       if(accountList==null)
           return false;
       if(accountList.size()>=100)
           return true;
       return false;
    }
     public Pagereference searchAccounts(){
        if(accountName == null || accountName.length()<2){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.label.MIN2CHAR));
            accountList=null;
            return null;
        }
        accountList=Database.query('select  a.id , a.Type__c,a.Street__c,a.City__c, a.Owner.Alias, a.OwnerId, a.Name  from account a where Name like \'%'+String.escapeSingleQuotes(accountName)+'%\' LIMIT 100');
        if(accountList == null || accountList.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.label.NOACTFOUND));
            accountList=null;
            return null;
        }
        return null; 
    }   
}