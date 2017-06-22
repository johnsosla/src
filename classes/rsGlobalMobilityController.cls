public with sharing class rsGlobalMobilityController extends rsSectionController {

    //Default available fields
    public List<SelectOption> locationRelocateCurr {get;set;}
    public List<SelectOption> locationRelocateDiff {get;set;}
    public List<SelectOption> lengthOfTimeAbroad {get; set;}
    public List<SelectOption> timeToRelocate {get; set;}
    public List<SelectOption> accompaniedStatus {get; set;}
    public List<SelectOption> countries {get; set;}
    public List<SelectOption> regions {get; set;}

    //List of countries interested/not interested available to select from
    public List<SelectOption> availableInterestCountries {get; set;}
    public List<SelectOption> availableNoInterestCountries {get; set;}
    public List<SelectOption> availableInterestRegions {get; set;}
    public List<SelectOption> availableNoInterestRegions {get; set;}

    //List of countries interested/not interested to relocate to that are selected
    private List<SelectOption> interestCountriesSel;
    private List<SelectOption> noInterestCountriesSel;
    private List<SelectOption> interestRegionsSel;
    private List<SelectOption> noInterestRegionsSel;

    public rsGlobalMobilityController() {
        super();
        //Global Mobility Setup
        sObject sObjPP = Schema.getGlobalDescribe().get('rs_Profile_Part__c').newSObject();
        sObject sObjUser = Schema.getGlobalDescribe().get('User').newSObject();
        countries = rsDataUtils.getPicklistValues(sObjPP, 'Country__c');
        locationRelocateCurr = rsDataUtils.getPicklistValues(sObjUser, 'Interest_Relocating_Current_Country__c');
        locationRelocateDiff = rsDataUtils.getPicklistValues(sObjUser, 'Interest_Relocating_Different_Country__c');
        lengthOfTimeAbroad = rsDataUtils.getPicklistValues(sObjUser, 'Length_of_Time_Abroad__c');
        timeToRelocate = rsDataUtils.getPicklistValues(sObjUser, 'rs_Time_To_Relocate__c');
        accompaniedStatus = rsDataUtils.getPicklistValues(sObjUser, 'rs_Accompanied_Status__c');
        regions = rsDataUtils.getPicklistValues(sObjUser, 'Interest_Regions__c');

    }

    public override PageReference editPart() {
        setupCountriesOptions();
        enableEditMode();
        return null;
    }

    public override PageReference cancelPart() {
        enableListMode();
        return null;
    }

    public override PageReference savePart() {
        //The countries text areas will actually be done in these setters
        setInterestCountriesSel(interestCountriesSel);
        setNoInterestCountriesSel(noInterestCountriesSel);
        setInterestRegionsSel(interestRegionsSel);
        setNoInterestRegionsSel(noInterestRegionsSel);
        profile.save();
        enableListMode();
        return null;
    }

    private void setupCountriesOptions() {
        // We are holding the countries in a text area, we'll have to parse it and make the list
        interestCountriesSel = new List<SelectOption>();
        noInterestCountriesSel = new List<SelectOption>();
        availableInterestCountries = new List<SelectOption>();
        availableNoInterestCountries = new List<SelectOption>();

        // This is for regions
        interestRegionsSel = new List<SelectOption>();
        noInterestRegionsSel = new List<SelectOption>();
        availableInterestRegions = new List<SelectOption>();
        availableNoInterestRegions = new List<SelectOption>();

        Set<String> interestedCountries = new Set<String>();
        Set<String> notInterestedCountries = new Set<String>();
        Set<String> interestedRegions = new Set<String>();
        Set<String> notInterestedRegions = new Set<String>();
        if(String.isNotBlank(profile.getInterestCountries())) interestedCountries =  new Set<String>(profile.getInterestCountries().split('; ',0));
        if(String.isNotBlank(profile.getNoInterestCountries())) notInterestedCountries = new Set<String>(profile.getNoInterestCountries().split('; ',0));
        if(String.isNotBlank(profile.getInterestRegions())) interestedRegions = new Set<String>(profile.getInterestRegions().split(';'));
        if(String.isNotBlank(profile.getNoInterestRegions())) notInterestedRegions = new Set<String>(profile.getNoInterestRegions().split(';'));

        // Booleans to check if the lists have any countries in them, we'll break out of the following loop if they don't

        Boolean interestedEmpty = interestedCountries.size() == 0;
        Boolean notInterestedCountriesEmpty = notInterestedCountries.size() == 0;

        // Boolean for regions to check if the lists have anything selected
        Boolean interestedRegionsEmpty = interestedRegions.size() == 0;
        Boolean notInterestedRegionsEmpty = notInterestedRegions.size() == 0;

        for(SelectOption op : countries) {
            String country = op.getValue();

            if(!interestedEmpty && !notInterestedCountriesEmpty) {              // Neither are empty, we'll check which ones have been selected and add to the appropriate lists
                if(interestedCountries.contains(country)) {
                    interestCountriesSel.add(new SelectOption(country,country));
                } else {
                    availableInterestCountries.add(new SelectOption(country,country));
                }
                if(notInterestedCountries.contains(country)) {
                    noInterestCountriesSel.add(new SelectOption(country,country));
                } else {
                    availableNoInterestCountries.add(new SelectOption(country,country));
                }
            } else if(!interestedEmpty && notInterestedCountriesEmpty) {        //Interested Countries Not empty, we'll just be checking/adding against those lists
                if(interestedCountries.contains(country)) {
                    interestCountriesSel.add(new SelectOption(country,country));
                } else {
                    availableInterestCountries.add(new SelectOption(country,country));
                }
                if(availableNoInterestCountries.size() == 0) {                  //We'll add all available countries to the Not Interested available list, but just once
                    availableNoInterestCountries = countries;
                }
            } else if(interestedEmpty && !notInterestedCountriesEmpty) {        //Not Interested Countries Not empty, we'll just be checking/adding against those lists
                if(notInterestedCountries.contains(country)) {
                    noInterestCountriesSel.add(new SelectOption(country,country));
                } else {
                    availableNoInterestCountries.add(new SelectOption(country,country));
                }
                if(availableInterestCountries.size() == 0) {                    //We'll add all available countries to the Interested available list, but just once
                    availableInterestCountries = countries;
                }
            } else {                                                            // Both of the lists are empty, add all available countries to them and exit loop
                availableInterestCountries = countries;
                availableNoInterestCountries = countries;
                break;
            }
        }

        for(SelectOption op : regions) {
            String region = op.getValue();
            if(!interestedRegionsEmpty && !notInterestedRegionsEmpty) {         // Neither are empty, we'll check which ones have been selected and add to the appropriate lists
                if(interestedRegions.contains(region)) {
                    interestRegionsSel.add(new SelectOption(region,region));
                } else {
                    availableInterestRegions.add(new SelectOption(region,region));
                }
                if(notInterestedRegions.contains(region)) {
                    noInterestRegionsSel.add(new SelectOption(region,region));
                } else {
                    availableNoInterestRegions.add(new SelectOption(region,region));
                }
            } else if(!interestedRegionsEmpty && notInterestedRegionsEmpty) {   //Interested Regions Not empty, we'll just be checking/adding against those lists
                if(interestedRegions.contains(region)) {
                    interestRegionsSel.add(new SelectOption(region,region));
                } else {
                    availableInterestRegions.add(new SelectOption(region,region));
                }
                if(availableNoInterestRegions.size() == 0) {                    //We'll add all available Regions to the Not Interested available list, but just once
                    availableNoInterestRegions = regions;
                }
            } else if(interestedRegionsEmpty && !notInterestedRegionsEmpty) {   //Not Interested Regions Not empty, we'll just be checking/adding against those lists
                if(notInterestedRegions.contains(region)) {
                    noInterestRegionsSel.add(new SelectOption(region,region));
                } else {
                    availableNoInterestRegions.add(new SelectOption(region,region));
                }
                if(availableInterestRegions.size() == 0) {                      //We'll add all available Regions to the Interested available list, but just once
                    availableInterestRegions = regions;
                }
            } else {                                                            // Both of the lists are empty, add all available Regions to them and exit loop
                availableInterestRegions = regions;
                availableNoInterestRegions = regions;
                break;
            }
        }
    }

    // Getters and Setters for countries

    public List<SelectOption> getInterestCountriesSel() {
        return interestCountriesSel;
    }

    public void setInterestCountriesSel(List<SelectOption> sel) {
        interestCountriesSel = sel;
        String countryString = '';
        Integer i = 0;
        for(SelectOption op : interestCountriesSel) {
            countryString += i < interestCountriesSel.size() - 1 ? op.getValue() + '; ' : op.getValue();
            i++;
        }
        profile.setInterestCountries(countryString);
    }

    public List<SelectOption> getNoInterestCountriesSel() {
        return noInterestCountriesSel;
    }

    public void setNoInterestCountriesSel(List<SelectOption> sel) {
        noInterestCountriesSel = sel;
        String countryString = '';
        Integer i = 0;
        for(SelectOption op : noInterestCountriesSel) {
            countryString += i < noInterestCountriesSel.size()-1 ? op.getValue() + '; ' : op.getValue();
            i++;
        }
        profile.setNoInterestCountries(countryString);
    }

    //  Getters and Setters for countries END

    // Getters and Setters for Regions
    public List<SelectOption> getInterestRegionsSel() {
        return interestRegionsSel;
    }

    public void setInterestRegionsSel(List<SelectOption> sel) {
        interestRegionsSel = sel;
        String regionString = '';
        Integer i = 0;
        for(SelectOption op : interestRegionsSel) {
            regionString += i < interestRegionsSel.size() - 1 ? op.getValue() + ';' : op.getValue();
            i++;
        }
        profile.setInterestRegions(regionString);
    }

    public List<SelectOption> getNoInterestRegionsSel() {
        return noInterestRegionsSel;
    }

    public void setNoInterestRegionsSel(List<SelectOption> sel) {
        noInterestRegionsSel = sel;
        String regionString = '';
        Integer i = 0;
        for(SelectOption op : noInterestRegionsSel) {
            regionString += i < noInterestRegionsSel.size() - 1 ? op.getValue() + ';' : op.getValue();
            i++;
        }
        profile.setNoInterestRegions(regionString);
    }
    //  Getters and Setters for Regions End
}