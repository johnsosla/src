public with sharing class Service_Catalog_AECOMServiceCatalog 
{


	public String chatterGroupId {get; set;}
	public boolean isMemberOfChatterGroup{get;set;}
	public boolean joinBtnDisabled{get;set;}
	public boolean leaveBtnDisabled{get;set;}
    public String coveoSrchStr1{get;set;}
    public String coveoSrchStr2{get;set;}
    public String coveoSrchStr3{get;set;}
    
    public String vw_CatEntriesByCategory_base {get;set;}
    public String vw_AECOMIntellectualProperty {get;set;}
    public String vw_ApplicationDevelopmentMobile {get;set;}
    public String vw_AssetManagementSolutions {get;set;}
    public String vw_BIM {get;set;}
    public String vw_Certifications {get;set;}
    public String vw_CloudInfrastructureServices {get;set;}
    public String vw_ConvergedResilience {get;set;}
    public String vw_ImmersiveTechnologyVisualization {get;set;}
    public String vw_InfoDataManagementservices {get;set;}
    public String vw_ITOperationsSupportServices {get;set;}
    public String vw_SensorsRemoteMonitoringSmartCities {get;set;}   

    public PageReference onLoad() 
    {
    	joinBtnDisabled = true;
    	leaveBtnDisabled = true;

    	chatterGroupId  = '';
    	isMemberOfChatterGroup = false;
    	
        List<Service_Catalog_Settings__c> mcs = Service_Catalog_Settings__c.getall().values();
		chatterGroupId = mcs[0].ChatterId__c;
        coveoSrchStr1 = mcs[0].coveoSrchStr1__c;
        coveoSrchStr2 = mcs[0].coveoSrchStr2__c;
        coveoSrchStr3 = mcs[0].coveoSrchStr3__c;
        
        vw_CatEntriesByCategory_base = mcs[0].vw_CatEntriesByCategory_base__c;
        vw_AECOMIntellectualProperty = mcs[0].vw_CatEntriesByCategory_base__c + mcs[0].vw_AECOMIntellectualProperty__c;
        vw_ApplicationDevelopmentMobile = mcs[0].vw_CatEntriesByCategory_base__c + mcs[0].vw_ApplicationDevelopmentMobile__c;
        vw_AssetManagementSolutions = mcs[0].vw_CatEntriesByCategory_base__c + mcs[0].vw_AssetManagementSolutions__c;
        vw_BIM = mcs[0].vw_CatEntriesByCategory_base__c + mcs[0].vw_BIM__c;
        vw_Certifications = mcs[0].vw_CatEntriesByCategory_base__c + mcs[0].vw_Certifications__c;
        vw_CloudInfrastructureServices = mcs[0].vw_CatEntriesByCategory_base__c + mcs[0].vw_CloudInfrastructureServices__c;
        vw_ConvergedResilience = mcs[0].vw_CatEntriesByCategory_base__c + mcs[0].vw_ConvergedResilience__c;
        vw_ImmersiveTechnologyVisualization = mcs[0].vw_CatEntriesByCategory_base__c + mcs[0].vw_ImmersiveTechnologyVisualization__c;
        vw_InfoDataManagementservices = mcs[0].vw_CatEntriesByCategory_base__c + mcs[0].vw_InfoDataManagementservices__c;
        vw_ITOperationsSupportServices = mcs[0].vw_CatEntriesByCategory_base__c + mcs[0].vw_ITOperationsSupportServices__c;
        vw_SensorsRemoteMonitoringSmartCities = mcs[0].vw_CatEntriesByCategory_base__c + mcs[0].vw_SensorsRemoteMonitoringSmartCities__c;
        
        
        
		Integer count = [SELECT count() FROM CollaborationGroupMember WHERE CollaborationGroupId = :chatterGroupId AND MemberId = :UserInfo.getUserId()];

		if(count>0)
		{
			isMemberOfChatterGroup = true;
			leaveBtnDisabled = false;
		}
		else
		{
			joinBtnDisabled = false;	
		}

			return null ;
    }

    public PageReference addUserToChatterGroup()
    {	joinBtnDisabled = true;
    	ConnectApi.ChatterGroups.addMember(null,chatterGroupId,UserInfo.getUserId());
    	return null;
    }
	public PageReference removeUserFromChatterGroup()
	{
		String membershipId = '';
		leaveBtnDisabled = true;
		List<CollaborationGroupMember> membershipIds  = [SELECT id FROM CollaborationGroupMember WHERE CollaborationGroupId = :chatterGroupId AND MemberId = :UserInfo.getUserId() order by id LIMIT 1];
		//should only return one row

		If(!membershipIds.isEmpty())
		{	
			membershipId = membershipIds[0].id;
			ConnectApi.ChatterGroups.deleteMember(null,membershipId);
		}
		joinBtnDisabled = false;
		return null;
	}
}