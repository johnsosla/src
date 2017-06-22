/** ------------------------------------------------------------------------------------------------------
* @Description Trigger Handler for DOA Approver Object
*
* @Author      NTT Data - Priya Parepalli
* @Date        September, 2016
*-----------------------------------------------------------------------------------------------------*/
public class ECO_DOAApproverTriggerHandler 
{
    /**
     * Trigger Handler Method to create Project Team Members for DOA Approvers
     *
     * @Author  NTT Data - Priya Parepalli
     * @Date    September, 2016
     *
     * @param   list<DOAApprover__c>
     * @param   Map<Id, DOAApprover__c>
     * @param   Boolean
     * @param   Boolean
     * @return  null
     **/
    public static void createDOAApprovers(list<DOAApprover__c> lApprovers, Map<Id, DOAApprover__c> oldApproversMap, Boolean isInsert, Boolean isUpdate){
        System.debug('Inside createDOAApprovers ');

        Set<String> projectIds = new Set<String>();
        Set<Id> userIds = new Set<Id>();
        Set<String> sPTMcombi = new Set<String>();
        Set<String> sProjectUser = new Set<String>();
        Set<String> sProjectOldNewUser = new Set<String>();
        
        Map<Id,Id> mUserContact = new Map<Id,Id>();
        Map<Id,DOAApprovalRequest__c> mDOAToInsert = new Map<Id,DOAApprovalRequest__c>();
        Map<Id,DOAApprovalRequest__c> mDOAToUpdate = new Map<Id,DOAApprovalRequest__c>();
         
        List<ProjectTeamMember__c> listPTMToInsert = new List<ProjectTeamMember__c>();
        List<ProjectTeamMember__c> listPTMToUpdate = new List<ProjectTeamMember__c>();
        List<ProjectTeamMember__c> listPTMToDelete = new List<ProjectTeamMember__c>();

        //new
        List<ProjectTeamMember__c> lAllPTMs = new List<ProjectTeamMember__c>();
        List<DOAApprover__c> lAllApprovers = new List<DOAApprover__c>();
        Set<String> sProjUserOnPTM = new Set<String>();
        Set<String> sInsertProjUser = new Set<String>();
        Set<String> sDOAApprover = new Set<String>();
        Set<Id> sApproverIds = new Set<Id>();
        Set<String> sOldNewApproverProj = new Set<String>();
        Map<String, String> mUsrProjDoaProj = new Map<String,String>();
        Map<String, ProjectTeamMember__c> mProjUserPTM = new Map<String, ProjectTeamMember__c>();

        ProjectRole__c[] pRole = [select id, Name from ProjectRole__c where Name = 'DOA Approver'];

        for(DOAApprover__c approver : lApprovers){
            if(isInsert || (isUpdate && approver.ApproverName__c != oldApproversMap.get(approver.Id).ApproverName__c ) 
                        && approver.Project__c != null && approver.Project__c != ''){
                //lDOAIds.add(approver.DOAApprovalRequest__c);
                projectIds.add(String.valueOf(approver.Project__c).substring(0, 15));
                userIds.add(approver.ApproverName__c);
                sApproverIds.add(approver.Id);
            }
            
        }

        
        if(projectIds != null && projectIds.size()>0 && userIds!= null && userIds.size()>0){
            lAllPTMs = [Select Id, Project__c, ProjectRole__c, Contact__r.pse__Salesforce_User__c, Contact__c 
                         From ProjectTeamMember__c 
                         WHERE Project__c IN :projectIds
                         AND ProjectRole__c = :pRole[0].Id];

            for(ProjectTeamMember__c ptm : lAllPTMs){
                String sProject = String.valueOf(ptm.Project__c).substring(0, 15);
                String sUser = String.valueOf(ptm.Contact__r.pse__Salesforce_User__c).substring(0, 15);
                sProjUserOnPTM.add(sProject+'-'+sUser);
                mProjUserPTM.put(sProject+'-'+sUser, ptm);
            }

            
            lAllApprovers = [Select Id, ApproverName__c, Project__c, DOAApprovalRequest__c
                                FROM DOAApprover__c 
                                WHERE Project__c IN :projectIds 
                                AND Id NOT IN : sApproverIds];

            for(DOAApprover__c app : lAllApprovers){
                String sProject = String.valueOf(app.Project__c).substring(0, 15);
                String sUser = String.valueOf(app.ApproverName__c).substring(0, 15);
                sDOAApprover.add(app.DOAApprovalRequest__c+'-'+app.ApproverName__c);
                mUsrProjDoaProj.put(sUser+'-'+sProject , app.Id+'-'+app.Project__c );
            }

            for(Contact con : [Select Id, pse__Salesforce_User__c From Contact Where pse__Salesforce_User__c in :userIds]){
                mUserContact.put(con.pse__Salesforce_User__c, con.Id);
            }

            
            for(DOAApprover__c approver : lApprovers){
                Id ContactId = mUserContact.get(approver.ApproverName__c);
                
                String sProject = String.valueOf(approver.Project__c).substring(0, 15);
                String sUser = String.valueOf(approver.ApproverName__c).substring(0, 15);
                
                if(isInsert && sProjUserOnPTM!= null && !sProjUserOnPTM.contains(sProject+'-'+sUser) && ContactId != null){

                    listPTMToInsert.add(new ProjectTeamMember__c(Contact__c = ContactId, ProjectRole__c = pRole[0].Id, Project__c = approver.Project__c));

                }else if(isUpdate && ContactId != null){
                    String sOldUser = oldApproversMap.get(approver.Id).ApproverName__c;
                    sOldUser = sOldUser.substring(0, 15);
                    //check if old user is not mentioned on any other DOA of this project. If not mentioned - update old ptm with new user, if already mentioned - create new ptm
                    String mapValue = approver.Id+'-'+approver.Project__c;
                    
                    if(mUsrProjDoaProj!= null && mUsrProjDoaProj.containsKey(sOldUser+'-'+sProject) //&& mUsrProjDoaProj.get(sOldUser+'-'+sProject) != mapValue 
                        && !mProjUserPTM.containsKey(sProject+'-'+sUser)){ 
                        
                        //sInsertProjUser.add(approver.Project__c+'-'+approver.ApproverName__c);
                        listPTMToInsert.add(new ProjectTeamMember__c(Contact__c = ContactId, ProjectRole__c = pRole[0].Id, Project__c = approver.Project__c));

                    }else if(mUsrProjDoaProj!= null && !mUsrProjDoaProj.containsKey(sOldUser+'-'+sProject)
                            && mProjUserPTM != null && mProjUserPTM.containsKey(sProject+'-'+sOldUser)){

                        ProjectTeamMember__c ptm = new ProjectTeamMember__c();
                        if(!mUsrProjDoaProj.containsKey(sUser+'-'+sProject)){

                            ptm = mProjUserPTM.get(sProject+'-'+sOldUser);
                            ptm.Contact__c = ContactId;
                            listPTMToUpdate.add(ptm);
                        }
                        //sOldNewApproverProj.add(oldApproversMap.get(approver.Id).ApproverName__c+'-'+approver.ApproverName__c+'-'+approver.Project__c);
                        //old user not on any other doa but new user on other doa. So delete old user ptm and no need to insert new user
                        else {
                            ptm = mProjUserPTM.get(sProject+'-'+sOldUser);
                            listPTMToDelete.add(ptm);
                        }
                    }
                    
                    

                }
            }
            
            if(listPTMToInsert != null && listPTMToInsert.size() > 0){
                try{
                    insert listPTMToInsert;
                }catch(Exception e){
                    ECO_Service_ErrorLog.formatPageError(e, e.getMessage());
                }
                    
            }

            if(listPTMToUpdate != null && listPTMToUpdate.size()>0){
                try{
                    update listPTMToUpdate;
                }catch(Exception e){
                    ECO_Service_ErrorLog.formatPageError(e, e.getMessage());
                }
                    
            }

            if(listPTMToDelete != null && listPTMToDelete.size()>0){
                try{
                    delete listPTMToDelete;
                }catch(Exception e){
                    ECO_Service_ErrorLog.formatPageError(e, e.getMessage());
                }
                    
            }
        }

    }
    
}