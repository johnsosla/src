public class ECO_Service_Agreement {
    
    public static Integer getNextProjectAgreementCount(String projectId)
    {
        AggregateResult[] results = [select MAX(ProjectAgreementRecordCount__c) maxCount from Agreement__c where Project__c = :projectId];
        
        if(results[0].get('MaxCount') != null)
        {
            Integer maxCountValue = Integer.ValueOf((Decimal)results[0].get('MaxCount'));
            return maxCountValue + 1;
        }
        
        return 1;
    }
    
    public static String getProjectManagerFromProjectTeam(String projectId)
    {
        ProjectRole__c role = [select Id from ProjectRole__c where Name = 'Project Manager'];
        list<ProjectTeamMember__c> projectTeamMembers = [select Id, Role__c, Active__c from ProjectTeamMember__c 
                                                         where Project__c = :projectId and Active__c = true 
                                                            and ProjectRole__c = :role.Id];    
                                                                     
        if(projectTeamMembers.size() > 0)
            return projectTeamMembers[0].Id;
                
        return null;
    }
    
    public static String getSiteAccountIdFromProjPrimBillAcct(String primaryBillingClientId)
    {
        list<Site__c> sites = [select Id, Account__c from Site__c where Id = :primaryBillingClientId];
        if(sites.size() > 0)
            return sites[0].Account__c;
        
        return null;
    }
    
    public static String getPaymentTermIdFromString(String paymentTerm)
    {
        list<ECO_PaymentTermIdMapping__c> mapping = [select Name, TermId__c from ECO_PaymentTermIdMapping__c where name = :paymentTerm];
        if(mapping.size() > 0)
        {
            return mapping[0].TermId__c;
        }
        else
            return '0'; 
    }
    
    public static pse__Proj__c getProjectFromId(String projectId)
    {
        if(projectId != null)
            return [select Id, Name, ProjectNumber__c, PrimaryBillingClient__c, OUID__c, OracleProjectnumber__c, EstimatedContractValue__c, 
                    EcoSystemReferenceNumber__c, pse__Project_Manager__c, ProjectCurrencyCode__c, pse__Stage__c, EnableTopTaskCustomerFlag__c
                    from pse__Proj__c where Id = :projectId limit 1]; 
        return null;           
    }
    
    public static pse__Proj__c getProjectFromProjectAgreement(String agreementId)
    {
        if(agreementId != null)
        {
        	list<ProjectAgreement__c> projectAgreements = [select Id, Project__c, Agreement__c from ProjectAgreement__c where Agreement__c = :agreementId];
            if(projectAgreements.size() > 0)
            {
            	return getProjectFromId(projectAgreements[0].Project__c);
            }
        }    	
        return null;           
    }    
    
    public static Agreement__c getAgreementFromId(String agreementId)
    {
        return [select Id, Name, Project__r.Name, MSAReference__c, ProjectTeamMember__c,ParentAgreement__c, OracleAgreementID__c, 
                Project__r.OracleProjectnumber__c, PaymentTerms__c,
                AgreementStatus__c, Project__r.EcoSystemReferenceNumber__c, AgreementExecutedBy__c,  Account__c, ExecutionDate__c, 
                InvoicingClient__c,FeeType__c,ContractTitle__c, project__r.TotalApprovedCost__c, project__r.CostComplete__c, 
                //TermID__c, 
                ClientContractReferenceNo__c, FundingCurrencyCode__c, ScopePackage__c, Amount__c, ScopeOfServices__c,
                AgreementAmountEstimated__c, AgreementType__c, TotalFundingAmount__c, CreatedDate, AgreementFundingVariance__c,
                StartDate__c, VarianceReason__c, ExpirationDate__c, ProfIndemnityLiabilityAmt__c, PublicGeneralLiabilityAmt__c,
                USFederalGovernmentProject__c, RecordTypeId, VendorName__c, BacktoBackwithPrime__c, Total_Invoiced__c, TotalPaid__c,
                ContractAttachment__c, ProgramPlanAttachment__c, GuidanceAttachment__c, BusinessDevelopmentAttachment__c,
                MeetingMinutesAttachment__c, AgreementNumber__c, OrderingPeriod__c, ContractingAgency__c,
                TotalContractValue__c, ScopePackage__r.Scope_Details__c, RecordType.Name, OrderingPeriodStart__c, OrderingPeriodEnd__c, 
                IntercompanySubconsultant__c, AgreementOwner__c, RecordType.DeveloperName,
                CommericialTerms__c,CommericialTermsOther__c, CommericialTermsDescription__c, TeamLeaderName__c, TeamLeaderTitle__c,
                Intercompany_Project__c, SpecialConditions__c, MSAReference__r.OrderingPeriodStart__c, MSAReference__r.OrderingPeriodEnd__c,
                Project__c, ChangeManagerApprovedForSynch__c, ChangeManagerIsChanged__c, ActionCode__c, Description__c,
                RevenueLimitFlag__c, InvoiceLimitFlag__c, project__r.GoProbability__c, project__r.GetProbability__c,
                TotalTaskOrdersValue__c, ISMSA__c, InterimApprovalType__c, InterimApprovalDate__c,
                InterimApprovalExpiryDate__c, InterimApprovalComments__c, TotalApprovedRevenueLimit__c,
                InterimApprovalRevenueFeeLimit__c, InterimApprovalCostLimit__c, AgreementVariance__c, UnallocatedFunding__c,
                JointVenturePartner__c, VendorSite__c, VendorSite__r.AccountName__c, AgreementExecutedBy2__c, ChangeManagerIsNew__c,
                PotentialPerformanceBonus__c, FinancialComments__c, SegApprovalStatus__c, OracleSynchAgreementType__c, ContractTypeComments__c, Agreement_With__c, RelatedProjectCount__c
                from Agreement__c where Id = :agreementId]; 
    }
    
    public static List<Agreement__c> getAgreementsForProject(String projectId)
    {
        return [select Id, Name, Project__r.Name, MSAReference__c, ProjectTeamMember__c,ParentAgreement__c, OracleAgreementID__c, 
                Project__r.OracleProjectnumber__c, PaymentTerms__c,
                AgreementStatus__c, Project__r.EcoSystemReferenceNumber__c, AgreementExecutedBy__c,  Account__c, ExecutionDate__c, 
                InvoicingClient__c,FeeType__c,ContractTitle__c, project__r.TotalApprovedCost__c, project__r.CostComplete__c, 
                //TermID__c, 
                ClientContractReferenceNo__c, FundingCurrencyCode__c, ScopePackage__c, Amount__c, ScopeOfServices__c,
                AgreementAmountEstimated__c, AgreementType__c, TotalFundingAmount__c, CreatedDate, AgreementFundingVariance__c,
                StartDate__c, VarianceReason__c, ExpirationDate__c, ProfIndemnityLiabilityAmt__c, PublicGeneralLiabilityAmt__c,
                USFederalGovernmentProject__c, RecordTypeId, VendorName__c, BacktoBackwithPrime__c, Total_Invoiced__c, TotalPaid__c,
                ContractAttachment__c, ProgramPlanAttachment__c, GuidanceAttachment__c, BusinessDevelopmentAttachment__c,
                MeetingMinutesAttachment__c, AgreementNumber__c, OrderingPeriod__c, ContractingAgency__c,
                TotalContractValue__c, ScopePackage__r.Scope_Details__c, RecordType.Name, OrderingPeriodStart__c, OrderingPeriodEnd__c, 
                IntercompanySubconsultant__c, AgreementOwner__c, RecordType.DeveloperName,
                CommericialTerms__c,CommericialTermsOther__c, CommericialTermsDescription__c, TeamLeaderName__c, TeamLeaderTitle__c,
                Intercompany_Project__c, SpecialConditions__c, MSAReference__r.OrderingPeriodStart__c, MSAReference__r.OrderingPeriodEnd__c,
                Project__c, ChangeManagerApprovedForSynch__c, ChangeManagerIsChanged__c, ActionCode__c, Description__c,
                RevenueLimitFlag__c, InvoiceLimitFlag__c, project__r.GoProbability__c, project__r.GetProbability__c,
                TotalTaskOrdersValue__c, ISMSA__c, InterimApprovalType__c, InterimApprovalDate__c,
                InterimApprovalExpiryDate__c, InterimApprovalComments__c, TotalApprovedRevenueLimit__c,
                InterimApprovalRevenueFeeLimit__c, InterimApprovalCostLimit__c, AgreementVariance__c, UnallocatedFunding__c,
                JointVenturePartner__c, VendorSite__c, VendorSite__r.AccountName__c, ChangeManagerIsNew__c,
                PotentialPerformanceBonus__c, FinancialComments__c, SegApprovalStatus__c
                from Agreement__c where Id in (select Agreement__c from ProjectAgreement__c where Project__c = :projectId)]; 
    }
    
    public static List<Agreement__c> getPrimeAgreementsForProject(String projectId)
    {
        return [select Id, Name, Project__r.Name, MSAReference__c, ProjectTeamMember__c,ParentAgreement__c, OracleAgreementID__c, 
                Project__r.OracleProjectnumber__c, PaymentTerms__c,
                AgreementStatus__c, Project__r.EcoSystemReferenceNumber__c, AgreementExecutedBy__c,  Account__c, ExecutionDate__c, 
                InvoicingClient__c,FeeType__c,ContractTitle__c, project__r.TotalApprovedCost__c, project__r.CostComplete__c, 
                //TermID__c, 
                ClientContractReferenceNo__c, FundingCurrencyCode__c, ScopePackage__c, Amount__c, ScopeOfServices__c,
                AgreementAmountEstimated__c, AgreementType__c, TotalFundingAmount__c, CreatedDate, AgreementFundingVariance__c,
                StartDate__c, VarianceReason__c, ExpirationDate__c, ProfIndemnityLiabilityAmt__c, PublicGeneralLiabilityAmt__c,
                USFederalGovernmentProject__c, RecordTypeId, VendorName__c, BacktoBackwithPrime__c, Total_Invoiced__c, TotalPaid__c,
                ContractAttachment__c, ProgramPlanAttachment__c, GuidanceAttachment__c, BusinessDevelopmentAttachment__c,
                MeetingMinutesAttachment__c, AgreementNumber__c, OrderingPeriod__c, ContractingAgency__c,
                TotalContractValue__c, ScopePackage__r.Scope_Details__c, RecordType.Name, OrderingPeriodStart__c, OrderingPeriodEnd__c, 
                IntercompanySubconsultant__c, AgreementOwner__c, RecordType.DeveloperName,
                CommericialTerms__c,CommericialTermsOther__c, CommericialTermsDescription__c, TeamLeaderName__c, TeamLeaderTitle__c,
                Intercompany_Project__c, SpecialConditions__c, MSAReference__r.OrderingPeriodStart__c, MSAReference__r.OrderingPeriodEnd__c,
                Project__c, ChangeManagerApprovedForSynch__c, ChangeManagerIsChanged__c, ActionCode__c, Description__c,
                RevenueLimitFlag__c, InvoiceLimitFlag__c, project__r.GoProbability__c, project__r.GetProbability__c,
                TotalTaskOrdersValue__c, ISMSA__c, InterimApprovalType__c, InterimApprovalDate__c,
                InterimApprovalExpiryDate__c, InterimApprovalComments__c, TotalApprovedRevenueLimit__c,
                InterimApprovalRevenueFeeLimit__c, InterimApprovalCostLimit__c, AgreementVariance__c, UnallocatedFunding__c,
                JointVenturePartner__c, VendorSite__c, VendorSite__r.AccountName__c, ChangeManagerIsNew__c, PotentialPerformanceBonus__c, FinancialComments__c,
                SegApprovalStatus__c
                from Agreement__c 
                where Id in (select Agreement__c from ProjectAgreement__c where Project__c = :projectId)
                and RecordType.DeveloperName in ('Prime', 'PrimeTaskOrder', 'PrimeMSA')];
    }

}