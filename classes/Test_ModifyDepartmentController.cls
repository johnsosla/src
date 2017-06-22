/*******************************************************************
  Name        :   Test_ModifyDepartmentController
  Author      :   Appirio Off
  Version     :   1.0 
  Purpose     :   Test Class for ModifyDepartmentController Class
  Date        :   20 Aug, 2010 
********************************************************************/
@isTest
private class Test_ModifyDepartmentController {
    static testMethod void testModifyDepartment(){
        Sub_Practice_Area__c spa = new Sub_Practice_Area__c(Name='subP1');
        insert spa;
        Practice_Area__c pa = new Practice_Area__c(name='pa1');
        insert pa;
        Geography__c geog = new Geography__c(name='pa1');
        insert geog;
        Business_Line__c bl = new Business_Line__c(name='bl');
        insert bl;
        Practice_Area_Collection__c pac= new Practice_Area_Collection__c(Business_Line__c=bl.id,Geography__c=geog.id,Practice_Area__c=pa.id,Sub_Practice_Area__c=spa.id);
        insert pac;
                
        AECOM_Primary_Department__c apd = new AECOM_Primary_Department__c();
        apd.Geography_Lookup__c = geog.Id;
        apd.Business_Line_Lookup__c = bl.id;
        //apd.Lead_District__c = 'Test Destrict';
        apd.Geography__c = 'Test geo';
        apd.Lead_Region__c = 'Test lead';
        insert apd;
        Opportunity op=new Opportunity(Legacy_OpportunityID__c='100');
        op.Name='Test case opportunity';
        op.CloseDate=Date.today().addDays(30);
        op.StageName='Prospecting';
        op.Amount=100;
        op.Win_Probability__c=10;
        op.CloseDate = Date.today().addDays(5);
        op.WinDate__c=Date.today().addDays(-2);
        op.Book_date__c=Date.today().addDays(-1);
        //op.Contract_duration_in_Months__c=2.0;
        op.AECOM_Primary_Dept_Lookup__c=apd.Id;
        op.ValidateGo__c = false;
        op.Enterprise_Service__c = 'Engineering';
        insert op;        
        List<Opportunity_Department__c> lstDepartMent = New List<Opportunity_Department__c>(); 
        Opportunity_Department__c oppDept = new Opportunity_Department__c(Opportunity__c =op.Id,split__c   = 50);
        lstDepartMent.add(oppDept);
        insert lstDepartMent ;        
        
        ApexPages.StandardController ap  = new ApexPages.StandardController(op);      
        ModifyDepartmentController dc1=new ModifyDepartmentController (ap);              
        
        ApexPages.currentPage().getParameters().put('oppid',op.Id);
        
        ModifyDepartmentController dc = new ModifyDepartmentController();
        dc.Save();  
        
        Opportunity_Department__c oppDept1 = new Opportunity_Department__c(Opportunity__c =op.Id);
        lstDepartMent.add(oppDept1);
        Opportunity_Department__c oppDept2 = new Opportunity_Department__c(Opportunity__c =op.Id);
        lstDepartMent.add(oppDept2);
        upsert lstDepartMent ; 
        
        oppDept.Primary__c = true;
        update lstDepartMent;
        dc = new ModifyDepartmentController();
        dc.Save();  
        
        if(dc.lstDept.size() > 1){
          dc.subAreaNumber = 0;
          dc.lstDept[0].dept.AECOM_Department__c = apd.id;
          dc.lstDept[0].dept.split__c   = 45;
          dc.lstDept[0].getPracticeAreas();
          dc.lstDept[0].dept.Practice_Area__c   = pa.id;
          dc.fillSubArea();
          dc.lstDept[0].getSubPracticeAreas();
          dc.lstDept[0].getisSubAreaDisabled();
          
          dc.lstDept[1].dept.primary__c = true;
          dc.lstDept[1].dept.AECOM_Department__c = apd.id;
          dc.save();
        }
        if(dc.lstDept.size() > 2){
          dc.lstDept[1].dept.primary__c = false;
          dc.lstDept[1].dept.AECOM_Department__c = null;
          dc.lstDept[1].dept.Split__c = 60;
          dc.lstDept[2].dept.split__c   = 45;
          dc.save();
        }
        if(dc.lstDept.size() > 1){
            System.debug('--dc lstDept size ---'+dc.lstDept.size()+'--'+dc.lstDept[1].rowNumber);
            dc.delRowNumber = dc.lstDept[1].rowNumber;
            dc.deleteRow();
        }     
        dc.addRow();
        if(dc.lstDept.size() > 2){
          dc.lstDept[1].dept.primary__c = false;
          dc.lstDept[1].dept.AECOM_Department__c = null;
          dc.lstDept[1].dept.Split__c = 25;
          dc.lstDept[2].dept.split__c   =25;
          dc.save();
        } 
        dc.callOppDeptEdit();
        dc.Cancel();
        
    }
}