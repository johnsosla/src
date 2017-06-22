/**
 * As of Winter '14 release, email templates used with approval processes can
 * include {!ApprovalRequest.field_name} merge fields.
 * For example, {!ApprovalRequest.Comments} merge field returns the most recently
 * entered comment in emails for an approval step.
 * 
 * This class represents the controller in this workaround solution.
 * Also see ApprovalRequestComments visualforce component.
 * 
 * Inspired by https://developer.salesforce.com/forums/ForumsMain?id=906F00000008xjUIAQ 
 * 
 * http://docs.releasenotes.salesforce.com/en-us/winter14/release-notes/rn_186_forcecom_process_approval_comment_merge_fields.htm
 */
public class ECO_ApprovalRequestCommentsController {

    // ID of the record whose most recent approval process comments to retrieve
    public ID targetObjectId { get; set; }
    
    // The most recent approval process comments
    // Could show in visualforce email template, for example
    public String comments {
        get {
            if ( comments == null ) {
                ProcessInstanceStep lastStep = getLastApprovalStep();
                comments = ( lastStep != null ) ? lastStep.comments : '';
            }
            return comments;
        }
        private set;
    }
    
    public ECO_ApprovalRequestCommentsController() {}
    
    // Queries the most recent approval process step for the target record
    private ProcessInstanceStep getLastApprovalStep() {
        List<ProcessInstanceStep> steps = new List<ProcessInstanceStep>([
            SELECT
                Comments
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