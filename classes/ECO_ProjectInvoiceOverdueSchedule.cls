global class ECO_ProjectInvoiceOverdueSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		ECO_ProjectInvoiceOverdueBatch b = new ECO_ProjectInvoiceOverdueBatch();
		database.executeBatch(b);
	}
}