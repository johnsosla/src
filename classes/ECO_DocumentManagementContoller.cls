/** ------------------------------------------------------------------------------------------------------
* @Description This is a controller extension that extends the existing custom  controller
*
* @Author      NTTD
* @Date        2016
*/
public class ECO_DocumentManagementContoller {
    
    private Transient Attachment documentControlSystemAttachment;
    public String overrideControlSystemName  {get;set;}
    private Transient Attachment documentNamingConventionsAttachment;
    public String overrideNamingConventionsName  {get;set;}
    private Transient Attachment fileManagementStructureAttachment;
    public String overrideFileManagementStructureName  {get;set;}
    private Transient Attachment documentTransmittalsAttachment;
    public String overrideTransmittalsName {get;set;}
    private Transient Attachment documentRecordsAndArchivingAttachment;
    public String overrideRecordsArchivingName {get; set;}
    private Transient Attachment documentCommentsOtherNotesAttachment;
    private Transient Attachment DocM_Attachment;
    public String overrideCommentsOtherNotesName {get; set;}
    public string sTargetAttachment {get;set;}
    public String overrideDocMName  {get;set;}
    
    public pse__Proj__c project;
    public map<Id, Attachment> attachmentsMap {get; set;}
    public list<SelectOption> types { get; set; }

    public list<string> lstLinks {get;set;}

    public boolean bAttachAvail {get;set;}
    public boolean bViewLinks {get;set;}
    
    /**
     * 
     *
     * @Author  NTTD - Shoukat Khan
     * @Date    2016
     *
     * @param   stdController
     * @return  
     **/
    public ECO_DocumentManagementContoller(ApexPages.StandardController controller)
    {
        project = (pse__Proj__c) controller.getRecord();
        
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
    public ECO_DocumentManagementContoller(pse__Proj__c proj)
    {
        //US-06752: To avoid addFields error for 'Print Project Plan' button, created new contructor and moved common code to initialize method.
        project = proj;
        initialize();
    }

    /**
     * 
     *
     * @Author  NTTD - Shoukat Khan
     * @Date    2016
     *
     * @param   
     * @return  
     **/
    private void initialize()
    {
        
        attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :project.Id]);
        
        types = new List<SelectOption>();
        types.add(new SelectOption('AECOM', 'AECOM'));
        types.add(new SelectOption('Client/Project', 'Client/Project'));  

        bAttachAvail = true;

        

        lstLinks = new list<string>();

        if(project.DocumentControlLinks__c != null){
           ViewLinks();
        }  else {
            EditLinks();
        }
        
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
    public PageReference EditLinks(){
        bViewLinks = false;
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
    public PageReference ViewLinks(){
        bViewLinks = true;
        splitList();
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
    public PageReference setDirty(){

        System.Debug('BrentBrentBrent');
        bAttachAvail = false;
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
    public void splitList(){

        lstLinks = new list<string>();

        if(project.DocumentControlLinks__c != null) {            
            list<string> templst = project.DocumentControlLinks__c.split('\n', -1);

            for(string s:templst){
                string temp = s.trim();

                if(temp.length() == 0){
                    continue;
                }

                //if(temp.indexof('http') != 0){
                //    temp = 'https://' + temp;
                //}
                lstLinks.add(temp);
            }
        }
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
    public Attachment docControlSystemAttachment
    {
        get
        {
            if(documentControlSystemAttachment==null)
            {
                documentControlSystemAttachment = new Attachment(parentid = project.id);
            }
            return documentControlSystemAttachment;
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
    public Attachment docNamingConventionsAttachment
    {
        get
        {
            if(documentNamingConventionsAttachment==null)
            {
                documentNamingConventionsAttachment = new Attachment(parentid = project.id);
            }
            return documentNamingConventionsAttachment;
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
    public Attachment fManagementStructureAttachment
    {
        get
        {
            if(fileManagementStructureAttachment==null)
            {
                fileManagementStructureAttachment = new Attachment(parentid = project.id);
            }
            return fileManagementStructureAttachment;
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
    public Attachment docTransmittalsAttachment
    {
        get
        {
            if(documentTransmittalsAttachment==null)
            {
                documentTransmittalsAttachment = new Attachment(parentid = project.id);
            }
            return documentTransmittalsAttachment;
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
    public Attachment docRecordsAndArchivingAttachment
    {
        get
        {
            if(documentRecordsAndArchivingAttachment==null)
            {
                documentRecordsAndArchivingAttachment = new Attachment(parentid = project.id);
            }
            return documentRecordsAndArchivingAttachment;
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
    public Attachment docCommentsOtherNotesAttachment
    {
        get
        {
            if(documentCommentsOtherNotesAttachment==null)
            {
                documentCommentsOtherNotesAttachment = new Attachment(parentid = project.id);
            }
            return documentCommentsOtherNotesAttachment;
        }
        set;
    }    
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   attachmentIds list
     * @return  Attachments list 
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
    public list<Attachment> getAttachedDocumentControlSystemFiles()
    {

        list<String> attachmentIds = new list<String>();
        if(project.DocumentControlSystemAttachment__c != null)
            attachmentIds = project.DocumentControlSystemAttachment__c.split(';');
            
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
    public void saveDocumentControlSystemAttachmentAndProject()
    {
        if(documentControlSystemAttachment.Body != null)
        {   
            if(overrideControlSystemName != null && overrideControlSystemName != '')
                documentControlSystemAttachment.Name = overrideControlSystemName;               
            insert documentControlSystemAttachment;
            
            if(project.DocumentControlSystemAttachment__c != null)
                project.DocumentControlSystemAttachment__c += documentControlSystemAttachment.Id + ';';
            else
                project.DocumentControlSystemAttachment__c = documentControlSystemAttachment.Id + ';';          
            update project;
            
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :project.Id]);
            documentControlSystemAttachment = null;
        }           
    }
    
     /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  attachment lists
     **/
    public list<Attachment> getAttachedDocumentNamingConventionsFiles()
    {
        list<String> attachmentIds = new list<String>();
        if(project.DocumentNamingConventionsAttachment__c != null)
            attachmentIds = project.DocumentNamingConventionsAttachment__c.split(';');

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
    public void saveDocumentNamingConventionsAttachmentAndProject()
    {
        if(documentNamingConventionsAttachment.Body != null)
        {
            if(overrideNamingConventionsName != null && overrideNamingConventionsName != '')
                documentNamingConventionsAttachment.Name = overrideNamingConventionsName;                           
            insert documentNamingConventionsAttachment;
            
            if(project.DocumentNamingConventionsAttachment__c != null)
                project.DocumentNamingConventionsAttachment__c += documentNamingConventionsAttachment.Id + ';';
            else
                project.DocumentNamingConventionsAttachment__c = documentNamingConventionsAttachment.Id + ';';
            
            update project;
                
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :project.Id]);
            documentNamingConventionsAttachment = null; 
        }
    }
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  attachment lists
     **/
    public list<Attachment> getAttachedFileManagementStructureFiles()
    {
        list<String> attachmentIds = new list<String>();
        if(project.FileManagementStructureAttachment__c != null)
            attachmentIds = project.FileManagementStructureAttachment__c.split(';');

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
    public void saveFileManagementStructureAttachmentAndProject()
    {
        if(fileManagementStructureAttachment.Body != null)
        {
            if(overrideFileManagementStructureName != null && overrideFileManagementStructureName != '')
                fileManagementStructureAttachment.Name = overrideFileManagementStructureName;                                       
            insert fileManagementStructureAttachment;
            
            if(project.FileManagementStructureAttachment__c != null)
                project.FileManagementStructureAttachment__c += fileManagementStructureAttachment.Id + ';';
            else
                project.FileManagementStructureAttachment__c = fileManagementStructureAttachment.Id + ';';
            
            update project;
                
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :project.Id]);
            fileManagementStructureAttachment = null;   
        }
    }    
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  attachment lists
     **/
     
    public list<Attachment> getAttachedDocumentTransmittalsFiles()
    {
        list<String> attachmentIds = new list<String>();
        if(project.DocumentTransmittalsAttachment__c != null)
            attachmentIds = project.DocumentTransmittalsAttachment__c.split(';');

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
    public void saveDocumentTransmittalsAttachmentAndProject()
    {
        if(documentTransmittalsAttachment.Body != null)
        {
            if(overrideTransmittalsName != null && overrideTransmittalsName != '')
                documentTransmittalsAttachment.Name = overrideTransmittalsName;             
            insert documentTransmittalsAttachment;
            
            if(project.DocumentTransmittalsAttachment__c != null)
                project.DocumentTransmittalsAttachment__c += documentTransmittalsAttachment.Id + ';';
            else
                project.DocumentTransmittalsAttachment__c = documentTransmittalsAttachment.Id + ';';
            
            update project;
                
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :project.Id]);
            documentTransmittalsAttachment = null;  
        }
    }    
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  attachment lists
     **/
    public list<Attachment> getAttachedDocumentRecordsAndArchivingFiles()
    {
        list<String> attachmentIds = new list<String>();
        if(project.DocumentRecordsArchivingAttachment__c != null)
            attachmentIds = project.DocumentRecordsArchivingAttachment__c.split(';');

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
    public void saveDocumentRecordsAndArchivingAttachmentAndProject()
    {
        if(documentRecordsAndArchivingAttachment.Body != null)
        {
            if(overrideRecordsArchivingName != null && overrideRecordsArchivingName != '')
                documentRecordsAndArchivingAttachment.Name = overrideRecordsArchivingName;              
            insert documentRecordsAndArchivingAttachment;
            
            if(project.DocumentRecordsArchivingAttachment__c != null)
                project.DocumentRecordsArchivingAttachment__c += documentRecordsAndArchivingAttachment.Id + ';';
            else
                project.DocumentRecordsArchivingAttachment__c = documentRecordsAndArchivingAttachment.Id + ';';
            
            update project;
                
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :project.Id]);
            documentRecordsAndArchivingAttachment = null;   
        }
    }     
    
    /**
     * 
     *
     * @Author  NTTD
     * @Date    2016
     *
     * @param   
     * @return  attachment lists
     **/
    public list<Attachment> getAttachedDocumentCommentsOtherNotesFiles()
    {
        list<String> attachmentIds = new list<String>();
        if(project.DocumentOtherCommentsNotesAttachment__c != null)
            attachmentIds = project.DocumentOtherCommentsNotesAttachment__c.split(';');

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
    public void saveDocumentCommentsOtherNotesAttachmentAndProject()
    {
        if(documentCommentsOtherNotesAttachment.Body != null)
        {
            if(overrideCommentsOtherNotesName != null && overrideCommentsOtherNotesName != '')
                documentCommentsOtherNotesAttachment.Name = overrideCommentsOtherNotesName;             
            insert documentCommentsOtherNotesAttachment;
            
            if(project.DocumentOtherCommentsNotesAttachment__c != null)
                project.DocumentOtherCommentsNotesAttachment__c += documentCommentsOtherNotesAttachment.Id + ';';
            else
                project.DocumentOtherCommentsNotesAttachment__c = documentCommentsOtherNotesAttachment.Id + ';';
            
            update project;
                
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :project.Id]);
            
            documentCommentsOtherNotesAttachment = null;    
        }
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
        bAttachAvail = true;

        if(project.DocumentControlLinks__c != null){
           ViewLinks();
        }  else {
            EditLinks();
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
     * @return  PageReference 
     **/
    public PageReference removeattachment(){
            id iTargetAttachment = sTargetAttachment;
            Attachment aAttachToRemove = attachmentsMap.get(iTargetAttachment);
            attachmentsMap.remove(iTargetAttachment);
            delete aAttachToRemove;
            project.DocManAttachment__c = project.DocManAttachment__c.remove(iTargetAttachment + ';');
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
     * @return  @attachment lists
     **/
    public list<Attachment> getDocM_AttachmentFiles(){
        list<String> attachmentIds = new list<String>();
        if(project.DocManAttachment__c != null)
                        attachmentIds = project.DocManAttachment__c.split(';');
                        
        //system.debug( 'getOSP_AttachmentFiles called' + attachmentIds.size() );

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
    public void saveDocM_AttachmentAndProject(){
        if(DocM_Attachment.Body != null){

            if(overrideDocMName != null && overrideDocMName != '')
                DocM_Attachment.Name = overrideDocMName; 

            //system.debug( 'DocM_Attachment ' + DocM_Attachment.Name );
            
            insert DocM_Attachment;
            
            if(project.DocManAttachment__c != null)
                project.DocManAttachment__c += DocM_Attachment.Id + ';';
            else
                project.DocManAttachment__c = DocM_Attachment.Id + ';'; 
            
            update project;
            
            attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :project.Id]);
            DocM_Attachment = null;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'A file must be selected in order to attach'));
        }
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
    public Attachment newDocM_Attachment{
        get{
            if(DocM_Attachment==null)
            {
                DocM_Attachment = new Attachment(parentid = project.id);
            }
            return DocM_Attachment;
        }
        set;
    }  
}