public without sharing class CFM_ProjectContactEditController {


    public Boolean isEditMode { get; set; }
    public CFM_Project project { get; set; }
    public Contact surveyContact { get; set; }

    public String modifiedProjectName { get; set; }

    public String contactMode { get; set; }

    public Boolean wasSaved { get; set; }

    public CFM_ProjectContactEditController(ApexPages.StandardController sc) {
        isEditMode = false;
        getProject(sc.getId());
        wasSaved = false;

        if (project.obj.CFM_Survey_Contact__c != null) {
            contactMode = '1'; // Contact information is correct
            surveyContact = getContact(project.obj.CFM_Survey_Contact__c);  
        }
        else {
            surveyContact = new Contact(); // Placeholder obj for user to put in contact information
        }
    }

    private void getProject(Id projectId) {
        project = CFM_Project.findAllFields.findById(projectId);
        modifiedProjectName = project.obj.Modified_Project_Name__c;
    }

    public Boolean getHasExistingContact() {
        return project.obj.CFM_Survey_Contact__c != null;
    }


    public list<SelectOption> getContactOptions() {
        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption('1', Label.CFM_Contact_Edit_Correct_Info));
        options.add(new SelectOption('2', Label.CFM_Contact_Edit_Out_Of_Date));
        options.add(new SelectOption('3', Label.CFM_Contact_Edit_Wrong_Contact));

        return options;
    }

    public PageReference switchContactMode() {
        if (contactMode == '1') {
            surveyContact = getContact(project.obj.CFM_Survey_Contact__c);  
        }
        else if (contactMode == '2') {
            surveyContact = getContact(project.obj.CFM_Survey_Contact__c);  
        }
        else if (contactMode == '3') {
            surveyContact = new Contact();
        }

        return null;
    }


    public PageReference setEditMode() {
        isEditMode = true;
        return null;
    }


    public PageReference cancelEdit() {
        contactMode = '1';
        getProject(project.getId());
        isEditMode = false;
        return null;
    }


    public PageReference performSave() {

        Boolean disableLast90DaysCheck = false;

        CFM_Survey_Settings__c settings = CFM_Survey_Settings__c.getOrgDefaults();
        if (!String.isBlank(settings.P90_Disabled_Geographies__c) && !String.isBlank(project.obj.Oracle_Geography__c)) {
            List<String> geoList = settings.P90_Disabled_Geographies__c.split(',');
            for (String geo : geoList) {
                if (CFM_StringUtil.trimStringEquals(geo, project.obj.Oracle_Geography__c)) {
                    disableLast90DaysCheck = true;
                }
            }
        }
        
        if (String.isBlank(surveyContact.LastName)) {
            CFM_PageUtil.addError(Label.CFM_Contact_Edit_Error_BlankName);
            return null;
        }
        if (String.isBlank(surveyContact.Email)) {
            CFM_PageUtil.addError(Label.CFM_Contact_Edit_Error_BlankEmail);
            return null;
        }
        if (String.isBlank(project.obj.Oracle_Client__c)) {
            CFM_PageUtil.addError(Label.CFM_Contact_Edit_Error_NoAccount);
            return null;
        }
        if (surveyContact.Id != null) {
            update surveyContact;
        }
        else {
            List<Contact> contactsWithSameEmail = [Select Id, CFM_Last_Survey_Date_Sent__c, CFM_Do_Not_Survey__c from Contact where Email = :surveyContact.Email];

            surveyContact.AccountId = project.obj.Oracle_Client__c;
            surveyContact.Status__c = 'Active';

            // P90 Check

            if (!disableLast90DaysCheck && contactsWithSameEmail.size() > 0) {
                for (Contact existingContact : contactsWithSameEmail) {
                    if (existingContact.CFM_Last_Survey_Date_Sent__c != null && existingContact.CFM_Last_Survey_Date_Sent__c.addDays(90) >= Date.today()) {
                        CFM_PageUtil.addError(Label.CFM_Contact_SurveyedLast90);
                        return null;
                    }
                    if (existingContact.CFM_Do_Not_Survey__c) {
                        CFM_PageUtil.addError(Label.CFM_Contact_DoNotSurveyError);
                        return null;
                    }
                }    
            }
            

            if (contactsWithSameEmail.size() > 0) {
                surveyContact.Id = contactsWithSameEmail.get(0).Id;
            }
            
            upsert surveyContact; 


            project.obj.CFM_Survey_Contact__c = surveyContact.Id;
        }

        project.obj.Modified_Project_Name__c = modifiedProjectName;

        if (!String.isBlank(modifiedProjectName)) {
            project.obj.Review_Requested__c = true;
        }
    
        project.save();

        wasSaved = true;


        CFM_PageUtil.addConfirm('Contact information updated');

        return null;
    }


    private static Contact getContact(Id contactId) {
        return [Select Id, FirstName, LastName, Email, Phone, Survey_Language__c from Contact where Id = :contactId];   
    }
}