public class ECO_ePM_ConsolidatedController {
    public string EndpointUrl {get; set;}
    
    public ECO_ePM_ConsolidatedController()
    {
        ECO_IntegrationEndpoints__c cs;
        Organization currOrg = [Select IsSandbox from Organization limit 1];
        if(!currOrg.IsSandbox)
        {
            cs = ECO_IntegrationEndpoints__c.getInstance('ConsolidatedInbox_PROD');
        } else {
            cs = ECO_IntegrationEndpoints__c.getInstance('ConsolidatedInbox_Sandbox');
        }
        
        if(cs != null)
        	EndpointUrl = cs.EndPointUrl__c;
    }
}