/*
*    @Author : Avi (avidev9@gmail.com)
*    @Description : Controller class to generate random nums for tab id
*    @Created Date : 5 - May - 2013
*    @Blog : http://blogforce9.blogspot.in/
*    @Revision :
*                  1. 30-Sep-2013 : Minor bug fixes, which wont allow to generate the tabs properly
**/
public class Tab_Con {
    
    public Integer randomSuffix{get;set;}
    
    public Tab_Con(){
        randomSuffix = getRandomNumber(1000000);
    }
    
    private Integer getRandomNumber(Integer size){
        Double d = Math.random() * size;
        return d.intValue();
    }
    
    static testMethod void testCon(){
        Tab_Con controller = new Tab_Con ();
        System.assertNotEquals(Null,controller.randomSuffix);
    }
    
}