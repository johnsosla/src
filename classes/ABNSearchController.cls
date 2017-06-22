/*************************************************************************
*
* PURPOSE: Controller for ABNSearch page
*
* AUTHOR: Luke Farbotko
***************************************************************************/
public class ABNSearchController {
    private  Account acct;
       
    public String authenticationGuid = '6a1c6efc-4ada-47de-bcaa-898f9bf187d1';

    public String searchString { get; set; }
    
    public String  message {get; private set;}
    
    public String accountId {get; private set;}
    
    public List<ABNCompany> abnCompanies {get;set;}
    
	private ApexPages.StandardController myController ;
    
    public String abnParan{get;set;}
    
    public String nameParan{get;set;}
    
    private boolean resultRootFound ;
    
    
     public ABNSearchController(ApexPages.StandardController controller) {
         	
         	//string newid = ApexPages.currentPage().getParameters().get('newid');
         	//message = ''
         	//if (newid != '')
            //{
            //string redirectStr ='/apex/ABNSearch?scontrolCaching=1&id=001e000000K5PSP' + newid;
             //RefreshRedirect(redirectStr);
            //}
         	
         	this.myController = controller;
         	
	        acct = (Account)controller.getRecord();
         	
         
         	searchString = acct.Name;
			resultRootFound = false;
     }   

    
         
     public PageReference ABNSelect(){
         
         //string selectedAbn = Apexpages.currentpage().getParameters().get('selectedAbn');
         //string selectedName = Apexpages.currentpage().getParameters().get('selectedName');
         
     	 
         
         acct.Registered_Name__c = this.nameParan;
         acct.Registration_Business_Number__c = this.abnParan;
         
         
         update this.acct;
         return this.myController.Save();
         
         
         //return null; 
     }

  	public void GetMatchingABNs() {   
        ABNHttpGetCallout abn = new ABNHttpGetCallout();
        abnCompanies  = new List<ABNCompany>();
        HttpResponse resp = abn.getABNsAndParse(searchString, authenticationGuid );
        message = resp.getBody();
        parse(message);
        
    }
    
    private void parse(String toParse) {
        resultRootFound = false;
          DOM.Document doc = new DOM.Document();   
       
          try {
            doc.load(toParse);    
            DOM.XMLNode root = doc.getRootElement();
               FindResults(root);
            
          } catch (System.XMLException e) {  // invalid XML
            
          }
	}
    
    
    private void FindResults(DOM.XMLNode node) {

      if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) 
      {
          if (node.getName() == 'searchResultsList'){
              resultRootFound = true;
              LoopThoughResults(node);
          }
      }
      if (resultRootFound == false){
          for (Dom.XMLNode child: node.getChildElements()) {
              FindResults(child);
          }
      }

    }
    
    
    private void LoopThoughResults(DOM.XMLNode node) {
        //we are currently in the searchResultsRecord element
        //
        //Loop through the ABN elements
        string namespace = 'http://abr.business.gov.au/ABRXMLSearch/';
        for (Dom.XMLNode child: node.getChildElements()) {
            if (child.getName() == 'searchResultsRecord'){
                ABNCompany a = new ABNCompany();
                
                
                a.abn = child.getChildElement('ABN', namespace).getChildElement('identifierValue', namespace).getText();
                try{
                	a.organisationName = child.getChildElement('mainName', namespace).getChildElement('organisationName', namespace).getText();    
                    a.score = child.getChildElement('mainName', namespace).getChildElement('score', namespace).getText();    
                    a.isCurrentIndicator = child.getChildElement('mainName', namespace).getChildElement('isCurrentIndicator', namespace).getText();    
                }catch(Exception e){
                    try{
                        a.organisationName = child.getChildElement('mainTradingName', namespace).getChildElement('organisationName', namespace).getText();    
                        a.score = child.getChildElement('mainTradingName', namespace).getChildElement('score', namespace).getText();    
                        a.isCurrentIndicator = child.getChildElement('mainTradingName', namespace).getChildElement('isCurrentIndicator', namespace).getText();    
                    }catch(Exception ex){
                        try{
                        	a.organisationName = child.getChildElement('businessName', namespace).getChildElement('organisationName', namespace).getText();    
                            a.score = child.getChildElement('businessName', namespace).getChildElement('score', namespace).getText();    
                            a.isCurrentIndicator = child.getChildElement('businessName', namespace).getChildElement('isCurrentIndicator', namespace).getText();    
                    	}catch(Exception exx){
                        	 try{
                        		a.organisationName = child.getChildElement('otherTradingName', namespace).getChildElement('organisationName', namespace).getText();    
                                 a.score = child.getChildElement('otherTradingName', namespace).getChildElement('score', namespace).getText();    
                                 a.isCurrentIndicator = child.getChildElement('otherTradingName', namespace).getChildElement('isCurrentIndicator', namespace).getText();    
                    		}catch(Exception exxx){
                        		a.organisationName = child.getChildElements()[1].getName();
                    		}
                    	}
                    }
  
                }
                Dom.XMLNode stateNode = child.getChildElement('mainBusinessPhysicalAddress', 'http://abr.business.gov.au/ABRXMLSearch/');
                if(stateNode != null) {
                    stateNode = stateNode.getChildElement('stateCode', 'http://abr.business.gov.au/ABRXMLSearch/');
                    if(stateNode != null) {
                        a.stateCode = stateNode.getText();
                    }
                }
                abnCompanies.add(a) ;
           }
        }
        
    }

}