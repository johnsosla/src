public class HRS_ContactHandler {

    public static Set<Id> hrsRTInfo = new Set<Id>();

    /*   Method to validate if the contact record type is HR only
    *    @param RecordtypeId : Id
    *    return: if HR contact record type true, otherwise false
    */ 
    public static Boolean checkifHRContact (  Id recordtypeId  ){

        //assume the contact is not a HR contact
        Boolean isHRContact = false;

        if ( hrsRTInfo.size() == 0 ){
            List<RecordType> rtContactList =  [ SELECT Id FROM RecordType where sobjectType = 'Contact' and ( DeveloperName = 'PSA_Resource' or DeveloperName = 'HR_Pre_Hire') ];
            hrsRTInfo = ( new Map<Id, RecordType>( rtContactList ) ).keySet();
        }

        if ( hrsRTInfo.contains( recordtypeId ) )
            isHRContact = true;

        return isHRContact;
    }

    /*   Method to assign entitlement when new contact is created
    *    @param List : contact list
    *    return: none
    */
    public static void assignEntitlementContact ( List<Contact> contactList ){

        List<Contact> contactEntitlemntList = new List<Contact>();
        Map<String, String> countryRegionMap = new Map<String, String>();
        List<HRS_Contact_Entitlement__mdt> countryRegionList = new List<HRS_Contact_Entitlement__mdt>();
        Map<String, Id> regionEntitlementIdMap = new Map<String, Id>();
        List<EntitlementContact> newEntitlementContact = new List<EntitlementContact>();

        for ( HRS_Contact_Entitlement__mdt a : [ select Id, Country__c, Entitlement__c from HRS_Contact_Entitlement__mdt ]){
            if ( a.Country__c != null && a.Entitlement__c != null )
                countryRegionMap.put( a.Country__c, a.Entitlement__c );
        }

        for ( Entitlement e : [ select Id, Name from Entitlement where status = 'Active'] ){
            if ( e.Name != null )
                regionEntitlementIdMap.put( e.Name, e.Id );
        }

        for ( Contact c : contactList ){
            if ( checkifHRContact ( c.RecordTypeId ) ){ 
                contactEntitlemntList.add( c );
            }
        }

        for ( Contact c : contactEntitlemntList ){
        System.debug(c.MailingCountry);    
       // System.debug(countryRegionMap.get( c.MailingCountry ));
       // System.debug(regionEntitlementIdMap.get( countryRegionMap.get( c.MailingCountry ) ));
        
            if ( c.MailingCountry != null && countryRegionMap.get( c.MailingCountry ) != null
                 && regionEntitlementIdMap.get( countryRegionMap.get( c.MailingCountry ) ) != null ){
                EntitlementContact ec = new EntitlementContact();
                ec.ContactId = c.Id;
                ec.EntitlementId =  regionEntitlementIdMap.get( countryRegionMap.get( c.MailingCountry ) );
                newEntitlementContact.add( ec );
            }

        }

        if ( newEntitlementContact.size() > 0 )
            insert newEntitlementContact;
            

    }
    
    //Check if there are any duplicate contacts.
    //This code has been added to address the duplicate contact issue.
    public static void checkForDuplicateContacts( List<Contact> contactList ){
        Set<String> trackingIDSet = new Set<String>();
        Set<String> trackingIDNumberSet = new Set<String>();
        
        String trackingID;
        for (Contact con : contactList) {
            if (!String.isBlank(con.OracleContactID__c)) {
                trackingID = con.OracleContactID__c.replace('Employee-', '');
                trackingIDSet.add('%' + trackingID + '%');
            }
            if (!String.isBlank(con.TrackingID__c)) {
                trackingIDNumberSet.add('%' + con.TrackingID__c + '%');
            }
        }

        List<Contact> duplicateContacts = [SELECT Id, OracleContactID__c, TrackingID__c FROM Contact 
                                           WHERE OracleContactID__c LIKE :trackingIDSet OR OracleContactID__c LIKE :trackingIDNumberSet 
                                           OR TrackingID__c LIKE :trackingIDSet OR TrackingID__c LIKE :trackingIDNumberSet LIMIT 1000];
        
        for (Contact con : contactList) {
            if (!String.isBlank(con.OracleContactID__c)) {
                trackingID = con.OracleContactID__c.replace('Employee-', '');
            } else {
                trackingID = '';
            }
            
            for (Contact dupCon : duplicateContacts) {
                String dupTrackingID = '';
                if (!String.isBlank(dupCon.OracleContactID__c)) {
                    dupTrackingID = dupCon.OracleContactID__c.replace('Employee-', '');
                } else {
                    dupTrackingID = '';
                }                
                if ((((!String.isBlank(trackingID) && ((!String.isBlank(dupTrackingID) && trackingID == dupTrackingID) || (!String.isBlank(dupcon.TrackingID__c) && trackingID == dupcon.TrackingID__c)))) ||
                    ((!String.isBlank(con.TrackingID__c) && ((!String.isBlank(dupTrackingID) && con.TrackingID__c == dupTrackingID) || (!String.isBlank(dupcon.TrackingID__c) && con.TrackingID__c == dupcon.TrackingID__c))))) &&
                    !(con.Id != null && con.Id == dupCon.Id) ) {
                    con.addError('There is already another contact with same Tracking ID, this contact cannot be inserted/updated.');
                    break;
                }
            }
        }
    }    
}