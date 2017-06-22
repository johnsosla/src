/*************************************************************************
*
* PURPOSE: Decorator for rs Update Tracking
*
*
* CREATED: 2015 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
***************************************************************************/
public class rsUpdateTracking extends rsModel {

    public static Finder find = new Finder('rs_Update_Tracking__c');

    public rsUpdateTracking() {
        super(new rs_Update_Tracking__c());
    }

    public rsUpdateTracking(rs_Update_Tracking__c track) {
        super(track);
    }

    public rsUpdateTracking(Id userId) {
        super(new rs_Update_Tracking__c(User__c = userId));
    }

    public String getDetails() {
        return (String)mObj.get('Details__c');
    }
    public void setDetails(String Details) {
        mObj.put('Details__c', Details);
    }

    public String getSource() {
        return (String)mObj.get('Source__c');
    }
    public void setSource(String Source) {
        mObj.put('Source__c', Source);
    }

    public Id getUserId() {
        return (Id)mObj.get('User__c');
    }
    public void setUserId(Id UserId) {
        mObj.put('User__c', UserId);
    }

    public String getCreatedDate() {
        return ((rs_Update_Tracking__c)mObj).CreatedDate.format();
    }

    public String getCreatedByName() {
        return ((rs_Update_Tracking__c)mObj).CreatedBy.Name;
    }


    public class Finder extends rsFinder {

        public Finder(String sObjectName) {
            super(sObjectName);
            addFields(new Set<String> {
                'CreatedBy.Name'
            });
        }

        public rsUpdateTracking byTrackId(Id trackId) {
            return new rsUpdateTracking((rs_Update_Tracking__c)byId(trackId).getObj());
        }

        public List<rsUpdateTracking> getByWhere(String whereStr) {
            System.debug('### ' + whereStr);
            List<rsUpdateTracking> returnList = new List<rsUpdateTracking>();
            for(rs_Update_Tracking__c track : (List<rs_Update_Tracking__c>)Database.query(getSelect() + ' where ' + whereStr)) {
                returnList.add(new rsUpdateTracking(track));
            }
            return returnList;
        }

        public List<rsUpdateTracking> byUserId(Id userId) {
            return getByWhere('User__c = ' + rsStringUtil.quote(userId));
        }


    }

}