/*************************************************************************
*
* PURPOSE: Data access object for Opportunity
*
* CLASS: gng_OpportunityDao
* CREATED: 1/7/2015 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
***************************************************************************/

public class gng_OpportunityDao extends gng_BaseDao{

	private static final gng_OpportunityDao oppDao = new gng_OpportunityDao();

	private gng_OpportunityDao() {
		super('Opportunity');
	}

	public static gng_OpportunityDao getInstance() {
		return oppDao;
	}

	public Opportunity getOpportunity(Id oppId) {
		Opportunity opp = new Opportunity();
		Opportunity opp2 = new Opportunity();
		Set<String> objectFields = new Set<String>();
		Set<String> setA = new Set<String>();
		Set<String> setB = new Set<String>();
    	SObjectType objToken = Schema.getGlobalDescribe().get('Opportunity');
    	DescribeSObjectResult objDef = objToken.getDescribe();	
    	objectFields.addAll(objDef.Fields.getMap().keySet());

    	Integer i = 0;
    	for(String field : objectFields) {
    		if( i < objectFields.size()/2) setA.add(field);
    		else setB.add(field);
    		i++;
    	}
    	opp = (Opportunity)getSObjectById(oppId,setA);
    	opp2 = (Opportunity)getSObjectById(oppId,setB);

    	for(String field : setB) {
			if(objDef.Fields.getMap().get(field).getDescribe().isUpdateable()) opp.put(field,opp2.get(field));
    	}
    	return opp;

	}
}