/** ------------------------------------------------------------------------------------------------------
* @Description Service class to check if logged in user has been assigned to Financial Visibility 
*              Permission Set and grant access to Budget Pages.
* @Author      NTT Data - Priya Parepalli
* @Date        April, 2016
*-----------------------------------------------------------------------------------------------------*/
public virtual class ECO_Financial_Security{
    public Boolean hasFinancialForceAccess {get;set;}
    public Boolean hasFinancialForceAccessPS {get;set;}
    public class ECO_Financial_SecurityAccessException extends Exception {}
    
    /**
     * @Description Contructor to check if logged in user is assigned with 
     *              'EcoEPMFinancials' Permission set.
     * @Author  NTT Data - Priya Parepalli
     * @Date    08/08/2016
     *
     * @param 
     * @return  
     **/
    public ECO_Financial_Security(){
        
        Profile userProfile = [Select Name from Profile where Id = :Userinfo.getProfileId() Limit 1];
        
        List<PermissionSet> ps = new List<PermissionSet>();
        List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
        hasFinancialForceAccessPS = false;
        
        ps = [SELECT Id, Label, Name FROM PermissionSet WHERE Name = 'EcoEPMFinancials' ];
        if(ps!= null){
            
            psa = [SELECT Id, PermissionSetId, PermissionSet.Label FROM PermissionSetAssignment WHERE AssigneeId= :UserInfo.getUserId() AND PermissionSetId =:ps[0].Id ];
            
        }

        if(userProfile.Name == 'System Administrator' || psa.size() > 0){
            hasFinancialForceAccess = true;
            //System.debug('inside if sys admin or psa size >0::'+userProfile.Name+'     psa.size()::'+psa.size());
        }
        else {
            //System.debug('inside else sys admin or psa size >0::'+userProfile.Name+'     psa.size()::'+psa.size());
            hasFinancialForceAccess = false;
            Throw new ECO_Financial_SecurityAccessException('You do not have permissions to view financials for this project');
        }

        //System.debug('hasFinancialForceAccessPS:::'+hasFinancialForceAccessPS);

        
    }
}