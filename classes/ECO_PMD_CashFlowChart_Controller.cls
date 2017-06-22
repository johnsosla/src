global class ECO_PMD_CashFlowChart_Controller {

     public ECO_PMD_CashFlowChart_Controller(){}

    
    @RemoteAction
    global static CashFlowDetails ProjectSnapshot(String projectNum)
    {
        
        Id projectId = projectNum;

        CashFlowDetails cashflowdetails = new CashFlowDetails();
        
        List<ProjectSnapshot__c> cashflowdata  =  [SELECT 
                    id , SnapshotFiscalMonth__c, SnapshotDate__c, ARTotal__c, ReceiptsITD__c, CashFlowITD__c, 
                    CashFlowITDPrevME__c, CurrencyIsoCode, CreatedDate
                    FROM 
                        ProjectSnapshot__c 
                    WHERE
                        SnapshotType__c ='Auto' AND Project__c = :projectId
                    order by SnapshotFiscalMonth__c asc];

        Integer listsize = cashflowdata.size();    

        if (listsize > 0)
        {            
            cashflowdetails.cashflowdata = cashflowdata;
            cashflowdetails.ARITD = ECO_PMD_Helpers.validDecimal(cashflowdata[listsize-1].ARTotal__c);
            cashflowdetails.receiptsITD = ECO_PMD_Helpers.validDecimal(cashflowdata[listsize-1].ReceiptsITD__c);
            cashflowdetails.cashFlowITD = ECO_PMD_Helpers.validDecimal(cashflowdata[listsize-1].CashFlowITD__c);
            cashflowdetails.currencyCode = cashflowdata[listsize-1].CurrencyIsoCode; 
        }
        else 
        {
            cashflowdetails.nodata = true;

        }

        return cashflowdetails;
    }


    global class CashFlowDetails
    {
        public CashFlowDetails()
        {
            error = '';
            nodata = false;
            ARITD = 0;
            receiptsITD = 0;
            cashFlowITD = 0;
            currencyCode = '';
            cashflowdata = null;
        }

        public String error;
        public Boolean nodata;
        public string currencyCode;
        public Decimal  ARITD;
        public Decimal  receiptsITD;
        public Decimal  cashFlowITD;
        

        public List<ProjectSnapshot__c> cashflowdata;



    }
}