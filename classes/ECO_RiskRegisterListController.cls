public class ECO_RiskRegisterListController {
    public pse__Proj__c thisProject {get; set;}
    public Decimal totalPostMitigation {get;set;}
    public Decimal totalApprovedCost {get;set;}
    public Decimal totalForecastCost {get;set;}
    public Id activityId {get;set;}
    
    public ApexPages.StandardController oStandardController {get; set;}
    
    public ECO_RiskRegisterListController(ApexPages.StandardController oStandardController){
        this.oStandardController = oStandardController; 
        thisProject = (pse__Proj__c)oStandardController.getRecord();
        calculateTotals();
    }
    public void calculateTotals(){
        totalApprovedCost =0;
        totalForecastCost =0;
        List <BudgetHeader__c> lBudgetHeader = new List<BudgetHeader__c> ([Select Id, Status__c, Project__c, TotalContingencyAmount__c From BudgetHeader__c Where Project__c =: thisProject.Id AND (Status__c = 'Forecast' OR Status__c = 'Approved')]);
        //List <BudgetHeader__c> approved = new List<BudgetHeader__c> ([Select Id, Status__c, Project__c, TotalContingencyAmount__c From BudgetHeader__c Where Project__c =: thisProject.Id AND Status__c = 'Approved']);
        for(BudgetHeader__c oBH : lBudgetHeader){
            if(oBH.Status__c == 'Approved')
                totalApprovedCost = totalApprovedCost + oBH.TotalContingencyAmount__c;
            //if(oBH.Status__c == 'Forecast')
            totalForecastCost = totalForecastCost + oBH.TotalContingencyAmount__c;
        }
        thisProject.TotalContingencyApproved__c = totalApprovedCost;
        thisProject.TotalContingencyForecast__c = totalForecastCost;
        totalApprovedCost = totalApprovedCost.setScale(2);
        totalForecastCost = totalForecastCost.setScale(2);
    }
    public PageReference returnProj(){
        return new PageReference('/' + thisProject.Id);
    }
    public PageReference newRisk(){
        Id riskId;
        Risk__C oRisk = new Risk__c();
        oRisk.Project__c = thisProject.id;
        oRisk.Name = 'New Risk';
        try{
            Insert oRisk;
        }catch (DmlException e){
            System.debug('Exception: '+e);
        }
        //System.debug('oRisk id:  '+oRisk.Id);
        //System.debug('oRisk project id:  '+oRisk.Project__c);

        //return new PageReference('/a4f/e?CF00Ne00000016atX='+thisProject.Name+'&CF00Ne00000016atX_lkid='+thisProject.id);
        return new PageReference('/'+oRisk.Id+'/e?retURL=/apex/ECO_RiskRegisterList?id='+thisProject.id);
    }
    public List<Risk__c> getRisks(){
        totalPostMitigation = 0;
        List <Risk__c> riskList = new List<Risk__c>([Select id, Name, CurrentStatus__c, EventPhase__c, RiskOwner__c, Premitigationrating__c, ContingencyDollars__c, RiskMitigation__c, MitigationCostTotal__c, Postmitigationrating__c, PostmitigationContingencyTotal__c From Risk__c Where Project__c = :thisProject.Id]);
        for(Risk__c oRisk :riskList){
            if(oRisk.CurrentStatus__c != 'Expired' && oRisk.CurrentStatus__c != 'Cancelled')
                totalPostMitigation = totalPostMitigation + oRisk.PostmitigationContingencyTotal__c;
        }
        thisProject.TotalPostMitigation__c = totalPostMitigation;
        totalPostMitigation = totalPostMitigation.setScale(2);
        //System.debug('riskList.size:  '+riskList.size());
        //System.debug('thisProject.Id:  '+thisProject.Id);

        return riskList;
        
    }
    
    public List<OpenActivity> getActivitiesOpen(){
        List<OpenActivity> actRList = new List<OpenActivity>();
        List<pse__Proj__c> lProjects = [ Select (Select o.What.Name , o.PrimaryWhoId, o.WhatId, o.IsTask, o.ActivityDate, o.Subject, o.OwnerId, o.Status, o.Priority, o.LastModifiedDate, o.EndDateTime From OpenActivities o) from pse__Proj__c where ID =: thisProject.id];
        
        for(pse__Proj__c proj : lProjects){
            if(!proj.OpenActivities.isempty()){
                for(OpenActivity opnAct: proj.OpenActivities){  
                    actRList.add(opnAct);
                }
            }
        }
        return actRList;
    }
    
    public PageReference deleteActivity(){
        Task t = new Task();
        Event e = new Event();
        Boolean isTask;
        List<OpenActivity> actRList = new List<OpenActivity>();
        for(pse__Proj__c proj:[ Select (Select o.What.Name , o.PrimaryWhoId, o.WhatId, o.IsTask, o.ActivityDate, o.Subject, o.OwnerId, o.Status, o.Priority, o.LastModifiedDate, o.EndDateTime From OpenActivities o Where o.Id = :activityId) from pse__Proj__c where ID =: thisProject.id]){
            if(!proj.OpenActivities.isempty()){
                for(OpenActivity opnAct: proj.OpenActivities){  
                    actRList.add(opnAct);
                    if(opnAct.IsTask){
                        t.id = opnAct.Id;
                        isTask = true;
                    }
                    else{
                        e.Id = opnAct.Id;
                        isTask = false;
                    }
                }
            }
        }
        if(isTask)
            delete t;
        else
            delete e;
        return null;
    }
    
    public Pagereference newTask(){
 
        Id taskRecordTypeId = ECO_Utils_Meta.getRecordTypeId(Task.sObjectType, 'ECOTasks');
       
        Task t = new Task();
        t.WhatId = thisProject.Id;
        t.RecordTypeId = taskRecordTypeId;
        insert t;

        PageReference pageRef = new PageReference('/' + t.Id + '/e');
        pageRef.getParameters().put('retURL', '/apex/ECO_RiskRegisterList?id=' + thisProject.Id);
        return PageRef;

    }
    
    public Pagereference newEvent(){
 
        Id eventRecordTypeId = ECO_Utils_Meta.getRecordTypeId(Event.sObjectType, 'EcoProjectEvent');
       
        Event e = new Event();
        e.WhatId = thisProject.Id;
        e.RecordTypeId = eventRecordTypeId;
        e.DurationInMinutes = 60;
        e.ActivityDateTime = DateTime.now()+60;
        insert e;

        PageReference pageRef = new PageReference('/' + e.Id + '/e');
        pageRef.getParameters().put('retURL', '/apex/ECO_RiskRegisterList?id=' + thisProject.Id);
        return PageRef;

    }
    
    public PageReference deleteRisk(){
        Id riskId = ApexPages.currentPage().getParameters().get('recid');
        Risk__c riskRecord = [Select id From Risk__c where id = :riskId];
        //System.debug('riskRecord id:  '+riskRecord.Id);
        if(riskRecord != null)
            delete riskRecord;
        return null;
    }
    
    public PageReference exportCSV(){
        String reportId = ReportDetails__c.getInstance('Project Risks').Report_Id__c;
        String projectId = thisProject.id;
        projectId = projectId.substring(0, 15);
        //System.debug('reportId:  '+reportId);
        return new PageReference('/'+reportId+'?pv0='+projectId);
    }
}