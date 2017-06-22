public class ECO_ClassificationEditorController {

    public pse__Proj__c oProject {get; set;}
    public List<FieldSetMemberWrapper> lClassifications {get; set;}

    public class FieldSetMemberWrapper {
        public FieldSetMember fsm { get; set; }
        public Boolean isRequired { get; set; }
    }

    public PageReference SaveClassification() {
        ECO_TriggerSettings.bypass('regenerateWeeklyRollupEntries');
        update oProject;
        ECO_TriggerSettings.clearBypass('regenerateWeeklyRollupEntries');
        
        return null;
    } 
    
    public ECO_ClassificationEditorController(ApexPages.StandardController stdController) {
        List<String> lClassificationPathNames = new List<String>();
        lClassificationPathNames.add('CarryingOutOrganization__c');
        for (FieldSetMember oFSM : SObjectType.pse__Proj__c.FieldSets.ECO_OracleClassificationFields.getFields()) {
            lClassificationPathNames.add(oFSM.getFieldPath());
        }

		if (!test.isRunningTest()) {
        	stdController.addFields(lClassificationPathNames);
		}
		
        this.oProject = (pse__Proj__c) stdController.getRecord();
        List<OrganizationString__c> lOrganizationStrings = new List<OrganizationString__c>();
        OrganizationString__c oOrganizationString = new OrganizationString__c();
        
        if (this.oProject.CarryingOutOrganization__c != NULL) {
            String sSOQL = 'SELECT id';
            for (FieldSetMember oFSM : SObjectType.pse__Proj__c.FieldSets.ECO_OracleClassificationFields.getFields()) {
                sSOQL += ', ' + oFSM.getFieldPath();
            }
            sSOQL += ' FROM OrganizationString__c';
            sSOQL += ' WHERE Id = \'' + this.oProject.CarryingOutOrganization__c + '\''; 
            System.debug(sSOQL);
            lOrganizationStrings = Database.query(sSOQL);
        }

        if (lOrganizationStrings.size() > 0) {
            oOrganizationString = lOrganizationStrings.get(0);
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Primary Organization found, cannot edit classifications!'));
            /*
            ApexPages.addMessages(new ECO_DBExceptionNamespace.NoDataException('Opening Project Classifications Editor', 
                                                             '1_1_1',
                                                             'No Organization String Found!'));
            */
            return;
        }

        lClassifications = new List<FieldSetMemberWrapper>();
        for (FieldSetMember oFSM : SObjectType.pse__Proj__c.FieldSets.ECO_OracleClassificationFields.getFields()) {
            String sOrganizationStringValue = (String) oOrganizationString.get(oFSM.getFieldPath());
            FieldSetMemberWrapper fsmWrapper = new FieldSetMemberWrapper();
            fsmWrapper.fsm = oFSM;

            fsmWrapper.isRequired = false;
            if (sOrganizationStringValue == 'Include') {
                lClassifications.add(fsmWrapper);
            } else if (sOrganizationStringValue == 'Require') {
                lClassifications.add(fsmWrapper);
                fsmWrapper.isRequired = true;
            } else if (sOrganizationStringValue != NULL && sOrganizationStringValue != 'Exclude') {
                lClassifications.add(fsmWrapper);
                // Cannot use isEmpty method of the String class as getFieldPath can return a boolean value
                // Comparing to a string does an implicit conversion to a string
                if (oProject.get(oFSM.getFieldPath()) == NULL || oProject.get(oFSM.getFieldPath()) == '') {
                    oProject.put(oFSM.getFieldPath(), sOrganizationStringValue);
                }
            } else if (oProject.get(oFSM.getFieldPath()) != NULL && oProject.get(oFSM.getFieldPath()) != '') {
                lClassifications.add(fsmWrapper);
            }
            
        } // end of for
    }
}