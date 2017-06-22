public class ECO_ApprovalRequestStatusController {

    // ID of the record whose most recent approval process comments to retrieve
    public ID targetObjectId { get; set; }
    
    // The most recent approval process status
    // Could show in visualforce email template, for example
    public String status{
        get {
            if ( status== null ) {
                ProcessInstanceStep lastStep = getLastApprovalStep();
                status = ( lastStep != null ) ? lastStep.StepStatus: '';
            }
            return status;
        }
        private set;
    }
    
    public ECO_ApprovalRequestStatusController() {}
    
    // Queries the most recent approval process step for the target record
    private ProcessInstanceStep getLastApprovalStep() {
        List<ProcessInstanceStep> steps = new List<ProcessInstanceStep>([
            SELECT
                StepStatus 
            FROM
                ProcessInstanceStep
            WHERE
                ProcessInstance.TargetObjectId = :targetObjectId
            ORDER BY
                SystemModStamp DESC
            LIMIT
                1
        ]);
        return ( steps.size() > 0 ) ? steps[0] : null;
    }    
}