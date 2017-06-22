global with sharing class ECO_PMD_ChangeOrder_Controller {
  public ECO_PMD_ChangeOrder_Controller() {}

  @RemoteAction
    global static ChangeOrderDetails getChangeOrderDetails(String projectNum)
    {
        Id projectId = projectNum;

        ChangeOrderDetails codetails = new ChangeOrderDetails();
        
        try{
          ECO_DTO_BudgetHeaderWrapper budgets = new ECO_DTO_BudgetHeaderWrapper(projectNum);
          Integer countDraft     = budgets.calculateRecordsWithStatus(ECO_DTO_BudgetHeader.STATUS_ESTIMATE, '', null);
          Integer countApproved  = budgets.calculateRecordsWithStatus(ECO_DTO_BudgetHeader.STATUS_APPROVED, '', null);
          Integer countSubmitted = budgets.calculateRecordsWithStatus('',ECO_DTO_BudgetHeader.STATUS_SUBMITTED_APPROVAL, null);
          // Integer countNotAppvd  = budgets.calculateRecordsWithStatus(ECO_DTO_BudgetHeader.STATUS_APPROVED, '', true);
          
          Decimal costOriginal   = budgets.calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED,'TotalCost__c', '', true);
          Decimal costApproved   = budgets.calculateTotal(ECO_DTO_BudgetHeader.STATUS_APPROVED,'TotalCost__c', '', false);
          Decimal costSubmitted  = budgets.calculateTotal('','TotalCost__c',ECO_DTO_BudgetHeader.STATUS_SUBMITTED_APPROVAL, null);

          codetails.draftCount = countDraft;
          codetails.submitedCount = countSubmitted;
          codetails.approvedCount = countApproved;
          codetails.notApprovedCount = -1; // TODO __ HOW TO IDENTIFY REJECTED?

          List<ChangeOrderData> codata = new List<ChangeOrderData>();
          codata.add(new ChangeOrderData('Original', costOriginal));
          codata.add(new ChangeOrderData('Approved', costApproved));
          codata.add(new ChangeOrderData('Submitted', costSubmitted));

          codetails.codata = codata;
         
        }
        catch (Exception ex){

            codetails.error = ex.getMessage() + ' ' + ex.getLineNumber();
            codetails.nodata = true;
        }

        return codetails;
    }

    global class ChangeOrderData
    {
      public ChangeOrderData(string lname , decimal lvalue )
      {
        name = lname;
        value = lvalue;
      }

      public ChangeOrderData(string lname , string lsummary )
      {
        name = lname;
        summary = lsummary;
      }

      public String name;
      public decimal value;
      public String summary;
    }

    global class ChangeOrderDetails
    {
        public ChangeOrderDetails()
        {
          
            error = '';
            nodata = false;

            draftCount = 0;
            submitedCount = 0;
            approvedCount = 0;
            notApprovedCount = 0;

            codata = null;

        }

        public String error;
        public Boolean nodata;

        public Integer  draftCount;
        public Integer  submitedCount;
        public Integer  approvedCount;
        public Integer  notApprovedCount;

        public List<ChangeOrderData> codata;
    }
}