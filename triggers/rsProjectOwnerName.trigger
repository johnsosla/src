/*************************************************************************
*
* PURPOSE: Trigger to populate the Client__c field on PR Team records.
            We can't use formula fields because this logic along with Owner_Client_Output__c makes it compile too large for SF (~9000 chars)
*
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina
***************************************************************************/
trigger rsProjectOwnerName on PR_Team_Employee__c (before insert, before update) {


    //Iterate through trigger records and get the ids of relationships we might need to traverse
    Set<Id> projIds = new Set<Id>();
    Set<Id> previousPRTeamIds = new Set<Id>();

    //First iterate through and get any previous project parts, so later we can get the project ids on these previous parts
    for (PR_Team_Employee__c tempPr : Trigger.new) {
        if (tempPr.Previous_Project_Part__c != null) {
            previousPRTeamIds.add(tempPr.Previous_Project_Part__c);
        }
    }
    Map<Id, PR_Team_Employee__c> previousProjectMap = new Map<Id, PR_Team_Employee__c>([SELECT Id, Project_Id__c FROM PR_Team_Employee__c WHERE Id IN :previousPRTeamIds]);


    //get all of the projects and their owner_client_output__c fields that are either in this trigger items OR in the trigger items previous parts
    for (PR_Team_Employee__c tempPr : Trigger.new) {
        if (tempPr.Project_ID__c != null) {
            projIds.add(tempPr.Project_ID__c);
        } else if (tempPr.Previous_Project_Part__c != null && previousProjectMap.get(tempPr.Previous_Project_Part__c).Project_Id__c != null) {
            projIds.add(previousProjectMap.get(tempPr.Previous_Project_Part__c).Project_Id__c);
        }
    }
    Map<Id, Project__c> projectMap = new Map<Id, Project__c>([SELECT Id, Owner_Client_Output__c FROM Project__c WHERE Id IN :projIds]);


    //perform logic for assigning the client__c field
    // 1 - If there is a linked project (project_id__c) use that
    // 2 - If there is a previous project with a linked project, use that
    //   3 - Use the editable field

    for (PR_Team_Employee__c tempPr : Trigger.new) {
        if (tempPr.Project_Id__c != null) {
            tempPR.Client__c = projectMap.get(tempPr.Project_ID__c).Owner_Client_Output__c;
        } else if (tempPr.Previous_Project_Part__c != null && previousProjectMap.get(tempPr.Previous_Project_Part__c).Project_Id__c != null) {
            tempPR.Client__c = projectMap.get(previousProjectMap.get(tempPr.Previous_Project_Part__c).Project_Id__c).Owner_Client_Output__c;
        } else {
            tempPR.Client__c = tempPR.Client_Name_Editable__c;
        }
    }
}