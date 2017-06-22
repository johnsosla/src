global class gng_Weekly_Pending_EMEA implements Schedulable {
	global void execute(SchedulableContext sc) {
		//Testing for Schedulable
		//DateTime n = datetime.now().addSeconds(1);
		//String cron = '';
		//cron += n.second();
		//cron += ' ' + n.minute();
		//cron += ' ' + n.hour();
		//cron += ' ' + n.day();
		//cron += ' ' + n.month();
		//cron += ' ' + '?';
		//cron += ' ' + n.year();
		//System.schedule('EMEA Emails',cron, new gng_Weekly_Pending_EMEA());

		//cron String for job to run every Friday at 12
		//String cron = '0 0 12 ? * FRI *'; 
		//System.schedule('EMEA Pending GNG Emails',cron, new gng_Weekly_Pending_EMEA());
		String sfDomain = URL.getSalesforceBaseUrl().toExternalForm();
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		List<Go_No_Go_Conversation__c> pendingGNGs = [Select Id,Name,Approval_Status__c,Project_Director__r.Email,Opportunity__r.StageName,Opportunity__c,Opportunity__r.Name,Project_Director__c
													 from Go_No_Go_Conversation__c
													 where (NOT Opportunity__r.StageName LIKE '1%') AND
													 	   (Approval_Status__c =: 'Not Submitted' OR Approval_Status__c =: 'Submitted for Approval - Pending') AND (Project_Director__c != null)];
		Map<String,List<Go_No_Go_Conversation__c>> projDirToGNG = new Map<String,List<Go_No_Go_Conversation__c>>();
		Map<Id,Id> gngIdsToPD = new Map<Id,Id>(); // GNG Id and their project director

		for(Go_No_Go_Conversation__c gng : pendingGNGs) {
			if(!projDirToGNG.containsKey(gng.Project_Director__r.Email)) projDirToGNG.put(gng.Project_Director__r.Email,new List<Go_No_Go_Conversation__c>{gng});
			else projDirToGNG.get(gng.Project_Director__r.Email).add(gng);

			if(!gngIdsToPD.containsKey(gng.Id)) gngIdsToPD.put(gng.Id,gng.Project_Director__c);
		}

		for(String dirId : projDirToGNG.keySet()) {
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			email.setSubject('Pending GNG records this week: ' + Date.today().toStartOfWeek().format() + ' - ' + Date.today().toStartOfWeek().addDays(6).format());
			email.setToAddresses(new List<String>{dirId});
			String bodyText = '<style>table {border-collapse: collapse;text-align: center;}table,td, th {border: 1px solid black;}</style>Pending GNG records for this week: <br/><table>';
			bodyText += '<thead><th>Go/No Go Record</th><th>GNG Approval Status</th><th>Opportunity</th><th>Opportunity Stage</th></thead>';
			for(Go_No_Go_Conversation__c gng : projDirToGNG.get(dirId)) {
				bodyText += '<tr>';
				bodyText +=	'<td><a href="' + sfDomain + '/' + gng.Id + '">' + gng.Name + '</a></td>';
				bodyText +=	'<td>' + gng.Approval_Status__c + '</td>';
				bodyText +=	'<td><a href="' + sfDomain + '/' + gng.Opportunity__c + '">' + gng.Opportunity__r.Name + '</a></td>';
				bodyText +=	'<td>' + gng.Opportunity__r.StageName + '</td>';
				bodyText += '</tr>';
			}
			bodyText += '</table>';
			email.setHtmlBody(bodyText);
			emails.add(email);
		}

		Messaging.sendEmail(emails);
	}
}