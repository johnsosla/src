public with sharing class ConvertProjectToTaskOrderController {
    
    public Map<String,RecordType> recordTypesMap = new Map<String,RecordType>();
    
    public String opportunityName{get;set;}
    
    public Opportunity projOrder{get;set;}
    
    public List<Opportunity> masterContracts{get;set;}
    public integer currentStep{get;set;}
    public Opportunity newTask {get;set;}
    public string selectedOption{get;set;}
    private id currentAccountidofOpp;
    public ConvertProjectToTaskOrderController(ApexPages.StandardController controller)
    {
        currentStep =1;
        selectedOption = 'sameAccount';
        recordTypesMap = TaskOrderRollup.getOpportunityRecordtypeMapByName();
        projOrder = (Opportunity) controller.getRecord();
        List<Opportunity> projOrders= [Select AccountId,Id,RecordTypeId,RecordType.Name, Master_Contract_lookup__c  From Opportunity o where id =:projOrder.ID Limit 1 ];
        newTask = new Opportunity();
        
        if(projOrders.size()!= 0 ){
            projOrder=projOrders.get(0);
            currentAccountidofOpp = projOrders[0].AccountId;
        }   
    } 
    public boolean getShowMoreThen100()
    {
       if(masterContracts==null)
           return false;
       if(masterContracts.size()>=100)
           return true;
       return false;
    }
     public Pagereference searchOpportunities()
     {
         searchOpportunities1();
         return null;
     }
    private string taskOrderNAME = '';
    public Boolean searchOpportunities1(){
        if((opportunityName == null || opportunityName.length()<2) && selectedOption != 'sameAccount'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.label.MIN2CHAR));
            masterContracts=null;
            return false;
        }
        string Error='';
        //---------------Sumit Add for different record type-----------------------------
        string sArea = '';
        if(projOrder.RecordType.name.indexOf('APAC')>=0)
            sArea = 'APAC';
        if(projOrder.RecordType.name.indexOf('EMEA')>=0)
            sArea = 'EMEA&I';
        if(projOrder.RecordType.name.indexOf('Americas')>=0)
            sArea = 'Americas';
        if(projOrder.RecordType.name.indexOf('CS')>=0)
            sArea = 'CS';
        if(projOrder.Recordtype.name.indexOf('MS')>=0)
            sArea = 'MS';
        string RecordTypename ='Program - ' + sArea;
        taskOrderNAME = 'Task Order - ' + sArea;
        //string RecordTypename ='Program - North America';
        //if(projOrder.RecordType.Name.indexOf('Asia')>=0)
        //    RecordTypename ='Program - Asia';
        if(selectedOption == 'sameAccount')
        {
            masterContracts=Database.query('select Master_Contract_Number__c,ID,Name,Account.Name,CloseDate,Business_Line_of_Primary_AECOM_Dept__c,Project_State_Province__c,ProjectCountry__c,Master_Contract_lookup__c from Opportunity where AccountId=:currentAccountidofOpp AND RecordType.Name=:RecordTypename Order By CloseDate DESC');
            Error = System.label.NOPROGOPPPLSCREATE;           
        }
        else
        {
            masterContracts=Database.query('select Master_Contract_Number__c,ID,Name,Account.Name,CloseDate,Business_Line_of_Primary_AECOM_Dept__c,Project_State_Province__c,ProjectCountry__c,Master_Contract_lookup__c from Opportunity where Account.Name like \'%'+ String.escapeSingleQuotes(opportunityName)+'%\' and RecordType.Name=:RecordTypename Order By CloseDate DESC');
            Error = System.label.NOPROGOPPPLSCREATE;
        }
        
        if(masterContracts == null || masterContracts.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,Error));
            masterContracts=null;
            return false;
        }
        return true; 
    }
    public string masterId{get;set;}
    public Pagereference createNewTaskOrder(){
        try{
            if(masterId == null || masterId  == ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.label.SELECTMASTERCON));
                return null;
            }
            newTask.Master_Contract_lookup__c = masterId;
            String mContract = newTask.Master_Contract_lookup__c;
            //newTask = projOrder.clone(false,true);
            newTask = projOrder;
            newTask.RecordTypeId = recordTypesMap.get(taskOrderNAME.toLowerCase()).id;
            //if(projOrder.RecordType.Name.indexOf('Asia')>=0)
            //    newTask.RecordTypeId = recordTypesMap.get('Task_Order_Asia'.toLowerCase()).id;
            //else
            //    newTask.RecordTypeId = recordTypesMap.get('Task_Order_North_America'.toLowerCase()).id;
                
            newTask.Master_Contract_lookup__c = mContract;
            for(Opportunity oppm: [Select AccountId from Opportunity where id=:mContract])
                newtask.AccountId = oppm.AccountId;
            //delete projOrder;
            Upsert newTask;
            return new Pagereference('/'+newTask.ID);
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage()));
            return null;
        }
    }
    public Pagereference cancel(){
        return  new Pagereference('/'+projOrder.ID);
    }
    //-------------------------------------------------------------------------------------------
    public List<SelectOption> getOptions() 
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('sameAccount','To the same Account (where Project is currently associated)'));
        options.add(new SelectOption('differentAccount','To a different Account'));
        return options;
    }
    public void goNext()
    {
        if(selectedOption == 'sameAccount')
        {
            boolean b=searchOpportunities1();
            if(!b)
                return;
        }
        currentStep=2;
    }
    public void goPrevious()
    {
        currentStep=1;
    }
}