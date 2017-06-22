public with sharing class rsResumeXmlDownloadController {

    public String xmlString { get; set; }

    public rsResumeXmlDownloadController() {

        // You may want to change this to be a comma separated list rather than a single user ID
        string userId = ApexPages.currentPage().getParameters().get('userId');
        string[] split = userId.Split(',');
        List<String> userIds = new List<String>();
        Integer i = 0;
        while (i < split.size()) {
            userIds.add(split[i]);
            i++;
        }


        String jsonString = rsResumeGenerationUtil.generateResumeJson(userIds);

        rsGenerationClient client = new rsGenerationClient();
        this.xmlString = client.getXml(jsonString);
        System.debug('##### ' + xmlString);
    }
}