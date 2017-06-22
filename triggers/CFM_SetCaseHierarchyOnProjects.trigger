trigger CFM_SetCaseHierarchyOnProjects on Project__c (before insert, before update) {
	Map<String, CFM_SurveyCaseHierarchy> caseHierarchyMap = CFM_SurveyCaseHierarchy.find.forProjects(
																(List<Project__c>)Trigger.new
															);

	for(Project__c proj : Trigger.new) {
		CFM_SurveyCaseHierarchy hierarchy = CFM_SurveyCaseHierarchy.findRoutingForProject(caseHierarchyMap, proj);
		if(hierarchy != null) {
			proj.Survey_Case_Hierarchy__c = hierarchy.getId();
		}
	}
}