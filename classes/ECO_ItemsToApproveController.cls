public with sharing class ECO_ItemsToApproveController{
    
    // @Author: Scott Mantei
    // @Created: Sep 21, 2016
    // This is a controller to the ECO_ItemsToApprove VF page. It basically mimics the 
    // Items to Approve list on the Home Page, but without the Reassign Links and the 
    // Manage All button.
    
    public List<ECO_PiwWrapper> pws {get; set;}
    public Id userId {get; set;}    
    public String userName {get; set;}    
        
    public ECO_ItemsToApproveController() {
        userId = UserInfo.getUserId();
        userName = [Select Name From User Where Id = :UserInfo.getUserId()].Name;
   
        // Create a list of ECO_PiwWrapper objects, which is a wrapper class
        pws = new List<ECO_PiwWrapper>();
        
        // Get list of queues the logged-in user might be a member of
        Set<Id> actorIds = new Set<Id>();
        for (GroupMember gm : [Select Group.Name, GroupId From GroupMember Where UserOrGroupId = :UserInfo.getUserId()]) {
            actorIds.add(gm.GroupId);
        }    

        // If the queue is part of a Public Group, need to add those Ids to actorIds also
        for (GroupMember gm : [Select Group.Name, GroupId From GroupMember Where UserOrGroupId In :actorIds]) {
            actorIds.add(gm.GroupId);
        } 
        
        // Also add the User Id
        actorIds.add(UserInfo.getUserId());
        
        // Get current list of items to approve for the logged in user
        List<ProcessInstanceWorkitem> pis = [SELECT ProcessInstance.TargetObjectId
                                             , ProcessInstance.LastModifiedById
                                             , ProcessInstance.LastModifiedBy.Name
                                             , ActorId
                                             , Actor.Name
                                             , CreatedDate                                              
                                             FROM ProcessInstanceWorkitem
                                             Where actorid In :actorIds
                                             And isDeleted = false];
        
        Set<String> targetObjectsPrefix = new Set<String>();
        
        // Populate fields and append to the list
        for (ProcessInstanceWorkitem pi : pis) {
            ECO_PiwWrapper pw = new ECO_PiwWrapper(pi);
            pw.keyPrefix = String.valueOf(pi.ProcessInstance.TargetObjectId).left(3);
            pw.targetId = pi.ProcessInstance.TargetObjectId;
            pws.add(pw);
        
            targetObjectsPrefix.add(pw.keyPrefix); 
        }
                
        
        Map<String, String> prefix2Label = new Map<String, String>();
        Map<String, String> prefix2Api = new Map<String, String>();
        
        // Get the object label and api name
        for (EntityDefinition e : [SELECT QualifiedApiName, KeyPrefix, Label FROM EntityDefinition Where KeyPrefix In :targetObjectsPrefix]){
            prefix2Label.put(e.KeyPrefix, e.Label);
            prefix2Api.put(e.KeyPrefix, e.QualifiedApiName);
        }
        
        // Populate the items in the wrapper list with the object label and api name
        for (ECO_PiwWrapper pw : pws) {
            pw.objectLabel = prefix2Label.get(pw.keyPrefix); 
            pw.objectApi = prefix2Api.get(pw.keyPrefix); 
        }
        
        // Create a map with the object api name as key and a list of ids as value
        // This will be used later to dynamically query those objects
        Map<String, List<Id>> targetMap = new Map<String, List<Id>>();
        for (ECO_PiwWrapper pw : pws) {
            if (targetMap.get(pw.objectApi) == null){
                targetMap.put(pw.objectApi, new List<Id>());
            }
            targetMap.get(pw.objectApi).add(pw.targetId);    
        }   
        
        Map<Id, String> id2Name = new Map<Id, String>();
        
        // Create a dynamic query for each object and obtain the name field for each
        // Populate the id2Name map with this info
        for (String apiName : targetMap.keySet()) {
            List<Id> ids = targetMap.get(apiName);
            String query = 'Select Name From ' + apiName + ' Where Id In :ids';    
            List<sObject> sobjList = Database.query(query);
            for(sObject so : sobjList) {
                id2Name.put(so.Id, String.valueOf(so.get('Name')));
            }
        }
        
        // Using the id2Name, loop through the items in the wrapper list and populate
        // the targetName field
        String targetId = '';
        for (ECO_PiwWrapper pw : pws) {
            pw.targetName = id2Name.get(pw.TargetId);   
        }
        
        // The wrapper class has a custom sort, based on CreatedDate, descending
        pws.sort();
 
    
    }
}