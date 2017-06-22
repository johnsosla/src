public with sharing class GFA_TemplateSubtask_DetailController extends GFA_BaseController {

    public GFA_TemplateSubtask ts {get; set;}
    public GFA_TemplatePhase phase {get; set;}
    public GFA_TemplateTask task {get; set;}
    public GFA_Template template {get; set;}
    public GFA_LibrarySubtaskVersion libSubtaskVersion {get; set;}
    public GFA_TemplateSubtask_DetailController(ApexPages.StandardController sc) {
        ts = GFA_TemplateSubtask.find.findById(sc.getId());

        libSubtaskVersion = GFA_LibrarySubtaskVersion.find.findLatestActiveVersion(ts.getLibrarySubtaskId());
        List<GFA_LibrarySubtaskContent> documentationList = GFA_LibrarySubtaskContent.find.findBySubtaskVersionId(libSubtaskVersion.getId());

        libSubtaskVersion.setLibrarySubtaskContents(documentationList);

        task = GFA_TemplateTask.find.findById(ts.getTemplateTaskId());
        phase = GFA_TemplatePhase.find.findById(ts.getTemplatePhaseId());
        template = GFA_Template.find.findById(ts.getTemplateId());
    }

    public PageReference cancel() {
        PageReference pr = Page.GFA_Template_Subtask_DetailViewPage;
        pr.setRedirect(true);
        putParam(pr, 'id', ts.getId());
        return pr;

    }

    public PageReference saveSubtask() {
        List<GFA_BaseModel> models = new List<GFA_BaseModel>();
        models.add(ts);

        GFA_BaseModel.save(models);

        PageReference pr = Page.GFA_Template_Subtask_DetailViewPage;
        pr.setRedirect(true);
        putParam(pr, 'id', ts.getId());
        return pr;

    }

    public PageReference deleteSubtask() {
        PageReference pr = Page.GFA_TemplateTaskDetail;
        putParam(pr, 'id', ts.getTemplateTaskId());
        pr.setRedirect(true);

        List<GFA_BaseModel> models = new List<GFA_BaseModel>();
        models.add(ts);
        GFA_BaseModel.destroy(models);

        return pr;
    }

    public Boolean getCanEdit() {
        return CurrentUser.getIsAdminUser();
    }
}