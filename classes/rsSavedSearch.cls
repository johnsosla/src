public with sharing class rsSavedSearch extends rsModel {

    public static Finder find = new Finder('rs_Search__c');


    public rsSavedSearch(rs_Search__c s) {
        super(s);
    }

    public class Finder extends rsFinder {

        public Finder(String sObjectName) {
            super(sObjectName);
        }

        public override rsModel byId(Id recId) {
            return new rsSavedSearch((rs_Search__c)byId(recId).getObj());
        }

    }
}