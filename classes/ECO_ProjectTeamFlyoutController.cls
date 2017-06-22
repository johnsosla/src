public class ECO_ProjectTeamFlyoutController {
    public id sProjectId {get; set;}
    private boolean bInitialDefault;
    public List<ProjectRole__c> lRoles;

    public ECO_ProjectTeamFlyoutController() {
        oProjectTeamMember = new ProjectTeamMember__c();
        bInitialDefault = true;
        lRoles = new List<ProjectRole__c>([Select Id, Name, Type__c From ProjectRole__c Where Active__c = true and Type__c = 'Team Member' 
                                                                    AND Name <> 'Project Owner' AND Name <> 'Capture Manager' 
                                                                    AND Name <> 'Client Account Manager' AND Name <> 'Go/No Go Approver' 
                                                                    Order By Name ASC]);

    }
    
    public list<SelectOption> lTeamRoleTypes{
        get{
            lTeamRoleTypes = new List<SelectOption>();
            lTeamRoleTypes.add(new SelectOption('',Label.EcoGeneralNone));     
            for(ProjectRole__c role : lRoles) 
            {
                lTeamRoleTypes.add(new SelectOption(role.Id, role.Name));
            }
            return lTeamRoleTypes;
        }
        set;
    }

    public ProjectTeamMember__c oProjectTeamMember {
    
        get{
            if(bInitialDefault){
                oProjectTeamMember.Project__c = sProjectId;
                bInitialDefault = false;
            }

            return oProjectTeamMember;
        }

        set;
    }
    
    public list<ProjectTeamMember__c> lProjectTeamMembers {
        get{
            string sSOQL = 'SELECT ';

            sSOQL += ' Id, Name, Contact__c, ProjectRoleTitle__c, Email__c, Phone__c, ProjectRole__c, ProjectRole__r.Type__c FROM ProjectTeamMember__c WHERE Project__c =\'' + sProjectId + '\'';
            sSOQL += ' and (ProjectRole__r.Type__c = \'' + 'Team Member' + '\' or  (ProjectRole__r.Type__c = \'' + 'Key Member' + '\' AND Active__c = true))';
            sSOQL += ' ORDER BY Name';

            return (list<ProjectTeamMember__c>)Database.query(sSOQL);
        }

        set;
    }
    


public PageReference saveTeamMember()
    {
        try {
            insert oProjectTeamMember;
        } catch (Exception e) {
            ECO_Service_ErrorLog.formatPageError(e, 'An Error has occurred while attempting to save Project Team Member: ' + e.getMessage());               
            return null;
        }       

        oProjectTeamMember = new ProjectTeamMember__c();
        oProjectTeamMember.Project__c = sProjectId;
        return null;        
    }   
}