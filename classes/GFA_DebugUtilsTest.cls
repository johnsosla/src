@isTest
public class GFA_DebugUtilsTest {

    @isTest static void testDebugMethods() {
        GFA_DebugUtils.setDebugMode(true);
        System.assert(GFA_DebugUtils.getDebugMode());
        GFA_DebugUtils.log('Test');
        GFA_DebugUtils.log('TEST', 'TEST123');
        GFA_DebugUtils.log();
        GFA_DebugUtils.startMethod('debugMethod');
        GFA_DebugUtils.stopMethod('debugMethod');
        GFA_DebugUtils.startMethod('debugMethod');

        Boolean logSingle = false;
        Boolean logDouble = false;

        for (ApexPages.Message msg : ApexPages.getMessages()) {
            if (msg.getDetail().contains('Test')) {
                logSingle = true;
            }
            if (msg.getDetail().contains('TEST123')) {
                logDouble = true;
            }
        }

        System.assert(logSingle && logDouble);
    }

}