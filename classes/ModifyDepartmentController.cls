/************************************************************************************************************
Created By    :    Sumit Mishra(Appirio offshore)
Date          :    20 Aug 2010
Reason        :    This VF page will validate,edit,create,delete Opportunity Departments
**************************************************************************************************************/
public class ModifyDepartmentController {
    public boolean showCancel {get; set;}
    public boolean disabledUpdateOpp {get; set;}
    public integer currentStep {get; set;}
    public static boolean NotRunOpportunityUpdateTrigger = false;
    public static boolean NotRunAccountUpdateTrigger = false;
    public integer rowcount = 0;
    public integer PrimaryRowNumber {get; set;}
    private map<id, string> PAMAp = new map<id, string>();
    private map<id, string> subPAMAp = new map<id, string>();
    private string PrimaryDeptid;
    Public Class Geography {
        Practice_Area_Collection__c thispac;
        public Geography(Practice_Area_Collection__c pac) {
            thispac = pac;
            Name = pac.Business_Line__c + ' ' + pac.Geography__c;
            mapPA = new Map<id, PracticeArea>();
        }
        public string Name{get; set;}
        public Map<id, PracticeArea> mapPA{get; set;}
    }
    Public Class PracticeArea {
        Practice_Area_Collection__c thispac;
        public PracticeArea(Practice_Area_Collection__c pac) {
            thispac = pac;
            Id = pac.Practice_Area__c;
            Name = pac.Practice_Area__r.name;
            mapSPA = new Map<id, SubPracticeArea>();
        }
        public string Name{get; set;}
        public string Id{get; set;}
        public Map<id, SubPracticeArea> mapSPA{get; set;}
    }
    Public Class SubPracticeArea {
        Practice_Area_Collection__c thispac;
        public SubPracticeArea(Practice_Area_Collection__c pac) {
            thispac = pac;
            Id = pac.Sub_Practice_Area__c;
            Name = pac.Sub_Practice_Area__r.name;
        }
        public string Name{get; set;}
        public string Id{get; set;}
    }
    public void fillPracticeAreaAll(set<Id> BusinessLineSet, set<Id>geoGraphySet) {
        for (Practice_Area_Collection__c pac : [Select id, Business_Line__c, Business_Line__r.Name,
                                                Geography__c, Geography__r.name,
                                                Practice_Area__c, Practice_Area__r.name,
                                                Sub_Practice_Area__c, Sub_Practice_Area__r.Name
                                                from Practice_Area_Collection__c where Business_Line__c in :BusinessLineSet
                                                AND Geography__c in :geoGraphySet]) {
            if (mapGeography.get(pac.Business_Line__c + ' ' + pac.Geography__c) == null) {
                mapGeography.put(pac.Business_Line__c + ' ' + pac.Geography__c, new Geography(pac));
            }
            Geography g1 = mapGeography.get(pac.Business_Line__c + ' ' + pac.Geography__c);
            if (g1.mapPA.get(pac.Practice_Area__c) == null) {
                g1.mapPA.put(pac.Practice_Area__c, new PracticeArea(pac));
            }
            PracticeArea p1 = g1.mapPA.get(pac.Practice_Area__c);
            if (pac.Sub_Practice_Area__c != null)
                if (p1.mapSPA.get(pac.Sub_Practice_Area__c) == null) {
                    p1.mapSPA.put(pac.Sub_Practice_Area__c, new SubPracticeArea(pac));
                }
            if (pac.Practice_Area__c != null) {
                PAMAp.put(pac.Practice_Area__c, pac.Practice_Area__r.name);
            }
            if (pac.Sub_Practice_Area__c != null) {
                SubPAMAp.put(pac.Sub_Practice_Area__c, pac.Sub_Practice_Area__r.name);
            }

        }
    }
    public class MyDepartment {
        Map<string, Geography> mapGeography;
        public Opportunity_Department__c dept {get; set;}
        public integer rowNumber {get; set;}
        public string BusinessLine {get; set;}
        public string Geography {get; set;}
        public MyDepartment(Opportunity_Department__c d, Map<string, Geography> mapGeography1, integer rowCount) {
            mapGeography = mapGeography1;
            rowNumber = rowcount;
            dept = d;
        }
        public boolean getisSubAreaDisabled() {
            if (dept.Practice_Area__c == null) {
                return true;
            } else {
                return false;
            }
        }
        public List<SelectOption> getPracticeAreas() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--None--'));
            if (Geography != null && Geography != '')
                if (mapGeography.get(Geography) != null) {
                    List<PracticeArea> lstP = mapGeography.get(Geography).mapPA.values();
                    for (integer i = 0; i < lstP.size(); i++) {
                        for (integer j = i + 1; j < lstP.size(); j++) {
                            if (lstP[i].Name > lstP[j].Name) {
                                PracticeArea pa = lstP[i];
                                lstP[i] = lstP[j];
                                lstP[j] = pa;
                            }
                        }
                    }
                    for (PracticeArea pa : lstP) {
                        options.add(new SelectOption(pa.Id, pa.Name));
                    }
                }
            return options;
        }
        public List<SelectOption> getSubPracticeAreas() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--None--'));
            if (dept.Practice_Area__c != null)
                if (mapGeography.get(Geography) != null) {
                    if (mapGeography.get(Geography).mapPA.get(dept.Practice_Area__c) != null) {
                        List<SubPracticeArea> lstP = mapGeography.get(Geography).mapPA.get(dept.Practice_Area__c).mapSPA.values();
                        for (integer i = 0; i < lstP.size(); i++) {
                            for (integer j = i + 1; j < lstP.size(); j++) {
                                if (lstP[i].Name > lstP[j].Name) {
                                    SubPracticeArea pa = lstP[i];
                                    lstP[i] = lstP[j];
                                    lstP[j] = pa;
                                }
                            }
                        }
                        for (SubPracticeArea pa : lstP) {
                            options.add(new SelectOption(pa.Id, pa.Name));
                        }
                    }
                }
            return options;
        }
    }
    public integer subAreaNumber {get; set;}
    public string PAID {get; set;}
    public void fillSubArea() {
        for (integer i = 0; i < lstDept.size(); i++) {
            if (lstDept[i].rowNumber == subAreaNumber) {
                if (PAID == '') {
                    lstDept[i].dept.Practice_Area__c = null;
                } else {
                    lstDept[i].dept.Practice_Area__c = PAID;
                }
                lstDept[i].dept.Sub_Practice_Area__c = null;
                break;
            }
        }
    }
    public List<MyDepartment> lstDept {get; set;}
    public Opportunity opp {get; set;}
    public ModifyDepartmentController(ApexPages.StandardController std) {
        disabledUpdateOpp = true;
        showCancel = true;
        Opportunity pOpportunity = (Opportunity) std.getRecord();
        string oppId = pOpportunity.Id;
        runNow(oppId);
    }
    public void runNow(string oppId) {
        currentStep = 1;
        opp = [Select id, Name, CurrencyISOCode,
               BL_Distribution__c, PCC_End_Market__c, PCC_Sub_Market__c, StageName, CM_Type__c,
               PDD_D_P_E_Primary_Global_Practice_Line__c, Transportation_Initiatives__c, Services__c, Enterprise_Service__c, Project_Delivery_Method__c, Client_Service_Experience__c, Program_IDIQ_Type__c, Contingent_Liabilities__c, Total_Prime_Contract_Value__c
               from opportunity Where id = :oppId];
        lstDept = new List<MyDepartment>();
        for (Opportunity_Department__c od : [Select id, Revenue_Split_TO_Proj__c, Revenue_Split_Program__c, AECOM_Department__c, Practice_Area__c, Sub_Practice_Area__c, Primary__c, split__c from Opportunity_Department__c where Opportunity__c = :opp.id LIMIT 1000]) {
            MyDepartment md = new MyDepartment(od, mapGeography, rowCount++);
            lstDept.add(md);
            if (od.Primary__c) {
                PrimaryRowNumber = md.rowNumber;
            }
        }
    }
    public ModifyDepartmentController() {
        disabledUpdateOpp = true;
        showCancel = true;
        currentStep = 1;
        PrimaryRowNumber = -1;
        string oppId = ApexPages.currentPage().getParameters().get('oppid');
        if (oppId == '' || oppId == null) {
            oppId = ApexPages.currentPage().getParameters().get('newid');
            showCancel = false;
        }

        opp = [Select id, Name, CurrencyISOCode,
               BL_Distribution__c, PCC_End_Market__c, PCC_Sub_Market__c, StageName, CM_Type__c,
               PDD_D_P_E_Primary_Global_Practice_Line__c, Transportation_Initiatives__c, Services__c, Enterprise_Service__c, Project_Delivery_Method__c, Client_Service_Experience__c, Program_IDIQ_Type__c, Contingent_Liabilities__c, Total_Prime_Contract_Value__c
               from opportunity Where id = :oppId];
        lstDept = new List<MyDepartment>();
        for (Opportunity_Department__c od : [Select Business_Line__c, id, AECOM_Department__c, Primary__c, split__c, Practice_Area__c, Sub_Practice_Area__c from Opportunity_Department__c where Opportunity__c = :opp.id LIMIT 1000]) {
            MyDepartment md = new MyDepartment(od, mapGeography, rowCount++);
            lstDept.add(md);
            if (od.Primary__c) {
                PrimaryRowNumber = md.rowNumber;
            }
        }
        while (lstDept.size() < 5) {
            lstDept.add(new MyDepartment(new Opportunity_Department__c(Opportunity__c = opp.Id), mapGeography, rowCount++));
        }
        if (ApexPages.currentPage().getParameters().get('step') == '2') {
            Save();
        }
    }
    private List<Opportunity_Department__c> lstDelete = new List<Opportunity_Department__c>();
    public void Previous() {
        currentStep = 1;
        while (lstDept.size() < 5) {
            lstDept.add(new MyDepartment(new Opportunity_Department__c(Opportunity__c = opp.Id), mapGeography, rowCount++));
        }
    }
    Map<string, Geography> mapGeography = new Map<string, Geography>();
    public pagereference Save() {
        Set<Id> blSet = new Set<Id>();
        Set<Id> gSet = new Set<Id>();
        List<Opportunity_Department__c> lst = new List<Opportunity_Department__c>();
        integer PrimaryCount = 0;
        Double SplitCount = 0;
        Set<String> deptSet = new Set<String>();
        Set<id> aecomeDeptIdSet = new Set<id>();
        List<MyDepartment> lstMyDeptNew = new List<MyDepartment>();
        opp.AECOM_Department_2__c = null;
        opp.AECOM_Department_2_Percent__c =  0;

        opp.AECOM_Department_2_Practice_Area__c = null;
        opp.AECOM_Department_2_Sub_Practice_Area__c = null;

        opp.AECOM_Department_3__c = null;
        opp.AECOM_Department_3_Percent__c =  0;

        opp.AECOM_Department_3_Practice_Area__c = null;
        opp.AECOM_Department_3_Sub_Practice_Area__c = null;

        opp.AECOM_Department_4__c = null;
        opp.AECOM_Department_4_Percent__c =  0;

        opp.AECOM_Department_4_Practice_Area__c = null;
        opp.AECOM_Department_4_Sub_Practice_Area__c = null;

        opp.AECOM_Department_5__c = null;
        opp.AECOM_Department_5_Percent__c =  0;
        opp.AECOM_Department_5_Practice_Area__c = null;
        opp.AECOM_Department_5_Sub_Practice_Area__c = null;

        opp.AECOM_Department_6__c = null;
        opp.AECOM_Department_6_Percent__c =  0;
        opp.AECOM_Department_6_Practice_Area__c = null;
        opp.AECOM_Department_6_Sub_Practice_Area__c = null;

        integer RegularDeptCount = 2;
        for (MyDepartment od : lstDept) {
            od.dept.CurrencyISOCode = opp.CurrencyISOCode;
            if (PrimaryRowNumber == od.RowNumber) {
                od.dept.Primary__c = true;
            } else {
                od.dept.Primary__c = false;
            }
            if (od.dept.Primary__c == true && od.dept.AECOM_Department__c == null) {
                ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, System.label.IFISPRIMCHK);
                ApexPages.addMessage(msg);
                return null;
            }
            if (od.dept.Primary__c == true) {
                PrimaryCount++;
                PrimaryDeptid = od.dept.AECOM_Department__c;
                opp.AECOM_Primary_Dept_Lookup__c = od.dept.AECOM_Department__c;
                opp.Sub_Practice_Area_of_Primary_AECOM_Dept__c = od.dept.Sub_Practice_Area__c;
                opp.Practice_Area_of_Primary_AECOM_Dept__c = od.dept.Practice_Area__c;
                opp.AECOM_Primary_Department_Percent__c = od.dept.Split__c;
                if (currentStep == 2 && od.dept.Practice_Area__c == null) {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, 'AECOM Work is required for Primary Department.');
                    ApexPages.addMessage(msg);
                    return null;
                }
            }
            if (od.dept.AECOM_Department__c != null) {
                string currentKey = od.dept.AECOM_Department__c;
                if (od.dept.Practice_Area__c != null) {
                    currentKey = currentKey + od.dept.Practice_Area__c;
                }
                if (od.dept.Sub_Practice_Area__c != null) {
                    currentKey = currentKey + od.dept.Sub_Practice_Area__c;
                }
                if (deptSet.contains(currentKey) && currentStep == 2) {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, System.Label.CANNOTADDDUPLIDEPT);
                    ApexPages.addMessage(msg);
                    return null;
                }
                if (od.dept.Split__c == null || od.dept.Split__c == 0) {
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, 'Split % is required.');
                    ApexPages.addMessage(msg);
                    return null;
                }
                aecomeDeptIdSet.add(od.dept.AECOM_Department__c);
                lstMyDeptNew.add(od);
                lst.add(od.dept);
                deptSet.add(currentKey);
                if (od.dept.Split__c != null) {
                    SplitCount = SplitCount + od.dept.Split__c;
                }
                if (!od.dept.Primary__c && currentStep == 2) {
                    if (RegularDeptCount == 2) {
                        opp.AECOM_Department_2__c = od.dept.AECOM_Department__c;
                        opp.AECOM_Department_2_Percent__c =  od.dept.Split__c;
                        if (od.Dept.Practice_Area__c != null) {
                            opp.AECOM_Department_2_Practice_Area__c = paMap.get(od.Dept.Practice_Area__c);
                        }
                        if (od.Dept.Sub_Practice_Area__c != null) {
                            opp.AECOM_Department_2_Sub_Practice_Area__c = subpaMap.get(od.Dept.Sub_Practice_Area__c);
                        }
                    }
                    if (RegularDeptCount == 3) {
                        opp.AECOM_Department_3__c = od.dept.AECOM_Department__c;
                        opp.AECOM_Department_3_Percent__c =  od.dept.Split__c;
                        if (od.Dept.Practice_Area__c != null) {
                            opp.AECOM_Department_3_Practice_Area__c = paMap.get(od.Dept.Practice_Area__c);
                        }
                        if (od.Dept.Sub_Practice_Area__c != null) {
                            opp.AECOM_Department_3_Sub_Practice_Area__c = subpaMap.get(od.Dept.Sub_Practice_Area__c);
                        }
                    }
                    if (RegularDeptCount == 4) {
                        opp.AECOM_Department_4__c = od.dept.AECOM_Department__c;
                        opp.AECOM_Department_4_Percent__c =  od.dept.Split__c;
                        if (od.Dept.Practice_Area__c != null) {
                            opp.AECOM_Department_4_Practice_Area__c = paMap.get(od.Dept.Practice_Area__c);
                        }
                        if (od.Dept.Sub_Practice_Area__c != null) {
                            opp.AECOM_Department_4_Sub_Practice_Area__c = subpaMap.get(od.Dept.Sub_Practice_Area__c);
                        }
                    }
                    if (RegularDeptCount == 5) {
                        opp.AECOM_Department_5__c = od.dept.AECOM_Department__c;
                        opp.AECOM_Department_5_Percent__c =  od.dept.Split__c;
                        if (od.Dept.Practice_Area__c != null) {
                            opp.AECOM_Department_5_Practice_Area__c = paMap.get(od.Dept.Practice_Area__c);
                        }
                        if (od.Dept.Sub_Practice_Area__c != null) {
                            opp.AECOM_Department_5_Sub_Practice_Area__c = subpaMap.get(od.Dept.Sub_Practice_Area__c);
                        }
                    }
                    if (RegularDeptCount == 6) {
                        opp.AECOM_Department_6__c = od.dept.AECOM_Department__c;
                        opp.AECOM_Department_6_Percent__c =  od.dept.Split__c;
                        if (od.Dept.Practice_Area__c != null) {
                            opp.AECOM_Department_6_Practice_Area__c = paMap.get(od.Dept.Practice_Area__c);
                        }
                        if (od.Dept.Sub_Practice_Area__c != null) {
                            opp.AECOM_Department_6_Sub_Practice_Area__c = subpaMap.get(od.Dept.Sub_Practice_Area__c);
                        }
                    }
                    RegularDeptCount++;
                }
            }
        }
        if (PrimaryCount == 0) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, System.Label.ATLEASTONEDEPT);
            ApexPages.addMessage(msg);
            return null;
        }
        if (PrimaryCount > 1) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, System.label.ONLYONEDEPTPRI);
            ApexPages.addMessage(msg);
            return null;
        }
        if (SplitCount <>100) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, System.label.SPLITPER);
            ApexPages.addMessage(msg);
            return null;
        }
        if (currentStep == 1) {
            Map<Id, AECOM_Primary_Department__c> mapDept = new Map<Id, AECOM_Primary_Department__c>([Select id, Business_Line_Lookup__c, Geography_Lookup__c, Geography_Lookup__r.Name, Business_Line_Lookup__r.name from AECOM_Primary_Department__c Where ID in:aecomeDeptIdSet]);
            lstDept = lstMyDeptNew;

            for (MyDepartment od : lstDept) {
                if (mapDept.get(od.dept.AECOM_Department__c) != null) {
                    if (mapDept.get(od.dept.AECOM_Department__c).Business_Line_Lookup__c != null && mapDept.get(od.dept.AECOM_Department__c).Geography_Lookup__c != null) {
                        od.BusinessLine = mapDept.get(od.dept.AECOM_Department__c).Business_Line_Lookup__r.name;
                        od.Geography = mapDept.get(od.dept.AECOM_Department__c).Business_Line_Lookup__c + ' ' + mapDept.get(od.dept.AECOM_Department__c).Geography_Lookup__c;
                        blSet.add(mapDept.get(od.dept.AECOM_Department__c).Business_Line_Lookup__c);
                        gSet.add(mapDept.get(od.dept.AECOM_Department__c).Geography_Lookup__c);
                    }
                }
            }
            fillPracticeAreaAll(blSet, gSet);
            currentStep = 2;
            return null;
        }
        try {
            NotRunOpportunityUpdateTrigger = true;
            update opp;
            NotRunOpportunityUpdateTrigger = false;
            if (lstDelete.size() > 0) {
                delete lstDelete;
            }
            upsert lst;
            return new PageReference('/' + opp.id);
        } catch (Exception ex) {
            //ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR,'Exception:' + ex.getMessage());
            ApexPages.addMessages(ex);
            //ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR,'Click update Opportunity button to edit Oppirtunity');
            //ApexPages.addMessage(msg);
            disabledUpdateOpp = false;
            return null;
        }
    }
    public integer delRowNumber {get; set;}
    /*public pageReference goBackToEditOpportunity()
    {
        string retUrl;
        string retUrl1='';
        string primaryFill = '&CF00N30000004piop_lkid='+PrimaryDeptid;
        for(AECOM_Primary_Department__c ad:[Select Name from AECOM_Primary_Department__c where Id =:PrimaryDeptid])
            primaryFill = primaryFill +'&CF00N30000004piop='+  EncodingUtil.urlEncode(ad.Name,'UTF-8');
        if(showCancel)
        {
            retUrl= EncodingUtil.urlEncode('/apex/ModifyDepartment?oppid='+opp.id+'&step=2','UTF-8');
            retUrl1= EncodingUtil.urlEncode('?oppid='+opp.id+'&step=2','UTF-8');
        }
        else
        {
            retUrl= EncodingUtil.urlEncode('/apex/ModifyDepartment?newid='+opp.id+'&step=2','UTF-8');
            retUrl1= EncodingUtil.urlEncode('?step=2','UTF-8');

        }
        string url = '/'+opp.id+'/e?retURL='+retUrl+'&saveURL=%2Fapex%2FModifyDepartment'+retUrl1+primaryFill;
        return new PageReference(url);
    }*/
    public void deleteRow() {
        for (integer i = 0; i < lstDept.size(); i++) {
            if (lstDept[i].rowNumber == delRowNumber) {
                if (lstDept[i].dept.id != null) {
                    lstDelete.add(lstDept[i].dept);
                }
                lstDept.remove(i);
                break;
            }
        }
    }
    public void addrow() {
        lstDept.add(new MyDepartment(new Opportunity_Department__c(Opportunity__c = opp.Id), mapGeography, rowCount++));
    }
    public pageReference Cancel() {
        return new PageReference('/' + opp.id);
    }

    public pageReference callOppDeptEdit() {
        return new PageReference('/apex/ModifyDepartment?oppid=' + opp.id);
    }

}