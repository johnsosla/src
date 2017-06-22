/*******************************************************************************
*
* PURPOSE: Base decorator for sObjects
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
*******************************************************************************/
public virtual class GFA_BaseModel {

    protected sObject mObj {get; set;}

    public GFA_BaseModel(sObject obj) {
        mObj = obj;
    }

    public Id getId() {
        return mObj.Id;
    }

    public Boolean isNew() {
        return String.isBlank(getId());
    }
    public Boolean isExisting() {
        return !isNew();
    }

    public sObject getObj() {
        return mObj;
    }

    public virtual void save() {
        upsert mObj;
    }

    public virtual void destroy() {
        delete mObj;
    }

    public static void destroy(List<GFA_BaseModel> modelList) {
        List<sObject> records = new List<sObject>();

        for (GFA_BaseModel record : modelList) {
            if (record.getId() != null) {
                records.add(record.getObj());
            }
        }

        delete records;
    }

    public virtual GFA_BaseModel cloneModel() {
        return new GFA_BaseModel(mObj.clone(false, true));
    }

    public static void save(List<GFA_BaseModel> modelList) {
        List<sObject> updateList = new List<sObject>();
        List<sObject> insertList = new List<sObject>();

        for (GFA_BaseModel tempModel : modelList) {
            if (tempModel.getId() != null) {
                updateList.add(tempModel.getObj());
            } else {
                insertList.add(tempModel.getObj());
            }
        }

        if (!insertList.isEmpty()) {
            insert insertList;
        }
        if (!updateList.isEmpty()) {
            update updateList;
        }
    }
}