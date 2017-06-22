/*************************************************************************
*
* PURPOSE: a mock call out the ABR Web methods to get Australian bisiness Numbers
* 		   ANZ region, used for testing
*
* AUTHOR: Richard Cook
***************************************************************************/
@isTest
global class ABNHttpGetCalloutMock implements HttpCalloutMock  {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setBody(
'<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">' +
'  <s:Header xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" />' +
'  <soap:Body>' +
'    <ABRSearchByNameAdvancedSimpleProtocol2006Response xmlns="http://abr.business.gov.au/ABRXMLSearch/">' +
'      <ABRPayloadSearchResults>' +
'        <request>' +
'          <nameSearchRequestAdvanced2006>' +
'            <authenticationGUID>6a1c6efc-4ada-47de-bcaa-898f9bf187d1</authenticationGUID>' +
'            <name>Test</name>' +
'            <filters>' +
'              <nameType>' +
'                <tradingName>Y</tradingName>' +
'                <legalName>Y</legalName>' +
'              </nameType>' +
'              <postcode />' +
'              <stateCode>' +
'                <QLD>Y</QLD>' +
'                <NT>Y</NT>' +
'                <SA>Y</SA>' +
'                <WA>Y</WA>' +
'                <VIC>Y</VIC>' +
'                <ACT>Y</ACT>' +
'                <TAS>Y</TAS>' +
'                <NSW>Y</NSW>' +
'              </stateCode>' +
'            </filters>' +
'            <searchWidth>Typical</searchWidth>' +
'            <minimumScore>90</minimumScore>' +
'            <maxSearchResults>35</maxSearchResults>' +
'          </nameSearchRequestAdvanced2006>' +
'        </request>' +
'        <response>' +
'          <usageStatement>This extract is based on information supplied by businesses to the Registrar of the Australian Business Register. ' +
'         Neither the Registrar nor the Australian Government guarantee this information is accurate, up to date or complete. ' +
'         You should consider verifying this information from other sources.</usageStatement>' +
'          <dateRegisterLastUpdated>2014-08-25</dateRegisterLastUpdated>' +
'          <dateTimeRetrieved>2014-08-25T17:03:17.5545936+10:00</dateTimeRetrieved>' +
'          <searchResultsList>' +
'            <numberOfRecords>35</numberOfRecords>' +
'            <searchResultsRecord>' +
'              <ABN>' +
'                <identifierValue>58725115040</identifierValue>' +
'                <identifierStatus>Cancelled</identifierStatus>' +
'              </ABN>' +
'              <mainTradingName>' +
'                <organisationName>T.E.S.T.</organisationName>' +
'                <score>100</score>' +
'                <isCurrentIndicator>Y</isCurrentIndicator>' +
'              </mainTradingName>' +
'              <mainBusinessPhysicalAddress>' +
'                <stateCode>QLD</stateCode>' +
'                <postcode>4074</postcode>' +
'                <isCurrentIndicator>Y</isCurrentIndicator>' +
'              </mainBusinessPhysicalAddress>' +
'            </searchResultsRecord>' +
'            <searchResultsRecord>' +
'              <ABN>' +
'                <identifierValue>21006819692</identifierValue>' +
'                <identifierStatus>Active</identifierStatus>' +
'              </ABN>' +
'              <mainName>' +
'                <organisationName>T.E.S.T. PTY. LTD.</organisationName>' +
'                <score>100</score>' +
'                <isCurrentIndicator>Y</isCurrentIndicator>' +
'              </mainName>' +
'              <mainBusinessPhysicalAddress>' +
'                <stateCode>VIC</stateCode>' +
'                <postcode>3207</postcode>' +
'                <isCurrentIndicator>Y</isCurrentIndicator>' +
'              </mainBusinessPhysicalAddress>' +
'            </searchResultsRecord>' +
'            <searchResultsRecord>' +
'				<ABN>' + 
'				<identifierValue>87137436820</identifierValue>' + 
'				<identifierStatus>Active</identifierStatus>' + 
'				</ABN>' + 
'				<businessName>' + 
'				<organisationName>OTHER FILMS</organisationName>' + 
'				<score>97</score>' + 
'				<isCurrentIndicator>Y</isCurrentIndicator>' + 
'				</businessName>' + 
'				<mainBusinessPhysicalAddress>' + 
'				<stateCode>NSW</stateCode>' + 
'				<postcode>2479</postcode>' + 
'				<isCurrentIndicator>Y</isCurrentIndicator>' + 
'				</mainBusinessPhysicalAddress>' + 
'				</searchResultsRecord>' + 
'            <searchResultsRecord>' +
'              <ABN>' +
'                <identifierValue>21006819692</identifierValue>' +
'                <identifierStatus>Active</identifierStatus>' +
'              </ABN>' +
'              <otherTradingName>' +
'                <organisationName>T.E.S.T. PTY. LTD.</organisationName>' +
'                <score>100</score>' +
'                <isCurrentIndicator>Y</isCurrentIndicator>' +
'              </otherTradingName>' +
'            </searchResultsRecord>' +            
            
'            <searchResultsRecord>' +
'              <ABN>' +
'                <identifierValue>21006819692</identifierValue>' +
'                <identifierStatus>Active</identifierStatus>' +
'              </ABN>' +
'              <Other>' +
'                <something>something</something>' +
'                <else>else</else>' +
'              </Other>' +

            
'            </searchResultsRecord>' +             
            
'          </searchResultsList>' +
'        </response>' +
'      </ABRPayloadSearchResults>' +
'    </ABRSearchByNameAdvancedSimpleProtocol2006Response>' +
'  </soap:Body>' +
'</soap:Envelope>'
        );
        return res;
    }
}