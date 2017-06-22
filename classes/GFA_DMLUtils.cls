/*******************************************************************************
*
* PURPOSE: Base decorator for sObjects
*
* CREATED: 2016 Ethos Solutions - www.ethos.com
* AUTHOR:
*******************************************************************************/
public virtual without sharing class GFA_DMLUtils {

    protected sObject mObj {get; set;}

    public GFA_DMLUtils(sObject obj) {
        mObj = obj;
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