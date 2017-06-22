/**
 *   API definition: https://survey.qualtrics.com/WRAPI/ControlPanel/docs.php
 *
 */
public with sharing class CFM_QualtricsSendSurveyToPanelCallout extends CFM_QualtricsBaseCallout {

    public static final Integer EXP_DATE_WEEKS_AHEAD  = 3;
    public static final Integer EXP_DATE_DAYS_AHEAD  = 27;

    public static final String PARAM_KEY_SURVEY       = 'SurveyID';
    public static final String PARAM_KEY_SEND_DATE    = 'SendDate';
    public static final String PARAM_KEY_SENT_ADDR    = 'SentFromAddress';
    public static final String PARAM_KEY_FROM_EMAIL   = 'FromEmail';
    public static final String PARAM_KEY_FROM_NAME    = 'FromName';
    public static final String PARAM_KEY_SUBJECT      = 'Subject';
    public static final String PARAM_KEY_MSG_ID       = 'MessageID';
    public static final String PARAM_KEY_MSG_LIB_ID   = 'MessageLibraryID';
    public static final String PARAM_KEY_PANEL_LIB_ID = 'PanelLibraryID';
    public static final String PARAM_KEY_EXP_DATE     = 'ExpirationDate';

    private String          mPanelId;
    private CFM_SurveyBatch mSurveyBatch;

    public CFM_QualtricsSendSurveyToPanelCallout(CFM_SurveyBatch surveyBatch, String panelId) {
        super();
        mSurveyBatch = surveyBatch;
        mPanelId = panelId;
        setSurveyBatchId(mSurveyBatch.getId());
    }

    public override Map<String, String> getAdditionalHeaders() {
        Map<String, String> headers = new Map<String, String>();
        headers.put(PARAM_KEY_SURVEY,       getSurveyID());
        headers.put(PARAM_KEY_SEND_DATE,    getSendDateFormatted());
        headers.put(PARAM_KEY_SENT_ADDR,    getSentFromEmail());
        headers.put(PARAM_KEY_FROM_EMAIL,   getFromEmail());
        headers.put(PARAM_KEY_FROM_NAME,    getFromName());
        headers.put(PARAM_KEY_SUBJECT,      getSubject());
        headers.put(PARAM_KEY_MSG_ID,       getMessageID());
        headers.put(PARAM_KEY_MSG_LIB_ID,   getMessageLibraryID());
        headers.put(PARAM_KEY_PANEL_LIB_ID, getPanelLibraryID());
        
        // Putting expiration date back in, per I-1794
        headers.put(PARAM_KEY_EXP_DATE,     getExpirationDateFormatted());
        
        return headers;
    }

    public override String getHTTPMethod() {
        return 'GET';
    }

    public override String getRequest() {
        return 'sendSurveyToPanel';
    }

    public override String getVersion() {
        return mSettings.Qualtrics_Send_Survey_Version__c;
    }

    public override String getPanelID() {
        return mPanelId;
    }
    public void setPanelID(String panelId) {
        mPanelId = panelId;
    }

    public String getSurveyID() {
        return mSettings.Qualtrics_Survey_ID__c;
    }

    public Datetime getSendDate() {
        return Datetime.now();
    }

    public String getSendDateFormatted() {
        return getSendDate().format(QUALTRICS_DATE_FORMAT, QUALTRICS_TIME_ZONE);
    }

    public Datetime getExpirationDate() {
        // 6:59AM GMT the day after, is 11:59PM Pacific on the 21st day
        DateTime expirationDate = getSendDate().addDays(EXP_DATE_DAYS_AHEAD).addDays(1);
        expirationDate = DateTime.newInstanceGmt(expirationDate.year(), expirationDate.month(), expirationDate.day(), 6, 59, 0); 
        return expirationDate;
    }

    public String getExpirationDateFormatted() {
        return getExpirationDate().format(QUALTRICS_DATE_FORMAT, QUALTRICS_TIME_ZONE);
    }


    public String getPanelLibraryID() {
        return mSettings.Qualtrics_Panel_Library_ID__c;
    }
}