public class ChatterLiveController {
  DateTime NextReload;
  Long SecondsRemaining;
  Integer RefreshIntervalSeconds = 15;
  private ApexPages.StandardController ctrl;
	 public id GroupId{
         get{return (id)ctrl.getRecord().get('id');}
 
     }
 
  public ChatterLiveController (ApexPages.StandardController controller) {
      ctrl = controller;
      NextReload = DateTime.Now().addSeconds(RefreshIntervalSeconds);
      CheckReload();
  }
   
 public PageReference CheckReload() {
     SecondsRemaining = (NextReload.getTime() - DateTime.Now().getTime())/1000;
     if (SecondsRemaining <= 0) {
         PageReference pageRef = new PageReference(getURL());
         pageRef.setRedirect(true);
         return pageRef;
     } else {
         return null;
     }
 }
 public String getNow() {
     return String.ValueOf(DateTime.Now());
 }
 public String getURL() {
     String URL = ApexPages.CurrentPage().GetURL();
     return URL.substring(0,URL.indexOf('?')) + '?id=' + ctrl.getRecord().get('id');
 }
 public Long getSecondsRemaining() {
     return SecondsRemaining;
 }
 public String getNextReloadAt() {
     return String.ValueOf(NextReload);
 }
}