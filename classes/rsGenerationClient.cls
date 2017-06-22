/*************************************************************************
*
* PURPOSE: WS Client for res generation
*
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Jason Swenski
***************************************************************************/
public with sharing class rsGenerationClient {

    public static final String AECOM_FORMAT = 'aecom_format';
    public static final String AECOM_330 = 'aecom_330';
    public static final String AECOM_PLAIN = 'aecom_plain';
    public static final String XML_OUTPUT = 'xml_output';

    private static final Integer MAX_POLL = 5;

    private String mBaseUrl;
    private String mDebug;
    private String mError;
    private Boolean mAsync;

    public rsGenerationClient() {
        mBaseUrl = Profile_Info__c.getInstance().Heroku_Endpoint__c;
        mAsync = false;
        if(mBaseUrl == null) mBaseUrl = 'http://aecom-resume-ws-dev.herokuapp.com';
        Boolean debug = Profile_Info__c.getInstance().Generation_Debugging__c;
        mDebug = debug ? '1' : '0';
    }

    public String getXml(String jsonStr) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(mBaseUrl + '/convertJsonToXml');
        req.setMethod('POST');
        req.setBody(jsonStr);
        req.setHeader('Content-Type', 'application/json; charset=utf-8');

        Http http = new Http();
        HttpResponse res = new HttpResponse();
        res = http.send(req);

        String xml = res.getBody();
        return xml;
    }
    public String getEndpoint() {
        return mBaseUrl;
    }

    public Boolean getAsync() {
        return mAsync;
    }

    public void setAsync(Boolean value) {
        mAsync = value;
    }

    public String getError() {
        return mError;
    }

    public Map<String,Object> status() {

        HttpRequest req = new HttpRequest();

        req.setEndpoint(mBaseUrl);
        req.setMethod('GET');
        //these parts of the POST you may want to customize
        req.setCompressed(false);
        req.setTimeout(30000);
        //req.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HttpResponse res = new HttpResponse();
        res = http.send(req);

        return (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
    }

    public String generate(String jsonStr, String templateName) {
        HttpRequest req = new HttpRequest();
        //point 5 on AECR-861
        req.setEndpoint(mBaseUrl+'/merge?debug='+mDebug+'&templateName='+ templateName
                                     + '&uid=' + UserInfo.getUserId()
                                     + '&oid=' + UserInfo.getOrganizationId()
                                     + '&oname=' + UserInfo.getOrganizationName()
                                     + '&async=' + (mAsync ? '1' : '0'));

        req.setMethod('POST');
        req.setCompressed(false);

        req.setTimeout(30000);
        req.setBody(jsonStr);
        req.setHeader('Content-Type', 'application/json; charset=utf-8');

        Http http = new Http();
        HttpResponse res = new HttpResponse();
        res = http.send(req);


         //aw shit.
        if(res.getStatusCode() != 200) {
            mError = res.getBody();
            return null;
        }

        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        String key = String.valueOf(responseMap.get('key'));
        String resId = null;

        //incase the result is cached
        if(responseMap.containsKey('resumeId')) mAsync = false;

        if(mAsync) {
            //poll the endpoint
            for(Integer i = 0; i < MAX_POLL; i++) {

                req = new HttpRequest();
                req.setEndpoint(mBaseUrl+'/poll?key=' + key + '&duration=20000');
                req.setMethod('GET');
                req.setCompressed(false);
                req.setTimeout(30000);
                req.setHeader('Content-Type', 'application/json; charset=utf-8');

                http = new Http();
                res = new HttpResponse();
                res = http.send(req);

                responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

                if(responseMap.containsKey('resumeId')) {
                    resId = String.valueOf(responseMap.get('resumeId'));
                    break;
                }


            }

        }
        else {
            resId = String.valueOf(responseMap.get('resumeId'));
        }

        return mBaseUrl+'/download?resumeId='+resid + '&key=' + key;
    }
}