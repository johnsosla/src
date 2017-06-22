global class ECO_PMD_WorkingCapitalChart_Controller {

     public ECO_PMD_WorkingCapitalChart_Controller(){}

    
    @RemoteAction
    global static WorkingCapitalDetails ProjectSnapshot(String projectNum)
    {
        
        Id projectId = projectNum;

        WorkingCapitalDetails workingCapitalDetails = new WorkingCapitalDetails();
        
        List<ProjectSnapshot__c> workingCapitalData =  [SELECT 
                                                    ARTotal__c, UnbilledTotal__c, DSO__c,ProjectStartDate__c, ProjectEndDate__c, 
                                                    SnapshotFiscalMonth__c, SnapshotDate__c, SnapshotType__c, CurrencyIsoCode, CreatedDate
                                                FROM 
                                                    ProjectSnapshot__c 
                                                WHERE
                                                    Project__c = :projectId AND SnapshotType__c = 'Auto'
                                                order by SnapshotFiscalMonth__c asc];

    Integer listsize = workingCapitalData.size();

        if (listsize > 0)
        {
            //validNumber v = new validNumber();
            workingCapitalDetails.workingCapitalData = workingCapitalData;
            workingCapitalDetails.ttlARBilled = ECO_PMD_Helpers.validDecimal(workingCapitalData[listsize-1].ARTotal__c); 
            workingCapitalDetails.ttlUnbilled = ECO_PMD_Helpers.validDecimal(workingCapitalData[listsize-1].UnbilledTotal__c); 
            workingCapitalDetails.ttlDays = ECO_PMD_Helpers.validDecimal(workingCapitalData[listsize-1].DSO__c); 
            workingCapitalDetails.currencyCode = workingCapitalData[listsize-1].CurrencyIsoCode; 

        }                                
 
        

        return workingCapitalDetails;
    }

    //public class validNumber {
    //    Decimal result;
    //    public Decimal retVal(Decimal i){
    //        result = i;
    //    if(i == null){
    //        result = 0;
    //    }
        
    //    return result;
    //    }
    //}

     global class WorkingCapitalDetails
    {
        public WorkingCapitalDetails()
        {
            error='';
            ttlARBilled = 0;
            ttlUnbilled = 0;
            ttlDays = 0;

            workingCapitalData = null;
        }

        public String error;
        public Boolean nodata;
        public Decimal ttlARBilled;
        public Decimal ttlUnbilled;
        public Decimal ttlDays;
        public String currencyCode;
        public List<ProjectSnapshot__c> workingCapitalData;
    }
}