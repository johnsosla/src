public with sharing class ECO_CloneProjectController{

	public String searchProjectName {get;set;}
	public List<pse__Proj__c> projects {get;set;}
    public List<pse__Proj__c> globalTemplates {get;set;}
    public List<pse__Proj__c> myTemplates {get;set;}

    //project paging vars
    public Boolean hasNextProjects{get;set;}
    public Boolean hasPrevProjects{get;set;}
    public Integer projectsCurrentPage {get; set;}
    public Integer projectsTotalPages {get;set;}
    public Boolean hasFirstProject {get;set;}
    public Boolean hasLastProject {get;set;}
    //global template paging vars
    public Boolean hasNextGTs{get;set;}
    public Boolean hasPrevGTs{get;set;}
    public Integer gtCurrentPage {get; set;}
    public Integer gtTotalPages {get;set;}
    public Boolean hasFirstGT {get;set;}
    public Boolean hasLastGT {get;set;}
    //my template paging vars
    public Boolean hasNextMTs{get;set;}
    public Boolean hasPrevMTs{get;set;}
    public Integer mtCurrentPage {get; set;}
    public Integer mtTotalPages {get;set;}
    public Boolean hasFirstMT {get;set;}
    public Boolean hasLastMT {get;set;}

    public String selectedProjectId {get;set;}
    public String selectedProjectName {get;set;}
    public pse__Proj__c project {get;set;}
    public pse__Proj__c mergeProject {get;set;}
    public String mergeProjectId {get;set;}  
    public String newProjectName {get;set;}

    public Boolean noSearchResults {get;set;}
    public Boolean noGTSearchResults {get;set;}
    public Boolean noMTSearchResults {get;set;}

	private ApexPAges.StandardsetController setCon;
    private ApexPAges.StandardsetController setConGlobalTemplates;
    private ApexPAges.StandardsetController setConMyTemplates;

    @TestVisible
    private final Integer pagingResultSize = 10;

    public Boolean hideSourceLink {get; private set;}
    public Boolean hideTargetLink {get; private set;}
    public Boolean hideTemplates {get; private set;}
    public Boolean showNewProjectFields {get; private set;}
    public String cloningActionStr {get; private set;}

    private enum cloningAction {ALL, TASKS, RISKS}
    @TestVisible
    private cloningAction pageCloningAction{get;set;}
    @TestVisible
    private String retUrl;

   	public ECO_CloneProjectController(ApexPages.StandardSetController controller) {
		searchProjectName = '';
		selectedProjectId = '';
        mergeProjectId = '';
        selectedProjectName = '';
        newProjectName = '';
        retUrl = '';
		projects = new List<pse__Proj__c>();
        globalTemplates = new List<pse__Proj__c>();
        myTemplates = new List<pse__Proj__c>();
        noSearchResults = true;
        noGTSearchResults = true;
        noMTSearchResults = true;
		showNewProjectFields = true;

		project = new pse__Proj__c();
        mergeProject = new pse__Proj__c();

        hideSourceLink = false;
        hideTargetLink = false;
        hideTemplates = false;
        checkForPreSelectedSourceProject();
        checkForPreSelectedTargetProject();
        checkForReturnUrl();

        if(hideSourceLink || hideTargetLink){
            hideTemplates = true;
        }

        cloningActionStr = '';
        checkForCloningAction();

        SearchProjects();

	}

    private void checkForReturnUrl(){
        if(ApexPages.currentPage().getParameters().containsKey('retUrl')){
            retUrl = ApexPages.currentPage().getParameters().get('retUrl');          
        }
    }

    private void checkForCloningAction(){
        pageCloningAction = cloningAction.ALL;
        if(ApexPages.currentPage().getParameters().containsKey('cloningAction')){
            String action = ApexPages.currentPage().getParameters().get('cloningAction');
            if(action.containsIgnoreCase(String.valueOf(cloningAction.TASKS))){
                pageCloningAction = cloningAction.TASKS;
                cloningActionStr = 'Tasks';
            }
            if(action.containsIgnoreCase(String.valueOf(cloningAction.RISKS))){
                pageCloningAction = cloningAction.RISKS;
                cloningActionStr = 'Risks';
            }
        }
    }

    private void checkForPreSelectedSourceProject(){
        if(ApexPages.currentPage().getParameters().containsKey('sourceProjectId')){
            selectedProjectId = ApexPages.currentPage().getParameters().get('sourceProjectId');
            setSelectedProject();
            hideSourceLink = true;
        }
    }

    private void checkForPreSelectedTargetProject(){
        if(ApexPages.currentPage().getParameters().containsKey('targetProjectId')){
            mergeProjectId = ApexPages.currentPage().getParameters().get('targetProjectId');
            setMergeProject();
            hideTargetLink = true;
        }
    }

	public void SearchProjects(){

        Id currentUserId = UserInfo.getUserId();
	    /*String soqlSelect = 'SELECT Id, Name, pse__Account__r.Name, Owner.Name, pse__Opportunity__r.Name, clGlobalProjectTemplate__c, PersonalProjectTemplate__c FROM pse__Proj__c ';
		
        String soqlWhereGT = 'WHERE PersonalProjectTemplate__c != true AND clGlobalProjectTemplate__c = true ';
        String soqlWhereMT = 'WHERE PersonalProjectTemplate__c = true AND clGlobalProjectTemplate__c != true AND OwnerId = :currentUserId ';
        String soqlWhere = 'WHERE clGlobalProjectTemplate__c != true AND PersonalProjectTemplate__c != true ';*/
        
        String soqlSelect = 'SELECT Id, Name, pse__Account__r.Name, Owner.Name, pse__Opportunity__r.Name, isGlobalTemplate__c, PersonalProjectTemplate__c, pse__Project_Manager__r.Name FROM pse__Proj__c ';

        //tab 1) Available to Copy - operates with search
        String soqlWhere = 'WHERE PersonalProjectTemplate__c = true AND isGlobalTemplate__c != true ';
        //tab 2) Global Templates
        String soqlWhereGT = 'WHERE PersonalProjectTemplate__c != true AND isGlobalTemplate__c = true ';
        //tab 3) My Templates
        String soqlWhereMT = 'WHERE PersonalProjectTemplate__c = true AND isGlobalTemplate__c != true AND (OwnerId = :currentUserId OR pse__Project_Manager__c = :currentUserId) '; 

        String soqlSearchWhere = '';
        if(!String.isEmpty(searchProjectName)){
			soqlSearchWhere += 'AND Name LIKE \'%' + String.escapeSingleQuotes(searchProjectName) + '%\' ';
		}

        /*
        if(hideTargetLink && mergeProject.Id != null){
            //soqlWhere += '  AND Id != mergeProject.Id ';
        }
        */

        //to support more selective cloning add where clauses here
        String soqlHasTasksWhere = 'AND Id IN (select pse__Project__c from pse__Project_Task__c) ';
        String soqlHasRisksWhere = 'AND Id IN (select Project__c from Risk__c) ';
        if(pageCloningAction == cloningAction.TASKS){
            soqlWhere += soqlHasTasksWhere;
        }else if(pageCloningAction == cloningAction.RISKS){
            soqlWhere += soqlHasRisksWhere;
        }

		String soqlOrder = 'ORDER BY Name ASC LIMIT 10000';    

        String soqlProjects = soqlSelect + soqlWhere + soqlSearchWhere + soqlOrder; 
		setCon = new ApexPages.StandardsetController(Database.getQueryLocator(soqlProjects));
        setCon.setPageSize(pagingResultSize);  
        getProjects(); 

        //if(!hideTemplates){
            String soqlGT = soqlSelect + soqlWhereGT + soqlSearchWhere + soqlOrder; 
            setConGlobalTemplates = new ApexPages.StandardsetController(Database.getQueryLocator(soqlGT));
            setConGlobalTemplates.setPageSize(pagingResultSize);  
            getGlobalTemplates();
        
            String soqlMT = soqlSelect + soqlWhereMT + soqlSearchWhere + soqlOrder; 
            setConMyTemplates = new ApexPages.StandardsetController(Database.getQueryLocator(soqlMT));
            setConMyTemplates.setPageSize(pagingResultSize);
            getMyTemplates();
        //}
        system.debug('soqlProjects: ' + soqlProjects);
        system.debug('soqlGT: ' + soqlGT);
        system.debug('soqlMT: ' + soqlMT);
	}

	private void getProjects(){
		projects = setCon.getRecords(); 
        if(projects.isEmpty()){
            noSearchResults = true;
        }else{
            noSearchResults = false;
        }
		updatePagingVars();
	}

    private void getGlobalTemplates(){
        globalTemplates = setConGlobalTemplates.getRecords(); 
        if(globalTemplates.isEmpty()){
            noGTSearchResults = true;
        }else{
            noGTSearchResults = false;
        }
        updateGlobalTemplatesPagingVars();
    }

    private void getMyTemplates(){
        myTemplates = setConMyTemplates.getRecords(); 
        if(myTemplates.isEmpty()){
            noMTSearchResults = true;
        }else{
            noMTSearchResults = false;
        }
        updateMyTemplatesPagingVars();
    }


	private void updatePagingVars(){
        //non template projects
        hasNextProjects = setCon.getHasNext();
        hasPrevProjects = setCon.getHasPrevious();
        projectsCurrentPage = setCon.getPageNumber();
        Decimal totalPages = ( setCon.getResultSize() / setCon.getPageSize() );
        totalPages = Math.floor(totalPages) + ( ( Math.mod(setCon.getResultSize(), setCon.getPageSize()) > 0 ) ? 1 : 0);
        projectsTotalPages = Integer.valueOf(totalPages);
        if(hasPrevProjects){
            hasFirstProject = true;
        }else{
            hasFirstProject = false;
        }
        if(hasNextProjects){
            hasLastProject = true;
        }else{
            hasLastProject = false;
        }
    }

    private void updateGlobalTemplatesPagingVars(){
        //global templates
        hasNextGTs = setConGlobalTemplates.getHasNext();
        hasPrevGTs = setConGlobalTemplates.getHasPrevious();
        gtCurrentPage = setConGlobalTemplates.getPageNumber();
        Decimal globalTemplatesTotalPages = ( setConGlobalTemplates.getResultSize() / setConGlobalTemplates.getPageSize() );
        globalTemplatesTotalPages = Math.floor(globalTemplatesTotalPages) + ( ( Math.mod(setConGlobalTemplates.getResultSize(), setConGlobalTemplates.getPageSize()) > 0 ) ? 1 : 0);
        gtTotalPages = Integer.valueOf(globalTemplatesTotalPages);
        if(hasPrevGTs){
            hasFirstGT = true;
        }else{
            hasFirstGT = false;
        }
        if(hasNextGTs){
            hasLastGT = true;
        }else{
            hasLastGT = false;
        }
    }

    private void updateMyTemplatesPagingVars(){
        //my templates
        hasNextMTs = setConMyTemplates.getHasNext();
        hasPrevMTs = setConMyTemplates.getHasPrevious();
        mtCurrentPage = setConMyTemplates.getPageNumber();
        Decimal myTemplatesTotalPages = ( setConMyTemplates.getResultSize() / setConMyTemplates.getPageSize() );
        myTemplatesTotalPages = Math.floor(myTemplatesTotalPages) + ( ( Math.mod(setConMyTemplates.getResultSize(), setConMyTemplates.getPageSize()) > 0 ) ? 1 : 0);
        mtTotalPages = Integer.valueOf(myTemplatesTotalPages);
        if(hasPrevMTs){
            hasFirstMT = true;
        }else{
            hasFirstMT = false;
        }
        if(hasNextMTs){
            hasLastMT = true;
        }else{
            hasLastMT = false;
        }

    }



    //project paging methods
	public void moveNextProjects(){        
         if(setCon.getHasNext()){
            setCon.next();
            getProjects();   
         }       
    }

    public void movePrevProjects(){        
        if(setCon.getHasPrevious()){
            setCon.previous();
            getProjects();
        }       
    }

    public void moveLastProjects(){
        setCon.last();
        getProjects();       
    }

    public void moveFirstProjects(){
        setCon.first();
        getProjects();        
    }
    ///////////////////////////

    //global template paging methods
    public void moveNextGTs(){        
         if(setConGlobalTemplates.getHasNext()){
            setConGlobalTemplates.next();
            getGlobalTemplates();   
         }       
    }

    public void movePrevGTs(){        
        if(setConGlobalTemplates.getHasPrevious()){
            setConGlobalTemplates.previous();
            getGlobalTemplates();
        }       
    }

    public void moveLastGTs(){
        setConGlobalTemplates.last();
        getGlobalTemplates();       
    }

    public void moveFirstGTs(){
        setConGlobalTemplates.first();
        getGlobalTemplates();        
    }
    ///////////////////////////

    //my template paging methods
    public void moveNextMTs(){        
         if(setConMyTemplates.getHasNext()){
            setConMyTemplates.next();
            getMyTemplates();   
         }       
    }

    public void movePrevMTs(){        
        if(setConMyTemplates.getHasPrevious()){
            setConMyTemplates.previous();
            getMyTemplates();
        }       
    }

    public void moveLastMTs(){
        setConMyTemplates.last();
        getMyTemplates();       
    }

    public void moveFirstMTs(){
        setConMyTemplates.first();
        getMyTemplates();        
    }

    ///////////////////////////


    public void setSelectedProject(){
    	project = new pse__Proj__c();
		if(!String.isEmpty(selectedProjectId)){
			Id projId = Id.valueOf(selectedProjectId);
			List<pse__Proj__c> projects = [SELECT Id, Name, OwnerId, pse__Opportunity__c, pse__Account__r.Name, Owner.Name, pse__Parent_Project__c
											FROM pse__Proj__c
											WHERE Id = :projId];
			if(!projects.isEmpty()){
				project = projects.get(0);
                selectedProjectName = project.Name;	                       
			}else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occurred! Unable to find project with Id = ' + selectedProjectId));
            }			
		}
    }

    public void setMergeProject(){
       mergeProject = new pse__Proj__c();
        if(!String.isEmpty(mergeProjectId)){
            Id projId = Id.valueOf(mergeProjectId);
            List<pse__Proj__c> projects = [SELECT Id, Name, OwnerId, pse__Opportunity__c, pse__Account__r.Name, Owner.Name, pse__Parent_Project__c, IsCloned__c
                                            FROM pse__Proj__c
                                            WHERE Id = :projId];
            if(!projects.isEmpty()){               
                mergeProject = projects.get(0);
                showNewProjectFields = false;
            }
            
        }
    }

    public pageReference cloneProject(){
    	PageReference pageRef = null;


        if(mergeProject.IsCloned__c == true){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'A cloned project has already been copied into this project.  The copy project function may only be used once per project.'));
            return pageRef;            
        }

    	//validate project fields
    	if(project.Id == null){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a project!'));
            return pageRef;
    	}
    	if(String.isEmpty(newProjectName) && mergeProject == null){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Project Name cannot be empty!'));
            return pageRef;
    	}
    	if(String.isEmpty(project.OwnerId)){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Record Owner cannot be empty!'));
            return pageRef;
    	}
        if(project == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a project!'));
            return pageRef;
        }else{
            if(mergeProject.Id != null){
                if(project.Id == mergeProject.Id){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Source project and merge target project cannot be the same!'));
                }
            }
        }

    	try{
    		ECO_ProjectCloningService cloner = new ECO_ProjectCloningService();
            if(mergeProject != null){
                cloner.newProjectId = mergeProject.Id;
            }
            if(pageCloningAction == cloningAction.ALL){
                cloner.newProjectName = newProjectName;
                cloner.newProjectOwner = project.OwnerId;
                cloner.newProjectOpportunity = project.pse__Opportunity__c;
                cloner.cloneProject(project.Id);
            }else if(pageCloningAction == cloningAction.TASKS){
                cloner.cloneProjectTasks(project.Id);
            }else if(pageCloningAction == cloningAction.RISKS){
                cloner.cloneProjectRisks(project.Id);
            }

    		Id newProjectId = cloner.newProjectId;
            if(!String.isEmpty(retUrl)){
                pageRef = new PageReference(retUrl);
            }else{
                pageRef = new PageReference('/' + newProjectId);
            }    		
    		pageRef.setRedirect(true);

    	}catch(Exception e){
    		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + ' - ' + e.getStackTraceString()));

            ECO_Service_ErrorLog.formatPageError(e, e.getMessage() + ' - ' + e.getStackTraceString());
            
    	    pageRef = null;
        }


    	return pageRef;
    }

    public void clear(){
        if(!hideSourceLink){
            project = new pse__Proj__c();
        }        
        if(!hideTargetLink){
            mergeProject = new pse__Proj__c();
            showNewProjectFields = true;
        }        
        newProjectName = '';
       
    }

    public PageReference doCancel(){
        String url = '/a32';
        if(!String.isEmpty(retUrl)){
            url = retUrl;
        }
        PageReference pageRef = new PageReference(url);
        pageRef.setRedirect(true);
        return pageRef;
    }
}