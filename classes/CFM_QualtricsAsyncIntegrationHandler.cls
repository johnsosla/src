public with sharing class CFM_QualtricsAsyncIntegrationHandler implements Queueable, Database.AllowsCallouts {
    
    private CFM_SurveyBatch mSurveyBatch;
    private String          mSurveyBatchProjectCSV;
    private Boolean         mSendReminders;

    private CFM_QualtricsImportPanelCallout       importPanelCallout;
    private CFM_QualtricsSendSurveyToPanelCallout sendSurveyToPanelCallout;
    private CFM_QualtricsReminderCallout          reminderCallout;


    public CFM_QualtricsAsyncIntegrationHandler(CFM_SurveyBatch surveyBatch, String surveyBatchProjectCSV) {
        mSurveyBatch = surveyBatch;
        mSurveyBatchProjectCSV = surveyBatchProjectCSV;
        mSendReminders = false;
    }

    public CFM_QualtricsAsyncIntegrationHandler(CFM_SurveyBatch surveyBatch, Boolean sendReminders) {
        mSurveyBatch = surveyBatch;
        mSendReminders = sendReminders;
    }

    public void execute(QueueableContext context) {
        if (mSendReminders) {
            sendRemindersToQualtrics();
        }
        else {
            sendSurveyToQualtrics();    
        }
    }

    private void sendSurveyToQualtrics() {

        CFM_QualtricsImportPanelResponse importPanelResponse;
        try {
            importPanelResponse = importPanel();
        }
        catch (CFM_QualtricsBaseCallout.ResponseNotOKException e) {
            addLog(e, importPanelCallout.getRequest());
        }

        if (importPanelResponse != null) {
            try {
                String panelId = importPanelResponse.getPanelId();
                CFM_QualtricsSendSurveyToPanelResponse sendSurveyResponse = sendSurveyToPanel(panelId);

                if (sendSurveyResponse != null && sendSurveyResponse.Result != null) {
                    mSurveyBatch.obj.Email_Distribution_ID__c = sendSurveyResponse.Result.EmailDistributionID;
                    mSurveyBatch.obj.Survey_Panel_ID__c = importPanelResponse.getPanelId();
                    mSurveyBatch.save();
                }
            } 
            catch (CFM_QualtricsBaseCallout.ResponseNotOKException e) {
                addLog(e, sendSurveyToPanelCallout.getRequest());
            }

            
        }

        //---Null checks in case callouts fail
        if (importPanelCallout != null) {
            importPanelCallout.saveLog();
        }
        if (sendSurveyToPanelCallout != null) {
            sendSurveyToPanelCallout.saveLog();
        }

    }

    private void sendRemindersToQualtrics() {
        reminderCallout = new CFM_QualtricsReminderCallout(mSurveyBatch.getId(), mSurveyBatch.obj.Email_Distribution_ID__c);
        reminderCallout.setShouldSaveLog(false);

        HttpResponse res = reminderCallout.callout();

        reminderCallout.saveLog();

        // Clone record to remove "read-only" flag in memory, and clear the "Send Reminders" checkbox so the workflow can fire again in the future
        CFM_Survey_Batch__c sb = new CFM_Survey_Batch__c(Id=mSurveyBatch.getId());
        sb.Send_Reminders__c = false;
        update sb;

        System.debug('Reminder response body: ' + res.getBody());
    }

    private CFM_QualtricsImportPanelResponse importPanel() {
        importPanelCallout = new CFM_QualtricsImportPanelCallout(mSurveyBatch.getId(), mSurveyBatchProjectCSV);
        importPanelCallout.setShouldSaveLog(false);
        HttpResponse res = importPanelCallout.callout();
        CFM_QualtricsImportPanelResponse response = CFM_QualtricsImportPanelResponse.parse(res.getBody());
        if (response.Meta.Status != CFM_QualtricsBaseCallout.STATUS_SUCCESS) {
            String details = '';
            details += CFM_QualtricsImportPanelCallout.PARAM_KEY_LIB_ID + ': ' + importPanelCallout.getLibraryID()   + ',\n ';
            details += CFM_QualtricsImportPanelCallout.PARAM_KEY_EMAIL  + ': ' + importPanelCallout.getEmailColumn() + ',\n ';
            throw new CFM_QualtricsBaseCallout.ResponseNotOKException(
                'Error recieved from callout \nResponse: ' + res.getBody() 
                + '\n-----\nDetails: ' + details 
                + '\n-----\nSent this as CSV: ' + mSurveyBatchProjectCSV
            );
        }

        return response;
    }

    private CFM_QualtricsSendSurveyToPanelResponse sendSurveyToPanel(String panelId) {
        sendSurveyToPanelCallout = new CFM_QualtricsSendSurveyToPanelCallout(mSurveyBatch, panelId);
        sendSurveyToPanelCallout.setShouldSaveLog(false);
        HttpResponse res = sendSurveyToPanelCallout.callout();
        CFM_QualtricsSendSurveyToPanelResponse response = CFM_QualtricsSendSurveyToPanelResponse.parse(res.getBody());
        if (response.Meta.Status != CFM_QualtricsBaseCallout.STATUS_SUCCESS) {
            String details = '';
            details += CFM_QualtricsSendSurveyToPanelCallout.PARAM_KEY_SURVEY       + ': ' + sendSurveyToPanelCallout.getSurveyID()         + ',\n ';
            details += CFM_QualtricsSendSurveyToPanelCallout.PARAM_KEY_SEND_DATE    + ': ' + sendSurveyToPanelCallout.getSendDate()         + ',\n ';
            details += CFM_QualtricsSendSurveyToPanelCallout.PARAM_KEY_SENT_ADDR    + ': ' + sendSurveyToPanelCallout.getSentFromEmail()    + ',\n ';
            details += CFM_QualtricsSendSurveyToPanelCallout.PARAM_KEY_FROM_EMAIL   + ': ' + sendSurveyToPanelCallout.getFromEmail()        + ',\n ';
            details += CFM_QualtricsSendSurveyToPanelCallout.PARAM_KEY_FROM_NAME    + ': ' + sendSurveyToPanelCallout.getFromName()         + ',\n ';
            details += CFM_QualtricsSendSurveyToPanelCallout.PARAM_KEY_SUBJECT      + ': ' + sendSurveyToPanelCallout.getSubject()          + ',\n ';
            details += CFM_QualtricsSendSurveyToPanelCallout.PARAM_KEY_MSG_ID       + ': ' + sendSurveyToPanelCallout.getMessageID()        + ',\n ';
            details += CFM_QualtricsSendSurveyToPanelCallout.PARAM_KEY_MSG_LIB_ID   + ': ' + sendSurveyToPanelCallout.getMessageLibraryID() + ',\n ';
            details += CFM_QualtricsSendSurveyToPanelCallout.PARAM_KEY_PANEL_LIB_ID + ': ' + sendSurveyToPanelCallout.getPanelLibraryID()  ;

            throw new CFM_QualtricsBaseCallout.ResponseNotOKException(
                'Error recieved from callout \nResponse: ' + res.getBody() 
                + '\n-----\nDetails: ' + details);
        }
        return response;
    }

    private void addLog(CFM_QualtricsBaseCallout.ResponseNotOKException e, String method) {

        CFM_IntegrationLog log = new CFM_IntegrationLog(
            new CFM_Integration_Log__c(
                Method_Called__c = method,
                Result__c = 'Successful connection but invalid result',
                Response__c = 'Cause: ' + e.getCause() 
                            + '\n-----\nStack Trace: ' + e.getStackTraceString() 
                            + '\n-----\nMessage: ' + e.getMessage(),
                Status__c = CFM_IntegrationLog.STATUS_PROC_EXCEPTION,
                Survey_Batch__c = mSurveyBatch.getId()
            )
        );
        log.save();
    }

    public String getSurveyBatchProjectCSV() {
        return mSurveyBatchProjectCSV;
    }
    public void setSurveyBatchProjectCSV(String surveyBatchProjectCSV) {
        mSurveyBatchProjectCSV = surveyBatchProjectCSV;
    }

}