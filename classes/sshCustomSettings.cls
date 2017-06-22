/*************************************************************************
* COMPONENT: Shared Services Helpdesk
* CLASS: sshCustomSettings
* PURPOSE:
* CREATED: 07/10/15 Ethos Solutions - www.ethos.com
* AUTHOR: Joe DePetro
* Update July 7 2016 - Change record type to psa resource
***************************************************************************/
public class sshCustomSettings {
    public sshCustomSettings() {}

    /**
    * @Description This method will get all the needed Custom Settings for the Case trigger functionality and
    *                 build a CaseTriggerSettings object that holds all the needed settings
    * @return CaseTriggerSettings - the CaseTriggerSettings object will have all the settings needed for the Case trigger
    */
    public static CaseTriggerSettings getCaseTriggerSettings() {
        CaseTriggerSettings settings = new CaseTriggerSettings();

        if (ssh_User_Contact_Settings__c.getInstance('Default') == null
                && Test.isRunningTest()) {
            Account acct = new Account(Name = 'Uncategorized Vendor');
            insert acct;

            Account acct2 = new Account(Name = 'AECOM Internal Account');
            acct2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account Record Type - Global').getRecordTypeId();
            insert acct2;

            //--Insert custom settings cs that the other triggers don't freak out
            ssh_User_Contact_Settings__c custSetting = new ssh_User_Contact_Settings__c();
            custSetting.Name = 'Default';
            custSetting.External_Vendor_Uncategorized_Account__c = acct.Id;
            custSetting.External_Vendor_Record_Type__c = 'Vendor';
            custSetting.Employee_Record_Type__c = 'PSA_Resource';
            custSetting.Internal_User_Account__c = acct2.Id;
            insert custSetting;
        }
        if (ssh_User_Contact_Settings__c.getInstance('Default') != null) {
            String settingName = ssh_User_Contact_Settings__c.getInstance('Default').Internal_User_Account__c;
            if (settingName != null) {
                settings.internalUserAccount = [select Id from Account where Id = :settingName];
            } else {
                System.debug('Custom Settings Error - Internal_User_Account__c not set');
            }

            settingName = ssh_User_Contact_Settings__c.getInstance('Default').External_Vendor_Uncategorized_Account__c;
            if (settingName != null) {
                List<Account> externalVendorAccounts = [select Id from Account where Id = :settingName];
                if(externalVendorAccounts.size() > 0){
                    settings.externalVendorAccount = externalVendorAccounts[0];
                }
            } else {
                System.debug('Custom Settings Error - External_Vendor_Uncategorized_Account__c not set');
            }

            settingName = ssh_User_Contact_Settings__c.getInstance('Default').Employee_Record_Type__c;
            if (settingName != null) {
                settings.internalUserContactRecordTypeId = sshUserContactUtils.getRecordTypeIdByName(settingName);
            } else {
                System.debug('Custom Settings Error - Employee_Record_Type__c not set');
            }

            settingName = ssh_User_Contact_Settings__c.getInstance('Default').External_Vendor_Record_Type__c;
            if (settingName != null) {
                settings.vendorContactRecordTypeId = sshUserContactUtils.getRecordTypeIdByName(settingName);
            } else {
                System.debug('Custom Settings Error - External_Vendor_Record_Type__c not set');
            }
        } else {
            System.debug('Custom Settings Error - SSH User Contact Settings needs to have a "Default" record.');
        }

        return settings;
    }

    /**
    * @Description Holder object for holding all the settings needed for the Case trigger
    */
    public class CaseTriggerSettings {
        public Account internalUserAccount { get; set; }
        public Account externalVendorAccount { get; set; }
        public String internalUserContactRecordTypeId { get; set; }
        public String vendorContactRecordTypeId { get; set; }

        /**
        * @Description Helper method to make sure all the Custom Settings fields have values.
        * @return Boolean - true if all the fields have values.
        */
        public Boolean validationOk() {
            return internalUserAccount != null && externalVendorAccount != null && String.isNotBlank(internalUserContactRecordTypeId) && String.isNotBlank(vendorContactRecordTypeId);
        }
    }
}