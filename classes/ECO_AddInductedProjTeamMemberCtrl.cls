public with sharing class ECO_AddInductedProjTeamMemberCtrl {

    public ApexPages.StandardController stdController {get; set;}
    public Id projectId {get;set;}
    public Id inductionId {get;set;}
    public Id PTMid {get;set;}
	public InductedProjectTeamMembers__c teamMember {get; set;}
    public pse__Proj__c theProject {get; set;}
    public Induction__c induction {get;set;}
    public ECO_AddInductedProjTeamMemberCtrl(ApexPages.StandardController stdcontroller) {
		teamMember = (InductedProjectTeamMembers__c)stdcontroller.getRecord();
        
            
            
    }
    public void init(){
        System.debug('teamMember::::::'+teamMember);
        projectId = ApexPages.currentPage().getParameters().get('projectId');
        
        inductionId = ApexPages.currentPage().getParameters().get('inductionId');
        PTMid = ApexPages.currentPage().getParameters().get('Id');
        System.debug('projectId::::'+projectId+'    inductionId::::'+inductionId);
        
        if(teamMember.Id == null && projectId != null && inductionId != null){
            theProject = [Select Id From pse__Proj__c Where Id = :projectId];
            induction = [Select Id From Induction__c Where Id = :inductionId];
            teamMember.Project__c = theProject.Id;
            teamMember.Induction__c = induction.Id;
        }
        else if(PTMid != null || PTMid != ''){
            System.debug('teamMember:::'+teamMember+'   projectId::::'+projectId+'   inductionId:::'+inductionId);
            teamMember = [Select Id, Name, ProjectTeamMember__c,Induction__c, Project__c, TeamMember__c From InductedProjectTeamMembers__c Where Id = :PTMid];
        }
        else{
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You have reached this page incorrectly.' );
	        ApexPages.addMessage(oMsg);
            return;
        }
        try{
            if(teamMember.Id == null)
            	insert teamMember;
            System.debug('teamMember id:::'+teamMember.Id);
        }catch(Exception e){
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An error occured while saving record:'+e );
            ApexPages.addMessage(oMsg);
            
        }
        
    }
    public PageReference saveInductionTeamMember(){
        
        try{
            update teamMember;
            PageReference pageRef = new PageReference('/apex/ECO_AddInductedProjTeamMember?Id='+teamMember.Id); 
            pageref.setRedirect(true);
			return pageRef;
            //return null;
        }catch(Exception e){
            ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An error occured while saving record:'+e );
	        ApexPages.addMessage(oMsg);
            return null;
        }
    }
    public PageReference saveAndNew(){
        update teamMember;
        theProject = [Select Id From pse__Proj__c Where Id = :teamMember.Project__c];
        induction = [Select Id From Induction__c Where Id = :teamMember.Induction__c];
        System.debug('inductionId='+inductionId+'&projectId='+projectId);
        PageReference pageRef = new PageReference('/apex/ECO_AddInductedProjTeamMember?inductionId='+induction.Id+'&projectId='+theProject.Id); 
        pageref.setRedirect(true);
		return pageRef;
        
    }
    public PageReference returnToInduction(){
        //init();
        PageReference pageRef = new PageReference('/'+teamMember.Induction__c); 
        pageref.setRedirect(true);
		return pageRef;
    }

}