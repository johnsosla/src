public virtual class CFM_BaseModel {
	protected sObject mObj {get; set;}

	public CFM_BaseModel(sObject obj) {
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

    public static CFM_BaseModel decorate(sObject sObj) {
        return null;
    }

    public static List<sObject> undecorate(List<CFM_BaseModel> mList) {
        List<sObject> result = new List<sObject>();

        for (CFM_BaseModel m : mList) {
            result.add(m.getObj());
        }

        return result;
    }

    public static void destroy(List<CFM_BaseModel> modelList) {
        List<sObject> records = new List<sObject>();

        for(CFM_BaseModel record : modelList) {
            if (record.getId() != null) records.add(record.getObj());
        }

        delete records;
    }

    public virtual CFM_BaseModel cloneModel() {
        return new CFM_BaseModel(mObj.clone(false, true));
    }

    public static void save(List<CFM_BaseModel> modelList) {
        List<sObject> updateList = new List<sObject>();
        List<sObject> insertList = new List<sObject>();

        for (CFM_BaseModel tempModel : modelList) {
            if (tempModel.getId() != null) {
                updateList.add(tempModel.getObj());
            } 
            else {
                insertList.add(tempModel.getObj());
            }
        }

        if (!insertList.isEmpty()) insert insertList;
        if (!updateList.isEmpty()) update updateList;
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