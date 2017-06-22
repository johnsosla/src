/*******************************************************************************
*
* PURPOSE: Base controller for View/Edit controllers for Edit tree
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
*******************************************************************************/
public abstract with sharing class GFA_ProjectTreeBaseController extends GFA_BaseController {

    public GFA_Project project {get; set;}
    public String ViewType {get; set;}
    private Boolean mOnlyApplicable;
    public Boolean addTemplate {get; set;}

    public final static String VIEW_ALL = 'All';
    public final static String VIEW_APPLICABLE = 'Applicable';

    public GFA_ProjectTreeBaseController(ApexPages.StandardController sc) {
        if (sc.getId() != null) {
            project = GFA_Project.find.findById(sc.getId());
            setupProject();
            if (getParam('ViewType') == VIEW_APPLICABLE) {
                for (GFA_ProjectPhase phase : project.getProjectPhases()) {
                    for (GFA_ProjectTask task : phase.getProjectTasks()) {
                        for (Integer i = task.getProjectSubtasks().size() - 1; i > -1; i--) {
                            if (!task.getProjectSubtasks()[i].getIsApplicable()) {
                                task.getProjectSubtasks().remove(i);
                            }
                        }
                    }
                }
            }
        } else {
            project = new GFA_Project();
        }
    }

    /*
    *   Setups a Project with all related Phases, Tasks, and Subtasks
    */
    protected void setupProject() {
        addTemplate = false;
        mOnlyApplicable = getParam('OnlyApplicable') == 'true';
        List<GFA_ProjectPhase> projectPhases = GFA_ProjectPhase.find.findByProjectId(
                project.getId());
        Map<Id, List<GFA_ProjectTask>> phasesToTaskMap = GFA_ProjectTask.find.findByProjectPhaseIds(
                    projectPhases);

        List<GFA_ProjectTask> allTasks = new List<GFA_ProjectTask>();
        for (Id key : phasesToTaskMap.keySet()) {
            allTasks.addAll(phasesToTaskMap.get(key));
        }

        Map<Id, List<GFA_ProjectSubtask>> taskSubMap = GFA_ProjectSubtask.find.findByProjectTaskIds(
                    allTasks);

        if (mOnlyApplicable) {
            for (Id key : taskSubMap.keySet()) {
                List<GFA_ProjectSubtask> newSubtaskList = new List<GFA_ProjectSubtask>();
                for (GFA_ProjectSubtask subtask : taskSubMap.get(key)) {
                    if (subtask.getIsApplicable() || subtask.getIsPMVisible()) {
                        newSubtaskList.add(subtask);
                    }
                }
                taskSubMap.put(key, newSubtaskList);
            }
        }

        Map<Id, Integer> numberOfSubtasks = new Map<Id, Integer>();
        Map<Id, Integer> numberOfCriticals = new Map<Id, Integer>();

        //---Adding subtasks to task, task to phases, and phases to Projects
        for (GFA_ProjectTask task : allTasks) {
            if (taskSubMap.containsKey(task.getId())) {
                task.setProjectSubtasks(taskSubMap.get(task.getId()));
                Integer numSubtasks = numberOfSubtasks.get(task.getProjectPhaseId()) != null
                                      ? numberOfSubtasks.get(task.getProjectPhaseId())
                                      : 0;
                numberOfSubtasks.put(task.getProjectPhaseId(), numSubtasks + task.getProjectSubtasks().size());
            }
            for (GFA_ProjectSubtask subtask : task.getProjectSubtasks()) {
                if (subtask.getIsCritical() || subtask.getIsCriticalOverride()) {
                    if (numberOfCriticals.containsKey(task.getProjectPhaseId())) {
                        Integer available = numberOfCriticals.get(task.getProjectPhaseId());
                        numberOfCriticals.put(task.getProjectPhaseId(), available + 1);
                    } else {
                        numberOfCriticals.put(task.getProjectPhaseId(), 1);
                    }
                }
            }
        }

        for (GFA_ProjectPhase phase : projectPhases) {
            List<GFA_ProjectTask> tasks = phasesToTaskMap.get(phase.getId());
            if (tasks != null) {
                for (Integer i = tasks.size() - 1; i > -1; i--) {
                    if (tasks[i].getProjectSubtasks().isEmpty()) {
                        tasks.remove(i);
                    }
                }
                phase.setProjectTasks(tasks);
            }
            if (numberOfSubtasks.containsKey(phase.getId())) {
                phase.NumberOfSubtasks = numberOfSubtasks.get(phase.getId());
            }
            if (numberOfCriticals.containsKey(phase.getId())) {
                phase.NumberOfCriticals = numberOfCriticals.get(phase.getId());
            }
        }

        for (Integer i = projectPhases.size() - 1; i > -1; i--) {
            if (projectPhases[i].getProjectTasks().isEmpty()) {
                projectPhases.remove(i);
            }
        }

        project.setProjectPhases(projectPhases);

        // logic to determine who can add template to a project
        List<GFA_ProjectRoster> projectRosters = GFA_ProjectRoster.find.findByProjectId(project.getId());
        if (projectRosters != null && projectRosters.size() > 0) {
            for (GFA_ProjectRoster roster : projectRosters) {
                 if (roster.getTeamMemberUserId() == GFA_User.getCurrentUser().getId() && roster.getIsActingPM()
                        && (String.isBlank(project.getTemplateId()) || String.isEmpty(project.getTemplateId()))) {
                    addTemplate = true;
                 }
            }
        }
    }
}