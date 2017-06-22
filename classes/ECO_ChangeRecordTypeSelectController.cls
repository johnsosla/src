/** ------------------------------------------------------------------------------------------------------
 * @Description Controller for the ECO_ChangeRecordTypeSelect page.  Page was created since SFDC Translation
 *              workbench does not provide translation on RecordType description field
 *
 * @Author      NTT Data - Scott Mantei
 * @Date        Feb 2017
 *-----------------------------------------------------------------------------------------------------*/
public with sharing class ECO_ChangeRecordTypeSelectController {

    public List<SelectOption> availableRtList           { get; private set; }
    public String selectedRt                            { get; set; }
    public List<RtDescriptionWrapper> rtDescriptionList { get; private set; }

    private String ent;
    private String retURL;
    private String save_new_url;
    private String projectName;
    private String projectId;

    /**
     * constructor - init variables & save command line params
     *
     * @Author  NTT Data - Scott Mantei
     * @Date    Feb 2017
     *
     * @param   controller
     * @return  
     **/
    public ECO_ChangeRecordTypeSelectController() {

        this.ent = ApexPages.currentPage().getParameters().get('ent');
        this.retURL = ApexPages.currentPage().getParameters().get('retURL');
        this.save_new_url = ApexPages.currentPage().getParameters().get('save_new_url');

        System.PageReference save_new_url_pr = new System.PageReference('/' + save_new_url);
        Map<String,String> save_new_url_map = save_new_url_pr.getParameters();

        this.projectName = save_new_url_map.get('CF00Na000000AtFuF');
        this.projectId = save_new_url_map.get('CF00Na000000AtFuF_lkid');

        //load the available RT info
        this.availableRtList = new List<SelectOption>();
        this.rtDescriptionList = new List<rtDescriptionWrapper>();

    }

    /**
     * Get the RT data from metadata and custom labels
     *
     * @Author  NTT Data - Scott Mantei
     * @Date    Feb 2017
     *
     * @param   controller
     * @return  
     **/
    public pageReference startHere() {
        
        
        List<RecordType> availableRecordTypes = ECO_Utils_Meta.GetAvailableRecordTypesForSObject(ChangeManager__c.SObjectType);

        for( RecordType rt : availableRecordTypes){
                this.availableRtList.add(new SelectOption(rt.id, rt.Name));
                this.rtDescriptionList.add( new RtDescriptionWrapper( rt));
        }       

        this.selectedRt = ECO_Utils_Meta.defaultRecordTypeId;
    
        return null;         
    }

    /**
     * constructor - init variables
     *
     * @Author  NTT Data - Scott Mantei
     * @Date    Feb 2017
     *
     * @param   controller
     * @return  
     **/
    public pageReference btnContinue() { 

        PageReference newTask = new PageReference('/apex/ECO_ChangeManagerDetail');
        newTask.getParameters().put('CF00Na000000AtFuF', this.projectName);
        newTask.getParameters().put('CF00Na000000AtFuF_lkid', this.projectId);
        newTask.getParameters().put('scontrolCaching', '1');
        newTask.getParameters().put('retURL', '/apex/ECO_ProjectChangeManager?id=' + this.projectId);
        newTask.getParameters().put('RecordType', this.selectedRt);
        newTask.getParameters().put('ent', this.ent);
        newTask.getParameters().put('save_new', '1');
        newTask.getParameters().put('sfdc.override', '1');
        return newTask;
    }

    /**
     * constructor - init variables
     *
     * @Author  NTT Data - Deborah Orth
     * @Date    Feb 2017
     *
     * @param   controller
     * @return  
     **/
    public pageReference btnCancel() {
        return new pageReference(this.retUrl);
    }

    /** ------------------------------------------------------------------------------------------------------
     * @Description Wrapper class to show RT Name and Description in table
     *
     * @Author      NTT Data - Deborah Orth
     * @Date        Feb 2017
     *-----------------------------------------------------------------------------------------------------*/
    public class RtDescriptionWrapper {
        public String name                      { get; set; }
        public String devName                   { get; set; }
      
        /**
         * constructor - init variables
         *
         * @Author  NTT Data - Deborah Orth
         * @Date    Feb 2017
         *
         * @param   controller
         * @return  
         **/
        public RtDescriptionWrapper( RecordType dbRecord) {
            this.name = dbRecord.Name;
            this.devName = dbRecord.DeveloperName;
        }
    }

}