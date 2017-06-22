global with sharing class rsSearch extends rsModel implements Comparable {

    public static Finder find = new Finder('rs_Search__c');

    private List<Condition> mConditions; //rs_Profile_part__c
    private String mSearchType; // Basic/Advanced
    private Map<String,Condition> mUserConditions; //User conditions
    private List<Condition> mPRTeamEmpConditions;

    private List<String> mResultFields; //String of selection on the left
    private List<SelectOption> mResultFieldsOptions; //Picklist on the left
    private List<String> mSelectedFields; //String of selection on the right
    private List<SelectOption> mSelectedFieldOptions; //Picklist on the right
    private List<SelectOption> mAdvancedFieldOptions; //picklist of available field options

    //private String mAdditionalLanguage;
    private String mLicenseRegCountry;
    private String mLicenseReg;
     private String mCertifiedPm;
    private String mTextSearch; //Search String
    private String mFilter; // Filter Logic String

    public rsSearch() {
        super(new rs_Search__c());
        mConditions = new List<Condition>();
        mUserConditions = setUpUserConditionMap();
        mPRTeamEmpConditions = new List<Condition>();
        //mAdditionalLanguage = 'EN';
        mLicenseRegCountry = '';
        mLicenseReg = '';
        mSearchType = BASIC_SEARCH;
        getResultFieldOptions();
        sortSelectedFieldsSpecific();
    }

    //public String getAdditionalLanguage() {
    //  return mAdditionalLanguage;
    //}

    //public void setAdditionalLanguage(String value) {
    //  mAdditionalLanguage = value;
    //}

    public Id getOwnerId() {
        return (Id)mObj.get('OwnerId');
    }
    public void setOwnerId(Id OwnerId) {
        mObj.put('OwnerId', OwnerId);
    }


    public String getLastName() {
        return (String)mUserConditions.get('lastName').value.replaceAll('%','');
    }

    public void setLastName(String lstName) {
        String name = String.isNotBlank(lstName) ? lstName+'%' : lstName;
        String operator = ' LIKE ';
        String field = 'LastName';
        mUserConditions.put('lastName',new Condition(name,operator,field));
    }

    public String getFirstName() {
        return (String)mUserConditions.get('firstName').value.replaceAll('%','');
    }

    public void setFirstName(String frstName) {
        String name = String.isNotBlank(frstName) ? frstName+'%' : frstName;
        String operator = ' LIKE ';
        String field = 'FirstName';
        mUserConditions.put('firstName',new Condition(name,operator,field));
    }

    public String getLicenseRegistrationCountry() {
        return mLicenseRegCountry;
    }

    public void setLicenseRegistrationCountry(String country) {
        mLicenseRegCountry = country;
    }

    public String getCertifiedPm() {
        return mCertifiedPm;
    }

    public void setCertifiedPm(String val) {
        mCertifiedPm = val;
    }

    public String getLicenseRegistration() {
        return mLicenseReg;
    }

    public void setLicenseRegistration(String licReg) {
        mLicenseReg = licReg;
    }

    public List<SelectOption> getCertifiedPmList() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('','--None--'));
        result.add(new SelectOption('Yes','Yes'));
        result.add(new SelectOption('No','No'));
        result.add(new SelectOption('Provisional','Provisional'));
        return result;
    }

    public List<SelectOption> getLicenseRegistrationList() {
        List<SelectOption> licReg = new List<SelectOption>();
        licReg.add(new SelectOption('','--None--'));
        licReg.add(new SelectOption('Agrologist in Training','Agrologist in Training'));
        licReg.add(new SelectOption('Air Monitoring  Technician','Air Monitoring  Technician'));
        licReg.add(new SelectOption('Applied Science Technologist','Applied Science Technologist'));
        licReg.add(new SelectOption('Approved Consulting Forester','Approved Consulting Forester'));
        licReg.add(new SelectOption('Articling Agrologist','Articling Agrologist'));
        licReg.add(new SelectOption('Associate Value Specialist','Associate Value Specialist'));
        licReg.add(new SelectOption('Association of Architectural Technologist of Ontario','Association of Architectural Technologist of Ontario'));
        licReg.add(new SelectOption('Biologist in Training','Biologist in Training'));
        licReg.add(new SelectOption('Board Certified Environmental Engineer','Board Certified Environmental Engineer'));
        licReg.add(new SelectOption('Board Certified Environmental Engineering Member','Board Certified Environmental Engineering Member'));
        licReg.add(new SelectOption('Canadian Registered Safety Professional','Canadian Registered Safety Professional'));
        licReg.add(new SelectOption('Certified Arborist','Certified Arborist'));
        licReg.add(new SelectOption('Certified Associate in Project Management','Certified Associate in Project Management'));
        licReg.add(new SelectOption('Certified Building Contractor','Certified Building Contractor'));
        licReg.add(new SelectOption('Certified Construction Contract Administrator','Certified Construction Contract Administrator'));
        licReg.add(new SelectOption('Certified Construction Manager ','Certified Construction Manager '));
        licReg.add(new SelectOption('Certified Consulting Meteorologist','Certified Consulting Meteorologist'));
        licReg.add(new SelectOption('Certified Cost Professional','Certified Cost Professional'));
        licReg.add(new SelectOption('Certified Ecologist','Certified Ecologist'));
        licReg.add(new SelectOption('Certified Emergency Manager ','Certified Emergency Manager '));
        licReg.add(new SelectOption('Certified Energy Manager','Certified Energy Manager'));
        licReg.add(new SelectOption('Certified Engineering Geologist','Certified Engineering Geologist'));
        licReg.add(new SelectOption('Certified Engineering Technician','Certified Engineering Technician'));
        licReg.add(new SelectOption('Certified Engineering Technologist','Certified Engineering Technologist'));
        licReg.add(new SelectOption('Certified Environmental Analytical Chemist ','Certified Environmental Analytical Chemist '));
        licReg.add(new SelectOption('Certified Environmental Engineer ','Certified Environmental Engineer '));
        licReg.add(new SelectOption('Certified Environmental Manager','Certified Environmental Manager'));
        licReg.add(new SelectOption('Certified Environmental Practitioner in Training','Certified Environmental Practitioner in Training'));
        licReg.add(new SelectOption('Certified Floodplain Manager','Certified Floodplain Manager'));
        licReg.add(new SelectOption('Certified GIS Professional','Certified GIS Professional'));
        licReg.add(new SelectOption('Certified Hazardous Materials Manager','Certified Hazardous Materials Manager'));
        licReg.add(new SelectOption('Certified Hydrogeologist','Certified Hydrogeologist'));
        licReg.add(new SelectOption('Certified Industrial Hygienist','Certified Industrial Hygienist'));
        licReg.add(new SelectOption('Certified Interior Designer','Certified Interior Designer'));
        licReg.add(new SelectOption('Certified Planner','Certified Planner'));
        licReg.add(new SelectOption('Certified Planning Technician','Certified Planning Technician'));
        licReg.add(new SelectOption('Certified Professional Environmental Auditor','Certified Professional Environmental Auditor'));
        licReg.add(new SelectOption('Certified Professional Geologist','Certified Professional Geologist'));
        licReg.add(new SelectOption('Certified Professional in Erosion and Sediment Control','Certified Professional in Erosion and Sediment Control'));
        licReg.add(new SelectOption('Certified Professional Services Marketer','Certified Professional Services Marketer'));
        licReg.add(new SelectOption('Certified Safety Professional','Certified Safety Professional'));
        licReg.add(new SelectOption('Certified Technician','Certified Technician'));
        licReg.add(new SelectOption('Certified Technology Specialist, Design','Certified Technology Specialist, Design'));
        licReg.add(new SelectOption('Certified Technology Specialist, General','Certified Technology Specialist, General'));
        licReg.add(new SelectOption('Certified Technology Specialist, Installation','Certified Technology Specialist, Installation'));
        licReg.add(new SelectOption('Certified Value Specialist','Certified Value Specialist'));
        licReg.add(new SelectOption('Certified Wetland Delineator','Certified Wetland Delineator'));
        licReg.add(new SelectOption('Chartered Biologist','Chartered Biologist'));
        licReg.add(new SelectOption('Chartered Chemist','Chartered Chemist'));
        licReg.add(new SelectOption('Chartered Engineer','Chartered Engineer'));
        licReg.add(new SelectOption('Chartered Environmentalist, Society for the Environment, UK','Chartered Environmentalist, Society for the Environment, UK'));
        licReg.add(new SelectOption('Chartered Scientist','Chartered Scientist'));
        licReg.add(new SelectOption('Chartered Surveyor','Chartered Surveyor'));
        licReg.add(new SelectOption('Chartered Water & Environment Manager','Chartered Water & Environment Manager'));
        licReg.add(new SelectOption('Data Center Design Consultant','Data Center Design Consultant'));
        licReg.add(new SelectOption('Designated Consulting Engineer','Designated Consulting Engineer'));
        licReg.add(new SelectOption('Designer of Engineering Systems','Designer of Engineering Systems'));
        licReg.add(new SelectOption('Diplomate of the American Board of Toxicology','Diplomate of the American Board of Toxicology'));
        licReg.add(new SelectOption('Electrical Contractor','Electrical Contractor'));
        licReg.add(new SelectOption('Electronic Safety and Security Designer','Electronic Safety and Security Designer'));
        licReg.add(new SelectOption('Engineer in Training','Engineer in Training'));
        licReg.add(new SelectOption('Engineering Intern','Engineering Intern'));
        licReg.add(new SelectOption('ENV Sustainability Professional','ENV Sustainability Professional'));
        licReg.add(new SelectOption('European Engineer','European Engineer'));
        licReg.add(new SelectOption('FCC General Radiotelephone Operator License','FCC General Radiotelephone Operator License'));
        licReg.add(new SelectOption('Foreign Licensee (Engineering) ','Foreign Licensee (Engineering) '));
        licReg.add(new SelectOption('Geologist in Training','Geologist in Training'));
        licReg.add(new SelectOption('Geoscientist in Training','Geoscientist in Training'));
        licReg.add(new SelectOption('Green Globes Professional','Green Globes Professional'));
        licReg.add(new SelectOption('Incorporated Engineer','Incorporated Engineer'));
        licReg.add(new SelectOption('Interior Designer','Interior Designer'));
        licReg.add(new SelectOption('Intern Architect','Intern Architect'));
        licReg.add(new SelectOption('Landscape Architect','Landscape Architect'));
        licReg.add(new SelectOption('LEED Accredited Professional','LEED Accredited Professional'));
        licReg.add(new SelectOption('LEED AP Building Design + Construction (BD+C)','LEED AP Building Design + Construction (BD+C)'));
        licReg.add(new SelectOption('LEED Green Associate','LEED Green Associate'));
        licReg.add(new SelectOption('Licensed Asbestos Building Inspector','Licensed Asbestos Building Inspector'));
        licReg.add(new SelectOption('Licensed Attorney ','Licensed Attorney '));
        licReg.add(new SelectOption('Licensed Construction Supervisor','Licensed Construction Supervisor'));
        licReg.add(new SelectOption('Licensed Contractor','Licensed Contractor'));
        licReg.add(new SelectOption('Licensed Designer','Licensed Designer'));
        licReg.add(new SelectOption('Licensed Environmental Professional','Licensed Environmental Professional'));
        licReg.add(new SelectOption('Licensed Lead Risk Assessor','Licensed Lead Risk Assessor'));
        licReg.add(new SelectOption('Licensed Remediation Specialist','Licensed Remediation Specialist'));
        licReg.add(new SelectOption('Licensed Site Professional','Licensed Site Professional'));
        licReg.add(new SelectOption('Licensed Site Remediation Professional','Licensed Site Remediation Professional'));
        licReg.add(new SelectOption('Licensed Surveyor','Licensed Surveyor'));
        licReg.add(new SelectOption('Licensed Technologist, Ontario Association of Architects','Licensed Technologist, Ontario Association of Architects'));
        licReg.add(new SelectOption('Licensed Tree Expert','Licensed Tree Expert'));
        licReg.add(new SelectOption('Limited Licence Engineer','Limited Licence Engineer'));
        licReg.add(new SelectOption('Maryland Department of the Environment Green Card','Maryland Department of the Environment Green Card'));
        licReg.add(new SelectOption('Maryland Department of the Environment Yellow Card','Maryland Department of the Environment Yellow Card'));
        licReg.add(new SelectOption('NCARB Certificate','NCARB Certificate'));
        licReg.add(new SelectOption('NCEES Certificate','NCEES Certificate'));
        licReg.add(new SelectOption('NCIDQ Certificate','NCIDQ Certificate'));
        licReg.add(new SelectOption('Network Technology Systems Designer','Network Technology Systems Designer'));
        licReg.add(new SelectOption('Notary Public','Notary Public'));
        licReg.add(new SelectOption('Ordre des ingénieurs du Québec','Ordre des ingénieurs du Québec'));
        licReg.add(new SelectOption('Outside Plant Designer','Outside Plant Designer'));
        licReg.add(new SelectOption('Permission to Consult','Permission to Consult'));
        licReg.add(new SelectOption('Planning and Scheduling Professional','Planning and Scheduling Professional'));
        licReg.add(new SelectOption('Professional Agrologist','Professional Agrologist'));
        licReg.add(new SelectOption('Professional Biologist','Professional Biologist'));
        licReg.add(new SelectOption('Professional Chemist ','Professional Chemist '));
        licReg.add(new SelectOption('Professional Engineer','Professional Engineer'));
        licReg.add(new SelectOption('Professional Engineer (Agricultural)','Professional Engineer (Agricultural)'));
        licReg.add(new SelectOption('Professional Engineer (Chemical)','Professional Engineer (Chemical)'));
        licReg.add(new SelectOption('Professional Engineer (Civil)','Professional Engineer (Civil)'));
        licReg.add(new SelectOption('Professional Engineer (Civil/Environmental)','Professional Engineer (Civil/Environmental)'));
        licReg.add(new SelectOption('Professional Engineer (Civil/Structural)','Professional Engineer (Civil/Structural)'));
        licReg.add(new SelectOption('Professional Engineer (Control Systems)','Professional Engineer (Control Systems)'));
        licReg.add(new SelectOption('Professional Engineer (Electrical)','Professional Engineer (Electrical)'));
        licReg.add(new SelectOption('Professional Engineer (Environmental)','Professional Engineer (Environmental)'));
        licReg.add(new SelectOption('Professional Engineer (Fire Protection)','Professional Engineer (Fire Protection)'));
        licReg.add(new SelectOption('Professional Engineer (Geotechnical)','Professional Engineer (Geotechnical)'));
        licReg.add(new SelectOption('Professional Engineer (Industrial)','Professional Engineer (Industrial)'));
        licReg.add(new SelectOption('Professional Engineer (Mechanical)','Professional Engineer (Mechanical)'));
        licReg.add(new SelectOption('Professional Engineer (Mechanical-Electrical)','Professional Engineer (Mechanical-Electrical)'));
        licReg.add(new SelectOption('Professional Engineer (Petroleum)','Professional Engineer (Petroleum)'));
        licReg.add(new SelectOption('Professional Engineer (Sanitary)','Professional Engineer (Sanitary)'));
        licReg.add(new SelectOption('Professional Engineer (Structural)','Professional Engineer (Structural)'));
        licReg.add(new SelectOption('Professional Engineer (Traffic)','Professional Engineer (Traffic)'));
        licReg.add(new SelectOption('Professional Environmental Scientist','Professional Environmental Scientist'));
        licReg.add(new SelectOption('Professional Geologist','Professional Geologist'));
        licReg.add(new SelectOption('Professional Geophysicist','Professional Geophysicist'));
        licReg.add(new SelectOption('Professional Geoscientist','Professional Geoscientist'));
        licReg.add(new SelectOption('Professional Hydrogeologist','Professional Hydrogeologist'));
        licReg.add(new SelectOption('Professional Hydrologist','Professional Hydrologist'));
        licReg.add(new SelectOption('Professional Land Surveyor','Professional Land Surveyor'));
        licReg.add(new SelectOption('Professional Licensee (Engineering)','Professional Licensee (Engineering)'));
        licReg.add(new SelectOption('Professional Licensee (Geoscience)','Professional Licensee (Geoscience)'));
        licReg.add(new SelectOption('Professional Planner','Professional Planner'));
        licReg.add(new SelectOption('Professional Soil Scientist','Professional Soil Scientist'));
        licReg.add(new SelectOption('Professional Traffic Operations Engineer™','Professional Traffic Operations Engineer™'));
        licReg.add(new SelectOption('Professional Transportation Planner','Professional Transportation Planner'));
        licReg.add(new SelectOption('Professional Wetland Scientist','Professional Wetland Scientist'));
        licReg.add(new SelectOption('Program Management Professional','Program Management Professional'));
        licReg.add(new SelectOption('Project Management Professional ','Project Management Professional '));
        licReg.add(new SelectOption('Provisional Licensee (Engineering)','Provisional Licensee (Engineering)'));
        licReg.add(new SelectOption('Qualified Environmental Professional','Qualified Environmental Professional'));
        licReg.add(new SelectOption('Real Estate Broker','Real Estate Broker'));
        licReg.add(new SelectOption('Registered Architect','Registered Architect'));
        licReg.add(new SelectOption('Registered Biology Technologist','Registered Biology Technologist'));
        licReg.add(new SelectOption('Registered Communications Distribution Designer ','Registered Communications Distribution Designer '));
        licReg.add(new SelectOption('Registered Communications Distribution Designer','Registered Communications Distribution Designer'));
        licReg.add(new SelectOption('Registered Community Planner','Registered Community Planner'));
        licReg.add(new SelectOption('Registered Engineering Technician','Registered Engineering Technician'));
        licReg.add(new SelectOption('Registered Engineering Technologist','Registered Engineering Technologist'));
        licReg.add(new SelectOption('Registered Environmental Manager','Registered Environmental Manager'));
        licReg.add(new SelectOption('Registered Environmental Professional','Registered Environmental Professional'));
        licReg.add(new SelectOption('Registered Environmental Property Assessor','Registered Environmental Property Assessor'));
        licReg.add(new SelectOption('Registered Groundwater Professional','Registered Groundwater Professional'));
        licReg.add(new SelectOption('Registered Information Technology Professional','Registered Information Technology Professional'));
        licReg.add(new SelectOption('Registered Land Court Surveyor','Registered Land Court Surveyor'));
        licReg.add(new SelectOption('Registered Land Surveyor','Registered Land Surveyor'));
        licReg.add(new SelectOption('Registered Landscape Architect','Registered Landscape Architect'));
        licReg.add(new SelectOption('Registered Nurse','Registered Nurse'));
        licReg.add(new SelectOption('Registered Occupational Hygienist ','Registered Occupational Hygienist '));
        licReg.add(new SelectOption('Registered Professional Archaeologist','Registered Professional Archaeologist'));
        licReg.add(new SelectOption('Registered Professional Biologist','Registered Professional Biologist'));
        licReg.add(new SelectOption('Registered Professional Engineering Technologist','Registered Professional Engineering Technologist'));
        licReg.add(new SelectOption('Registered Professional Forester','Registered Professional Forester'));
        licReg.add(new SelectOption('Registered Professional Planner','Registered Professional Planner'));
        licReg.add(new SelectOption('Registered Professional Technologist','Registered Professional Technologist'));
        licReg.add(new SelectOption('Registered Respiratory Therapist','Registered Respiratory Therapist'));
        licReg.add(new SelectOption('Registered Safety Professional','Registered Safety Professional'));
        licReg.add(new SelectOption('Registered Sanitarian','Registered Sanitarian'));
        licReg.add(new SelectOption('Registered Site Manager','Registered Site Manager'));
        licReg.add(new SelectOption('Registered Specification Writer','Registered Specification Writer'));
        licReg.add(new SelectOption('Registered Telecommunications Project Manager','Registered Telecommunications Project Manager'));
        licReg.add(new SelectOption('Structural Engineering Certification Board','Structural Engineering Certification Board'));
        licReg.add(new SelectOption('Surveyor in Training','Surveyor in Training'));
        licReg.add(new SelectOption('Technician in Training','Technician in Training'));
        licReg.add(new SelectOption('Technologist in Training','Technologist in Training'));
        licReg.add(new SelectOption('Toxic Substance Reduction Planner','Toxic Substance Reduction Planner'));
        licReg.add(new SelectOption('Well Drilling/Pump Installation Contractor','Well Drilling/Pump Installation Contractor'));
        licReg.add(new SelectOption('Wireless Designer','Wireless Designer'));
        return licReg;
    }

    public List<SelectOption> getCountryList() {
        List<SelectOption> countries = new List<SelectOption>();
        countries.add(new SelectOption('','--None--'));
        sObject sObj = Schema.getGlobalDescribe().get('rs_Profile_Part__c').newSObject();
        countries.addAll(rsDataUtils.getPicklistValues(sObj, 'Country__c'));
        return countries;
    }

    public String getCountry() {
        String retVal = '';
        if(mUserConditions.get('country') != null) {
            retVal = (String)mUserConditions.get('country').value;
        }
        return retVal;
    }

    public void setCountry(String country) {
        mUserConditions.put('country',new Condition(country, ' = ', 'Country'));
    }

    public String getGeography() {
        String retVal = '';
        if(mUserConditions.get('geography') != null) {
            retVal = (String)mUserConditions.get('geography').value;
        }
        return retVal;
    }

    public void setGeography(String geo) {
        mUserConditions.put('geography',new Condition(geo,' = ', 'Geography__c'));
    }

     public List<SelectOption> getGeographyList() {
        List<SelectOption> geos = new List<SelectOption>();
        geos.add(new SelectOption('','--None--'));
        geos.add(new SelectOption('AECOM Corp','AECOM Corp'));
        geos.add(new SelectOption('Africa','Africa'));
        geos.add(new SelectOption('Americas','Americas'));
        geos.add(new SelectOption('Americas CS','Americas CS'));
        geos.add(new SelectOption('ANZ ','ANZ '));
        geos.add(new SelectOption('APAC','APAC'));
        geos.add(new SelectOption('APAC Overhead','APAC Overhead'));
        geos.add(new SelectOption('EMEA','EMEA'));
        geos.add(new SelectOption('EMEA Mgmt','EMEA Mgmt'));
        geos.add(new SelectOption('End Markets','End Markets'));
        geos.add(new SelectOption('Europe','Europe'));
        geos.add(new SelectOption('Greater China','Greater China'));
        geos.add(new SelectOption('GSS','GSS'));
        geos.add(new SelectOption('IT - Americas','IT - Americas'));
        geos.add(new SelectOption('IT - APAC','IT - APAC'));
        geos.add(new SelectOption('IT - EMEA','IT - EMEA'));
        geos.add(new SelectOption('Middle East','Middle East'));
        geos.add(new SelectOption('South & SE Asia','South & SE Asia'));
        return geos;
    }

    public String getOfficeLocation() {
        String retVal = '';
        if(mUserConditions.get('officeLocation') != null) {
            retVal = (String)mUserConditions.get('officeLocation').value;
        }
        return retVal;
    }

    public void setOfficeLocation(String offLoc) {
        mUserConditions.put('officeLocation',new Condition(offLoc, ' = ', 'Office__c'));
    }

    public List<SelectOption> getOfficeLocationList() {
        List<SelectOption> offList = new List<SelectOption>();
        offList.add(new SelectOption('','--None--'));
        offList.add(new SelectOption('AE - Abu Dhabi, UAE - International Tower','AE - Abu Dhabi, UAE - International Tower'));
        offList.add(new SelectOption('AE - Al Ain, UAE - Liwa Centre Building','AE - Al Ain, UAE - Liwa Centre Building'));
        offList.add(new SelectOption('AE - Dubai, UAE - UBora Tower','AE - Dubai, UAE - UBora Tower'));
        offList.add(new SelectOption('AF - Kabul, XX - House 63, Lane 1, Street 15 Wazir Akhbar Kh','AF - Kabul, XX - House 63, Lane 1, Street 15 Wazir Akhbar Kh'));
        offList.add(new SelectOption('AR - Azatutyan 27, ER - Rooms 503 and 506 Eraz Business Cent','AR - Azatutyan 27, ER - Rooms 503 and 506 Eraz Business Cent'));
        offList.add(new SelectOption('AR - Buenos Aires, XX - Suipacha 280, 6th Floor','AR - Buenos Aires, XX - Suipacha 280, 6th Floor'));
        offList.add(new SelectOption('AT - Vienna - Bovis Lend Lease','AT - Vienna - Bovis Lend Lease'));
        offList.add(new SelectOption('AU - Adelaide, SA','AU - Adelaide, SA'));
        offList.add(new SelectOption('AU - Adelaide, XX - Level 4 70 Light Square','AU - Adelaide, XX - Level 4 70 Light Square'));
        offList.add(new SelectOption('AU - Brisbane QLD, XX - Level 17, 240 Queen Street','AU - Brisbane QLD, XX - Level 17, 240 Queen Street'));
        offList.add(new SelectOption('AU - Brisbane, QLD','AU - Brisbane, QLD'));
        offList.add(new SelectOption('AU - Cairns, QLD','AU - Cairns, QLD'));
        offList.add(new SelectOption('AU - Canberra, ACT','AU - Canberra, ACT'));
        offList.add(new SelectOption('AU - Darwin NT, XX - Level 3, 93 Mitchell Street GPO Box 200','AU - Darwin NT, XX - Level 3, 93 Mitchell Street GPO Box 200'));
        offList.add(new SelectOption('AU - Darwin, NT','AU - Darwin, NT'));
        offList.add(new SelectOption('AU - Graz, 06 - Muenzgrabenstrasse 94','AU - Graz, 06 - Muenzgrabenstrasse 94'));
        offList.add(new SelectOption('AU - Hobart, TAS','AU - Hobart, TAS'));
        offList.add(new SelectOption('AU - Hunter, NSW','AU - Hunter, NSW'));
        offList.add(new SelectOption('AU - Mackay, QLD','AU - Mackay, QLD'));
        offList.add(new SelectOption('AU - Maroochydore, QLD','AU - Maroochydore, QLD'));
        offList.add(new SelectOption('AU - Mayfield, NS - Unit 4, 54 Industrial Drive','AU - Mayfield, NS - Unit 4, 54 Industrial Drive'));
        offList.add(new SelectOption('AU - Melbourne VIC, XX - 1 Southbank Blvd 1 Southbank Boulev','AU - Melbourne VIC, XX - 1 Southbank Blvd 1 Southbank Boulev'));
        offList.add(new SelectOption('AU - Melbourne, VIC - 8 Exhibition St','AU - Melbourne, VIC - 8 Exhibition St'));
        offList.add(new SelectOption('AU - Melbourne, VIC - 80 Collins St','AU - Melbourne, VIC - 80 Collins St'));
        offList.add(new SelectOption('AU - North Sydney NSW, XX - Australia - Level 3 116 Miller S','AU - North Sydney NSW, XX - Australia - Level 3 116 Miller S'));
        offList.add(new SelectOption('AU - Perth, AUS -','AU - Perth, AUS -'));
        offList.add(new SelectOption('AU - Perth, WA','AU - Perth, WA'));
        offList.add(new SelectOption('AU - Perth, WA - URS Corporation 226 Adelaide Terrace','AU - Perth, WA - URS Corporation 226 Adelaide Terrace'));
        offList.add(new SelectOption('AU - Rockhampton, QLD','AU - Rockhampton, QLD'));
        offList.add(new SelectOption('AU - Singleton, NSW','AU - Singleton, NSW'));
        offList.add(new SelectOption('AU - Sydney, NSW','AU - Sydney, NSW'));
        offList.add(new SelectOption('AU - Tatura, VI - 155A Hogan St','AU - Tatura, VI - 155A Hogan St'));
        offList.add(new SelectOption('AU - Townsville, QLD','AU - Townsville, QLD'));
        offList.add(new SelectOption('AU - Turner ACT, XX - 91 Northbourne Avenue Level 1, Suite 2','AU - Turner ACT, XX - 91 Northbourne Avenue Level 1, Suite 2'));
        offList.add(new SelectOption('AZ - Baku - 96, Nizami Street','AZ - Baku - 96, Nizami Street'));
        offList.add(new SelectOption('AZ - Baku, XX - Natavan Residences 5th Floor, Tbilisi Avenue','AZ - Baku, XX - Natavan Residences 5th Floor, Tbilisi Avenue'));
        offList.add(new SelectOption('BA - Sarajevo - Tesanjska 24A','BA - Sarajevo - Tesanjska 24A'));
        offList.add(new SelectOption('BE - Ghent, XX - Stapelplein 70, 9000','BE - Ghent, XX - Stapelplein 70, 9000'));
        offList.add(new SelectOption('BE - Leuven, XX - Maria Theresiastraat 34a 3000 Leuven','BE - Leuven, XX - Maria Theresiastraat 34a 3000 Leuven'));
        offList.add(new SelectOption('BH - Juffair, - MSC SSU BAH, Bldg 262 Road 40, Block 340','BH - Juffair, - MSC SSU BAH, Bldg 262 Road 40, Block 340'));
        offList.add(new SelectOption('BH - Manama, - Manama Euro Tower Office 31 Bldg. 485, Road 1','BH - Manama, - Manama Euro Tower Office 31 Bldg. 485, Road 1'));
        offList.add(new SelectOption('BH - Manama, BH - Al Saffar House, Seef District','BH - Manama, BH - Al Saffar House, Seef District'));
        offList.add(new SelectOption('BH - Manama, BH - Euro Tower','BH - Manama, BH - Euro Tower'));
        offList.add(new SelectOption('BO - BOL -','BO - BOL -'));
        offList.add(new SelectOption('BO - Cochabamba, XX - Avenida Uyuni 1103','BO - Cochabamba, XX - Avenida Uyuni 1103'));
        offList.add(new SelectOption('BR - Nova Lima, Brazil - Alameda do Inga','BR - Nova Lima, Brazil - Alameda do Inga'));
        offList.add(new SelectOption('BR - Rio de Janeiro, Brazil - Praia de Botafogo','BR - Rio de Janeiro, Brazil - Praia de Botafogo'));
        offList.add(new SelectOption('BR - Sao Paulo, Brazil - Rua Antonio das Chagas','BR - Sao Paulo, Brazil - Rua Antonio das Chagas'));
        offList.add(new SelectOption('BR - Sao Paulo, Brazil - Rua Tenente Negrao','BR - Sao Paulo, Brazil - Rua Tenente Negrao'));
        offList.add(new SelectOption('BW - Gaborone - Gaborone International Finance Park','BW - Gaborone - Gaborone International Finance Park'));
        offList.add(new SelectOption('CA - Alida, SK - Highway 361','CA - Alida, SK - Highway 361'));
        offList.add(new SelectOption('CA - Anzac, AB - 60 KM South-South East of Fort McMurray, Ki','CA - Anzac, AB - 60 KM South-South East of Fort McMurray, Ki'));
        offList.add(new SelectOption('CA - Anzac, AB - N/A','CA - Anzac, AB - N/A'));
        offList.add(new SelectOption('CA - Bonnyville, AB - 6015 50 Avenue','CA - Bonnyville, AB - 6015 50 Avenue'));
        offList.add(new SelectOption('CA - Bonnyville, AB - 6016 52 Avenue','CA - Bonnyville, AB - 6016 52 Avenue'));
        offList.add(new SelectOption('CA - Bonnyville, AB - 6024 52 Avenue','CA - Bonnyville, AB - 6024 52 Avenue'));
        offList.add(new SelectOption('CA - Bonnyville, AB - Highway 28 East, 61317 RR 452, PO Box ','CA - Bonnyville, AB - Highway 28 East, 61317 RR 452, PO Box '));
        offList.add(new SelectOption('CA - Brooks, AB - 10 Industrial Road, PO Box 1348','CA - Brooks, AB - 10 Industrial Road, PO Box 1348'));
        offList.add(new SelectOption('CA - Brooks, AB - 10 Industrial Road, PO Box 310','CA - Brooks, AB - 10 Industrial Road, PO Box 310'));
        offList.add(new SelectOption('CA - Brooks, AB - 143006 Highway 1A, PO Box 387','CA - Brooks, AB - 143006 Highway 1A, PO Box 387'));
        offList.add(new SelectOption('CA - Calgary, AB - 240-6025 11 Street SE','CA - Calgary, AB - 240-6025 11 Street SE'));
        offList.add(new SelectOption('CA - Calgary, AB - 3000-715 5 Avenue SW','CA - Calgary, AB - 3000-715 5 Avenue SW'));
        offList.add(new SelectOption('CA - Calgary, AB - 700-300 5 Avenue SW','CA - Calgary, AB - 700-300 5 Avenue SW'));
        offList.add(new SelectOption('CA - Calgary, AB - 9727 40 Street SE','CA - Calgary, AB - 9727 40 Street SE'));
        offList.add(new SelectOption('CA - Calgary, AB - Life Plaza 734 7th Avenue, SW','CA - Calgary, AB - Life Plaza 734 7th Avenue, SW'));
        offList.add(new SelectOption('CA - CAN -','CA - CAN -'));
        offList.add(new SelectOption('CA - Carlyle, SK - PO Box 1149','CA - Carlyle, SK - PO Box 1149'));
        offList.add(new SelectOption('CA - Christina Lake, AB - N/A','CA - Christina Lake, AB - N/A'));
        offList.add(new SelectOption('CA - Cold Lake, AB - Hwy 55 West, Bag 5000','CA - Cold Lake, AB - Hwy 55 West, Bag 5000'));
        offList.add(new SelectOption('CA - Drayton Valley, AB - 6242 56 Avenue, PO Box 6509','CA - Drayton Valley, AB - 6242 56 Avenue, PO Box 6509'));
        offList.add(new SelectOption('CA - Edmonton, AB - 10360 58 Avenue','CA - Edmonton, AB - 10360 58 Avenue'));
        offList.add(new SelectOption('CA - Edmonton, AB - 3052 84 Avenue','CA - Edmonton, AB - 3052 84 Avenue'));
        offList.add(new SelectOption('CA - Edson, AB - Highway 16 East, RR 170, PO Box 6060','CA - Edson, AB - Highway 16 East, RR 170, PO Box 6060'));
        offList.add(new SelectOption('CA - Estevan, SK - 100 Supreme Street Highway 39 East of Est','CA - Estevan, SK - 100 Supreme Street Highway 39 East of Est'));
        offList.add(new SelectOption('CA - Estevan, SK - Highway 47 North, PO Box 909','CA - Estevan, SK - Highway 47 North, PO Box 909'));
        offList.add(new SelectOption('CA - Fort McMurray, AB - 150 MacDonald Crescent','CA - Fort McMurray, AB - 150 MacDonald Crescent'));
        offList.add(new SelectOption('CA - Fort Saskatchewan, AB - 11000 125 St','CA - Fort Saskatchewan, AB - 11000 125 St'));
        offList.add(new SelectOption('CA - Fort St. John, BC - 7307 100 Street, PO Box 6782','CA - Fort St. John, BC - 7307 100 Street, PO Box 6782'));
        offList.add(new SelectOption('CA - Fort St. John, BC - 8320 89A Street','CA - Fort St. John, BC - 8320 89A Street'));
        offList.add(new SelectOption('CA - Fort St. John, BC - 8320 89A Street, PO Box 6010','CA - Fort St. John, BC - 8320 89A Street, PO Box 6010'));
        offList.add(new SelectOption('CA - Fort St. John, BC - 8912 81 Avenue','CA - Fort St. John, BC - 8912 81 Avenue'));
        offList.add(new SelectOption('CA - FortMcMurray, AB - N/A','CA - FortMcMurray, AB - N/A'));
        offList.add(new SelectOption('CA - Grande Prairie (Clairmont), AB - 10414 84 Avenue','CA - Grande Prairie (Clairmont), AB - 10414 84 Avenue'));
        offList.add(new SelectOption('CA - Grande Prairie, AB - 9514 39 Avenue','CA - Grande Prairie, AB - 9514 39 Avenue'));
        offList.add(new SelectOption('CA - Halbrite, SK - Highway 39','CA - Halbrite, SK - Highway 39'));
        offList.add(new SelectOption('CA - Hardisty, AB - Husky Enbridge Line Expansion','CA - Hardisty, AB - Husky Enbridge Line Expansion'));
        offList.add(new SelectOption('CA - Hardisty, AB - N/A','CA - Hardisty, AB - N/A'));
        offList.add(new SelectOption('CA - Joffre, AB - Flint Building 27, Joffre Plant','CA - Joffre, AB - Flint Building 27, Joffre Plant'));
        offList.add(new SelectOption('CA - Joffre, AB - Flint Trailers - Joffre Plant - Across Fro','CA - Joffre, AB - Flint Trailers - Joffre Plant - Across Fro'));
        offList.add(new SelectOption('CA - Kiplin, SK - 903 Main Street','CA - Kiplin, SK - 903 Main Street'));
        offList.add(new SelectOption('CA - Lampman, SK - Highway 361 West, PO Box 160','CA - Lampman, SK - Highway 361 West, PO Box 160'));
        offList.add(new SelectOption('CA - Lloydminster, AB - 5701 59 Avenue, Box 10470','CA - Lloydminster, AB - 5701 59 Avenue, Box 10470'));
        offList.add(new SelectOption('CA - Lloydminster, AB - 5704  59 Avenue, Box 10470','CA - Lloydminster, AB - 5704  59 Avenue, Box 10470'));
        offList.add(new SelectOption('CA - Lloydminster, AB - County Energy Park, Highway 16 West,','CA - Lloydminster, AB - County Energy Park, Highway 16 West,'));
        offList.add(new SelectOption('CA - Lloydminster, AB - Highway 16 W, RR 13, PO Box 12188','CA - Lloydminster, AB - Highway 16 W, RR 13, PO Box 12188'));
        offList.add(new SelectOption('CA - Lloydminster, AB - Reinhart Industrial Park, PO Box 118','CA - Lloydminster, AB - Reinhart Industrial Park, PO Box 118'));
        offList.add(new SelectOption('CA - Mount Pearl, NL - PO Box 176','CA - Mount Pearl, NL - PO Box 176'));
        offList.add(new SelectOption('CA - N/A, Multiple Provinces - N/A','CA - N/A, Multiple Provinces - N/A'));
        offList.add(new SelectOption('CA - Nisku North, AB - 950 30 Avenue','CA - Nisku North, AB - 950 30 Avenue'));
        offList.add(new SelectOption('CA - Nisku South, AB - 1511 4 Street','CA - Nisku South, AB - 1511 4 Street'));
        offList.add(new SelectOption('CA - Norman Wells, NWT - PO Box 143 (couriers to call # prio','CA - Norman Wells, NWT - PO Box 143 (couriers to call # prio'));
        offList.add(new SelectOption('CA - Olds, AB - 11 Imperial Close','CA - Olds, AB - 11 Imperial Close'));
        offList.add(new SelectOption('CA - Peace River, AB - 9 Cessna Road, PO Box 6957','CA - Peace River, AB - 9 Cessna Road, PO Box 6957'));
        offList.add(new SelectOption('CA - Peace River, AB - N/A','CA - Peace River, AB - N/A'));
        offList.add(new SelectOption('CA - Peace River, AB - Shell Peace River Complex,  Secondary','CA - Peace River, AB - Shell Peace River Complex,  Secondary'));
        offList.add(new SelectOption('CA - Rainbow Lake, AB - 14 Del Rio Street','CA - Rainbow Lake, AB - 14 Del Rio Street'));
        offList.add(new SelectOption('CA - Rainbow Lake, AB - 53 Imperial Drive','CA - Rainbow Lake, AB - 53 Imperial Drive'));
        offList.add(new SelectOption('CA - Red Deer, AB - 4115 Henry Street','CA - Red Deer, AB - 4115 Henry Street'));
        offList.add(new SelectOption('CA - Red Deer, AB - 4747 78A Street Close','CA - Red Deer, AB - 4747 78A Street Close'));
        offList.add(new SelectOption('CA - Redcliff, AB - 1901 Highway Avenue SE','CA - Redcliff, AB - 1901 Highway Avenue SE'));
        offList.add(new SelectOption('CA - Regina, SK - 290 Hodsman Road','CA - Regina, SK - 290 Hodsman Road'));
        offList.add(new SelectOption('CA - Richmond Hill, ON - 30 Leek Crescent 4th Floor','CA - Richmond Hill, ON - 30 Leek Crescent 4th Floor'));
        offList.add(new SelectOption('CA - Saskatoon, SK - 202A Cory Road, East Cory Industrial Pa','CA - Saskatoon, SK - 202A Cory Road, East Cory Industrial Pa'));
        offList.add(new SelectOption('CA - Shaunavon, SK - 1110 Highway 13, Box 1390','CA - Shaunavon, SK - 1110 Highway 13, Box 1390'));
        offList.add(new SelectOption('CA - Sherwood Park, AB - 100-2899 Broadmoor Boulevard','CA - Sherwood Park, AB - 100-2899 Broadmoor Boulevard'));
        offList.add(new SelectOption('CA - Sherwood Park, AB - 106 Strathmoor Drive','CA - Sherwood Park, AB - 106 Strathmoor Drive'));
        offList.add(new SelectOption('CA - Sherwood Park, AB - 108, 2257 Premier Way','CA - Sherwood Park, AB - 108, 2257 Premier Way'));
        offList.add(new SelectOption('CA - Sherwood Park, AB - 151 Strathmoor Drive','CA - Sherwood Park, AB - 151 Strathmoor Drive'));
        offList.add(new SelectOption('CA - Sherwood Park, AB - 176-2257 Premier Way','CA - Sherwood Park, AB - 176-2257 Premier Way'));
        offList.add(new SelectOption('CA - Sherwood Park, AB - 180 Strathmoor Drive','CA - Sherwood Park, AB - 180 Strathmoor Drive'));
        offList.add(new SelectOption('CA - Sherwood Park, AB - 208-2257 Premier Way','CA - Sherwood Park, AB - 208-2257 Premier Way'));
        offList.add(new SelectOption('CA - Sherwood Park, AB - 240-2257 Premier Way','CA - Sherwood Park, AB - 240-2257 Premier Way'));
        offList.add(new SelectOption('CA - Sherwood Park, AB - 260-2257 Premier Way','CA - Sherwood Park, AB - 260-2257 Premier Way'));
        offList.add(new SelectOption('CA - Sherwood Park, AB - 276, 2257 Premier Way','CA - Sherwood Park, AB - 276, 2257 Premier Way'));
        offList.add(new SelectOption('CA - Sherwood Park, AB - 28 Strathmoor Way','CA - Sherwood Park, AB - 28 Strathmoor Way'));
        offList.add(new SelectOption('CA - Strathmore, AB - RR 243, 8 KM East on Highway 2','CA - Strathmore, AB - RR 243, 8 KM East on Highway 2'));
        offList.add(new SelectOption('CA - Swift Current, SK - 2435 North Service Road West','CA - Swift Current, SK - 2435 North Service Road West'));
        offList.add(new SelectOption('CA - Vancouver, BC - P.O. Box 11507 650 West Georgia St.','CA - Vancouver, BC - P.O. Box 11507 650 West Georgia St.'));
        offList.add(new SelectOption('CA - Virden, MB - 265 Commonwealth Drive, PO Box 352','CA - Virden, MB - 265 Commonwealth Drive, PO Box 352'));
        offList.add(new SelectOption('CA - Wabasca, AB - N/A','CA - Wabasca, AB - N/A'));
        offList.add(new SelectOption('CA - Wainwright, AB - 1718 23 Avenue, PO Box 3273','CA - Wainwright, AB - 1718 23 Avenue, PO Box 3273'));
        offList.add(new SelectOption('CA - White City, SK - Hwy 1 East, 3 North Service Road','CA - White City, SK - Hwy 1 East, 3 North Service Road'));
        offList.add(new SelectOption('CA - Whitecourt, AB - 3315 41 Avenue','CA - Whitecourt, AB - 3315 41 Avenue'));
        offList.add(new SelectOption('CAN - Baie Comeau, QC - 235, Blvd La Salle','CAN - Baie Comeau, QC - 235, Blvd La Salle'));
        offList.add(new SelectOption('CAN - Barrie, ON - 55 Cedar Point Drive','CAN - Barrie, ON - 55 Cedar Point Drive'));
        offList.add(new SelectOption('CAN - Burnaby, BC - 3292 Production Way','CAN - Burnaby, BC - 3292 Production Way'));
        offList.add(new SelectOption('CAN - Calgary, AB - 48 Quarry Park Blvd','CAN - Calgary, AB - 48 Quarry Park Blvd'));
        offList.add(new SelectOption('CAN - Chicoutimi, QC - 255, Rue Racine Est','CAN - Chicoutimi, QC - 255, Rue Racine Est'));
        offList.add(new SelectOption('CAN - Cobalt, ON - 1 Station Rd','CAN - Cobalt, ON - 1 Station Rd'));
        offList.add(new SelectOption('CAN - Edmonton, AB - 18817 Stony Plain Rd NW','CAN - Edmonton, AB - 18817 Stony Plain Rd NW'));
        offList.add(new SelectOption('CAN - Guelph, ON - 55 Wyndham St N','CAN - Guelph, ON - 55 Wyndham St N'));
        offList.add(new SelectOption('CAN - Halifax, NS - 1701 Hollis St','CAN - Halifax, NS - 1701 Hollis St'));
        offList.add(new SelectOption('CAN - Hamilton, ON - 45 Goderich Rd','CAN - Hamilton, ON - 45 Goderich Rd'));
        offList.add(new SelectOption('CAN - Kelowna, BC - 3275 Lakeshore Rd','CAN - Kelowna, BC - 3275 Lakeshore Rd'));
        offList.add(new SelectOption('CAN - Kingston, ON - 654 Norris Ct','CAN - Kingston, ON - 654 Norris Ct'));
        offList.add(new SelectOption('CAN - Kitchener, ON - 50 Sportsworld Crossing Rd','CAN - Kitchener, ON - 50 Sportsworld Crossing Rd'));
        offList.add(new SelectOption('CAN - Levis, QC - 1120 Boul. Guillaume-Couture','CAN - Levis, QC - 1120 Boul. Guillaume-Couture'));
        offList.add(new SelectOption('CAN - London, ON - 250 York St','CAN - London, ON - 250 York St'));
        offList.add(new SelectOption('CAN - Longueuil, QC - 2199 Blvd Fernand-Lafontaine','CAN - Longueuil, QC - 2199 Blvd Fernand-Lafontaine'));
        offList.add(new SelectOption('CAN - Markham, ON - 105 Commerce Valley Dr W','CAN - Markham, ON - 105 Commerce Valley Dr W'));
        offList.add(new SelectOption('CAN - Mississauga, ON - 5080 Commerce Blvd','CAN - Mississauga, ON - 5080 Commerce Blvd'));
        offList.add(new SelectOption('CAN - Montreal, QC - 85, Sainte-Catherine St West','CAN - Montreal, QC - 85, Sainte-Catherine St West'));
        offList.add(new SelectOption('CAN - North Bay, ON - 189 Wyld St','CAN - North Bay, ON - 189 Wyld St'));
        offList.add(new SelectOption('CAN - Ottawa, ON - 1150 Morrison Dr','CAN - Ottawa, ON - 1150 Morrison Dr'));
        offList.add(new SelectOption('CAN - Ouagadougou, BF - BP2601 Ouagadougou 01','CAN - Ouagadougou, BF - BP2601 Ouagadougou 01'));
        offList.add(new SelectOption('CAN - Port of Spain, Trinidad','CAN - Port of Spain, Trinidad'));
        offList.add(new SelectOption('CAN - Port of Spain, Trinidad - 27 Saddle Road','CAN - Port of Spain, Trinidad - 27 Saddle Road'));
        offList.add(new SelectOption('CAN - Port-au-Prince, HT - 63, rue Faustin 1er','CAN - Port-au-Prince, HT - 63, rue Faustin 1er'));
        offList.add(new SelectOption('CAN - Quebec, QC - 4700, Blvd Wilfrid-Hamel','CAN - Quebec, QC - 4700, Blvd Wilfrid-Hamel'));
        offList.add(new SelectOption('CAN - Regina, SK - 183-1621 Albert St','CAN - Regina, SK - 183-1621 Albert St'));
        offList.add(new SelectOption('CAN - Richmond Hill, ON - 30 Leek Crescent','CAN - Richmond Hill, ON - 30 Leek Crescent'));
        offList.add(new SelectOption('CAN - Riviere Du Loup, QC - 2, Rue de la Cour','CAN - Riviere Du Loup, QC - 2, Rue de la Cour'));
        offList.add(new SelectOption('CAN - Rouyn-Noranda, QC - 436, Ave Lariviere','CAN - Rouyn-Noranda, QC - 436, Ave Lariviere'));
        offList.add(new SelectOption('CAN - Saskatoon, SK - 2100 8th St','CAN - Saskatoon, SK - 2100 8th St'));
        offList.add(new SelectOption('CAN - Sault Ste Marie, ON - 523 Wellington St E','CAN - Sault Ste Marie, ON - 523 Wellington St E'));
        offList.add(new SelectOption('CAN - St Catharines, ON - 30 Hannover Dr','CAN - St Catharines, ON - 30 Hannover Dr'));
        offList.add(new SelectOption('CAN - St Jerome, QC - 424 St Georges','CAN - St Jerome, QC - 424 St Georges'));
        offList.add(new SelectOption('CAN - Sudbury, ON - 1361 Paris Street','CAN - Sudbury, ON - 1361 Paris Street'));
        offList.add(new SelectOption('CAN - Sydney, NS - 164 Charlotte St','CAN - Sydney, NS - 164 Charlotte St'));
        offList.add(new SelectOption('CAN - Trois-Rivieres, QC - 2, Rue Fusey','CAN - Trois-Rivieres, QC - 2, Rue Fusey'));
        offList.add(new SelectOption('CAN - Victoria, BC - 415 Gorge Rd E','CAN - Victoria, BC - 415 Gorge Rd E'));
        offList.add(new SelectOption('CAN - Whitby, ON - 1615 Dundas St E','CAN - Whitby, ON - 1615 Dundas St E'));
        offList.add(new SelectOption('CAN - Whitby, ON - 300 Water St','CAN - Whitby, ON - 300 Water St'));
        offList.add(new SelectOption('CAN - Windsor, ON - 350 Cabana Rd E','CAN - Windsor, ON - 350 Cabana Rd E'));
        offList.add(new SelectOption('CAN - Winnipeg, MB - 99 Commerce Dr','CAN - Winnipeg, MB - 99 Commerce Dr'));
        offList.add(new SelectOption('CAN - Yellowknife, NT - 4916 47 St','CAN - Yellowknife, NT - 4916 47 St'));
        offList.add(new SelectOption('CH - , -','CH - , -'));
        offList.add(new SelectOption('CH - 4600 Olten, SO - Ringstrasse 2','CH - 4600 Olten, SO - Ringstrasse 2'));
        offList.add(new SelectOption('CH - Beijing, XX - NO. 7 Guanghua Road Hanwei Plaza, Suite 1','CH - Beijing, XX - NO. 7 Guanghua Road Hanwei Plaza, Suite 1'));
        offList.add(new SelectOption('CH - Providencia Santiago CI, - Miraflores 178, Floor 21','CH - Providencia Santiago CI, - Miraflores 178, Floor 21'));
        offList.add(new SelectOption('CH - Shanghai, 31 - 31st Floor Kerry Parkside Office Tower 1','CH - Shanghai, 31 - 31st Floor Kerry Parkside Office Tower 1'));
        offList.add(new SelectOption('CH - Shanghai, XX - No. 107 Zunyi Road Aetna Tower, Suite 50','CH - Shanghai, XX - No. 107 Zunyi Road Aetna Tower, Suite 50'));
        offList.add(new SelectOption('CH - Shatin Hong Kong, XX - 138 Shatin Rural Committee Road','CH - Shatin Hong Kong, XX - 138 Shatin Rural Committee Road'));
        offList.add(new SelectOption('CH - Shenzhen, XX - Unit 501, 5th Floor Cafu Plaza 5 Guihua ','CH - Shenzhen, XX - Unit 501, 5th Floor Cafu Plaza 5 Guihua '));
        offList.add(new SelectOption('CH - Suzhou, XX - URS Consulting (Shanghai) Ltd No.1 Suhua R','CH - Suzhou, XX - URS Consulting (Shanghai) Ltd No.1 Suhua R'));
        offList.add(new SelectOption('CH - Tianhe District Guangzhou, XX - Unit 1301, 13th Floor, ','CH - Tianhe District Guangzhou, XX - Unit 1301, 13th Floor, '));
        offList.add(new SelectOption('CN - Beijing - No 9 Zheng Ren Building','CN - Beijing - No 9 Zheng Ren Building'));
        offList.add(new SelectOption('CN - Beijing - Office 24, F24, Tower One','CN - Beijing - Office 24, F24, Tower One'));
        offList.add(new SelectOption('CN - Chongqing - 35F Metropolitan Tower','CN - Chongqing - 35F Metropolitan Tower'));
        offList.add(new SelectOption('CN - Guangzhou - 34F HNA Building','CN - Guangzhou - 34F HNA Building'));
        offList.add(new SelectOption('CN - Jiangxi - 459 Industrial Road','CN - Jiangxi - 459 Industrial Road'));
        offList.add(new SelectOption('CN - Shanghai - 36-38/F Wheelock Square','CN - Shanghai - 36-38/F Wheelock Square'));
        offList.add(new SelectOption('CN - Shenzhen - 14-15/F, Block B, East Tower, Coastal Bldg','CN - Shenzhen - 14-15/F, Block B, East Tower, Coastal Bldg'));
        offList.add(new SelectOption('CN - Shenzhen - 14/F Southern Securities Bldg','CN - Shenzhen - 14/F Southern Securities Bldg'));
        offList.add(new SelectOption('CN - Shenzhen - Unit 01- 05, 28F, Tiley Central Plaza','CN - Shenzhen - Unit 01- 05, 28F, Tiley Central Plaza'));
        offList.add(new SelectOption('CN - Tianjin - Maigou International Plaza','CN - Tianjin - Maigou International Plaza'));
        offList.add(new SelectOption('CO - Bogota, Colombia - Calle 72 No 10-51','CO - Bogota, Colombia - Calle 72 No 10-51'));
        offList.add(new SelectOption('CU - FPO, AE, 14 - URS Group, Inc. PSC 1005 Box 9','CU - FPO, AE, 14 - URS Group, Inc. PSC 1005 Box 9'));
        offList.add(new SelectOption('CU - Guantanamo Bay, CUB -','CU - Guantanamo Bay, CUB -'));
        offList.add(new SelectOption('CZ - Brno - Gen.Píky , Brno','CZ - Brno - Gen.Píky , Brno'));
        offList.add(new SelectOption('CZ - Liberec - Londynska 51/2, Liberec','CZ - Liberec - Londynska 51/2, Liberec'));
        offList.add(new SelectOption('CZ - Ostrava - Brandlova 6','CZ - Ostrava - Brandlova 6'));
        offList.add(new SelectOption('CZ - Plzen - Borská 55','CZ - Plzen - Borská 55'));
        offList.add(new SelectOption('CZ - Prague - Trojská 92','CZ - Prague - Trojská 92'));
        offList.add(new SelectOption('DE - APO AE, - CMR 489 Box 1466','DE - APO AE, - CMR 489 Box 1466'));
        offList.add(new SelectOption('DE - Berlin, XX - URS Deutschland GmbH Germaniastrasse 18-20','DE - Berlin, XX - URS Deutschland GmbH Germaniastrasse 18-20'));
        offList.add(new SelectOption('DE - Bradenburg, XX - Calauer Strasse 70 Cottbus','DE - Bradenburg, XX - Calauer Strasse 70 Cottbus'));
        offList.add(new SelectOption('DE - Chemnitz, XX - Ludwig-Kirsch-Strasse 12','DE - Chemnitz, XX - Ludwig-Kirsch-Strasse 12'));
        offList.add(new SelectOption('DE - DEU -','DE - DEU -'));
        offList.add(new SelectOption('DE - Essen, XX - Am Handelshof 1','DE - Essen, XX - Am Handelshof 1'));
        offList.add(new SelectOption('DE - Hamburg, XX - Schweriner Strasse 8-12','DE - Hamburg, XX - Schweriner Strasse 8-12'));
        offList.add(new SelectOption('DE - Kaiserslautern, XX - Europaallee 3-5','DE - Kaiserslautern, XX - Europaallee 3-5'));
        offList.add(new SelectOption('DE - Landstuhl Kirchberg, - Landstuhl Region Medical Center ','DE - Landstuhl Kirchberg, - Landstuhl Region Medical Center '));
        offList.add(new SelectOption('DE - Munich - Heimeranstrasse 37','DE - Munich - Heimeranstrasse 37'));
        offList.add(new SelectOption('DE - Munich, BY - Heimeranstrasse 37','DE - Munich, BY - Heimeranstrasse 37'));
        offList.add(new SelectOption('DE - Neu-Isenburg, XX - Siemenstrasse 10','DE - Neu-Isenburg, XX - Siemenstrasse 10'));
        offList.add(new SelectOption('DE - Neurenberg, - Fuerther Strausse 212','DE - Neurenberg, - Fuerther Strausse 212'));
        offList.add(new SelectOption('EG - , - URS','EG - , - URS'));
        offList.add(new SelectOption('EG - Cairo, EGY -','EG - Cairo, EGY -'));
        offList.add(new SelectOption('ES - A Gudina - Calle Atallo 6','ES - A Gudina - Calle Atallo 6'));
        offList.add(new SelectOption('ES - Barcelona - Calle Josep Estivill 77','ES - Barcelona - Calle Josep Estivill 77'));
        offList.add(new SelectOption('ES - Barcelona - Calle La Sagrera 111','ES - Barcelona - Calle La Sagrera 111'));
        offList.add(new SelectOption('ES - Barcelona, XX - C/ Urgel nº 143 - 4ª Planta','ES - Barcelona, XX - C/ Urgel nº 143 - 4ª Planta'));
        offList.add(new SelectOption('ES - Madrid - 54 Santa Engracia','ES - Madrid - 54 Santa Engracia'));
        offList.add(new SelectOption('ES - Madrid - Alfonso','ES - Madrid - Alfonso'));
        offList.add(new SelectOption('ES - Madrid - Alfonso XII','ES - Madrid - Alfonso XII'));
        offList.add(new SelectOption('ES - Madrid, XX - Juan De Mariana 17B 2nd Floor, 28045','ES - Madrid, XX - Juan De Mariana 17B 2nd Floor, 28045'));
        offList.add(new SelectOption('ES - Roales del Pan - Calle Merida 26','ES - Roales del Pan - Calle Merida 26'));
        offList.add(new SelectOption('ES - Rota Spain, - Hospital Americano Base Naval de Rota','ES - Rota Spain, - Hospital Americano Base Naval de Rota'));
        offList.add(new SelectOption('ES - Tallinn, - Narvo 13 mnt','ES - Tallinn, - Narvo 13 mnt'));
        offList.add(new SelectOption('ET - , -','ET - , -'));
        offList.add(new SelectOption('FI - Vantaa, XX - URS Nordic AB Myyrmaentie 2B, 4th Floor','FI - Vantaa, XX - URS Nordic AB Myyrmaentie 2B, 4th Floor'));
        offList.add(new SelectOption('FR - Aix-en-Prov Cedex, XX - EUROPARC DE PICHAURY - Bat. A5 ','FR - Aix-en-Prov Cedex, XX - EUROPARC DE PICHAURY - Bat. A5 '));
        offList.add(new SelectOption('FR - Lyon, XX - Immeuble Le Capitole 97 Cours Gambetta','FR - Lyon, XX - Immeuble Le Capitole 97 Cours Gambetta'));
        offList.add(new SelectOption('FR - Nanterre Cedex, XX - 87, avenue Francois Arago','FR - Nanterre Cedex, XX - 87, avenue Francois Arago'));
        offList.add(new SelectOption('FR - Paris - 28 Bld Haussmann','FR - Paris - 28 Bld Haussmann'));
        offList.add(new SelectOption('GB - , -','GB - , -'));
        offList.add(new SelectOption('GB - , XX - TBD','GB - , XX - TBD'));
        offList.add(new SelectOption('GB - Aberdeen, - C/O Scott Wilson Centurion Court North Espl','GB - Aberdeen, - C/O Scott Wilson Centurion Court North Espl'));
        offList.add(new SelectOption('GB - Andover, Hampshire -','GB - Andover, Hampshire -'));
        offList.add(new SelectOption('GB - Ashford, XX - Ashford International House 3rd Floor Dov','GB - Ashford, XX - Ashford International House 3rd Floor Dov'));
        offList.add(new SelectOption('GB - Basingstoke, XX - Scott House Alencon Link','GB - Basingstoke, XX - Scott House Alencon Link'));
        offList.add(new SelectOption('GB - Bedford, XX - URS House Horne Lane','GB - Bedford, XX - URS House Horne Lane'));
        offList.add(new SelectOption('GB - Belfast, XX - Belfast Beechill House Beechill Road','GB - Belfast, XX - Belfast Beechill House Beechill Road'));
        offList.add(new SelectOption('GB - Birmingham, XX - Alpha Tower, 7th Floor Suffolk Street ','GB - Birmingham, XX - Alpha Tower, 7th Floor Suffolk Street '));
        offList.add(new SelectOption('GB - Birmingham, XX - The McLaren Building 46 The Priory Que','GB - Birmingham, XX - The McLaren Building 46 The Priory Que'));
        offList.add(new SelectOption('GB - Bristol, XX - The Crescent Center Temple Back','GB - Bristol, XX - The Crescent Center Temple Back'));
        offList.add(new SelectOption('GB - Bristol, XX - The Crescent Centre Temple Black','GB - Bristol, XX - The Crescent Centre Temple Black'));
        offList.add(new SelectOption('GB - Caithess -','GB - Caithess -'));
        offList.add(new SelectOption('GB - Cambridge, XX - Michael Young Center Purbeck Road','GB - Cambridge, XX - Michael Young Center Purbeck Road'));
        offList.add(new SelectOption('GB - Cardiff, Glamorgan, XX - 1 Drake Walk, Brigantine Place','GB - Cardiff, Glamorgan, XX - 1 Drake Walk, Brigantine Place'));
        offList.add(new SelectOption('GB - Chelmsford, XX - Alexandra Court 36 Church Street Great','GB - Chelmsford, XX - Alexandra Court 36 Church Street Great'));
        offList.add(new SelectOption('GB - Chesterfield, XX - Chesterfield Royal Court Basil Close','GB - Chesterfield, XX - Chesterfield Royal Court Basil Close'));
        offList.add(new SelectOption('GB - Cumbria, XX - Saltom Suite Fleswick Court Westlakes Sci','GB - Cumbria, XX - Saltom Suite Fleswick Court Westlakes Sci'));
        offList.add(new SelectOption('GB - Edinburgh, XX - 2nd Floor Apex 2 97 Haymarket Terrace','GB - Edinburgh, XX - 2nd Floor Apex 2 97 Haymarket Terrace'));
        offList.add(new SelectOption('GB - Edinburgh, XX - Hopetoun Gate 8B McDonald Road','GB - Edinburgh, XX - Hopetoun Gate 8B McDonald Road'));
        offList.add(new SelectOption('GB - Exeter, XX - Belvedere House Pynes Hill','GB - Exeter, XX - Belvedere House Pynes Hill'));
        offList.add(new SelectOption('GB - Glasgow -','GB - Glasgow -'));
        offList.add(new SelectOption('GB - Glasgow, XX - Buchanan House 58 Port Dundas Road','GB - Glasgow, XX - Buchanan House 58 Port Dundas Road'));
        offList.add(new SelectOption('GB - Glasgow, XX - City Point 2 25 Tyndrum Street','GB - Glasgow, XX - City Point 2 25 Tyndrum Street'));
        offList.add(new SelectOption('GB - Glasgow, XX - Kinneil House 243 West George Street','GB - Glasgow, XX - Kinneil House 243 West George Street'));
        offList.add(new SelectOption('GB - Holmborrk, CU - Allerdale Court Greengarth Business Par','GB - Holmborrk, CU - Allerdale Court Greengarth Business Par'));
        offList.add(new SelectOption('GB - Holmrook, Cumbria - Low Level Waste Repository Site Dri','GB - Holmrook, Cumbria - Low Level Waste Repository Site Dri'));
        offList.add(new SelectOption('GB - Holmrook, Cumbria - UKNWM Greenbarth Business Centr All','GB - Holmrook, Cumbria - UKNWM Greenbarth Business Centr All'));
        offList.add(new SelectOption('GB - Inverness, XX - 6 Ardross Street','GB - Inverness, XX - 6 Ardross Street'));
        offList.add(new SelectOption('GB - Leeds, XX - West One Wellington Street Wellington Stree','GB - Leeds, XX - West One Wellington Street Wellington Stree'));
        offList.add(new SelectOption('GB - Liverpool, XX - Queen Buildings 24 Queens Avenue','GB - Liverpool, XX - Queen Buildings 24 Queens Avenue'));
        offList.add(new SelectOption('GB - London - 20 Bedford Square Bloomsbury','GB - London - 20 Bedford Square Bloomsbury'));
        offList.add(new SelectOption('GB - London, - CVU, Crescent Wharf, Silvertown','GB - London, - CVU, Crescent Wharf, Silvertown'));
        offList.add(new SelectOption('GB - London, Londonderry -','GB - London, Londonderry -'));
        offList.add(new SelectOption('GB - London, XX - 5 St. George\'s Road St. George\'s House, 2n','GB - London, XX - 5 St. George\'s Road St. George\'s House, 2n'));
        offList.add(new SelectOption('GB - London, XX - 6-8 Greencoat Place','GB - London, XX - 6-8 Greencoat Place'));
        offList.add(new SelectOption('GB - London, XX - Midcity Place 71 High Holborn','GB - London, XX - Midcity Place 71 High Holborn'));
        offList.add(new SelectOption('GB - London, XX - St. George\'s House, 2nd Floor 5 St. George','GB - London, XX - St. George\'s House, 2nd Floor 5 St. George'));
        offList.add(new SelectOption('GB - Londonderry, XX - River House 12-14 John Street','GB - Londonderry, XX - River House 12-14 John Street'));
        offList.add(new SelectOption('GB - Manchester, XX - Brunel House 54 Princess Street','GB - Manchester, XX - Brunel House 54 Princess Street'));
        offList.add(new SelectOption('GB - Middlesbrough, XX - Victoria House 159 Albert Road','GB - Middlesbrough, XX - Victoria House 159 Albert Road'));
        offList.add(new SelectOption('GB - Moor Row, Cumbria - Fleswick Court Westlakes Science & ','GB - Moor Row, Cumbria - Fleswick Court Westlakes Science & '));
        offList.add(new SelectOption('GB - Newcastle-upon-Tyne, XX - Earl Grey House 75-85 Grey St','GB - Newcastle-upon-Tyne, XX - Earl Grey House 75-85 Grey St'));
        offList.add(new SelectOption('GB - Norwich, XX - Meridian House 1 Meridian Way','GB - Norwich, XX - Meridian House 1 Meridian Way'));
        offList.add(new SelectOption('GB - Nottingham, XX - 12 Regan Way Chetwynd Business Park','GB - Nottingham, XX - 12 Regan Way Chetwynd Business Park'));
        offList.add(new SelectOption('GB - Peterborough Cambs -','GB - Peterborough Cambs -'));
        offList.add(new SelectOption('GB - Plymouth, XX - Mayflower House Armada Way 1st and 3rd F','GB - Plymouth, XX - Mayflower House Armada Way 1st and 3rd F'));
        offList.add(new SelectOption('GB - Seascale, CU - B582, 3rd Floor South','GB - Seascale, CU - B582, 3rd Floor South'));
        offList.add(new SelectOption('GB - Seascale, Cumbria - Sellafield Limited Sellafield','GB - Seascale, Cumbria - Sellafield Limited Sellafield'));
        offList.add(new SelectOption('GB - St Albans, HR - AECOM House 63-77 Victoria Street','GB - St Albans, HR - AECOM House 63-77 Victoria Street'));
        offList.add(new SelectOption('GB - Stafford -','GB - Stafford -'));
        offList.add(new SelectOption('GB - Stockton-on-Tees, NY - Cedar House 2nd Floor Building I','GB - Stockton-on-Tees, NY - Cedar House 2nd Floor Building I'));
        offList.add(new SelectOption('GB - Sutton Coldfield, West Midlands - URS Dio Headquaters K','GB - Sutton Coldfield, West Midlands - URS Dio Headquaters K'));
        offList.add(new SelectOption('GB - Swindon, XX - Tricentre 3 Newbridge Square','GB - Swindon, XX - Tricentre 3 Newbridge Square'));
        offList.add(new SelectOption('GB - Telford, XX - 3 Pemberton House Stafford Court Stafford','GB - Telford, XX - 3 Pemberton House Stafford Court Stafford'));
        offList.add(new SelectOption('GB - Thurso, Caithness, - Dounreay Site Restoration, Ltd (DS','GB - Thurso, Caithness, - Dounreay Site Restoration, Ltd (DS'));
        offList.add(new SelectOption('GB - Warminster, Wiltshire - DIO Warminster Land Warfare Cen','GB - Warminster, Wiltshire - DIO Warminster Land Warfare Cen'));
        offList.add(new SelectOption('GB - Warrington, CH - 1100 Daresbury Park','GB - Warrington, CH - 1100 Daresbury Park'));
        offList.add(new SelectOption('GB - Warrington, CH - Hinton House (Risley) Birchwood Park A','GB - Warrington, CH - Hinton House (Risley) Birchwood Park A'));
        offList.add(new SelectOption('GB - Warrington, CH - Washington House Birchwood Park Ave','GB - Warrington, CH - Washington House Birchwood Park Ave'));
        offList.add(new SelectOption('GB - Warrington, Cheshire - URS 401 Faraday St Birchwood Par','GB - Warrington, Cheshire - URS 401 Faraday St Birchwood Par'));
        offList.add(new SelectOption('GB - Warrington, Cheshire - Washington House Birchwood Park ','GB - Warrington, Cheshire - Washington House Birchwood Park '));
        offList.add(new SelectOption('GB - Warrington, Cheshire - Washington House Birchwood Part ','GB - Warrington, Cheshire - Washington House Birchwood Part '));
        offList.add(new SelectOption('GB - Warrington, XX - Washington House, Birchwood Park Avenu','GB - Warrington, XX - Washington House, Birchwood Park Avenu'));
        offList.add(new SelectOption('GB - York, XX - 16 Toft Green','GB - York, XX - 16 Toft Green'));
        offList.add(new SelectOption('GE - Poti Georgia, - 4th Floor Business Center Poti 50 Agmas','GE - Poti Georgia, - 4th Floor Business Center Poti 50 Agmas'));
        offList.add(new SelectOption('GE - Tbilisi - 34 Rustaveli Avenue','GE - Tbilisi - 34 Rustaveli Avenue'));
        offList.add(new SelectOption('GH - Accra - Limited F641/1 Otu Kofi Link','GH - Accra - Limited F641/1 Otu Kofi Link'));
        offList.add(new SelectOption('GR - , -','GR - , -'));
        offList.add(new SelectOption('GR - Athens - 47-49 Persefonis Street','GR - Athens - 47-49 Persefonis Street'));
        offList.add(new SelectOption('GR - Athens, XX - 227 Kifisias Avenue 14561','GR - Athens, XX - 227 Kifisias Avenue 14561'));
        offList.add(new SelectOption('GU - Santa Rita, - Bldg. 3110 (K1) U.S. Navy Base','GU - Santa Rita, - Bldg. 3110 (K1) U.S. Navy Base'));
        offList.add(new SelectOption('HK - , -','HK - , -'));
        offList.add(new SelectOption('HK - , - Body-shopping of Civil Engs and Tech Officers (Civi','HK - , - Body-shopping of Civil Engs and Tech Officers (Civi'));
        offList.add(new SelectOption('HK - , - Cycle Trks Connecting NW New Territories with NE Ne','HK - , - Cycle Trks Connecting NW New Territories with NE Ne'));
        offList.add(new SelectOption('HK - , - Detailed Design for MOL Modifications and Hin Keng ','HK - , - Detailed Design for MOL Modifications and Hin Keng '));
        offList.add(new SelectOption('HK - , - Hong Kong MP Office','HK - , - Hong Kong MP Office'));
        offList.add(new SelectOption('HK - , - Modern Terminals Lmtd Kwai Chung Contnr Terminals 2','HK - , - Modern Terminals Lmtd Kwai Chung Contnr Terminals 2'));
        offList.add(new SelectOption('HK - , - Outlying Isls Sewerage Stg 1 Phase 1 Pt2 and Phase2','HK - , - Outlying Isls Sewerage Stg 1 Phase 1 Pt2 and Phase2'));
        offList.add(new SelectOption('HK - , - Private Projects in BUG','HK - , - Private Projects in BUG'));
        offList.add(new SelectOption('HK - , - Private Projects in BUG (SLOPE)','HK - , - Private Projects in BUG (SLOPE)'));
        offList.add(new SelectOption('HK - , - Private Projects in BUI','HK - , - Private Projects in BUI'));
        offList.add(new SelectOption('HK - , - Private Projects in BUS','HK - , - Private Projects in BUS'));
        offList.add(new SelectOption('HK - , - Private Projects in BUS (HKHA) Private Projects in ','HK - , - Private Projects in BUS (HKHA) Private Projects in '));
        offList.add(new SelectOption('HK - , - Recon & Imprv & Rehab of Kai Tak River from Wong Ta','HK - , - Recon & Imprv & Rehab of Kai Tak River from Wong Ta'));
        offList.add(new SelectOption('HK - , - Recon & Imprv Kai Tak Nullah Choi Hung (Choi Hung R','HK - , - Recon & Imprv Kai Tak Nullah Choi Hung (Choi Hung R'));
        offList.add(new SelectOption('HK - , - Replacement & Rehb of Water Mains Stg 3 Mains in Ne','HK - , - Replacement & Rehb of Water Mains Stg 3 Mains in Ne'));
        offList.add(new SelectOption('HK - , - Site Formation for Kai Tak Cruise Terminal Developm','HK - , - Site Formation for Kai Tak Cruise Terminal Developm'));
        offList.add(new SelectOption('HK - Hong Kong, XX - Hong Kong Airport Auth','HK - Hong Kong, XX - Hong Kong Airport Auth'));
        offList.add(new SelectOption('HK - Honk Kong, XX - Modern Terminal 1 & 2 Quay Structures S','HK - Honk Kong, XX - Modern Terminal 1 & 2 Quay Structures S'));
        offList.add(new SelectOption('HK - Shatin - 10/F, Tower 2, Grand Central Plaza','HK - Shatin - 10/F, Tower 2, Grand Central Plaza'));
        offList.add(new SelectOption('HK - Shatin, N.T.','HK - Shatin, N.T.'));
        offList.add(new SelectOption('HR - Zagreb, 01 - Ivana Lucica 2a','HR - Zagreb, 01 - Ivana Lucica 2a'));
        offList.add(new SelectOption('HU - Budapest - Budafoki ut 209','HU - Budapest - Budafoki ut 209'));
        offList.add(new SelectOption('HU - Szentgotthárd, Vas - Füzesi út 15.','HU - Szentgotthárd, Vas - Füzesi út 15.'));
        offList.add(new SelectOption('ID - Jakarta Pusat - Ratu Plaza Building, 15th Floor','ID - Jakarta Pusat - Ratu Plaza Building, 15th Floor'));
        offList.add(new SelectOption('ID - Jakarta Pusat, XX - Jl. Kusuma Atmaja No. 75','ID - Jakarta Pusat, XX - Jl. Kusuma Atmaja No. 75'));
        offList.add(new SelectOption('ID - Jakarta Selatan - Recapital Building, 1st Floor','ID - Jakarta Selatan - Recapital Building, 1st Floor'));
        offList.add(new SelectOption('IE - Cork - Douglas Business Centre','IE - Cork - Douglas Business Centre'));
        offList.add(new SelectOption('IE - Dublin - 24 Lower Hatch Street','IE - Dublin - 24 Lower Hatch Street'));
        offList.add(new SelectOption('IE - Dublin - Adelphi Plaza','IE - Dublin - Adelphi Plaza'));
        offList.add(new SelectOption('IE - Dublin - Kingswood Drive','IE - Dublin - Kingswood Drive'));
        offList.add(new SelectOption('IE - Galway - Heritage Hall','IE - Galway - Heritage Hall'));
        offList.add(new SelectOption('IE - Limerick','IE - Limerick'));
        offList.add(new SelectOption('IN - , -','IN - , -'));
        offList.add(new SelectOption('IN - , - House No. 65, Sector-7, Channi Housing Colony Opp,','IN - , - House No. 65, Sector-7, Channi Housing Colony Opp,'));
        offList.add(new SelectOption('IN - , - India Location','IN - , - India Location'));
        offList.add(new SelectOption('IN - Agra, UP -','IN - Agra, UP -'));
        offList.add(new SelectOption('IN - AJMER - ANA SAGAR ROAD','IN - AJMER - ANA SAGAR ROAD'));
        offList.add(new SelectOption('IN - Almora - 1st Floor, Uday Milan','IN - Almora - 1st Floor, Uday Milan'));
        offList.add(new SelectOption('IN - Assam - H/o Harprasad Ghosh','IN - Assam - H/o Harprasad Ghosh'));
        offList.add(new SelectOption('IN - Assam - Jiribam Tupul Railway Line Project T1','IN - Assam - Jiribam Tupul Railway Line Project T1'));
        offList.add(new SelectOption('IN - Aurangabad, MH - G1 Additional Shendra','IN - Aurangabad, MH - G1 Additional Shendra'));
        offList.add(new SelectOption('IN - Bag Sewaniya, Bhopal, XX - Rail Viksa Nigam Limited A-1','IN - Bag Sewaniya, Bhopal, XX - Rail Viksa Nigam Limited A-1'));
        offList.add(new SelectOption('IN - Baharampore, WB -','IN - Baharampore, WB -'));
        offList.add(new SelectOption('IN - Bangalore, KA -','IN - Bangalore, KA -'));
        offList.add(new SelectOption('IN - Bangalore, Mittal Tower','IN - Bangalore, Mittal Tower'));
        offList.add(new SelectOption('IN - Bharatpur, RJ -','IN - Bharatpur, RJ -'));
        offList.add(new SelectOption('IN - Bihar - Manoma Public School','IN - Bihar - Manoma Public School'));
        offList.add(new SelectOption('IN - Chennai - 5/F Khivraj Building II','IN - Chennai - 5/F Khivraj Building II'));
        offList.add(new SelectOption('IN - Chennai, Apex Towers','IN - Chennai, Apex Towers'));
        offList.add(new SelectOption('IN - Chennai, TN -','IN - Chennai, TN -'));
        offList.add(new SelectOption('IN - Dehradun - Uttarakhand Tourism','IN - Dehradun - Uttarakhand Tourism'));
        offList.add(new SelectOption('IN - District Hoogly Westbengal, XX - Tarakeshwar Baidyabadt','IN - District Hoogly Westbengal, XX - Tarakeshwar Baidyabadt'));
        offList.add(new SelectOption('IN - Faridabad, HR -','IN - Faridabad, HR -'));
        offList.add(new SelectOption('IN - GANDHINAGAR - 3rd Floor, Udyog Bhavan','IN - GANDHINAGAR - 3rd Floor, Udyog Bhavan'));
        offList.add(new SelectOption('IN - GANDHINAGAR - 6th Floor, Udyog Bhavan','IN - GANDHINAGAR - 6th Floor, Udyog Bhavan'));
        offList.add(new SelectOption('IN - Gandhinagar, Vijayawada, XX - Rail Vikas Nigam Lmtd Doo','IN - Gandhinagar, Vijayawada, XX - Rail Vikas Nigam Lmtd Doo'));
        offList.add(new SelectOption('IN - Gurgaon - 19/F, Tower C Building 5, Cyber Terraces','IN - Gurgaon - 19/F, Tower C Building 5, Cyber Terraces'));
        offList.add(new SelectOption('IN - Gurgaon - 3rd floor, DLF Cyber City','IN - Gurgaon - 3rd floor, DLF Cyber City'));
        offList.add(new SelectOption('IN - Gurgaon - 5/F, Building No-10, DLF Cyber City','IN - Gurgaon - 5/F, Building No-10, DLF Cyber City'));
        offList.add(new SelectOption('IN - Gurgaon - 9th Floor, Infinity Tower C','IN - Gurgaon - 9th Floor, Infinity Tower C'));
        offList.add(new SelectOption('IN - Gurgaon - HUDA DLF Sector, Sector 42','IN - Gurgaon - HUDA DLF Sector, Sector 42'));
        offList.add(new SelectOption('IN - Gurgaon - P81, DLF Site','IN - Gurgaon - P81, DLF Site'));
        offList.add(new SelectOption('IN - Gurgaon - P86, DLF Site','IN - Gurgaon - P86, DLF Site'));
        offList.add(new SelectOption('IN - Gurgaon, HR -','IN - Gurgaon, HR -'));
        offList.add(new SelectOption('IN - Guwahati - Goswami Bhawan','IN - Guwahati - Goswami Bhawan'));
        offList.add(new SelectOption('IN - Guwahati, AS -','IN - Guwahati, AS -'));
        offList.add(new SelectOption('IN - Hamirpur - 218, Asthakanwal Complex','IN - Hamirpur - 218, Asthakanwal Complex'));
        offList.add(new SelectOption('IN - Haryana - Sec 82A Vill - Shikopur','IN - Haryana - Sec 82A Vill - Shikopur'));
        offList.add(new SelectOption('IN - Haryana - Sector - 90 - DLF Regal Garden','IN - Haryana - Sector - 90 - DLF Regal Garden'));
        offList.add(new SelectOption('IN - Hyderabad, 2nd Floor, House No 8-202','IN - Hyderabad, 2nd Floor, House No 8-202'));
        offList.add(new SelectOption('IN - Hyderabad, AP -','IN - Hyderabad, AP -'));
        offList.add(new SelectOption('IN - Hyderabad, Hi-Tech City','IN - Hyderabad, Hi-Tech City'));
        offList.add(new SelectOption('IN - Indore, MP -','IN - Indore, MP -'));
        offList.add(new SelectOption('IN - Jabalpur, MP -','IN - Jabalpur, MP -'));
        offList.add(new SelectOption('IN - Jodhpur, RJ -','IN - Jodhpur, RJ -'));
        offList.add(new SelectOption('IN - Kannur Site, Kerala','IN - Kannur Site, Kerala'));
        offList.add(new SelectOption('IN - Kanpur (UP), XX - 870/79 Ram Puram Daheli Sujanpur','IN - Kanpur (UP), XX - 870/79 Ram Puram Daheli Sujanpur'));
        offList.add(new SelectOption('IN - Karanataka - C/o Nagashree Building','IN - Karanataka - C/o Nagashree Building'));
        offList.add(new SelectOption('IN - Kolkata - 1st floor, DLF IT park -1','IN - Kolkata - 1st floor, DLF IT park -1'));
        offList.add(new SelectOption('IN - Kolkata, WB -','IN - Kolkata, WB -'));
        offList.add(new SelectOption('IN - Kota, RJ -','IN - Kota, RJ -'));
        offList.add(new SelectOption('IN - Lucknow, UP -','IN - Lucknow, UP -'));
        offList.add(new SelectOption('IN - Malda, WB -','IN - Malda, WB -'));
        offList.add(new SelectOption('IN - Malpura Jaipur, RJ -','IN - Malpura Jaipur, RJ -'));
        offList.add(new SelectOption('IN - Mangalore, KA -','IN - Mangalore, KA -'));
        offList.add(new SelectOption('IN - Manipur - 1st Floor, Food World Building','IN - Manipur - 1st Floor, Food World Building'));
        offList.add(new SelectOption('IN - Mathura, UP -','IN - Mathura, UP -'));
        offList.add(new SelectOption('IN - Meghalaya - Holy Cross Hospital Road','IN - Meghalaya - Holy Cross Hospital Road'));
        offList.add(new SelectOption('IN - Mumbai, Times Square','IN - Mumbai, Times Square'));
        offList.add(new SelectOption('IN - Nagaon, AS -','IN - Nagaon, AS -'));
        offList.add(new SelectOption('IN - New Delhi, DL - A-26/44 Mohan Co-op Ind Es Mathura Road','IN - New Delhi, DL - A-26/44 Mohan Co-op Ind Es Mathura Road'));
        offList.add(new SelectOption('IN - Noida - Sec 32 A, Wave City Centre','IN - Noida - Sec 32 A, Wave City Centre'));
        offList.add(new SelectOption('IN - Noida, A-197, Sector-63','IN - Noida, A-197, Sector-63'));
        offList.add(new SelectOption('IN - Odisha - 1B/27, L&T Construction','IN - Odisha - 1B/27, L&T Construction'));
        offList.add(new SelectOption('IN - Panchkula, HR -','IN - Panchkula, HR -'));
        offList.add(new SelectOption('IN - Patna, BR -','IN - Patna, BR -'));
        offList.add(new SelectOption('IN - Patna, Personi Plaza','IN - Patna, Personi Plaza'));
        offList.add(new SelectOption('IN - Pune, MH -','IN - Pune, MH -'));
        offList.add(new SelectOption('IN - Pune, Pride Portal Building','IN - Pune, Pride Portal Building'));
        offList.add(new SelectOption('IN - Raiganj, WB -','IN - Raiganj, WB -'));
        offList.add(new SelectOption('IN - Raipur, CT -','IN - Raipur, CT -'));
        offList.add(new SelectOption('IN - Rajahmundry, AP -','IN - Rajahmundry, AP -'));
        offList.add(new SelectOption('IN - Rohtak, HR -','IN - Rohtak, HR -'));
        offList.add(new SelectOption('IN - Sanand, GJ -','IN - Sanand, GJ -'));
        offList.add(new SelectOption('IN - Sikar, RJ -','IN - Sikar, RJ -'));
        offList.add(new SelectOption('IN - Sittwe, -','IN - Sittwe, -'));
        offList.add(new SelectOption('IN - South 24 Pgs., XX - Vill + P.O. Dahkin Raipur Jana Para','IN - South 24 Pgs., XX - Vill + P.O. Dahkin Raipur Jana Para'));
        offList.add(new SelectOption('IN - Tinsukia - Bordoloi Nagar','IN - Tinsukia - Bordoloi Nagar'));
        offList.add(new SelectOption('IN - Titlagarh, CT -','IN - Titlagarh, CT -'));
        offList.add(new SelectOption('IN - Uttarakhand - 2nd Floor, C/O Tejinder Singh','IN - Uttarakhand - 2nd Floor, C/O Tejinder Singh'));
        offList.add(new SelectOption('IN - Uttarakhand - CSC2, Hotel View King','IN - Uttarakhand - CSC2, Hotel View King'));
        offList.add(new SelectOption('IR - Baghdad, BG - US Embassy Baghdad c/o URS/AECOM Baghdad ','IR - Baghdad, BG - US Embassy Baghdad c/o URS/AECOM Baghdad '));
        offList.add(new SelectOption('IR - Baghdad, XX - CPA PMO APO AE 09348','IR - Baghdad, XX - CPA PMO APO AE 09348'));
        offList.add(new SelectOption('IR - Camp Liberty, Baghdad, XX - R4 Incorporated Class IV Ya','IR - Camp Liberty, Baghdad, XX - R4 Incorporated Class IV Ya'));
        offList.add(new SelectOption('IR - Cork, XX - Douglas Business Center Carrigaline Road','IR - Cork, XX - Douglas Business Center Carrigaline Road'));
        offList.add(new SelectOption('IR - Dublin 2, XX - Second Floor 50 City Quay','IR - Dublin 2, XX - Second Floor 50 City Quay'));
        offList.add(new SelectOption('IR - Sandyford Dublin, DU - Units 410 & 411 - Q House 76 Fur','IR - Sandyford Dublin, DU - Units 410 & 411 - Q House 76 Fur'));
        offList.add(new SelectOption('IT - Catania, Sicily, XX - US Naval Hospital Sgonella Attn M','IT - Catania, Sicily, XX - US Naval Hospital Sgonella Attn M'));
        offList.add(new SelectOption('IT - CE Naples, - US Naval Hospital Naples US Support Site L','IT - CE Naples, - US Naval Hospital Naples US Support Site L'));
        offList.add(new SelectOption('IT - Milan - Via Francesco Ferrucci 17/A','IT - Milan - Via Francesco Ferrucci 17/A'));
        offList.add(new SelectOption('IT - Milan, XX - Via Watt, 27','IT - Milan, XX - Via Watt, 27'));
        offList.add(new SelectOption('IT - Pescara - Via Di Sotto 123/2','IT - Pescara - Via Di Sotto 123/2'));
        offList.add(new SelectOption('JA - Mandeville, Manchester - Albion District Mandeville P.O','JA - Mandeville, Manchester - Albion District Mandeville P.O'));
        offList.add(new SelectOption('JP - , - URS','JP - , - URS'));
        offList.add(new SelectOption('JP - Chatan Cho Okinawa, - USNH Camp Lester Camp Lester Bldg','JP - Chatan Cho Okinawa, - USNH Camp Lester Camp Lester Bldg'));
        offList.add(new SelectOption('JP - JPN -','JP - JPN -'));
        offList.add(new SelectOption('JP - Kandena, 47 - LSI Rep: Sgt Craig West/Wing Avionics Mg ','JP - Kandena, 47 - LSI Rep: Sgt Craig West/Wing Avionics Mg '));
        offList.add(new SelectOption('JP - Okinawa, XX - Joint Material Mgmt Svcs - JEMMS Bldg 501','JP - Okinawa, XX - Joint Material Mgmt Svcs - JEMMS Bldg 501'));
        offList.add(new SelectOption('JP - Tokyo - Kojimachi Square Plaza','JP - Tokyo - Kojimachi Square Plaza'));
        offList.add(new SelectOption('JP - Yokohama City, XX - 168-1 Yamashita-cho Naka-ku Yokoham','JP - Yokohama City, XX - 168-1 Yamashita-cho Naka-ku Yokoham'));
        offList.add(new SelectOption('JP - Yokosuka, Japan, XX - USNH Yokosuka Honcho 1 Chome Bldg','JP - Yokosuka, Japan, XX - USNH Yokosuka Honcho 1 Chome Bldg'));
        offList.add(new SelectOption('KE - Nairobi - Dale House, Rhapta Rd','KE - Nairobi - Dale House, Rhapta Rd'));
        offList.add(new SelectOption('KG - Bishek, - 52-54 Orozbekova Street 3rd Floor','KG - Bishek, - 52-54 Orozbekova Street 3rd Floor'));
        offList.add(new SelectOption('KH - Cambodia, -','KH - Cambodia, -'));
        offList.add(new SelectOption('KO - Apo Ap, XX - BR SARSSI, Building 1646, Camp Humphre Uni','KO - Apo Ap, XX - BR SARSSI, Building 1646, Camp Humphre Uni'));
        offList.add(new SelectOption('KO - APO, - MSCO-K, Pier 8, Busan, South Korea Unite 15175','KO - APO, - MSCO-K, Pier 8, Busan, South Korea Unite 15175'));
        offList.add(new SelectOption('KO - Seoul, Korea, XX - 18th Medcom US Army Unit 15281 Bldg ','KO - Seoul, Korea, XX - 18th Medcom US Army Unit 15281 Bldg '));
        offList.add(new SelectOption('KSA - Al Khobar, SA - Al Khereji Business Center','KSA - Al Khobar, SA - Al Khereji Business Center'));
        offList.add(new SelectOption('KSA - Jeddah, SA - Bin Sulaiman Center','KSA - Jeddah, SA - Bin Sulaiman Center'));
        offList.add(new SelectOption('KSA - Riyadh, SA - Tatweer Building','KSA - Riyadh, SA - Tatweer Building'));
        offList.add(new SelectOption('KW - , - URS','KW - , - URS'));
        offList.add(new SelectOption('KW - Kuwait, KW - Nafisi Building','KW - Kuwait, KW - Nafisi Building'));
        offList.add(new SelectOption('KZ - Almaty - 134 Dostyk Ave','KZ - Almaty - 134 Dostyk Ave'));
        offList.add(new SelectOption('LK - Battaramulla, Sri Lanka, - URS Scott Wilson India Pvt L','LK - Battaramulla, Sri Lanka, - URS Scott Wilson India Pvt L'));
        offList.add(new SelectOption('LK - Colombo - 51/4A Ward Place','LK - Colombo - 51/4A Ward Place'));
        offList.add(new SelectOption('LT - , -','LT - , -'));
        offList.add(new SelectOption('LV - Riga - Kr. Barona iela 36-4','LV - Riga - Kr. Barona iela 36-4'));
        offList.add(new SelectOption('MD - Chisinau, CU - 63 Vlaicu Pircalab St','MD - Chisinau, CU - 63 Vlaicu Pircalab St'));
        offList.add(new SelectOption('ME - Mexico D.F., XX - Anatole France No. 311 Colonia Polanc','ME - Mexico D.F., XX - Anatole France No. 311 Colonia Polanc'));
        offList.add(new SelectOption('ME - Veracruz, MEX -','ME - Veracruz, MEX -'));
        offList.add(new SelectOption('MN - Ulaanbaatar, - Chingeltei District 4th Koroo','MN - Ulaanbaatar, - Chingeltei District 4th Koroo'));
        offList.add(new SelectOption('MY - , -','MY - , -'));
        offList.add(new SelectOption('MY - Johor Bahru','MY - Johor Bahru'));
        offList.add(new SelectOption('MY - Kuala Lumpur - 18-6, Blk B, 18th Fl, Megan Ave II','MY - Kuala Lumpur - 18-6, Blk B, 18th Fl, Megan Ave II'));
        offList.add(new SelectOption('MY - Kuching','MY - Kuching'));
        offList.add(new SelectOption('MY - Penang','MY - Penang'));
        offList.add(new SelectOption('MY - Petaling Jaya - Level 2A, Tower Block Menara Batu Kawan','MY - Petaling Jaya - Level 2A, Tower Block Menara Batu Kawan'));
        offList.add(new SelectOption('MZ - Maputo - Rua de Argelia','MZ - Maputo - Rua de Argelia'));
        offList.add(new SelectOption('NG - Lagos - 51 Agodoga Ave','NG - Lagos - 51 Agodoga Ave'));
        offList.add(new SelectOption('NL - Amsterdam - Herengracht 124','NL - Amsterdam - Herengracht 124'));
        offList.add(new SelectOption('NL - Rotterdam - Rivium Boulevard 301','NL - Rotterdam - Rivium Boulevard 301'));
        offList.add(new SelectOption('NL - Rotterdam, XX - Airportplein 22-R Cornerstone Bldg 1st ','NL - Rotterdam, XX - Airportplein 22-R Cornerstone Bldg 1st '));
        offList.add(new SelectOption('NO - Oslo, 03 - Nydalsveien 33','NO - Oslo, 03 - Nydalsveien 33'));
        offList.add(new SelectOption('NZ - Auckland','NZ - Auckland'));
        offList.add(new SelectOption('NZ - Christchurch','NZ - Christchurch'));
        offList.add(new SelectOption('NZ - Hamilton','NZ - Hamilton'));
        offList.add(new SelectOption('NZ - Ponsonby, XX - URS Centre, 6th Floor 13-15 College Hill','NZ - Ponsonby, XX - URS Centre, 6th Floor 13-15 College Hill'));
        offList.add(new SelectOption('NZ - Tauranga','NZ - Tauranga'));
        offList.add(new SelectOption('NZ - Wellington','NZ - Wellington'));
        offList.add(new SelectOption('OM - Muscat, OM - Al Khuwair','OM - Muscat, OM - Al Khuwair'));
        offList.add(new SelectOption('PA - Panama City, XX - Piso 15, Oficina 3 Calle 54 Torre Gen','PA - Panama City, XX - Piso 15, Oficina 3 Calle 54 Torre Gen'));
        offList.add(new SelectOption('PH - Taguig City - 23rd Floor, Fort Legend Tower','PH - Taguig City - 23rd Floor, Fort Legend Tower'));
        offList.add(new SelectOption('PL - Kraków - BP Europa SE','PL - Kraków - BP Europa SE'));
        offList.add(new SelectOption('PL - Lublin - Ul. Leśna 38','PL - Lublin - Ul. Leśna 38'));
        offList.add(new SelectOption('PL - Sopot - Al. Niepodległości 606/610','PL - Sopot - Al. Niepodległości 606/610'));
        offList.add(new SelectOption('PL - Warsaw - Warsaw Ambassador Office Building','PL - Warsaw - Warsaw Ambassador Office Building'));
        offList.add(new SelectOption('PN - , -','PN - , -'));
        offList.add(new SelectOption('PN - Boroko, - 2nd Floor, Brian Bell Plaza, Turumu St','PN - Boroko, - 2nd Floor, Brian Bell Plaza, Turumu St'));
        offList.add(new SelectOption('PO - , -','PO - , -'));
        offList.add(new SelectOption('PO - Krakow, XX - 78 Aleja Pokoju Street','PO - Krakow, XX - 78 Aleja Pokoju Street'));
        offList.add(new SelectOption('PO - Wroclaw, XX - 123 Klecinska Street','PO - Wroclaw, XX - 123 Klecinska Street'));
        offList.add(new SelectOption('QA - Doha, QA - Jaidah Square','QA - Doha, QA - Jaidah Square'));
        offList.add(new SelectOption('QA - Doha, QA - West Bay Office','QA - Doha, QA - West Bay Office'));
        offList.add(new SelectOption('QA - Doha, XX - PO Box 22108','QA - Doha, XX - PO Box 22108'));
        offList.add(new SelectOption('RO - Bucharest - 68-72 Polona St','RO - Bucharest - 68-72 Polona St'));
        offList.add(new SelectOption('RO - Bucharest, - 9-9A Dimitire Pompei Blvd','RO - Bucharest, - 9-9A Dimitire Pompei Blvd'));
        offList.add(new SelectOption('RO - Voluntari, IF, ROU - Sos. Pipera nr 2/II, North Center,','RO - Voluntari, IF, ROU - Sos. Pipera nr 2/II, North Center,'));
        offList.add(new SelectOption('RU - Moscow - 29 Serebryanicheskaya nab','RU - Moscow - 29 Serebryanicheskaya nab'));
        offList.add(new SelectOption('RU - Moscow - Bovis Lend Lease International Ltd','RU - Moscow - Bovis Lend Lease International Ltd'));
        offList.add(new SelectOption('RU - Moscow Russia, - Ducat Place II 7 Gasheka Street','RU - Moscow Russia, - Ducat Place II 7 Gasheka Street'));
        offList.add(new SelectOption('RU - Saint-Petersburg - Bovis Lend Lease, 30 Bolshaya','RU - Saint-Petersburg - Bovis Lend Lease, 30 Bolshaya'));
        offList.add(new SelectOption('RU - Saint-Petersburg - Office 701/1','RU - Saint-Petersburg - Office 701/1'));
        offList.add(new SelectOption('SA - , - URS Overseas Site','SA - , - URS Overseas Site'));
        offList.add(new SelectOption('SA - Riyadh, XX - 614 Olaya Akharia II P.O. Box 2384','SA - Riyadh, XX - 614 Olaya Akharia II P.O. Box 2384'));
        offList.add(new SelectOption('SG - 865 Mountbatten Road','SG - 865 Mountbatten Road'));
        offList.add(new SelectOption('SG - SGP -','SG - SGP -'));
        offList.add(new SelectOption('SG - Singapore, - Deptford Road','SG - Singapore, - Deptford Road'));
        offList.add(new SelectOption('SG - The Concourse','SG - The Concourse'));
        offList.add(new SelectOption('SL - Honiara City, CT - 1st Fl, City Centre Build, Mendara A','SL - Honiara City, CT - 1st Fl, City Centre Build, Mendara A'));
        offList.add(new SelectOption('SV - Ruzomberok, XX - Slovakia Office','SV - Ruzomberok, XX - Slovakia Office'));
        offList.add(new SelectOption('SW - 171 68 Solna, XX - Hannebergsgatan 33','SW - 171 68 Solna, XX - Hannebergsgatan 33'));
        offList.add(new SelectOption('TH - , - URS','TH - , - URS'));
        offList.add(new SelectOption('TH - Bangkok - 53 Sivatel Tower 9 Floor','TH - Bangkok - 53 Sivatel Tower 9 Floor'));
        offList.add(new SelectOption('TR - Ankara - Mustafa Kemal Mah. Dumlupınar Bulvari','TR - Ankara - Mustafa Kemal Mah. Dumlupınar Bulvari'));
        offList.add(new SelectOption('TR - Istanbul - Buyukdere Cad Harman Sokak','TR - Istanbul - Buyukdere Cad Harman Sokak'));
        offList.add(new SelectOption('TW - Kaohsiung City','TW - Kaohsiung City'));
        offList.add(new SelectOption('TW - New Taipei City','TW - New Taipei City'));
        offList.add(new SelectOption('TW - Taipei - 16F, Shin Kong Manhattan Building','TW - Taipei - 16F, Shin Kong Manhattan Building'));
        offList.add(new SelectOption('TW - TWN -','TW - TWN -'));
        offList.add(new SelectOption('UA - Kiev - Horizon Business Park','UA - Kiev - Horizon Business Park'));
        offList.add(new SelectOption('UG - Kampala - 1207 Ggaba Rd','UG - Kampala - 1207 Ggaba Rd'));
        offList.add(new SelectOption('UK - Aberdeen','UK - Aberdeen'));
        offList.add(new SelectOption('UK - Altrincham','UK - Altrincham'));
        offList.add(new SelectOption('UK - Ashford','UK - Ashford'));
        offList.add(new SelectOption('UK - Barnsley - Wentworth Business Park','UK - Barnsley - Wentworth Business Park'));
        offList.add(new SelectOption('UK - Basingstoke','UK - Basingstoke'));
        offList.add(new SelectOption('UK - Bedford','UK - Bedford'));
        offList.add(new SelectOption('UK - Belfast','UK - Belfast'));
        offList.add(new SelectOption('UK - Belfast - Beechill','UK - Belfast - Beechill'));
        offList.add(new SelectOption('UK - Birmingham - Colmore Plaza','UK - Birmingham - Colmore Plaza'));
        offList.add(new SelectOption('UK - Birmingham - Victoria Square','UK - Birmingham - Victoria Square'));
        offList.add(new SelectOption('UK - Bristol','UK - Bristol'));
        offList.add(new SelectOption('UK - Cambridge - 36 Storey\'s Way','UK - Cambridge - 36 Storey\'s Way'));
        offList.add(new SelectOption('UK - Cardiff','UK - Cardiff'));
        offList.add(new SelectOption('UK - Chelmsford','UK - Chelmsford'));
        offList.add(new SelectOption('UK - Croydon - Bedford Park','UK - Croydon - Bedford Park'));
        offList.add(new SelectOption('UK - East Malling','UK - East Malling'));
        offList.add(new SelectOption('UK - Edinburgh - Apex','UK - Edinburgh - Apex'));
        offList.add(new SelectOption('UK - Edinburgh - Tanfield','UK - Edinburgh - Tanfield'));
        offList.add(new SelectOption('UK - Exeter','UK - Exeter'));
        offList.add(new SelectOption('UK - Glasgow','UK - Glasgow'));
        offList.add(new SelectOption('UK - Glasgow - 120 Bothwell Street','UK - Glasgow - 120 Bothwell Street'));
        offList.add(new SelectOption('UK - Kiev, - Building 43V Office 16','UK - Kiev, - Building 43V Office 16'));
        offList.add(new SelectOption('UK - Leeds','UK - Leeds'));
        offList.add(new SelectOption('UK - Leeds - Livingstone House','UK - Leeds - Livingstone House'));
        offList.add(new SelectOption('UK - Liverpool','UK - Liverpool'));
        offList.add(new SelectOption('UK - London - Acton','UK - London - Acton'));
        offList.add(new SelectOption('UK - London - MidCity Place','UK - London - MidCity Place'));
        offList.add(new SelectOption('UK - London - Victoria','UK - London - Victoria'));
        offList.add(new SelectOption('UK - London Greencoat Place','UK - London Greencoat Place'));
        offList.add(new SelectOption('UK - Maidstone','UK - Maidstone'));
        offList.add(new SelectOption('UK - Manchester - 1 New York Street','UK - Manchester - 1 New York Street'));
        offList.add(new SelectOption('UK - Newcastle-upon-Tyne','UK - Newcastle-upon-Tyne'));
        offList.add(new SelectOption('UK - Newry - Old Gasworks Business Park','UK - Newry - Old Gasworks Business Park'));
        offList.add(new SelectOption('UK - Norwich','UK - Norwich'));
        offList.add(new SelectOption('UK - Norwich - 3 St James Court','UK - Norwich - 3 St James Court'));
        offList.add(new SelectOption('UK - Nottingham','UK - Nottingham'));
        offList.add(new SelectOption('UK - Oxford - Avalon House','UK - Oxford - Avalon House'));
        offList.add(new SelectOption('UK - Pavlograd, - 71 Schevchenko Street','UK - Pavlograd, - 71 Schevchenko Street'));
        offList.add(new SelectOption('UK - Peterborough - Clarence House','UK - Peterborough - Clarence House'));
        offList.add(new SelectOption('UK - Southampton','UK - Southampton'));
        offList.add(new SelectOption('UK - St. Albans','UK - St. Albans'));
        offList.add(new SelectOption('UK - Tankersley - Wentworth Business Park','UK - Tankersley - Wentworth Business Park'));
        offList.add(new SelectOption('UK - York - 16 Toft Green','UK - York - 16 Toft Green'));
        offList.add(new SelectOption('US - 1 Stennis Space Center of NASA - Stennis Space Center','US - 1 Stennis Space Center of NASA - Stennis Space Center'));
        offList.add(new SelectOption('US - Aberdeen Proving Ground, MD - 6200 Guardian Gateway, Su','US - Aberdeen Proving Ground, MD - 6200 Guardian Gateway, Su'));
        offList.add(new SelectOption('US - Aberdeen Proving Grounds, MD - Aviaton Army Support Fac','US - Aberdeen Proving Grounds, MD - Aviaton Army Support Fac'));
        offList.add(new SelectOption('US - Aberdeen, MD - URS C/O Rite Aid 601 Chelsea Road','US - Aberdeen, MD - URS C/O Rite Aid 601 Chelsea Road'));
        offList.add(new SelectOption('US - Abilene, TX - 7th Medical Group 697 Louisiana Rd','US - Abilene, TX - 7th Medical Group 697 Louisiana Rd'));
        offList.add(new SelectOption('US - Abingdon, MD - 1309 Continental Drive Suite R','US - Abingdon, MD - 1309 Continental Drive Suite R'));
        offList.add(new SelectOption('US - Abu Dhabi, UAE - Al Jazira Sports Club','US - Abu Dhabi, UAE - Al Jazira Sports Club'));
        offList.add(new SelectOption('US - Acton, MA - 7 Whittier Dr','US - Acton, MA - 7 Whittier Dr'));
        offList.add(new SelectOption('US - Adams, NY - 9262 Swan Road','US - Adams, NY - 9262 Swan Road'));
        offList.add(new SelectOption('US - Addison, TX - URS 16051 Addison Road Suite 220','US - Addison, TX - URS 16051 Addison Road Suite 220'));
        offList.add(new SelectOption('US - Afghanistan','US - Afghanistan'));
        offList.add(new SelectOption('US - AIKEN, SC - 106 Newberry Street, SW','US - AIKEN, SC - 106 Newberry Street, SW'));
        offList.add(new SelectOption('US - AIKEN, SC - 2131 S. Centennial Drive','US - AIKEN, SC - 2131 S. Centennial Drive'));
        offList.add(new SelectOption('US - AIKEN, SC - 2310 S. Centennial Drive','US - AIKEN, SC - 2310 S. Centennial Drive'));
        offList.add(new SelectOption('US - Aiken, SC - URS 1019 Kismet Drive','US - Aiken, SC - URS 1019 Kismet Drive'));
        offList.add(new SelectOption('US - Aiken, SC - URS Savannah River Project Bldg 717 - 5n, 1','US - Aiken, SC - URS Savannah River Project Bldg 717 - 5n, 1'));
        offList.add(new SelectOption('US - Aiken, SC - URS Savannah River Site Building 717 5n','US - Aiken, SC - URS Savannah River Site Building 717 5n'));
        offList.add(new SelectOption('US - Aiken, SC - URS Urs Safety Management Solutions 2131 S ','US - Aiken, SC - URS Urs Safety Management Solutions 2131 S '));
        offList.add(new SelectOption('US - Akron, OH - 564 White Pond Drive','US - Akron, OH - 564 White Pond Drive'));
        offList.add(new SelectOption('US - Akron, OH - URS 2460 Penninsula Rd','US - Akron, OH - URS 2460 Penninsula Rd'));
        offList.add(new SelectOption('US - Alabama - Telecommute','US - Alabama - Telecommute'));
        offList.add(new SelectOption('US - Alaska - Telecommute','US - Alaska - Telecommute'));
        offList.add(new SelectOption('US - Albany, GA - 814 Radford Blvd, Ste 20325','US - Albany, GA - 814 Radford Blvd, Ste 20325'));
        offList.add(new SelectOption('US - ALBANY, OR - 1450 Queen Avenue SW','US - ALBANY, OR - 1450 Queen Avenue SW'));
        offList.add(new SelectOption('US - Albany, OR - URS 1450 Queen Avenue Sw','US - Albany, OR - URS 1450 Queen Avenue Sw'));
        offList.add(new SelectOption('US - Albuquerque, NM - 201 Third St NW','US - Albuquerque, NM - 201 Third St NW'));
        offList.add(new SelectOption('US - Albuquerque, NM - 2420 Comanche NE Suite D-6','US - Albuquerque, NM - 2420 Comanche NE Suite D-6'));
        offList.add(new SelectOption('US - Albuquerque, NM - 6501 Americas Parkway NE','US - Albuquerque, NM - 6501 Americas Parkway NE'));
        offList.add(new SelectOption('US - Albuquerque, NM - 6501 Americas Parkway, NE Suite 900','US - Albuquerque, NM - 6501 Americas Parkway, NE Suite 900'));
        offList.add(new SelectOption('US - Albuquerque, NM - New Mexico ANG Kirtland AFB, Bldg 105','US - Albuquerque, NM - New Mexico ANG Kirtland AFB, Bldg 105'));
        offList.add(new SelectOption('US - Albuquerque, NM - One Park Square 6501 Americas Parkway','US - Albuquerque, NM - One Park Square 6501 Americas Parkway'));
        offList.add(new SelectOption('US - Albuquerque, NM - URS 201 3rd Street Northwest #600','US - Albuquerque, NM - URS 201 3rd Street Northwest #600'));
        offList.add(new SelectOption('US - Albuquerque, NM - URS 7415 Sandia Glow Ct Ne','US - Albuquerque, NM - URS 7415 Sandia Glow Ct Ne'));
        offList.add(new SelectOption('US - Alexandria, Egypt','US - Alexandria, Egypt'));
        offList.add(new SelectOption('US - Alexandria, VA - 6440 General Green Way','US - Alexandria, VA - 6440 General Green Way'));
        offList.add(new SelectOption('US - Alexandria, VA - 675 N Washington St','US - Alexandria, VA - 675 N Washington St'));
        offList.add(new SelectOption('US - Almaty, Kazakhstan - 12/24 Dostyk-Kazaybek Bi St','US - Almaty, Kazakhstan - 12/24 Dostyk-Kazaybek Bi St'));
        offList.add(new SelectOption('US - Altoona, FL - 18510 NFS 524, Bldg C','US - Altoona, FL - 18510 NFS 524, Bldg C'));
        offList.add(new SelectOption('US - Amman, Jordan','US - Amman, Jordan'));
        offList.add(new SelectOption('US - Anaheim, CA - 1585 South Manchester Avenue','US - Anaheim, CA - 1585 South Manchester Avenue'));
        offList.add(new SelectOption('US - Anaheim, CA - 160 North Riverview Drive','US - Anaheim, CA - 160 North Riverview Drive'));
        offList.add(new SelectOption('US - Anchorage, AK - 620 E 10Th Avenue','US - Anchorage, AK - 620 E 10Th Avenue'));
        offList.add(new SelectOption('US - Anchorage, AK - 700 G Street','US - Anchorage, AK - 700 G Street'));
        offList.add(new SelectOption('US - Anchorage, AK - 700 G Street Suite 500','US - Anchorage, AK - 700 G Street Suite 500'));
        offList.add(new SelectOption('US - Anchorage, AK - 700 G Street, Suite 500 Sos. Pipera nr ','US - Anchorage, AK - 700 G Street, Suite 500 Sos. Pipera nr '));
        offList.add(new SelectOption('US - Anchorage, AK - URS 700 G. Street Suite #500','US - Anchorage, AK - URS 700 G. Street Suite #500'));
        offList.add(new SelectOption('US - Andover, MA - 310 Lowell Street Mail Stop 214','US - Andover, MA - 310 Lowell Street Mail Stop 214'));
        offList.add(new SelectOption('US - Annapolis Junction, MD - 2720 Technology Drive','US - Annapolis Junction, MD - 2720 Technology Drive'));
        offList.add(new SelectOption('US - Annapolis Junction, MD - 430 National Business Parkway','US - Annapolis Junction, MD - 430 National Business Parkway'));
        offList.add(new SelectOption('US - Annapolis Junction, MD - 430 National Business Parkway ','US - Annapolis Junction, MD - 430 National Business Parkway '));
        offList.add(new SelectOption('US - Annapolis Junction, MD - 430 National Business Parkway,','US - Annapolis Junction, MD - 430 National Business Parkway,'));
        offList.add(new SelectOption('US - Annapolis Junction, MD - URS 2720 Technology Dr. Suite ','US - Annapolis Junction, MD - URS 2720 Technology Dr. Suite '));
        offList.add(new SelectOption('US - Annapolis, MD - 2004 Turbot Landing','US - Annapolis, MD - 2004 Turbot Landing'));
        offList.add(new SelectOption('US - Anniston, AL - Ft. McClellan, 40 Twill Lane Po Box 5398','US - Anniston, AL - Ft. McClellan, 40 Twill Lane Po Box 5398'));
        offList.add(new SelectOption('US - Anniston, AL - SDC Bldg. 695 c o Anniston Army Depot Co','US - Anniston, AL - SDC Bldg. 695 c o Anniston Army Depot Co'));
        offList.add(new SelectOption('US - Anniston, AL - URS 23 Diana Hills Road','US - Anniston, AL - URS 23 Diana Hills Road'));
        offList.add(new SelectOption('US - APO AE, Sinai','US - APO AE, Sinai'));
        offList.add(new SelectOption('US - APO, AA - COMUSNAVSO FOL Unit 3129','US - APO, AA - COMUSNAVSO FOL Unit 3129'));
        offList.add(new SelectOption('US - Arizona - Telecommute','US - Arizona - Telecommute'));
        offList.add(new SelectOption('US - Arlington, TX - URS General Motor Assembly 2525 East Ab','US - Arlington, TX - URS General Motor Assembly 2525 East Ab'));
        offList.add(new SelectOption('US - Arlington, VA - 100 Boundry Channel Dr','US - Arlington, VA - 100 Boundry Channel Dr'));
        offList.add(new SelectOption('US - Arlington, VA - 1616 North Fort Myers Drive','US - Arlington, VA - 1616 North Fort Myers Drive'));
        offList.add(new SelectOption('US - Arlington, VA - 1777 N Kent Street','US - Arlington, VA - 1777 N Kent Street'));
        offList.add(new SelectOption('US - Arlington, VA - 1800 S Bell Street','US - Arlington, VA - 1800 S Bell Street'));
        offList.add(new SelectOption('US - Arlington, VA - 2101 Wilson Blvd','US - Arlington, VA - 2101 Wilson Blvd'));
        offList.add(new SelectOption('US - Arlington, VA - 2101 Wilson Boulevard - Suite 800','US - Arlington, VA - 2101 Wilson Boulevard - Suite 800'));
        offList.add(new SelectOption('US - Arlington, VA - 2121 Crystal Drive','US - Arlington, VA - 2121 Crystal Drive'));
        offList.add(new SelectOption('US - Arlington, VA - 2345 Crystal Drive','US - Arlington, VA - 2345 Crystal Drive'));
        offList.add(new SelectOption('US - Arlington, VA - 2345 Crystal Drive Ste 708','US - Arlington, VA - 2345 Crystal Drive Ste 708'));
        offList.add(new SelectOption('US - Arlington, VA - 2345 Crystal Drive Suite 708','US - Arlington, VA - 2345 Crystal Drive Suite 708'));
        offList.add(new SelectOption('US - Arlington, VA - 2450 Crystal City Drive Suite 500','US - Arlington, VA - 2450 Crystal City Drive Suite 500'));
        offList.add(new SelectOption('US - Arlington, VA - 2450 Crystal Drive','US - Arlington, VA - 2450 Crystal Drive'));
        offList.add(new SelectOption('US - Arlington, VA - 3101 Wilson Blvd','US - Arlington, VA - 3101 Wilson Blvd'));
        offList.add(new SelectOption('US - Arlington, VA - 3501 N Fairfax Drive','US - Arlington, VA - 3501 N Fairfax Drive'));
        offList.add(new SelectOption('US - Arlington, VA - 3701 N Fairfax Dr','US - Arlington, VA - 3701 N Fairfax Dr'));
        offList.add(new SelectOption('US - Arlington, VA - 875 North Randolph Street Ste 1211','US - Arlington, VA - 875 North Randolph Street Ste 1211'));
        offList.add(new SelectOption('US - Arlington, VA - Army Navy Dr & Fern St','US - Arlington, VA - Army Navy Dr & Fern St'));
        offList.add(new SelectOption('US - Arlington, VA - Taylor Bldg, 2530 Crystal Drive','US - Arlington, VA - Taylor Bldg, 2530 Crystal Drive'));
        offList.add(new SelectOption('US - Arlington, VA - TSA HQ 701 12th Street South','US - Arlington, VA - TSA HQ 701 12th Street South'));
        offList.add(new SelectOption('US - Arlington, VA - URS 2345 Crystal Drive Suite 708','US - Arlington, VA - URS 2345 Crystal Drive Suite 708'));
        offList.add(new SelectOption('US - Arlington, WA - 27700 Washington 530','US - Arlington, WA - 27700 Washington 530'));
        offList.add(new SelectOption('US - Arvin, CA - URS Caterpillar-Arvin Parts Dist Center 592','US - Arvin, CA - URS Caterpillar-Arvin Parts Dist Center 592'));
        offList.add(new SelectOption('US - Astoria, NY','US - Astoria, NY'));
        offList.add(new SelectOption('US - Astoria, NY - 42-15 Berrian Blvd','US - Astoria, NY - 42-15 Berrian Blvd'));
        offList.add(new SelectOption('US - Atlanta, GA - 101 Marietta St NW 2350','US - Atlanta, GA - 101 Marietta St NW 2350'));
        offList.add(new SelectOption('US - Atlanta, GA - 1255 Collier Road NW','US - Atlanta, GA - 1255 Collier Road NW'));
        offList.add(new SelectOption('US - Atlanta, GA - 1360 Peachtree St NE','US - Atlanta, GA - 1360 Peachtree St NE'));
        offList.add(new SelectOption('US - Atlanta, GA - 2150 Parklake Drive','US - Atlanta, GA - 2150 Parklake Drive'));
        offList.add(new SelectOption('US - Atlanta, GA - 2400 Piedmont Rd NE','US - Atlanta, GA - 2400 Piedmont Rd NE'));
        offList.add(new SelectOption('US - Atlanta, GA - 400 Northpark Town Center','US - Atlanta, GA - 400 Northpark Town Center'));
        offList.add(new SelectOption('US - Atlanta, GA - 400 Northpark Town Center 1000 Abernathy ','US - Atlanta, GA - 400 Northpark Town Center 1000 Abernathy '));
        offList.add(new SelectOption('US - Atlanta, GA - 4800 Burford Highway Mailstop 3E','US - Atlanta, GA - 4800 Burford Highway Mailstop 3E'));
        offList.add(new SelectOption('US - Atlanta, GA - URS 400 Northpark Town Center 1000 Aberna','US - Atlanta, GA - URS 400 Northpark Town Center 1000 Aberna'));
        offList.add(new SelectOption('US - Atlanta, GA - URS 400 Northpark Town Center,1000 Aberna','US - Atlanta, GA - URS 400 Northpark Town Center,1000 Aberna'));
        offList.add(new SelectOption('US - Atlanta, GA - URS 7305 Chattahoochee Bluff Drive','US - Atlanta, GA - URS 7305 Chattahoochee Bluff Drive'));
        offList.add(new SelectOption('US - Atlanta, GA - US SEC 3475 Lenox Rd Suite 500','US - Atlanta, GA - US SEC 3475 Lenox Rd Suite 500'));
        offList.add(new SelectOption('US - ATLANTIC CITY, NJ - William J. Hughes FAA Technical Cen','US - ATLANTIC CITY, NJ - William J. Hughes FAA Technical Cen'));
        offList.add(new SelectOption('US - Atlantic Field, NC - Electronic Warfare Range','US - Atlantic Field, NC - Electronic Warfare Range'));
        offList.add(new SelectOption('US - Aurora, CO - 16401 E Centretech Pkwy','US - Aurora, CO - 16401 E Centretech Pkwy'));
        offList.add(new SelectOption('US - Aurora, CO - DET 33, OSACOM 19340 E. Sunlight Way Bldg ','US - Aurora, CO - DET 33, OSACOM 19340 E. Sunlight Way Bldg '));
        offList.add(new SelectOption('US - Aurora, IL - URS Caterpillar Inc. Route 31 South 12a-35','US - Aurora, IL - URS Caterpillar Inc. Route 31 South 12a-35'));
        offList.add(new SelectOption('US - Austin, TX - 111 Congress Avenue','US - Austin, TX - 111 Congress Avenue'));
        offList.add(new SelectOption('US - Austin, TX - 11103 Hidden Bluff Dr','US - Austin, TX - 11103 Hidden Bluff Dr'));
        offList.add(new SelectOption('US - Austin, TX - 123 1/2 Red River Street','US - Austin, TX - 123 1/2 Red River Street'));
        offList.add(new SelectOption('US - Austin, TX - 2021 E. Woodward','US - Austin, TX - 2021 E. Woodward'));
        offList.add(new SelectOption('US - Austin, TX - 300 East 5th Street','US - Austin, TX - 300 East 5th Street'));
        offList.add(new SelectOption('US - Austin, TX - 400 W 15th St','US - Austin, TX - 400 W 15th St'));
        offList.add(new SelectOption('US - Austin, TX - 500 E Stassney Lane, No 318','US - Austin, TX - 500 E Stassney Lane, No 318'));
        offList.add(new SelectOption('US - Austin, TX - 608 East Cesar Chavez Street','US - Austin, TX - 608 East Cesar Chavez Street'));
        offList.add(new SelectOption('US - Austin, TX - 7109 Fireoak Drive','US - Austin, TX - 7109 Fireoak Drive'));
        offList.add(new SelectOption('US - Austin, TX - 9400 Amberglen Blvd Bldg B','US - Austin, TX - 9400 Amberglen Blvd Bldg B'));
        offList.add(new SelectOption('US - Austin, TX - 9400 Amberglen Boulevard','US - Austin, TX - 9400 Amberglen Boulevard'));
        offList.add(new SelectOption('US - Austin, TX - 9400 Amberglen Boulevard 9400 Amberglen Bo','US - Austin, TX - 9400 Amberglen Boulevard 9400 Amberglen Bo'));
        offList.add(new SelectOption('US - Austin, TX - 9400 Amberglen Boulevard Amber Oaks','US - Austin, TX - 9400 Amberglen Boulevard Amber Oaks'));
        offList.add(new SelectOption('US - Austin, TX - 9400 Amberglen Boulevard Amber Oaks, Build','US - Austin, TX - 9400 Amberglen Boulevard Amber Oaks, Build'));
        offList.add(new SelectOption('US - Austin, TX - 9720 Morgan Creek Drive','US - Austin, TX - 9720 Morgan Creek Drive'));
        offList.add(new SelectOption('US - Austin, TX - URS Amber Oaks 9400 Amberglen Boulevard','US - Austin, TX - URS Amber Oaks 9400 Amberglen Boulevard'));
        offList.add(new SelectOption('US - Australia','US - Australia'));
        offList.add(new SelectOption('US - Aweil, South Sudan','US - Aweil, South Sudan'));
        offList.add(new SelectOption('US - Bakersfield, CA - 5001 E Commercenter Dr','US - Bakersfield, CA - 5001 E Commercenter Dr'));
        offList.add(new SelectOption('US - Bakersfield, CA - 800 Truxton Ave','US - Bakersfield, CA - 800 Truxton Ave'));
        offList.add(new SelectOption('US - Baldwinsville, NY - PO Box 5','US - Baldwinsville, NY - PO Box 5'));
        offList.add(new SelectOption('US - Baldwinsville, NY - URS Anheuser-Busch, Inc 2885 Belgiu','US - Baldwinsville, NY - URS Anheuser-Busch, Inc 2885 Belgiu'));
        offList.add(new SelectOption('US - Baldwinsville, NY - URS W.O 28788 A-B Baldwinsville Ase','US - Baldwinsville, NY - URS W.O 28788 A-B Baldwinsville Ase'));
        offList.add(new SelectOption('US - Baldwinsville, NY - URS W.O. 28788 A-B Baldwinsville As','US - Baldwinsville, NY - URS W.O. 28788 A-B Baldwinsville As'));
        offList.add(new SelectOption('US - Baltimore, MD - 100 S Charles Street - MTA Prj Office','US - Baltimore, MD - 100 S Charles Street - MTA Prj Office'));
        offList.add(new SelectOption('US - Baltimore, MD - 1800 Washington Blvd','US - Baltimore, MD - 1800 Washington Blvd'));
        offList.add(new SelectOption('US - Baltimore, MD - 31 Hopkins Plaza','US - Baltimore, MD - 31 Hopkins Plaza'));
        offList.add(new SelectOption('US - Baltimore, MD - 6 Saint Paul Street - MTA Office','US - Baltimore, MD - 6 Saint Paul Street - MTA Office'));
        offList.add(new SelectOption('US - Baltimore, MD - 7 Saint Paul St','US - Baltimore, MD - 7 Saint Paul St'));
        offList.add(new SelectOption('US - Baltimore, MD - 707 E Ordance Road Suite 410','US - Baltimore, MD - 707 E Ordance Road Suite 410'));
        offList.add(new SelectOption('US - Baltimore, MD - 707 North Calvert Street','US - Baltimore, MD - 707 North Calvert Street'));
        offList.add(new SelectOption('US - Baltimore, MD - SSA HQ 6401 Security Blvd','US - Baltimore, MD - SSA HQ 6401 Security Blvd'));
        offList.add(new SelectOption('US - Bamako, Mali','US - Bamako, Mali'));
        offList.add(new SelectOption('US - Bangkok, Thailand - 5/117 Soi Suanlu','US - Bangkok, Thailand - 5/117 Soi Suanlu'));
        offList.add(new SelectOption('US - Barstow, CA - Attn: URS, Toby Bristow PO Box 110880','US - Barstow, CA - Attn: URS, Toby Bristow PO Box 110880'));
        offList.add(new SelectOption('US - Baton Rouge, LA - 232 Third St','US - Baton Rouge, LA - 232 Third St'));
        offList.add(new SelectOption('US - Baton Rouge, LA - 7389 Florida Blvd','US - Baton Rouge, LA - 7389 Florida Blvd'));
        offList.add(new SelectOption('US - Baton Rouge, LA - 7389 Florida Blvd Suite 300','US - Baton Rouge, LA - 7389 Florida Blvd Suite 300'));
        offList.add(new SelectOption('US - Baton Rouge, LA - 7389 Florida Boulevard, Suite 300','US - Baton Rouge, LA - 7389 Florida Boulevard, Suite 300'));
        offList.add(new SelectOption('US - Battle Creek, MI - 4625 Beckley Road','US - Battle Creek, MI - 4625 Beckley Road'));
        offList.add(new SelectOption('US - Beaufort, SC - Bldg. 1107 Itami Street','US - Beaufort, SC - Bldg. 1107 Itami Street'));
        offList.add(new SelectOption('US - Beaufort, SC - Marine Corps Air Station','US - Beaufort, SC - Marine Corps Air Station'));
        offList.add(new SelectOption('US - Beavercreek, OH - 4141 Colonel Glenn Highway Ste. 350','US - Beavercreek, OH - 4141 Colonel Glenn Highway Ste. 350'));
        offList.add(new SelectOption('US - Bedford, IN - 1554 E Oolitic Road','US - Bedford, IN - 1554 E Oolitic Road'));
        offList.add(new SelectOption('US - Bedford, IN - 3260 16 St.','US - Bedford, IN - 3260 16 St.'));
        offList.add(new SelectOption('US - Bedford, IN - URS Gm Metal Casting Plant 105 Gm Drive','US - Bedford, IN - URS Gm Metal Casting Plant 105 Gm Drive'));
        offList.add(new SelectOption('US - Bellevue, WA - URS Seattle Office 10900 Ne 8th Street S','US - Bellevue, WA - URS Seattle Office 10900 Ne 8th Street S'));
        offList.add(new SelectOption('US - Bellingham, WA - 405 32nd Street','US - Bellingham, WA - 405 32nd Street'));
        offList.add(new SelectOption('US - Bellingham, WA - 405 32nd Street Suite 305','US - Bellingham, WA - 405 32nd Street Suite 305'));
        offList.add(new SelectOption('US - Belmont, MA - 29 Oliver Road','US - Belmont, MA - 29 Oliver Road'));
        offList.add(new SelectOption('US - Beltsville, MD - 8000 Virginia Manor Road','US - Beltsville, MD - 8000 Virginia Manor Road'));
        offList.add(new SelectOption('US - Bensalem, PA - 2997 Galloway Road','US - Bensalem, PA - 2997 Galloway Road'));
        offList.add(new SelectOption('US - Benson, AZ - 25345 E Castlerock Kennel Dr','US - Benson, AZ - 25345 E Castlerock Kennel Dr'));
        offList.add(new SelectOption('US - Berkley, CA - 1879 Euclid Avenue','US - Berkley, CA - 1879 Euclid Avenue'));
        offList.add(new SelectOption('US - Bethesda, MD - 6000 MacArthur Boulevard','US - Bethesda, MD - 6000 MacArthur Boulevard'));
        offList.add(new SelectOption('US - Bethesda, MD - 6430 Rocklaedg Dr Suite 600','US - Bethesda, MD - 6430 Rocklaedg Dr Suite 600'));
        offList.add(new SelectOption('US - Bethesda, MD - National Naval Medical Center 8901 Wisco','US - Bethesda, MD - National Naval Medical Center 8901 Wisco'));
        offList.add(new SelectOption('US - Beulah, ND - Rust Constructors Inc Dakota Gasification ','US - Beulah, ND - Rust Constructors Inc Dakota Gasification '));
        offList.add(new SelectOption('US - Beulah, ND - URS 420 County Rd 26 P. O. Box 1149','US - Beulah, ND - URS 420 County Rd 26 P. O. Box 1149'));
        offList.add(new SelectOption('US - Billings, MT - 207 N Broadway STE 315','US - Billings, MT - 207 N Broadway STE 315'));
        offList.add(new SelectOption('US - Biloxi, MS - 2442 W Shore Drive','US - Biloxi, MS - 2442 W Shore Drive'));
        offList.add(new SelectOption('US - Birmingham, AL - 3800 Colonnade Parkway','US - Birmingham, AL - 3800 Colonnade Parkway'));
        offList.add(new SelectOption('US - Birmingham, AL - URS 2 Perimeter Park South, Suite 350w','US - Birmingham, AL - URS 2 Perimeter Park South, Suite 350w'));
        offList.add(new SelectOption('US - Birmingham, AL - URS 2708 Drennen Circle','US - Birmingham, AL - URS 2708 Drennen Circle'));
        offList.add(new SelectOption('US - Birmingham, MI','US - Birmingham, MI'));
        offList.add(new SelectOption('US - Bismarck, ND - 1000 East Calgary Avenue','US - Bismarck, ND - 1000 East Calgary Avenue'));
        offList.add(new SelectOption('US - Bismarck, ND - 400 East Broadway','US - Bismarck, ND - 400 East Broadway'));
        offList.add(new SelectOption('US - Blaine, WA - BP Cherry Point Refinery 4519 Grandview Ro','US - Blaine, WA - BP Cherry Point Refinery 4519 Grandview Ro'));
        offList.add(new SelectOption('US - Bloomington, IN - 1800 W 17th St','US - Bloomington, IN - 1800 W 17th St'));
        offList.add(new SelectOption('US - Blue Ash, OH - 4219 Malsbary Rd','US - Blue Ash, OH - 4219 Malsbary Rd'));
        offList.add(new SelectOption('US - Bluffdale, UT - 15623 South Thunder Gulch Drive','US - Bluffdale, UT - 15623 South Thunder Gulch Drive'));
        offList.add(new SelectOption('US - Bluffton, SC - 36 Halsey Circle','US - Bluffton, SC - 36 Halsey Circle'));
        offList.add(new SelectOption('US - Boca Raton, FL - 7800 Congress Avenue','US - Boca Raton, FL - 7800 Congress Avenue'));
        offList.add(new SelectOption('US - Boca Raton, FL - 7800 Congress Avenue Suite 200','US - Boca Raton, FL - 7800 Congress Avenue Suite 200'));
        offList.add(new SelectOption('US - Boise, ID - 1185 South Vinnell Way','US - Boise, ID - 1185 South Vinnell Way'));
        offList.add(new SelectOption('US - Boise, ID - 1750 Front Street Suite 100','US - Boise, ID - 1750 Front Street Suite 100'));
        offList.add(new SelectOption('US - Boise, ID - 400 South Broadway Avenue','US - Boise, ID - 400 South Broadway Avenue'));
        offList.add(new SelectOption('US - Boise, ID - 720 Park Blvd','US - Boise, ID - 720 Park Blvd'));
        offList.add(new SelectOption('US - Boise, ID - 720 Park Boulevard','US - Boise, ID - 720 Park Boulevard'));
        offList.add(new SelectOption('US - Boise, ID - 720 Park Boulevard PO Box 73','US - Boise, ID - 720 Park Boulevard PO Box 73'));
        offList.add(new SelectOption('US - Boise, ID - URS 720 Park Blvd','US - Boise, ID - URS 720 Park Blvd'));
        offList.add(new SelectOption('US - Boise, ID - URS P. O. Box 73','US - Boise, ID - URS P. O. Box 73'));
        offList.add(new SelectOption('US - Booneville, MS - URS Caterpillar Prentiss Facility 100 ','US - Booneville, MS - URS Caterpillar Prentiss Facility 100 '));
        offList.add(new SelectOption('US - Bossier City, LA - 4921 Shed Road, Suite 400 and 500','US - Bossier City, LA - 4921 Shed Road, Suite 400 and 500'));
        offList.add(new SelectOption('US - Boston, MA - 101 Federal Street','US - Boston, MA - 101 Federal Street'));
        offList.add(new SelectOption('US - Boston, MA - 66 Long Wharf','US - Boston, MA - 66 Long Wharf'));
        offList.add(new SelectOption('US - Boulder, WY - 31 Larry Lozier Road, PO Box 248','US - Boulder, WY - 31 Larry Lozier Road, PO Box 248'));
        offList.add(new SelectOption('US - Bowie, MD - 16701 Melford Blvd Suite 200','US - Bowie, MD - 16701 Melford Blvd Suite 200'));
        offList.add(new SelectOption('US - Bowling Green, KY - URS Bowling Green Metalforming 111 ','US - Bowling Green, KY - URS Bowling Green Metalforming 111 '));
        offList.add(new SelectOption('US - Boynton Beach, FL - 8499 Aryshire Court','US - Boynton Beach, FL - 8499 Aryshire Court'));
        offList.add(new SelectOption('US - Brcko, Bosnia and Herzegovina','US - Brcko, Bosnia and Herzegovina'));
        offList.add(new SelectOption('US - Bridgeport, CT - 615 Asylum Street 615 Asylum Street','US - Bridgeport, CT - 615 Asylum Street 615 Asylum Street'));
        offList.add(new SelectOption('US - Bridgeport, TX - 315 Industrial Park','US - Bridgeport, TX - 315 Industrial Park'));
        offList.add(new SelectOption('US - Bridgeport, WV - 1000 Fixed Wing Drive Bridgeport','US - Bridgeport, WV - 1000 Fixed Wing Drive Bridgeport'));
        offList.add(new SelectOption('US - Bronx, NY - 2301 White Plains Road','US - Bronx, NY - 2301 White Plains Road'));
        offList.add(new SelectOption('US - Brooklyn, NY - 320 Freeman St','US - Brooklyn, NY - 320 Freeman St'));
        offList.add(new SelectOption('US - Brooklyn, NY - 40 20th St','US - Brooklyn, NY - 40 20th St'));
        offList.add(new SelectOption('US - Brooklyn, NY - 4105 Ave V','US - Brooklyn, NY - 4105 Ave V'));
        offList.add(new SelectOption('US - Brooklyn, NY - 55 Washington Street','US - Brooklyn, NY - 55 Washington Street'));
        offList.add(new SelectOption('US - Brooklyn, NY - 620 Atlantic Avenue','US - Brooklyn, NY - 620 Atlantic Avenue'));
        offList.add(new SelectOption('US - Brooklyn, NY - 951 3rd Ave','US - Brooklyn, NY - 951 3rd Ave'));
        offList.add(new SelectOption('US - Buffalo, NY - 10 Fountain Plaza','US - Buffalo, NY - 10 Fountain Plaza'));
        offList.add(new SelectOption('US - Buffalo, NY - 138 Delaware Avenue','US - Buffalo, NY - 138 Delaware Avenue'));
        offList.add(new SelectOption('US - Buffalo, NY - 257 West Genesee Street','US - Buffalo, NY - 257 West Genesee Street'));
        offList.add(new SelectOption('US - Buffalo, NY - 257 West Genesee Street Ste 440','US - Buffalo, NY - 257 West Genesee Street Ste 440'));
        offList.add(new SelectOption('US - Burlington, NJ - 437 High Street','US - Burlington, NJ - 437 High Street'));
        offList.add(new SelectOption('US - Cairo, Egypt - 21 Misr-Helwan Rd','US - Cairo, Egypt - 21 Misr-Helwan Rd'));
        offList.add(new SelectOption('US - Calexico, CA - 1699 Carr Road','US - Calexico, CA - 1699 Carr Road'));
        offList.add(new SelectOption('US - California - Telecommute','US - California - Telecommute'));
        offList.add(new SelectOption('US - Camarillo, CA - 1220 Avenida Acaso','US - Camarillo, CA - 1220 Avenida Acaso'));
        offList.add(new SelectOption('US - Cambridge, MA - 5 Cambridge Center, 9th Floor','US - Cambridge, MA - 5 Cambridge Center, 9th Floor'));
        offList.add(new SelectOption('US - Cambridge, MA - URS One Canal Park 3rd Floor','US - Cambridge, MA - URS One Canal Park 3rd Floor'));
        offList.add(new SelectOption('US - Camp H.M. Smith, HI - Joint Innovation and Experimentat','US - Camp H.M. Smith, HI - Joint Innovation and Experimentat'));
        offList.add(new SelectOption('US - Camp Lejeune, NC - FC 286 Gonzales Blvd','US - Camp Lejeune, NC - FC 286 Gonzales Blvd'));
        offList.add(new SelectOption('US - Camp Lejeune, NC - MAET, Camp Lejeune Training Center B','US - Camp Lejeune, NC - MAET, Camp Lejeune Training Center B'));
        offList.add(new SelectOption('US - Camp Lejeune, NC - Naval Hospital Camp LeJeune 100 Brew','US - Camp Lejeune, NC - Naval Hospital Camp LeJeune 100 Brew'));
        offList.add(new SelectOption('US - Camp Pendleton, CA - MAET, Traffic Management Office Bl','US - Camp Pendleton, CA - MAET, Traffic Management Office Bl'));
        offList.add(new SelectOption('US - Camp Springs, MD - Joint Base Andrews','US - Camp Springs, MD - Joint Base Andrews'));
        offList.add(new SelectOption('US - Cannon AFB, NM - 103 N Torch Blvd, Bldg 680','US - Cannon AFB, NM - 103 N Torch Blvd, Bldg 680'));
        offList.add(new SelectOption('US - Canton, NY - 1311 CR 25','US - Canton, NY - 1311 CR 25'));
        offList.add(new SelectOption('US - Cape Canaveral, FL - 752 Bayside Drive 405a','US - Cape Canaveral, FL - 752 Bayside Drive 405a'));
        offList.add(new SelectOption('US - Cape Canaveral, FL - 8910 Astronaut Blvd Suite 302','US - Cape Canaveral, FL - 8910 Astronaut Blvd Suite 302'));
        offList.add(new SelectOption('US - Carlisle, PA - URS 180 Kost Road','US - Carlisle, PA - URS 180 Kost Road'));
        offList.add(new SelectOption('US - CARLSBAD, NM - 4021 National Parks Highway','US - CARLSBAD, NM - 4021 National Parks Highway'));
        offList.add(new SelectOption('US - Carolina, PR - Luis Munoz Marin Intl Airport','US - Carolina, PR - Luis Munoz Marin Intl Airport'));
        offList.add(new SelectOption('US - Carrollton, VA - 22217 Tradewinds Drive','US - Carrollton, VA - 22217 Tradewinds Drive'));
        offList.add(new SelectOption('US - Carswell, TX - ASF Bldg 1027 Perimeter Road','US - Carswell, TX - ASF Bldg 1027 Perimeter Road'));
        offList.add(new SelectOption('US - Carthage, TX - 1109 West Panola','US - Carthage, TX - 1109 West Panola'));
        offList.add(new SelectOption('US - Casper, WY - PO Box 2106 (82601) All US Mail to PO Box ','US - Casper, WY - PO Box 2106 (82601) All US Mail to PO Box '));
        offList.add(new SelectOption('US - Centennial, CO 12445 East Caley Ave','US - Centennial, CO 12445 East Caley Ave'));
        offList.add(new SelectOption('US - Centerville, OH - 7793 Windy Hill Court','US - Centerville, OH - 7793 Windy Hill Court'));
        offList.add(new SelectOption('US - Centurion, South Africa - 263A West Avenue','US - Centurion, South Africa - 263A West Avenue'));
        offList.add(new SelectOption('US - Chantilly, VA - 4800 Westfields Blvd','US - Chantilly, VA - 4800 Westfields Blvd'));
        offList.add(new SelectOption('US - Chaparral, NM - 9582 Patriot Road','US - Chaparral, NM - 9582 Patriot Road'));
        offList.add(new SelectOption('US - Charlotte, NC - 5925 Carnegie Boulevard','US - Charlotte, NC - 5925 Carnegie Boulevard'));
        offList.add(new SelectOption('US - Charlotte, NC - 6000 Fairview Road','US - Charlotte, NC - 6000 Fairview Road'));
        offList.add(new SelectOption('US - Charlotte, NC - 6000 Fairview Road Suite 200','US - Charlotte, NC - 6000 Fairview Road Suite 200'));
        offList.add(new SelectOption('US - Charlotte, NC - 6000 Fairview Road, Suite 200','US - Charlotte, NC - 6000 Fairview Road, Suite 200'));
        offList.add(new SelectOption('US - Charlotte, NC - 6130 Tyvola Center Drive','US - Charlotte, NC - 6130 Tyvola Center Drive'));
        offList.add(new SelectOption('US - Charlotte, NC - URS 7207 Ibm Drive Clt-3a','US - Charlotte, NC - URS 7207 Ibm Drive Clt-3a'));
        offList.add(new SelectOption('US - Charlotte, NC - URS Sgt 7207 Ibm Drive','US - Charlotte, NC - URS Sgt 7207 Ibm Drive'));
        offList.add(new SelectOption('US - Charlottesville, VA - 305 Harvest Drive','US - Charlottesville, VA - 305 Harvest Drive'));
        offList.add(new SelectOption('US - Chatanooga, TN - 1428 Chestnut Street','US - Chatanooga, TN - 1428 Chestnut Street'));
        offList.add(new SelectOption('US - Chattanooga, TN - URS 1428 Chestnut Street, Suite A','US - Chattanooga, TN - URS 1428 Chestnut Street, Suite A'));
        offList.add(new SelectOption('US - Chattanooga, TN - URS 4605 Amnicola Highway','US - Chattanooga, TN - URS 4605 Amnicola Highway'));
        offList.add(new SelectOption('US - Chelmsford, MA - 250 Apollo Drive','US - Chelmsford, MA - 250 Apollo Drive'));
        offList.add(new SelectOption('US - Chelsea, AL - URS 109 Courtyard Drive','US - Chelsea, AL - URS 109 Courtyard Drive'));
        offList.add(new SelectOption('US - Cherry Point, NC - Bldg. 4031 6th Avenue','US - Cherry Point, NC - Bldg. 4031 6th Avenue'));
        offList.add(new SelectOption('US - Cherry Point, NC - EWN Bldg. 137','US - Cherry Point, NC - EWN Bldg. 137'));
        offList.add(new SelectOption('US - Cherry Point, NC - TBD','US - Cherry Point, NC - TBD'));
        offList.add(new SelectOption('US - Chesapeake, VA - 2912 Sir Thomas Dr','US - Chesapeake, VA - 2912 Sir Thomas Dr'));
        offList.add(new SelectOption('US - Chestnut Ridge, NY - 100 Red Schoolhouse Rd','US - Chestnut Ridge, NY - 100 Red Schoolhouse Rd'));
        offList.add(new SelectOption('US - Chicago, IL - 1 S Wacker Dr','US - Chicago, IL - 1 S Wacker Dr'));
        offList.add(new SelectOption('US - Chicago, IL - 100 S Wacker Drive','US - Chicago, IL - 100 S Wacker Drive'));
        offList.add(new SelectOption('US - Chicago, IL - 10510 W Zemke Rd','US - Chicago, IL - 10510 W Zemke Rd'));
        offList.add(new SelectOption('US - Chicago, IL - 175 W Jackson Blvd, Suite 900','US - Chicago, IL - 175 W Jackson Blvd, Suite 900'));
        offList.add(new SelectOption('US - Chicago, IL - 303 E Wacker Drive','US - Chicago, IL - 303 E Wacker Drive'));
        offList.add(new SelectOption('US - Chico, CA','US - Chico, CA'));
        offList.add(new SelectOption('US - Chico, CA - 1550 Humboldt Road Suite 2','US - Chico, CA - 1550 Humboldt Road Suite 2'));
        offList.add(new SelectOption('US - Churubusco, NY - 385 Ryan Rd','US - Churubusco, NY - 385 Ryan Rd'));
        offList.add(new SelectOption('US - Cincinnati, OH - 11260 Chester Rd','US - Cincinnati, OH - 11260 Chester Rd'));
        offList.add(new SelectOption('US - Cincinnati, OH - 4676 Columbia Parkway','US - Cincinnati, OH - 4676 Columbia Parkway'));
        offList.add(new SelectOption('US - Cincinnati, OH - 525 Vine Street','US - Cincinnati, OH - 525 Vine Street'));
        offList.add(new SelectOption('US - Clayton, NC - 354 Broadmoor Way','US - Clayton, NC - 354 Broadmoor Way'));
        offList.add(new SelectOption('US - Clayton, NC - URS Cat Inc 954 Nc 42 East','US - Clayton, NC - URS Cat Inc 954 Nc 42 East'));
        offList.add(new SelectOption('US - Clayton, OH - URS 6611 Hoke Road','US - Clayton, OH - URS 6611 Hoke Road'));
        offList.add(new SelectOption('US - Clearwater, FL - USAR 16100 Fairchild Drive','US - Clearwater, FL - USAR 16100 Fairchild Drive'));
        offList.add(new SelectOption('US - Cleveland, OH - 1001 Lakeside Avenue','US - Cleveland, OH - 1001 Lakeside Avenue'));
        offList.add(new SelectOption('US - Cleveland, OH - 1375 Euclid Avenue','US - Cleveland, OH - 1375 Euclid Avenue'));
        offList.add(new SelectOption('US - Cleveland, OH - 1375 Euclid Avenue Suite 600','US - Cleveland, OH - 1375 Euclid Avenue Suite 600'));
        offList.add(new SelectOption('US - Cleveland, OH - 1500 W 3rd St., Suite 200','US - Cleveland, OH - 1500 W 3rd St., Suite 200'));
        offList.add(new SelectOption('US - Cleveland, OH - Cleveland Hopkins Intl Airport','US - Cleveland, OH - Cleveland Hopkins Intl Airport'));
        offList.add(new SelectOption('US - Cleveland, OH - URS Mk Ferguson Plaza 1500 W 3rd St','US - Cleveland, OH - URS Mk Ferguson Plaza 1500 W 3rd St'));
        offList.add(new SelectOption('US - Clifton Park, NY - 3 Corporate Drive Suite 203','US - Clifton Park, NY - 3 Corporate Drive Suite 203'));
        offList.add(new SelectOption('US - Clifton, AZ - URS Rust Constructors Inc Po Box 1565','US - Clifton, AZ - URS Rust Constructors Inc Po Box 1565'));
        offList.add(new SelectOption('US - Clifton, NJ - 1255 Broad Street','US - Clifton, NJ - 1255 Broad Street'));
        offList.add(new SelectOption('US - Cocoa Beach, FL -','US - Cocoa Beach, FL -'));
        offList.add(new SelectOption('US - College Park, GA - 1255 S Loop Rd','US - College Park, GA - 1255 S Loop Rd'));
        offList.add(new SelectOption('US - College Park, MD - 8601 Adelphi Rd','US - College Park, MD - 8601 Adelphi Rd'));
        offList.add(new SelectOption('US - Collegeville, PA - URS 500 Arcola Road','US - Collegeville, PA - URS 500 Arcola Road'));
        offList.add(new SelectOption('US - Colorado - Telecommute','US - Colorado - Telecommute'));
        offList.add(new SelectOption('US - Colorado Springs, CO','US - Colorado Springs, CO'));
        offList.add(new SelectOption('US - Colorado Springs, CO - 160 Patrick St','US - Colorado Springs, CO - 160 Patrick St'));
        offList.add(new SelectOption('US - Colorado Springs, CO - 2315 Briargate Parkway','US - Colorado Springs, CO - 2315 Briargate Parkway'));
        offList.add(new SelectOption('US - Colorado Springs, CO - 9960 Federal Drive Suite 300','US - Colorado Springs, CO - 9960 Federal Drive Suite 300'));
        offList.add(new SelectOption('US - Colorado Springs, CO - Cheyenne Mountain AFS','US - Colorado Springs, CO - Cheyenne Mountain AFS'));
        offList.add(new SelectOption('US - Columbia, MD - 9755 Patuxent Woods Drive Suite 300','US - Columbia, MD - 9755 Patuxent Woods Drive Suite 300'));
        offList.add(new SelectOption('US - Columbia, SC - 101 Research Drive','US - Columbia, SC - 101 Research Drive'));
        offList.add(new SelectOption('US - Columbus, GA - URS 8801 Macon Rd Box 9903 M/S 906-71','US - Columbus, GA - URS 8801 Macon Rd Box 9903 M/S 906-71'));
        offList.add(new SelectOption('US - Columbus, OH - 277 West Nationwide Blvd','US - Columbus, OH - 277 West Nationwide Blvd'));
        offList.add(new SelectOption('US - Columbus, OH - 3990 E Broad Street','US - Columbus, OH - 3990 E Broad Street'));
        offList.add(new SelectOption('US - Commerce City, CO - URS 6550 Gateway Road Bld 129','US - Commerce City, CO - URS 6550 Gateway Road Bld 129'));
        offList.add(new SelectOption('US - Commerce City, CO - URS Suncor 5801 Brighton Blvd.','US - Commerce City, CO - URS Suncor 5801 Brighton Blvd.'));
        offList.add(new SelectOption('US - Connecticut - Telecommute','US - Connecticut - Telecommute'));
        offList.add(new SelectOption('US - Conroe, TX - 4724 S Parkway Drive AASF Houston','US - Conroe, TX - 4724 S Parkway Drive AASF Houston'));
        offList.add(new SelectOption('US - Conshohocken, PA - 625 West Ridge Pike','US - Conshohocken, PA - 625 West Ridge Pike'));
        offList.add(new SelectOption('US - Conshokocken, PA - 625 West Ridge Pike','US - Conshokocken, PA - 625 West Ridge Pike'));
        offList.add(new SelectOption('US - Coral Gables, FL','US - Coral Gables, FL'));
        offList.add(new SelectOption('US - Coral Gables, FL - 135 San Lorenzo Avenue','US - Coral Gables, FL - 135 San Lorenzo Avenue'));
        offList.add(new SelectOption('US - Corbin, KY - 203 Allison Boulevard','US - Corbin, KY - 203 Allison Boulevard'));
        offList.add(new SelectOption('US - Corinth, MS - URS Caterpillar Corinth Facility 501 Card','US - Corinth, MS - URS Caterpillar Corinth Facility 501 Card'));
        offList.add(new SelectOption('US - Corpus Christi, TX - 10221 Avenue E Bldg 1770 Mail Stop','US - Corpus Christi, TX - 10221 Avenue E Bldg 1770 Mail Stop'));
        offList.add(new SelectOption('US - Corpus Christi, TX - 310 Crecy Street Door 114D','US - Corpus Christi, TX - 310 Crecy Street Door 114D'));
        offList.add(new SelectOption('US - Council Bluffs, IA - URS 10410 Bunge Road','US - Council Bluffs, IA - URS 10410 Bunge Road'));
        offList.add(new SelectOption('US - Covina, CA - 614 East Edna Place','US - Covina, CA - 614 East Edna Place'));
        offList.add(new SelectOption('US - Covina, CA - 628 East Edna Place','US - Covina, CA - 628 East Edna Place'));
        offList.add(new SelectOption('US - Covington, KY - 201 West Rivercenter Blvd. Stop 629','US - Covington, KY - 201 West Rivercenter Blvd. Stop 629'));
        offList.add(new SelectOption('US - Craig, CO - URS Tri-State Craig Station 2101 S Ranney S','US - Craig, CO - URS Tri-State Craig Station 2101 S Ranney S'));
        offList.add(new SelectOption('US - Crane, IN - 300 Highway 361 Bldg 2035','US - Crane, IN - 300 Highway 361 Bldg 2035'));
        offList.add(new SelectOption('US - Crane, IN - 300 Hwy 361 Bldg 2693','US - Crane, IN - 300 Hwy 361 Bldg 2693'));
        offList.add(new SelectOption('US - Crane, IN - 300 Hwy 361 Bldg 3330N','US - Crane, IN - 300 Hwy 361 Bldg 3330N'));
        offList.add(new SelectOption('US - Crane, IN - 300 Hwy 361 Bldg 3330S','US - Crane, IN - 300 Hwy 361 Bldg 3330S'));
        offList.add(new SelectOption('US - Crane, IN - 300 Hwy 361 Building 2044','US - Crane, IN - 300 Hwy 361 Building 2044'));
        offList.add(new SelectOption('US - Crane, IN - 300 Hwy 361 Building 3188','US - Crane, IN - 300 Hwy 361 Building 3188'));
        offList.add(new SelectOption('US - Crane, IN - 300 Hwy 361 Building 3291','US - Crane, IN - 300 Hwy 361 Building 3291'));
        offList.add(new SelectOption('US - Crane, IN - 300 Hwy 361 Building 3330W','US - Crane, IN - 300 Hwy 361 Building 3330W'));
        offList.add(new SelectOption('US - Crane, IN - 300 Hwy 361 Building 3334','US - Crane, IN - 300 Hwy 361 Building 3334'));
        offList.add(new SelectOption('US - Crane, IN - 300 Hwy 361 Building 3395','US - Crane, IN - 300 Hwy 361 Building 3395'));
        offList.add(new SelectOption('US - Crane, IN - 300 Hwy 361 Building 38','US - Crane, IN - 300 Hwy 361 Building 38'));
        offList.add(new SelectOption('US - Crane, IN - 300 Hwy 361 Building 41','US - Crane, IN - 300 Hwy 361 Building 41'));
        offList.add(new SelectOption('US - Creech AFB, NV - Building 1000 Perimeter','US - Creech AFB, NV - Building 1000 Perimeter'));
        offList.add(new SelectOption('US - Creve Coeur, MO - URS 800 N Lindbergh Blvd','US - Creve Coeur, MO - URS 800 N Lindbergh Blvd'));
        offList.add(new SelectOption('US - Crystal River, FL - URS Sgt 15760 West Power Line Stree','US - Crystal River, FL - URS Sgt 15760 West Power Line Stree'));
        offList.add(new SelectOption('US - Cutler Bay, FL - 32300 SW 97th Avenue','US - Cutler Bay, FL - 32300 SW 97th Avenue'));
        offList.add(new SelectOption('US - Dahlgren, VA - 16156 Dahlgren Road Po Box 552','US - Dahlgren, VA - 16156 Dahlgren Road Po Box 552'));
        offList.add(new SelectOption('US - Dahlgren, VA - 17214 Avenue B','US - Dahlgren, VA - 17214 Avenue B'));
        offList.add(new SelectOption('US - Dahlgren, VA - 17214 Avenue B Bldg 1500','US - Dahlgren, VA - 17214 Avenue B Bldg 1500'));
        offList.add(new SelectOption('US - Dahlgren, VA - 17230 Dahlgren Rd Bldg 1450T','US - Dahlgren, VA - 17230 Dahlgren Rd Bldg 1450T'));
        offList.add(new SelectOption('US - Dahlgren, VA - 17230 Dahlgren Rd Bldg 1470','US - Dahlgren, VA - 17230 Dahlgren Rd Bldg 1470'));
        offList.add(new SelectOption('US - Dahlgren, VA - 17230 Dahlgren Rd Bldg 1490','US - Dahlgren, VA - 17230 Dahlgren Rd Bldg 1490'));
        offList.add(new SelectOption('US - Dahlgren, VA - 18236 Thompson Rd','US - Dahlgren, VA - 18236 Thompson Rd'));
        offList.add(new SelectOption('US - Dahlgren, VA - 18313 Frontage Rd Suite 317','US - Dahlgren, VA - 18313 Frontage Rd Suite 317'));
        offList.add(new SelectOption('US - Dahlgren, VA - 18372 Frontage Rd Suite 318','US - Dahlgren, VA - 18372 Frontage Rd Suite 318'));
        offList.add(new SelectOption('US - Dahlgren, VA - 18444 Frontage Rd Bldg 1470','US - Dahlgren, VA - 18444 Frontage Rd Bldg 1470'));
        offList.add(new SelectOption('US - Dahlgren, VA - 19008 Wayside Dr Bldg 1490','US - Dahlgren, VA - 19008 Wayside Dr Bldg 1490'));
        offList.add(new SelectOption('US - Dahlgren, VA - 4048 Higley Rd','US - Dahlgren, VA - 4048 Higley Rd'));
        offList.add(new SelectOption('US - Dahlgren, VA - 4086 Higley Rd Bldg 1450T','US - Dahlgren, VA - 4086 Higley Rd Bldg 1450T'));
        offList.add(new SelectOption('US - Dahlgren, VA - 5297 4th St Bldg 1560','US - Dahlgren, VA - 5297 4th St Bldg 1560'));
        offList.add(new SelectOption('US - Dahlgren, VA - 5297 4th St Bldg 1700','US - Dahlgren, VA - 5297 4th St Bldg 1700'));
        offList.add(new SelectOption('US - Dahlgren, VA - 5389 Bronson Rd Bldg 1530','US - Dahlgren, VA - 5389 Bronson Rd Bldg 1530'));
        offList.add(new SelectOption('US - Dahlgren, VA - 5395 1st St Bldg 1520','US - Dahlgren, VA - 5395 1st St Bldg 1520'));
        offList.add(new SelectOption('US - Dahlgren, VA - 5409 First St Bldg 1500','US - Dahlgren, VA - 5409 First St Bldg 1500'));
        offList.add(new SelectOption('US - Dahlgren, VA - 5443 Bronson Rd Bldg 1200','US - Dahlgren, VA - 5443 Bronson Rd Bldg 1200'));
        offList.add(new SelectOption('US - Dahlgren, VA - 5443 Bronson Rd Bldg 1700','US - Dahlgren, VA - 5443 Bronson Rd Bldg 1700'));
        offList.add(new SelectOption('US - Dahlgren, VA - 5493 Marple Rd Bldg 110B','US - Dahlgren, VA - 5493 Marple Rd Bldg 110B'));
        offList.add(new SelectOption('US - Dahlgren, VA - 5493 Marple Rd Bldg 150','US - Dahlgren, VA - 5493 Marple Rd Bldg 150'));
        offList.add(new SelectOption('US - Dahlgren, VA - 5493 Marple Rd Bldg 185','US - Dahlgren, VA - 5493 Marple Rd Bldg 185'));
        offList.add(new SelectOption('US - Dakar, Senegal - 32 Avenue de la Republique','US - Dakar, Senegal - 32 Avenue de la Republique'));
        offList.add(new SelectOption('US - Daleville, AL - 807 Donnell Blvd, Suite F','US - Daleville, AL - 807 Donnell Blvd, Suite F'));
        offList.add(new SelectOption('US - Dallas, TX - 1401 Pacific Ave','US - Dallas, TX - 1401 Pacific Ave'));
        offList.add(new SelectOption('US - Dallas, TX - 16000 Dallas Parkway','US - Dallas, TX - 16000 Dallas Parkway'));
        offList.add(new SelectOption('US - Dallas, TX - 1601 Bryant St','US - Dallas, TX - 1601 Bryant St'));
        offList.add(new SelectOption('US - Dallas, TX - 1950 N Stemmons Freeway','US - Dallas, TX - 1950 N Stemmons Freeway'));
        offList.add(new SelectOption('US - Dallas, TX - 2300 N Stemmons Freeway','US - Dallas, TX - 2300 N Stemmons Freeway'));
        offList.add(new SelectOption('US - Dallas, TX - 2619 McKinney Avenue','US - Dallas, TX - 2619 McKinney Avenue'));
        offList.add(new SelectOption('US - Dallas, TX - 3130 N Harwood Street','US - Dallas, TX - 3130 N Harwood Street'));
        offList.add(new SelectOption('US - Dallas, TX - 3801 Herschel Ave','US - Dallas, TX - 3801 Herschel Ave'));
        offList.add(new SelectOption('US - Dallas, TX - 4099 McEwen Drive','US - Dallas, TX - 4099 McEwen Drive'));
        offList.add(new SelectOption('US - Dallas, TX - 5669 N Central Expressway','US - Dallas, TX - 5669 N Central Expressway'));
        offList.add(new SelectOption('US - Dallas, TX - 6190 Wyche Blvd','US - Dallas, TX - 6190 Wyche Blvd'));
        offList.add(new SelectOption('US - Dallas, TX - 7701 N Stemmons Freeway','US - Dallas, TX - 7701 N Stemmons Freeway'));
        offList.add(new SelectOption('US - Dallas, TX - 8001 N Stemmons','US - Dallas, TX - 8001 N Stemmons'));
        offList.add(new SelectOption('US - Dallas, TX - URS 1950 North Stemmons Freeway Suite: 600','US - Dallas, TX - URS 1950 North Stemmons Freeway Suite: 600'));
        offList.add(new SelectOption('US - Dania Beach, FL - 550 NW 10th Street','US - Dania Beach, FL - 550 NW 10th Street'));
        offList.add(new SelectOption('US - Davenport, FL - URS 305 Navarra Lane','US - Davenport, FL - URS 305 Navarra Lane'));
        offList.add(new SelectOption('US - Dayton, NJ - 111 Herrod Blvd','US - Dayton, NJ - 111 Herrod Blvd'));
        offList.add(new SelectOption('US - Dearborn, MI - URS West Park Center 5111 Auto Club Driv','US - Dearborn, MI - URS West Park Center 5111 Auto Club Driv'));
        offList.add(new SelectOption('US - Decatur, IL - 345 East Ash Avenue','US - Decatur, IL - 345 East Ash Avenue'));
        offList.add(new SelectOption('US - Decatur, IL - URS Dectur, Usod 27th St & Pershing Rd, C','US - Decatur, IL - URS Dectur, Usod 27th St & Pershing Rd, C'));
        offList.add(new SelectOption('US - Deepwater, NJ - c/o DuPont Chamber Works','US - Deepwater, NJ - c/o DuPont Chamber Works'));
        offList.add(new SelectOption('US - Deepwater, NJ - c/o DuPont Chamber Works Administration','US - Deepwater, NJ - c/o DuPont Chamber Works Administration'));
        offList.add(new SelectOption('US - Del Estanque Santiago, Peru','US - Del Estanque Santiago, Peru'));
        offList.add(new SelectOption('US - Delaware - Telecommute','US - Delaware - Telecommute'));
        offList.add(new SelectOption('US - Delmont, PA - URS 8 Bel Aire Drive','US - Delmont, PA - URS 8 Bel Aire Drive'));
        offList.add(new SelectOption('US - Delta, PA - URS Peach Bottom Atomic Power Station 1848 ','US - Delta, PA - URS Peach Bottom Atomic Power Station 1848 '));
        offList.add(new SelectOption('US - Denton, MD - 1107 Cypress Court','US - Denton, MD - 1107 Cypress Court'));
        offList.add(new SelectOption('US - Denver, CO - 15th Street and California Street','US - Denver, CO - 15th Street and California Street'));
        offList.add(new SelectOption('US - Denver, CO - 1801 California St Suite 1500','US - Denver, CO - 1801 California St Suite 1500'));
        offList.add(new SelectOption('US - Denver, CO - 24735 E 75th Avenue','US - Denver, CO - 24735 E 75th Avenue'));
        offList.add(new SelectOption('US - Denver, CO - 717 17th St','US - Denver, CO - 717 17th St'));
        offList.add(new SelectOption('US - Denver, CO - 7800 E Union Avenue','US - Denver, CO - 7800 E Union Avenue'));
        offList.add(new SelectOption('US - Denver, CO - 7800 East Union Avenue Suite 100','US - Denver, CO - 7800 East Union Avenue Suite 100'));
        offList.add(new SelectOption('US - Denver, CO - 8181 East Tufts Avenue','US - Denver, CO - 8181 East Tufts Avenue'));
        offList.add(new SelectOption('US - Denver, CO - 8500 Pena Blvd','US - Denver, CO - 8500 Pena Blvd'));
        offList.add(new SelectOption('US - Denver, Co - Sos. Pipera nr 2/II, North Center, 3rd flo','US - Denver, Co - Sos. Pipera nr 2/II, North Center, 3rd flo'));
        offList.add(new SelectOption('US - Denver, CO - URS 1441 S Ulster','US - Denver, CO - URS 1441 S Ulster'));
        offList.add(new SelectOption('US - Denver, CO - URS 7800 E. Union Ave Suite: 100','US - Denver, CO - URS 7800 E. Union Ave Suite: 100'));
        offList.add(new SelectOption('US - Denver, CO - URS Civil Construction And Mining 8181 E. ','US - Denver, CO - URS Civil Construction And Mining 8181 E. '));
        offList.add(new SelectOption('US - Des Moines, IA - 132d Wing-URS/C26 3100 McKinley Ave','US - Des Moines, IA - 132d Wing-URS/C26 3100 McKinley Ave'));
        offList.add(new SelectOption('US - Des Moines, IA - 3100 Mckinley Ave','US - Des Moines, IA - 3100 Mckinley Ave'));
        offList.add(new SelectOption('US - Des Moines, IA - 500 SW 7th St','US - Des Moines, IA - 500 SW 7th St'));
        offList.add(new SelectOption('US - Destin, FL - 4300 Legendary Dr','US - Destin, FL - 4300 Legendary Dr'));
        offList.add(new SelectOption('US - Detroit, MI - 11411 E Jefferson Avenue','US - Detroit, MI - 11411 E Jefferson Avenue'));
        offList.add(new SelectOption('US - Detroit, MI - 400 Monroe Street International Center Bu','US - Detroit, MI - 400 Monroe Street International Center Bu'));
        offList.add(new SelectOption('US - Detroit, MI - 985 Michigan Third Floor','US - Detroit, MI - 985 Michigan Third Floor'));
        offList.add(new SelectOption('US - District of Columbia - Telecommute','US - District of Columbia - Telecommute'));
        offList.add(new SelectOption('US - Djibouti','US - Djibouti'));
        offList.add(new SelectOption('US - DM AFB, AZ - 5220 East Gafford Way','US - DM AFB, AZ - 5220 East Gafford Way'));
        offList.add(new SelectOption('US - Doha, Qatar','US - Doha, Qatar'));
        offList.add(new SelectOption('US - Doha, Qatar - Pearl Bldg PO Box 6650','US - Doha, Qatar - Pearl Bldg PO Box 6650'));
        offList.add(new SelectOption('US - Doha, Qatar - United Car Al-Mana Building','US - Doha, Qatar - United Car Al-Mana Building'));
        offList.add(new SelectOption('US - Dover, DE - 436th Medical Group 300 Tuskegee Ave Suite ','US - Dover, DE - 436th Medical Group 300 Tuskegee Ave Suite '));
        offList.add(new SelectOption('US - Dripping Springs, TX - 1001 Stagecoach Ranch Road','US - Dripping Springs, TX - 1001 Stagecoach Ranch Road'));
        offList.add(new SelectOption('US - Dulles, VA','US - Dulles, VA'));
        offList.add(new SelectOption('US - Duluth, MN - 11 East Superior Street','US - Duluth, MN - 11 East Superior Street'));
        offList.add(new SelectOption('US - Durango, CO - 211 Rock Point Dr','US - Durango, CO - 211 Rock Point Dr'));
        offList.add(new SelectOption('US - Durham, NC - 301 Roycroft Drive','US - Durham, NC - 301 Roycroft Drive'));
        offList.add(new SelectOption('US - Durham, NC - URS 4222 Emperor Blvd','US - Durham, NC - URS 4222 Emperor Blvd'));
        offList.add(new SelectOption('US - Dyersburg, TN - URS Caterpillar Inc 2000 Hoff Rd','US - Dyersburg, TN - URS Caterpillar Inc 2000 Hoff Rd'));
        offList.add(new SelectOption('US - Eagle Pass, TX - URS C/O Towne Place Suites - Attn Will','US - Eagle Pass, TX - URS C/O Towne Place Suites - Attn Will'));
        offList.add(new SelectOption('US - East China Twp, MI - URS Dte Energy, St. Clair Power Pl','US - East China Twp, MI - URS Dte Energy, St. Clair Power Pl'));
        offList.add(new SelectOption('US - East Elmhurst, NY - 75-20 Astoria Blvd','US - East Elmhurst, NY - 75-20 Astoria Blvd'));
        offList.add(new SelectOption('US - East Islip, NY - 164 Easy Main Street','US - East Islip, NY - 164 Easy Main Street'));
        offList.add(new SelectOption('US - East Peoria, IL - URS 901 W Washington Street','US - East Peoria, IL - URS 901 W Washington Street'));
        offList.add(new SelectOption('US - East Peoria, IL - URS Cat-Process 901 W. Washington St ','US - East Peoria, IL - URS Cat-Process 901 W. Washington St '));
        offList.add(new SelectOption('US - East Peoria, IL - URS Proving Grounds(Ppg) Caterpillar ','US - East Peoria, IL - URS Proving Grounds(Ppg) Caterpillar '));
        offList.add(new SelectOption('US - East Peoria, IL - URS Usoep 901 W Washington St Bldg Ss','US - East Peoria, IL - URS Usoep 901 W Washington St Bldg Ss'));
        offList.add(new SelectOption('US - East Syracuse, NY - 5015 Campuswood Dr','US - East Syracuse, NY - 5015 Campuswood Dr'));
        offList.add(new SelectOption('US - East Windsor, NJ - 50 Millstone Rd','US - East Windsor, NJ - 50 Millstone Rd'));
        offList.add(new SelectOption('US - Eatontown, NJ - 42 Buttonwood Ave','US - Eatontown, NJ - 42 Buttonwood Ave'));
        offList.add(new SelectOption('US - Eddystone, PA - URS Eddystone Generating Station 1 Indu','US - Eddystone, PA - URS Eddystone Generating Station 1 Indu'));
        offList.add(new SelectOption('US - Egg Harbor Township, NJ','US - Egg Harbor Township, NJ'));
        offList.add(new SelectOption('US - Eielson AFB, AK - 2421 Flightline Ave, Bldg. 1138','US - Eielson AFB, AK - 2421 Flightline Ave, Bldg. 1138'));
        offList.add(new SelectOption('US - El Centro, CA - 1115 North Imperial Ave','US - El Centro, CA - 1115 North Imperial Ave'));
        offList.add(new SelectOption('US - El Centro, CA - Bldg. 514 8th Street','US - El Centro, CA - Bldg. 514 8th Street'));
        offList.add(new SelectOption('US - El Centro, CA - Naval Air Facility El Centro, CA','US - El Centro, CA - Naval Air Facility El Centro, CA'));
        offList.add(new SelectOption('US - El Paso, TX - 1 Ballpark Plaza','US - El Paso, TX - 1 Ballpark Plaza'));
        offList.add(new SelectOption('US - El Paso, TX - Ft Bliss DOL','US - El Paso, TX - Ft Bliss DOL'));
        offList.add(new SelectOption('US - El Paso, TX - William Baumont Army Medical Center 5005 ','US - El Paso, TX - William Baumont Army Medical Center 5005 '));
        offList.add(new SelectOption('US - Elizabeth City, NC - 1335 Possum Quater Road','US - Elizabeth City, NC - 1335 Possum Quater Road'));
        offList.add(new SelectOption('US - Ellsworth AFB, SD - 1432 Spaatz Dr Bldg 1008','US - Ellsworth AFB, SD - 1432 Spaatz Dr Bldg 1008'));
        offList.add(new SelectOption('US - Ellworth AFB, SD - 1008 Spatz Drive','US - Ellworth AFB, SD - 1008 Spatz Drive'));
        offList.add(new SelectOption('US - Englewood, CO - 5575 Dtc Pkwy','US - Englewood, CO - 5575 Dtc Pkwy'));
        offList.add(new SelectOption('US - Englewood, CO - URS 6901 South Havana Street','US - Englewood, CO - URS 6901 South Havana Street'));
        offList.add(new SelectOption('US - Enterprise, AL - Building 4509, 3rd Floor Andrews Avenu','US - Enterprise, AL - Building 4509, 3rd Floor Andrews Avenu'));
        offList.add(new SelectOption('US - Essex Junction, VT - 30 River Road','US - Essex Junction, VT - 30 River Road'));
        return offList;
    }

    public List<SelectOption> getOfficeLocation2List() {
        List<SelectOption> offList = new List<SelectOption>();
        offList.add(new SelectOption('US - Evans, GA - URS 1431 Andover Ct','US - Evans, GA - URS 1431 Andover Ct'));
        offList.add(new SelectOption('US - Evansville, IN - 16 NW 6th Street','US - Evansville, IN - 16 NW 6th Street'));
        offList.add(new SelectOption('US - Evergreen, CO - URS 35715 Us Highway 40, Building D Sui','US - Evergreen, CO - URS 35715 Us Highway 40, Building D Sui'));
        offList.add(new SelectOption('US - Fairbanks, AK - Building 2077, Hangar 8, Montogmery Roa','US - Fairbanks, AK - Building 2077, Hangar 8, Montogmery Roa'));
        offList.add(new SelectOption('US - Fairfax, VA - 10304 Eaton Place','US - Fairfax, VA - 10304 Eaton Place'));
        offList.add(new SelectOption('US - Fallon, NV - Fallon Centroid Facility 32033 Austin Hwy ','US - Fallon, NV - Fallon Centroid Facility 32033 Austin Hwy '));
        offList.add(new SelectOption('US - Falls Church, VA - Skyline 7 5275 Leesburg Pike','US - Falls Church, VA - Skyline 7 5275 Leesburg Pike'));
        offList.add(new SelectOption('US - Fargo, ND - 1400 32nd Avenue North','US - Fargo, ND - 1400 32nd Avenue North'));
        offList.add(new SelectOption('US - Farmington, NM - 5736 US 64','US - Farmington, NM - 5736 US 64'));
        offList.add(new SelectOption('US - Fayetteville, GA - 12100 Fairway Overlook','US - Fayetteville, GA - 12100 Fairway Overlook'));
        offList.add(new SelectOption('US - Fayetteville, GA - 170 Sweetwater Dr','US - Fayetteville, GA - 170 Sweetwater Dr'));
        offList.add(new SelectOption('US - Fayetteville, GA - 255 Doe Hollow Trce','US - Fayetteville, GA - 255 Doe Hollow Trce'));
        offList.add(new SelectOption('US - Flint, MI','US - Flint, MI'));
        offList.add(new SelectOption('US - Flint, MI - URS Flint Engine South 2100 Bristol Road','US - Flint, MI - URS Flint Engine South 2100 Bristol Road'));
        offList.add(new SelectOption('US - Flint, MI - URS Flint Truck Assembly G3100 Van Slyke','US - Flint, MI - URS Flint Truck Assembly G3100 Van Slyke'));
        offList.add(new SelectOption('US - Flint, MI - URS Gm Flint Assembly Plant G 3100 Vanslyke','US - Flint, MI - URS Gm Flint Assembly Plant G 3100 Vanslyke'));
        offList.add(new SelectOption('US - Florence, SC - 1807 West Evans Street','US - Florence, SC - 1807 West Evans Street'));
        offList.add(new SelectOption('US - Florida - Telecommute','US - Florida - Telecommute'));
        offList.add(new SelectOption('US - Flushing, NY - Billie Jean King Tennis Center','US - Flushing, NY - Billie Jean King Tennis Center'));
        offList.add(new SelectOption('US - Fort AP Hill, VA - 10675 Lumpkin Road','US - Fort AP Hill, VA - 10675 Lumpkin Road'));
        offList.add(new SelectOption('US - Fort Belvior, VA - 9820 Belvoir Road','US - Fort Belvior, VA - 9820 Belvoir Road'));
        offList.add(new SelectOption('US - Fort Belvoir, VA - RDER-NVC-HD 10221 Burbeck Rd','US - Fort Belvoir, VA - RDER-NVC-HD 10221 Burbeck Rd'));
        offList.add(new SelectOption('US - Fort Benning, GA - Bldg 5514 8th Division Road','US - Fort Benning, GA - Bldg 5514 8th Division Road'));
        offList.add(new SelectOption('US - Fort Benning, GA - Martin ACH 7950 Martin Loop','US - Fort Benning, GA - Martin ACH 7950 Martin Loop'));
        offList.add(new SelectOption('US - Fort Bragg, NC - 100 Malvesti Drive Bldg 2147 J3','US - Fort Bragg, NC - 100 Malvesti Drive Bldg 2147 J3'));
        offList.add(new SelectOption('US - Fort Bragg, NC - Shipping Address: Building 2-2404 Wood','US - Fort Bragg, NC - Shipping Address: Building 2-2404 Wood'));
        offList.add(new SelectOption('US - Fort Carson, CO - Bldg 1882 Minick Ave','US - Fort Carson, CO - Bldg 1882 Minick Ave'));
        offList.add(new SelectOption('US - Fort Collins, CO - 1513 Webster Court','US - Fort Collins, CO - 1513 Webster Court'));
        offList.add(new SelectOption('US - Fort Collins, CO - 1601 Prospect Pkwy','US - Fort Collins, CO - 1601 Prospect Pkwy'));
        offList.add(new SelectOption('US - Fort Gordon, GA - Eisenhower AMC Bldg 300 Fisher House ','US - Fort Gordon, GA - Eisenhower AMC Bldg 300 Fisher House '));
        offList.add(new SelectOption('US - Fort Hood, TX - Darnell Army Medical Center HSX1-IMD Bl','US - Fort Hood, TX - Darnell Army Medical Center HSX1-IMD Bl'));
        offList.add(new SelectOption('US - Fort Huachuca, AZ - Raymond W Bliss Army Health Ctr 224','US - Fort Huachuca, AZ - Raymond W Bliss Army Health Ctr 224'));
        offList.add(new SelectOption('US - Fort Irwin, CA - Fort Irwin Logistics Readiness Center','US - Fort Irwin, CA - Fort Irwin Logistics Readiness Center'));
        offList.add(new SelectOption('US - Fort Irwin, CA - Langford Lake Road','US - Fort Irwin, CA - Langford Lake Road'));
        offList.add(new SelectOption('US - Fort Knox, KY - Ireland ACH 851 Ireland Ave 9th Floor','US - Fort Knox, KY - Ireland ACH 851 Ireland Ave 9th Floor'));
        offList.add(new SelectOption('US - Fort Lauderdale, FL','US - Fort Lauderdale, FL'));
        offList.add(new SelectOption('US - Fort Lauderdale, FL - 2300 W Commercial Blvd','US - Fort Lauderdale, FL - 2300 W Commercial Blvd'));
        offList.add(new SelectOption('US - Fort Lauderdale, FL - 3400 Commercial Blvd','US - Fort Lauderdale, FL - 3400 Commercial Blvd'));
        offList.add(new SelectOption('US - Fort Lauderdale, FL - 4101 Ravenswood Road','US - Fort Lauderdale, FL - 4101 Ravenswood Road'));
        offList.add(new SelectOption('US - Fort Leonard Wood, MO - Bldg 5133 Training are 211 Iowa','US - Fort Leonard Wood, MO - Bldg 5133 Training are 211 Iowa'));
        offList.add(new SelectOption('US - Fort Leonard Wood, MO - Chemical Defense Training Facil','US - Fort Leonard Wood, MO - Chemical Defense Training Facil'));
        offList.add(new SelectOption('US - Fort Leonard Wood, MO - General Leonard Wood Comm Hosp ','US - Fort Leonard Wood, MO - General Leonard Wood Comm Hosp '));
        offList.add(new SelectOption('US - Fort McCoy, WI - 200 E G Street','US - Fort McCoy, WI - 200 E G Street'));
        offList.add(new SelectOption('US - Fort Meade, MD - DISA Headquarters 6910 Cooper Ave','US - Fort Meade, MD - DISA Headquarters 6910 Cooper Ave'));
        offList.add(new SelectOption('US - Fort Meade, MD - Kimbrough ACH 2480 Llewellyn Av','US - Fort Meade, MD - Kimbrough ACH 2480 Llewellyn Av'));
        offList.add(new SelectOption('US - Fort Mill, SC - URS 3023 Hsbc Way, Mail Room 400','US - Fort Mill, SC - URS 3023 Hsbc Way, Mail Room 400'));
        offList.add(new SelectOption('US - Fort Myers, FL','US - Fort Myers, FL'));
        offList.add(new SelectOption('US - Fort Myers, FL - 4415 Metro Pkwy','US - Fort Myers, FL - 4415 Metro Pkwy'));
        offList.add(new SelectOption('US - Fort Pierce, FL - 222 Colonial Rd','US - Fort Pierce, FL - 222 Colonial Rd'));
        offList.add(new SelectOption('US - Fort Polk, LA - 7015 Radio Road Building 414','US - Fort Polk, LA - 7015 Radio Road Building 414'));
        offList.add(new SelectOption('US - Fort Polk, LA - Bayne-Jones ACH 1585 3rd Street','US - Fort Polk, LA - Bayne-Jones ACH 1585 3rd Street'));
        offList.add(new SelectOption('US - Fort Polk, LA - Bldg 8226 H Avenue','US - Fort Polk, LA - Bldg 8226 H Avenue'));
        offList.add(new SelectOption('US - Fort Rucker, AL - Lyster Army Health Clinic 301 Andrews','US - Fort Rucker, AL - Lyster Army Health Clinic 301 Andrews'));
        offList.add(new SelectOption('US - Fort Shafter, HI - Bldg T-128 Palm Circle','US - Fort Shafter, HI - Bldg T-128 Palm Circle'));
        offList.add(new SelectOption('US - Fort Snelling, MN - 506 Roeder Circle','US - Fort Snelling, MN - 506 Roeder Circle'));
        offList.add(new SelectOption('US - Fort Stewart, GA - Winn ACH 1061 Harmon Ave','US - Fort Stewart, GA - Winn ACH 1061 Harmon Ave'));
        offList.add(new SelectOption('US - Fort Worth, TX - 1200 Summit Avenue Suite 102','US - Fort Worth, TX - 1200 Summit Avenue Suite 102'));
        offList.add(new SelectOption('US - Fort Worth, TX - 1200 Summit Avenue Suite 320','US - Fort Worth, TX - 1200 Summit Avenue Suite 320'));
        offList.add(new SelectOption('US - Fort Worth, TX - 2821 Cullen St','US - Fort Worth, TX - 2821 Cullen St'));
        offList.add(new SelectOption('US - Fort Worth, TX - AIMD 900 Div. Bldg. 1401','US - Fort Worth, TX - AIMD 900 Div. Bldg. 1401'));
        offList.add(new SelectOption('US - Fort Worth, TX - Burnett Plaze, Suite 1900 801 Cherry S','US - Fort Worth, TX - Burnett Plaze, Suite 1900 801 Cherry S'));
        offList.add(new SelectOption('US - FPO, AP - MAG-36 MALS-36 Unit 37141','US - FPO, AP - MAG-36 MALS-36 Unit 37141'));
        offList.add(new SelectOption('US - Franklin, OH - 20 Sprucewood Court','US - Franklin, OH - 20 Sprucewood Court'));
        offList.add(new SelectOption('US - Franklin, TN - 1000 Corporate Centre Drive One Corporat','US - Franklin, TN - 1000 Corporate Centre Drive One Corporat'));
        offList.add(new SelectOption('US - Fredericksburg, VA - 6406 Medallion Drive','US - Fredericksburg, VA - 6406 Medallion Drive'));
        offList.add(new SelectOption('US - Fredericksburg, VA - 8601 Laroque Run Drive','US - Fredericksburg, VA - 8601 Laroque Run Drive'));
        offList.add(new SelectOption('US - Fredrick, CO - 8123 West I-25 Frontage Road','US - Fredrick, CO - 8123 West I-25 Frontage Road'));
        offList.add(new SelectOption('US - Freeport, FL - 375 Mango Lane','US - Freeport, FL - 375 Mango Lane'));
        offList.add(new SelectOption('US - Freeport, TX - 2301 N Brazosport Boulevard','US - Freeport, TX - 2301 N Brazosport Boulevard'));
        offList.add(new SelectOption('US - Freeport, TX - 2301 N Brazosport Boulevard Building BM ','US - Freeport, TX - 2301 N Brazosport Boulevard Building BM '));
        offList.add(new SelectOption('US - Fresno, CA - 1106th AVCRAD, 5168 East Dakota Avenue','US - Fresno, CA - 1106th AVCRAD, 5168 East Dakota Avenue'));
        offList.add(new SelectOption('US - Fresno, CA - 1177 Fulton Mall','US - Fresno, CA - 1177 Fulton Mall'));
        offList.add(new SelectOption('US - Fresno, CA - 1360 E Spruce Ave','US - Fresno, CA - 1360 E Spruce Ave'));
        offList.add(new SelectOption('US - Fresno, CA - 30 River Park Place Suite 180','US - Fresno, CA - 30 River Park Place Suite 180'));
        offList.add(new SelectOption('US - Fresno, CA - 5045 East Butler','US - Fresno, CA - 5045 East Butler'));
        offList.add(new SelectOption('US - Fresno, CA - 5405 E. McKinley Ave Bldg. 114','US - Fresno, CA - 5405 E. McKinley Ave Bldg. 114'));
        offList.add(new SelectOption('US - Frisco, TX - 2889 Breezy Point Lane','US - Frisco, TX - 2889 Breezy Point Lane'));
        offList.add(new SelectOption('US - Ft Irwin, CA - FORSCOM Bldg 166 Room 110 PO Box 105109','US - Ft Irwin, CA - FORSCOM Bldg 166 Room 110 PO Box 105109'));
        offList.add(new SelectOption('US - Ft Myers, FL - 10041 Daniels Parkway','US - Ft Myers, FL - 10041 Daniels Parkway'));
        offList.add(new SelectOption('US - Ft Polk, LA - 2650 Loussiana Ave Bldg 4386','US - Ft Polk, LA - 2650 Loussiana Ave Bldg 4386'));
        offList.add(new SelectOption('US - Ft. Eustis, VA - 950 Jefferson Ave (ARCIC)','US - Ft. Eustis, VA - 950 Jefferson Ave (ARCIC)'));
        offList.add(new SelectOption('US - Ft. Hood, TX - Brigade Aviation Maintenance 21st Cavalr','US - Ft. Hood, TX - Brigade Aviation Maintenance 21st Cavalr'));
        offList.add(new SelectOption('US - Ft. Irwin, CA - Bldg 851C Langford Lake Road','US - Ft. Irwin, CA - Bldg 851C Langford Lake Road'));
        offList.add(new SelectOption('US - Ft. Knox, KY - Godman Army Airfield 5222 Pilot Street','US - Ft. Knox, KY - Godman Army Airfield 5222 Pilot Street'));
        offList.add(new SelectOption('US - Ft. Lewis, WA - Bldg 3985, Cemetary Road','US - Ft. Lewis, WA - Bldg 3985, Cemetary Road'));
        offList.add(new SelectOption('US - Ft. Lewis, WA - Bldg TE1301 A Street (North Fort)','US - Ft. Lewis, WA - Bldg TE1301 A Street (North Fort)'));
        offList.add(new SelectOption('US - Gaborone, Botswana - PO Box 602090','US - Gaborone, Botswana - PO Box 602090'));
        offList.add(new SelectOption('US - Gainseville, VA - 8045 Crescent Park Drive','US - Gainseville, VA - 8045 Crescent Park Drive'));
        offList.add(new SelectOption('US - Gaithersburg, MD - 200 Orchard Ridge, Suite 100','US - Gaithersburg, MD - 200 Orchard Ridge, Suite 100'));
        offList.add(new SelectOption('US - Gaithersburg, MD - URS C/O Lockheed Martin 700 N Freder','US - Gaithersburg, MD - URS C/O Lockheed Martin 700 N Freder'));
        offList.add(new SelectOption('US - Galena Park, TX - 203 Clinton Dr','US - Galena Park, TX - 203 Clinton Dr'));
        offList.add(new SelectOption('US - Gallatin, TN - URS Tva- Gallatin Project 1499 Steam Pla','US - Gallatin, TN - URS Tva- Gallatin Project 1499 Steam Pla'));
        offList.add(new SelectOption('US - Gallatin, TN - URS Tva-Gallatin Project 1499 Steam Plan','US - Gallatin, TN - URS Tva-Gallatin Project 1499 Steam Plan'));
        offList.add(new SelectOption('US - Gao, Mali','US - Gao, Mali'));
        offList.add(new SelectOption('US - Gary, IN - 3400 Broadway','US - Gary, IN - 3400 Broadway'));
        offList.add(new SelectOption('US - George West, TX - 3165 Highway 281 North','US - George West, TX - 3165 Highway 281 North'));
        offList.add(new SelectOption('US - Georgia - Telecommute','US - Georgia - Telecommute'));
        offList.add(new SelectOption('US - Germantown, MD - 12420 Milestone Center Drive','US - Germantown, MD - 12420 Milestone Center Drive'));
        offList.add(new SelectOption('US - Germantown, MD - 20501 Seneca Meadows Parkway Suite 300','US - Germantown, MD - 20501 Seneca Meadows Parkway Suite 300'));
        offList.add(new SelectOption('US - Germantown, MD - 20501 Seneca Meadows Pkwy','US - Germantown, MD - 20501 Seneca Meadows Pkwy'));
        offList.add(new SelectOption('US - Germantown, MD - 20501 Seneca Meadows Pkwy Suite 300','US - Germantown, MD - 20501 Seneca Meadows Pkwy Suite 300'));
        offList.add(new SelectOption('US - Gig Harbor, WA - URS 1225 Sea Cliff Dr. Nw','US - Gig Harbor, WA - URS 1225 Sea Cliff Dr. Nw'));
        offList.add(new SelectOption('US - Gilbert, AZ - 4032 S Summer Court','US - Gilbert, AZ - 4032 S Summer Court'));
        offList.add(new SelectOption('US - Gilboa, NY - URS/Gilboa Dam Reconstruction 368 Route 99','US - Gilboa, NY - URS/Gilboa Dam Reconstruction 368 Route 99'));
        offList.add(new SelectOption('US - Gillette, WY - URS 113 S Gillette Ave','US - Gillette, WY - URS 113 S Gillette Ave'));
        offList.add(new SelectOption('US - Glen Allen, VA - 4840 Cox Road','US - Glen Allen, VA - 4840 Cox Road'));
        offList.add(new SelectOption('US - Glendale, AZ - 9500 W Northern Avenue','US - Glendale, AZ - 9500 W Northern Avenue'));
        offList.add(new SelectOption('US - Golden, CO - URS 448 Parkview Ave','US - Golden, CO - URS 448 Parkview Ave'));
        offList.add(new SelectOption('US - Goleta, CA - Exxon Company 12000 Calle Real','US - Goleta, CA - Exxon Company 12000 Calle Real'));
        offList.add(new SelectOption('US - Grafton, MA - 22 Church Street','US - Grafton, MA - 22 Church Street'));
        offList.add(new SelectOption('US - Grand Rapids, MI - 3950 Sparks Drive SE','US - Grand Rapids, MI - 3950 Sparks Drive SE'));
        offList.add(new SelectOption('US - Grand Rapids, MI - 5555 Glenwood Hills Pkwy SE','US - Grand Rapids, MI - 5555 Glenwood Hills Pkwy SE'));
        offList.add(new SelectOption('US - Great lakes, IL - Naval Hospital Great Lakes 3001A 6th ','US - Great lakes, IL - Naval Hospital Great Lakes 3001A 6th '));
        offList.add(new SelectOption('US - Green Bay, WI - 1035 Kepler Dr','US - Green Bay, WI - 1035 Kepler Dr'));
        offList.add(new SelectOption('US - Green River, WY - 1415 West Teton Blvd','US - Green River, WY - 1415 West Teton Blvd'));
        offList.add(new SelectOption('US - Greenville, SC - 10 Patewood Dr','US - Greenville, SC - 10 Patewood Dr'));
        offList.add(new SelectOption('US - Greenville, SC - 11 Brendan Way Suite 140','US - Greenville, SC - 11 Brendan Way Suite 140'));
        offList.add(new SelectOption('US - Greenville, SC - 128 Millport Circle','US - Greenville, SC - 128 Millport Circle'));
        offList.add(new SelectOption('US - Greenwich, CT','US - Greenwich, CT'));
        offList.add(new SelectOption('US - Greenwood Village, CO - 5445 DTC Parkway, Suite 600','US - Greenwood Village, CO - 5445 DTC Parkway, Suite 600'));
        offList.add(new SelectOption('US - Greenwood, IN - 2717 S Morgantown Road','US - Greenwood, IN - 2717 S Morgantown Road'));
        offList.add(new SelectOption('US - Groton, CT - 349B Mitchell Street','US - Groton, CT - 349B Mitchell Street'));
        offList.add(new SelectOption('US - Groton, CT - 70 Bridge Street','US - Groton, CT - 70 Bridge Street'));
        offList.add(new SelectOption('US - Groton, CT - 75 Eastern Point Rd','US - Groton, CT - 75 Eastern Point Rd'));
        offList.add(new SelectOption('US - Groton, CT - MSRA Facility SUBASE PO Box 300 B-153','US - Groton, CT - MSRA Facility SUBASE PO Box 300 B-153'));
        offList.add(new SelectOption('US - Groton, CT - MTST Sub Learning Cntr Naval Subase New Lo','US - Groton, CT - MTST Sub Learning Cntr Naval Subase New Lo'));
        offList.add(new SelectOption('US - Groton, CT - Naval Branch Health Clinic 1 Wahoo Drive','US - Groton, CT - Naval Branch Health Clinic 1 Wahoo Drive'));
        offList.add(new SelectOption('US - Groton, CT - Sub Tech Support Cntr Naval Sub Base PO Bo','US - Groton, CT - Sub Tech Support Cntr Naval Sub Base PO Bo'));
        offList.add(new SelectOption('US - Groton, CT - URS 558 Eastern Point Road','US - Groton, CT - URS 558 Eastern Point Road'));
        offList.add(new SelectOption('US - Groton, CT - URS C/O Urs/Pfizer 284 Shennecossett Road','US - Groton, CT - URS C/O Urs/Pfizer 284 Shennecossett Road'));
        offList.add(new SelectOption('US - Guaynabo, PR - Metro Office Park 2 NA Street','US - Guaynabo, PR - Metro Office Park 2 NA Street'));
        offList.add(new SelectOption('US - Hagatna, GU - 108 Hernan Cortez Ave, suite 100','US - Hagatna, GU - 108 Hernan Cortez Ave, suite 100'));
        offList.add(new SelectOption('US - Hagatna, Guam - 414 W Soledad Ave','US - Hagatna, Guam - 414 W Soledad Ave'));
        offList.add(new SelectOption('US - Hampton, GA - 10640 Wimbelton Ct','US - Hampton, GA - 10640 Wimbelton Ct'));
        offList.add(new SelectOption('US - Hampton, GA - 10642 Day Lily Dr','US - Hampton, GA - 10642 Day Lily Dr'));
        offList.add(new SelectOption('US - Hanahan, SC - One Innovation Drive Bldg 3112','US - Hanahan, SC - One Innovation Drive Bldg 3112'));
        offList.add(new SelectOption('US - Hancocks Bridge, NJ - URS C/O Pseg Nuclear Llc Po Box 2','US - Hancocks Bridge, NJ - URS C/O Pseg Nuclear Llc Po Box 2'));
        offList.add(new SelectOption('US - Hanscom AFB, MA - 25 Langley Rd.','US - Hanscom AFB, MA - 25 Langley Rd.'));
        offList.add(new SelectOption('US - Harker Heights, TX - 3304 Oak Ridge','US - Harker Heights, TX - 3304 Oak Ridge'));
        offList.add(new SelectOption('US - Harrisburg, PA - 4507 North Front Street','US - Harrisburg, PA - 4507 North Front Street'));
        offList.add(new SelectOption('US - Harrisburg, PA - 4507 North Front Street Suite 200','US - Harrisburg, PA - 4507 North Front Street Suite 200'));
        offList.add(new SelectOption('US - Hartsville, SC - URS Robinson Power Plant 3581 W Entran','US - Hartsville, SC - URS Robinson Power Plant 3581 W Entran'));
        offList.add(new SelectOption('US - Haskell, TX - URS Ett Crez 11780 Loop Rd','US - Haskell, TX - URS Ett Crez 11780 Loop Rd'));
        offList.add(new SelectOption('US - Hawaii - Telecommute','US - Hawaii - Telecommute'));
        offList.add(new SelectOption('US - Haynesville, LA - 9788 Hwy 79','US - Haynesville, LA - 9788 Hwy 79'));
        offList.add(new SelectOption('US - Hayward, CA - URS 3526 Breakwater Court','US - Hayward, CA - URS 3526 Breakwater Court'));
        offList.add(new SelectOption('US - Helena, MT - 2800 Skyway Drive','US - Helena, MT - 2800 Skyway Drive'));
        offList.add(new SelectOption('US - Helotes, TX - 9510 Kelsey Cove','US - Helotes, TX - 9510 Kelsey Cove'));
        offList.add(new SelectOption('US - Henderson, NV - 258 Chestnut Ridge Circle','US - Henderson, NV - 258 Chestnut Ridge Circle'));
        offList.add(new SelectOption('US - Herlong, CA - PO Box 30, Bldg #201, Sierra Army Depot','US - Herlong, CA - PO Box 30, Bldg #201, Sierra Army Depot'));
        offList.add(new SelectOption('US - Herndon, VA - 13825 Sunrise Valley Drive','US - Herndon, VA - 13825 Sunrise Valley Drive'));
        offList.add(new SelectOption('US - Herndon, VA - 13825 Sunrise Valley Drive Suite 250','US - Herndon, VA - 13825 Sunrise Valley Drive Suite 250'));
        offList.add(new SelectOption('US - Herndon, VA - 380 Herndon Pkwy','US - Herndon, VA - 380 Herndon Pkwy'));
        offList.add(new SelectOption('US - Herriman, UT - 13708 S. Manas Way','US - Herriman, UT - 13708 S. Manas Way'));
        offList.add(new SelectOption('US - Hialeah, FL - 5880 NW 183rd Street','US - Hialeah, FL - 5880 NW 183rd Street'));
        offList.add(new SelectOption('US - High Holborn, London','US - High Holborn, London'));
        offList.add(new SelectOption('US - Highland, CA - URS 27400 E Fifth St','US - Highland, CA - URS 27400 E Fifth St'));
        offList.add(new SelectOption('US - Highland, CA - URS 27400 E Fifth Street','US - Highland, CA - URS 27400 E Fifth Street'));
        offList.add(new SelectOption('US - Highlands Ranch, CO - 10156 Alexa Lane','US - Highlands Ranch, CO - 10156 Alexa Lane'));
        offList.add(new SelectOption('US - Hill AFB, UT - 5851 F Avenue DDHU, Bldg 849 - Rm 285','US - Hill AFB, UT - 5851 F Avenue DDHU, Bldg 849 - Rm 285'));
        offList.add(new SelectOption('US - Hilo, HI','US - Hilo, HI'));
        offList.add(new SelectOption('US - Hobbs, MN - 1909 W Marland','US - Hobbs, MN - 1909 W Marland'));
        offList.add(new SelectOption('US - Holloman AFB, NM - 1022 5th Street','US - Holloman AFB, NM - 1022 5th Street'));
        offList.add(new SelectOption('US - Holloman AFB, NM - P.O. Box Drawer R','US - Holloman AFB, NM - P.O. Box Drawer R'));
        offList.add(new SelectOption('US - Holloman Air Force Base, NM - 1644 Vandergrift Road','US - Holloman Air Force Base, NM - 1644 Vandergrift Road'));
        offList.add(new SelectOption('US - Hollywood, FL - 2 Oakwook Blvd','US - Hollywood, FL - 2 Oakwook Blvd'));
        offList.add(new SelectOption('US - Hollywood, FL - 6565 Taft Street','US - Hollywood, FL - 6565 Taft Street'));
        offList.add(new SelectOption('US - Holtsville, NY - 1040 Waverly Avenue Stop 920','US - Holtsville, NY - 1040 Waverly Avenue Stop 920'));
        offList.add(new SelectOption('US - Holtsville, NY - 30 Barretts Ave','US - Holtsville, NY - 30 Barretts Ave'));
        offList.add(new SelectOption('US - Honolulu, HI - 1001 Bishop St','US - Honolulu, HI - 1001 Bishop St'));
        offList.add(new SelectOption('US - Honolulu, HI - 500 Ala Moana Blvd','US - Honolulu, HI - 500 Ala Moana Blvd'));
        offList.add(new SelectOption('US - Honolulu, HI - 595 Ala Moana Blvd','US - Honolulu, HI - 595 Ala Moana Blvd'));
        offList.add(new SelectOption('US - Honolulu, HI - Davies Pacific Center 841 Bishop Street ','US - Honolulu, HI - Davies Pacific Center 841 Bishop Street '));
        offList.add(new SelectOption('US - Honolulu, HI - Tripler Army Medical Center 1 Jarret Whi','US - Honolulu, HI - Tripler Army Medical Center 1 Jarret Whi'));
        offList.add(new SelectOption('US - Honolulu, HI - URS 3007a Wailani Road','US - Honolulu, HI - URS 3007a Wailani Road'));
        offList.add(new SelectOption('US - Hooks, TX - 300 Andrews Street','US - Hooks, TX - 300 Andrews Street'));
        offList.add(new SelectOption('US - Horsham, PA - 125 Rock Rd','US - Horsham, PA - 125 Rock Rd'));
        offList.add(new SelectOption('US - Houston, TX - 10550 Richmond Avenue Suite 155','US - Houston, TX - 10550 Richmond Avenue Suite 155'));
        offList.add(new SelectOption('US - Houston, TX - 1130 John Freeman Blvd','US - Houston, TX - 1130 John Freeman Blvd'));
        offList.add(new SelectOption('US - Houston, TX - 126 Northpoint Drive','US - Houston, TX - 126 Northpoint Drive'));
        offList.add(new SelectOption('US - Houston, TX - 140 Cypress Station','US - Houston, TX - 140 Cypress Station'));
        offList.add(new SelectOption('US - Houston, TX - 14657 Sneider St Bldg 1258','US - Houston, TX - 14657 Sneider St Bldg 1258'));
        offList.add(new SelectOption('US - Houston, TX - 14657 Sneider Street','US - Houston, TX - 14657 Sneider Street'));
        offList.add(new SelectOption('US - Houston, TX - 18220 Tomball Pkwy','US - Houston, TX - 18220 Tomball Pkwy'));
        offList.add(new SelectOption('US - Houston, TX - 19219 Katy Freeway','US - Houston, TX - 19219 Katy Freeway'));
        offList.add(new SelectOption('US - Houston, TX - 19219 Katy Freeway Suite 100','US - Houston, TX - 19219 Katy Freeway Suite 100'));
        offList.add(new SelectOption('US - Houston, TX - 19219 Katy Freeway, Suite 100','US - Houston, TX - 19219 Katy Freeway, Suite 100'));
        offList.add(new SelectOption('US - Houston, TX - 5444 Westheimer Road','US - Houston, TX - 5444 Westheimer Road'));
        offList.add(new SelectOption('US - Houston, TX - 5757 Woodway Dr','US - Houston, TX - 5757 Woodway Dr'));
        offList.add(new SelectOption('US - Houston, TX - 601 Jefferson Street','US - Houston, TX - 601 Jefferson Street'));
        offList.add(new SelectOption('US - Houston, TX - URS 14035 Industrial Dr','US - Houston, TX - URS 14035 Industrial Dr'));
        offList.add(new SelectOption('US - Houston, TX - URS 19219 Katy Freeway','US - Houston, TX - URS 19219 Katy Freeway'));
        offList.add(new SelectOption('US - Houston, TX - URS Air Liquide 2700 Post Oak Blvd. Suite','US - Houston, TX - URS Air Liquide 2700 Post Oak Blvd. Suite'));
        offList.add(new SelectOption('US - Houston, TX - URS Houston Power Office 1111 Fannin Stre','US - Houston, TX - URS Houston Power Office 1111 Fannin Stre'));
        offList.add(new SelectOption('US - Houston, TX - URS Rust 19219 Katy Freeway- Ste: 100','US - Houston, TX - URS Rust 19219 Katy Freeway- Ste: 100'));
        offList.add(new SelectOption('US - Huber Heights, OH - 8653 Taylorsville Rd','US - Huber Heights, OH - 8653 Taylorsville Rd'));
        offList.add(new SelectOption('US - Hunt Valley, MD - 4 North Park Drive','US - Hunt Valley, MD - 4 North Park Drive'));
        offList.add(new SelectOption('US - Huntersville, NC - URS 13225 Hagers Ferry Rd.','US - Huntersville, NC - URS 13225 Hagers Ferry Rd.'));
        offList.add(new SelectOption('US - Huntington Beach, CA - P.O. Box 2388','US - Huntington Beach, CA - P.O. Box 2388'));
        offList.add(new SelectOption('US - Huntsville, AL - 310 The Bridge Street','US - Huntsville, AL - 310 The Bridge Street'));
        offList.add(new SelectOption('US - Huntsville, AL - 675 Discovery Dr. Suite 301','US - Huntsville, AL - 675 Discovery Dr. Suite 301'));
        offList.add(new SelectOption('US - Huntsville, AL - 675 Discovery Drive','US - Huntsville, AL - 675 Discovery Drive'));
        offList.add(new SelectOption('US - Huntsville, AL - 7115 Old Madison Pike','US - Huntsville, AL - 7115 Old Madison Pike'));
        offList.add(new SelectOption('US - Huntsville, AL - MSFC Building 4471, Room 101 Po Box 90','US - Huntsville, AL - MSFC Building 4471, Room 101 Po Box 90'));
        offList.add(new SelectOption('US - Huntsville, AL - Redstone Arsenal','US - Huntsville, AL - Redstone Arsenal'));
        offList.add(new SelectOption('US - Hurlburt AFB, FL - 814 Tuly Street','US - Hurlburt AFB, FL - 814 Tuly Street'));
        offList.add(new SelectOption('US - Hyattsville, MD - 6525 Belcrest Rd','US - Hyattsville, MD - 6525 Belcrest Rd'));
        offList.add(new SelectOption('US - Idaho - Telecommute','US - Idaho - Telecommute'));
        offList.add(new SelectOption('US - IDAHO FALLS, ID - 1955 N. Freemont','US - IDAHO FALLS, ID - 1955 N. Freemont'));
        offList.add(new SelectOption('US - Ijamsville, MD - 9639 Doctor Perry Road Suite 214S','US - Ijamsville, MD - 9639 Doctor Perry Road Suite 214S'));
        offList.add(new SelectOption('US - Illinois - Telecommute','US - Illinois - Telecommute'));
        offList.add(new SelectOption('US - Indian Springs, NV - 432 WG/UASOCS 2nd St','US - Indian Springs, NV - 432 WG/UASOCS 2nd St'));
        offList.add(new SelectOption('US - Indian Springs, NV - Bay 2 Room 15703 Bldg 1004 Perimet','US - Indian Springs, NV - Bay 2 Room 15703 Bldg 1004 Perimet'));
        offList.add(new SelectOption('US - Indian Springs, NV - GA/ASI-Building 273 Permeter Road ','US - Indian Springs, NV - GA/ASI-Building 273 Permeter Road '));
        offList.add(new SelectOption('US - Indiana - Telecommute','US - Indiana - Telecommute'));
        offList.add(new SelectOption('US - Indianapolis, IN - 2450 South Tibbs Avenue','US - Indianapolis, IN - 2450 South Tibbs Avenue'));
        offList.add(new SelectOption('US - Indianapolis, IN - 301 N University Blvd','US - Indianapolis, IN - 301 N University Blvd'));
        offList.add(new SelectOption('US - Indianapolis, IN - 4030 Vincennes Road','US - Indianapolis, IN - 4030 Vincennes Road'));
        offList.add(new SelectOption('US - Indianapolis, IN - 420 University Blvd','US - Indianapolis, IN - 420 University Blvd'));
        offList.add(new SelectOption('US - Indianapolis, IN - 4790 W 16th Street','US - Indianapolis, IN - 4790 W 16th Street'));
        offList.add(new SelectOption('US - Indianapolis, IN - 50 W Washington Street','US - Indianapolis, IN - 50 W Washington Street'));
        offList.add(new SelectOption('US - Indianapolis, IN - 9115 Hague Road','US - Indianapolis, IN - 9115 Hague Road'));
        offList.add(new SelectOption('US - Indianapolis, IN - 9701 Billings Road','US - Indianapolis, IN - 9701 Billings Road'));
        offList.add(new SelectOption('US - Indianapolis, IN - One Indiana Square Suite 2100','US - Indianapolis, IN - One Indiana Square Suite 2100'));
        offList.add(new SelectOption('US - Iowa - Telecommute','US - Iowa - Telecommute'));
        offList.add(new SelectOption('US - Irmo, SC - 636 Gaelens Lane','US - Irmo, SC - 636 Gaelens Lane'));
        offList.add(new SelectOption('US - Irvine, CA - 2020 Main Street','US - Irvine, CA - 2020 Main Street'));
        offList.add(new SelectOption('US - Irving, TX - 4500 Fuller Drive','US - Irving, TX - 4500 Fuller Drive'));
        offList.add(new SelectOption('US - Jackson, MS - 111 East Capitol Street Suite 400','US - Jackson, MS - 111 East Capitol Street Suite 400'));
        offList.add(new SelectOption('US - Jacksonville, FL','US - Jacksonville, FL'));
        offList.add(new SelectOption('US - Jacksonville, FL - 30 Yorktown Ave','US - Jacksonville, FL - 30 Yorktown Ave'));
        offList.add(new SelectOption('US - Jacksonville, FL - 4168 Southpoint Parkway','US - Jacksonville, FL - 4168 Southpoint Parkway'));
        offList.add(new SelectOption('US - Jacksonville, FL - 4168 Southpoint Parkway Suite 205','US - Jacksonville, FL - 4168 Southpoint Parkway Suite 205'));
        offList.add(new SelectOption('US - Jacksonville, FL - 5880 Channel View Blvd Bldg. 6D2','US - Jacksonville, FL - 5880 Channel View Blvd Bldg. 6D2'));
        offList.add(new SelectOption('US - Jacksonville, FL - 6801 Roosevelt Blvd','US - Jacksonville, FL - 6801 Roosevelt Blvd'));
        offList.add(new SelectOption('US - Jacksonville, FL - 701 West Adams Street','US - Jacksonville, FL - 701 West Adams Street'));
        offList.add(new SelectOption('US - Jacksonville, FL - Bldg. 200 DRP 024','US - Jacksonville, FL - Bldg. 200 DRP 024'));
        offList.add(new SelectOption('US - Jacksonville, FL - Naval Hospital Jacksonville 2080 Chi','US - Jacksonville, FL - Naval Hospital Jacksonville 2080 Chi'));
        offList.add(new SelectOption('US - Jacksonville, FL - URS Federal Services 171 Macon Road,','US - Jacksonville, FL - URS Federal Services 171 Macon Road,'));
        offList.add(new SelectOption('US - Jacksonville, FL - Yorktown Ave, Bldg 110, Door 1 Jacks','US - Jacksonville, FL - Yorktown Ave, Bldg 110, Door 1 Jacks'));
        offList.add(new SelectOption('US - Jamaica, NY - JFK Airport','US - Jamaica, NY - JFK Airport'));
        offList.add(new SelectOption('US - Jeddah, Saudi Arabia - Sultan Center Bldg','US - Jeddah, Saudi Arabia - Sultan Center Bldg'));
        offList.add(new SelectOption('US - Jenkinsville, SC - URS V C Summer Site 14368 Highway 21','US - Jenkinsville, SC - URS V C Summer Site 14368 Highway 21'));
        offList.add(new SelectOption('US - Jersey City, NJ - URS Hudson Bergen O&M 20 Caven Point ','US - Jersey City, NJ - URS Hudson Bergen O&M 20 Caven Point '));
        offList.add(new SelectOption('US - Johns Creek, GA - 11460 Johns Creek Parkway','US - Johns Creek, GA - 11460 Johns Creek Parkway'));
        offList.add(new SelectOption('US - Johnstown, PA - Aasf # 2 292 Aviation Drive','US - Johnstown, PA - Aasf # 2 292 Aviation Drive'));
        offList.add(new SelectOption('US - Joint Base Elmendorf Richardso, AK - 8535 Wewak Drive J','US - Joint Base Elmendorf Richardso, AK - 8535 Wewak Drive J'));
        offList.add(new SelectOption('US - Jonesboro, GA - 289 Kendrick Estates Drive','US - Jonesboro, GA - 289 Kendrick Estates Drive'));
        offList.add(new SelectOption('US - Jonesboro, GA - 362 Tara Beach Lane','US - Jonesboro, GA - 362 Tara Beach Lane'));
        offList.add(new SelectOption('US - Juba, Sudan - PO Box 18','US - Juba, Sudan - PO Box 18'));
        offList.add(new SelectOption('US - Kailua Kona, HI - URS 75-370 Aloha Kona Drive','US - Kailua Kona, HI - URS 75-370 Aloha Kona Drive'));
        offList.add(new SelectOption('US - Kandahar, Afghanistan','US - Kandahar, Afghanistan'));
        offList.add(new SelectOption('US - Kaneohe, HI - 45-180 Mahalani Pl Unit 8','US - Kaneohe, HI - 45-180 Mahalani Pl Unit 8'));
        offList.add(new SelectOption('US - Kaneohe, HI - MAET, Bldg 222, Room 212, E Street','US - Kaneohe, HI - MAET, Bldg 222, Room 212, E Street'));
        offList.add(new SelectOption('US - Kansas - Telecommute','US - Kansas - Telecommute'));
        offList.add(new SelectOption('US - Kansas City, MO - 2380 McGee St','US - Kansas City, MO - 2380 McGee St'));
        offList.add(new SelectOption('US - Kansas City, MO - 333 West Pershing Road Mail Stop 0600','US - Kansas City, MO - 333 West Pershing Road Mail Stop 0600'));
        offList.add(new SelectOption('US - Kaukauna, WI - URS Team Industries Inc 1200 Maloney Roa','US - Kaukauna, WI - URS Team Industries Inc 1200 Maloney Roa'));
        offList.add(new SelectOption('US - Kearneysville, WV - 250 Murall Drive Mail Stop 2221','US - Kearneysville, WV - 250 Murall Drive Mail Stop 2221'));
        offList.add(new SelectOption('US - Kennedy Space Center, FL - PO Box 21025, MS:ISC-001','US - Kennedy Space Center, FL - PO Box 21025, MS:ISC-001'));
        offList.add(new SelectOption('US - Kennett Square, PA - URS Excelon Marog Office Suite 210','US - Kennett Square, PA - URS Excelon Marog Office Suite 210'));
        offList.add(new SelectOption('US - Kenova, WV - 1505 Beech Street','US - Kenova, WV - 1505 Beech Street'));
        offList.add(new SelectOption('US - Kenova, WV - URS 333 Valley Lake Drive','US - Kenova, WV - URS 333 Valley Lake Drive'));
        offList.add(new SelectOption('US - Kent, OH - URS Akron Water Supply Plant 1570 Ravenna Ro','US - Kent, OH - URS Akron Water Supply Plant 1570 Ravenna Ro'));
        offList.add(new SelectOption('US - Kentucky - Telecommute','US - Kentucky - Telecommute'));
        offList.add(new SelectOption('US - Key West, FL - Naval Air Station','US - Key West, FL - Naval Air Station'));
        offList.add(new SelectOption('US - Khartoum, Sudan','US - Khartoum, Sudan'));
        offList.add(new SelectOption('US - Kilgore, TX - 2105 Hwy 31 East','US - Kilgore, TX - 2105 Hwy 31 East'));
        offList.add(new SelectOption('US - KNOXVILLE, TN - 2410 Cherahala Boulevard','US - KNOXVILLE, TN - 2410 Cherahala Boulevard'));
        offList.add(new SelectOption('US - La Jolla, CA - 4225 Executive Square','US - La Jolla, CA - 4225 Executive Square'));
        offList.add(new SelectOption('US - Lacey, WA - 7307 39th Ct, SE','US - Lacey, WA - 7307 39th Ct, SE'));
        offList.add(new SelectOption('US - Lackland AFB, TX - 1517 Billy Mitchell Blvd, Bldg 954','US - Lackland AFB, TX - 1517 Billy Mitchell Blvd, Bldg 954'));
        offList.add(new SelectOption('US - Laguna Niguel, CA – 24000 Avila Road #3205','US - Laguna Niguel, CA – 24000 Avila Road #3205'));
        offList.add(new SelectOption('US - Lake Mary, FL - 300 Colonial Center Pkwy','US - Lake Mary, FL - 300 Colonial Center Pkwy'));
        offList.add(new SelectOption('US - Lake Mary, FL - 367 Crystal Ridge Way','US - Lake Mary, FL - 367 Crystal Ridge Way'));
        offList.add(new SelectOption('US - Lakehurst, NJ - Hangar 5, Building 194','US - Lakehurst, NJ - Hangar 5, Building 194'));
        offList.add(new SelectOption('US - Lakeland, FL - 1000 Longfellow Blvd','US - Lakeland, FL - 1000 Longfellow Blvd'));
        offList.add(new SelectOption('US - Lakeland, FL - 500 South Florida Ave Suite 400','US - Lakeland, FL - 500 South Florida Ave Suite 400'));
        offList.add(new SelectOption('US - Lakewood, CO - 7125 W Jefferson Ave','US - Lakewood, CO - 7125 W Jefferson Ave'));
        offList.add(new SelectOption('US - Lanham, MD - 5000 Ellin Road Room A0503','US - Lanham, MD - 5000 Ellin Road Room A0503'));
        offList.add(new SelectOption('US - Lansing, MI - URS 510 Olds Ave','US - Lansing, MI - URS 510 Olds Ave'));
        offList.add(new SelectOption('US - Laredo, TX - 303 Union Pacific Blvd','US - Laredo, TX - 303 Union Pacific Blvd'));
        offList.add(new SelectOption('US - Las Vegas, NV - 181 E Warm Springs Road','US - Las Vegas, NV - 181 E Warm Springs Road'));
        offList.add(new SelectOption('US - Las Vegas, NV - 250 Pilot Rd','US - Las Vegas, NV - 250 Pilot Rd'));
        offList.add(new SelectOption('US - Las Vegas, NV - 3373 Pepper Lane','US - Las Vegas, NV - 3373 Pepper Lane'));
        offList.add(new SelectOption('US - Las Vegas, NV - 7660 W Cheyenne Ave','US - Las Vegas, NV - 7660 W Cheyenne Ave'));
        offList.add(new SelectOption('US - Las Vegas, NV - 811 Grier Drive','US - Las Vegas, NV - 811 Grier Drive'));
        offList.add(new SelectOption('US - Las Vegas, NV - 811 Grier Rd, Ste A','US - Las Vegas, NV - 811 Grier Rd, Ste A'));
        offList.add(new SelectOption('US - Las Vegas, NV - URS Urs Corporation 811 Grier Drive','US - Las Vegas, NV - URS Urs Corporation 811 Grier Drive'));
        offList.add(new SelectOption('US - Latham, NY - 1086 Troy-Schenectady Road','US - Latham, NY - 1086 Troy-Schenectady Road'));
        offList.add(new SelectOption('US - Latham, NY - 40 British American Blvd','US - Latham, NY - 40 British American Blvd'));
        offList.add(new SelectOption('US - Lawton, OK - Reynolds Army Comm Hosp 4300 Moway Road','US - Lawton, OK - Reynolds Army Comm Hosp 4300 Moway Road'));
        offList.add(new SelectOption('US - Lazaro Cardenas, Mexico - Port of Lazaro Cardenas','US - Lazaro Cardenas, Mexico - Port of Lazaro Cardenas'));
        offList.add(new SelectOption('US - Lees Summit, MO - 850 NW Chipman Road','US - Lees Summit, MO - 850 NW Chipman Road'));
        offList.add(new SelectOption('US - Lemoore, CA - Naval Air Station Lemoore, CA','US - Lemoore, CA - Naval Air Station Lemoore, CA'));
        offList.add(new SelectOption('US - Lenexa, KS - 9401 Renner Blvd','US - Lenexa, KS - 9401 Renner Blvd'));
        offList.add(new SelectOption('US - Lexington Park, MD - 46591 Expedition Drive Suite 100','US - Lexington Park, MD - 46591 Expedition Drive Suite 100'));
        offList.add(new SelectOption('US - Lincoln, NE - 100 Centennial Mall North','US - Lincoln, NE - 100 Centennial Mall North'));
        offList.add(new SelectOption('US - Lincoln, NE - 1301 West Highland Boulevard','US - Lincoln, NE - 1301 West Highland Boulevard'));
        offList.add(new SelectOption('US - Lincoln, NE - 850 S Street','US - Lincoln, NE - 850 S Street'));
        offList.add(new SelectOption('US - Linton, IN - 325 SE 12th Street','US - Linton, IN - 325 SE 12th Street'));
        offList.add(new SelectOption('US - Lithia Springs, GA - URS 300 Riverside Parkway','US - Lithia Springs, GA - URS 300 Riverside Parkway'));
        offList.add(new SelectOption('US - Little Rock AFB, AR - 19th Medical Group 1090 Arnold Dr','US - Little Rock AFB, AR - 19th Medical Group 1090 Arnold Dr'));
        offList.add(new SelectOption('US - Little Rock, AR - 101 South Spring Street','US - Little Rock, AR - 101 South Spring Street'));
        offList.add(new SelectOption('US - Little Rock, AR - 10801 Executive Center Drive Suite 20','US - Little Rock, AR - 10801 Executive Center Drive Suite 20'));
        offList.add(new SelectOption('US - Little Rock, AR - 10801 Executive Center Suite 202','US - Little Rock, AR - 10801 Executive Center Suite 202'));
        offList.add(new SelectOption('US - Livermore, CA - 161 S. Vasco Rd, Suite L','US - Livermore, CA - 161 S. Vasco Rd, Suite L'));
        offList.add(new SelectOption('US - Livonia, MI - 13955 Farmington Rd','US - Livonia, MI - 13955 Farmington Rd'));
        offList.add(new SelectOption('US - Long Beach, CA - 310 Golden Shore','US - Long Beach, CA - 310 Golden Shore'));
        offList.add(new SelectOption('US - Long Beach, CA - 3760 Kilroy Airport Way','US - Long Beach, CA - 3760 Kilroy Airport Way'));
        offList.add(new SelectOption('US - Long Beach, CA - 3995 Via Oro Ave','US - Long Beach, CA - 3995 Via Oro Ave'));
        offList.add(new SelectOption('US - Long Beach, CA - 501 W Ocean Blvd','US - Long Beach, CA - 501 W Ocean Blvd'));
        offList.add(new SelectOption('US - Lorton, VA - 7002-I Newington Rd','US - Lorton, VA - 7002-I Newington Rd'));
        offList.add(new SelectOption('US - Los Alamitos, CA - 4404 Doolittle Ave Hangar 2','US - Los Alamitos, CA - 4404 Doolittle Ave Hangar 2'));
        offList.add(new SelectOption('US - Los Alamos, NM - 1 Los Alamos Lab','US - Los Alamos, NM - 1 Los Alamos Lab'));
        offList.add(new SelectOption('US - Los Angeles, CA - 1015 Wilshire Boulevard','US - Los Angeles, CA - 1015 Wilshire Boulevard'));
        offList.add(new SelectOption('US - Los Angeles, CA - 1999 Avenue of the Stars','US - Los Angeles, CA - 1999 Avenue of the Stars'));
        offList.add(new SelectOption('US - Los Angeles, CA - 300 N Los Angeles St','US - Los Angeles, CA - 300 N Los Angeles St'));
        offList.add(new SelectOption('US - Los Angeles, CA - 515 S Flower','US - Los Angeles, CA - 515 S Flower'));
        offList.add(new SelectOption('US - Los Angeles, CA - 555 S Flower','US - Los Angeles, CA - 555 S Flower'));
        offList.add(new SelectOption('US - Los Angeles, CA - 5670 Wilshire Boulevard 11th Floor','US - Los Angeles, CA - 5670 Wilshire Boulevard 11th Floor'));
        offList.add(new SelectOption('US - Los Angeles, CA - 5949 West Pico Boulevard','US - Los Angeles, CA - 5949 West Pico Boulevard'));
        offList.add(new SelectOption('US - Los Angeles, CA - 7301 World Way West','US - Los Angeles, CA - 7301 World Way West'));
        offList.add(new SelectOption('US - Los Angeles, CA - 915 Wilshire Boulevard','US - Los Angeles, CA - 915 Wilshire Boulevard'));
        offList.add(new SelectOption('US - Los Angeles, CA - 915 Wilshire Boulevard Suite 1800','US - Los Angeles, CA - 915 Wilshire Boulevard Suite 1800'));
        offList.add(new SelectOption('US - Los Angeles, CA - 915 Wilshire Boulevard Suite 700','US - Los Angeles, CA - 915 Wilshire Boulevard Suite 700'));
        offList.add(new SelectOption('US - Los Angeles, CA - URS 515 South Flower Street','US - Los Angeles, CA - URS 515 South Flower Street'));
        offList.add(new SelectOption('US - Louisiana - Telecommute','US - Louisiana - Telecommute'));
        offList.add(new SelectOption('US - Louisville, KY - 1433 S. 1st St.','US - Louisville, KY - 1433 S. 1st St.'));
        offList.add(new SelectOption('US - Louisville, KY - 4200 Camp Ground Rd','US - Louisville, KY - 4200 Camp Ground Rd'));
        offList.add(new SelectOption('US - Louisville, KY - 4200 Camp Ground Rd 0','US - Louisville, KY - 4200 Camp Ground Rd 0'));
        offList.add(new SelectOption('US - Louisville, KY - 500 West Jefferson Street','US - Louisville, KY - 500 West Jefferson Street'));
        offList.add(new SelectOption('US - Louisville, KY - 601 West Broadway','US - Louisville, KY - 601 West Broadway'));
        offList.add(new SelectOption('US - Louisville, KY - URS Const Trailers 4200 Camp Ground Ro','US - Louisville, KY - URS Const Trailers 4200 Camp Ground Ro'));
        offList.add(new SelectOption('US - Louisville, TN - URS 1302 Topside Road','US - Louisville, TN - URS 1302 Topside Road'));
        offList.add(new SelectOption('US - Louisville,KY - 4200 Camp Ground Rd 0','US - Louisville,KY - 4200 Camp Ground Rd 0'));
        offList.add(new SelectOption('US - Lowville, NY - URS Kraft Foods 7388 Utica Blvd.','US - Lowville, NY - URS Kraft Foods 7388 Utica Blvd.'));
        offList.add(new SelectOption('US - Lynchburg, VA','US - Lynchburg, VA'));
        offList.add(new SelectOption('US - MacDill AFB, FL - CENTCOM 7115 S Boundary Blvd','US - MacDill AFB, FL - CENTCOM 7115 S Boundary Blvd'));
        offList.add(new SelectOption('US - MacDill AFB, FL - USSOCOM 7701 Tampa Point Blvd','US - MacDill AFB, FL - USSOCOM 7701 Tampa Point Blvd'));
        offList.add(new SelectOption('US - Madison, WI - 1950 Pearson Street','US - Madison, WI - 1950 Pearson Street'));
        offList.add(new SelectOption('US - Madrid, Spain - Calle de la Quintana 2','US - Madrid, Spain - Calle de la Quintana 2'));
        offList.add(new SelectOption('US - Makati City, Philippines - 168 Salcedo St','US - Makati City, Philippines - 168 Salcedo St'));
        offList.add(new SelectOption('US - Manassas, VA - 10374 Battleview Pkwy Sub Site - CWS','US - Manassas, VA - 10374 Battleview Pkwy Sub Site - CWS'));
        offList.add(new SelectOption('US - Manassas, VA - 12131 Tall Trees Lane','US - Manassas, VA - 12131 Tall Trees Lane'));
        offList.add(new SelectOption('US - Manassas, VA - 9464 Innovation Drive','US - Manassas, VA - 9464 Innovation Drive'));
        offList.add(new SelectOption('US - Manassas, VA - 9500 Goodwin Drive Bldg 105 D118','US - Manassas, VA - 9500 Goodwin Drive Bldg 105 D118'));
        offList.add(new SelectOption('US - Manchester, NH - 1000 Elm Street','US - Manchester, NH - 1000 Elm Street'));
        offList.add(new SelectOption('US - Manchester, NH - 1155 Elm Street','US - Manchester, NH - 1155 Elm Street'));
        offList.add(new SelectOption('US - Manlius, NY - 4511 Lamplighter Lane','US - Manlius, NY - 4511 Lamplighter Lane'));
        offList.add(new SelectOption('US - Maputo, Mozambique','US - Maputo, Mozambique'));
        offList.add(new SelectOption('US - Marblehead, MA - 11 Madison Road 860/448-1719 x6926','US - Marblehead, MA - 11 Madison Road 860/448-1719 x6926'));
        offList.add(new SelectOption('US - March ARB, CA - 245 Airlift Way','US - March ARB, CA - 245 Airlift Way'));
        offList.add(new SelectOption('US - Marietta, OH - URS 16701 St Rt 7 South','US - Marietta, OH - URS 16701 St Rt 7 South'));
        offList.add(new SelectOption('US - Markham, ON - 300 Town Centre Blvd','US - Markham, ON - 300 Town Centre Blvd'));
        offList.add(new SelectOption('US - Marlton, NJ - URS Holtec International 555 Lincoln Driv','US - Marlton, NJ - URS Holtec International 555 Lincoln Driv'));
        offList.add(new SelectOption('US - Marquette, MI','US - Marquette, MI'));
        offList.add(new SelectOption('US - Maryland - Telecommute','US - Maryland - Telecommute'));
        offList.add(new SelectOption('US - Marysville, CA - 2088 N Beale Rd','US - Marysville, CA - 2088 N Beale Rd'));
        offList.add(new SelectOption('US - Mason, OH - 8700 Mason Montgomery Road','US - Mason, OH - 8700 Mason Montgomery Road'));
        offList.add(new SelectOption('US - Massachusetts - Telecommute','US - Massachusetts - Telecommute'));
        offList.add(new SelectOption('US - Mayport, FL - Southeast Regional Maintenance Center Bui','US - Mayport, FL - Southeast Regional Maintenance Center Bui'));
        offList.add(new SelectOption('US - MCAS Camp Pendelton, CA - HMLAT-303 Bldg 2360','US - MCAS Camp Pendelton, CA - HMLAT-303 Bldg 2360'));
        offList.add(new SelectOption('US - Mechanicsburg, PA - 100 Sterling Parkway','US - Mechanicsburg, PA - 100 Sterling Parkway'));
        offList.add(new SelectOption('US - Mechanicsburg, PA - URS 600 Bent Creek Blvd., Suite 120','US - Mechanicsburg, PA - URS 600 Bent Creek Blvd., Suite 120'));
        offList.add(new SelectOption('US - Memphis, TN - 5333 Getwell Stop WC','US - Memphis, TN - 5333 Getwell Stop WC'));
        offList.add(new SelectOption('US - Memphis, TN - URS Ei Dupont 2571 Fite Rd','US - Memphis, TN - URS Ei Dupont 2571 Fite Rd'));
        offList.add(new SelectOption('US - Meredosia, IL - URS 800 S Washington Street','US - Meredosia, IL - URS 800 S Washington Street'));
        offList.add(new SelectOption('US - Meridian, MS - 186 ARW/Bldg 100 6225 M. Street','US - Meridian, MS - 186 ARW/Bldg 100 6225 M. Street'));
        offList.add(new SelectOption('US - Merritt Island, FL - 4770 Seminole Trail','US - Merritt Island, FL - 4770 Seminole Trail'));
        offList.add(new SelectOption('US - Mesa, AZ - 1400 South Dobson Road','US - Mesa, AZ - 1400 South Dobson Road'));
        offList.add(new SelectOption('US - Mesa, AZ - 3740 S Single Butte Road','US - Mesa, AZ - 3740 S Single Butte Road'));
        offList.add(new SelectOption('US - Metairie, LA - 3500 N Causeway Blvd Suite 900','US - Metairie, LA - 3500 N Causeway Blvd Suite 900'));
        offList.add(new SelectOption('US - Mexico City, Mexico - Cerro de la Estrella 107 PH','US - Mexico City, Mexico - Cerro de la Estrella 107 PH'));
        offList.add(new SelectOption('US - Miami Gardens, FL - 2269 NW 199th Street','US - Miami Gardens, FL - 2269 NW 199th Street'));
        offList.add(new SelectOption('US - Miami, FL - 1001 NW 111th Ave','US - Miami, FL - 1001 NW 111th Ave'));
        offList.add(new SelectOption('US - Miami, FL - 14675 SW 120th Street','US - Miami, FL - 14675 SW 120th Street'));
        offList.add(new SelectOption('US - Miami, FL - 347 Don Shula Drive','US - Miami, FL - 347 Don Shula Drive'));
        offList.add(new SelectOption('US - Miami, FL - 7650 Corporate Center Drive','US - Miami, FL - 7650 Corporate Center Drive'));
        offList.add(new SelectOption('US - Miami, FL - 7650 Corporate Center Drive Suite 400','US - Miami, FL - 7650 Corporate Center Drive Suite 400'));
        offList.add(new SelectOption('US - Miami, FL - 7650 Corporate Center Drive Suite 401','US - Miami, FL - 7650 Corporate Center Drive Suite 401'));
        offList.add(new SelectOption('US - Miami, FL - 801 Bricknell Ave Suite 1800','US - Miami, FL - 801 Bricknell Ave Suite 1800'));
        offList.add(new SelectOption('US - Miami, FL - 99 SE 5th Street','US - Miami, FL - 99 SE 5th Street'));
        offList.add(new SelectOption('US - Miami, FL - URS 1620 Nw 125 St','US - Miami, FL - URS 1620 Nw 125 St'));
        offList.add(new SelectOption('US - Miami, FL - URS 8350 Nw 52 Terrace, Ste 100','US - Miami, FL - URS 8350 Nw 52 Terrace, Ste 100'));
        offList.add(new SelectOption('US - Miami, FL - URS Cat 90 Miami 701 Waterford Way, Suite 2','US - Miami, FL - URS Cat 90 Miami 701 Waterford Way, Suite 2'));
        offList.add(new SelectOption('US - Michigan - Telecommute','US - Michigan - Telecommute'));
        offList.add(new SelectOption('US - Mico, TX - 128 Private Road 1739 W','US - Mico, TX - 128 Private Road 1739 W'));
        offList.add(new SelectOption('US - Middlebury, VT','US - Middlebury, VT'));
        offList.add(new SelectOption('US - Middleton, WI - 1350 Deming Way','US - Middleton, WI - 1350 Deming Way'));
        offList.add(new SelectOption('US - Middletown, RI - Two Corporate Place Newport Corporate ','US - Middletown, RI - Two Corporate Place Newport Corporate '));
        offList.add(new SelectOption('US - Midland, MI - 2030 Dow Center','US - Midland, MI - 2030 Dow Center'));
        offList.add(new SelectOption('US - Midland, TX - 12808 W. County Rd. 91 - PO Box 3748','US - Midland, TX - 12808 W. County Rd. 91 - PO Box 3748'));
        offList.add(new SelectOption('US - Midwest City, OK - 2701 Liberty Parkway Suite 304','US - Midwest City, OK - 2701 Liberty Parkway Suite 304'));
        offList.add(new SelectOption('US - Milford, MA','US - Milford, MA'));
        offList.add(new SelectOption('US - Milford, MI - URS Gm Providing Grounds 3300 General Mot','US - Milford, MI - URS Gm Providing Grounds 3300 General Mot'));
        offList.add(new SelectOption('US - Milwaukee, WI - 1555 N Rivercenter Drive','US - Milwaukee, WI - 1555 N Rivercenter Drive'));
        offList.add(new SelectOption('US - Milwaukee, WI - 342 North Water Street','US - Milwaukee, WI - 342 North Water Street'));
        offList.add(new SelectOption('US - Milwaukee, WI - URS We Energies Valley Plant Gas Conver','US - Milwaukee, WI - URS We Energies Valley Plant Gas Conver'));
        offList.add(new SelectOption('US - Minneapolis, MN - 100 South Fifth Street Suite 1500 Fif','US - Minneapolis, MN - 100 South Fifth Street Suite 1500 Fif'));
        offList.add(new SelectOption('US - Minneapolis, MN - 800 S LaSalle Ave','US - Minneapolis, MN - 800 S LaSalle Ave'));
        offList.add(new SelectOption('US - Minnesota - Telecommute','US - Minnesota - Telecommute'));
        offList.add(new SelectOption('US - Minot, ND - 609-30 Avenue NW, Suite B','US - Minot, ND - 609-30 Avenue NW, Suite B'));
        offList.add(new SelectOption('US - Minot, ND - N/A','US - Minot, ND - N/A'));
        offList.add(new SelectOption('US - Minot, ND - URS 509 30th Avenue Suite#2','US - Minot, ND - URS 509 30th Avenue Suite#2'));
        offList.add(new SelectOption('US - Miramar, CA - Marine Corps Air Station Miramar, CA','US - Miramar, CA - Marine Corps Air Station Miramar, CA'));
        offList.add(new SelectOption('US - Mission, TX - 11916 West Mile 7 Road','US - Mission, TX - 11916 West Mile 7 Road'));
        offList.add(new SelectOption('US - Mississippi - Telecommute','US - Mississippi - Telecommute'));
        offList.add(new SelectOption('US - Missouri - Telecommute','US - Missouri - Telecommute'));
        offList.add(new SelectOption('US - Mobile, AL - 917 Western America Circle','US - Mobile, AL - 917 Western America Circle'));
        offList.add(new SelectOption('US - Mobile, AL - 917 Western America Circle Executive Cente','US - Mobile, AL - 917 Western America Circle Executive Cente'));
        offList.add(new SelectOption('US - Mobile, AL - 917 Western America Circle Suite 400','US - Mobile, AL - 917 Western America Circle Suite 400'));
        offList.add(new SelectOption('US - Model, CO - URS 27205 Country Road 91.0 Box 17','US - Model, CO - URS 27205 Country Road 91.0 Box 17'));
        offList.add(new SelectOption('US - Moffett Federal Airfield, CA','US - Moffett Federal Airfield, CA'));
        offList.add(new SelectOption('US - Monroe, MI - 3500 East Front St Gibco Bldg','US - Monroe, MI - 3500 East Front St Gibco Bldg'));
        offList.add(new SelectOption('US - Monroe, MI - URS 3500 East Front St Warehouse F','US - Monroe, MI - URS 3500 East Front St Warehouse F'));
        offList.add(new SelectOption('US - Monroe, WA - URS 13304 Chain Link Road','US - Monroe, WA - URS 13304 Chain Link Road'));
        offList.add(new SelectOption('US - Monroe,MI - 3500 East Front St Gibco Bldg','US - Monroe,MI - 3500 East Front St Gibco Bldg'));
        offList.add(new SelectOption('US - Montague, MI - c/o Dupont Montague Plant 6270 Wilkes Rd','US - Montague, MI - c/o Dupont Montague Plant 6270 Wilkes Rd'));
        offList.add(new SelectOption('US - Montgomery, AL','US - Montgomery, AL'));
        offList.add(new SelectOption('US - Montgomery, AL - 11644 Atlanta Hwy','US - Montgomery, AL - 11644 Atlanta Hwy'));
        offList.add(new SelectOption('US - Montgomery, AL - 24 Felder Avenue','US - Montgomery, AL - 24 Felder Avenue'));
        offList.add(new SelectOption('US - Montgomery, AL - 60 Commerce St Suite 1205','US - Montgomery, AL - 60 Commerce St Suite 1205'));
        offList.add(new SelectOption('US - Montgomery, AL - Dannely Field 187th ANG 5187 Selma Hig','US - Montgomery, AL - Dannely Field 187th ANG 5187 Selma Hig'));
        offList.add(new SelectOption('US - Montgomery, AL - URS 429 Carrington Pkwy','US - Montgomery, AL - URS 429 Carrington Pkwy'));
        offList.add(new SelectOption('US - Montoursville, PA - 1050 Broad Street','US - Montoursville, PA - 1050 Broad Street'));
        offList.add(new SelectOption('US - Montoursville, PA - N/A','US - Montoursville, PA - N/A'));
        offList.add(new SelectOption('US - Morehead City, NC - 113 Arendell Street Suite 100','US - Morehead City, NC - 113 Arendell Street Suite 100'));
        offList.add(new SelectOption('US - Morenci, AZ - URS Rust Constructors - Craft 4521 Us Hig','US - Morenci, AZ - URS Rust Constructors - Craft 4521 Us Hig'));
        offList.add(new SelectOption('US - Morenci, AZ - URS Rust Constructors 4521 U.S. Highway 1','US - Morenci, AZ - URS Rust Constructors 4521 U.S. Highway 1'));
        offList.add(new SelectOption('US - Morgantown, WV','US - Morgantown, WV'));
        offList.add(new SelectOption('US - MORGANTOWN, WV - 3610 Collins Ferry Road Suite 160','US - MORGANTOWN, WV - 3610 Collins Ferry Road Suite 160'));
        offList.add(new SelectOption('US - Morgantown, WV - 451 North Metro Drive','US - Morgantown, WV - 451 North Metro Drive'));
        offList.add(new SelectOption('US - Morgantown, WV - URS Attn Renee Beckish 3610 Collins Fe','US - Morgantown, WV - URS Attn Renee Beckish 3610 Collins Fe'));
        offList.add(new SelectOption('US - Morrisville, NC - 1600 Perimeter Park Drive','US - Morrisville, NC - 1600 Perimeter Park Drive'));
        offList.add(new SelectOption('US - Morrisville, NC - 1600 Perimeter Park Drive Suite 100','US - Morrisville, NC - 1600 Perimeter Park Drive Suite 100'));
        offList.add(new SelectOption('US - Morrisville, NC - 1600 Perimeter Park Drive Suite 400','US - Morrisville, NC - 1600 Perimeter Park Drive Suite 400'));
        offList.add(new SelectOption('US - Morrisville, NC - URS 200 Sorrell Grove Church Rd Suite','US - Morrisville, NC - URS 200 Sorrell Grove Church Rd Suite'));
        offList.add(new SelectOption('US - Moss Point, MS - URS Plant Daniel Fgd Project 13201 Hig','US - Moss Point, MS - URS Plant Daniel Fgd Project 13201 Hig'));
        offList.add(new SelectOption('US - Mossville, IL - URS Bldg Ac, Catrpillar Inc Route 29','US - Mossville, IL - URS Bldg Ac, Catrpillar Inc Route 29'));
        offList.add(new SelectOption('US - Mossville, IL - URS Mossville Engine Center Cedar Hills','US - Mossville, IL - URS Mossville Engine Center Cedar Hills'));
        offList.add(new SelectOption('US - Mossville, IL - URS Tech Center, Technologies % Solutio','US - Mossville, IL - URS Tech Center, Technologies % Solutio'));
        offList.add(new SelectOption('US - Moulton, AL - URS 1931 Alabama Hwy # 36','US - Moulton, AL - URS 1931 Alabama Hwy # 36'));
        offList.add(new SelectOption('US - Moundsville, WV - URS William Midstream 200 Caiman Driv','US - Moundsville, WV - URS William Midstream 200 Caiman Driv'));
        offList.add(new SelectOption('US - Mount Pleasant, SC','US - Mount Pleasant, SC'));
        offList.add(new SelectOption('US - Moyock, NC - 220 Old Jury Road','US - Moyock, NC - 220 Old Jury Road'));
        offList.add(new SelectOption('US - MSFC, AL - 4250 Morris Road','US - MSFC, AL - 4250 Morris Road'));
        offList.add(new SelectOption('US - Multiple cities, Multiple States - N/A','US - Multiple cities, Multiple States - N/A'));
        offList.add(new SelectOption('US - Murray, UT - 756 East Winchester Street','US - Murray, UT - 756 East Winchester Street'));
        offList.add(new SelectOption('US - Nairobi, Kenya - No. 1 Diani Close off Ole','US - Nairobi, Kenya - No. 1 Diani Close off Ole'));
        offList.add(new SelectOption('US - NAS Lemoore, CA - 291 Reeves Blvd','US - NAS Lemoore, CA - 291 Reeves Blvd'));
        offList.add(new SelectOption('US - Nashville, TN - 220 Athens Way','US - Nashville, TN - 220 Athens Way'));
        offList.add(new SelectOption('US - Nashville, TN - 240 Knapp Blvd Bldg 720','US - Nashville, TN - 240 Knapp Blvd Bldg 720'));
        offList.add(new SelectOption('US - Nashville, TN - URS 3106 Knobdale Rd.','US - Nashville, TN - URS 3106 Knobdale Rd.'));
        offList.add(new SelectOption('US - Navarre, FL - 6726 Hartland Street','US - Navarre, FL - 6726 Hartland Street'));
        offList.add(new SelectOption('US - Navy Dare Range, NC - Navy Dare Range','US - Navy Dare Range, NC - Navy Dare Range'));
        offList.add(new SelectOption('US - Nebraska - Telecommute','US - Nebraska - Telecommute'));
        offList.add(new SelectOption('US - Nevada - Telecommute','US - Nevada - Telecommute'));
        offList.add(new SelectOption('US - New Boston, TX - 245 Ammo Drive','US - New Boston, TX - 245 Ammo Drive'));
        offList.add(new SelectOption('US - New Boston, TX - Mobility Center 333 Panther Creek Driv','US - New Boston, TX - Mobility Center 333 Panther Creek Driv'));
        offList.add(new SelectOption('US - New Boston, TX - P.O. Box 815','US - New Boston, TX - P.O. Box 815'));
        offList.add(new SelectOption('US - New Hampshire - Telecommute','US - New Hampshire - Telecommute'));
        offList.add(new SelectOption('US - New Haven, CT','US - New Haven, CT'));
        offList.add(new SelectOption('US - New Haven, CT - URS 1 Howe Street','US - New Haven, CT - URS 1 Howe Street'));
        offList.add(new SelectOption('US - New Haven, CT - URS Pfizer New Haven 1 Howe Street','US - New Haven, CT - URS Pfizer New Haven 1 Howe Street'));
        offList.add(new SelectOption('US - New Jersey - Telecommute','US - New Jersey - Telecommute'));
        offList.add(new SelectOption('US - New Johnsonville, TN - URS Ei Dupont 2nd Street','US - New Johnsonville, TN - URS Ei Dupont 2nd Street'));
        offList.add(new SelectOption('US - New Mexico - Telecommute','US - New Mexico - Telecommute'));
        offList.add(new SelectOption('US - New Orleans, LA - 1515 Poydras Street','US - New Orleans, LA - 1515 Poydras Street'));
        offList.add(new SelectOption('US - New Orleans, LA - 1515 Poydras Street Suite 2700','US - New Orleans, LA - 1515 Poydras Street Suite 2700'));
        offList.add(new SelectOption('US - New Orleans, LA - 400 Russell Avenue Bldg. 559','US - New Orleans, LA - 400 Russell Avenue Bldg. 559'));
        offList.add(new SelectOption('US - New Orleans, LA - URS 1515 Poydras Street Suite 2700','US - New Orleans, LA - URS 1515 Poydras Street Suite 2700'));
        offList.add(new SelectOption('US - New York - Telecommute','US - New York - Telecommute'));
        offList.add(new SelectOption('US - New York, NY - 100 Broadway, 3rd + 4th Floors','US - New York, NY - 100 Broadway, 3rd + 4th Floors'));
        offList.add(new SelectOption('US - New York, NY - 100 Park Ave','US - New York, NY - 100 Park Ave'));
        offList.add(new SelectOption('US - New York, NY - 125 Broad Street','US - New York, NY - 125 Broad Street'));
        offList.add(new SelectOption('US - New York, NY - 2 Broadway','US - New York, NY - 2 Broadway'));
        offList.add(new SelectOption('US - New York, NY - 20 Exchange Pl','US - New York, NY - 20 Exchange Pl'));
        offList.add(new SelectOption('US - New York, NY - 201 Varick Street','US - New York, NY - 201 Varick Street'));
        offList.add(new SelectOption('US - New York, NY - 26 Federal Plaza','US - New York, NY - 26 Federal Plaza'));
        offList.add(new SelectOption('US - New York, NY - 30 Broad Street','US - New York, NY - 30 Broad Street'));
        offList.add(new SelectOption('US - New York, NY - 314 E 34th St','US - New York, NY - 314 E 34th St'));
        offList.add(new SelectOption('US - New York, NY - 333 West 52nd Street','US - New York, NY - 333 West 52nd Street'));
        offList.add(new SelectOption('US - New York, NY - 469 7th Ave','US - New York, NY - 469 7th Ave'));
        offList.add(new SelectOption('US - New York, NY - 605 Third Ave','US - New York, NY - 605 Third Ave'));
        offList.add(new SelectOption('US - New York, NY - Alexander Hamilton','US - New York, NY - Alexander Hamilton'));
        offList.add(new SelectOption('US - New York, NY - Fulton & Broadway','US - New York, NY - Fulton & Broadway'));
        offList.add(new SelectOption('US - New York, NY - Moynihan Station','US - New York, NY - Moynihan Station'));
        offList.add(new SelectOption('US - New York, NY - One Penn Plaza','US - New York, NY - One Penn Plaza'));
        offList.add(new SelectOption('US - New York, NY - One Penn Plaza Suite 600','US - New York, NY - One Penn Plaza Suite 600'));
        offList.add(new SelectOption('US - New York, NY - Penn Station','US - New York, NY - Penn Station'));
        offList.add(new SelectOption('US - New York, NY - Randall\'s Island SVC Rd','US - New York, NY - Randall\'s Island SVC Rd'));
        offList.add(new SelectOption('US - New York, NY - Rte 9A Pier 40','US - New York, NY - Rte 9A Pier 40'));
        offList.add(new SelectOption('US - New York, NY - Tappan Zee','US - New York, NY - Tappan Zee'));
        offList.add(new SelectOption('US - New York, NY - URS 1 Penn Plaza, Suite 600','US - New York, NY - URS 1 Penn Plaza, Suite 600'));
        offList.add(new SelectOption('US - New York, NY - US SEC 3 World Financial Center','US - New York, NY - US SEC 3 World Financial Center'));
        offList.add(new SelectOption('US - Newark, DE - Iron Hill Corporate Center','US - Newark, DE - Iron Hill Corporate Center'));
        offList.add(new SelectOption('US - Newark, DE - Iron Hill Corporate Center 4051 Ogletown R','US - Newark, DE - Iron Hill Corporate Center 4051 Ogletown R'));
        offList.add(new SelectOption('US - Newark, DE - Iron Hill Corporate Center Suite 300','US - Newark, DE - Iron Hill Corporate Center Suite 300'));
        offList.add(new SelectOption('US - Newark, NJ - 1 Riverfront Plaza','US - Newark, NJ - 1 Riverfront Plaza'));
        offList.add(new SelectOption('US - Newark, NJ - 2 Gateway Center','US - Newark, NJ - 2 Gateway Center'));
        offList.add(new SelectOption('US - Newark, NJ - 570 Broad St','US - Newark, NJ - 570 Broad St'));
        offList.add(new SelectOption('US - Newport News, VA - 11832 Rock Landing Drive Suite 306','US - Newport News, VA - 11832 Rock Landing Drive Suite 306'));
        offList.add(new SelectOption('US - Newport News, VA - 4101 Washington Ave Bldg 4633 Waterf','US - Newport News, VA - 4101 Washington Ave Bldg 4633 Waterf'));
        offList.add(new SelectOption('US - Newport News, VA - The Atrium Building 11832 Rock Landi','US - Newport News, VA - The Atrium Building 11832 Rock Landi'));
        offList.add(new SelectOption('US - Newport, MI - 6400 North Dixie Hwy','US - Newport, MI - 6400 North Dixie Hwy'));
        offList.add(new SelectOption('US - Newport, MI - 6400 North Dixie Hwy 0','US - Newport, MI - 6400 North Dixie Hwy 0'));
        offList.add(new SelectOption('US - Newport, MI - URS C/O Detroit Edison 6400 North Dixie H','US - Newport, MI - URS C/O Detroit Edison 6400 North Dixie H'));
        offList.add(new SelectOption('US - Newport, MI -- 6400 North Dixie Hwy','US - Newport, MI -- 6400 North Dixie Hwy'));
        offList.add(new SelectOption('US - Newport, NC - PO Box 1137','US - Newport, NC - PO Box 1137'));
        offList.add(new SelectOption('US - Newport, RI - NUWC 1176 Howell St','US - Newport, RI - NUWC 1176 Howell St'));
        offList.add(new SelectOption('US - Newton, IL - URS Newton Fgd System Epc Services 6725 N ','US - Newton, IL - URS Newton Fgd System Epc Services 6725 N '));
        offList.add(new SelectOption('US - Niagara Falls, NY - Buffalo Avenue and 26th Street Buil','US - Niagara Falls, NY - Buffalo Avenue and 26th Street Buil'));
        offList.add(new SelectOption('US - Niceville, FL - 233 Galway Drive','US - Niceville, FL - 233 Galway Drive'));
        offList.add(new SelectOption('US - NISKAYUNA, NY - 2425 River Road','US - NISKAYUNA, NY - 2425 River Road'));
        offList.add(new SelectOption('US - Niskayuna, NY - URS 2425 River Road','US - Niskayuna, NY - URS 2425 River Road'));
        offList.add(new SelectOption('US - Norfolk, VA - 1027 Bellinger Blvd','US - Norfolk, VA - 1027 Bellinger Blvd'));
        offList.add(new SelectOption('US - Norfolk, VA - 1629 Longdale Drive 860/448-1719 x6926','US - Norfolk, VA - 1629 Longdale Drive 860/448-1719 x6926'));
        offList.add(new SelectOption('US - Norfolk, VA - 440 Monticello Ave','US - Norfolk, VA - 440 Monticello Ave'));
        offList.add(new SelectOption('US - Norfolk, VA - 4565 Progress Raod Suite 1C','US - Norfolk, VA - 4565 Progress Raod Suite 1C'));
        offList.add(new SelectOption('US - Norfolk, VA - 524 A Street HSC-2 SP-35','US - Norfolk, VA - 524 A Street HSC-2 SP-35'));
        offList.add(new SelectOption('US - Norfolk, VA - 5425 Robin Hood Road Suite 111','US - Norfolk, VA - 5425 Robin Hood Road Suite 111'));
        offList.add(new SelectOption('US - Norfolk, VA - 7927 Ingersol Street Suite 250','US - Norfolk, VA - 7927 Ingersol Street Suite 250'));
        offList.add(new SelectOption('US - Norfolk, VA - 9276 Third Ave Bldg LP26','US - Norfolk, VA - 9276 Third Ave Bldg LP26'));
        offList.add(new SelectOption('US - Norfolk, VA - 9727 Avionics Loop','US - Norfolk, VA - 9727 Avionics Loop'));
        offList.add(new SelectOption('US - North Attleboro, MA - 23 North Pond Terrace','US - North Attleboro, MA - 23 North Pond Terrace'));
        offList.add(new SelectOption('US - North Beach, MD - 8902 Erie Ave','US - North Beach, MD - 8902 Erie Ave'));
        offList.add(new SelectOption('US - North Carolina - Telecommute','US - North Carolina - Telecommute'));
        offList.add(new SelectOption('US - North Charleston, SC - 4016 Salt Point Prkwy Suite 200','US - North Charleston, SC - 4016 Salt Point Prkwy Suite 200'));
        offList.add(new SelectOption('US - North Charleston, SC - 4016 Salt Pointe Parkway','US - North Charleston, SC - 4016 Salt Pointe Parkway'));
        offList.add(new SelectOption('US - North Charleston, SC - 8709 Silver Creek Lane','US - North Charleston, SC - 8709 Silver Creek Lane'));
        offList.add(new SelectOption('US - Northridge, CA','US - Northridge, CA'));
        offList.add(new SelectOption('US - Oak Creek, WI - URS Caterpillar Global Mining Hq 1 Bucy','US - Oak Creek, WI - URS Caterpillar Global Mining Hq 1 Bucy'));
        offList.add(new SelectOption('US - Oak Harbor, WA - AIMD 400 Div., 950 W Essex Rd','US - Oak Harbor, WA - AIMD 400 Div., 950 W Essex Rd'));
        offList.add(new SelectOption('US - OAK RIDGE, TN - 105 Mitchell Rd Suite 900','US - OAK RIDGE, TN - 105 Mitchell Rd Suite 900'));
        offList.add(new SelectOption('US - Oak Ridge, TN - 105 Mitchell Road','US - Oak Ridge, TN - 105 Mitchell Road'));
        offList.add(new SelectOption('US - Oak Ridge, TN - 105 Mitchell Road Suite 200','US - Oak Ridge, TN - 105 Mitchell Road Suite 200'));
        offList.add(new SelectOption('US - Oak Ridge, TN - 1099 Commerce Park Drive','US - Oak Ridge, TN - 1099 Commerce Park Drive'));
        offList.add(new SelectOption('US - Oak Ridge, TN - URS Oakridge Disposal Cell Project 105 ','US - Oak Ridge, TN - URS Oakridge Disposal Cell Project 105 '));
        offList.add(new SelectOption('US - Oakland, CA - 1301 Clay Street Federal Bldg Mail Stop 1','US - Oakland, CA - 1301 Clay Street Federal Bldg Mail Stop 1'));
        offList.add(new SelectOption('US - Oakland, CA - 1333 Broadway','US - Oakland, CA - 1333 Broadway'));
        offList.add(new SelectOption('US - Oakland, CA - 1333 Broadway Suite 800','US - Oakland, CA - 1333 Broadway Suite 800'));
        offList.add(new SelectOption('US - Oakland, CA - 2101 Webster St','US - Oakland, CA - 2101 Webster St'));
        offList.add(new SelectOption('US - Oakland, CA - 300 Lakeside Drive','US - Oakland, CA - 300 Lakeside Drive'));
        offList.add(new SelectOption('US - Oar Harbor, WA - Hanger 12, 3740 N Charles Porter Ave','US - Oar Harbor, WA - Hanger 12, 3740 N Charles Porter Ave'));
        offList.add(new SelectOption('US - Oceanside, CA - Naval Hosp Camp Pendelton Bldg H-100 Rm','US - Oceanside, CA - Naval Hosp Camp Pendelton Bldg H-100 Rm'));
        offList.add(new SelectOption('US - Odessa, TX - 2409 E I-20, PO Box 1147','US - Odessa, TX - 2409 E I-20, PO Box 1147'));
        offList.add(new SelectOption('US - Odessa, TX - URS Flint- Og 2409 E. 1-20','US - Odessa, TX - URS Flint- Og 2409 E. 1-20'));
        offList.add(new SelectOption('US - Odon, IN - 13923 E CAPT WJ Nelson Dr','US - Odon, IN - 13923 E CAPT WJ Nelson Dr'));
        offList.add(new SelectOption('US - Ogden, UT - 1973 North Rulon White Blvd','US - Ogden, UT - 1973 North Rulon White Blvd'));
        offList.add(new SelectOption('US - Ohio - Telecommute','US - Ohio - Telecommute'));
        offList.add(new SelectOption('US - Oklahoma - Telecommute','US - Oklahoma - Telecommute'));
        offList.add(new SelectOption('US - Oklahoma City, OK - 72d Medical Support Squadron 5700 A','US - Oklahoma City, OK - 72d Medical Support Squadron 5700 A'));
        offList.add(new SelectOption('US - Oklahoma City, OK - 8120 Mid America Blvd. Sldg 3, Door','US - Oklahoma City, OK - 8120 Mid America Blvd. Sldg 3, Door'));
        offList.add(new SelectOption('US - Oklahoma City, OK - URS Pratt & Whitney Eagle Supply 81','US - Oklahoma City, OK - URS Pratt & Whitney Eagle Supply 81'));
        offList.add(new SelectOption('US - Olmsted, IL - URS 675 New Dam Road','US - Olmsted, IL - URS 675 New Dam Road'));
        offList.add(new SelectOption('US - Olmsted, IL - URS Olmsted 675 New Dam Road','US - Olmsted, IL - URS Olmsted 675 New Dam Road'));
        offList.add(new SelectOption('US - Olyphant, PA','US - Olyphant, PA'));
        offList.add(new SelectOption('US - Omaha, NE - 12020 Shamrock Plaza','US - Omaha, NE - 12020 Shamrock Plaza'));
        offList.add(new SelectOption('US - Omaha, NE - 12120 Shamrock Plaza','US - Omaha, NE - 12120 Shamrock Plaza'));
        offList.add(new SelectOption('US - Omaha, NE - 12120 Shamrock Plaza Suite 300','US - Omaha, NE - 12120 Shamrock Plaza Suite 300'));
        offList.add(new SelectOption('US - Ontario, CA - 1131 W Sixth St','US - Ontario, CA - 1131 W Sixth St'));
        offList.add(new SelectOption('US - Ontario, CA - 3500 Porsche Way Ste 300','US - Ontario, CA - 3500 Porsche Way Ste 300'));
        offList.add(new SelectOption('US - Ontario, CA - 3500 Porsche Way Suite 300','US - Ontario, CA - 3500 Porsche Way Suite 300'));
        offList.add(new SelectOption('US - Ontario, CA - 901 Via Piemonte','US - Ontario, CA - 901 Via Piemonte'));
        offList.add(new SelectOption('US - Orange Park, FL - 649 Thornwood Lane','US - Orange Park, FL - 649 Thornwood Lane'));
        offList.add(new SelectOption('US - Orange, CA - 999 Town & Country Rd','US - Orange, CA - 999 Town & Country Rd'));
        offList.add(new SelectOption('US - Oregon - Telecommute','US - Oregon - Telecommute'));
        offList.add(new SelectOption('US - Oregon, OH - 4001 Cedar Point Rd','US - Oregon, OH - 4001 Cedar Point Rd'));
        offList.add(new SelectOption('US - Oregon, OH - 4001 Cedar Point Rd 0','US - Oregon, OH - 4001 Cedar Point Rd 0'));
        offList.add(new SelectOption('US - Oregon, OH - URS Bp Husky Refining Llc 4001 Ceder Point','US - Oregon, OH - URS Bp Husky Refining Llc 4001 Ceder Point'));
        offList.add(new SelectOption('US - Oregon, OH -- 4001 Cedar Point Rd','US - Oregon, OH -- 4001 Cedar Point Rd'));
        offList.add(new SelectOption('US - Orem, UT - 75 WEST 165 S','US - Orem, UT - 75 WEST 165 S'));
        offList.add(new SelectOption('US - Orlando, FL - 150 N Orange Ave','US - Orlando, FL - 150 N Orange Ave'));
        offList.add(new SelectOption('US - Orlando, FL - 1560 North Orange Ave','US - Orlando, FL - 1560 North Orange Ave'));
        offList.add(new SelectOption('US - Orlando, FL - 1610 W Church Street','US - Orlando, FL - 1610 W Church Street'));
        offList.add(new SelectOption('US - Orlando, FL - 2603 Discovery Drive','US - Orlando, FL - 2603 Discovery Drive'));
        offList.add(new SelectOption('US - Orlando, FL - 3039 Technology Parkway 5th Floor','US - Orlando, FL - 3039 Technology Parkway 5th Floor'));
        offList.add(new SelectOption('US - Orlando, FL - 315 East Robinson Street','US - Orlando, FL - 315 East Robinson Street'));
        offList.add(new SelectOption('US - Orlando, FL - 6680 Corporate Centre Boulevard','US - Orlando, FL - 6680 Corporate Centre Boulevard'));
        offList.add(new SelectOption('US - Orlando, FL - 7680 Universal Blvd','US - Orlando, FL - 7680 Universal Blvd'));
        offList.add(new SelectOption('US - Orlando, FL - URS 315 East Robinson Street, Suite 245','US - Orlando, FL - URS 315 East Robinson Street, Suite 245'));
        offList.add(new SelectOption('US - Orlando, FL - URS 4974 Orl Tower Road','US - Orlando, FL - URS 4974 Orl Tower Road'));
        offList.add(new SelectOption('US - Orlando, FL -20 N Orange Ave','US - Orlando, FL -20 N Orange Ave'));
        offList.add(new SelectOption('US - Ormond Beach, FL - P.O. Box 64','US - Ormond Beach, FL - P.O. Box 64'));
        offList.add(new SelectOption('US - Oro Valley, AZ - 1917 W Placita Rancho Naranjo','US - Oro Valley, AZ - 1917 W Placita Rancho Naranjo'));
        offList.add(new SelectOption('US - Oshkosh, WI','US - Oshkosh, WI'));
        offList.add(new SelectOption('US - Oswego, NY - URS 268 Lake Road','US - Oswego, NY - URS 268 Lake Road'));
        offList.add(new SelectOption('US - Ottumwa, IA - URS Alliant Energy 20775 Power Plant Road','US - Ottumwa, IA - URS Alliant Energy 20775 Power Plant Road'));
        offList.add(new SelectOption('US - Overland Park, KS - 7600 W 119th Street','US - Overland Park, KS - 7600 W 119th Street'));
        offList.add(new SelectOption('US - Overland Park, KS - 8300 College Blvd','US - Overland Park, KS - 8300 College Blvd'));
        offList.add(new SelectOption('US - Overland Park, KS - 8300 College Blvd Suite 200','US - Overland Park, KS - 8300 College Blvd Suite 200'));
        offList.add(new SelectOption('US - Overland Park, KS - URS 8300 College Blvd, Suite 200','US - Overland Park, KS - URS 8300 College Blvd, Suite 200'));
        offList.add(new SelectOption('US - Oxnard, CA - URS 1620 Firethorne Place','US - Oxnard, CA - URS 1620 Firethorne Place'));
        offList.add(new SelectOption('US - Oxnard, CA - URS 5901 Arctures Ave','US - Oxnard, CA - URS 5901 Arctures Ave'));
        offList.add(new SelectOption('US - Pacific Beach, WA - 108 First Street N P O Box 335','US - Pacific Beach, WA - 108 First Street N P O Box 335'));
        offList.add(new SelectOption('US - Paducah, KY - 333 Broadway Suite 808','US - Paducah, KY - 333 Broadway Suite 808'));
        offList.add(new SelectOption('US - Palestine, TX - 8049 S US Highway 79','US - Palestine, TX - 8049 S US Highway 79'));
        offList.add(new SelectOption('US - Palm Coast, FL - 8 Barrister Lane','US - Palm Coast, FL - 8 Barrister Lane'));
        offList.add(new SelectOption('US - Palm Harbor, FL - 2917 Glenpark Road','US - Palm Harbor, FL - 2917 Glenpark Road'));
        offList.add(new SelectOption('US - Palmyra, MO - URS 5374 Hwy 168','US - Palmyra, MO - URS 5374 Hwy 168'));
        offList.add(new SelectOption('US - Panama City, FL - 213 N. Comet Ave','US - Panama City, FL - 213 N. Comet Ave'));
        offList.add(new SelectOption('US - Panama City, FL - 239 Southwood Drive','US - Panama City, FL - 239 Southwood Drive'));
        offList.add(new SelectOption('US - Patuxent River, MD - 22709 McCauley Road','US - Patuxent River, MD - 22709 McCauley Road'));
        offList.add(new SelectOption('US - Patuxent River, MD - 47765 Ranch Road Hangar 101 Room A','US - Patuxent River, MD - 47765 Ranch Road Hangar 101 Room A'));
        offList.add(new SelectOption('US - Paulsboro, NJ - 303 Mantua Avenue','US - Paulsboro, NJ - 303 Mantua Avenue'));
        offList.add(new SelectOption('US - Pearl Harbor, HI - Pearl Harbor Naval Station 850 Ticon','US - Pearl Harbor, HI - Pearl Harbor Naval Station 850 Ticon'));
        offList.add(new SelectOption('US - Pearl River, NY - URS 401 Middletown Rd','US - Pearl River, NY - URS 401 Middletown Rd'));
        offList.add(new SelectOption('US - Pelham, AL - 6538 Remington Court','US - Pelham, AL - 6538 Remington Court'));
        offList.add(new SelectOption('US - Pennsylvania - Telecommute','US - Pennsylvania - Telecommute'));
        offList.add(new SelectOption('US - Pensacola, FL - Naval Hosp Pensacola 6000 West Hwy 98','US - Pensacola, FL - Naval Hosp Pensacola 6000 West Hwy 98'));
        offList.add(new SelectOption('US - Peoria, IL - URS 1335 Sw Washington St.','US - Peoria, IL - URS 1335 Sw Washington St.'));
        offList.add(new SelectOption('US - Peoria, IL - URS 411 Hamilton Blvd. Suite 1810','US - Peoria, IL - URS 411 Hamilton Blvd. Suite 1810'));
        offList.add(new SelectOption('US - Peoria, IL - URS Cat Corporate Offices 100 Ne Adams St','US - Peoria, IL - URS Cat Corporate Offices 100 Ne Adams St'));
        offList.add(new SelectOption('US - Petion-Ville, Haiti - rue Panaméricaine no 47','US - Petion-Ville, Haiti - rue Panaméricaine no 47'));
        offList.add(new SelectOption('US - Philadelphia, PA - 10300 Drummond Road','US - Philadelphia, PA - 10300 Drummond Road'));
        offList.add(new SelectOption('US - Philadelphia, PA - 11601 Roosevelt Blvd','US - Philadelphia, PA - 11601 Roosevelt Blvd'));
        offList.add(new SelectOption('US - Philadelphia, PA - 1700 Market St','US - Philadelphia, PA - 1700 Market St'));
        offList.add(new SelectOption('US - Philadelphia, PA - 1900 Market St','US - Philadelphia, PA - 1900 Market St'));
        offList.add(new SelectOption('US - Philadelphia, PA - 2 Intl Plaza','US - Philadelphia, PA - 2 Intl Plaza'));
        offList.add(new SelectOption('US - Philadelphia, PA - 2205 Richmond Street','US - Philadelphia, PA - 2205 Richmond Street'));
        offList.add(new SelectOption('US - Philadelphia, PA - 8 Penn Center 1628 John F Kennedy Bo','US - Philadelphia, PA - 8 Penn Center 1628 John F Kennedy Bo'));
        offList.add(new SelectOption('US - Phoenix, AZ - 11 South Central Aveune','US - Phoenix, AZ - 11 South Central Aveune'));
        offList.add(new SelectOption('US - Phoenix, AZ - 1300 South 16th Street','US - Phoenix, AZ - 1300 South 16th Street'));
        offList.add(new SelectOption('US - Phoenix, AZ - 2325 E Camelback','US - Phoenix, AZ - 2325 E Camelback'));
        offList.add(new SelectOption('US - Phoenix, AZ - 2916 S 40th Street','US - Phoenix, AZ - 2916 S 40th Street'));
        offList.add(new SelectOption('US - Phoenix, AZ - 3400 E Sky Harbor Blvd','US - Phoenix, AZ - 3400 E Sky Harbor Blvd'));
        offList.add(new SelectOption('US - Phoenix, AZ - 420 North 44th Street','US - Phoenix, AZ - 420 North 44th Street'));
        offList.add(new SelectOption('US - Phoenix, AZ - 426 North 44th Street','US - Phoenix, AZ - 426 North 44th Street'));
        offList.add(new SelectOption('US - Phoenix, AZ - 5777 E Mayo Blvd','US - Phoenix, AZ - 5777 E Mayo Blvd'));
        offList.add(new SelectOption('US - Phoenix, AZ - 7720 North','US - Phoenix, AZ - 7720 North'));
        offList.add(new SelectOption('US - Phoenix, AZ - 7720 North 16th Street Suite 100','US - Phoenix, AZ - 7720 North 16th Street Suite 100'));
        offList.add(new SelectOption('US - Phoenix, AZ - 7720 North Suite 100','US - Phoenix, AZ - 7720 North Suite 100'));
        offList.add(new SelectOption('US - Phoenix, AZ - URS 7720 North 16th St. Suite: 100','US - Phoenix, AZ - URS 7720 North 16th St. Suite: 100'));
        offList.add(new SelectOption('US - Picayune, MS - 616 E. Canal Street','US - Picayune, MS - 616 E. Canal Street'));
        offList.add(new SelectOption('US - Piketon, OH - 1862 Shyville Road Suite 205','US - Piketon, OH - 1862 Shyville Road Suite 205'));
        offList.add(new SelectOption('US - Piscataway, NJ - 30 Knightsbridge Rd','US - Piscataway, NJ - 30 Knightsbridge Rd'));
        offList.add(new SelectOption('US - Pittsburgh, PA - 2000 Cliff Mine Rd','US - Pittsburgh, PA - 2000 Cliff Mine Rd'));
        offList.add(new SelectOption('US - Pittsburgh, PA - 3000 Sidney Street','US - Pittsburgh, PA - 3000 Sidney Street'));
        offList.add(new SelectOption('US - Pittsburgh, PA - 416 7th Avenue','US - Pittsburgh, PA - 416 7th Avenue'));
        offList.add(new SelectOption('US - PITTSBURGH, PA - 626 Cochran\'s Mill Road','US - PITTSBURGH, PA - 626 Cochran\'s Mill Road'));
        offList.add(new SelectOption('US - Pittsburgh, PA - 707 Grant Street','US - Pittsburgh, PA - 707 Grant Street'));
        offList.add(new SelectOption('US - Pittsburgh, PA - Foster Plaza 6','US - Pittsburgh, PA - Foster Plaza 6'));
        offList.add(new SelectOption('US - Pittsburgh, PA - Foster Plaza 6 681 Andersen Drive Suit','US - Pittsburgh, PA - Foster Plaza 6 681 Andersen Drive Suit'));
        offList.add(new SelectOption('US - PITTSBURGH, PA - Foster Plaza 6 681 Andersen Drive, Sui','US - PITTSBURGH, PA - Foster Plaza 6 681 Andersen Drive, Sui'));
        offList.add(new SelectOption('US - Pittsburgh, PA - Foster Plaza 6 Suite 400','US - Pittsburgh, PA - Foster Plaza 6 Suite 400'));
        offList.add(new SelectOption('US - Pittsburgh, PA - URS 60 Cedar Blvd','US - Pittsburgh, PA - URS 60 Cedar Blvd'));
        offList.add(new SelectOption('US - Pittsburgh, PA - URS 800 Regis Avenue Third Floor','US - Pittsburgh, PA - URS 800 Regis Avenue Third Floor'));
        offList.add(new SelectOption('US - Pittsfield, MA - 100 Plastics Ave','US - Pittsfield, MA - 100 Plastics Ave'));
        offList.add(new SelectOption('US - Pleasanton, CA - URS 1316 Montrose Place','US - Pleasanton, CA - URS 1316 Montrose Place'));
        offList.add(new SelectOption('US - Pleasanton, TX - 756 Eagle Ford','US - Pleasanton, TX - 756 Eagle Ford'));
        offList.add(new SelectOption('US - Plymouth, MA - URS Pilgrim Nuclear Station 600 Rocky Hi','US - Plymouth, MA - URS Pilgrim Nuclear Station 600 Rocky Hi'));
        offList.add(new SelectOption('US - Pocasset, MA - 9 Jonathan Bourne Drive','US - Pocasset, MA - 9 Jonathan Bourne Drive'));
        offList.add(new SelectOption('US - Pomona, MO - URS 4225 Odc Road 1020','US - Pomona, MO - URS 4225 Odc Road 1020'));
        offList.add(new SelectOption('US - Pompano Beach, FL - 2951 NW 27th Ave','US - Pompano Beach, FL - 2951 NW 27th Ave'));
        offList.add(new SelectOption('US - Pompano Beach, FL - Florida\'s Turnpike Enterprise','US - Pompano Beach, FL - Florida\'s Turnpike Enterprise'));
        offList.add(new SelectOption('US - Pontiac, MI - URS 220 East Columbia','US - Pontiac, MI - URS 220 East Columbia'));
        offList.add(new SelectOption('US - Pontiac, MI - URS 895 Joslyn Ave','US - Pontiac, MI - URS 895 Joslyn Ave'));
        offList.add(new SelectOption('US - Pontiac, MI - URS Cetc-Plant Engineering 823 Joslyn Roa','US - Pontiac, MI - URS Cetc-Plant Engineering 823 Joslyn Roa'));
        offList.add(new SelectOption('US - Pontiac, MI - URS Gm Me Cetc 823 Joslyn Road','US - Pontiac, MI - URS Gm Me Cetc 823 Joslyn Road'));
        offList.add(new SelectOption('US - Port of Spain, Trinidad & Tobago - 26 Kelly Kenny St','US - Port of Spain, Trinidad & Tobago - 26 Kelly Kenny St'));
        offList.add(new SelectOption('US - Port Saint Lucie, FL - 9312 Scarborough Ct','US - Port Saint Lucie, FL - 9312 Scarborough Ct'));
        offList.add(new SelectOption('US - Portand, OR - 15943 SE Bybee Dr','US - Portand, OR - 15943 SE Bybee Dr'));
        offList.add(new SelectOption('US - Portland, MA - 159 Lambert Street','US - Portland, MA - 159 Lambert Street'));
        offList.add(new SelectOption('US - Portland, ME - 477 Congress Street','US - Portland, ME - 477 Congress Street'));
        offList.add(new SelectOption('US - Portland, ME - 477 Congress Street 9th Floor','US - Portland, ME - 477 Congress Street 9th Floor'));
        offList.add(new SelectOption('US - Portland, ME - Two City Center','US - Portland, ME - Two City Center'));
        offList.add(new SelectOption('US - Portland, OR - 111 SW 5th Avenue','US - Portland, OR - 111 SW 5th Avenue'));
        offList.add(new SelectOption('US - Portland, OR - 111 SW Columbia Street','US - Portland, OR - 111 SW Columbia Street'));
        offList.add(new SelectOption('US - Portland, OR - 111 SW Columbia Street Suite 1500','US - Portland, OR - 111 SW Columbia Street Suite 1500'));
        offList.add(new SelectOption('US - Portland, OR - 333 SW 5th Ave','US - Portland, OR - 333 SW 5th Ave'));
        offList.add(new SelectOption('US - Portland, OR - 511 NW Broadway Ave','US - Portland, OR - 511 NW Broadway Ave'));
        offList.add(new SelectOption('US - Portsmouth, RI - 44 Silva Avenue','US - Portsmouth, RI - 44 Silva Avenue'));
        offList.add(new SelectOption('US - Portsmouth, VA - Bldg. 236 Berrien Street','US - Portsmouth, VA - Bldg. 236 Berrien Street'));
        offList.add(new SelectOption('US - Portsmouth, VA - Norfolk Naval Shipyard 100-199 William','US - Portsmouth, VA - Norfolk Naval Shipyard 100-199 William'));
        offList.add(new SelectOption('US - Portsmouth, VA - Portsmouth NMCP Cntr Portsmouth 54 Lew','US - Portsmouth, VA - Portsmouth NMCP Cntr Portsmouth 54 Lew'));
        offList.add(new SelectOption('US - Portsmouth, VA - SPAWARSYSCEN Atlantic Juliens Creek An','US - Portsmouth, VA - SPAWARSYSCEN Atlantic Juliens Creek An'));
        offList.add(new SelectOption('US - Pretoria, South Africa','US - Pretoria, South Africa'));
        offList.add(new SelectOption('US - Princeton, NJ - URS 510 Carnegie Center','US - Princeton, NJ - URS 510 Carnegie Center'));
        offList.add(new SelectOption('US - Providence, RI','US - Providence, RI'));
        offList.add(new SelectOption('US - Pryor, OK - URS 4581 Webb Street','US - Pryor, OK - URS 4581 Webb Street'));
        offList.add(new SelectOption('US - Pueblo, CO - 45825 Hwy 96E','US - Pueblo, CO - 45825 Hwy 96E'));
        offList.add(new SelectOption('US - Pueblo, CO - URS Bechtel Pueblo Team/Process Support Bl','US - Pueblo, CO - URS Bechtel Pueblo Team/Process Support Bl'));
        offList.add(new SelectOption('US - Pueblo, CO - URS Federal Services 45825 Highway 96 East','US - Pueblo, CO - URS Federal Services 45825 Highway 96 East'));
        offList.add(new SelectOption('US - Purcellville, VA - 208 E Skyline Drive','US - Purcellville, VA - 208 E Skyline Drive'));
        offList.add(new SelectOption('US - Quantico, VA - 27402 MCB-1 Road Marine Corps Informatio','US - Quantico, VA - 27402 MCB-1 Road Marine Corps Informatio'));
        offList.add(new SelectOption('US - Questa, NM - Rust Constructors Inc Chevron Environmenta','US - Questa, NM - Rust Constructors Inc Chevron Environmenta'));
        offList.add(new SelectOption('US - Questa, NM - Rust Constuctors Inc Chevron Environmental','US - Questa, NM - Rust Constuctors Inc Chevron Environmental'));
        offList.add(new SelectOption('US - Questa, NM - URS Questa Storm Water Mgmt 57 Red River S','US - Questa, NM - URS Questa Storm Water Mgmt 57 Red River S'));
        offList.add(new SelectOption('US - Raleigh, NC - 701 Corporate Center Dr','US - Raleigh, NC - 701 Corporate Center Dr'));
        offList.add(new SelectOption('US - Ratliff City, OK - 24130  State Hwy 76, PO Box 247','US - Ratliff City, OK - 24130  State Hwy 76, PO Box 247'));
        offList.add(new SelectOption('US - Redwood City, CA - 2940 Whipple Avenue','US - Redwood City, CA - 2940 Whipple Avenue'));
        offList.add(new SelectOption('US - Reno, NV','US - Reno, NV'));
        offList.add(new SelectOption('US - Reno, NV - 3950 Double R Blvd #4418','US - Reno, NV - 3950 Double R Blvd #4418'));
        offList.add(new SelectOption('US - Reno, NV - 790 Sandhill Road','US - Reno, NV - 790 Sandhill Road'));
        offList.add(new SelectOption('US - Reston, VA - 11911 Freedom Drive','US - Reston, VA - 11911 Freedom Drive'));
        offList.add(new SelectOption('US - Rhode Island - Telecommute','US - Rhode Island - Telecommute'));
        offList.add(new SelectOption('US - Richalnd, WA - 2435 Stevens Center Place','US - Richalnd, WA - 2435 Stevens Center Place'));
        offList.add(new SelectOption('US - Richardson, AR - TMC Bldg 604 B Street','US - Richardson, AR - TMC Bldg 604 B Street'));
        offList.add(new SelectOption('US - RICHLAND, WA - 2440 Stevens Dr','US - RICHLAND, WA - 2440 Stevens Dr'));
        offList.add(new SelectOption('US - Richland, WA - 723 The Parkway','US - Richland, WA - 723 The Parkway'));
        offList.add(new SelectOption('US - Richland, WA - 825 Goethals Drive','US - Richland, WA - 825 Goethals Drive'));
        offList.add(new SelectOption('US - Richland, WA - URS 723 The Parkway','US - Richland, WA - URS 723 The Parkway'));
        offList.add(new SelectOption('US - Richland, WA - URS Hanford Tank Operations Contract 244','US - Richland, WA - URS Hanford Tank Operations Contract 244'));
        offList.add(new SelectOption('US - Richland, WA - URS Washington Closure Hanford 2620 Ferm','US - Richland, WA - URS Washington Closure Hanford 2620 Ferm'));
        offList.add(new SelectOption('US - Richmond, British Columbia - 13775 Commerce Parkway','US - Richmond, British Columbia - 13775 Commerce Parkway'));
        offList.add(new SelectOption('US - Richmond, KY - 830 Eastern Bypress, Suite 106','US - Richmond, KY - 830 Eastern Bypress, Suite 106'));
        offList.add(new SelectOption('US - Richmond, KY - URS 830 Eastern Bypass Suite 106','US - Richmond, KY - URS 830 Eastern Bypass Suite 106'));
        offList.add(new SelectOption('US - Richmond, TX - URS 500 Hillcrest Drive','US - Richmond, TX - URS 500 Hillcrest Drive'));
        offList.add(new SelectOption('US - Richmond, VA - 4905 Dickens Road','US - Richmond, VA - 4905 Dickens Road'));
        offList.add(new SelectOption('US - Richmond, VA - 8000 Jefferson Davis Highway Building 54','US - Richmond, VA - 8000 Jefferson Davis Highway Building 54'));
        offList.add(new SelectOption('US - Richmond, VA - 900 East Broad Street','US - Richmond, VA - 900 East Broad Street'));
        offList.add(new SelectOption('US - Richmond, VA - URS C/O Altria Client Services 2325 Bell','US - Richmond, VA - URS C/O Altria Client Services 2325 Bell'));
        offList.add(new SelectOption('US - Richmond, VA - URS Pfizer 1211 Sherwood Ave','US - Richmond, VA - URS Pfizer 1211 Sherwood Ave'));
        offList.add(new SelectOption('US - Rimrock, AZ - URS 4605 N. Lazy Lariat Ln','US - Rimrock, AZ - URS 4605 N. Lazy Lariat Ln'));
        offList.add(new SelectOption('US - Riverside, CA - 6721 Sycamore Canyon Blvd','US - Riverside, CA - 6721 Sycamore Canyon Blvd'));
        offList.add(new SelectOption('US - Riyadh, Saudi Arabia - King Abdullah Education Bldg','US - Riyadh, Saudi Arabia - King Abdullah Education Bldg'));
        offList.add(new SelectOption('US - Roanoke, IN - URS Gm Fort Wayne Assembly Plant 12200 La','US - Roanoke, IN - URS Gm Fort Wayne Assembly Plant 12200 La'));
        offList.add(new SelectOption('US - Roanoke, VA - 10 S Jefferson St','US - Roanoke, VA - 10 S Jefferson St'));
        offList.add(new SelectOption('US - Roanoke, VA - 1315 Franklin Rd','US - Roanoke, VA - 1315 Franklin Rd'));
        offList.add(new SelectOption('US - Rochester, NY - 1200 Brooks Ave','US - Rochester, NY - 1200 Brooks Ave'));
        offList.add(new SelectOption('US - Rock Island Arsenal, IL - 1479 Gillespie Street, Ste 30','US - Rock Island Arsenal, IL - 1479 Gillespie Street, Ste 30'));
        offList.add(new SelectOption('US - Rock Island, IL','US - Rock Island, IL'));
        offList.add(new SelectOption('US - Rockville, MD - URS 9231 Corporate Blvd','US - Rockville, MD - URS 9231 Corporate Blvd'));
        offList.add(new SelectOption('US - Rocky Hill, CT - 500 Enterprise Dr','US - Rocky Hill, CT - 500 Enterprise Dr'));
        offList.add(new SelectOption('US - Rocky Hill, CT - 500 Enterprise Drive','US - Rocky Hill, CT - 500 Enterprise Drive'));
        offList.add(new SelectOption('US - Romulus, MI - URS Gm Romulus Engine Plant 36880 Ecorse ','US - Romulus, MI - URS Gm Romulus Engine Plant 36880 Ecorse '));
        offList.add(new SelectOption('US - Rosslyn, VA - 1801 N Lynn St 18th Floor','US - Rosslyn, VA - 1801 N Lynn St 18th Floor'));
        offList.add(new SelectOption('US - Rothschild, WI - URS Wps-Attn: Dan Price 2501 Morrison ','US - Rothschild, WI - URS Wps-Attn: Dan Price 2501 Morrison '));
        offList.add(new SelectOption('US - Round Rock, TX - 3341 Pioneer Crossing Drive','US - Round Rock, TX - 3341 Pioneer Crossing Drive'));
        offList.add(new SelectOption('US - Roxana, IL - Madison Ave & Hwy 111 Contractor Gate 4','US - Roxana, IL - Madison Ave & Hwy 111 Contractor Gate 4'));
        offList.add(new SelectOption('US - Roxana, IL - URS Contractor Gate #5 Rt 111 Madison Aven','US - Roxana, IL - URS Contractor Gate #5 Rt 111 Madison Aven'));
        offList.add(new SelectOption('US - Russellville, AL - URS 4590 County Road 339','US - Russellville, AL - URS 4590 County Road 339'));
        offList.add(new SelectOption('US - Sacramento, CA - 2020 L St','US - Sacramento, CA - 2020 L St'));
        offList.add(new SelectOption('US - Sacramento, CA - 2870 Gateway Oaks Drive','US - Sacramento, CA - 2870 Gateway Oaks Drive'));
        offList.add(new SelectOption('US - Sacramento, CA - 2870 Gateway Oaks Drive Suite 150','US - Sacramento, CA - 2870 Gateway Oaks Drive Suite 150'));
        offList.add(new SelectOption('US - Sacramento, CA - 650 Capital Mall','US - Sacramento, CA - 650 Capital Mall'));
        offList.add(new SelectOption('US - Sagamore Hills, OH - URS 622 Inverlane Drive','US - Sagamore Hills, OH - URS 622 Inverlane Drive'));
        offList.add(new SelectOption('US - Saint Albans, UK - 63-77 Victoria Street','US - Saint Albans, UK - 63-77 Victoria Street'));
        offList.add(new SelectOption('US - Saint Francisville, LA - URS Entergy Operations, River ','US - Saint Francisville, LA - URS Entergy Operations, River '));
        offList.add(new SelectOption('US - Saint Louis, MO - 1222 Spruce Street','US - Saint Louis, MO - 1222 Spruce Street'));
        offList.add(new SelectOption('US - Saint Louis, MO - URS 1001 Highland Plaza Dr. West Suit','US - Saint Louis, MO - URS 1001 Highland Plaza Dr. West Suit'));
        offList.add(new SelectOption('US - Saint Louis, MO - URS 1001 Highlands Plaza Dr W# 300','US - Saint Louis, MO - URS 1001 Highlands Plaza Dr W# 300'));
        offList.add(new SelectOption('US - Saint Louis, MO - URS One Busch Place','US - Saint Louis, MO - URS One Busch Place'));
        offList.add(new SelectOption('US - Saint Paul, MN - 1360 University Avenue','US - Saint Paul, MN - 1360 University Avenue'));
        offList.add(new SelectOption('US - Salt Lake City, UT - 5272 S. College Drive','US - Salt Lake City, UT - 5272 S. College Drive'));
        offList.add(new SelectOption('US - Salt Lake City, UT - 756 East Winchester Street','US - Salt Lake City, UT - 756 East Winchester Street'));
        offList.add(new SelectOption('US - Salt Lake City, UT - 756 East Winchester Street Suite 4','US - Salt Lake City, UT - 756 East Winchester Street Suite 4'));
        offList.add(new SelectOption('US - Salt Lake City, UT - 776 N Terminal Dr','US - Salt Lake City, UT - 776 N Terminal Dr'));
        offList.add(new SelectOption('US - San Angelo, TX - 4859 North Chadbourne','US - San Angelo, TX - 4859 North Chadbourne'));
        offList.add(new SelectOption('US - San Antonio, TX - 1048 E Commerce Street','US - San Antonio, TX - 1048 E Commerce Street'));
        offList.add(new SelectOption('US - San Antonio, TX - 10819 Caddo Cavern','US - San Antonio, TX - 10819 Caddo Cavern'));
        offList.add(new SelectOption('US - San Antonio, TX - 1111 Vista Valet Ste. 314','US - San Antonio, TX - 1111 Vista Valet Ste. 314'));
        offList.add(new SelectOption('US - San Antonio, TX - 112 Pecan Street','US - San Antonio, TX - 112 Pecan Street'));
        offList.add(new SelectOption('US - San Antonio, TX - 11225 Gordon Road Suite 102','US - San Antonio, TX - 11225 Gordon Road Suite 102'));
        offList.add(new SelectOption('US - San Antonio, TX - 18722 Crosstimber','US - San Antonio, TX - 18722 Crosstimber'));
        offList.add(new SelectOption('US - San Antonio, TX - 300 Convent Street','US - San Antonio, TX - 300 Convent Street'));
        offList.add(new SelectOption('US - San Antonio, TX - 33 Morris Witt Street, Bldg. 1 Door 1','US - San Antonio, TX - 33 Morris Witt Street, Bldg. 1 Door 1'));
        offList.add(new SelectOption('US - San Antonio, TX - 333 Morris Witt, Bldg 1538, Ste C','US - San Antonio, TX - 333 Morris Witt, Bldg 1538, Ste C'));
        offList.add(new SelectOption('US - San Antonio, TX - 403 Willow Grove Drive','US - San Antonio, TX - 403 Willow Grove Drive'));
        offList.add(new SelectOption('US - San Antonio, TX - 8200 IH-10 West Suite 820','US - San Antonio, TX - 8200 IH-10 West Suite 820'));
        offList.add(new SelectOption('US - San Antonio, TX - 8626 Tesoro Drive, Ste 450','US - San Antonio, TX - 8626 Tesoro Drive, Ste 450'));
        offList.add(new SelectOption('US - San Antonio, TX - 9901 IH10 West','US - San Antonio, TX - 9901 IH10 West'));
        offList.add(new SelectOption('US - San Antonio, TX - 9901 IH10 West Suite 350','US - San Antonio, TX - 9901 IH10 West Suite 350'));
        offList.add(new SelectOption('US - San Antonio, TX - Brooke AMC HQ US 5th Army, 3851 Roger','US - San Antonio, TX - Brooke AMC HQ US 5th Army, 3851 Roger'));
        offList.add(new SelectOption('US - San Antonio, TX - One AT&T Center Parkway','US - San Antonio, TX - One AT&T Center Parkway'));
        offList.add(new SelectOption('US - San Antonio, TX - PROS Acquisition Center 1070 Arion Ci','US - San Antonio, TX - PROS Acquisition Center 1070 Arion Ci'));
        offList.add(new SelectOption('US - San Bernardino, CA - 290 North D Street','US - San Bernardino, CA - 290 North D Street'));
        offList.add(new SelectOption('US - San Diego, CA - 2417 McCain Road','US - San Diego, CA - 2417 McCain Road'));
        offList.add(new SelectOption('US - San Diego, CA - 3990 Old Town Avenue','US - San Diego, CA - 3990 Old Town Avenue'));
        offList.add(new SelectOption('US - San Diego, CA - 401 West A Street','US - San Diego, CA - 401 West A Street'));
        offList.add(new SelectOption('US - San Diego, CA - 4755 Railroad Way Suite 113','US - San Diego, CA - 4755 Railroad Way Suite 113'));
        offList.add(new SelectOption('US - San Diego, CA - 5500 Campanile Drive','US - San Diego, CA - 5500 Campanile Drive'));
        offList.add(new SelectOption('US - San Diego, CA - 7807 Convoy Ct','US - San Diego, CA - 7807 Convoy Ct'));
        offList.add(new SelectOption('US - San Diego, CA - 880 Front St #4255','US - San Diego, CA - 880 Front St #4255'));
        offList.add(new SelectOption('US - San Diego, CA - 9284 Balboa Ave','US - San Diego, CA - 9284 Balboa Ave'));
        offList.add(new SelectOption('US - San Diego, CA - Balboa Naval Med Center San Diego 34520','US - San Diego, CA - Balboa Naval Med Center San Diego 34520'));
        offList.add(new SelectOption('US - San Diego, CA - Bldg. 873 Rogers Road','US - San Diego, CA - Bldg. 873 Rogers Road'));
        offList.add(new SelectOption('US - San Diego, CA - DDDC Bldg 322, 2680 Woden St','US - San Diego, CA - DDDC Bldg 322, 2680 Woden St'));
        offList.add(new SelectOption('US - San Diego, CA - DLA/FRCSW','US - San Diego, CA - DLA/FRCSW'));
        offList.add(new SelectOption('US - San Diego, CA - NAS North Island Bldg G, Rm 133','US - San Diego, CA - NAS North Island Bldg G, Rm 133'));
        offList.add(new SelectOption('US - San Diego, CA - URS 11961 Avenida Sivrita','US - San Diego, CA - URS 11961 Avenida Sivrita'));
        offList.add(new SelectOption('US - San Francisco, CA - 100 Pine Street','US - San Francisco, CA - 100 Pine Street'));
        offList.add(new SelectOption('US - San Francisco, CA - 250 Broadway Street','US - San Francisco, CA - 250 Broadway Street'));
        offList.add(new SelectOption('US - San Francisco, CA - 300 California Street','US - San Francisco, CA - 300 California Street'));
        offList.add(new SelectOption('US - San Francisco, CA - 44 Montgomery Street, Ste. 2800','US - San Francisco, CA - 44 Montgomery Street, Ste. 2800'));
        offList.add(new SelectOption('US - San Francisco, CA - 600 Montgomery Street','US - San Francisco, CA - 600 Montgomery Street'));
        offList.add(new SelectOption('US - San Francisco, CA - 600 Montgomery Street 26th Floor','US - San Francisco, CA - 600 Montgomery Street 26th Floor'));
        offList.add(new SelectOption('US - San Francisco, CA - 630 Sansome St','US - San Francisco, CA - 630 Sansome St'));
        offList.add(new SelectOption('US - San Francisco, CA - One Montgomery Street','US - San Francisco, CA - One Montgomery Street'));
        offList.add(new SelectOption('US - San Francisco, CA - One Montgomery Street Suite 900','US - San Francisco, CA - One Montgomery Street Suite 900'));
        offList.add(new SelectOption('US - San Jose, CA - 100 W San Fernando Street','US - San Jose, CA - 100 W San Fernando Street'));
        offList.add(new SelectOption('US - San Jose, CA - 100 W San Fernando Street Suite 200','US - San Jose, CA - 100 W San Fernando Street Suite 200'));
        offList.add(new SelectOption('US - San Jose, CA - 150 West San Carlos','US - San Jose, CA - 150 West San Carlos'));
        offList.add(new SelectOption('US - San Jose, CA - 2025 Gateway Pl','US - San Jose, CA - 2025 Gateway Pl'));
        offList.add(new SelectOption('US - San Juan, PR - 500 Tanca Street Suite 401','US - San Juan, PR - 500 Tanca Street Suite 401'));
        offList.add(new SelectOption('US - San Lorenzo, CA - 16525 Worthley Drive','US - San Lorenzo, CA - 16525 Worthley Drive'));
        offList.add(new SelectOption('US - San Luis Obispo, CA - 1194 Pacific St','US - San Luis Obispo, CA - 1194 Pacific St'));
        offList.add(new SelectOption('US - San Marcos, CA - URS 1632 San Pablo Drive','US - San Marcos, CA - URS 1632 San Pablo Drive'));
        offList.add(new SelectOption('US - San Tan Valley, AZ - 484 E Laddoos Ave','US - San Tan Valley, AZ - 484 E Laddoos Ave'));
        offList.add(new SelectOption('US - Sandpoint, ID - URS Transportation Information Office T','US - Sandpoint, ID - URS Transportation Information Office T'));
        offList.add(new SelectOption('US - Sanford, NC - URS Cat Inc 5000 Womack Rd','US - Sanford, NC - URS Cat Inc 5000 Womack Rd'));
        offList.add(new SelectOption('US - Santa Ana, CA - 1666 North Main Street','US - Santa Ana, CA - 1666 North Main Street'));
        offList.add(new SelectOption('US - Santa Ana, CA - 2020 East First Street','US - Santa Ana, CA - 2020 East First Street'));
        offList.add(new SelectOption('US - Santa Ana, CA - 2020 East First Street Suite 400','US - Santa Ana, CA - 2020 East First Street Suite 400'));
        offList.add(new SelectOption('US - Santa Ana, CA - 34 Civic Center Plaza 4th floor','US - Santa Ana, CA - 34 Civic Center Plaza 4th floor'));
        offList.add(new SelectOption('US - Santa Ana, CA - URS 2020 E. First Street, Ste. 400','US - Santa Ana, CA - URS 2020 E. First Street, Ste. 400'));
        offList.add(new SelectOption('US - Santa Barbara, CA - 130 Robin Hill Road','US - Santa Barbara, CA - 130 Robin Hill Road'));
        offList.add(new SelectOption('US - Santa Maria, CA - 2400 Professional Parkway','US - Santa Maria, CA - 2400 Professional Parkway'));
        offList.add(new SelectOption('US - Santa Maria, CA - 2625 South Miller Street','US - Santa Maria, CA - 2625 South Miller Street'));
        offList.add(new SelectOption('US - Sarasota, FL - 6151 Lake Osprey Drive','US - Sarasota, FL - 6151 Lake Osprey Drive'));
        offList.add(new SelectOption('US - Savannah, GA - Riverside Powerplant','US - Savannah, GA - Riverside Powerplant'));
        offList.add(new SelectOption('US - Scott AFB, IL - DISA CONUS 604 Tyler St Bldg 3189','US - Scott AFB, IL - DISA CONUS 604 Tyler St Bldg 3189'));
        offList.add(new SelectOption('US - Scott Depot, WV - Number 4 Mission Way Suite 201','US - Scott Depot, WV - Number 4 Mission Way Suite 201'));
        offList.add(new SelectOption('US - Scottsdale, AZ - 6720 North Scottsdale Rd','US - Scottsdale, AZ - 6720 North Scottsdale Rd'));
        offList.add(new SelectOption('US - Seagrove, NC - 3455 Brower Mill Road','US - Seagrove, NC - 3455 Brower Mill Road'));
        offList.add(new SelectOption('US - Seattle, WA - 12500 Tukwila International Blvd','US - Seattle, WA - 12500 Tukwila International Blvd'));
        offList.add(new SelectOption('US - Seattle, WA - 12500 Tukwila Intl Blvd','US - Seattle, WA - 12500 Tukwila Intl Blvd'));
        offList.add(new SelectOption('US - Seattle, WA - 1501 4th Avenue','US - Seattle, WA - 1501 4th Avenue'));
        offList.add(new SelectOption('US - Seattle, WA - 710 Second Ave','US - Seattle, WA - 710 Second Ave'));
        offList.add(new SelectOption('US - Seattle, WA - 9017-A 18th Ave SW','US - Seattle, WA - 9017-A 18th Ave SW'));
        offList.add(new SelectOption('US - Seattle, WA - URS 1501 4th Ave Suite: 1400','US - Seattle, WA - URS 1501 4th Ave Suite: 1400'));
        offList.add(new SelectOption('US - Seattle, WA - URS Cse Ee3/ Construction Office 185 Stev','US - Seattle, WA - URS Cse Ee3/ Construction Office 185 Stev'));
        offList.add(new SelectOption('US - Selfridge ANGB, MI - Bldg 1414 West Perimeter Road','US - Selfridge ANGB, MI - Bldg 1414 West Perimeter Road'));
        offList.add(new SelectOption('US - Seneca, SC - URS Oconee Nuclear Power Plant 7800 Roches','US - Seneca, SC - URS Oconee Nuclear Power Plant 7800 Roches'));
        offList.add(new SelectOption('US - Sevierville, TN - 3319 Thomaswood Trail','US - Sevierville, TN - 3319 Thomaswood Trail'));
        offList.add(new SelectOption('US - Sevilla, Spain - Moron Air Base','US - Sevilla, Spain - Moron Air Base'));
        offList.add(new SelectOption('US - Shanghai, China - 30th, Shanghai Times Square','US - Shanghai, China - 30th, Shanghai Times Square'));
        offList.add(new SelectOption('US - Shanghai, China - Disney Shanghai','US - Shanghai, China - Disney Shanghai'));
        offList.add(new SelectOption('US - Shatin, Hong Kong','US - Shatin, Hong Kong'));
        offList.add(new SelectOption('US - Shatin, Hong Kong - 138 Shatin Rural Committee Road','US - Shatin, Hong Kong - 138 Shatin Rural Committee Road'));
        offList.add(new SelectOption('US - Shrewsbury, NJ - EG&G/LSI 595 Shrewsbury Ave.','US - Shrewsbury, NJ - EG&G/LSI 595 Shrewsbury Ave.'));
        offList.add(new SelectOption('US - Sidney, MT - URS Montana Utilities 35023 Highway 23 E','US - Sidney, MT - URS Montana Utilities 35023 Highway 23 E'));
        offList.add(new SelectOption('US - Sierra Vista, AZ - 2818 Sierra Bermeja Drive','US - Sierra Vista, AZ - 2818 Sierra Bermeja Drive'));
        offList.add(new SelectOption('US - Silver Spring, MD - 1315 East West Highway','US - Silver Spring, MD - 1315 East West Highway'));
        offList.add(new SelectOption('US - Silver Spring, MD - 1317 Crockett Lane','US - Silver Spring, MD - 1317 Crockett Lane'));
        offList.add(new SelectOption('US - Simpsonville, SC - 205 Loraine Drive','US - Simpsonville, SC - 205 Loraine Drive'));
        offList.add(new SelectOption('US - Singapore - 300 Beach Rd','US - Singapore - 300 Beach Rd'));
        offList.add(new SelectOption('US - Skowhegan, ME - URS 1329 Waterville Road','US - Skowhegan, ME - URS 1329 Waterville Road'));
        offList.add(new SelectOption('US - Skowhegan, ME - URS C/O S D Warren Rt 201 Rfd #3','US - Skowhegan, ME - URS C/O S D Warren Rt 201 Rfd #3'));
        offList.add(new SelectOption('US - Soda Springs, ID - URS 3010 Conda Road','US - Soda Springs, ID - URS 3010 Conda Road'));
        offList.add(new SelectOption('US - Soda Springs, ID - URS 91 S Main','US - Soda Springs, ID - URS 91 S Main'));
        offList.add(new SelectOption('US - Soda Springs, ID - URS 91 S. Main','US - Soda Springs, ID - URS 91 S. Main'));
        offList.add(new SelectOption('US - Soda Springs, ID - URS Government Dam Road','US - Soda Springs, ID - URS Government Dam Road'));
        offList.add(new SelectOption('US - Solomons, MD - Bldg. 105 B Avenue','US - Solomons, MD - Bldg. 105 B Avenue'));
        offList.add(new SelectOption('US - South Bend, IN - 63480 Ironwood Rd','US - South Bend, IN - 63480 Ironwood Rd'));
        offList.add(new SelectOption('US - South Burlington, VT - 65 Bowdoin Street','US - South Burlington, VT - 65 Bowdoin Street'));
        offList.add(new SelectOption('US - South Burlington, VT - 70 Kimball Avenue','US - South Burlington, VT - 70 Kimball Avenue'));
        offList.add(new SelectOption('US - South Carolina - Telecommute','US - South Carolina - Telecommute'));
        offList.add(new SelectOption('US - South Jordan, UT - 9766 S. Yorkshire','US - South Jordan, UT - 9766 S. Yorkshire'));
        offList.add(new SelectOption('US - South Park Twp, PA - URS 626 Cochrans Mill Road','US - South Park Twp, PA - URS 626 Cochrans Mill Road'));
        offList.add(new SelectOption('US - SOUTH PARK, PA - PO Box 618','US - SOUTH PARK, PA - PO Box 618'));
        offList.add(new SelectOption('US - South Portland, ME - 500 Southborough Dr','US - South Portland, ME - 500 Southborough Dr'));
        offList.add(new SelectOption('US - Southfield, MI - 26500 American Drive','US - Southfield, MI - 26500 American Drive'));
        offList.add(new SelectOption('US - Southfield, MI - 27777 Franklin Road','US - Southfield, MI - 27777 Franklin Road'));
        offList.add(new SelectOption('US - Southfield, MI - URS 27777 Franklin Road Suite 2000','US - Southfield, MI - URS 27777 Franklin Road Suite 2000'));
        offList.add(new SelectOption('US - Southport, CT - 2425 Post Rd','US - Southport, CT - 2425 Post Rd'));
        offList.add(new SelectOption('US - Southport, NC - URS Brunswick Nuclear Generation Stn. 8','US - Southport, NC - URS Brunswick Nuclear Generation Stn. 8'));
        offList.add(new SelectOption('US - Southport, NC - URS Brunswick Nuclear Power Plant 8520 ','US - Southport, NC - URS Brunswick Nuclear Power Plant 8520 '));
        offList.add(new SelectOption('US - Spello, Italy - Via Cappuccini 4A','US - Spello, Italy - Via Cappuccini 4A'));
        offList.add(new SelectOption('US - Spokane, WA - 141 LS/LGS 2 South Olympia Avenue','US - Spokane, WA - 141 LS/LGS 2 South Olympia Avenue'));
        offList.add(new SelectOption('US - Spokane, WA - 411 West Cataldo Avenue','US - Spokane, WA - 411 West Cataldo Avenue'));
        offList.add(new SelectOption('US - Spokane, WA - 528 East Spokane Falls Blvd','US - Spokane, WA - 528 East Spokane Falls Blvd'));
        offList.add(new SelectOption('US - Spokane, WA - URS Caterpillar Inc 9610 W. Hallett Road','US - Spokane, WA - URS Caterpillar Inc 9610 W. Hallett Road'));
        offList.add(new SelectOption('US - Spring City, TN - URS Watts Bar Units 1 & 2 1270 Nuclea','US - Spring City, TN - URS Watts Bar Units 1 & 2 1270 Nuclea'));
        offList.add(new SelectOption('US - Spring Hill, TN - URS Hwy 31 S','US - Spring Hill, TN - URS Hwy 31 S'));
        offList.add(new SelectOption('US - Springfield, OH - 1128 A Avenue Bldg 128','US - Springfield, OH - 1128 A Avenue Bldg 128'));
        offList.add(new SelectOption('US - Springfield, VA - 6564 Loisdale Ct','US - Springfield, VA - 6564 Loisdale Ct'));
        offList.add(new SelectOption('US - Springfield, VA - 7405 Alban Station Ct','US - Springfield, VA - 7405 Alban Station Ct'));
        offList.add(new SelectOption('US - Springfield, VA - 7420 Fullterton Road, Suite 104','US - Springfield, VA - 7420 Fullterton Road, Suite 104'));
        offList.add(new SelectOption('US - Springfield, VA - OCONUS Classified','US - Springfield, VA - OCONUS Classified'));
        offList.add(new SelectOption('US - St George, UT - 805 South Dixie Drive, Unit 44','US - St George, UT - 805 South Dixie Drive, Unit 44'));
        offList.add(new SelectOption('US - St Louis, MO - 1001 Highlands Plaza Dr West Suite 300','US - St Louis, MO - 1001 Highlands Plaza Dr West Suite 300'));
        offList.add(new SelectOption('US - St. Louis, MO - 1001 Highlands Plaza Dr West','US - St. Louis, MO - 1001 Highlands Plaza Dr West'));
        offList.add(new SelectOption('US - St. Louis, MO - 1001 Highlands Plaza Drive West Suite 3','US - St. Louis, MO - 1001 Highlands Plaza Drive West Suite 3'));
        offList.add(new SelectOption('US - Stafford, VA - 1000 Corporate Drive, Suite 201','US - Stafford, VA - 1000 Corporate Drive, Suite 201'));
        offList.add(new SelectOption('US - State College, PA','US - State College, PA'));
        offList.add(new SelectOption('US - Stevens Point, WI - 200 Indiana Ave','US - Stevens Point, WI - 200 Indiana Ave'));
        offList.add(new SelectOption('US - Stillwater, OK - 8712 West 6 Avenue','US - Stillwater, OK - 8712 West 6 Avenue'));
        offList.add(new SelectOption('US - Stockton, UT - 11600 Stark Road','US - Stockton, UT - 11600 Stark Road'));
        offList.add(new SelectOption('US - Stuart, FL - 850 NW Federal Highway','US - Stuart, FL - 850 NW Federal Highway'));
        offList.add(new SelectOption('US - Suffolk, VA - 115 Lakeview Parkway','US - Suffolk, VA - 115 Lakeview Parkway'));
        offList.add(new SelectOption('US - Suffolk, VA - 116 Lakeview Parkway Suite 100B','US - Suffolk, VA - 116 Lakeview Parkway Suite 100B'));
        offList.add(new SelectOption('US - Suffolk, VA - URS Lockheed Martin 7021 Harbor View Blvd','US - Suffolk, VA - URS Lockheed Martin 7021 Harbor View Blvd'));
        offList.add(new SelectOption('US - Sugar Creek, MO - PO Box 7770','US - Sugar Creek, MO - PO Box 7770'));
        offList.add(new SelectOption('US - Sunrise, FL - 13450 W Sunrise Blvd','US - Sunrise, FL - 13450 W Sunrise Blvd'));
        offList.add(new SelectOption('US - Sunrise, FL - URS 10276 Nw 47 Street','US - Sunrise, FL - URS 10276 Nw 47 Street'));
        offList.add(new SelectOption('US - Sydney, Australia - 420 George St','US - Sydney, Australia - 420 George St'));
        offList.add(new SelectOption('US - Syracuse, NY - 174TH FW / C-26 6001 E. Molloy Road','US - Syracuse, NY - 174TH FW / C-26 6001 E. Molloy Road'));
        offList.add(new SelectOption('US - Syracuse, NY - 6001 E Malloy Road Bldg 610, Room 206','US - Syracuse, NY - 6001 E Malloy Road Bldg 610, Room 206'));
        offList.add(new SelectOption('US - Tacoma, WA - 1623 East J St 2nd floor','US - Tacoma, WA - 1623 East J St 2nd floor'));
        offList.add(new SelectOption('US - Tacoma, WA - MCHJ-IM Bldg 9040A Fitzsimmons Drive','US - Tacoma, WA - MCHJ-IM Bldg 9040A Fitzsimmons Drive'));
        offList.add(new SelectOption('US - Tallahassee, FL - 1625 Summit Lake Drive Suite 200','US - Tallahassee, FL - 1625 Summit Lake Drive Suite 200'));
        offList.add(new SelectOption('US - Tamarac, FL - URS 7000 Nw 64th Street','US - Tamarac, FL - URS 7000 Nw 64th Street'));
        offList.add(new SelectOption('US - Tampa, FL - 5629 Hoover Boulevard','US - Tampa, FL - 5629 Hoover Boulevard'));
        offList.add(new SelectOption('US - Tampa, FL - 7650 W Courtney Campbell Causeway','US - Tampa, FL - 7650 W Courtney Campbell Causeway'));
        offList.add(new SelectOption('US - Tampa, FL - One Metro Center','US - Tampa, FL - One Metro Center'));
        offList.add(new SelectOption('US - Tampa, FL - Wachovia Center 100 South Ashley Drive','US - Tampa, FL - Wachovia Center 100 South Ashley Drive'));
        offList.add(new SelectOption('US - Tempe, AZ - 500 East Veterans Way','US - Tempe, AZ - 500 East Veterans Way'));
        offList.add(new SelectOption('US - Tempe, AZ - 8701 South Hardy Drive','US - Tempe, AZ - 8701 South Hardy Drive'));
        offList.add(new SelectOption('US - Temperanceville, VA - 30457 Temperanceville Rd','US - Temperanceville, VA - 30457 Temperanceville Rd'));
        offList.add(new SelectOption('US - Tennessee - Telecommute','US - Tennessee - Telecommute'));
        offList.add(new SelectOption('US - Texarkana, TX - 29 Summer Lane','US - Texarkana, TX - 29 Summer Lane'));
        offList.add(new SelectOption('US - Texarkana, TX - Bldg. 421 South','US - Texarkana, TX - Bldg. 421 South'));
        offList.add(new SelectOption('US - Texas - Telecommute','US - Texas - Telecommute'));
        offList.add(new SelectOption('US - The Villages, FL - 1329 Eureka Mill Run','US - The Villages, FL - 1329 Eureka Mill Run'));
        offList.add(new SelectOption('US - The Villages, FL - 3101 Avondale Ave','US - The Villages, FL - 3101 Avondale Ave'));
        offList.add(new SelectOption('US - Tinker AFB, OK - AFLCMC/WWZB (B-2 Sustainment Branch) 7','US - Tinker AFB, OK - AFLCMC/WWZB (B-2 Sustainment Branch) 7'));
        offList.add(new SelectOption('US - Tobyhanna, PA - 11 Hap Arnold Blvd','US - Tobyhanna, PA - 11 Hap Arnold Blvd'));
        offList.add(new SelectOption('US - Tobyhanna, PA - 11 Hap Arnold Boulevard','US - Tobyhanna, PA - 11 Hap Arnold Boulevard'));
        offList.add(new SelectOption('US - Toronto, CAN - Toronto Pearson Intl Airport','US - Toronto, CAN - Toronto Pearson Intl Airport'));
        offList.add(new SelectOption('US - Travis AFB, CA - David Grant Medical Center 101 Bodin C','US - Travis AFB, CA - David Grant Medical Center 101 Bodin C'));
        offList.add(new SelectOption('US - Trenton, NJ','US - Trenton, NJ'));
        offList.add(new SelectOption('US - Tripoli, Libya','US - Tripoli, Libya'));
        offList.add(new SelectOption('US - Trophy Club, TX - 51 Alamosa Dr.','US - Trophy Club, TX - 51 Alamosa Dr.'));
        offList.add(new SelectOption('US - Tucson, AZ - 1600 E. Super Sabre Dr Bldg 10','US - Tucson, AZ - 1600 E. Super Sabre Dr Bldg 10'));
        offList.add(new SelectOption('US - Tucson, AZ - 1840 East River Road','US - Tucson, AZ - 1840 East River Road'));
        offList.add(new SelectOption('US - Tucson, AZ - 2924 E Cannes Street','US - Tucson, AZ - 2924 E Cannes Street'));
        offList.add(new SelectOption('US - Tucson, AZ - 333 East Wetmore Suite 400','US - Tucson, AZ - 333 East Wetmore Suite 400'));
        offList.add(new SelectOption('US - Tucson, AZ - 3374 S. Desert Echo Road','US - Tucson, AZ - 3374 S. Desert Echo Road'));
        offList.add(new SelectOption('US - Tucson, AZ - 4475 S Coach Drive','US - Tucson, AZ - 4475 S Coach Drive'));
        offList.add(new SelectOption('US - TUCSON, AZ - ARIZONA ANG 1500 E. VALENCIA','US - TUCSON, AZ - ARIZONA ANG 1500 E. VALENCIA'));
        offList.add(new SelectOption('US - Tulsa, OK - 7633 E 63rd Place, Suite 500','US - Tulsa, OK - 7633 E 63rd Place, Suite 500'));
        offList.add(new SelectOption('US - Tulsa, OK - URS Flint 7633 E. 63rd Suite: 500','US - Tulsa, OK - URS Flint 7633 E. 63rd Suite: 500'));
        offList.add(new SelectOption('US - Tyndall AFB, FL - 104 Research Rd Bldg 9738','US - Tyndall AFB, FL - 104 Research Rd Bldg 9738'));
        offList.add(new SelectOption('US - Uniondale, NY - 1255 Hempstead Turnpike','US - Uniondale, NY - 1255 Hempstead Turnpike'));
        offList.add(new SelectOption('US - Upper Macungie Twp, PA - URS Kraft Foods 7532 Industria','US - Upper Macungie Twp, PA - URS Kraft Foods 7532 Industria'));
        offList.add(new SelectOption('US - Utah - Telecommute','US - Utah - Telecommute'));
        offList.add(new SelectOption('US - Valencia, CA - 27065 Clarence Ct.','US - Valencia, CA - 27065 Clarence Ct.'));
        offList.add(new SelectOption('US - Van Nuys, CA - URS 8110 Woodley Avenue','US - Van Nuys, CA - URS 8110 Woodley Avenue'));
        offList.add(new SelectOption('US - Vermont - Telecommute','US - Vermont - Telecommute'));
        offList.add(new SelectOption('US - Vernon Hills, IL','US - Vernon Hills, IL'));
        offList.add(new SelectOption('US - Victoria, TX - 2905 Highway 59 North','US - Victoria, TX - 2905 Highway 59 North'));
        offList.add(new SelectOption('US - Vienna, VA - 1921 Gallows Road','US - Vienna, VA - 1921 Gallows Road'));
        offList.add(new SelectOption('US - Vienna, VA - URS 1595 Spring Hill Road','US - Vienna, VA - URS 1595 Spring Hill Road'));
        offList.add(new SelectOption('US - Vincennes, IN - 511 Willow Street','US - Vincennes, IN - 511 Willow Street'));
        offList.add(new SelectOption('US - Virginia - Telecommute','US - Virginia - Telecommute'));
        offList.add(new SelectOption('US - Virginia Beach, VA - 1922 Regulus Ave Hopper Hall','US - Virginia Beach, VA - 1922 Regulus Ave Hopper Hall'));
        offList.add(new SelectOption('US - Virginia Beach, VA - 2088 Regulus Ave Bldg 420','US - Virginia Beach, VA - 2088 Regulus Ave Bldg 420'));
        offList.add(new SelectOption('US - Virginia Beach, VA - 277 Bendix Road','US - Virginia Beach, VA - 277 Bendix Road'));
        offList.add(new SelectOption('US - Virginia Beach, VA - 427 Polaris Street Bldg 586','US - Virginia Beach, VA - 427 Polaris Street Bldg 586'));
        offList.add(new SelectOption('US - Virginia Beach, VA - 601 Oceana Blvd, Bldg 3030','US - Virginia Beach, VA - 601 Oceana Blvd, Bldg 3030'));
        offList.add(new SelectOption('US - Virginia Beach, VA - 649 Ocean Lakes Drive','US - Virginia Beach, VA - 649 Ocean Lakes Drive'));
        offList.add(new SelectOption('US - Virginia Beach, VA - 781 B Avenue Bldge 310','US - Virginia Beach, VA - 781 B Avenue Bldge 310'));
        offList.add(new SelectOption('US - Virginia Beach, VA - Strike Fighter Squadron 106 1760 F','US - Virginia Beach, VA - Strike Fighter Squadron 106 1760 F'));
        offList.add(new SelectOption('US - Virginia Beach, VA - URS 5124 Brockie St','US - Virginia Beach, VA - URS 5124 Brockie St'));
        offList.add(new SelectOption('US - Waco, TX - URS 2000 Texas Central Parkway','US - Waco, TX - URS 2000 Texas Central Parkway'));
        offList.add(new SelectOption('US - Waco, TX - URS Waco Parts And Dist Center 2901 Gateway ','US - Waco, TX - URS Waco Parts And Dist Center 2901 Gateway '));
        offList.add(new SelectOption('US - Wahiawa, HI - Hangar 435, Santos Dumont Avenue PO Box 8','US - Wahiawa, HI - Hangar 435, Santos Dumont Avenue PO Box 8'));
        offList.add(new SelectOption('US - Waipahu, HI - 93-051 Waipio Point Access Road','US - Waipahu, HI - 93-051 Waipio Point Access Road'));
        offList.add(new SelectOption('US - Wakefield, MA','US - Wakefield, MA'));
        offList.add(new SelectOption('US - Waller, TX - 19814 GH Circle, PO Box 1178','US - Waller, TX - 19814 GH Circle, PO Box 1178'));
        offList.add(new SelectOption('US - Wallops Island, VA - NASA Wallops Flight Facility Bldg ','US - Wallops Island, VA - NASA Wallops Flight Facility Bldg '));
        offList.add(new SelectOption('US - Wamego, KS - URS 400 Work Tools Dr','US - Wamego, KS - URS 400 Work Tools Dr'));
        offList.add(new SelectOption('US - Warren, MI - URS 30001 Van Dyke','US - Warren, MI - URS 30001 Van Dyke'));
        offList.add(new SelectOption('US - Warren, MI - URS Warren Cet 6275 Nine Mile Road','US - Warren, MI - URS Warren Cet 6275 Nine Mile Road'));
        offList.add(new SelectOption('US - Warrenton, VA - 713 Starting Point Court','US - Warrenton, VA - 713 Starting Point Court'));
        offList.add(new SelectOption('US - Warrenville, IL - 27755 Diehl Rd','US - Warrenville, IL - 27755 Diehl Rd'));
        offList.add(new SelectOption('US - Warrenville, IL - URS 4320 Winfield Road, Suite 300','US - Warrenville, IL - URS 4320 Winfield Road, Suite 300'));
        offList.add(new SelectOption('US - Warrenville, IL - URS Kraft Foods North America-Fm Svcs','US - Warrenville, IL - URS Kraft Foods North America-Fm Svcs'));
        offList.add(new SelectOption('US - Washington - Telecommute','US - Washington - Telecommute'));
        offList.add(new SelectOption('US - Washington DC, DC - 1111 Constitution Avenue NW Room 13','US - Washington DC, DC - 1111 Constitution Avenue NW Room 13'));
        offList.add(new SelectOption('US - Washington DC, DC - 1722 I Street NW','US - Washington DC, DC - 1722 I Street NW'));
        offList.add(new SelectOption('US - Washington DC, DC - 2020 K Street NW','US - Washington DC, DC - 2020 K Street NW'));
        offList.add(new SelectOption('US - Washington DC, DC - 300 M Street SE Suite 400','US - Washington DC, DC - 300 M Street SE Suite 400'));
        offList.add(new SelectOption('US - Washington DC, DC - 3390 V Street NE','US - Washington DC, DC - 3390 V Street NE'));
        offList.add(new SelectOption('US - Washington, DC - 100 F Street NE','US - Washington, DC - 100 F Street NE'));
        offList.add(new SelectOption('US - WASHINGTON, DC - 1000 Independence Avenue, SW','US - WASHINGTON, DC - 1000 Independence Avenue, SW'));
        offList.add(new SelectOption('US - Washington, DC - 111 Mass Avenue NW','US - Washington, DC - 111 Mass Avenue NW'));
        offList.add(new SelectOption('US - Washington, DC - 1150 18th St NW','US - Washington, DC - 1150 18th St NW'));
        offList.add(new SelectOption('US - Washington, DC - 1155 Defense Pentagon','US - Washington, DC - 1155 Defense Pentagon'));
        offList.add(new SelectOption('US - Washington, DC - 1200 1st Street','US - Washington, DC - 1200 1st Street'));
        offList.add(new SelectOption('US - Washington, DC - 1201 New York Avenue, NW, Suite 500','US - Washington, DC - 1201 New York Avenue, NW, Suite 500'));
        offList.add(new SelectOption('US - Washington, DC - 131 M Street NE','US - Washington, DC - 131 M Street NE'));
        offList.add(new SelectOption('US - Washington, DC - 1900 Half Street SW 7th floor','US - Washington, DC - 1900 Half Street SW 7th floor'));
        offList.add(new SelectOption('US - Washington, DC - 20 Massachusetts Ave NW','US - Washington, DC - 20 Massachusetts Ave NW'));
        offList.add(new SelectOption('US - Washington, DC - 2020 K Street NW','US - Washington, DC - 2020 K Street NW'));
        offList.add(new SelectOption('US - Washington, DC - 2020 K Street NW Suite 300','US - Washington, DC - 2020 K Street NW Suite 300'));
        offList.add(new SelectOption('US - Washington, DC - 300 M Street SE','US - Washington, DC - 300 M Street SE'));
        offList.add(new SelectOption('US - Washington, DC - 3000 Headquarters Pentagon','US - Washington, DC - 3000 Headquarters Pentagon'));
        offList.add(new SelectOption('US - Washington, DC - 320 First St NW','US - Washington, DC - 320 First St NW'));
        offList.add(new SelectOption('US - Washington, DC - 3408 Patterson St NW','US - Washington, DC - 3408 Patterson St NW'));
        offList.add(new SelectOption('US - Washington, DC - 400 Maryland Ave SW','US - Washington, DC - 400 Maryland Ave SW'));
        offList.add(new SelectOption('US - Washington, DC - 5000 Overlook Ave SW','US - Washington, DC - 5000 Overlook Ave SW'));
        offList.add(new SelectOption('US - Washington, DC - 600 Maryland Avenue SW','US - Washington, DC - 600 Maryland Avenue SW'));
        offList.add(new SelectOption('US - Washington, DC - 600 Pennsylvania Ave NW','US - Washington, DC - 600 Pennsylvania Ave NW'));
        offList.add(new SelectOption('US - Washington, DC - 614 Sicard St SE Navy Yard Bldg 201','US - Washington, DC - 614 Sicard St SE Navy Yard Bldg 201'));
        offList.add(new SelectOption('US - Washington, DC - 901 D Street SW 10th Floor Suite 1050','US - Washington, DC - 901 D Street SW 10th Floor Suite 1050'));
        offList.add(new SelectOption('US - Washington, DC - OASD(SO/LIC) SO&CT (Rm 5D379) 2500 Def','US - Washington, DC - OASD(SO/LIC) SO&CT (Rm 5D379) 2500 Def'));
        offList.add(new SelectOption('US - Washington, DC - PO Box 17451','US - Washington, DC - PO Box 17451'));
        offList.add(new SelectOption('US - Washington, DC - SSA ITC Bldg 500 E Street','US - Washington, DC - SSA ITC Bldg 500 E Street'));
        offList.add(new SelectOption('US - Washington, DC - URS 2020 K Street Nw Suite 300','US - Washington, DC - URS 2020 K Street Nw Suite 300'));
        offList.add(new SelectOption('US - Washington, DC - Wilbur Wright Bldg FOB10B FAA Natl HDQ','US - Washington, DC - Wilbur Wright Bldg FOB10B FAA Natl HDQ'));
        offList.add(new SelectOption('US - Washington, WV - 8480 Dupont Rd B104 Upstairs Sta 55','US - Washington, WV - 8480 Dupont Rd B104 Upstairs Sta 55'));
        offList.add(new SelectOption('US - Washington, WV - URS 8460 Dupont Road','US - Washington, WV - URS 8460 Dupont Road'));
        offList.add(new SelectOption('US - Waterloo, IA - 501 Sycamore St','US - Waterloo, IA - 501 Sycamore St'));
        offList.add(new SelectOption('US - Waynesboro, GA - URS Vogtle Units 3 & 4 - Westinghouse ','US - Waynesboro, GA - URS Vogtle Units 3 & 4 - Westinghouse '));
        offList.add(new SelectOption('US - West Bethesda, MD - 9500 MacArthur Blvd Naval Surface W','US - West Bethesda, MD - 9500 MacArthur Blvd Naval Surface W'));
        offList.add(new SelectOption('US - West Palm Beach, FL - 2090 Palm Beach Lakes Blvd','US - West Palm Beach, FL - 2090 Palm Beach Lakes Blvd'));
        offList.add(new SelectOption('US - West Palm Beach, FL - 2300 N Jog Road','US - West Palm Beach, FL - 2300 N Jog Road'));
        return offList;
    }

    public List<SelectOption> getOfficeLocation3List() {
        List<SelectOption> offList = new List<SelectOption>();
        offList.add(new SelectOption('US - West Palm Beach, FL - 9300 Belvedere Road','US - West Palm Beach, FL - 9300 Belvedere Road'));
        offList.add(new SelectOption('US - West Plains, MO - URS C/O Drs Sustainment Systems Inc 1','US - West Plains, MO - URS C/O Drs Sustainment Systems Inc 1'));
        offList.add(new SelectOption('US - West Point, NY - Keller ACH Bldg 900 MEDDAC','US - West Point, NY - Keller ACH Bldg 900 MEDDAC'));
        offList.add(new SelectOption('US - West Sacramento, CA - 825 Riverside Parkway','US - West Sacramento, CA - 825 Riverside Parkway'));
        offList.add(new SelectOption('US - West Valley, NY - 10282 Rock Springs Road','US - West Valley, NY - 10282 Rock Springs Road'));
        offList.add(new SelectOption('US - West Virginia - Telecommute','US - West Virginia - Telecommute'));
        offList.add(new SelectOption('US - Westport, CT','US - Westport, CT'));
        offList.add(new SelectOption('US - Wever, IA - URS 180th Street','US - Wever, IA - URS 180th Street'));
        offList.add(new SelectOption('US - Wever, IA - URS 3552 180th Street','US - Wever, IA - URS 3552 180th Street'));
        offList.add(new SelectOption('US - Wever, IA - URS Orascom Iowa Fertilizer Plant 3548 180t','US - Wever, IA - URS Orascom Iowa Fertilizer Plant 3548 180t'));
        offList.add(new SelectOption('US - Whidbey Island, WA - CTTR Building 2593','US - Whidbey Island, WA - CTTR Building 2593'));
        offList.add(new SelectOption('US - White Plains, NY - URS C/O New York Power Authority 123','US - White Plains, NY - URS C/O New York Power Authority 123'));
        offList.add(new SelectOption('US - Whitehall, MT - URS Pipestone Quarry (804) #1 Delmoe La','US - Whitehall, MT - URS Pipestone Quarry (804) #1 Delmoe La'));
        offList.add(new SelectOption('US - Whiteman AFB, MO - 920 12th St, Bldg. 53','US - Whiteman AFB, MO - 920 12th St, Bldg. 53'));
        offList.add(new SelectOption('US - Whiteman AFB, MO - Det 2 53d TMG 850 Arnold Avenue','US - Whiteman AFB, MO - Det 2 53d TMG 850 Arnold Avenue'));
        offList.add(new SelectOption('US - Wichita, KS','US - Wichita, KS'));
        offList.add(new SelectOption('US - Williamsport, PA - 715 Washington Boulevard','US - Williamsport, PA - 715 Washington Boulevard'));
        offList.add(new SelectOption('US - Williston, ND - 5043 Bennett Industrial Drive, PO Box 1','US - Williston, ND - 5043 Bennett Industrial Drive, PO Box 1'));
        offList.add(new SelectOption('US - Wilmington, DE - 1013 Centre Rd','US - Wilmington, DE - 1013 Centre Rd'));
        offList.add(new SelectOption('US - Wilmington, NC - 2221 Gibson Avenue','US - Wilmington, NC - 2221 Gibson Avenue'));
        offList.add(new SelectOption('US - Wilmington, NC - 7101 Cape Harbor Drive Apt O','US - Wilmington, NC - 7101 Cape Harbor Drive Apt O'));
        offList.add(new SelectOption('US - Wilmington, NC - URS Ge Hitachi Nuclear Energy 3901 Cas','US - Wilmington, NC - URS Ge Hitachi Nuclear Energy 3901 Cas'));
        offList.add(new SelectOption('US - Windhoek, Namibia','US - Windhoek, Namibia'));
        offList.add(new SelectOption('US - Winston Salem, NC - URS Catepillar 3950 Temple School R','US - Winston Salem, NC - URS Catepillar 3950 Temple School R'));
        offList.add(new SelectOption('US - Wisconsin - Telecommute','US - Wisconsin - Telecommute'));
        offList.add(new SelectOption('US - Wood River, IL - URS P. O. Box 262','US - Wood River, IL - URS P. O. Box 262'));
        offList.add(new SelectOption('US - Wright Patterson AFB, OH - 2690 Loop Road West','US - Wright Patterson AFB, OH - 2690 Loop Road West'));
        offList.add(new SelectOption('US - Wyoming - Telecommute','US - Wyoming - Telecommute'));
        offList.add(new SelectOption('US - Yakima, WA - 415 North Third Street','US - Yakima, WA - 415 North Third Street'));
        offList.add(new SelectOption('US - Yorktown, VA - 100 Occoquan Turning','US - Yorktown, VA - 100 Occoquan Turning'));
        offList.add(new SelectOption('US - Yuma, AZ - Marine Corps Air Station Yuma, AZ','US - Yuma, AZ - Marine Corps Air Station Yuma, AZ'));
        offList.add(new SelectOption('VE - Caracas, Venezuela - Av Solano Centro Emp Sabana Grande','VE - Caracas, Venezuela - Av Solano Centro Emp Sabana Grande'));
        offList.add(new SelectOption('VN - Ho Chi Minh City - 7/F Saigon Finance Centre','VN - Ho Chi Minh City - 7/F Saigon Finance Centre'));
        offList.add(new SelectOption('VN - Vietnam, - foreign','VN - Vietnam, - foreign'));
        offList.add(new SelectOption('ZA - Bloemfontein, 27 President Steyn Avenue','ZA - Bloemfontein, 27 President Steyn Avenue'));
        offList.add(new SelectOption('ZA - Cape Town, 45 Buitengragt Street','ZA - Cape Town, 45 Buitengragt Street'));
        offList.add(new SelectOption('ZA - Cape Town, Carl Cronje Drive, Bellville','ZA - Cape Town, Carl Cronje Drive, Bellville'));
        offList.add(new SelectOption('ZA - Durban, 2 Maryvale Road, Westville','ZA - Durban, 2 Maryvale Road, Westville'));
        offList.add(new SelectOption('ZA - East London, 35 Tecoma Street, Berea','ZA - East London, 35 Tecoma Street, Berea'));
        offList.add(new SelectOption('ZA - George, 97 Mitchell Street','ZA - George, 97 Mitchell Street'));
        offList.add(new SelectOption('ZA - Johannesburg - 145 West Street','ZA - Johannesburg - 145 West Street'));
        offList.add(new SelectOption('ZA - Pietermaritzburg, 170 Peter Brown Drive','ZA - Pietermaritzburg, 170 Peter Brown Drive'));
        offList.add(new SelectOption('ZA - Polokwane, 118 General Beyers Street','ZA - Polokwane, 118 General Beyers Street'));
        offList.add(new SelectOption('ZA - Port Elizabeth, 2 Fort Street','ZA - Port Elizabeth, 2 Fort Street'));
        offList.add(new SelectOption('ZA - Pretoria, 263A West Avenue, Centurion','ZA - Pretoria, 263A West Avenue, Centurion'));
        offList.add(new SelectOption('ZA - Richards Bay, 68 Dollar Lane','ZA - Richards Bay, 68 Dollar Lane'));
        offList.add(new SelectOption('ZA - Rustenburg, 67 Brink Street','ZA - Rustenburg, 67 Brink Street'));

        return offList;
    }

    public String getBusinessLine() {
        String retVal = '';
        if(mUserConditions.get('businessLine') != null) {
            retVal = (String)mUserConditions.get('businessLine').value;
        }
        return retVal;
    }

    public void setBusinessLine(String busLine) {
        mUserConditions.put('businessLine', new Condition(busLine, ' = ', 'Business_Line__c'));
    }
    public List<SelectOption> getBusinessLineList() {
        List<SelectOption> busLineList = new List<SelectOption>();
        busLineList.add(new SelectOption('','--None--'));
        busLineList.add(new SelectOption('AECOM Corporate','AECOM Corporate'));
        busLineList.add(new SelectOption('Architecture','Architecture'));
        busLineList.add(new SelectOption('Building Engineering','Building Engineering'));
        busLineList.add(new SelectOption('Buildings & Places','Buildings & Places'));
        busLineList.add(new SelectOption('Construction Services','Construction Services'));
        busLineList.add(new SelectOption('Design-Build','Design-Build'));
        busLineList.add(new SelectOption('DP&E','DP&E'));
        busLineList.add(new SelectOption('End Markets','End Markets'));
        busLineList.add(new SelectOption('Energy & Construction','Energy & Construction'));
        busLineList.add(new SelectOption('Environment','Environment'));
        busLineList.add(new SelectOption('Federal Services','Federal Services'));
        busLineList.add(new SelectOption('Geotechnical','Geotechnical'));
        busLineList.add(new SelectOption('Global IT','Global IT'));
        busLineList.add(new SelectOption('GSS','GSS'));
        busLineList.add(new SelectOption('Infrastructure & Environment','Infrastructure & Environment'));
        busLineList.add(new SelectOption('Mining & Metals','Mining & Metals'));
        busLineList.add(new SelectOption('National Government','National Government'));
        busLineList.add(new SelectOption('Oil & Gas','Oil & Gas'));
        busLineList.add(new SelectOption('PM/CM','PM/CM'));
        busLineList.add(new SelectOption('Power & Industrial','Power & Industrial'));
        busLineList.add(new SelectOption('Program, Cost, Consultancy','Program, Cost, Consultancy'));
        busLineList.add(new SelectOption('Support/Cross Services','Support/Cross Services'));
        busLineList.add(new SelectOption('Transportation','Transportation'));
        busLineList.add(new SelectOption('URS Division','URS Division'));
        busLineList.add(new SelectOption('Water','Water'));
        return busLineList;
    }

    public Boolean getActive() {
        return Boolean.valueOf(mUserConditions.get('active').value);
    }

    public void setActive(Boolean value) {
        String operator = ' = ';
        String field = 'IsActive';
        mUserConditions.put('active',new Condition(String.valueOf(value),operator,field));
    }

    public String getName() {
        return (String)this.mObj.get('Name');
    }

    public void setName(String name) {
        this.mObj.put('Name',name);
    }

    public Decimal getGroupSequence() {
        return (Decimal)mObj.get('Group_Sequence__c');
    }
    public void setGroupSequence(Decimal GroupSequence) {
        mObj.put('Group_Sequence__c', GroupSequence);
    }

    public Id getUserId() {
        return (Id)mObj.get('User__c');
    }
    public void setUserId(Id User) {
        mObj.put('User__c', User);
    }

    public rsSearch(rs_Search__c s) {
        super(s);
    }

    public void setResultFields(List<String> resultFields) {
        mResultFields = resultFields;
    }

    public List<String> getResultFields() {
        return mResultFields;
    }

    public String getSearchType() {
        return mSearchType;
    }

    public void setSearchType(String type) {
        mSearchType = type;
        mObj.put('Search_Type__c', type);
    }

    //Sets up conditions lists/map based on the text search and user fields
    //and puts them into the Search object
    public void setConditions(String textSearch) {
        mPRTeamEmpConditions = new List<Condition>();
        textSearch = textSearch+'%';
        if(mSearchType == BASIC_SEARCH) {
            mConditions = new List<Condition>();
            List<Condition> saveConditions = new List<Condition>();
            for(SearchField s : getFieldsForObject('rs_Profile_Part__c',false)) {
                if((rsStringUtil.cleanFieldName(s.getSelectOption().getValue(),'|') != 'License_Registration_Name__c' )
                    && (rsStringUtil.cleanFieldName(s.getSelectOption().getValue(),'|') != 'License_Registration_Country__c')) {
                    mConditions.add(new Condition(textSearch,'LIKE',rsStringUtil.cleanFieldName(s.getSelectOption().getValue(),'|')));
                } else if(rsStringUtil.cleanFieldName(s.getSelectOption().getValue(),'|') == 'License_Registration_Name__c'
                    && !rsStringUtil.isNullOrEmpty(mLicenseReg)) {
                    mConditions.add(new Condition(mLicenseReg,'LIKE',rsStringUtil.cleanFieldName(s.getSelectOption().getValue(),'|')));
                } else if (rsStringUtil.cleanFieldName(s.getSelectOption().getValue(),'|') == 'License_Registration_Country__c'
                    && !rsStringUtil.isNullOrEmpty(mLicenseRegCountry)) {
                    mConditions.add(new Condition(mLicenseRegCountry,'LIKE',rsStringUtil.cleanFieldName(s.getSelectOption().getValue(),'|')));
                }
            }
            for(SearchField s : getFieldsForObject('PR_Team_Employee__c',false)) {
                mPRTeamEmpConditions.add(new Condition(textSearch,'=',rsStringUtil.cleanFieldName(s.getSelectOption().getValue(),'|')));
            }
        } else if(mSearchType == ADVANCED_SEARCH) {
            System.debug('list mConditions size: ' + mConditions.size());
            List<Condition> conditions = new List<Condition>();
            for(Condition cond : mConditions) {
                System.debug('#### cond.value : ' + cond.value + ' cond.field: ' + cond.field + ' cond.operator: ' + cond.operator);
                if(!rsStringUtil.isNullOrEmpty(cond.value) && !rsStringUtil.isNullOrEmpty(cond.operator) &&
                    !rsStringUtil.isNullOrEmpty(cond.field)) {
                    conditions.add(cond);
                }
            }
            setConditions(conditions);
        }
        List<String> selectFields = new List<String>();
        for(SelectOption os : getSelectedFieldOptions()) {
            selectFields.add(os.getValue());
        }
        mObj.put('PR_Team_Employee_Fields__c',JSON.serializePretty(mPRTeamEmpConditions));
        mObj.put('User_Fields__c',JSON.serializePretty(mUserConditions));
        mObj.put('Search_Fields__c',JSON.serializePretty(mConditions));
        mObj.put('Result_Fields__c',JSON.serializePretty(selectFields));
        mObj.put('User__c',UserInfo.getUserId());
        mObj.put('Search_Type__c',mSearchType);
        mObj.put('Filter_Logic__c',mFilter);
    }

    public void setConditions(List<Condition> cond) {
        mConditions = cond;
        if(mConditions != null && mConditions.size() > 0 && mSearchType == BASIC_SEARCH) {
            System.debug('### condition text' + mConditions.get(0).value.replaceAll('%',''));
            mTextSearch = (mConditions.get(0).value.replaceAll('%|"null"',''));
            for(Condition condition : mConditions) {
                System.debug('#### ' + condition.value);
                if(condition.field == 'License_Registration_Name__c' &&  String.isNotBlank(condition.value) && !condition.value.startsWith('%')) {
                    mLicenseReg = condition.value;
                } else if(condition.field == 'License_Registration_Country__c' && !condition.value.startsWith('%') && String.isNotBlank(condition.value)) {
                    mLicenseRegCountry = condition.value;
                }
            }
        } else if(mConditions.size() < 5 && mSearchType == ADVANCED_SEARCH) {
            while(mConditions.size() < 5) {
                mConditions.add(new Condition('','',''));
            }
        }
    }

    public Map<String,Condition> getUserConditions() {
        return mUserConditions;
    }

    public void setUserConditions(Map<String,Condition> cond) {
        mUserConditions = cond;
    }

    public List<Condition> getConditions() {
        return mConditions;
    }

    public List<Condition> getPRTeamEmployeeConditions() {
        return mPRTeamEmpConditions;
    }

    public void setPRTeamEmployeeConditions(List<Condition> cond) {
        mPRTeamEmpConditions = cond;
    }

    public List<SearchField> getSearchFields() {

        List<SearchField> searchFields = new List<SearchField>();
        searchFields.addAll(getFieldsForObject('User',true));
        searchFields.sort();
        return searchFields;
    }

    public List<SelectOption> getAdvancedFieldOptions() {
        if(mAdvancedFieldOptions == null) {
            List<SearchField> searchFields = new List<SearchField>();           // Adding Search fields that are filterable
            searchFields.addAll(getFieldsForObject('PR_Team_Employee__c',false));
            searchFields.addAll(getFieldsForObject('User',false));
            searchFields.addAll(getFieldsForObject('rs_Profile_Part__c',false));
            searchFields.sort();
            List<SelectOption> options = new List<SelectOption>();
            for(SearchField s : searchFields) {
                options.add(s.getSelectOption());
            }
            mAdvancedFieldOptions = options;
        }
        return mAdvancedFieldOptions;
    }

    public List<SelectOption> getResultFieldOptions() {
        if(mResultFieldsOptions == null) {
            List<SelectOption> options = new List<SelectOption>();
            for(SearchField s : getSearchFields()) {
                if( s.FieldName != 'User|Name' &&
                    s.FieldName != 'User|rs_Note_To_User__c' &&
                    s.FieldName != 'User|Title' &&
                    s.FieldName != 'User|Business_Line__c' &&
                    s.FieldName != 'User|Region__c' &&
                    s.FieldName != 'User|Email' &&
                    s.FieldName != 'User|City' &&
                    s.FieldName != 'User|Phone' &&
                    s.FieldName != 'User|Cisco_IP_Phone__c') {
                    options.add(s.getSelectOption());
                } else {
                    if(mSelectedFieldOptions == null) {
                        if(s.FieldName != 'User|Name') setSelectedFieldOptions(new List<SelectOption>{s.getSelectOption()});
                        else setSelectedFieldOptions(new List<SelectOption>{new SelectOption('User|Name',Label.Name)});
                    } else {
                        if(s.FieldName != 'User|Name') mSelectedFieldOptions.add(s.getSelectOption());
                        else mSelectedFieldOptions.add(new SelectOption('User|Name',Label.Name));
                    }
                }
            }
            mResultFieldsOptions = options;
        } else {
            //blau AECR-664, Select Option has a sort that doesn't sort by label
            // will have to turn list into search fields, sort, then turn back into
            // select option
            List<SearchField> sortList = new List<SearchField>();
            for(SelectOption sel : mResultFieldsOptions) {
                String objectName = sel.getValue().substring(0,sel.getValue().indexOf('|'));
                sortList.add(new SearchField(sel.getValue(),sel.getLabel(),objectName));
            }
            sortList.sort();
            mResultFieldsOptions.clear();
            for(SearchField s : sortList) {
                mResultFieldsOptions.add(s.getSelectOption());
            }
        }
        return mResultFieldsOptions;
    }

    public void setResultFieldOptions(List<SelectOption> resOptions) {
        mResultFieldsOptions = resOptions;
    }

    public List<SelectOption> getSelectedFieldOptions() {
        if(mSelectedFieldOptions == null) {
            mSelectedFieldOptions = new List<SelectOption>();
        }
        return mSelectedFieldOptions;
    }

    public List<String> getSelectedFields() {
        if(mSelectedFields == null) {
            mSelectedFields = new List<String>();
        }
        return mSelectedFields;
    }

    public String getTextSearch() {
        if(mTextSearch == null) {
            mTextSearch = '';
        }
        return mTextSearch;
    }

    public String getFilter() {
        return mFilter;
    }

    public void setTextSearch(String search) {
        mTextSearch = search;
    }

    public void setSelectedFields(List<String> selFields) {
        mSelectedFields = selFields;
    }

    public void setSelectedFieldOptions(List<SelectOption> selOptions) {
        mSelectedFieldOptions = selOptions;
    }

    public void setFilter(String filterString) {
        mFilter = filterString;
    }

    private void sortSelectedFieldsSpecific() {
        if(mSelectedFieldOptions.size() == 9) {
            SelectOption nameOp = new SelectOption('','');
            SelectOption titleOp = new SelectOption('','');
            SelectOption businessLineOp = new SelectOption('','');
            SelectOption regionOp = new SelectOption('','');
            SelectOption phoneOp = new SelectOption('','');
            SelectOption extOp = new SelectOption('','');
            SelectOption emailOp = new SelectOption('','');
            SelectOption cityOp = new SelectOption('','');
            SelectOption noteUser = new SelectOption('','');

            for( SelectOption op : mSelectedFieldOptions ) {
                if(op.getValue() == 'User|Name') {
                    nameOp = op;
                } else if (op.getValue() == 'User|rs_Note_To_User__c') {
                    noteUser = op;
                } else if ( op.getValue() == 'User|Title' ) {
                    titleOp = op;
                } else if ( op.getValue() == 'User|Business_Line__c' ) {
                    businessLineOp = op;
                } else if ( op.getValue() == 'User|Region__c' ) {
                    regionOp = op;
                } else if ( op.getValue() == 'User|Email' ) {
                    emailOp = op;
                } else if ( op.getValue() == 'User|City' ) {
                    cityOp = op;
                } else if ( op.getValue() == 'User|Phone' ) {
                    phoneOp = op;
                } else if ( op.getValue() == 'User|Cisco_IP_Phone__c' ) {
                    extOp = op;
                }
            }
            mSelectedFieldOptions.set(0, nameOp);
            mSelectedFieldOptions.set(1, titleOp);
            mSelectedFieldOptions.set(2, businessLineOp);
            mSelectedFieldOptions.set(3, regionOp);
            mSelectedFieldOptions.set(4, phoneOp);
            mSelectedFieldOptions.set(5, extOp);
            mSelectedFieldOptions.set(6, emailOp);
            mSelectedFieldOptions.set(7, cityOp);
            mSelectedFieldOptions.set(8, noteUser);
        }
    }

    private Map<String,Condition> setUpUserConditionMap() {
        Map<String, Condition> userMap = new Map<String, Condition>();
        userMap.put('lastName',new Condition('%%','=','LastName'));
        userMap.put('firstName',new Condition('%%','=','FirstName'));
        userMap.put('active',new Condition('false','=','IsActive'));
        userMap.put('geography',new Condition('','=','Geography__c'));
        userMap.put('officeLocation',new Condition('','=','Office__c'));
        userMap.put('businessLine',new Condition('','=','Business_Line__c'));
        userMap.put('country', new Condition('','=','Country'));
        return userMap;
    }

    private List<SearchField> getFieldsForObject(String objectName, Boolean getNonFilterable) {
        List<SearchField> searchFields = new List<SearchField>();

        SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> objectFields
            = objToken.getDescribe().fields.getMap();

        for(String key : objectFields.keySet()) {
            Schema.DescribeFieldResult f = objectFields.get(key).getDescribe();
            if(f.isAccessible() && isSearchable(f) && getNonFilterable && !IGNORED_FIELDS.contains(f.getName())) {
                searchFields.add(
                    new SearchField(objectName + '|' + f.getName(),f.getLabel(),objectName)
                );
            } else if(f.isAccessible() && isSearchable(f) && !getNonFilterable && f.isFilterable() && !IGNORED_FIELDS.contains(f.getName())) {
                searchFields.add(
                    new SearchField(objectName + '|' + f.getName(),f.getLabel(),objectName)
                );
            }
        }

        return searchFields;
    }

    private Boolean isSearchable(Schema.DescribeFieldResult f) {

        //TODO - this probably needs to be a hardcoded set of API names or something
        //Since we can't do it by data type
        Schema.DisplayType t = f.getType();
        return t == Schema.DisplayType.Email
        || t == Schema.DisplayType.TextArea
        || t == Schema.DisplayType.Picklist
        || t == Schema.DisplayType.String
        || t == Schema.DisplayType.Phone
        || FORCE_SEARCHABLE_FIELDS.contains(f.getName());

    }

    global class SearchField implements Comparable {

        public String FieldName {get; set;}
        public String FieldLabel {get; set;}
        public String FieldObject {get; set;}

        public SearchField(String fieldName, String fieldLabel, String fieldObject) {
            this.FieldName = fieldName;
            this.FieldLabel = fieldLabel;
            this.FieldObject = fieldObject;
        }

        public SelectOption getSelectOption() {
            return new SelectOption(this.FieldName, this.FieldLabel);
        }

        global Integer compareTo(Object compareTo) {

            SearchField compareToField = (SearchField)compareTo;
            return this.FieldLabel.compareTo(compareToField.FieldLabel);
        }


    }

    public class Condition {
        public String value {get; set;}
        public String operator {get; set;}
        public String field {get; set;}

        public Condition(String value, String operator, String field) {
            this.value = value;
            this.operator = operator;
            this.field = field;
        }

        public List<SelectOption> getOperators() {
            List<SelectOption> operators = new List<SelectOption>();
            if(!rsStringUtil.isNullOrEmpty(field) && field.contains('|')) {
                String objectName = field.substring(0,field.indexOf('|'));
                String fieldName = rsStringUtil.cleanFieldName(field, '|');
                Schema.DisplayType dispType = getDisplayType(objectName,fieldName);
                if(dispType == Schema.DisplayType.TextArea) {
                    operators.add(new SelectOption('c','contains'));
                    operators.add(new SelectOption('dnc','does not contain'));
                }
                else if (dispType == Schema.DisplayType.Date || dispType == Schema.DisplayType.DateTime) {
                    operators.add(new SelectOption('e','equals'));
                    operators.add(new SelectOption('ne','not equal to'));
                    operators.add(new SelectOption('lt','less than'));
                    operators.add(new SelectOption('gt','greater than'));
                    operators.add(new SelectOption('loe','less or equal'));
                    operators.add(new SelectOption('goe','greater or equal'));
                }
                else if (dispType == Schema.DisplayType.String || dispType == Schema.DisplayType.Picklist
                    || dispType == Schema.DisplayType.Email || dispType == Schema.DisplayType.Phone) {
                    operators.add(new SelectOption('e','equals'));
                    operators.add(new SelectOption('ne','not equal to'));
                    operators.add(new SelectOption('lt','less than'));
                    operators.add(new SelectOption('gt','greater than'));
                    operators.add(new SelectOption('loe','less or equal'));
                    operators.add(new SelectOption('goe','greater or equal'));
                    operators.add(new SelectOption('c','contains'));
                    operators.add(new SelectOption('dnc','does not contain'));
                    operators.add(new SelectOption('sw','starts with'));
                }
            } else {
                operators.add(new SelectOption('e','equals'));
                operators.add(new SelectOption('ne','not equal to'));
                operators.add(new SelectOption('c','contains'));
                operators.add(new SelectOption('sw','starts with'));
                operators.add(new SelectOption('dnc','does not contain'));
                operators.add(new SelectOption('lt','less than'));
                operators.add(new SelectOption('gt','greater than'));
                operators.add(new SelectOption('loe','less or equal'));
                operators.add(new SelectOption('goe','greater or equal'));
                operators.add(new SelectOption('i','includes'));
                operators.add(new SelectOption('x','excludes'));
                operators.add(new SelectOption('w','within'));
            }
            return operators;
        }

        public Schema.DisplayType getDisplayType(String objectName, String fieldName) {
            Schema.DisplayType dispType = null;
            if(objectName == 'User') {
                dispType = rsSearch.USER_FIELDS.get(fieldName).getDescribe().getType();
            } else if(objectName == 'rs_Profile_Part__c') {
                dispType = rsSearch.PROFILE_PART_FIELDS.get(fieldName).getDescribe().getType();
            } else if(objectName == 'PR_Team_Employee__c') {
                dispType = rsSearch.PR_TEAM_EMPLOYEE_FIELDS.get(fieldName).getDescribe().getType();
            } else {
                SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
                Map<String, Schema.SObjectField> objectFields = objToken.getDescribe().fields.getMap();
                dispType = objectFields.get(fieldName).getDescribe().getType();
            }
            return dispType;
        }
    }

    public override Integer compareTo(Object searchObj) {
        rsSearch compareObj = (rsSearch)searchObj;

        if(compareObj.getGroupSequence() == null) {
            return -1;
        } else if(getGroupSequence() == null) {
            return 1;
        } else {
            return Integer.valueOf(getGroupSequence() - compareObj.getGroupSequence());
        }
    }

    public class Finder extends rsFinder {

        public Finder(String sObjectName) {
            super(sObjectName);
        }

        public override rsModel byId(Id recId) {
            return new rsSearch((rs_Search__c)byId(recId).getObj());
        }

        public List<rsSearch> getSearchesByUser(String userId) {
            List<rsSearch> searches = new List<rsSearch>();
            List<rs_Search__c> rsSearches = (List<rs_Search__c>)Database.query(getSelect() + 'where User__c =: userId AND (Search_Type__c =: BASIC_SEARCH OR Search_Type__c =: ADVANCED_SEARCH) ORDER BY Name ASC');
            for(rs_Search__c s : rsSearches) {
                searches.add(new rsSearch(s));
            }
            return searches;
        }

        public List<rsSearch> getProjectGroupsByUser(String userId) {
            List<rsSearch> searches = new List<rsSearch>();
            String query = 'where User__c =: userId AND Search_Type__c =:PROJECT_GROUP';
            for(rs_Search__c projGroup : (List<rs_Search__c>)Database.query(getSelect() + query)) {
                searches.add(new rsSearch(projGroup));
            }
            return searches;
        }

    }

    public static final String BASIC_SEARCH = 'Basic';
    public static final String ADVANCED_SEARCH = 'Advanced';
    public static final String PROJECT_GROUP = 'Project Group';
    public static final Map<String, Schema.SObjectField> USER_FIELDS = Schema.getGlobalDescribe().get('User').getDescribe().fields.getMap();
    public static final Map<String, Schema.SObjectField> PROFILE_PART_FIELDS = Schema.getGlobalDescribe().get('rs_Profile_Part__c').getDescribe().fields.getMap();
    public static final Map<String, Schema.SObjectField> PR_TEAM_EMPLOYEE_FIELDS = Schema.getGlobalDescribe().get('PR_Team_Employee__c').getDescribe().fields.getMap();

    // Fields which would not ordinarily be searchable (due to datatype, etc) but we want to explicity override/set as searchable
    private static final Set<String> FORCE_SEARCHABLE_FIELDS = new Set<String> {
        'Last_User_Profile_Update__c',
        'Last_CM_Profile_Update__c'
    };

    private static final Set<String> IGNORED_FIELDS = new Set<String>{  'ChkUniqueEmp__c',
                                                                        'Client__c',
                                                                        'Client_Name__c',
                                                                        'Client_Name_Editable__c',
                                                                        'CurrencyIsoCode',
                                                                        'Emp_Name__c',
                                                                        'Initial_Locale__c',
                                                                        'Location_Country_Editable__c',
                                                                        'Location_State_Prov_Emirate_Editable__c',
                                                                        'Oracle_Project_Number__c',
                                                                        'Project_Group_Editable__c',
                                                                        'Project_Number__c',
                                                                        'ProjectSort__c',
                                                                        'PRStatusEmployee__c',
                                                                        'Resume_Link__c',
                                                                        'Status__c',
                                                                        'Attachment_Id__c',
                                                                        'CurrencyIsoCode',
                                                                        'Alias',
                                                                        'Allocation_Subcategory__c',
                                                                        'Assignment_Status__c',
                                                                        'Citizenship__c',
                                                                        'Comment_on_User__c',
                                                                        'CommunityNickname',
                                                                        'CompanyName',
                                                                        'CurrencyIsoCode',
                                                                        'DefaultCurrencyIsoCode',
                                                                        'DefaultGroupNotificationFrequency',
                                                                        'DigestFrequency',
                                                                        'Division',
                                                                        'EmailEncodingKey',
                                                                        'Employee_Category__c',
                                                                        'FederationIdentifier',
                                                                        'Gender__c',
                                                                        'Geography_Allocation__c',
                                                                        'Global_Position_Title__c',
                                                                        'IDReport__c',
                                                                        'International_Assignment_Status__c',
                                                                        'Job_Family_Meaning__c',
                                                                        'LanguageLocaleKey',
                                                                        'LocaleSidKey',
                                                                        'Location_City_Editable__c',
                                                                        'Manager_Email__c',
                                                                        'Manager_Name__c',
                                                                        'ManagerID__c',
                                                                        'Middle_Names__c',
                                                                        'Names_Suffix__c',
                                                                        'Nationality__c',
                                                                        'PortalRole',
                                                                        'PostalCode',
                                                                        'Project_Name_Editable__c',
                                                                        'Project_Number_Editable__c',
                                                                        'Religion__c',
                                                                        'SenderEmail',
                                                                        'SenderName',
                                                                        'Service_Line__c',
                                                                        'Signature',
                                                                        'Status__c',
                                                                        'StayInTouchNote',
                                                                        'StayInTouchSignature',
                                                                        'StayInTouchSubject',
                                                                        'Sub_Business_Line__c',
                                                                        'TimeZoneSidKey',
                                                                        'TrackingID__c',
                                                                        'User_Name__c',
                                                                        'Username',
                                                                        'UserType',
                                                                        'Business_Group__c',
                                                                        'Operating_Group__c',
                                                                        'Skill__c',
                                                                        'Skill_Area__c',
                                                                        'Skill_Level__c',
                                                                        'rs_Miscellaneous_Notes__c'
                                                                        };
}