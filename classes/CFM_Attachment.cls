public with sharing class CFM_Attachment extends CFM_BaseModel {
    public static Finder find = new Finder();

    public static final String STATUS_NEW = 'New';
    public static final String STATUS_PENDING_REVIEW = 'Pending PM Review';
    public static final String STATUS_REVIEWED = 'PM Reviewed';
    public static final String STATUS_PENDING_QSUBMIT = 'Pending Qualtrics Submittal';
    public static final String STATUS_SENT = 'Sent to Qualtrics';


    public Attachment obj { get { 
            return (Attachment)mObj; 
        } 
    }

    public CFM_Attachment() {
        this(new Attachment());
    }

    public CFM_Attachment(Attachment sObj) {
        super(sObj);
    }

    public String getName() {
        return (String)mObj.get('Name');
    }
    public void setName(String name) {
        mObj.put('Name', name);
    }

    public Boolean getIsPrivate() {
        return (Boolean)mObj.get('IsPrivate');
    }
    public void setIsPrivate(Boolean isPrivate) {
        mObj.put('IsPrivate', isPrivate);
    }

    public Id getParentId() {
        return (Id)mObj.get('ParentId');
    }
    public void setParentId(Id parentId) {
        mObj.put('ParentId', parentId);
    }
    
    public Blob getBody() {
        return (Blob)mObj.get('Body');
    }
    public void setBody(Blob body) {
        mObj.put('Body', body);
    }
    
    public static List<CFM_Attachment> decorate(List<Attachment> sList) {
        List<CFM_Attachment> result = new List<CFM_Attachment>();
        for (Attachment row : sList) result.add(new CFM_Attachment(row));
        return result;
    }

    public class Finder extends CFM_BaseFinder {
        public Finder() {
            super('Attachment');
        }

        public List<CFM_Attachment> byParentId(Id parentId) {
            return decorate((List<Attachment>)getSelectWhere('ParentId', parentId));
        }

    }
}