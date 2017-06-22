public class ECO_TechnicalQualityTeam_TriggerHandler {
    public static Boolean emailSent = false;
    public static void handleEmailNotification(list<TechnicalQualityTeam__c> lTQT, boolean isTriggerNew){
        //If project stage = execution and email not sent already to Team Member for this role as part of another deliverable for this project
        /*List <TechnicalQualityTeam__c> updateIds = new List <TechnicalQualityTeam__c>();
        for(TechnicalQualityTeam__c tqt :lTQT){
            emailSent = false;
            if(tqt.Role__c == 'Reviewer' || tqt.Role__c == 'Lead Verifier' || tqt.Role__c == 'Independent Reviewer' || tqt.Role__c == 'Project Quality Manager' || tqt.Role__c == 'Interdisciplinary Reviewer')
            	handleEmailNotificationHelper(tqt);
            if(emailSent)
                updateTQTfield(tqt);
            //updateIds.add(tqt);
        }
        if(updateIds.size()>0){
            List <TechnicalQualityTeam__c> lUpdateTQT = new List <TechnicalQualityTeam__c>([Select Id From TechnicalQualityTeam__c Where Id IN :updateIds]);
            for(TechnicalQualityTeam__c tqt: lUpdateTQT){
                tqt.IsEmailSent__c = true;
            }
            update lUpdateTQT;
        }*/

        if(!ECO_TechnicalQualityTeam_TriggerHandler.emailSent){


            set<string> sRoles = new set<string>{'Reviewer', 'Lead Verifier','Independent Reviewer', 'Project Quality Manager', 'Interdisciplinary Reviewer' };
            set<id> sidProj = new set<id>();
            set<id> sidTQTM = new set<id>();
            set<string> ssRowCombo = new set<string>();
            map<string, TechnicalQualityTeam__c> mapTQTGroup = new map<string, TechnicalQualityTeam__c>();
            list<TechnicalQualityTeam__c> lstTQTtoUpdate = new list<TechnicalQualityTeam__c>();

            for(TechnicalQualityTeam__c tqt: lTQT){

                sidProj.add(tqt.Projid__c);
                sidTQTM.add(tqt.TechnicalQualityTeamMember__c);
                mapTQTGroup.put(tqt.Projid__c + ' - ' + tqt.TechnicalQualityTeamMember__c + ' - ' + tqt.Role__c, tqt);
            }

            list<pse__Proj__c> lstProj;
            
            try{
                lstProj = new list<pse__Proj__c>([Select Id, pse__Stage__c from pse__Proj__c Where id IN:sidProj and pse__Stage__c = 'Execution']);
            }catch(exception e){
                lstProj = new list<pse__Proj__c>();
                ECO_Service_ErrorLog.logException(e);         
            }   

            map<string,pse__Proj__c> mapProj = new map<string,pse__Proj__c>();

            for(pse__Proj__c p:lstProj){
                string truncID = p.id;
                truncID = truncID.left(15);
                mapProj.put( truncID, p);
            }


            if(mapProj.size() > 0){


                List <TechnicalQualityTeam__c> lTeam;
                try{

                    system.debug(mapProj.keyset());
                    system.debug(sidTQTM);
                    system.debug(sRoles);
                    lTeam = new List <TechnicalQualityTeam__c> ([Select Id, Deliverable__c,  TechnicalQualityTeamMember__c, Role__c, Projid__c
                                                                                                From TechnicalQualityTeam__c 
                                                                                                Where Projid__c IN :mapProj.keyset() 
                                                                                                AND TechnicalQualityTeamMember__c IN :sidTQTM 
                                                                                                AND Role__c IN :sRoles
                                                                                                AND IsEmailSent__c = TRUE] );

                    system.debug(lTeam);
                }catch(exception e){
                    lTeam = new List <TechnicalQualityTeam__c>();
                    ECO_Service_ErrorLog.logException(e);         
                }      

                for(TechnicalQualityTeam__c tqt: lTeam){
                    ssRowCombo.add(tqt.Projid__c + ' - ' + tqt.TechnicalQualityTeamMember__c + ' - ' + tqt.Role__c );
                }

                for(TechnicalQualityTeam__c tqt: mapTQTGroup.values()){

                    if(!ssRowCombo.contains(tqt.Projid__c + ' - ' + tqt.TechnicalQualityTeamMember__c + ' - ' + tqt.Role__c) 
                        && mapProj.containskey(tqt.Projid__c)){

                        tqt.SendEmail__c = true;
                        lstTQTtoUpdate.add(tqt);
                    }
                }

                if(lstTQTtoUpdate.size() > 0 && !isTriggerNew){
                    try{
                        update lstTQTtoUpdate;
                    } catch(exception e){
                        ECO_Service_ErrorLog.logException(e);         
                    }
                }

                ECO_TechnicalQualityTeam_TriggerHandler.emailSent = true;
            }
        }

    }
    /*public static void updateTQTfield (TechnicalQualityTeam__c TQT){
        TechnicalQualityTeam__c oTQT = [Select Id, IsEmailSent__c From TechnicalQualityTeam__c Where Id = :TQT.Id];
        oTQT.IsEmailSent__c = true;
        update oTQT;
    }*/
    /*public static void handleEmailNotificationHelper (TechnicalQualityTeam__c TQT){
        Id deliverableId = TQT.Deliverable__c;
        Id projectId = TQT.Projid__c;
        pse__Proj__c project = [Select Id, pse__Stage__c From pse__Proj__c Where Id = :projectId];
        if(project.pse__Stage__c == 'Execution'){
            List <Deliverable__c> lDeliverables = new List<Deliverable__c>([Select Id from Deliverable__c Where Project__c =:projectId ]);
            List <TechnicalQualityTeam__c> lTeam = new List <TechnicalQualityTeam__c> ([Select Id 
                                                                                        From TechnicalQualityTeam__c 
                                                                                        Where Deliverable__c IN :lDeliverables 
                                                                                        AND TechnicalQualityTeamMember__c = :TQT.TechnicalQualityTeamMember__c 
                                                                                        AND Role__c = :TQT.Role__c
                                                                                        AND IsEmailSent__c = TRUE] );
            if(lTeam.size() == 0){
                Id ContactId;
                User oUser = [Select Id, ContactId, Email From User Where Id = :tqt.TechnicalQualityTeamMember__c];
                if(oUser.ContactId == null || oUser.ContactId == '')
                    ContactId =  [Select Id From Contact Where User__c <> null LIMIT 1].Id;
                else
                    ContactId = oUser.ContactId;
                List<String> lToEmail = new List<String> { oUser.Email };
                try{
                    List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                    msg.setTemplateId( [select id from EmailTemplate where DeveloperName= 'EcoNotifyTechnicalQualityTeamMemberofNewRole'].id );
                    msg.setWhatId(TQT.Id);
                    msg.setTargetObjectId(ContactId);
                    msg.setToAddresses(lToEmail);
                    msg.setSaveAsActivity(false);
                    
                    lstMsgs.add(msg);
                    
                    Savepoint sp = Database.setSavepoint();
                    try{Messaging.sendEmail(lstMsgs);}catch(EmailException e){}
                    
                    Database.rollback(sp);
                    
                    List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
                    for (Messaging.SingleEmailMessage email : lstMsgs) {
                        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                        emailToSend.setToAddresses(email.getToAddresses());
                        emailToSend.setPlainTextBody(email.getPlainTextBody());
                        emailToSend.setHTMLBody(email.getHTMLBody());
                        emailToSend.setSubject(email.getSubject());
                        lstMsgsToSend.add(emailToSend);
                    }
                    Messaging.sendEmail(lstMsgsToSend);
                    emailSent = true;
                    
                }catch (EmailException e) {
                    System.debug('EmailException:::'+e);
                }
            	
            }
        }
    }*/
    
}