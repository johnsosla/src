public class CFM_QualtricsReminderCallout extends CFM_QualtricsBaseCallout {



    private String mEmailDistributionId;

    public CFM_QualtricsReminderCallout(Id surveyBatchId, String emailDistributionId) {
        super();
        mSurveyBatchId = surveyBatchId;
        mEmailDistributionId = emailDistributionId;
    }

    public override Map<String, String> getAdditionalHeaders() {
        Map<String, String> headers = new Map<String, String>();

        headers.put('ParentEmailDistributionID', mEmailDistributionId);
        headers.put('SendDate', getSendDateFormatted());
        headers.put('FromEmail', getFromEmail());
        headers.put('FromName', getFromName());
        headers.put('Subject', getSubject());
        headers.put('MessageID', getMessageID());
        headers.put('LibraryID', getLibraryID());

        return headers;
    }

    public override String getHTTPMethod() {
        return 'GET';
    }

    public override String getRequest() {
        return 'sendReminder';
    }

    public override String getVersion() {
        return mSettings.Qualtrics_Import_Panel_Version__c;
    }

    public String getLibraryID() {
        return mSettings.Qualtrics_Library_ID__c;
    }

    public Datetime getSendDate() {
        return Datetime.now();
    }

    public String getSendDateFormatted() {
        return getSendDate().format(QUALTRICS_DATE_FORMAT, QUALTRICS_TIME_ZONE);
    }
}