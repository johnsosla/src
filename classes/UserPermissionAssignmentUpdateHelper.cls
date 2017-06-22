/*******************************************************************
  Name        :   UserPermissionAssignmentUpdateHelper
  Requester   :   CRS Requirments , Additional global system permissionsets
  Author      :   AECOM - Luke Farbotko
  Version     :   1.0 
  Purpose     :   A Helper class to provide processing of users to 
                  detirmine if they require CRS or other generic 
                  Global permission sets to be added
                     
  Date        :   31 Jul, 2015 
              :   13 Jan, 2016 Efficiency Improvement
********************************************************************/
public  class UserPermissionAssignmentUpdateHelper 
{
    
    public List<PermissionSetAssignment>  permissionSetAssignmentToUpdate = new List<PermissionSetAssignment>{};
    public List<PermissionSetAssignment> permissionSetAssignmentToRemove  = new  List<PermissionSetAssignment>{};

    
    private List<User> users = new List<User>();

    public static void processPermissionSets(List<User> triggerUsers)
    {

        UserPermissionAssignmentUpdateHelper psahelper = new UserPermissionAssignmentUpdateHelper(triggerUsers);

        psahelper.ProcessCRSPermissionsSets();
        psahelper.ProcessGlobalPermissionsSets();

        List<PermissionSetAssignment>  permissionSetAssignmentToUpdate = new List<PermissionSetAssignment>{};
        List<PermissionSetAssignment> permissionSetAssignmentToRemove  = new  List<PermissionSetAssignment>{};

        permissionSetAssignmentToUpdate = psahelper.permissionSetAssignmentToUpdate;
        permissionSetAssignmentToRemove = psahelper.permissionSetAssignmentToRemove;

        // dont create a queue job unless there are items to update 
        if (permissionSetAssignmentToRemove.size() > 0 || permissionSetAssignmentToUpdate.size() > 0)
        {
            System.enqueueJob(new UserPermissionAssignmentUpdateQueue(permissionSetAssignmentToRemove,permissionSetAssignmentToUpdate));
        }
        
    }



    public UserPermissionAssignmentUpdateHelper(List<User> triggerUsers) 
    {
        users = triggerUsers; 
    }


    // Process the users so they have the permission sets configured in global 
    // permission set custom setting. This process will ignore permission sets 
    // bound to a licence
    public void ProcessGlobalPermissionsSets()
    {
        List<Id> generalUserListIdsInsert = new List<Id>();
        for(User user: users)
        {
            generalUserListIdsInsert.add(user.Id);
        }
        generalUserListIdsInsert.sort();

        List<Global_Permission_Sets__c> globalPermissionSetSetting = Global_Permission_Sets__c.getAll().values();  
        List<String>  globalPermissionSetNames = new List<String>  ();
        for (Global_Permission_Sets__c ps: globalPermissionSetSetting)
        {
            globalPermissionSetNames.add(ps.permission_set_name__c);
        }
        

        //Get a list of all other custom permissionset Ids
        Map<id, PermissionSet>  globalPermissionSetIds = new Map<id, PermissionSet>([Select id, Name From PermissionSet where UserLicenseId = '' AND name in :globalPermissionSetNames order by id]);             
        SET<id> keys = globalPermissionSetIds.keyset();

        list<PermissionSetAssignment> permissionSetsAssignmentsThatExist    =       [Select  AssigneeId, PermissionSetId From PermissionSetAssignment 
                                                                                    where PermissionSetId  IN :keys
                                                                                    and AssigneeId IN :generalUserListIdsInsert ORDER BY AssigneeId ASC];

        // Loop through the users backwards
        // generalUserListIdsInsert must both be sorted by the UserID ascending        
        for(Integer user_inc = generalUserListIdsInsert.size() - 1; user_inc >= 0; user_inc--)
        {
            Id userId = generalUserListIdsInsert.get(user_inc);
            for (Id psId : keys)
            {
                
                boolean itemAleadyExists = false;
                // loop through existing permissionset assignment and test if the permission set already exists .. so we can easily remove items 
                for(Integer inc = permissionSetsAssignmentsThatExist.size() - 1; inc >= 0; inc--)
                {
                    PermissionSetAssignment psa = permissionSetsAssignmentsThatExist.get(inc);
                    if(psa.AssigneeId != userId)
                    {
                        // if the assignee does not match the user then it is not necessary to continue
                        // due to the ordering
                        break;
                    }
                    if (psa.PermissionSetId == psId && psa.AssigneeId == userId )
                    {
                         itemAleadyExists = true;
                         // remove the item from the list once it has been found.
                         permissionSetsAssignmentsThatExist.remove(inc);
                         break;
                    }
                    
                }
                if ( itemAleadyExists == false )
                {
                    PermissionSetAssignment psa = new PermissionSetAssignment( AssigneeId = userId);
                    psa.PermissionSetId = psId;
                    permissionSetAssignmentToUpdate.add(psa);
                }
            }
            
        }
    
    }   
    

    // The CRS permission sets are bound to licence types and also have logic based assignmnet
    // thus cant be handled with the global permission set process. 
    public void ProcessCRSPermissionsSets()
    {
        // get CRS permissions sets
        List<PermissionSet>  permissionSetsCRS = [Select id, Name From PermissionSet where name in ('Contract_Reviewer_permission'
                                ) order by Name];
    
        PermissionSet permissionSetCRS = permissionSetsCRS[0];
        //PermissionSet generalPermissionSetCRS = permissionSetsCRS[0];

        List<Id> userListIdsInsert = new List<Id>();
        List<Id> userlistIdsRemove = new List<Id>();
        
        //List<Id> generalUserListIdsInsert = new List<Id>();
        for(User user: users){
            //Detirmine if we are removing or adding the legal contract reviewe permission set for each user
            if (user.Legal__c == true )
            {
                userListIdsInsert.add(user.Id);
            }
            else
            {
                // add to list of users to remove the permision set from 
                userlistIdsRemove.add(user.Id);
            }
            //generalUserListIdsInsert.add(user.Id);
        }
        

        //Get list of updated/inserted legal users that dont have either of the legal contract reviewer permission sets 
        List<User> userListToInsertCRS  = new  List<User>([SELECT id, profile.UserLicense.Name
                                                         FROM User
                                                         WHERE id IN :userListIdsInsert AND 
                                                             id not in (Select  AssigneeId From PermissionSetAssignment 
                                                                        where (PermissionSetId = :permissionSetCRS.Id
                                                                                 //OR PermissionSetId = :permissionSetSFCRS.Id
                                                                                 )
                                                                                 and AssigneeId IN :userListIdsInsert)]);   
                                        
        //Get list of updated/inserted users that dont have either of the contract reviewer general  permission sets                                                                                
        /*List<User> generalUserListToInsertCRS     =       new  List<User>([SELECT id, profile.UserLicense.Name
                                                         FROM User
                                                         WHERE id IN :generalUserListIdsInsert AND 
                                                             id not in (Select  AssigneeId From PermissionSetAssignment 
                                                                        where (PermissionSetId = :generalPermissionSetCRS.Id
                                                                                 OR PermissionSetId = :generalPermissionSetSFCRS.Id)
                                                                                 and AssigneeId IN :generalUserListIdsInsert)]);            
    */

        // loop through discovered legal users and add the permission set related to their licence.
        for(User user : userListToInsertCRS)
        {
            PermissionSetAssignment psa = new PermissionSetAssignment( AssigneeId = user.Id);
            /*if (user.profile.UserLicense.Name == 'salesforce' )
            {
                psa.PermissionSetId = permissionSetSFCRS.Id;
                permissionSetAssignmentToUpdate.add(psa);
            }
            else if (user.profile.UserLicense.Name == 'Force.com - App Subscription')
            {*/
                psa.PermissionSetId = permissionSetCRS.Id;
                permissionSetAssignmentToUpdate.add(psa);
            //}

            
        }
        

        // loop through discovered  users and add the permission set related to their licence.
        /*for(User user : generalUserListToInsertCRS)
        {
            PermissionSetAssignment psa = new PermissionSetAssignment( AssigneeId = user.Id);
            if (user.profile.UserLicense.Name == 'salesforce' )
            {
                psa.PermissionSetId = generalPermissionSetSFCRS.Id;
                permissionSetAssignmentToUpdate.add(psa);
            }
            else if (user.profile.UserLicense.Name == 'Force.com - App Subscription') 
            {
                psa.PermissionSetId = generalPermissionSetCRS.Id;
                permissionSetAssignmentToUpdate.add(psa);
            }
            
        }*/

        // find the users that require the contract reviewer permssion set removed.
        permissionSetAssignmentToRemove  =   [SELECT id
                                                     FROM PermissionSetAssignment
                                                     WHERE (PermissionSetId = :permissionSetCRS.Id
                                                     //OR PermissionSetId = :permissionSetSFCRS.Id
                                                     ) and AssigneeId IN :userlistIdsRemove];


    }
}