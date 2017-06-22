public class ECOM_RecentRecordsComponentController {
	@AuraEnabled
    public static List<RecentlyViewed> getRecords() {
        return [Select Id, Name, Type
                From RecentlyViewed
                Where LastViewedDate != null
               	Order By LastViewedDate DESC
                Limit 10];
    }

}