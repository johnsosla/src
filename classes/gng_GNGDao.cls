/*************************************************************************
*
* PURPOSE: Data access object for Go_No_Go_Conversation object
*
* CLASS: gng_OppToGNGC
* CREATED: 12/15/2014 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
***************************************************************************/

public class gng_GNGDao extends gng_BaseDao{

	private static final gng_GNGDao gngDao = new gng_GNGDao();

	private gng_GNGDao() {
		super('Go_No_Go_Conversation__c');
	}

	public static gng_GNGDao getInstance() {
		return gngDao;
	}

	public List<Go_No_Go_Conversation__c> getGNGbyOpportunity(Id oppId) {
		String whereStr = 'Opportunity__c = ' + quote(oppId);
		return (List<Go_No_Go_Conversation__c>)getSObjects(whereStr);
	}

	/**
    * @Description This method will save a Go_No_Go_Conversation object
    * @param a Go_No_Go_Conversation object
    */
    public void save(Go_No_Go_Conversation__c obj) {
        upsert obj;
    }
}