/*
	Purpose: - Test class for the ECO_ActivityExtension class

	Created By: Aaron Pettitt

	Revision Log:  
	 	v1.0 - (AP 12/04/2015) -- created
*/
@isTest
private class ECO_ActivityExtensionTest {
	
	@isTest static void test_method_one() {
		PageReference pg = Page.ECO_ActivityRecordType;
		pg.getParameters().put('sObject', 'Task');
		pg.getParameters().put('recordType', 'ECO Tasks');
		Test.setCurrentPage(pg);
		ECO_ActivityExtension controller = new ECO_ActivityExtension();
		pg = controller.Redirect();
		//system.assertEquals('/00T/e?nooverride=1&recordType=012e00000009AigAAE&sObject=Task', pg.getUrl());
		pg = Page.ECO_ActivityRecordType;
		pg.getParameters().put('sObject', 'Event');
		Test.setCurrentPage(pg);
		controller = new ECO_ActivityExtension();
		pg = controller.Redirect();
		system.assertEquals(null, pg);
	}

	@isTest static void test_method_two() {
		PageReference pg = Page.ECO_ActivityRecordType;
		pg.getParameters().put('sObject', 'Event');
		pg.getParameters().put('recordType', 'Echo Project Event');
		Test.setCurrentPage(pg);
		ECO_ActivityExtension controller = new ECO_ActivityExtension();
		pg = controller.Redirect();
		//system.assertEquals('/00T/e?nooverride=1&recordType=012e00000009AigAAE&sObject=Task', pg.getUrl());
		pg = Page.ECO_ActivityRecordType;
		pg.getParameters().put('sObject', 'Task');
		pg.getParameters().put('recordType', 'ECOTasks');
		Test.setCurrentPage(pg);
		controller = new ECO_ActivityExtension();
		pg = controller.Redirect();
		system.assert(pg != null);
	}

	@isTest static void test_method_three() {
		PageReference pg = Page.ECO_ActivityRecordType;
		pg.getParameters().put('sObject', 'Event');
		pg.getParameters().put('recordType', 'Echo Project Event');
		Test.setCurrentPage(pg);
		ECO_ActivityExtension controller = new ECO_ActivityExtension();
		pg = controller.Redirect();
		//system.assertEquals('/00T/e?nooverride=1&recordType=012e00000009AigAAE&sObject=Task', pg.getUrl());
		pg = Page.ECO_ActivityRecordType;
		pg.getParameters().put('sObject', 'Task');
		pg.getParameters().put('recordType', 'ECOTasks TEST');
		Test.setCurrentPage(pg);
		controller = new ECO_ActivityExtension();
		pg = controller.Redirect();
		system.assert(pg == null);
	}
}