public without sharing class INC_IncentiveSearch_Controller {
	
	public String projectNumber{get;set;}
	public String projectName {get;set;}
	public String projectManager {get;set;}
	public String customerName {get;set;}
	public String blankValue{get;set;}
	public List<criteriaRow> searchCriteria{get;set;}
	public list<resultRow> lResults {get;set;}
	private id ineligibleQueue;
	public Integer removeRow {
        get;
        // *** setter is NOT being called ***
        set {
            removeRow = value;
            System.debug('value: '+value);
        }
    }
	private String sProjectName;
	private String sProjectNumber;
	private String sCustomerName;
	private String sProjectManager;
	private String sOwner;

	public INC_IncentiveSearch_Controller() {
		lResults = new list<resultRow>();
		searchCriteria = new list<criteriaRow>();
		List<Group> lGroups = [Select Id from Group where name='DTW Ineligible Queue' and Type = 'Queue'];
		if(lGroups != null && lGroups.size() > 0){
			ineligibleQueue = lGroups[0].id;
		}
		addRow();

	}

	public PageReference addRow(){
		criteriaRow ocriteriaRow;
		if(searchCriteria != null && searchCriteria.size() > 0){
			
			if((searchCriteria[searchCriteria.size() -1].value != null && searchCriteria[searchCriteria.size() -1].value !='') ||
				searchCriteria[searchCriteria.size() -1].IncProj.ProjectManager__c != null){
			  	if(searchCriteria.size() <5){
			  		ocriteriaRow = new criteriaRow(searchCriteria[searchCriteria.size() -1]);
					searchCriteria.add(oCriteriaRow);
				}
			}
		}else{
			ocriteriaRow = new criteriaRow(null);
			searchCriteria.add(ocriteriaRow);
		}

		return null;
	}

	public PageReference removeRow(){
		if(searchCriteria != null && searchCriteria.size() == 1){
			return null;
		}
		Integer iCurrentRow = 0;
		Integer rowToRemove = 0;
		criteriaRow removalrow;
		for(criteriaRow CR: searchCriteria){
			if(CR.Row == removeRow){
				rowToRemove = iCurrentRow;
				removalrow = CR;
			}else{
				if(CR.Row > removeRow){
					CR.Row = CR.Row - 1;
				}
			}
			iCurrentRow ++;
		}
		searchCriteria.remove(rowToRemove);

		return null;
	}

	public PageReference changeOwner(){
		boolean bHasError = false;
		list<IncentiveProject__c> lupdate = new list<IncentiveProject__c>();
		for(resultRow rw: lResults){
			if(rw.changeOwner){
				if(rw.newOwner != null && rw.newOwner != ''){
					rw.oIP.OwnerID = rw.newOwner;
					rw.Message = '';
					lupdate.add(rw.oIP);
				}else{
					//DTWINCISCSELNEWOWN
					//rw.Message = 'Please select a new Owner.';
					rw.Message = LABEL.DTWINCISCSELNEWOWN;
					bHasError = true;
				}
			}
		} 

	  System.savePoint sp = Database.setSavePoint();
      if(lUpdate != null && lUpdate.size() > 0 && !bHasError){
	      try{
	          update lUpdate;
	          return search();
	      }catch(Exception e){
	          system.debug('Handling Exception:  '+e.getMessage() + ' ' + e.getStackTraceString());
	          system.debug(logginglevel.error, 'problem updating IncentiveProject__c ' + e);
	          Database.rollBack(sp);
	      }
	   }

		return null;
	}



	public PageReference search(){
		if(validateCriteria()){
			String sQuery = buildQuery();
			System.Debug(logginglevel.error,'sQuery: ' + sQuery + ' ' + sProjectManager);
			if(sQuery != null && sQuery.length() > 0){
				//lResults = Database.query(sQuery);
				lResults = new list<resultRow>();
				for(IncentiveProject__c ip: Database.Query(sQuery)){
					lResults.add(New resultRow(ip,ineligibleQueue));
				}
			}
			if(lResults.size() > 200){
				//DTWINCISCSEATOMANYERR
				//apexPages.addMessage(new apexPages.message(apexPages.Severity.Info,'Your search returned more that 200 results.  Only the first 200 are displayed.'));
				apexPages.addMessage(new apexPages.message(apexPages.Severity.Info,LABEL.DTWINCISCSEATOMANYERR));
			}
			if(lResults == null || lResults.size() == 0){
				//LABEL.DTWINCISCNORESERR
				//apexPages.addMessage(new apexPages.message(apexPages.Severity.Info,'Your search returned no results.'));
				apexPages.addMessage(new apexPages.message(apexPages.Severity.Info,LABEL.DTWINCISCNORESERR));
			}
			System.Debug(logginglevel.error,'lResults: ' + lResults);
		}else{
			//LABEL.DTWINCISCPREVDUP
			//apexPages.addMessage(new apexPages.message(apexPages.Severity.Error,'Please review your criteria for duplicates or missing values'));
			apexPages.addMessage(new apexPages.message(apexPages.Severity.Error,LABEL.DTWINCISCPREVDUP));
		}
		return null;
	}

	public boolean validateCriteria(){
		set<String> sCompare = new set<String>();
		boolean bReturn = true;
		for(criteriaRow CR: searchCriteria){
			if(sCompare != null && sCompare.contains(CR.criteria)){
				bReturn = false;
				break;
			}else{
				sCompare.add(Cr.criteria);
			}
			System.Debug(logginglevel.error,'CR: ' + CR);
			if((Cr.value == null || CR.value =='') &&
			   CR.IncProj.ProjectManager__c == null){
				bReturn = false;
				break;
			}

		}

		return bReturn;
	}


	private String buildQuery(){
		String sQuery = 'Select ID' + 
								+',EnrollmentPlan__c'
								+',EnrollmentStatus__c'
								+',Name'
								+',ProjectID__c'
								+',ProjectManager__c'
								+',ProjectManager__r.Name'
								+',DTWAdmin__r.Name'
								+',CustomerName__c'
								+',ApprovedNSRBudget__c'
								+',OwnerID'
								+',DTWAdmin__c'
								+' From IncentiveProject__c'
								+' Where ';
		Integer i = 0;
		System.Debug(logginglevel.error,'searchCriteria ' + searchCriteria.size());
		for(criteriaRow CR: searchCriteria){
			boolean blank = false;
			i ++;
			if(CR.criteria == 'PM'){
			 	//sProjectManager = cr.Value;
				//if(cr.Value == null || cr.Value == ''){
				sProjectManager = Cr.IncProj.ProjectManager__c;
				//}
				if(sProjectManager != null || sProjectManager == ''){
					sQuery += 'ProjectManager__c =: sProjectManager';
				}else{
					blank = true;
				}
				
			}
			if(CR.criteria == 'PN')
			{
				if(cr.Value != null && cr.Value != ''){
					sProjectName = '%'+ CR.value + '%';
					sQuery += 'Name LIKE : sProjectName';
				}else{
					blank = true;
				}
			}
			if(CR.criteria == 'CN'){
				if(cr.Value != null && cr.Value != ''){
					sCustomerName = '%'+ CR.Value + '%';
					System.Debug(logginglevel.error,'sCustomerName ' + sCustomerName);
					sQuery += 'CustomerName__c LIKE : sCustomerName';
				}else{
					blank = true;
				}
			}
			if(CR.criteria== 'PNUM'){
				if(cr.Value != null && cr.Value != ''){
					sProjectNumber = CR.Value;
					sQuery += 'ProjectID__c =: sProjectNumber';
				}else{
					blank = true;
				}
			}

			if(CR.criteria== 'OW'){
				if(cr.Value != null && cr.Value != ''){
					sOwner = '%'+ CR.value + '%';
					sQuery += 'Owner.Name LIKE: sOwner';
				}else{
					blank = true;
				}
			}


			if(i < searchCriteria.size() && !blank){
				sQuery += ' AND ';
			}
		}
		//sQuery += 'AND EnrollmentStatus__c != \'Archived\'';
		sQuery += ' order by ApprovedNSRBudget__c desc limit 201';
		return sQuery;
	}

	public boolean isNull(String s){
		boolean bReturn = false;
		if(s == null || s == ''){bReturn = true;}
		return bReturn; 
	}

	public class criteriaRow{
		public Integer row{get;set;}
		public string criteria{get;set;}
		public string value{get;set;}
		public list<SelectOption> criteriaRowlist {get;set;}
		public IncentiveProject__c IncProj{get;set;}
	
		public criteriaRow(criteriaRow previousRow){

			if(previousRow != null){
				System.Debug(logginglevel.error,'Row: ' + previousRow.Row);
				row = previousRow.row + 1;
			}else{
				row = 1;
			}
			IncProj = new IncentiveProject__c();
			criteriaRowlist = new list<SelectOption>();
			buildSelectOptions(previousRow);


		}
	
		private void buildSelectOptions(criteriaRow previousRow){
				/*
					DTWINCISCPM
					DTWINCISCPN
					DTWINCISCPNUM
					DTWINCISCCN
					DTWINCISCOW
				*/
				criteriaRowList.add(new SelectOption('',''));
				criteriaRowlist.add(new SelectOption('PM',LABEL.DTWINCISCPM));
				criteriaRowlist.add(new SelectOption('PN',LABEL.DTWINCISCPN));
				criteriaRowlist.add(new SelectOption('PNUM',LABEL.DTWINCISCPNUM));
				criteriaRowlist.add(new SelectOption('CN',LABEL.DTWINCISCCN));
				criteriaRowlist.add(new SelectOption('OW',LABEL.DTWINCISCOW));
		}

	}

	public class resultRow{
		public boolean changeOwner {get;set;}
		public boolean HasAccess {get;set;}
		public IncentiveProject__c oIP {get;set;}
		public String Message{get;set;}
		public list<SelectOption> possibleOwners {get;set;}
		public String newOwner{get;set;}
		public resultRow(IncentiveProject__c ip,id ineligibleQueue){
			Message = '';
			changeOwner = false;
			oIP = ip;
			System.Debug(logginglevel.error,'ineligibleQueue ' + ineligibleQueue);
			setOptions(ineligibleQueue);
			if(oIP.DTWAdmin__c == UserInfo.getUserId() || oIP.OwnerID == UserInfo.getUserId() ||
			   oIP.ProjectManager__c == UserInfo.getUserId()){
				HasAccess = true;
			}else{
				HasAccess = false;
			}

			System.debug(logginglevel.error,'User: ' + UserInfo.getUserId());
			System.debug(logginglevel.error,'DTWAdmin__c: ' + oIP.DTWAdmin__c);
			System.debug(logginglevel.error,'PM: ' + oIP.ProjectManager__c);
			System.debug(logginglevel.error,'Owner: ' + oIP.OwnerID);
			
			System.debug(logginglevel.error,'HasAccess: ' + HasAccess);
		}

		public void setOptions(id ineligibleQueue) {
	        List<SelectOption> options = new List<SelectOption>();
	        set<id> setids = new set<id>();
	        if(oIP.OwnerID == ineligibleQueue){
	      			if(oIp.DTWAdmin__c != null){
						options.add(new SelectOption(oIP.DTWAdmin__c,'(DTW Admin): ' + oIP.DTWAdmin__r.Name));
						setids.add(oIP.DTWAdmin__c);
					}
					if(oIp.ProjectManager__c != null){
						if(!setIds.contains(oIP.ProjectManager__c)){
							options.add(new SelectOption(oIP.ProjectManager__c,'(PM): ' + oIP.ProjectManager__r.Name));
						}
					}
			}
	        
	        possibleOwners = new list<SelectOption>();
	        if(options != null && options.size() > 0){
	        	possibleOwners.addAll(options);
	        }

	    }
	}

}