public with sharing virtual class ECO_PageControllerBase {

	public String awanJSPath										{ get; set; }

	//Collection of all URL parameters and cookie values. URL parameters take precedence.
	public Map<string, string> mParameters {get; set;}

	//Typical Return URL variable available to all pages as needed.
	public string sReturnURL {get; set;}

	
	//Initialize all page level variables for benifit of children
	public ECO_PageControllerBase() {
		mParameters = new Map<string, string>();
		
		//Get all page parameter cookies
		Cookie oCookie = ApexPages.CurrentPage().getCookies().get('pageParameters');
		
		//Combine cookie values with url paramters. Add URL parameters last as an "intentional override" of Cookie values
		mParameters.putAll(ParseCookie(oCookie));
		mParameters.putAll(ApexPages.CurrentPage().getParameters().clone());

		/* EXAMPLE of persisting URL parameter as Cookie from other project
		if(mParameters.containsKey('StoreId')){
			AddKeyValueToPageCookie('StoreId', mParameters.get('StoreId'));
		}
		*/

		sReturnURL = mParameters.get('retURL');
		
		awanJSPath = ECO_PortalSettings__c.getInstance().OnAWANJavascriptPath__c;
		
		return;
	}
	
	//Parse cookie logic. Note: this could be more exact with better split optionshaha 
	public Map<string, string> ParseCookie(Cookie oCookie){
		Map<string, string> mCookieResult = new Map<string, string>();
		
		if(oCookie != null){
			List<string> lCookieValues = oCookie.getValue().split(';');
			
			for(string sKeyValue : lCookieValues){
				List<string> lCookiePieces = sKeyValue.split('=');
				
				if(lCookiePieces.size() >= 2){
					string sKey = lCookiePieces.get(0);

					lCookiePieces.remove(0);
					
					string sValue = string.join(lCookiePieces, '=');
					
					mCookieResult.put(sKey, sValue);
				}
			}
		}
		
		return mCookieResult;
	}
	
	//Function to add value to a cookie
	public boolean AddKeyValueToPageCookie(string sKey, string sValue){
		Cookie oCookie = ApexPages.CurrentPage().getCookies().get('pageParameters');
		Map<string, string> mCookieResult = ParseCookie(oCookie);

		mCookieResult.put(sKey, sValue);
		string sCookieValueToSave = '';
		
		for(string sKeyToJoin : mCookieResult.keySet()){
			if(sCookieValueToSave != '')
				sCookieValueToSave += ';';
			
			sCookieValueToSave += sKeyToJoin + '=' + mCookieResult.get(sKeyToJoin);
		}
		
		Cookie oCookieToSave = new Cookie('pageParameters', sCookieValueToSave, null, null, false);
		
		ApexPages.currentPage().setCookies(new Cookie[]{ oCookieToSave } );
		
		return true;
	}
	

}