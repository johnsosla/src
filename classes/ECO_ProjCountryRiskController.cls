public class ECO_ProjCountryRiskController {
    public id objId { get; set; }
    public List<ProjectCountry_Risk__c> lstProjectCountryRisk;
    public string CountryName {get;set;}
    public decimal SafetyRating {get;set;}

    public ECO_ProjCountryRiskController() {
    }

    public string getQuoteCountryName(){ 
        setData();
        return CountryName; 
    }

    public string getQuoteSafetyRating(){ 
        setData();
        //return SafetyRating;
        return String.valueOf(SafetyRating);
    }   

    public void setData()
    {
        if(lstProjectCountryRisk == null || lstProjectCountryRisk.size()==0)
        {
            if (objId!=null)
            {
                lstProjectCountryRisk= [Select CountryName__c, Safety_Rating__c from ProjectCountry_Risk__c WHERE Project__c = :objId ORDER BY createddate desc];
                
                if (lstProjectCountryRisk.size()>0)
                {
                    if (!String.IsBlank(lstProjectCountryRisk[0].CountryName__c))
                        CountryName = lstProjectCountryRisk[0].CountryName__c;
                    else
                        CountryName = null;
                    
                    if (lstProjectCountryRisk[0].Safety_Rating__c != null)
                        SafetyRating = lstProjectCountryRisk[0].Safety_Rating__c;
                    else
                        SafetyRating = null;
                }
                else
                {
                    CountryName = null;
                    SafetyRating = null;
                }
            }
            else
            {
                CountryName = null;
                SafetyRating = null;
            }
        }       
    }    
}