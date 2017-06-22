public with sharing  class ECO_ApprovalCommentsApproverController{

    public String getApproverName { 
        get{
            getApproverName();
            return ApproverName; 
           }
           private set;
    }
    
    public String getComment { 
        get{
            getComment();
            return Comment; 
           }  
           private set;
    }

    public id objId {get;set;}
    public string StepStatusMessage {get;set;}
    public List<ProcessInstanceStep> ProcessInstanceSteps;
    public string Comment {get;set;}
    public string ApproverName {get;set;}
    
    public string getComment(){
    setData();
    return Comment ;
    }
    
    public string getApproverName(){
    setData();
    return ApproverName;
    }
    
    
    public ECO_ApprovalCommentsApproverController() {
         ApproverName=' ';
         Comment = ' ';

        }
    
              

    public void setData(){
        if(ProcessInstanceSteps == null || ProcessInstanceSteps.size()==0){
        ProcessInstanceSteps = new List<ProcessInstanceStep>([Select p.Comments, p.ProcessInstance.TargetObjectId, ActorId, Actor.firstname, Actor.lastname from ProcessInstanceStep p WHERE p.ProcessInstance.TargetObjectID = :objId AND StepStatus=:StepStatusMessage ORDER BY createddate desc]);
        
            if(ProcessInstanceSteps.size() > 0){
                Comment = ProcessInstanceSteps[0].Comments;
                ApproverName = ProcessInstanceSteps[0].Actor.firstname + ' ' + ProcessInstanceSteps[0].Actor.lastname;
            }
            else {
               Comment = '';
               ApproverName = '';
               
             }
        }
       }



}