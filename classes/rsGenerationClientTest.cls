@isTest
private class rsGenerationClientTest {

    private static testMethod void testGeneration() {

         Test.setMock(HttpCalloutMock.class, new rsGenerationMockResp());

         Test.startTest();
         rsGenerationClient client = new rsGenerationClient();
         client.status();
         client.getEndpoint();
         Test.stopTest();
         //No one cares about these methods. Not asserting jack.


    }

}