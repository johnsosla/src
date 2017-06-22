/*************************************************************************
*
* PURPOSE: call out the ABR Web methods to get Australian bisiness Numbers
* 		   ANZ region
*
* AUTHOR: Luke Farbotko
***************************************************************************/
public class ABNHttpGetCallout {
	public HttpResponse getABNsAndParse(String searchString, String authenticationGuid) {
    String search = searchString.replace(' ', '%20');
        
    // Get the XML document from the external server
    Http http = new Http();
    HttpRequest req = new HttpRequest();
    req.setEndpoint('http://abr.business.gov.au/abrxmlsearch/AbrXmlSearch.asmx/ABRSearchByNameAdvancedSimpleProtocol2006?name=' + search + '&postcode=&legalName=&tradingName=&NSW=&SA=&ACT=&VIC=&WA=&NT=&QLD=&TAS=&authenticationGuid=' + authenticationGuid + '&searchWidth=&minimumScore=90&maxSearchResults=35');
    req.setMethod('GET');
    req.setTimeout(30000) ;	 
    return http.send(req);
    
//    System.debug(res.getBody());
  //  return res.getBody();
      
    // Log the XML content
    // Generate the HTTP response as an XML stream

    // Read through the XML
   // while(reader.hasNext()) {
     // System.debug('Event Type:' + reader.getEventType());
    //  if (reader.getEventType() == XmlTag.START_ELEMENT) {
      //  System.debug(reader.getLocalName());
    //  }
     // reader.next();
  //  }
  	
    
  }
}