public virtual class PMC_BaseModel {
	protected sObject mObj { get; set; }
	protected Boolean isPlaceHolder { get; set; }

	public PMC_BaseModel(sObject obj) {
		mObj = obj;
		isPlaceHolder = false;
	}

	public Id getId() {
		return mObj.Id;
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

	public static List<sObject> undecorate(List<PMC_BaseModel> mList) {
		List<sObject> result = new List<sObject>();

		for (PMC_BaseModel m : mList) {
			result.add(m.getObj());
		}

		return result;
	}

	public static void destroy(List<PMC_BaseModel> modelList) {
		List<sObject> records = new List<sObject>();
		for (PMC_BaseModel record : modelList) {
			if (record.getId() != null) records.add(record.getObj());
		}
		delete records;
	}

	public virtual PMC_BaseModel cloneModel() {
		return new PMC_BaseModel(mObj.clone(false, true));
	}

	public static void save(List<PMC_BaseModel> saveList) {
		List<sObject> updateList = new List<sObject>();
		List<sObject> insertList = new List<sObject>();

		for (PMC_BaseModel row : saveList) {
			if (row.getId() != null) {
				updateList.add(row.getObj());
			} 
			else {
				insertList.add(row.getObj());
			}    
		}
		if (!insertList.isEmpty()) insert insertList;
		if (!updateList.isEmpty()) update updateList;
	}
}