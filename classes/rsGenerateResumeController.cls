public with sharing class rsGenerateResumeController {

    private String mTemplateName;
    private String mDownloadLink;
    private Boolean mShowDownloadLink;
    public List<String> UserIds {get; set;}

    public rsGenerateResumeController() {
        mShowDownloadLink = false;
    }

    public PageReference clearDownload() {
        mShowDownloadLink = false;
        return null;
    }

    public PageReference generateResume() {
        if (mTemplateName == 'xml_output') {
            return null;
        } else {
            rsGenerationClient client = new rsGenerationClient();
            try {
                mDownloadLink = client.generate(rsResumeGenerationUtil.generateResumeJson(UserIds), mTemplateName);
                if (mDownloadLink == null) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Generate_Resume_Error + ':' + client.getError()));
                    return null;
                }

            } catch (System.CalloutException ex) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Generate_Resume_Timeout));
                return null;
            }
            mShowDownloadLink = true;
            return null;
        }


    }

    public void setShowDownloadLink(Boolean val) {
        mShowDownloadLink = true;
    }

    public Boolean getShowDownloadLink() {
        return mShowDownloadLink;
    }

    public void setTemplateName(String value) {
        mTemplateName = value;
    }

    public String getTemplateName() {
        return mTemplateName;
    }

    public String getDownloadLink() {
        return mDownloadLink;
    }

    public Boolean getIsXMLDownload() {
        return mTemplateName == rsGenerationClient.XML_OUTPUT;
    }

    public String getXMLDownloadLink() {
        if (UserIds != null) {
            PageReference pg = new PageReference('/apex/rsResumeXmlDownload');
            String outputString = String.join(UserIds, ',');
            pg.getParameters().put('userId', outputString);
            return pg.getUrl();
        } else {
            return null;
        }
    }
}