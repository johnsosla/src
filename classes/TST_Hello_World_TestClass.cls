@isTest
private class TST_Hello_World_TestClass {
    static testMethod void validateHelloWorld() {
        TST_Hello_World hw = new TST_Hello_World();
        TST_Hello_World.sayYou();
        hw.sayMe();
        System.assert(true);
    }
}