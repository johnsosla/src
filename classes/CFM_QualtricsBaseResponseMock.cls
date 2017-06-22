@isTest
public with sharing class CFM_QualtricsBaseResponseMock implements HttpCalloutMock {

    public HttpResponse respond(HttpRequest req) {
        Map<String, String> params = getParams(req);

        String methodCalled = params.get(CFM_QualtricsBaseCallout.PARAM_KEY_REQUEST);
        System.assert(String.isNotBlank(methodCalled), 'Callouts must specify method to be called by Qualtrics');

        CFM_QualtricsSendSurveyToPanelCallout sendSurvey = new CFM_QualtricsSendSurveyToPanelCallout(new CFM_SurveyBatch(), '');
        CFM_QualtricsImportPanelCallout importPanel = new CFM_QualtricsImportPanelCallout(null, null);

        HttpCalloutMock handler;

        if (methodCalled == sendSurvey.getRequest()) {
            handler = new CFM_QualtricsSendSurveyResponseMock();
        }
        else if (methodCalled == importPanel.getRequest()) {
            handler = new CFM_QualtricsImportPanelResponseMock();
        }

        System.assert(handler != null, 'Unknown method called: ' + methodCalled);

        return handler.respond(req);
    }

    public static Map<String, String> getParams(HttpRequest req) {
        Map<String, String> params = new Map<String, String>();

        String url = req.getEndpoint();
        Integer startIndex = url.indexof('?');
        if (startIndex > -1) {
            String onlyParams = url.substring(startIndex + 1);
            for (String keyvalue : onlyParams.split('&')) {
                List<String> splitValues = keyvalue.split('=', 2);
                if (splitValues.size() > 1) {
                    //---there is an equals sign, assume key/value
                    params.put(splitValues[0], splitValues[1]);
                }
                else {
                    //---there is no equals sign, include in map as key anyway
                    params.put(splitValues[0], null);
                }
            }
        }

        return params;
    }
}