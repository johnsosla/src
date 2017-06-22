global class ECO_ProjectTask implements Comparable  {
    public static Boolean CONFIG_AUTOSETFLAGS = true;
    public static Boolean CONFIG_AUTOSETDATES = true;

    public pse__Project_Task__c oprojectTask {get; set;}

    // FinancialForce doesn't like when we query fields then try to update the task
    // so we have to start from scratch with only our fields
    public pse__Project_Task__c taskForUpdate;

    public Id id {
        get{return oprojectTask.Id;}
        private set;
    }
    
    public Id topParentTaskId {
        get;
        set;
    }

    public Id parentTaskId {
        get{return oprojectTask.pse__Parent_Task__c;} 
        private set;
    }
    
    public String name {
        get{return oprojectTask.Name;} 
        private set;
    }
    
    public String taskNumber {
        get{return oprojectTask.ProjectTaskNumber__c;} 
        private set;
    }
    
    public String taskName {
        get{return oprojectTask.Name;} 
        private set;
    }

    public Decimal lastChildPeerOrder = -1;
    public Decimal maxChildPeerOrder {get; set; }

    public Decimal peerOrder {
        get { return oprojectTask.pse__Order__c; }
        set { oprojectTask.pse__Order__c = value; }
    }

    public Boolean HasChildrenTasks;

    public Boolean hasChanged {
        get {
            hasChanged = false;
            taskForUpdate = new pse__Project_Task__c(id = this.Id);

            if (children.size() == 0) { 
                ForecastStartDate = oProjectTask.ForecastStartDate__c;
                ForecastEndDate = oProjectTask.ForecastEndDate__c;
                TransactionStartDate = oProjectTask.TransactionStartDate__c;
                TransactionEndDate = oProjectTask.TransactionEndDate__c;
            }

            if (CONFIG_AUTOSETFLAGS) {
                if (oprojectTask.isChargeable__c != isChargeable) {
                    taskForUpdate.isChargeable__c = isChargeable;
                    hasChanged = true;
                }

                if (oprojectTask.isBillable__c != isChargeable) {
                    // taskForUpdate.isBillable__c = isChargeable;
                    // hasChanged = true;
                }
            }

            if (CONFIG_AUTOSETDATES) {
                if (oprojectTask.ForecastStartDate__c != ForecastStartDate) {
                    taskForUpdate.ForecastStartDate__c = ForecastStartDate;
                    hasChanged = true;
                }

                if (oprojectTask.ForecastEndDate__c != ForecastEndDate) {
                    taskForUpdate.ForecastEndDate__c = forecastEndDate;
                    hasChanged = true;
                }    
                if (oprojectTask.TransactionStartDate__c != TransactionStartDate) {
                    taskForUpdate.TransactionStartDate__c = transactionStartDate;
                    hasChanged = true;
                }         
                if (oprojectTask.TransactionEndDate__c != TransactionEndDate) {
                    taskForUpdate.TransactionEndDate__c = transactionEndDate;
                    hasChanged = true;
                }           
            }
            
            if (oprojectTask.HasChildrenTasks__c != hasChildrenTasks) {
                taskForUpdate.HasChildrenTasks__c = hasChildrenTasks;
                hasChanged = true;
            }

            return hasChanged;
        }
        private set;
    }

    public Boolean isChargeable {
        get { return oProjectTask.FinancialTask__c && numChildrenFinancialTasks == 0; } 
        private set; /* {
            if (isChargeable == value) return; 
            isChargeable = value;
            /*
            if (CONFIG_AUTOSETFLAGS) {
                if (oprojectTask.isChargeable__c != isChargeable) {
                    oprojectTask.isChargeable__c = isChargeable;
                    hasChanged = true;
                }
            }
            
            if (oProjectTask.FinancialTask__c && parent != null) {
                parent.isChargeable = false;
            }
            
        }*/
    }
    private Date forecastStartDate;
    private Date forecastEndDate;
    private Date transactionStartDate;
    private Date transactionEndDate;
    
    /*public void setForecastStartDate(Date value) {
        //if (forecastStartDate == value) return;
        forecastStartDate = value;

        if (parent == null || forecastStartDate == null) return;

        if (parent.forecastStartDate == null || forecastStartDate < parent.forecastStartDate) {
            parent.setForecastStartDate(forecastStartDate);
        }
    }

    

    public void setForecastEndDate(Date value) {
        //if (forecastEndDate == value) return;
        forecastEndDate = value;

        if (parent == null || forecastEndDate == null) return;

        if (parent.forecastEndDate == null || forecastEndDate > parent.forecastEndDate) {
            parent.setForecastEndDate(forecastEndDate);
        }

    }
*/

    public ECO_ProjectTask parent {get; set;}
    public List<ECO_ProjectTask> children {get; set;}
    public Integer indentLevel {get; set;}

    public Integer numChildrenFinancialTasks = 0;
    public Boolean hasChildrenFinancialTasks {
        get;
        set {
            hasChildrenFinancialTasks = value;
            if (parent == null) return;

            if (hasChildrenFinancialTasks == true || oProjectTask.FinancialTask__c == true) {
                parent.hasChildrenFinancialTasks = true;
            } 
        }
    }

    public String parentClasses {get; set;}

    public static void recalcAllTasks(List<ECO_ProjectTask> taskList) {
        /*
        for (ECO_ProjectTask task : taskList) {  
            if (task.children.size() == 0) {
                task.setForecastStartDate(task.oProjectTask.ForecastStartDate__c);
                task.setForecastEndDate(task.oProjectTask.ForecastEndDate__c);
            }
        }
        */
    }

    public ECO_ProjectTask() {
        children = new List<ECO_ProjectTask>();
        hasChanged = false;
        hasChildrenTasks = false;
        maxChildPeerOrder = -1;
    }

    public ECO_ProjectTask(pse__Project_Task__c projectTask) {
        this();
        oprojectTask = projectTask;
        // if (peerOrder == null) peerOrder = 0;
    }

    public void addChild(ECO_ProjectTask child) {
        children.add(child);
        child.parent = this;
        compareOrder(child); // Set pse__Order__c
        child.topParentTaskId = this.topParentTaskId;
        compareDates(child);
        hasChildrenTasks = true;
        if (child.oProjectTask.FinancialTask__c) {
            this.numChildrenFinancialTasks++; 
        }
    }

    public void compareOrder(ECO_ProjectTask child ) {
        if (child.peerOrder == null) {
            child.peerOrder = ++maxChildPeerOrder;
        } else {
            if( maxChildPeerOrder < child.peerOrder ) {
                maxChildPeerOrder = child.peerOrder;
            }
        }
    }
    public void compareDates(ECO_ProjectTask child) {
        if (child.children.size() == 0) {
            child.forecastStartDate = child.oProjectTask.forecastStartDate__c;
            child.forecastEndDate = child.oProjectTask.forecastEndDate__c;
            child.transactionStartDate = child.oProjectTask.TransactionStartDate__c;
            child.transactionEndDate = child.oProjectTask.TransactionEndDate__c;
        }

        if(child.forecastStartDate != null) {
            if(forecastStartDate == null || child.forecastStartDate < ForecastStartDate) {
                forecastStartDate =  child.forecastStartDate; 
            }
        }

        if(child.forecastEndDate != null) {
            if(forecastEndDate == null || child.forecastEndDate > ForecastEndDate) {
                forecastEndDate = child.forecastEndDate; 
            }
        }
        if(child.transactionStartDate != null) {
            if(transactionStartDate == null || child.transactionStartDate < TransactionStartDate) {
                transactionStartDate = child.transactionStartDate; 
            }
        }
        if(child.transactionEndDate != null) {
            if(transactionEndDate == null || child.transactionEndDate > TransactionEndDate) {
                transactionEndDate = child.transactionEndDate; 
            }
        }
    }

    public static Map<Id, ECO_ProjectTask> init(Map<Id,pse__Project_Task__c> tNewMap) {
            Map<Id, pse__Project_Task__c> mapTasksById;
            Set<Id> projectIds = new Set<Id>();
            Map<Id, String> mapStageByProjectId = new Map<Id, String>();
            //Map<Id, pse__Project_Task__c> tNewMap = new Map<Id, pse__Project_Task__c>(tNew);
            // tasksToUpdateForecasts = new Map<Id,pse__Project_Task__c>();

            for (pse__Project_Task__c task : tNewMap.values()) {
                projectIds.add(task.pse__Project__c);
            }

            for (pse__Proj__c proj : [Select Id, pse__Stage__c From pse__Proj__c Where Id IN :projectIds]) {
                mapStageByProjectId.put(proj.Id, proj.pse__Stage__c);
            }

            mapTasksById =  new Map<Id, pse__Project_Task__c>(
                [SELECT Id, Name, pse__Project__c, pse__Project__r.pse__Stage__c, pse__Parent_Task__c, ForecastStartDate__c, ForecastEndDate__c, TransactionStartDate__c, TransactionEndDate__c ,
                    (SELECT Id, Name, pse__Project__c, pse__Parent_Task__c, ForecastStartDate__c, ForecastEndDate__c, TransactionStartDate__c, TransactionEndDate__c 
                    FROM pse__Immediate_Sub_Tasks__r)
                 FROM pse__Project_Task__c 
                 WHERE pse__Project__c IN :projectIds]);

            for (pse__Project_Task__c task : mapTasksById.values()) {

            }

            return new Map<Id, ECO_ProjectTask>();
        }

    global Integer compareTo(Object compareTo) {
        ECO_ProjectTask compareToTask = (ECO_ProjectTask)compareTo;
        if (oprojectTask.pse__Hierarchy_Depth__c == compareToTask.oprojectTask.pse__Hierarchy_Depth__c) return 0;
        if (oprojectTask.pse__Hierarchy_Depth__c > compareToTask.oprojectTask.pse__Hierarchy_Depth__c) return -1;
        return 1;
    }
}