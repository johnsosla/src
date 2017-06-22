/** ------------------------------------------------------------------------------------------------------
* @Description This is a controller extension that extends the existing custom  controller
*
* @Author      NTTD
* @Date        2016
*/
public without sharing class ECO_ResilienceController {
        public pse__Proj__c oProject {get;set;}

        public list<Project_Site__c> lstProjectSites {get;set;}
        public list<ProjectCity__c> lstProjectCities {get;set;}
        public list<ProjectCountry_Risk__c> lstProjectCountryRisks {get;set;}
        private Transient Attachment OSP_Attachment;
        public String overrideSafetyHealthInspectionName  {get;set;}  
        public boolean multipleCountry {get;set;}  
        public map<Id, Attachment> attachmentsMap {get; set;}
    
        public string idCityID {get;set;}
        public id idCountryRiskID {get;set;}

        public string strSearchResults {get;set;}
        public string strNoRecords {get;set;}
        public string strAnswer{get;set;}

        public decimal projectRisk {get;set;}

        public list<SelectOption> types { get; set; }

        public string sTargetAttachment {get;set;}
        public boolean bFromSHE {get;set;}

        public boolean bUpdateProject {get;set;}
        public class EcoControllerException extends Exception {}

        
        /**
         * <Re-Usable Method for Querying Project Cities >
         *
         * @Author  NTTD
         * @Date    2016
         *
         * @param   
         * @return  
         **/
        private void UpdateProjectCities(){
                projectRisk = 0;
            
                string country = null;
                multipleCountry = false;
                bUpdateProject = false;
            
                lstProjectCities = [SELECT ID, NAME, Project__c, CityName__c, 
                                            State_Name__c, ClassCategory__c, Type__c, ProjectCountryRisk__r.CountryName__c, 
                                            ProjectCountryRisk__r.Safety_Rating__c, ProjectCountryRisk__r.BusinessRisk__c, 
                                            ProjectCountryRisk__r.DetentionDiscrimination__c, ProjectCountryRisk__r.KidnapRansom__c, 
                                            ProjectCountryRisk__r.Property__c, AECOMWork__c, PhysicalProject__c, Other__c 
                                            FROM ProjectCity__c 
                                            WHERE Project__c =: oProject.id];

                //system.debug( 'lstProjectCities size 1 => ' + lstProjectCities.size() );

                for(ProjectCity__c p: lstProjectCities){
                        if(p.ProjectCountryRisk__r.Safety_Rating__c > projectRisk){
                                projectRisk = p.ProjectCountryRisk__r.Safety_Rating__c;
                        }                            
                            
                    if(! multipleCountry )
                    {                                       
                        if(( country != null ) && ( country != p.ProjectCountryRisk__r.CountryName__c ) )
                            multipleCountry = true;
                        else
                            multipleCountry = false;
                    }
                    
                    country = p.ProjectCountryRisk__r.CountryName__c;                        
                }
            
                //system.debug( 'lstProjectCities size 2 => ' + lstProjectCities.size() );
        } 

        /**
         * 
         *
         * @Author  NTTD - Shoukat Khan
         * @Date    2016
         *
         * @param   stdController
         * @return  
         **/
        public ECO_ResilienceController (ApexPages.StandardController oStandardController) {

                //US-06752: To avoid addFields error for 'Print Project Plan' button, reset the fields to 
                //call addFields below also as some other calling class could have done addFields too.
                if(!Test.isRunningTest()) {
                    oStandardController.reset();
                }
                
                list<string> lFields = new list<string>();
                lFields.add('OSPApprover__c');
                lFields.add('OSPTitle__c');
                lFields.add('OSPApproved__c');
                lFields.add('OSPComments__c');
                lFields.add('OSPApprovedBy__c');
                lFields.add('OSPDateTimeApproved__c');
                
                if(!Test.isRunningTest()) {
                    oStandardController.addFields(lFields);
                }
                this.oProject = (pse__Proj__c)oStandardController.getRecord();

                bFromSHE = false;

                if(ApexPages.currentPage().getParameters().get('fromSHE') != null){
                    bFromSHE = true;
                }

                projectRisk = 0;
                strAnswer = 'Unknown';

                types = new List<SelectOption>();
                types.add(new SelectOption('No', 'No'));
                types.add(new SelectOption('Yes', 'Yes'));  

                // retrieve all junction objects
                UpdateProjectCities();
        }
    
        /**
         * 
         *
         * @Author  NTTD
         * @Date    2016
         *
         * @param   
         * @return  
         **/
        public void init()
        {
                attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :oproject.Id]);
        }

        /**
         * 
         *
         * @Author  NTTD
         * @Date    2016
         *
         * @param   
         * @return  PageReference 
         **/
        public PageReference selectOption() {
                
                try{
                        update oProject;
                }catch(exception e){
                    
                        ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Unable to select: ' + e);
                        ApexPages.addMessage(oMsg);
                        return null;
                }               

                return null;
        }

        /**
         * 
         *
         * @Author  NTTD
         * @Date    2016
         *
         * @param   
         * @return  PageReference 
         **/
        public PageReference AddCity(){

                if(lstProjectCities.size() > 0){
                    try{
                        update lstProjectCities;
                    }catch(exception e){
                        ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Unable to add new City: ' + e);
                        ApexPages.addMessage(oMsg);
                        return null;
                    }
                }

                string sCity;
                string sState;
                string sCountry;
                id iCountry;

                if (idCityID.length() > 0) {
                        if(idCityID.split('\\,',3).size()==3){
                                list<string> sSplit = idCityID.split('\\,',3);

                                sCity = sSplit[0].trim();
                                sState = sSplit[1].trim();
                                sCountry = sSplit[2].trim();

                                //system.debug('DEBUG***: ' + sCity);

                                list<CountryRisk__c> lstSearchCountryRisk = [select id from CountryRisk__c where (name=:sCountry OR alias__c=:sCountry)];
                                if(lstSearchCountryRisk.size() > 0){
                                        iCountry = lstSearchCountryRisk[0].id;
                                } else {
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Could not find country risk :' + sCountry));
                                        return null;                                    
                                }


                        } else {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid City Format'));
                                return null;                            
                        }

                } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid City Choosen'));
                        return null;
                }


                Savepoint oSavePoint = Database.setSavepoint();

                //Check if primary already exists
                list<ProjectCity__c> lstCitiesToMakeSecondary = new list<ProjectCity__c>([SELECT Id
                                                                                          FROM ProjectCity__c
                                                                                          WHERE Project__c = :oProject.Id ]);
            
                //system.debug( 'lstCitiesToMakeSecondary 112 ' + lstCitiesToMakeSecondary );

                //Check if entry already exists
                list<ProjectCity__c> lstCitiesToMakePrimary = new list<ProjectCity__c>([SELECT Id
                                                                                        , Type__c
                                                                                        , ProjectCountryRisk__c
                                                                                            FROM ProjectCity__c
                                                                                            WHERE Project__c = :oProject.Id and CityName__c=: sCity and ProjectCountryRisk__r.CountryRisk__c=:iCountry] );


                //system.debug('DEBUG: ****' + lstCitiesToMakePrimary.size());

                if(lstCitiesToMakePrimary.size() > 0){

                        try{
                                update lstCitiesToMakePrimary;
                        }catch(EcoControllerException oException){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
                                Database.rollback(oSavePoint);

                                return null;
                        }

                        list<ProjectCountry_Risk__c> lstCountryToMakePrimary = [select id from ProjectCountry_Risk__c where id=:lstCitiesToMakePrimary[0].ProjectCountryRisk__c];

                        if(lstCountryToMakePrimary.size() > 0){

                                try{
                                        update lstCountryToMakePrimary;
                                }catch(EcoControllerException oException){
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
                                        Database.rollback(oSavePoint);

                                        return null;
                                }                               

                        } else {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There are no project countries associated with the project city.'));
                                Database.rollback(oSavePoint);

                                return null;                                    
                        }



                }else{
                        ProjectCountry_Risk__c oProjectCountryToInsert = new ProjectCountry_Risk__c(Project__c = oProject.Id, CountryRisk__c = iCountry, Type__c = 'Primary');
                        ProjectCity__c oProjectCityToInsert = new ProjectCity__c(Project__c = oProject.Id, CityName__c =sCity, State_Name__c=sState, Type__c = 'Primary');

                        try{
                                insert oProjectCountryToInsert;
                                oProjectCityToInsert.ProjectCountryRisk__c = oProjectCountryToInsert.id;
                                insert oProjectCityToInsert;
                        }catch(EcoControllerException oException){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
                                Database.rollback(oSavePoint);

                                return null;
                        }
                }

                //Update project to reflect
                //pse__Proj__c oProjectToUpdate = new pse__Proj__c(Id = oProject.Id, PrimaryCity__c = idCityID);
                oProject.PrimaryCityName__c = sCity;

                try{
                        update oProject;
                }catch(EcoControllerException oException){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
                        Database.rollback(oSavePoint);

                        return null;
                }

                UpdateProjectCities();
                return null;
        }
        
        /**
         * 
         *
         * @Author  NTTD
         * @Date    2016
         *
         * @param   
         * @return  PageReference 
         **/
        public PageReference updateProject(){
            bUpdateProject = true;
            return null;
        }

        /**
         * 
         *
         * @Author  NTTD
         * @Date    2016
         *
         * @param   
         * @return  PageReference 
         **/
        public PageReference SaveSelectedLocations(){

                Savepoint oSavePoint = Database.setSavepoint();
                
                try{
                        if(lstProjectCities.size() > 0 ){
                            update lstProjectCities;
                        }
                        update oProject;
                    
                }catch(EcoControllerException oException){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
                        Database.rollback(oSavePoint);

                        return null;
                }
                

                UpdateProjectCities();
            
                // Send the user back to current page.  
                //PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
                PageReference pageRef = new PageReference('/apex/ECO_Resilience?id='+oProject.Id);
                pageRef.setRedirect(true);
                return pageRef;
                //return null;
        }    
    
        //OSP_Attachment__c
        //

        /**
         * 
         *
         * @Author  NTTD
         * @Date    2016
         *
         * @param   
         * @return  PageReference 
         **/
        public PageReference removeattachment(){
            id iTargetAttachment = sTargetAttachment;
            Attachment aAttachToRemove = attachmentsMap.get(iTargetAttachment);
            attachmentsMap.remove(iTargetAttachment);
            delete aAttachToRemove;
            oProject.OSP_Attachment__c = oProject.OSP_Attachment__c.remove(iTargetAttachment + ';');
            update oProject;
            return null;
        }

        /**
         * 
         *
         * @Author  NTTD
         * @Date    2016
         *
         * @param   
         * @return  Attachment list
         **/
        public list<Attachment> getOSP_AttachmentFiles()
        {
            list<String> attachmentIds = new list<String>();
            if(oproject.OSP_Attachment__c != null)
                            attachmentIds = oproject.OSP_Attachment__c.split(';');
                            
            //system.debug( 'getOSP_AttachmentFiles called' + attachmentIds.size() );

            return getAttachmentListFromIdList(attachmentIds);
        } 
    
        /**
         * 
         *
         * @Author  NTTD
         * @Date    2016
         *
         * @param   
         * @return  
         **/
        public void saveOSP_AttachmentAndProject()
        {
            if(OSP_Attachment.Body != null){

                if(overrideSafetyHealthInspectionName != null && overrideSafetyHealthInspectionName != '')
                    OSP_Attachment.Name = overrideSafetyHealthInspectionName; 

                //system.debug( 'OSP_Attachment ' + OSP_Attachment.Name );
                try{
                    insert OSP_Attachment;
                }catch(exception e){
                        ApexPages.Message oMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Unable to attach file: ' + e);
                        ApexPages.addMessage(oMsg);
                }
                
                
                if(oProject.OSP_Attachment__c != null)
                    oProject.OSP_Attachment__c += OSP_Attachment.Id + ';';
                else
                    oProject.OSP_Attachment__c = OSP_Attachment.Id + ';'; 
                
                update oProject;
                
                attachmentsMap = new Map<Id, Attachment>([select Id, Name, ContentType, LastModifiedDate, LastModifiedById from Attachment where parentId = :oProject.Id]);
                OSP_Attachment = null;
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'A file must be selected in order to attach'));
            }
        }    
    
        /**
         * 
         *
         * @Author  NTTD
         * @Date    2016
         *
         * @param   attachmentIds list
         * @return  Attachment list
         **/
        private list<Attachment> getAttachmentListFromIdList(list<String> attachmentIds)
        {
            //system.debug( 'attachmentIds size ' + attachmentIds.size() );
            
            list<Attachment> attachments = new list<Attachment>();
            for(String attachmentId:attachmentIds)
            {
                    if(attachmentsMap.containsKey(attachmentId) && attachmentId != null && attachmentId != '')
                            attachments.add(attachmentsMap.get(attachmentId));
            }
            
            //system.debug( 'attachments size => ' + attachments.size() );
            
            return attachments;     
        }
    
         /**
         * 
         *
         * @Author  NTTD
         * @Date    2016
         *
         * @param   
         * @return  Attachment 
         **/
        public Attachment newOSP_Attachment
        {
            get
            {
                if(OSP_Attachment==null)
                {
                    OSP_Attachment = new Attachment(parentid = oproject.id);
                }
                return OSP_Attachment;
            }
            set;
        }   
        
        /**
         * 
         *
         * @Author  NTTD
         * @Date    2016
         *
         * @param   
         * @return  PageReference 
         **/
        public PageReference RemoveEntryCity()
        {

                if(lstProjectCities.size() > 0){
                    update lstProjectCities;
                }
                string sCity;
                string sState;
                string sCountry;
                id iCountry;


                if (idCityID.length() > 0) {
                        if(idCityID.split('\\,',3).size()==3){
                                list<string> sSplit = idCityID.split('\\,',3);

                                sCity = sSplit[0].trim();
                                sState = sSplit[1].trim();
                                sCountry = sSplit[2].trim();

                                //system.debug('DEBUG***: ' + sCity);

                                list<CountryRisk__c> lstSearchCountryRisk = [select id from CountryRisk__c where (name=:sCountry OR alias__c=:sCountry)];

                                if(lstSearchCountryRisk.size() > 0){
                                        iCountry = lstSearchCountryRisk[0].id;
                                } else {
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Could not find country risk :' + sCountry));
                                        return null;                                    
                                }


                        } else {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid City Format'));
                                return null;                            
                        }

                } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid City Choosen'));
                        return null;
                }

                Savepoint oSavePoint = Database.setSavepoint();

                //Check if entry already exists
                list<ProjectCity__c> lstCitiesToRemove = new list<ProjectCity__c>([SELECT Id, ProjectCountryRisk__c
                                                                                        FROM ProjectCity__c
                                                                                        WHERE Project__c = :oProject.Id and CityName__c = :sCity and ProjectCountryRisk__r.CountryRisk__c =: iCountry]);

                list<ProjectCountry_Risk__c> lstCountryRiskToRemove;

                if(lstCitiesToRemove.size() > 0){
                        lstCountryRiskToRemove = new list<ProjectCountry_Risk__c>([SELECT Id
                                                                                       FROM ProjectCountry_Risk__c
                                                                                       WHERE id = :lstCitiesToRemove[0].ProjectCountryRisk__c ]);

                } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Attempted to remove a City that does not exist in the system'));
                        Database.rollback(oSavePoint);
                        return null;
                }


                //Update project to reflect if organization is currently primary
                if(oProject.PrimaryCityName__c == sCity){
                        // oProject.PrimaryCity__c = null;

                        try{
                                update oProject;
                        }catch(EcoControllerException oException){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
                                Database.rollback(oSavePoint);

                                return null;
                        }
                }

                try{
                        delete lstCitiesToRemove;

                        if(lstCountryRiskToRemove.size() >0){
                                delete lstCountryRiskToRemove;
                        }

                }catch(EcoControllerException oException){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, oException.getMessage()));
                        Database.rollback(oSavePoint);
                        return null;
                }

                UpdateProjectCities();
                return null;
        }

}