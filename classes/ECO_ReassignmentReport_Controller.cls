/******************************************************************************************************************************
Created By :    Tom Smalara
Date       :    9 Jun 2016
Reason     :    This class is controller for the ECO_ReassignmentReport.page.
*******************************************************************************************************************************/
public class ECO_ReassignmentReport_Controller {
	public boolean bIsRunning {get; set;}

	public void ECO_ReassignmentReport_Controller(){
		bIsRunning = false;
	}

    public void callBatch()
        {
         ECO_ReassignmentReport_Batch b = new ECO_ReassignmentReport_Batch();
         Database.executeBatch(b);
    	 bIsRunning=true;
        }
    
}