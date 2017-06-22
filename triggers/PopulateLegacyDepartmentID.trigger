trigger PopulateLegacyDepartmentID on AECOM_Primary_Department__c (before insert, before update) {
  
  // Populate Legacy_DepartmentID__c with the Name of Aecom Department on Insert / Update
  for(AECOM_Primary_Department__c aecomDepartment: Trigger.new){
  	  aecomDepartment.Legacy_DepartmentID__c = aecomDepartment.Name;
  }
}