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
public class ECO_ApprovalRequestUrlController {

    // ID of the record whose most recent approval process url to retrieve
    public ID targetObjectId { get; set; }
    
    // The most recent approval process url
    // Could show in visualforce email template, for example
    public String url {
        get {
            if ( url == null ) {
                ProcessInstanceWorkitem lastStep = getLastApprovalStep();
                url = ( lastStep != null ) ? System.URL.getSalesforceBaseUrl().toExternalForm() + '/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + lastStep.id : '';
            }
            return url;
        }
        private set;
    }
    
    public ECO_ApprovalRequestUrlController() {}
    
    // Queries the most recent approval process step for the target record
    private ProcessInstanceWorkitem getLastApprovalStep() {
    	List<ProcessInstanceWorkitem> workItems =  new List<ProcessInstanceWorkitem>([
        	SELECT 
				id  
	      	FROM 
				ProcessInstanceWorkitem  
			WHERE 
				ProcessInstance.TargetObjectId = :targetObjectId
            ORDER BY
                SystemModStamp DESC
            LIMIT
                1
			]); 

        /*
        List<ProcessInstanceStep> steps = new List<ProcessInstanceStep>([
            SELECT
                id
            FROM
                ProcessInstanceStep
            WHERE
                ProcessInstance.TargetObjectId = :targetObjectId
            ORDER BY
                SystemModStamp DESC
            LIMIT
                1
        ]);*/
        return ( workItems.size() > 0 ) ? workItems[0] : null;
    }    
}