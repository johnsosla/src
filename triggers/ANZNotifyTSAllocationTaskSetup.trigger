/*******************************************************************
  Name        :   ANZNotifyTSAllocationTaskSetup
  Requester   :   ANZ Requirements GAP 
  Author      :   AECOM - Luke Farbotko
  Version     :   1.0 
  Purpose     :   This Trigger is used  to alert bid managers, directors 
                    of timesheet allocation and finance that a new task 
                    needs to be created within oracle
  Date        :   21 Jul, 2014 
  
  Change Order C31167  01 Dec 2014 - Luke Farbotko
    - Fix Bug in Salesforce ANZ Timesheet Allocation Notification 
    - Added 'else' statement at line 260 that handles key clients
    
  Change Order XXXXX  XX Jan 2015 - Luke Farbotko
   -  lines 81 - 107 added USER version of the three roles Capture manager, 
      Project manager and Project Director 
   -  Update select statemment on line 52 to include new USER versions of roles
********************************************************************/
trigger ANZNotifyTSAllocationTaskSetup on Opportunity_Department__c (after insert) {
    List<String> myEmail = new List<String>() ;
    List<Opportunity_Department__c> oppDepts = new List<Opportunity_Department__c>();
    boolean isKeyClient =  false;
    string subject = ''; 
    String htmlBody = '';
    string taskName = '';
    
    Opportunity_Department__c primaryDept;
    ANZDeptProject__c dept;
    ANZTaskStructure__c tasks;
    
    try
    {
        Id userId =userinfo.getUserId();
        //String geography =[Select Id,Geography_Allocation__c from User where Id=:userId].Geography_Allocation__c;
        String geography = [select Geography_Allocation__c from User where id = :UserInfo.getUserId()].Geography_Allocation__c;
        

        if(geography == 'ANZ')
        {
            
            for(Opportunity_Department__c oppDept:Trigger.New)
            {
                oppDepts.add(oppDept) ;
                if (oppDept.Primary__c == true)
                {
                    primaryDept = oppDept;
                }
            }
            // 12-jan-2015 Updates select
            Opportunity_Department__c oppDept = oppDepts.get(0);
            // 02-Feb-2015 -udated select to include extra fields for email alert
            Opportunity opp = [select   AECOM_Net_Value__c
										, B_P_Budget__c
										, Account.Name
										, End_Client_Sector__c
										, Opportunity_ID__c
										, Name
										, Capture_Manager__r.email__c
										, Project_Manager__r.email__c
										, Project_Director__r.email__c
										, Capture_Manager_User__r.email
										, Project_DirectorUser__r.email
										, Project_ManagerUser__r.email
										, ProjectCountry__c
										, Practice_Area_of_Primary_AECOM_Dept__r.Name
										, Capture_Manager_User__r.Name
										, CurrencyIsoCode
                               from Opportunity where id = :oppDept.Opportunity__c limit 1];

            try
            {
                if (opp.Capture_Manager__r.email__c.length()> 0)
                {
                    myEmail.add(opp.Capture_Manager__r.email__c);
                }
            }catch(Exception e1){
            }
            
            try
            {
                if (opp.Project_Manager__r.email__c.length()> 0)
                {
                    myEmail.add(opp.Project_Manager__r.email__c);
                }
            }catch(Exception e2){
            }
            
            try
            {
                if (opp.Project_Director__r.email__c.length()> 0)
                {
                    myEmail.add(opp.Project_Director__r.email__c);
                }
            }catch(Exception e3){}
            
            // 12-jan-2015 Add the above roles using the USER object version 
            try
            {
                if (opp.Capture_Manager_User__r.email.length()> 0)
                {
                    myEmail.add(opp.Capture_Manager_User__r.email);
                }
            }catch(Exception e1){
            }
            
            try
            {
                if (opp.Project_DirectorUser__r.email.length()> 0)
                {
                    myEmail.add(opp.Project_DirectorUser__r.email);
                }
            }catch(Exception e2){
            }
            
            try
            {
                if (opp.Project_DirectorUser__r.email.length()> 0)
                {
                    myEmail.add(opp.Project_DirectorUser__r.email);
                }
            }catch(Exception e3){}
            
            
            //get the opportunity and detirmine if its Greater then the threashholds
            // if yes and the primary department is one of the new items then continue 
            if ((opp.AECOM_Net_Value__c > 1000000 || opp.B_P_Budget__c > 50000) && primaryDept <> null)
            {
                 
                 //HelperMethods.sendHTMLEmail(myEmail, '1', '1');
                 // work out if is key client
                 
                try{
                    tasks = [select ClientEndClientName__c, 
                                             EndClientSector__c, 
                                             KeyClient__c, 
                                             ParentTaskName__c, 
                                             ParentTaskNo__c, 
                                             TaskName__c, 
                                             TaskNo__c
                                         from ANZTaskStructure__c 
                                         where ClientEndClientName__c = :opp.Account.Name 
                                              AND TotalPotentialFeeGTEThreshold__c = 'Yes' limit 1 ];
                }
                catch(Exception e){
                        System.Debug('zzz' + e.getLineNumber() + e.getMessage() );                    
                }
               
                
                if (tasks <> null)
                {
                     //HelperMethods.sendHTMLEmail(myEmail, 'key', 'Key');
                    isKeyClient = true;
                    taskName = 'Key client bid over $1M ';
                    try{
                        dept = [SELECT AECOM_Department__c, Name, EmailRecipient3__c, KeyClient__c, 
                                LastModifiedById, LastModifiedDate, OracleProjectName__c, OracleProjectNo__c 
                                FROM ANZDeptProject__c  
                                WHERE KeyClient__c = 'Yes'
                                   AND AECOM_Department__c = :primaryDept.AECOM_Department__c limit 1];
                       
                         myEmail.add(dept.EmailRecipient3__c); 
                    }
                    catch(Exception e){}
                        
                }
                else 
                {
                    //HelperMethods.sendHTMLEmail(myEmail, 'non key', 'non Key');
                    // not key client, so get the task related to the End client sector
                    isKeyClient = false;
                    taskName = 'Non Key Client Over $1M';
                    try{
                            
                        tasks = [select ClientEndClientName__c, 
                                                 EndClientSector__c, 
                                                 KeyClient__c, 
                                                 ParentTaskName__c, 
                                                 ParentTaskNo__c, 
                                                 TaskName__c, 
                                                 TaskNo__c
                                             from ANZTaskStructure__c 
                                             where EndClientSector__c = :opp.End_Client_Sector__c
                                                  AND TotalPotentialFeeGTEThreshold__c = 'Yes' limit 1];
                    }
                    catch(Exception e){
                        System.Debug('yzzz' + e.getLineNumber() + e.getMessage() );                    
                    }
                    try{
                        dept = [SELECT AECOM_Department__c, Name, EmailRecipient3__c, KeyClient__c, 
                            LastModifiedById, LastModifiedDate, OracleProjectName__c, OracleProjectNo__c 
                            FROM ANZDeptProject__c  
                            WHERE KeyClient__c = 'No'
                                AND AECOM_Department__c = :primaryDept.AECOM_Department__c limit 1];
                        myEmail.add(dept.EmailRecipient3__c);
                    }
                    catch(Exception e){
                        System.Debug('zzz' + e.getLineNumber() + e.getMessage() );                    
                    }
                }
                
                if (tasks <> null)
                {
                   //HelperMethods.sendHTMLEmail(myEmail, 'task not null', 'task not null');
                   // get department  details 
                   // [SELECT AECOM_Department__r.Name, Name, EmailRecipient3__c, KeyClient__c, LastModifiedById, LastModifiedDate, OracleProjectName__c, OracleProjectNo__c 
 
                    
                    subject = 'Business Development Timesheet Allocation and New Task Setup Instruction';
                    
                    htmlBody = '<p><b>Attention:</b> Project Finance - An Opportunity that has a Potential Net Fee >= $1,000,000 or a Bid Cost >= $50,000 has been setup in Salesforce.</p>';
                    htmlBody += '<p>A new task needs to be added to BD Project No.:<b><i>' + dept.OracleProjectNo__c + '    '  + dept.OracleProjectName__c  + '</i></b> under sub Task: <b><i>' +  tasks.TaskNo__c + '  ' + tasks.TaskName__c  + '</i></b></p>';
                    
                    htmlBody += '<p>Please use this Opportunity No.: <b><i>' + opp.Opportunity_ID__c + '</i></b> as the NEW Task number and <b><i>' + opp.Name + '</i></b> as the NEW Task Name (Limited to 20 Characters).</p>';
                    
                    htmlBody += '<p>On completion of the above task please send confirmation via a return email to the Opportunity Creator & Capture Manager so that they can pass this on to those employees working on the Opportunity for their timesheets.</p>';
                    
                    
                    htmlBody += '<p>';
                    htmlBody += '<b>Task Details:</b><br/>';
                    htmlBody += 'Project Country - ' + opp.ProjectCountry__c + '<br/>';
                    htmlBody += 'Key Client - ' + tasks.KeyClient__c + '<br/>';
                    htmlBody += 'End-Client Sector - ' + opp.End_Client_Sector__c + '<br/>';
                    htmlBody += 'AECOM Work - ' + opp.Practice_Area_of_Primary_AECOM_Dept__r.Name + '<br/>';
                    htmlBody += 'Capture Manager  - ' + opp.Capture_Manager_User__r.Name + '<br/>';
                    htmlBody += 'Bid & Proposal Budget  - ' + opp.B_P_Budget__c + opp.CurrencyIsoCode +  '<br/>';
                    htmlBody += '</p>';
                    
                    htmlBody += '<p>Thank You</p>';
                    
                    HelperMethods.sendHTMLEmail(myEmail, htmlBody, subject);
                }
            }
            else
            {
                                
                subject = 'FW: Business Development Timesheet Allocation - Opportunity No.:' + opp.Opportunity_ID__c + ', OpportunityName: ' + opp.Name ;
                
                try{
                    tasks = [select ClientEndClientName__c, 
                                             EndClientSector__c, 
                                             KeyClient__c, 
                                             ParentTaskName__c, 
                                             ParentTaskNo__c, 
                                             TaskName__c, 
                                             TaskNo__c
                                         from ANZTaskStructure__c 
                                         where ClientEndClientName__c = :opp.Account.Name 
                                              AND TotalPotentialFeeGTEThreshold__c = 'No' limit 1 ];
                }
                catch(Exception e){
                    System.Debug('bzzz' + e.getLineNumber() + e.getMessage() );                    
                }
               
                
                if (tasks <> null)
                {
                     //HelperMethods.sendHTMLEmail(myEmail, 'key', 'Key');
                    isKeyClient = true;   
                }
                else 
                {
                    //HelperMethods.sendHTMLEmail(myEmail, 'non key', 'non Key');
                    // not key client, so get the task related to the End client sector
                    isKeyClient = false;
                    try{
                            
                        tasks = [select ClientEndClientName__c, 
                                                 EndClientSector__c, 
                                                 KeyClient__c, 
                                                 ParentTaskName__c, 
                                                 ParentTaskNo__c, 
                                                 TaskName__c, 
                                                 TaskNo__c
                                             from ANZTaskStructure__c 
                                             where EndClientSector__c = :opp.End_Client_Sector__c
                                                  AND TotalPotentialFeeGTEThreshold__c = 'No' limit 1];
                    }
                    catch(Exception e){
                        System.Debug('azzz' + e.getLineNumber() + e.getMessage() );                    
                    }
                   
                }
                if (tasks <> null)
                {
                    if (isKeyClient == true)
                    {
                        htmlBody += '<p><b>Attention:</b> All Employees working on Opportunity No.:<b>' + opp.Opportunity_ID__c + '</b> , Opportunity Name: <b>' + opp.Name + '</b> with one of our APAC/Global Key Clients: <b>' + tasks.KeyClient__c + '</b></p>';    
                    }   
                    else
                    {
                        htmlBody += '<p><b>Attention:</b> All Employees working on Opportunity No.:<b>' + opp.Opportunity_ID__c + '</b> , Opportunity Name: <b>' + opp.Name + '</b> under End-Client Sector: <b>' + tasks.EndClientSector__c + '</b></p>';
                    }
                    
                    
                    
                    htmlBody += '<p>The departments below have been listed on the above Opportunity. All employees working on this Opportunity will need to allocate their Bid/Proposal time applicable to their own specific Business Line and Location BD Project as per the below.</p>';
                    htmlBody += '<p><b>Timesheet Allocation Guidance:</b></p>';
                    
                    
                    oppDepts = [SELECT split__c, AECOM_Department__c, Primary__c, AECOM_Department__r.Name
                                    FROM Opportunity_Department__c 
                                    WHERE Opportunity__c = :opp.Id];
                    
                    htmlBody += '<table>';
                    for(Opportunity_Department__c oppDpt:oppDepts)
                    {
                        try{
                            dept = new ANZDeptProject__c();
                             if (isKeyClient == true)
                    		{		
	                            dept = [SELECT AECOM_Department__c, Name, EmailRecipient3__c, KeyClient__c, 
	                            LastModifiedById, LastModifiedDate, OracleProjectName__c, OracleProjectNo__c 
	                            FROM ANZDeptProject__c  
	                            WHERE KeyClient__c = 'Yes'
	                                AND AECOM_Department__c = :oppDpt.AECOM_Department__c limit 1];
                    		}
                    		else
                    		{
                    			dept = [SELECT AECOM_Department__c, Name, EmailRecipient3__c, KeyClient__c, 
	                            LastModifiedById, LastModifiedDate, OracleProjectName__c, OracleProjectNo__c 
	                            FROM ANZDeptProject__c  
	                            WHERE KeyClient__c = 'No'
	                                AND AECOM_Department__c = :oppDpt.AECOM_Department__c limit 1];
                    		}
                        }
                        catch(Exception e){}
                        
                        if (dept <> null)
                        {
                            htmlBody +='<tr>' + 
                              '<td><b>Department:</b></td>' +
                              '<td style="width:200px">' + oppDpt.AECOM_Department__r.Name + '</td>' + 
                              '<td><b>Percentage Allocation:</b></td>' + 
                              '<td>' + oppDpt.split__c + '%</td>' + 
                            '</tr>' + 
                            '<tr>' + 
                              '<td><b>BD Project No.:</b></td>' +
                              '<td>' + dept.OracleProjectNo__c + '</td>' + 
                              '<td><b>Task No:</b></td>' + 
                              '<td>' + tasks.TaskNo__c + '</td>' + 
                            '</tr>' + 
                            '<tr>' + 
                              '<td><b>BD Project Name:</b></td>' +
                              '<td>' + dept.OracleProjectName__c + '</td>' + 
                              '<td><b>Task Name:</b></td>' + 
                              '<td>' + tasks.TaskName__c + '</td>' + 
                            '</tr>' +
                            '<tr>' + 
                              '<td>&nbsp;</td>' +
                              '<td></td>' + 
                              '<td></td>' + 
                              '<td></td>' + 
                            '</tr>';
                        }
                        
                    }
                    htmlBody += '</table>';
                    

                    HelperMethods.sendHTMLEmail(myEmail, htmlBody, subject);
                }
            }
        }
    }
    catch (Exception e){ 
        List<String> errorEmail = new List<String>{'luke.farbotko@aecom.com'} ;
        HelperMethods.sendHTMLEmail(errorEmail, e.getMessage() + ' - ' + e.getLineNumber() + ' - ' + e.getStackTraceString(),  'crap, error');
    }
}