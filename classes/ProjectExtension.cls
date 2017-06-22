public with sharing class ProjectExtension {

	public Project__c project {get;set;}
	
	/**
	*@description Extension constructor
	*/
	public ProjectExtension(ApexPages.standardController ctl) {
		this.project = (Project__c)ctl.getRecord();
	}
	
	/**
	*@description Empty constructor for initializing from Visualforce Component. (controller=ProjectExtension)
	*/
	public ProjectExtension() {
		
	}
	
	/**
	*@description return true if there is at least 1 "Won" external award for the project
	* Note this extension does not query Awards__r. It depends on it being queried elsewhere or Project__c.Awards__r is referenced on a standardController page
	*/
	public Boolean hasWonAwards {
		get {
			if (project.Awards__r != null && project.Awards__r.size() > 0) {
				for (Awards_Commendations__c awd : project.Awards__r) {
					if (awd.RecordType.DeveloperName=='Awards' && awd.Award_Status__c=='Won' && awd.Internal_Award__c==False) {
						return true; //only need to find one
					}
				}
			}
		
			return false;
		}
	}
	
	/**
	*@description returns true if there is at least 1 PR Contact record attached to the project
	* Note this extension does not query PR_Contacts. It depends on it being queried elsewhere or Project__c.PR_Contacts__r is referenced on a standardController page
	*/
	public Boolean hasReferences {
		get {
			if (project.PR_Contacts__r != null && project.PR_Contacts__r.size() > 0) {
				return true;
			}
			return false;
		}
	}
	
	@isTest (seeAllData=true)
    static void testProjectMerge() {
      // Create the account and contact
        Account acc1=new Account();
        acc1.Name='Test Account1';
        acc1.Type__c='Client';
        acc1.Client_Group__c='Industrial/Commercial';
        acc1.Client_Subgroup__c='Small - population under 500K';
        acc1.Legacy_AccountID__c='1221234';
        acc1.City__c='testCity';
        insert acc1;
        
        Contact con = new Contact(AccountId=acc1.id);
        con.firstName = 'Test';
        con.lastName = 'Test';
        insert con;
        
        
        //Create the Project
        Project__c proj = new Project__c();
        proj.Name='Test';
        proj.Owner__c = acc1.ID;
        proj.Project_Description__c = 'Test';
        insert proj;
        
        //send the new proejct to the ProjectMergeExtension. This ensures Awards and PR Contacts is queried properly
        List<Project__c> projList = new List<Project__c>();
        projList.add(proj);
        ApexPages.standardSetController setCtl = new ApexPages.standardSetController(projList);
        setCtl.setSelected(projList);
        
        ProjectMergeExtension ext = new ProjectMergeExtension(setCtl);
        System.assertEquals(1, ext.selectedProjects.size());
        proj = ext.selectedProjects[0];
        
        //Now instantiate ProjectExtension
        ApexPages.Standardcontroller ctl = new ApexPages.Standardcontroller(proj);
        ProjectExtension ext2 = new ProjectExtension(ctl);
        
        //both checks are false
        System.assertEquals(false, ext2.hasWonAwards);
        System.assertEquals(false, ext2.hasReferences);
        
        //Now create the awards and pr contacts
        Awards_Commendations__c awd = new Awards_Commendations__c();
        awd.Related_Project__c = proj.id;
        awd.Name = 'Test';
        awd.Award_Geography__c = 'Americas';
        awd.Award_Status__c = 'Won';
        awd.Internal_Award__c = false;
        RecordType rt = [SELECT ID FROM RecordType WHERE DeveloperName = 'Awards' AND sObjectType='Awards_Commendations__c' LIMIT 1];
        awd.RecordTypeId = rt.ID;
        insert awd;
        
        PR_Contact__c pr = new PR_Contact__c();
        pr.contact__c = con.ID;
        pr.Contact_Project__c = proj.ID;
        insert pr;       
        
        //clear the collection on ProjectMergeExtension so that it queries the projects again
        ext.selectedProjects = null;
        proj = ext.selectedProjects[0];
        
        //This time the assertions are true
        ProjectExtension ext3 = new ProjectExtension();
        ext3.project = proj;
        System.assertEquals(true, ext3.hasWonAwards);
        System.assertEquals(true, ext3.hasReferences);
        
        
        
    }
	
}