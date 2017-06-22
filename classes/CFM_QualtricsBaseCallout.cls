/**
 *   API definition: https://survey.qualtrics.com/WRAPI/ControlPanel/docs.php
 *
 */
public abstract class CFM_QualtricsBaseCallout {

    public static final String STATUS_SUCCESS     = 'Success';
    public static final String ENCODING           = 'UTF-8';

    public static final String PARAM_KEY_API_SEL  = 'API_SELECT';
    public static final String PARAM_KEY_VER      = 'Version';
    public static final String PARAM_KEY_REQUEST  = 'Request';
    public static final String PARAM_KEY_USER     = 'User';
    public static final String PARAM_KEY_TOKEN    = 'Token';
    public static final String PARAM_KEY_FORMAT   = 'Format';
    public static final String PARAM_KEY_PANEL_ID = 'PanelID';

    public static final String QUALTRICS_DATE_FORMAT  = 'yyyy-MM-dd hh:mm:ss';
    public static final String QUALTRICS_TIME_ZONE    = 'US/Pacific';

    //---Do not save the log as soon as it is created, in case there are multiple callouts 
    //---Being performed in the same transaction. saveLog() will need to be manually called
    //---After all transactions
    private   Boolean                mShouldSaveLog = true;
    private   CFM_IntegrationLog     mLog;
    private   CFM_Attachment         mAttachment;
    protected Id                     mSurveyBatchId;
    protected CFM_Survey_Settings__c mSettings;

    public CFM_QualtricsBaseCallout() {
        mSettings = CFM_Survey_Settings__c.getInstance(UserInfo.getUserId());
    }

    public abstract Map<String, String> getAdditionalHeaders();
    public abstract String getHTTPMethod();
    public abstract String getRequest();
    public abstract String getVersion();

    public virtual String getPanelID() {
        return null;
    }

    public virtual String getBodyForPost() {
        return null;
    }

    public HttpResponse callout() {
        HttpRequest req = buildCallout();

        CFM_DebugUtils.log(getRequest() + ' req.getEndpoint()', req.getEndpoint());
        if (String.isNotBlank(req.getBody())) {
            CFM_DebugUtils.log(getRequest() + ' req.getBody()', req.getBody());
        }

        HTTPResponse res;
        if (Test.isRunningTest()) {
            //---Sigh.. https://success.salesforce.com/issues_view?id=a1p30000000sXtbAAE
            CFM_QualtricsBaseResponseMock mockResponse = new CFM_QualtricsBaseResponseMock();
            res = mockResponse.respond(req);
        }
        else {
            Http h = new Http();
            res = h.send(req);
        }

        CFM_DebugUtils.log(getRequest() + ' res.getBody()', res.getBody());

        addLog(req, res, getSurveyBatchId(), getRequest(), getVersion());
        
        return res;
    }

    public HttpRequest buildCallout() {
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'text/plain');
        req.setTimeout(120 * 1000);

        req.setMethod(getHTTPMethod());
        if (req.getMethod() == 'POST') {
            req.setBody(getBodyForPost());
        }

        req.setEndpoint(getURL() + getEndpoint() + getURLParameters());

        return req;
    }

    private String getURLParameters() {
        List<String> params = new List<String>();

        params.add(PARAM_KEY_API_SEL + '=' + encode(getSelectedAPI()));
        params.add(PARAM_KEY_VER     + '=' + encode(getVersion()));
        params.add(PARAM_KEY_REQUEST + '=' + encode(getRequest()));
        params.add(PARAM_KEY_USER    + '=' + encode(getUser()));
        params.add(PARAM_KEY_TOKEN   + '=' + encode(getToken()));
        params.add(PARAM_KEY_FORMAT  + '=' + encode(getFormat()));

        if (String.isNotBlank(getPanelID())) {
            params.add(PARAM_KEY_PANEL_ID + '=' + encode(getPanelID()));
        }

        Map<String, String> additionalHeaders = getAdditionalHeaders();
        for (String key : additionalHeaders.keyset()) {
            params.add(key + '=' + encode(additionalHeaders.get(key)));
        }

        return '?' + String.join(params, '&');
    }


    protected String encode(String target) {
        if (String.isBlank(target)) {
            return '';
        }
        else {
            return EncodingUtil.urlEncode(target, ENCODING);
        }
    }

    public CFM_IntegrationLog addLog(HttpRequest req, HttpResponse res, Id surveyBatchId, String methodCalled, String version) {

        String message;
        String status;
        if (res.getStatusCode() == 200) {
            message = 'Successful Callout.';
            status = CFM_IntegrationLog.STATUS_COMPLETE;
        }
        else {
            message = 'Callout Error.';
            status = CFM_IntegrationLog.STATUS_CONN_EXCEPTION;
        }
        message += ' Code: ' +  res.getStatusCode() 
                + ' Status: ' + res.getStatus();


        CFM_IntegrationLog log = new CFM_IntegrationLog(
            new CFM_Integration_Log__c(
                Endpoint__c = req.getEndpoint(),
                Method_Called__c = methodCalled,
                Result__c = message,
                Response__c = res.getBody(),
                Status__c = status,
                Survey_Batch__c = surveyBatchId,
                Version__c = version
            )
        );
        if (mShouldSaveLog) {
            log.save();
        }
        else {
            //---Save in memory until later
            mLog = log;
        }

        Blob requestBody = req.getBodyAsBlob();
        if (requestBody != null) {
            CFM_Attachment att = new CFM_Attachment();
            att.setName('Request Body.txt');
            att.setBody(requestBody);
            att.setIsPrivate(false);
            if (mShouldSaveLog) {
                att.setParentId(log.getId());
                att.save();
            }
            else {
                mAttachment = att;
            }
        }

        return log;
    }

    public Boolean getShouldSaveLog() {
        return mShouldSaveLog;
    }
    public void setShouldSaveLog(Boolean shouldSave) {
        mShouldSaveLog = shouldSave;
    }

    public void saveLog() {
        //---Don't insert twice
        if (!mShouldSaveLog && mLog != null) {
            mLog.save();
            if (mAttachment != null) {
                mAttachment.setParentId(mLog.getId());
                mAttachment.save();
            }
        }
    }

    public String getURL() {
        return mSettings.Qualtrics_URL__c;
    }

    public String getEndpoint() {
        return mSettings.Qualtrics_Endpoint__c;
    }

    public String getUser() {
        return mSettings.Qualtrics_User__c;
    }

    public String getToken() {
        return mSettings.Qualtrics_Token__c;
    }

    public String getFormat() {
        //---Do not add to custom setting, since the implementing classes are expecting JSON
        return 'JSON';
    }

    public String getSentFromEmail() {
        return mSettings.Qualtrics_Sent_From_Email__c;
    }
 
    public String getFromEmail() {
        return mSettings.Qualtrics_From_Email__c;
    }

    public String getFromName() {
        return mSettings.Qualtrics_From_Name__c;
    }

    public String getSubject() {
        return mSettings.Qualtrics_Subject__c;
    }

    public String getSelectedAPI() {
        return mSettings.Qualtrics_Selected_API__c;
    }

    public String getMessageID() {
        return mSettings.Qualtrics_Message_ID__c;
    }

    public String getMessageLibraryID() {
        return mSettings.Qualtrics_Message_Library_ID__c;
    }

    public Id getSurveyBatchId() {
        return mSurveyBatchId;
    }
    public void setSurveyBatchId(Id surveyBatchId) {
        mSurveyBatchId = surveyBatchId;
    }

    public class ResponseNotOKException extends Exception{}

}