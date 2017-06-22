/*******************************************************************************
*
* PURPOSE: Controller class for GFA_ProjectDetailView.Page
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
*******************************************************************************/
public with sharing class GFA_ProjectDetailViewController extends GFA_ProjectTreeBaseController {

    private List<GFA_Template> mAvailableTemplates;

    public GFA_ProjectDetailViewController(ApexPages.StandardController sc) {
        super(sc);
        putParam('OnlyApplicable', 'true');
        setupProject();
        setupProjectItems();
    }

    private void setupProjectItems() {
        List<GFA_ProjectRoster> projectRosters = GFA_ProjectRoster.find.findByProjectId(project.getId());
        List<GFA_Note> notes = GFA_Note.find.findByProjectId(project.getId());
        List<GFA_Attachment> attachments = GFA_Attachment.find.findByProjectId(project.getId());
        project.setProjectRosters(projectRosters);
        project.setNotes(notes);
        project.setAttachments(attachments);
    }

    public List<GFA_Template> getAvailableTemplates() {
        if (mAvailableTemplates == null) {
            refreshAvailableTemplates();
        }
        return mAvailableTemplates;
    }

    private void refreshAvailableTemplates() {
        mAvailableTemplates = GFA_Template.find.findByMatchingProject(project);
    }

    public PageReference selectTemplate() {
        String templateId = getParam('templateId');
        if (String.isNotBlank(templateId)) {

            project.setTemplateId(templateId);
            List<GFA_Project> projects = new List<GFA_Project>();
            projects.add(project);

            GFA_DMLUtils.save(projects);

            GFA_Template template = setupTemplate(templateId);
            //---Map of templatePhaseId to new ProjectPhases
            Map<Id, GFA_ProjectPhase> projectPhases = new Map<Id, GFA_ProjectPhase>();
            //---Map of templateTaskId to new ProjectTasks
            Map<Id, GFA_ProjectTask> projectTasks = new Map<Id, GFA_ProjectTask>();
            List<GFA_ProjectSubtask> projectSubtasks = new List<GFA_ProjectSubtask>();

            for (GFA_TemplatePhase phase : template.getTemplatePhases()) {
                GFA_ProjectPhase projectPhase = new GFA_ProjectPhase();
                projectPhase.setSequence(phase.getSequence());
                projectPhase.setLibraryPhaseId(phase.getLibraryPhaseId());
                projectPhase.setProjectId(project.getId());
                projectPhases.put(phase.getId(), projectPhase);
            }
            GFA_DMLUtils.save(projectPhases.values());

            for (GFA_TemplatePhase phase : template.getTemplatePhases()) {
                for (GFA_TemplateTask task : phase.getTemplateTasks()) {
                    GFA_ProjectTask projectTask = new GFA_ProjectTask();
                    projectTask.setSequence(task.getSequence());
                    projectTask.setLibraryTaskId(task.getLibraryTaskId());
                    projectTask.setProjectPhaseId(projectPhases.get(phase.getId()).getId());
                    projectTasks.put(task.getId(), projectTask);
                }
            }
            GFA_DMLUtils.save(projectTasks.values());

            //---Get Subtask Library Ids to return latest library version
            Set<Id> latestSubtaskIds = new Set<Id>();
            //---Map of LibrarySubtaskId to Lastest library subtask version
            Map<Id, GFA_LibrarySubtaskVersion> versions = new Map<Id, GFA_LibrarySubtaskVersion>();
            for (GFA_TemplatePhase phase : template.getTemplatePhases()) {
                for (GFA_TemplateTask task : phase.getTemplateTasks()) {
                    for (GFA_TemplateSubtask subtask : task.getTemplateSubtasks()) {
                        latestSubtaskIds.add(subtask.getLibrarySubtaskId());
                    }
                }
            }
            //---Populate versions map
            for (GFA_LibrarySubtaskVersion version : GFA_LibrarySubtaskVersion.find.findLatestActiveVersions(latestSubtaskIds)) {
                versions.put(version.getLibrarySubtaskId(), version);
            }
            for (GFA_TemplatePhase phase : template.getTemplatePhases()) {
                for (GFA_TemplateTask task : phase.getTemplateTasks()) {
                    for (GFA_TemplateSubtask subtask : task.getTemplateSubtasks()) {
                        GFA_LibrarySubtaskVersion version = versions.get(subtask.getLibrarySubtaskId());
                        if (version != null) {
                            GFA_ProjectSubtask projectSubtask = new GFA_ProjectSubtask();
                            projectSubtask.setSequence(subtask.getSequence());
                            projectSubtask.setLibrarySubtaskVersionId(version.getId());
                            projectSubtask.setProjectTaskId(projectTasks.get(task.getId()).getId());
                            projectSubtask.setAddedBy(GFA_ProjectSubtask.ADDED_BY_TEMPLATE);
                            projectSubtasks.add(projectSubtask);
                        }
                    }
                }
            }
            GFA_DMLUtils.save(projectSubtasks);
            GFA_ProjectTriggerHandler.updateApplicability(new Map<Id, GFA_Project__c> {
                project.getId() => (GFA_Project__c)project.getObj()
            });
            setupProject();
        }
        return null;
    }

    public PageReference edit() {
        PageReference pr = Page.GFA_ProjectDetailEdit;
        putParam(pr, 'id', String.valueOf(project.getId()));
        putParam(pr, 'OnlyApplicable', 'true');
        pr.setRedirect(true);
        return pr;
    }

    public PageReference deleteProject() {
        PageReference pr = new PageReference('/' + String.valueOf(project.getId()).subString(0, 3) + '/o');
        List<GFA_ProjectDeliverable> deliverables = GFA_ProjectDeliverable.find.findByProjectId(project.getId());
        GFA_BaseModel.destroy(deliverables);
        project.destroy();
        pr.setRedirect(true);
        return pr;
    }

    private GFA_Template setupTemplate(String templateId) {
        GFA_Template template = GFA_Template.find.findById(templateId);
        List<GFA_TemplatePhase> templatePhases = GFA_TemplatePhase.find.findByTemplateId(
                    template.getId());

        Map<Id, List<GFA_TemplateTask>> phasesToTaskMap = GFA_TemplateTask.find.findByPhaseIds(
                    templatePhases);

        List<GFA_TemplateTask> allTasks = new List<GFA_TemplateTask>();
        for (Id key : phasesToTaskMap.keySet()) {
            allTasks.addAll(phasesToTaskMap.get(key));
        }

        Map<Id, List<GFA_TemplateSubtask>> taskSubMap = GFA_TemplateSubtask.find.findByTaskIds(
                    allTasks);

        //Start adding subtasks to task, task to phases, and phases to template
        for (GFA_TemplateTask task : allTasks) {
            if (taskSubMap.containsKey(task.getId())) {
                task.setTemplateSubtasks(taskSubMap.get(task.getId()));
            }
        }

        for (GFA_TemplatePhase phase : templatePhases) {
            if (phasesToTaskMap.containsKey(phase.getId())) {
                phase.setTemplateTasks(phasesToTaskMap.get(phase.getId()));
            }
        }

        template.setTemplatePhases(templatePhases);

        return template;
    }

    public PageReference newRoster() {
        PageReference pr = Page.GFA_ProjectRosterEdit;
        pr.setRedirect(true);
        GFA_ProjectRoster projectRosterNew = new GFA_ProjectRoster();
        putParam(pr, 'id', projectRosterNew.getId());
        putParam(pr, 'projectid', project.getId());
        return pr;
    }

    public PageReference editRoster() {
        Id rosterId = getParam('rosterId');
        PageReference pr = Page.GFA_ProjectRosterEdit;
        pr.setRedirect(true);
        putParam(pr, 'id', rosterId);
        putParam(pr, '/e?retURL=/apex/GFA_ProjectDetailView?id=', project.getId());
        return pr;
    }

    public PageReference deleteRoster() {
        List<GFA_ProjectRoster> delRosters = new List<GFA_ProjectRoster>();
        Id rosterId = getParam('rosterId');
        for (Integer i = project.getProjectRosters().size() - 1; i > -1; i--) {
            if (project.getProjectRosters()[i].getId() == rosterId) {
                GFA_ProjectRoster delRoster = project.getProjectRosters().remove(i);
                if (delRoster.getId() != null) {
                    delRosters.add(delRoster);
                }
            }
        }

        List<GFA_BaseModel> deleteModels = new List<GFA_BaseModel>();
        deleteModels.addAll((List<GFA_BaseModel>)delRosters);
        GFA_BaseModel.destroy(deleteModels);

        return null;
    }

    public PageReference newNote() {
        String idLength = project.getId();
        return new PageReference('/002/e?parent_id=' + idLength.substring(0, (idLength.length() - 3)) + '&retURL=/apex/GFA_ProjectDetailView?id=' + project.getId());
    }

    public PageReference attachFile() {
        String idLength = project.getId();
        return new PageReference('/p/attach/NoteAttach?pid=' + idLength.substring(0, (idLength.length() - 3)) + '&retURL=/apex/GFA_ProjectDetailView?id=' + project.getId());
    }

    public PageReference editNote() {
        Id noteId = getParam('noteId');
        return new PageReference('/' + noteId + '/e?retURL=/apex/GFA_ProjectDetailView?id=' + project.getId());
    }

    public PageReference deleteNote() {
        List<GFA_Note> delNotes = new List<GFA_Note>();
        Id noteId = getParam('noteId');

        for (Integer i = project.getNotes().size() - 1; i > -1; i--) {
            if (project.getNotes()[i].getId() == noteId) {
                GFA_Note delNote = project.getNotes().remove(i);
                if (delNote.getId() != null) {
                    delNotes.add(delNote);
                }
            }
        }

        List<GFA_BaseModel> deleteModels = new List<GFA_BaseModel>();
        deleteModels.addAll((List<GFA_BaseModel>)delNotes);
        GFA_BaseModel.destroy(deleteModels);

        return null;
    }

    public PageReference editAttach() {
        Id attachmentId = getParam('attachmentId');
        return new PageReference('/' + attachmentId + '/e?retURL=/apex/GFA_ProjectDetailView?id=' + project.getId());
    }

    public PageReference deleteAttach() {
        List<GFA_Attachment> delAttachments = new List<GFA_Attachment>();
        Id attachmentId = getParam('attachmentId');

        for (Integer i = project.getAttachments().size() - 1; i > -1; i--) {
            if (project.getAttachments()[i].getId() == attachmentId) {
                GFA_Attachment delAttachment = project.getAttachments().remove(i);
                if (delAttachment.getId() != null) {
                    delAttachments.add(delAttachment);
                }
            }
        }

        List<GFA_BaseModel> deleteModels = new List<GFA_BaseModel>();
        deleteModels.addAll((List<GFA_BaseModel>)delAttachments);
        GFA_BaseModel.destroy(deleteModels);

        return null;
    }

    public Boolean getCanEditProject() {
        Boolean isActingPM = false;

        if (project.getProjectRosters() != null && project.getProjectRosters().size() > 0) {
            for (GFA_ProjectRoster roster : project.getProjectRosters()) {
                if (roster.getTeamMemberUserId() == CurrentUser.getId() && roster.getIsActingPM()) {
                    isActingPM = true;
                }
            }
        }
        return (CurrentUser.getIsAdminUser() || isActingPM || project.getCreatedById() == CurrentUser.getId()) && !CurrentUser.getIsOtherUser();

    }
}