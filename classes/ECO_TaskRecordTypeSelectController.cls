/** ------------------------------------------------------------------------------------------------------
 * @Description Controller for the ECO_TaskRecordTypeSelect page.  Page was created since SFDC Translation
 *              workbench does not provide translation on RecordType description field
 *
 * @Author      NTT Data - Deborah Orth
 * @Date        Feb 2017
 *-----------------------------------------------------------------------------------------------------*/
public with sharing class ECO_TaskRecordTypeSelectController {

	public List<SelectOption> availableRtList           { get; private set; }
	public String selectedRt                            { get; set; }
	public List<RtDescriptionWrapper> rtDescriptionList { get; private set; }

	private String retUrl;
	private String entity;
	private String whatId;
	private String followUp;
	private String tsk5;

	/**
	 * constructor - init variables & save command line params
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    Feb 2017
	 *
	 * @param   controller
	 * @return  
	 **/
	public ECO_TaskRecordTypeSelectController() {
		//pull these params out of the URL to use later
		this.retUrl = ApexPages.currentPage().getParameters().get('retURL');
		this.entity = ApexPages.currentPage().getParameters().get('ent');
		this.whatId = ApexPages.currentPage().getParameters().get('what_id');
		this.followUp = ApexPages.currentPage().getParameters().get('followUp');
		this.tsk5 = ApexPages.currentPage().getParameters().get('tsk5');

		//load the available RT info
		this.availableRtList = new List<SelectOption>();
		this.rtDescriptionList = new List<rtDescriptionWrapper>();
	}

	/**
	 * Get the RT data from metadata and custom labels
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    Feb 2017
	 *
	 * @param   controller
	 * @return  
	 **/
	public pageReference startHere() {
		
		for( RecordType rt : [SELECT
								id,
								toLabel(Name),
								DeveloperName
							FROM RecordType
							WHERE sObjectType = 'Task'
								AND IsActive = true
							ORDER BY Name]){

			//User's don't have access to this RT, at least not at the time this page was developed
			if( rt.DeveloperName != 'CFM_PM_Review_Task'){
				this.availableRtList.add(new SelectOption(rt.id, rt.Name));
				this.rtDescriptionList.add( new RtDescriptionWrapper( rt));

				//is this the default?
				if( rt.DeveloperName == 'Standard_Tasks'){
					this.selectedRt = rt.Id;
				}
			}							   
		}
		
		return null;		 
	 }

	/**
	 * if the user hits continue then they have selected a RT and we add the params to the URL and send them to a new call log page
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    Feb 2017
	 *
	 * @param   
	 * @return  pageReference
	 **/
	public pageReference btnContinue() { 
		PageReference newTask = new PageReference('/00T/e');

		newTask.getParameters().put('what_id', this.whatId);
		newTask.getParameters().put('followup', this.followUp);
		newTask.getParameters().put('tsk5', this.tsk5);
		newTask.getParameters().put('retURL', this.retUrl);
		newTask.getParameters().put('RecordType', this.selectedRt);
		newTask.getParameters().put('ent', this.entity);

		return newTask;
	}

	/**
	 * if the user hits the cancel button controller returns to retUrl page
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    Feb 2017
	 *
	 * @param   
	 * @return  pageReference
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
		public String devName               	{ get; set; }
	  
		/**
		 * constructor - init variables
		 *
		 * @Author  NTT Data - Deborah Orth
		 * @Date    Feb 2017
		 *
		 * @param   dbRecord
		 * @return  
		 **/
		public RtDescriptionWrapper( RecordType dbRecord) {
			this.name = dbRecord.Name;
			this.devName = dbRecord.DeveloperName;
		}
	}

}