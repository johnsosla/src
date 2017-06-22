global with sharing class rsSysInfoController {

    private static rsGenerationClient mClient = new rsGenerationClient();

    global String getEndpoint() {
        return mClient.getEndpoint();
    }

    @RemoteAction
    global static String getStatus() {
        String status = 'Offline';
        try {
            status = String.valueOf(mClient.status().get('status'));
        }
        catch(Exception e) { System.debug(e); }
        return status;
    }
}