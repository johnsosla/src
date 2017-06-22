/** ------------------------------------------------------------------------------------------------------
* @Description This is a controller extension that extends the existing custom  controller
*
* @Author      NTTD - Sujit Kumar
* @Date        2016
*/
public class ECO_SafetyHealthEnvironmentController {       

    private  Attachment safetyHealthInspectionAtt; 
    public String overrideSafetyHealthInspectionName1  {get;set;} 

    public pse__Proj__c project;
    public list<Induction__c> inductionRegistrations {get;set;}
    public list<Induction__c> inductionRegistrationsRemove {get;set;}
    public list<InductedProjectTeamMembers__c> inductedProjectTeamMembers {get;set;} 
    public map<id, list<InductedProjectTeamMembers__c>> inductedProjectTeamMembersMap {get; set;}
    public map<id, list<Attachment>> inductionAttachmentsMap {get; set;}
    
    private Transient Attachment safetyHealthTravelAttachment;
    public String overrideSafetyHealthTravelName  {get;set;}

    private Transient Attachment safetyHealthPlanAttachment;
    public String overrideSafetyHealthPlanName  {get;set;}
    
    private Transient Attachment safetyHealthInspectionAttachment;
    public Transient String safetyHealthInspectionAttachmentName {get;set;}
    public String overrideSafetyHealthInspectionName  {get;set;}    
            
    public map<Id, Attachment> attachmentsMap {get; set;}
    
    public String inductionId2  {get; set;} 
    public string inductionName2  {get; set;} 
    
    public Id inductionId {get; set;}
    
    public list<Attachment> inductionAttachments;

    public list<ProjectActivities__c> ProjActivities {get;set;}
    public list<ProjectActivities__c> ProjActivitiesRemove {get;set;}

    public integer rowNumber {get;set;}
    public integer rowNumberInduction {get;set;}

    public string sTargetAttachment {get;set;}
    
    /**
     * 
     *
     * @Author  NTTD - Shoukat Khan
     * @Date    2016
     *
     * @param   stdController
     * @return  
     **/
    public ECO_SafetyHealthEnvironmentController(ApexPages.StandardController sc)
    {                
        project = (pse__Proj__c)sc.getRecord();
        initialize();
    }
    
    /**
     * 
     *
     * @Author  NTTD - Shoukat Khan
     * @Date    2016
     *
     * @param   pse__Proj__c
     * @return  
     **/ 
    public ECO_SafetyHealthEnvironmentController(pse__Proj__c proj)
    {
        //US-06752: To avoid addFields error for 'Print Project Plan' button, created new contructor and moved common code to initialize method.
        project = proj;
        initialize();
    }
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  void
     **/
    private void initialize() {
        
        inductionAttachmentsMap = new map<id, list<Attachment>>();
        inductedProjectTeamMembersMap = new map<id, list<InductedProjectTeamMembers__c>>();
        
        defaultAnswersFromRiskMarketAssessment();  
        //project.SafetyHealthOutsideOfficeEnvironment__c = 'No';

        queryProjectActivities();

        ProjActivitiesRemove = new list<ProjectActivities__c>();
        inductionRegistrationsRemove = new list<Induction__c>();
    }
            
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  
     **/
    private void queryProjectActivities(){
        ProjActivities = [select id, ImpactonEnv__c, Name, Significance__c, Control__c, ProposedAction__c, ActionTaken__c from ProjectActivities__c where Project__c =: project.id];
    }
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  PageReference 
     **/
    public PageReference newProjectActivities(){

        /*ProjActivities.add(new ProjectActivities__c(Project__c = project.id));

        return null;*/


        /*update project;
        
        ProjectActivities__c pa =  new ProjectActivities__c(Project__c = project.Id, Name='New Project Activity');
        insert pa;
        
        PageReference myPage = new PageReference('/' + pa.Id + '/e');
        myPage.getParameters().put('saveURL', '/apex/ECO_SafetyHealthEnvironment?Id=' + project.Id);
        myPage.getParameters().put('retURL', '/apex/ECO_SafetyHealthEnvironment?Id=' + project.Id + '&RecordToDelete='+ pa.Id + '&RecordType=ProjAct');
  
        return myPage;*/

        return  new PageReference('/apex/eco_projectactivity?ProjectID=' + project.Id);
    }
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  PageReference 
     **/
    public PageReference RemoveProjectActivities(){
        ProjectActivities__c pa = ProjActivities[rowNumber-1];

        if(pa.id != null){
            ProjActivitiesRemove.add(pa);
        }

        ProjActivities.remove(rowNumber-1);
        
        return null;

    }
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  PageReference 
     **/
    public PageReference RemoveInduciton(){
        Induction__c ind = inductionRegistrations[rowNumberInduction-1];

        if(ind.id != null){
            inductionRegistrationsRemove.add(ind);
        }

        inductionRegistrations.remove(rowNumberInduction-1);

        return null;

    }

    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  selectOption list 
     **/
    public list<selectOption> getImpactStatusOptions()
    {    
        list<selectOption> options = new list<selectOption>();
        Schema.DescribeFieldResult fieldResult = pse__Proj__c.SafetyHealthEnvImpactStatus__c.getDescribe();

        list<Schema.PicklistEntry> ple = fieldResult.getPickListValues();
        for(Schema.PicklistEntry p : ple)
        {
            options.add(new SelectOption(p.getLabel(), p.getValue()));
        }

        return options;
    }
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  
     **/
    private void defaultAnswersFromRiskMarketAssessment()
    {
        list<Questionnaire__c> sHEAssessment = new list<Questionnaire__c>();
        list<Answer__c> answer1 = new list<Answer__c>();
        list<Answer__c> answer2 = new list<Answer__c>();
        list<Answer__c> answer3 = new list<Answer__c>();
        
        list<QuestionnaireSet__c> riskAndMarketAssessment = [select Id from QuestionnaireSet__c where Project__c = :project.Id order by Id desc limit 1];
        if(riskAndMarketAssessment.size() > 0)
                sHEAssessment = [select Id from Questionnaire__c where QuestionnaireSet__c = :riskAndMarketAssessment[0].Id and Name = 'Risk Assessment'];

        list<TemplateQuestion__c> question1 = [select Id from TemplateQuestion__c where RiskTitle__c = 'Work Outside Environment' order by SortOrder__c limit 1];
        list<TemplateQuestion__c> question2 = [select Id from TemplateQuestion__c where RiskTitle__c = 'Project Travel' order by SortOrder__c limit 1];
        list<TemplateQuestion__c> question3 = [select Id from TemplateQuestion__c where RiskTitle__c = 'Environmental Impacts' order by SortOrder__c limit 1];

        if(sHEAssessment.size() > 0 && question1.size() > 0)
                answer1 = [select Id, Value__c from Answer__c where Questionnaire__c = :sHEAssessment[0].Id and TemplateQuestion__c = :question1[0].Id limit 1];
        if(sHEAssessment.size() > 0 && question2.size() > 0)
                answer2 = [select Id, Value__c from Answer__c where Questionnaire__c = :sHEAssessment[0].Id and TemplateQuestion__c = :question2[0].Id limit 1];
        if(sHEAssessment.size() > 0 && question3.size() > 0)
                answer3 = [select Id, Value__c from Answer__c where Questionnaire__c = :sHEAssessment[0].Id and TemplateQuestion__c = :question3[0].Id limit 1];

        if(project.SafetyHealthOutsideOfficeEnvironment__c == null && (answer1.size() > 0))
                project.SafetyHealthOutsideOfficeEnvironment__c = answer1[0].Value__c;
        if(project.SafetyHealthTravelRequired__c == null && (answer2.size() > 0))
                project.SafetyHealthTravelRequired__c = answer2[0].Value__c;
        if(project.SafetyHealthEnvRegulations__c == null && (answer3.size() > 0))
                project.SafetyHealthEnvRegulations__c = answer3[0].Value__c;                                  
    }
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  
     **/
    public void init()
    {

        if(Apexpages.currentPage().getParameters().get('RecordToDelete') != null)
        {
            String recordId = Apexpages.currentPage().getParameters().get('RecordToDelete');
            if(Apexpages.currentPage().getParameters().get('RecordType') == 'Induction')
            {       
                    Induction__c induction = [select Id from Induction__c where Id = :recordId];
                    delete induction;

            }
            else if(Apexpages.currentPage().getParameters().get('RecordType') == 'ProjAct'){
                    ProjectActivities__c projAct = [select Id from ProjectActivities__c where Id = :recordId];
                    delete projAct;
                    queryProjectActivities();
            }
            else
            {
                    InductedProjectTeamMembers__c teamMember = [select Id from InductedProjectTeamMembers__c where Id = :recordId];
                    delete teamMember;                              
            }
        }
        
        inductionRegistrations = [select Id, Name, RequiredBy__c, LocationofInduction__c, Frequency__c, Fee__c, Notes__c, Project__r.Name from Induction__c where Project__c = :project.Id];
        for(Induction__c induction:inductionRegistrations){
                inductedProjectTeamMembersMap.put(induction.Id, new list<InductedProjectTeamMembers__c>());
                inductionAttachmentsMap.put(induction.Id, new list<Attachment>());
        }
                        
        inductedProjectTeamMembers = [select Id, Name, Project__c, Induction__c, TeamMember__c from InductedProjectTeamMembers__c where Induction__c in :inductedProjectTeamMembersMap.keyset()];
        for(InductedProjectTeamMembers__c teamMember: inductedProjectTeamMembers)
                inductedProjectTeamMembersMap.get(teamMember.Induction__c).add(teamMember);
                
        inductionAttachments = [select Id, ParentId, Name from Attachment where ParentId in :inductedProjectTeamMembersMap.keyset()];
        for(Attachment inductionAttachment: inductionAttachments)
                inductionAttachmentsMap.get(inductionAttachment.ParentId).add(inductionAttachment);
                        
        attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :project.Id]);
        
    }
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  SelectOption list 
     **/
    public list<SelectOption> getYesNoOptions()
    {
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('Yes', 'Yes'));
        options.add(new SelectOption('No', 'No'));
    
        return options;
    }

    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  Attachment 
     **/
    public Attachment newSafetyHealthTravelAttachment
    {
        get
        {
            if(safetyHealthTravelAttachment==null)
            {
                safetyHealthTravelAttachment = new Attachment(parentid = project.id);
            }
            return safetyHealthTravelAttachment;
        }
        set;
    }

    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  Attachment 
     **/
    public Attachment newSafetyHealthPlanAttachment
    {
        get
        {
            if(safetyHealthPlanAttachment==null)
            {
                safetyHealthPlanAttachment = new Attachment(parentid = project.id);
            }
            return safetyHealthPlanAttachment;
        }
        set;
    }    

    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  Attachment 
     **/
    public Attachment newSafetyHealthInspectionAttachment
    {
        get
        {
            if(safetyHealthInspectionAttachment==null)
            {
                safetyHealthInspectionAttachment = new Attachment(parentid = project.id);
                //System.debug('safetyHealthInspectionAttachmentName::::'+safetyHealthInspectionAttachmentName);
                //System.debug('safetyHealthInspectionAttachment name:::'+safetyHealthInspectionAttachment.Name);
            }
            return safetyHealthInspectionAttachment;
        }
        set;
    }    

    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  Attachment 
     **/
    public Attachment newSafetyHealthInspectionAtt
    {
        get
        {
            //system.debug( 'newSafetyHealthInspectionAtt 247 ' + project.id );

            if(safetyHealthInspectionAtt==null)
            {
                //system.debug( 'newSafetyHealthInspectionAtt 251 ' + project.id );
                safetyHealthInspectionAtt = new Attachment(parentid = project.id);
            }
            return safetyHealthInspectionAtt;
        }
        set;
    }    
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  PageReference 
     **/         
    public PageReference removeattachment(){
        id iTargetAttachment = sTargetAttachment;
        Attachment aAttachToRemove = attachmentsMap.get(iTargetAttachment);
        attachmentsMap.remove(iTargetAttachment);
        delete aAttachToRemove;
        project.SafetyHealthInspectionAttachments__c = project.SafetyHealthInspectionAttachments__c.remove(iTargetAttachment + ';');
        update project;
        return null;
    }

    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  PageReference 
     **/ 
    public PageReference removeattachmentplan(){
        id iTargetAttachment = sTargetAttachment;
        Attachment aAttachToRemove = attachmentsMap.get(iTargetAttachment);
        attachmentsMap.remove(iTargetAttachment);
        delete aAttachToRemove;
        project.SafetyHealthPlanAttachments__c = project.SafetyHealthPlanAttachments__c.remove(iTargetAttachment + ';');
        update project;
        return null;
    }

    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  Attachment list
     **/
    private list<Attachment> getAttachmentListFromIdList(list<String> attachmentIds)
    {
        list<Attachment> attachments = new list<Attachment>();
        for(String attachmentId:attachmentIds)
        {
                if(attachmentsMap.containsKey(attachmentId) && attachmentId != null && attachmentId != '')
                        attachments.add(attachmentsMap.get(attachmentId));
        }

        return attachments;     
    }
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  Attachment list
     **/
    public list<Attachment> getSafetyHealthTravelFiles()
    {

        list<String> attachmentIds = new list<String>();
        if(project.SafetyHealthTravelAttachments__c != null)
                        attachmentIds = project.SafetyHealthTravelAttachments__c.split(';');
                        
        return getAttachmentListFromIdList(attachmentIds);
    }
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  Attachment list
     **/
    public list<Attachment> getSafetyHealthPlanFiles()
    {

        list<String> attachmentIds = new list<String>();
        if(project.SafetyHealthPlanAttachments__c != null)
                        attachmentIds = project.SafetyHealthPlanAttachments__c.split(';');

        return getAttachmentListFromIdList(attachmentIds);
    }   
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  Attachment list
     **/
    public list<Attachment> getSafetyHealthInspectionFiles()
    {

        list<String> attachmentIds = new list<String>();
        if(project.SafetyHealthInspectionAttachments__c != null)
                        attachmentIds = project.SafetyHealthInspectionAttachments__c.split(';');
        
        return getAttachmentListFromIdList(attachmentIds);
    }      
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  
     **/
    public void saveSafetyHealthTravelAttachmentAndProject()
    {
//      if(safetyHealthTravelAttachment.Body == null)
//      {       
            if(overrideSafetyHealthTravelName != null && overrideSafetyHealthTravelName != '')
                    safetyHealthTravelAttachment.Name = overrideSafetyHealthTravelName;                     
            insert safetyHealthTravelAttachment;
            
            if(project.SafetyHealthTravelAttachments__c != null)
                    project.SafetyHealthTravelAttachments__c += safetyHealthTravelAttachment.Id + ';';
            else
                    project.SafetyHealthTravelAttachments__c = safetyHealthTravelAttachment.Id + ';'; 
                                    
            update project;
            
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :project.Id]);
            safetyHealthTravelAttachment = null;
 //     }               
    }    
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  
     **/
    public void saveSafetyHealthPlanAttachmentAndProject()
    {
//      if(safetyHealthTravelAttachment.Body == null)
//      {       
            if(overrideSafetyHealthPlanName != null && overrideSafetyHealthPlanName != '')
                    safetyHealthPlanAttachment.Name = overrideSafetyHealthPlanName;                         
            insert safetyHealthPlanAttachment;
            
            if(project.SafetyHealthPlanAttachments__c != null)
                    project.SafetyHealthPlanAttachments__c += safetyHealthPlanAttachment.Id + ';';
            else
                    project.SafetyHealthPlanAttachments__c = safetyHealthPlanAttachment.Id + ';'; 
                                    
            update project;
            
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :project.Id]);
            safetyHealthPlanAttachment = null;
 //     }               
    }    
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  PageReference 
     **/ 
    public PageReference save()
    {
        update project;
        upsert ProjActivities;

        if(ProjActivitiesRemove.size() >0){
            delete ProjActivitiesRemove;
            ProjActivitiesRemove = new list<ProjectActivities__c>();
        }

        if(inductionRegistrationsRemove.size() >0){
            delete inductionRegistrationsRemove;
            inductionRegistrationsRemove = new list<Induction__c>();
        }

        return null;
    }
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  
     **/ 
    public void saveSafetyHealthInspectionAttProj()
    {
        
        Attachment attachmentObj = new Attachment();

        attachmentObj.ParentId = project.id;
        attachmentObj.name = safetyHealthInspectionAtt.name;
        attachmentObj.body = safetyHealthInspectionAtt.body;
        insert attachmentObj;
        attachmentObj = new Attachment();

    }     
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  
     **/ 
    public void saveSafetyHealthInspectionAttachmentAndProject()
    {
        
        //system.debug( 'safetyHealthInspectionAttachment ' + safetyHealthInspectionAttachment );
        //system.debug('safetyHealthInspectionAttachment.Name::::'+safetyHealthInspectionAttachment.Name);
        
        //if(safetyHealthTravelAttachment.Body == null)
        //{       
            if(overrideSafetyHealthInspectionName != null && overrideSafetyHealthInspectionName != '')
                safetyHealthInspectionAttachment.Name = overrideSafetyHealthInspectionName;                     
            //try{
                insert safetyHealthInspectionAttachment;
            /*}catch(Exception e){
                ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'An Error has occurred while attmpting to upload attachment.'+e);
                ApexPages.addMessage(oMsg);
            }*/
            
            
            if(project.SafetyHealthInspectionAttachments__c != null)
                project.SafetyHealthInspectionAttachments__c += safetyHealthInspectionAttachment.Id + ';';
            else
                project.SafetyHealthInspectionAttachments__c = safetyHealthInspectionAttachment.Id + ';'; 
            
            update project;                
            
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :project.Id]);
            safetyHealthInspectionAttachment = null;
        //}               
    }   
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  PageReference
     **/ 
    public PageReference newInduction()
    {
        update project;
        
        Induction__c induction =  new Induction__c(Project__c = project.Id, Name='New Induction', CurrencyIsoCode = project.CurrencyIsoCode);
        //Induction__c induction =  new Induction__c(Project__c = project.Id, Name='New Induction');
        insert induction;
        
        PageReference myPage = new PageReference('/' + induction.Id + '/e');
        myPage.getParameters().put('saveURL', '/apex/ECO_SafetyHealthEnvironment?Id=' + project.Id);
        myPage.getParameters().put('retURL', '/apex/ECO_SafetyHealthEnvironment?Id=' + project.Id + '&RecordToDelete='+ induction.Id + '&RecordType=Induction');
   
        return myPage;
    }
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  PageReference
     **/ 
    public PageReference newInductionTeamMember()
    {
        update project;
        
        InductedProjectTeamMembers__c projectTeamMember =  new InductedProjectTeamMembers__c(Project__c = project.Id, Induction__c = inductionId);
        insert projectTeamMember;
        
        PageReference myPage = new PageReference('/' + projectTeamMember.Id + '/e');
        myPage.getParameters().put('saveURL', '/apex/ECO_SafetyHealthEnvironment?Id=' + project.Id);
        myPage.getParameters().put('retURL', '/apex/ECO_SafetyHealthEnvironment?Id=' + project.Id + '&RecordToDelete='+ projectTeamMember.Id + '&RecordType=TeamMember');
   
        return myPage;
    }
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  PageReference
     **/ 
    public PageReference gotoLocationsAndResilience()
    {
        update project; 
        
        PageReference myPage = new PageReference('/apex/ECO_Resilience');       
        myPage.getParameters().put('Id',  project.Id);
        myPage.getParameters().put('fromSHE',  '1');
        myPage.getParameters().put('retURL',  '/apex/ECO_SafetyHealthEnvironment?Id=' + project.Id);
        return myPage;          
    }
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  PageReference
     **/ 
    public PageReference createInductionAttachment()
    {   
        PageReference myPage = new PageReference('/p/attach/NoteAttach?pid=' + inductionId2.left(15) + '&parentname=' + inductionName2 + '&retURL=/apex/ECO_SafetyHealthEnvironment?Id='+project.Id);
        return myPage;
    }   

}