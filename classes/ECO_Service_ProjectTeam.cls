public with sharing class ECO_Service_ProjectTeam {


    public static Id getActiveProjectAccountantId(Id projectId)
    {
    	list<ProjectTeamMember__c> teamMembers = [select Id, User__c, Contact__r.pse__Salesforce_User__c from ProjectTeamMember__c where ProjectRole__r.Name = 'Project Accountant' and Project__c = :projectId and Active__c = true];
		if(!teamMembers.isEmpty())
		{
			return teamMembers[0].Contact__r.pse__Salesforce_User__c;
		}
    	return null;
    }


    public static Id getActiveProjectApproverId(Id projectId)
    {
    	list<ProjectTeamMember__c> teamMembers = [select Id, User__c, Contact__r.pse__Salesforce_User__c from ProjectTeamMember__c where ProjectRole__r.Name = 'Project Approver' and Project__c = :projectId and Active__c = true];
		if(!teamMembers.isEmpty())
		{
			return teamMembers[0].Contact__r.pse__Salesforce_User__c;
		}
    	return null;
    }
    
    public static Id getActiveProjectFinanceLead(Id projectId)
    {
    	list<ProjectTeamMember__c> teamMembers = [select Id, User__c, Contact__r.pse__Salesforce_User__c from ProjectTeamMember__c where ProjectRole__r.Name = 'Finance Lead' and Project__c = :projectId and Active__c = true];
		if(!teamMembers.isEmpty())
		{
			return teamMembers[0].Contact__r.pse__Salesforce_User__c;
		}
    	return null;
    }    
    
    public static Id getActiveCFODelegate(Id projectId)
    {
    	list<ProjectTeamMember__c> teamMembers = [select Id, User__c, Contact__r.pse__Salesforce_User__c from ProjectTeamMember__c where ProjectRole__r.Name = 'CFO or Delegate' and Project__c = :projectId and Active__c = true];
		if(!teamMembers.isEmpty())
		{
			return teamMembers[0].Contact__r.pse__Salesforce_User__c;
		}
    	return null;
    }     

    public static Id getProjectManagerFromProjectTeam(Id projectId)
    {
        ProjectRole__c role = [select Id from ProjectRole__c where Name = 'Project Manager'];

        list<ProjectTeamMember__c> projectTeamMembers = [select Id, Role__c, Active__c, Contact__r.pse__Salesforce_User__c from ProjectTeamMember__c 
                                                         where Project__c = :projectId and Active__c = true 
                                                            and ProjectRole__c = :role.Id];    
                                                                     
        if(!projectTeamMembers.isEmpty())
            return projectTeamMembers[0].Contact__r.pse__Salesforce_User__c;
                
        return null;
    }

    public static Id populateProjectAccountant(Id projectId)
    {
        list<ProjectTeamMember__c> teamMembers = [select Id, User__c, Contact__r.pse__Salesforce_User__c from ProjectTeamMember__c where ProjectRole__r.Name = 'Project Accountant' and Project__c = :projectId and Active__c = true];
        if(!teamMembers.isEmpty())
        {
            return teamMembers[0].Contact__r.pse__Salesforce_User__c;
        }
        return null;
    }

    public static Id populateProjectFinanceLead(Id projectId)
    {
        list<ProjectTeamMember__c> teamMembers = [select Id, User__c, Contact__r.pse__Salesforce_User__c from ProjectTeamMember__c where ProjectRole__r.Name = 'Finance Lead' and Project__c = :projectId and Active__c = true];
        if(!teamMembers.isEmpty())
        {
            return teamMembers[0].Contact__r.pse__Salesforce_User__c;
        }
        return null;
    }    

    public static Id getActiveUserIdForProjectRole(Id projectId, String projectRole)
    {
        list<ProjectTeamMember__c> teamMembers = [select Id, User__c, Contact__r.pse__Salesforce_User__c from ProjectTeamMember__c where ProjectRole__r.Name = :projectRole and Project__c = :projectId and Active__c = true];
        if(!teamMembers.isEmpty())
        {
            return teamMembers[0].Contact__r.pse__Salesforce_User__c;
        }
        return null;
    }      

    public static void CheckMembers(list<CheckMember> lstChecks){

        if(lstChecks == null || lstChecks.size() == 0){
            return;
        }

        set<id> setProj = new set<id>();
        set<string> setRoleNmae = new set<string>();
        set<id> setUser = new set<id>();


        for(CheckMember c: lstChecks){
            setProj.add(c.projectid);
            setRoleNmae.add(c.roleName);
            setUser.add(c.userid);
        }

        map<id, user> mapUser = new map<id, user>([select id, Name from user where id IN: setUser]);

        list<ProjectTeamMember__c> teamMembers = [select Id
                                                        , User__c
                                                        , Contact__r.pse__Salesforce_User__c 
                                                        , Status__c
                                                        , Project__c
                                                        , Active__c
                                                        , ProjectRole__r.Name
                                                        , Name__c
                                                        , Contact__c
                                                    from ProjectTeamMember__c 
                                                    where Project__c IN: setProj
                                                    and Active__c = true ];
                                                        //and ProjectRole__r.Name IN: setRoleNmae
                                                        

        map<string, ProjectTeamMember__c> mapPTM = new map<string, ProjectTeamMember__c>();
        for(ProjectTeamMember__c ptm: teamMembers){
            if(setRoleNmae.contains(ptm.ProjectRole__r.Name)){
                string strKey = ptm.Project__c + '-' + ptm.ProjectRole__r.Name;
                if( mapPTM.containskey(strkey) && mapPTM.get(strkey).Status__c != 'Approved'){ //&& ptm.Status__c == 'Approved'){
                    mapPTM.remove(strkey);
                }
                mapPTM.put(strKey, ptm);
            }
        }
        
        try{
            for(CheckMember c: lstChecks){
                string strKey = c.projectid + '-' + c.roleName;
                if(mapPTM.containskey(strKey)){
                    ProjectTeamMember__c ptm = mapPTM.get(strKey);

                    if(ptm.Status__c != 'Approved'){
                        c.errormsg = 'The Project Team Member '+ ptm.Name__c + ' is not an approved ' + c.roleName;   
                    }
                    else{
                        c.approvedPTM = ptm;
                    }
                    
                }else{ 
                    c.errormsg = 'The Project Team Member  ' + c.roleName + ' has not been found or is not active';
                }
            }
        }catch(Exception e){
            ECO_Service_ErrorLog.logException(e);
        }
    }


    public class CheckMember{
        public id projectid {get;set;}
        public string roleName {get;set;}
        public id userid {get;set;}
        public string errormsg {get;set;}
        public string userRoleKey {get;set;}
        public ProjectTeamMember__c approvedPTM {get;set;}

        public checkMember(id projectid, string roleName,id userid){
            this.projectid = projectid;
            this.roleName = roleName;
            this.userid = userid;
            this.errormsg = null;
            this.approvedPTM = new ProjectTeamMember__c();
        }
        public checkMember(id projectid, string roleName){
            this.projectid = projectid;
            this.roleName = roleName;
            this.userid = userid;
            this.errormsg = null;
            this.approvedPTM = new ProjectTeamMember__c();
        }
    }


}