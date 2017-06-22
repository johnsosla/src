public without sharing class ECO_ApprovalCommentsController 
{
    public string ApprovalComments {get;set;}
    public id objId { get; set; }
    public string StepStatusMessage { get; set; }
    public List<ProcessInstanceStep> ProcessInstanceSteps;
    public string Comment {get;set;}
    public string ApproverName {get;set;}

    public ECO_ApprovalCommentsController() {
        ApprovalComments = 'Approval email Comments';
    }

    public string getQuoteApprovalComment(){ 
        setData();
        return Comment; 
    }

    public string getQuoteApprovalPerson(){ 
        setData();
        return ApproverName; 
    }   

    public void setData()
    {
        if(ProcessInstanceSteps == null || ProcessInstanceSteps.size() ==0)
        {
            if (objId!=null)
            {
                //ProcessInstanceSteps= new List<ProcessInstanceStep>([Select Comments, ProcessInstance.TargetObjectId, ActorId, Actor.firstname, Actor.lastname from ProcessInstanceStep WHERE ProcessInstance.TargetObjectID = :objId AND StepStatus =:StepStatusMessage ORDER BY createddate desc]);
                ProcessInstanceSteps= [Select Comments, ProcessInstance.TargetObjectId, ActorId, Actor.firstname, Actor.lastname from ProcessInstanceStep WHERE ProcessInstance.TargetObjectID = :objId AND StepStatus =:StepStatusMessage ORDER BY createddate desc];
                /*
                ProcessInstanceSteps= objId != null 
                    ? [Select p.Comments, p.ProcessInstance.TargetObjectId, ActorId, Actor.firstname, Actor.lastname from ProcessInstanceStep p  WHERE p.ProcessInstance.TargetObjectID = :objId AND StepStatus =:StepStatusMessage ORDER BY createddate desc]
                    : new List<ProcessInstanceStep>();
                */    
                if (ProcessInstanceSteps.size()>0)
                {
                    if (!String.IsBlank(ProcessInstanceSteps[0].Comments))
                        Comment = ProcessInstanceSteps[0].Comments;
                    else
                        Comment = null;
                    
                    if (ProcessInstanceSteps[0].Actor.firstname != null && ProcessInstanceSteps[0].Actor.lastname != null)
                        ApproverName = ProcessInstanceSteps[0].Actor.firstname + ' ' + ProcessInstanceSteps[0].Actor.lastname;
                    else
                        ApproverName = null;
                }
                else
                {
                    Comment = null;
                    ApproverName = null;
                }
            }
            else
            {
                Comment = null;
                ApproverName = null;
            }
        }       
    }
}