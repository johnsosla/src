/** ------------------------------------------------------------------------------------------------------
* @Description Provides helper methods to facilitate marking scope objects as "dirty"
*
* @Author      NTTD - Timothy Chiang
* @Date        October 2016
*-----------------------------------------------------------------------------------------------------*/

public without sharing class ECO_Service_DirtyScope {

	public static Boolean Run = true;
	public static Boolean ProjectDirtyRun = true;
	public static Boolean TaskDirtyRun = true;


	public static final String PROJECT_DIRTY_FLAG_SNAPSHOT_MTD = 'DirtyFlagSnapshotMTD__c';
	public static final String PROJECT_DIRTY_FLAG_FLAG_UPDATE = 'DirtyFlagTaskUpdate__c';
	public static final String DEFAULT_PROJECT_DEFAULT = 'Project__c';
	public static final String DEFAULT_PROJECT_NUMBER = 'ProjectNumber__c';
	public static final String DEFAULT_PROJECT_PSE_LINK = 'pse__Project__c';

	public static final String TASK_DIRTY_FLAG_UPDATE = 'DirtyFlagTaskUpdate__c';
	public static final String DEFAULT_TASK_DEFAULT = 'ProjectTask__c';


	public ECO_Service_DirtyScope() {

	}

    /**
     * Retrieve object name from generic SObject
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Oct 2016
     *
	 * @param	so - Sobject to check
	 * @return 	string
     **/
    private static string getObjectName(Sobject oTarget){
        if(oTarget != null){

            return oTarget.getSObjectType().getDescribe().getName();
        } else {
            return null;
        }
    }


    /**
     * Determines if a field exists on a generic SObject
     * NOTE: the hasSObjectField method requires an ALL LOWERCAP name to be passed in. Odd quirk, but it appears to be case sensative
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
	 * @param	fieldName - name of field to check
	 * @param	so - Sobject to check
	 * @return 	boolean
     *
     **/
    public static boolean hasSObjectField(String fieldName, SObject so){
        return so.getSobjectType().getDescribe().fields.getMap().keySet().contains(fieldName.tolowercase());
    }

    /**
     * Takes in a list of project and sets them to dirty
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    2016
     *
	 * @param	projectIdSet
	 * @param	flag
	 * @param	value
	 * @return 	void 
     *
     **/
 	public static void setProjectFlag(Set<Id> projectIdSet, String flag, Boolean value){


      	list<pse__proj__c> lstProj = new list<pse__proj__c>();

       	for(id projId: projectIdSet){

            pse__proj__c p = new pse__proj__c(id=projId);

            try{
				p.put(flag, value);
            } catch( Exception e){
                ECO_Service_ErrorLog.logException(e);
                return;
			}

			lstProj.add(p);
        }

        ECO_ProjectTriggers.run = false;
        ECO_Service_DirtyScope.run = false;
        ECO_TriggerSettings.bypassTrigger('PR');
        ECO_TriggerSettings.bypassTrigger('Proj_ALL');

        Database.SaveResult[] srList = Database.update(lstProj, false);
        ECO_Service_ErrorLog.logException( lstProj, srList, 'ECO_Service_DirtyScope - setProjectFlag');

        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {

            } else {

                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }

        ECO_ProjectTriggers.run = true;
        ECO_Service_DirtyScope.run = true;
        ECO_TriggerSettings.clearAllBypasses();

 	}



    /**
     * Takes in a list of project and sets them to dirty
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Oct 2016
     *
	 * @param	listProjects - list of projects to flag as dirty
	 * @return 	void
     **/
	public static void setProjectDirty(list<pse__proj__c> listProjects){

        if (!Run || !ProjectDirtyRun || !ECO_TriggerSettings.getIsTriggerEnabled('ECO_Project_Dirty')) {
            return;
        }

		string errorReason = null;

		for(pse__proj__c proj: listProjects){
			if(hasSObjectField(PROJECT_DIRTY_FLAG_SNAPSHOT_MTD, proj)){
				proj.put(PROJECT_DIRTY_FLAG_SNAPSHOT_MTD, true);
			} else {
				errorReason = 'Error setting dirty flag,' + PROJECT_DIRTY_FLAG_SNAPSHOT_MTD + ' on the project, field does not exist';
			}
		}

		if(errorReason != null){
			for(pse__proj__c s: listProjects){
				s.adderror(errorReason);
			}
		}

	}


    /**
     * Takes in a list of objects and sets the project to dirty
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Oct 2016
     *
	 * @param	listObjects - list of objects to flag projects for
	 * @param	flag - dirty flag on associated project
	 * @return 	void
     **/
	public static void setProjectDirty(list<SObject> listObjects, string flag){

        if (!Run || !ProjectDirtyRun || !ECO_TriggerSettings.getIsTriggerEnabled('ECO_Project_Dirty')) {
            return;
        }

        list<string> flags = new list<string>();
        flags.add(flag);

		setProjectDirty(listObjects, DEFAULT_PROJECT_DEFAULT, flags);
	}

    /**
     * Takes in a list of objects and sets the project to dirty
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Oct 2016
     *
	 * @param	listObjects - list of objects to flag projects for
	 * @param	projectField - field that connects sobject to associated project
	 * @param	flag - dirty flag on associated project
	 * @return 	void
     **/
	public static void setProjectDirty(list<SObject> listObjects, string projectField, string flag){
        if (!Run || !ProjectDirtyRun || !ECO_TriggerSettings.getIsTriggerEnabled('ECO_Project_Dirty')) {
            return;
        }

        list<string> flags = new list<string>();
        flags.add(flag);

        setProjectDirty(listObjects, projectField, flags);
	}


    /**
     * Takes in a list of objects and sets the project to dirty
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Oct 2016
     *
		 * @param	listObjects - list of objects to flag projects for
		 * @param	projectField - field that connects sobject to associated project
		 * @param	flags - list of dirty flags on associated project
		 * @return 	void
     **/
	public static void setProjectDirty(list<SObject> listObjects, string projectField, list<string> flags){

		//system.debug('@@@DEBUG: start');

	    if (!Run || !ProjectDirtyRun || !ECO_TriggerSettings.getIsTriggerEnabled('ECO_Project_Dirty')) {
	        return;
	    }

		if (ListObjects==null || ListObjects.size()==0) {
			return;
		}


		//system.debug('@@@DEBUG: after returns');

		set<id> projIds = new set<id>();
		list<pse__proj__c> lstProj = new list<pse__proj__c>();
		set<id> agreementids = new set<id>();

		string objectName = getObjectName(listObjects[0]);


		// Handle special cases where objects are related through junction objects or there is a 1-many relationship between Sobject and project
		if(objectName == 'Agreement__c'){

			for(SObject s: listObjects){
				agreementids.add((id)s.get('id'));
			}

        	List<ProjectAgreement__c> lstPas = [SELECT id, Project__c FROM ProjectAgreement__c WHERE Agreement__c IN :agreementids];

        	for(ProjectAgreement__c pa: lstPas){
        		projIds.add(pa.Project__c);
        	}
		}

		string errorReason = null;

		for(SObject s: listObjects){

			// extend if the object is not connected to project via Project__c
			if(objectName == 'Agreement__c'){

				// in the case of agreements, we have already handled this

			} else {
				if(hasSObjectField(projectField, s)){
					projIds.add((id)s.get(projectField));
				} else {
					errorReason = 'Error reading project field,' + projectField + ' on Sobject, field does not exist';
				}
			}
		}



		for(id projId: projIds){
			pse__proj__c updateProj = new pse__proj__c(id=projId);

			for(string flag: flags){
				if(hasSObjectField(flag, updateProj)){
					updateProj.put(flag, true);
				} else {
					errorReason = 'Error setting dirty flag,' + flag + ' on the project, field does not exist';
				}
			}

			if(errorReason == null){
				lstProj.add(updateProj);
			}
		}

		//system.debug('@@@DEBUG: ' + errorReason);
		if(errorReason != null){
			for(SObject s: listObjects){
				s.adderror(errorReason);
			}
		} else {
			ECO_ProjectTriggers.run = false;
			ECO_TriggerSettings.bypassTrigger('PR');
			ECO_TriggerSettings.bypassTrigger('Proj_ALL');

			try{
				update lstProj;
            } catch( Exception e){
                ECO_Service_ErrorLog.logException(e);
            }

            ECO_ProjectTriggers.run = true;
            ECO_TriggerSettings.clearAllBypasses();
		}

		// Assumption, once this method is executed, we assume that all the associated projects will already have been set to dirty, and thus eliminate the need to
		// call this method again
		ProjectDirtyRun = false;

	}


    /**
     * Takes in a list of tasks and sets them to dirty
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Oct 2016
     *
	 * @param	listTasks - list of tasks to flag as dirty
	 * @return 	void
     **/
	public static void setTaskDirty(list<pse__Project_Task__c> listTasks){

        if (!Run || !ProjectDirtyRun || !ECO_TriggerSettings.getIsTriggerEnabled('ECO_Project_Dirty')) {
            return;
        }

		string errorReason = null;

		for(pse__Project_Task__c task: listTasks){
			if(hasSObjectField(TASK_DIRTY_FLAG_UPDATE, task)){
				task.put(TASK_DIRTY_FLAG_UPDATE, true);
			} else {
				errorReason = 'Error setting dirty flag,' + TASK_DIRTY_FLAG_UPDATE + ' on the project, field does not exist';
			}
		}

		if(errorReason != null){
			for(pse__Project_Task__c s: listTasks){
				s.adderror(errorReason);
			}
		}

	}


    /**
     * Takes in a list of objects and sets the task to dirty
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Oct 2016
     *
	 * @param	listObjects - list of objects to flag projects for
	 * @param	flag - dirty flag on associated project
	 * @return 	void
     **/
	public static void setTaskDirty(list<SObject> listObjects, string flag){

        if (!Run || !ProjectDirtyRun || !ECO_TriggerSettings.getIsTriggerEnabled('ECO_Project_Dirty')) {
            return;
        }

		setTaskDirty(listObjects, DEFAULT_TASK_DEFAULT, flag);
	}


    /**
     * Takes in a list of objects and sets the task to dirty
     *
     * @Author  NTT Data - Tim Chiang
     * @Date    Oct 2016
     *
	 * @param	listObjects - list of objects to flag projects for
	 * @param	taskField - field that connects sobject to associated task
	 * @param	flag - dirty flag on associated task
	 * @return 	void
     **/
	public static void setTaskDirty(list<SObject> listObjects, string taskField, string flag){

        if (!Run || !TaskDirtyRun || !ECO_TriggerSettings.getIsTriggerEnabled('ECO_Project_Dirty')) {
            return;
        }

		set<id> taskIds = new set<id>();
		list<pse__Project_Task__c> lstTasks = new list<pse__Project_Task__c>();

		string objectName = getObjectName(listObjects[0]);

		string errorReason = null;

		for(SObject s: listObjects){

			// extend if the object relation is complicated
			if(false){


			} else {
				if(hasSObjectField(taskField, s)){
					taskIds.add((id)s.get(taskField));
				} else {
					errorReason = 'Error reading task field,' + taskField + ' on Sobject, field does not exist';
				}
			}
		}

		for(id taskId: taskIds){
			pse__Project_Task__c updateTask = new pse__Project_Task__c(id=taskId);
			if(hasSObjectField(flag, updateTask)){
				updateTask.put(flag, true);
				lstTasks.add(updateTask);
			} else {
				errorReason = 'Error setting dirty flag,' + flag + ' on the task, field does not exist';
			}
		}

		if(errorReason != null){
			for(SObject s: listObjects){
				s.adderror(errorReason);
			}
		} else {
			// Before the DML operation – API to disable the FF project task trigers
			ECO_pseProjectTaskTriggers.externalTriggerStart();
        	ECO_TriggerSettings.bypassTrigger('PT');

			try{
				update lstTasks;
            } catch( Exception e){
                ECO_Service_ErrorLog.logException(e);
            }

            // After DML – Renables the FF PT triggers
            ECO_pseProjectTaskTriggers.externalTriggerFinish();
            ECO_TriggerSettings.clearBypassTrigger('PT');
		}

		// Assumption, once this method is executed, we assume that all the associated tasks will already have been set to dirty, and thus eliminate the need to
		// call this method again
		TaskDirtyRun = false;


	}




































}