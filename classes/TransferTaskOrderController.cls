/*****************************************
PR          ::  PR-05787
Requester   ::  Karishma Sharma
Purpose     ::  transfer a Task Order from existing Program Opportunty to another Program Opportunity
Author      ::  Appirio Offshore(Shailendra Singh)
Date        ::  11/08/2010  
*****************************************/
public with sharing class TransferTaskOrderController {
    
    public String opportunityName{get;set;}
    
    public Opportunity taskOrder{get;set;}
    
    public List<Opportunity> masterContracts{get;set;}
    
    public TransferTaskOrderController(){
        String taskOrderID=Apexpages.currentPage().getParameters().get('taskOrderID');
        List<Opportunity> taskOrders=[select ID,Master_Contract_lookup__c,RecordType.name from Opportunity where ID=:taskOrderID and RecordType.Name Like '%Task Order%' limit 1];
        if(taskOrders != null && taskOrders.size()!= 0 )
            taskOrder=taskOrders.get(0);     
    }  
    public Pagereference searchOpportunities(){
        if(opportunityName == null || opportunityName.length()<2){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.label.MIN2CHAR));
            masterContracts=null;
            return null;
        }
        string RecType = 'Program - Americas';
        if(taskOrder.Recordtype.Name.indexof('APAC')>=0)
            RecType = 'Program - APAC';
        masterContracts=Database.query('select Master_Contract_Number__c,ID,Name,Account.Name,CloseDate,Business_Line_of_Primary_AECOM_Dept__c,Project_State_Province__c,ProjectCountry__c,Master_Contract_lookup__c from Opportunity where Account.Name like \'%'+String.escapeSingleQuotes(opportunityName)+'%\' and RecordType.Name=:RecType Order By CloseDate DESC');
        if(masterContracts == null || masterContracts.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,System.label.NOOPPFOUND));
            masterContracts=null;
            return null;
        }
        return null;  
    }
    
    public Pagereference updateTaskOrder()
    {
        if(taskOrder.Master_Contract_lookup__c!=null)
        {
            for(Opportunity opp:[Select AccountId from Opportunity where id=:taskOrder.Master_Contract_lookup__c])
                taskOrder.AccountId = opp.AccountId;
         }
        update taskOrder;
        return  new Pagereference('/'+taskOrder.ID);
    }
    public Pagereference cancel(){
        return  new Pagereference('/'+taskOrder.ID);
    }
}