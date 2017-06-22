/**
* @author Ethos Solutions
* @version 1.0
* @description COMPONENT: AECOM Sales Goal Tracking (ASGT)
*              CLASS: SGT_BaseModel
*              PURPOSE: Base model (decorator) class
*              CREATED: 06/2016 Ethos Solutions - www.ethos.com
**/
public virtual class SGT_BaseModel {

    protected sObject mObj {get; set;}

    public SGT_BaseModel(sObject obj) {
        mObj = obj;
    }

    public Id getId(){
        return mObj.Id;
    }

    public void setId(Id i) {
        mObj.Id = i;
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

    public static List<sObject> undecorate(List<SGT_BaseModel> mList) {
        List<sObject> result = new List<sObject>();

        for (SGT_BaseModel m : mList) {
            result.add(m.getObj());
        }

        return result;
    }

    public static void destroy(List<SGT_BaseModel> modelList) {
        List<sObject> records = new List<sObject>();

        for(SGT_BaseModel record : modelList) {
            if (record.getId() != null) records.add(record.getObj());
        }

        delete records;
    }

    public virtual SGT_BaseModel cloneModel() {
        return new SGT_BaseModel(mObj.clone(false, true));
    }

    public static void save(List<SGT_BaseModel> modelList) {
        List<sObject> updateList = new List<sObject>();
        List<sObject> insertList = new List<sObject>();

        for (SGT_BaseModel tempModel : modelList) {
            if (tempModel.getId() != null) {
                updateList.add(tempModel.getObj());
            } 
            else {
                insertList.add(tempModel.getObj());
            }
        }

        if (!insertList.isEmpty()) Database.insert(insertList, false);
        if (!updateList.isEmpty()) Database.update(updateList, false);
    }
    
    //---Will walk the sObject references to parent fields to get the value
    public Object get(String fieldName) {
        //---Split field into parts, e.g. Account__r.Name => ['Account__r', 'Name']
        List<String> objectParts = fieldName.toLowerCase().split('[.]');
        //---The last field in the list is the name of the field on the final object to use
        String finalField = objectParts.remove(objectParts.size() - 1);

        //---All the other fields in the list (if there are any) are 
        //---Relationship fields, so the relationships need to be traversed
        sObject target = mObj;
        for (String part : objectParts) {
            target = target.getSObject(part);
            //---Lookup is null, no value to return
            if (target == null) {
                return null;
            }
        }

        //---All relationships have been traversed, use the finalField found before 
        //---To access that field on the last parent object found
        return target.get(finalField);
    }  
}