public class ECO_EmailApprovalController{
	public Id targetObjectId { get; set; }

	public String RecalledComment{ get{
			List<ProcessInstanceStep> recalledSteps = [
				SELECT Comments 
				FROM ProcessInstanceStep 
				WHERE ProcessInstance.targetObjectId = :targetObjectId 
					AND StepStatus = 'Removed' 
				ORDER BY SystemModStamp DESC 
				LIMIT 1];
			return recalledSteps.isEmpty() ? null : recalledSteps[0].Comments;
		} }
}