public class IntranetChatter {
    public String feedID { get; set; } 
    public IntranetChatter() {
        feedID = ApexPages.currentPage().getParameters().get('feedID');
    }
}