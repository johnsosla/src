public with sharing class ECO_DTO_VendorSite {
    public VendorSite__c vendorSite {get; set;}
    public Boolean selected {get; set;}
    
    public ECO_DTO_VendorSite(VendorSite__c vendorSite) {
        this.vendorSite = vendorSite;
    }
}