/*******************************************************************************
*
* PURPOSE: Controller class for GFA_ProjectDetailEdit.Page
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
*******************************************************************************/
public with sharing class GFA_ProjectDetailEditController extends GFA_ProjectTreeBaseController {

    public GFA_ProjectDetailEditController(ApexPages.StandardController sc) {
        super(sc);
    }

    public PageReference save() {
        Boolean hasError = false;
        if (String.isBlank(project.getProjectName())) {
            addError('Enter Project Name');
            hasError = true;
        }
        if (String.isBlank(project.getGroup())) {
            addError('Select Group.');
        }
        if (String.isBlank(project.getOperatingGroup())) {
            addError('Select Operating Group.');
            hasError = true;
        }
        if (project.getOperatingGroup() == GFA_Project.OPERATING_GROUP_CSOIL && String.isBlank(project.getBusinessLine())) {
            addError('Select Business Line');
            hasError = true;
        }
        if (String.isBlank(project.getProjectSponsor())) {
            addError('Select GFA Type');
            hasError = true;
        }
        if (String.isBlank(project.getComplexity())) {
            addError('Select Complexity');
            hasError = true;
        }
        if (String.isBlank(project.getRiskLevel())) {
            addError('Select Risk Level');
            hasError = true;
        }
        if (!hasError) {
            if (String.isNotBlank(project.getLifecycleStage()) && project.getLifecycleStage() ==  GFA_Project.LIFECYCLE_STAGE_PROPOSAL
                    && String.isBlank(project.getProjectStatus())) {
                project.setProjectStatus('NA');
            } else if (String.isNotBlank(project.getLifecycleStage()) && project.getLifecycleStage() ==  GFA_Project.LIFECYCLE_STAGE_PROJECT
                       && String.isBlank(project.getProjectStatus())) {
                project.setProjectStatus('Not Started');
            }

            List<GFA_BaseModel> models = new List<GFA_BaseModel>();
            List<GFA_ProjectPhase> projectPhases = new List<GFA_ProjectPhase>();

            project.save();

            projectPhases.addAll(project.getProjectPhases());
            models.addAll((List<GFA_BaseModel>)projectPhases);
            GFA_BaseModel.save(models);

            PageReference pr = Page.GFA_ProjectDetailView;
            putParam(pr, 'id', project.getId());
            putParam(pr, 'OnlyApplicable', 'true');
            pr.setRedirect(true);
            return pr;
        }
        return null;
    }

    public PageReference cancel() {
        if (project.getId() != null) {
            PageReference pr = Page.GFA_ProjectDetailView;
            putParam(pr, 'id', project.getId());
            putParam(pr, 'OnlyApplicable', 'true');
            pr.setRedirect(true);
            return pr;
        } else {
            PageReference pr = new PageReference('/' + GFA_Project__c.SObjectType.getDescribe().getKeyPrefix() + '/o');
            pr.setRedirect(true);
            return pr;
        }
    }
}