/*******************************************************************************
*
* PURPOSE: Decorator for Attachment object
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
*******************************************************************************/
public with sharing class GFA_Attachment extends GFA_BaseModel {

    public static Finder find = new Finder('Attachment');

    public Attachment obj {
        get {
            return (Attachment)mObj;
        }
    }

    public GFA_Attachment() {
        this(new Attachment());
    }

    public GFA_Attachment(Attachment attachment) {
        super(attachment);
    }

    public String getName() {
        return obj.Name;
    }
    public void setName(String name) {
        obj.Name = name;
    }

    public class Finder extends GFA_BaseFinder {

        public Finder(String sObjectName) {
            super(sObjectName);
        }

        public GFA_Attachment findById(Id attachmentId) {
            Attachment attachment = (Attachment)byId(attachmentId);
            return new GFA_Attachment(attachment);
        }

        public List<GFA_Attachment> findByProjectId(Id projectId) {
            List<GFA_Attachment> attachments = new List<GFA_Attachment>();
            for (Attachment attachment : (List<Attachment>)Database.query(
                        getSelect() + ' where ParentId =: projectId')) {
                attachments.add(new GFA_Attachment(attachment));
            }
            return attachments;
        }
    }
}