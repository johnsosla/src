public with sharing class AcctandOpptyTree {

//  Copyright (c) 2010, Erik Lue, Sales Engineering, Salesforce.com Inc.
//  Thanks to Matthew Friend, Garrik Sturges, and Helder Rocha
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
//  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//  Neither the name of the salesforce.com nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. 
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
//  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
//  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


// To adapt this to anouther Object simply search for "Change" to go to the places 
// where the sObject and query must be changed

    //Wrapper class
    public class ObjectStructureMap {

        public String nodeId;
        public Boolean[] levelFlag = new Boolean[]{};
        public Boolean[] closeFlag = new Boolean[]{};
        public String nodeType;
        public Boolean currentNode;
        //
        // Change this to your sObject
        //
        public Account account;
        //
        
        public String getnodeId() { return nodeId; }
        public Boolean[] getlevelFlag() { return levelFlag; }
        public Boolean[] getcloseFlag() { return closeFlag; }
        public String getnodeType() { return nodeType; }
        public Boolean getcurrentNode() { return currentNode; }
        //
        // Change this to your sObject
        //
        public Account getaccount() { return account; }
        //
        
        public void setnodeId( String n ) { this.nodeId = n; }
        public void setlevelFlag( Boolean l ) { this.levelFlag.add(l); }
        public void setlcloseFlag( Boolean l ) { this.closeFlag.add(l); }
        public void setnodeType( String nt ) { this.nodeType = nt; }
        public void setcurrentNode( Boolean cn ) { this.currentNode = cn; }
        //
        // Change this to your sObject
        //
        public void setaccount( Account a ) { this.account = a; }
        //
        //Change this to the second level of the hierarchy
        private list<Opportunity> opplist;
        public list <CustomHelper> customlist	{get; set;}
        //hasStuff is referenced by the Component
        public Boolean hasStuff {get;set;}
        //
        // Change the parameters to your sObject
        //
        public ObjectStructureMap(String nodeId, Boolean[] levelFlag,Boolean[] closeFlag , String nodeType, Boolean lastNode, Boolean currentNode, Account a){
            this.nodeId = nodeId;
            this.levelFlag = levelFlag; 
            this.closeFlag = closeFlag;
            this.nodeType = nodeType;
            this.currentNode = currentNode;
            //
            // Change this to your sObject  
            //
            this.account = a;
            this.opplist = a.Opportunities;
            //
            customlist = new list <CustomHelper>();
            for (Opportunity o: this.opplist){
            	customlist.add(new CustomHelper(o));
            }
            
            if(customlist.Size() > 0)
            	hasStuff = true;
            else
            	hasStuff = false;
        }
    }
    //change declared variables to what you wish to show in the second layer of the hierarchy
    public class CustomHelper{
    	public String oppName		{get;set;}
    	public String oppId			{get;set;}
		public String oppAmount		{get; set;}
		public String oppProb 		{get;set;}
		public String oppCloseDate 	{get;set;}
		public String oppStageName 		{get;set;}
		public String oppOwner {get;set;}
		
		public CustomHelper(Opportunity o){
	//set declared variables from above to corresponding values
			oppName = o.Name;
			oppId = o.Id;
			oppAmount = String.valueOf(o.Amount);
			oppProb = String.valueOf(o.Probability);
			oppCloseDate = String.valueOf(o.CloseDate);
			oppStageName = o.StageName;
			oppOwner = o.Owner.Name;
		}
    }

    // Declare variables
    // 
    public String currentId;
    public List<ObjectStructureMap> asm = new List<ObjectStructureMap>{};
    public Map<String, ObjectStructureMap> masm = new Map<String, ObjectStructureMap>{};
    public List<Integer> maxLevel = new List<Integer>{};
        
    // Allow page to set the current ID
    //
    public void setcurrentId(String cid) {
        currentId = cid;
    }

    // Return ObjectStructureMap to page
    //
    public List<ObjectStructureMap> getObjectStructure(){
        asm.clear();
        if (currentId == null) {
            currentId = System.currentPageReference().getParameters().get('id');
        }
        System.assertNotEquals(currentId,null,'sObject ID must be provided');
        asm = formatObjectStructure(CurrentId);
        return asm;
    }

    // Query Account from top down to build the ObjectStructureMap
    //
    public ObjectStructureMap[] formatObjectStructure(String currentId){
    
        List<ObjectStructureMap> asm = new List<ObjectStructureMap>{};
        masm.clear();
        //
        // Change below
        //
        List<Account> al = new List<Account>{};
        //
        List<ID> currentParent = new List<ID>{};
        Map<ID, String> nodeList = new Map<ID, String>{};
        List<String> nodeSortList = new List<String>{};
        List<Boolean> levelFlag = new List<Boolean>{};
        List<Boolean> closeFlag = new List<Boolean>{};
        String nodeId = '0';
        String nodeType = 'child';
        Integer count = 0;
        Integer level = 0;
        Boolean endOfStructure = false;
        
        // Find highest level obejct in the structure
        //
        currentParent.add(GetTopElement(currentId));

        // Loop though all children
        while (!endOfStructure ){

            if(level==0){
                //
                // Change below
                //        
                al = [SELECT Type, Site, ParentId, OwnerId, Name, Industry, Id,
                (SELECT StageName, Owner.Name, Name, Id, CloseDate, Amount, Probability FROM Opportunities)
                FROM Account WHERE Id IN :CurrentParent ORDER BY Name];
                //
            }
            else {
                //
                // Change below
                //        
                al = [SELECT Type, Site, ParentId, OwnerId, Name, Industry, Id,
                //Second Object to Show 
                (SELECT StageName, Owner.Name, Name, Id, CloseDate, Amount, Probability FROM Opportunities)
                FROM Account WHERE ParentID IN :CurrentParent ORDER BY Name];
                //
            }

            if(al.size() == 0){
                endOfStructure = true;
            }
            else {
                currentParent.clear();
                for (Integer i = 0 ; i < al.size(); i++){
                    //
                    // Change below
                    //
                    Account a = al[i];
                    //
                    if (level > 0){
                        nodeId=NodeList.get(a.ParentId)+'.'+String.valueOf(i);
                    }
                    else {
                        nodeId=String.valueOf(i);
                    }
                    masm.put( NodeID, new ObjectStructureMap(nodeID,levelFlag,closeFlag,nodeType,false,false,a));
                    currentParent.add(a.id);
                    nodeList.put(a.id,nodeId);
                    nodeSortList.add(nodeId);
                }
                maxLevel.add(level);                
                level++;
            }
            
        }
        
        // Account structure must now be formatted
        //
        
        NodeSortList.sort();
        for (Integer i = 0; i < NodeSortList.size();i++){
            List<String> pnl = new List<String> {};
            List<String> cnl = new List<String> {};
            List<String> nnl = new List<String> {};
            
            if (i > 0){
                String pn = NodeSortList[i-1];
                pnl = pn.split('\\.',-1);
            }

            String cn = NodeSortList[i];
            cnl = cn.split('\\.',-1);

            if (i < NodeSortList.size()-1){
                String nn = NodeSortList[i+1];
                nnl = nn.split('\\.',-1);
            }
            ObjectStructureMap tasm = masm.get(cn);
            if (cnl.size() < nnl.size()){
                //Parent
                if (isLastNode(cnl)){
                    tasm.nodeType='parent_end';
                }
                else {
                    tasm.nodeType='parent';
                }
            }
            else if (cnl.size() > nnl.size()){
                tasm.nodeType='child_end';
                tasm.closeFlag=setcloseFlag(cnl, nnl, tasm.nodeType);
            }
            else {
                tasm.nodeType='child';
            }
            tasm.levelFlag = setlevelFlag(cnl, tasm.nodeType); 
            //
            // Change below
            //
            if (tasm.account.id == currentId) {
                tasm.currentNode=true;
            }
            //
            asm.add(tasm);
        }
        asm[0].nodeType='start';
        asm[asm.size()-1].nodeType='end';
        
        return asm;
    }
    
    // Determin parent elements relationship to current element
    //
    public List<Boolean> setlevelFlag(List<String> nodeElements, String nodeType){
        List<Boolean> flagList = new List<Boolean>{};
        String searchNode = '';
        String workNode = '';
        Integer cn = 0;
            for(Integer i = 0; i < nodeElements.size()-1;i++){
                cn = Integer.valueOf(nodeElements[i]);
                cn++;
                searchNode=workNode + String.valueOf(cn);
                workNode=workNode + nodeElements[i] + '.';
                if (masm.containsKey(searchNode)){
                    flagList.add(true);
                }
                else {
                    flagList.add(false);
                }
            }
        return flagList;
    }
    
    // Determin if the element is a closing element
    //
    public List<Boolean> setcloseFlag(List<String> cnl, List<String> nnl, String nodeType){
        List<Boolean> flagList = new List<Boolean>{};
        String searchNode = '';
        String workNode = '';
        Integer cn = 0;
        for(Integer i = nnl.size(); i < cnl.size();i++){
                    flagList.add(true);
        }
        return flagList;
    }

    // Determin if Element is the bottom node
    //    
    public Boolean isLastNode(List<String> nodeElements){
        String searchNode = '';
        Integer cn = 0;
        for(Integer i = 0; i < nodeElements.size();i++){
            if (i == nodeElements.size()-1){
                cn = Integer.valueOf(nodeElements[i]);
                cn++;
                searchNode=searchNode + String.valueOf(cn);
            }
            else {
                searchNode=searchNode + nodeElements[i] + '.';
            }
        }
        if (masm.containsKey(searchNode)){
            return false;
        }
        else{
            return true;
        }
    }

    // Find the tom most element in Heirarchy
    //    
    public String GetTopElement(String objId) {
        Boolean top = false;
        while (!top) {
            //
            // Change below
            //
            Account a = [Select a.id, a.ParentId From Account a where a.id = :objId LIMIT 1];
            //
            
            if (a.ParentId != null) {
                objId = a.ParentID;
            }
            else {
                top=true;
            }
        }
        return objId;
    }
    
	public static testMethod void testAdd() {
        //Primary Department
        AECOM_Primary_Department__c primaryDept;
        List<AECOM_Primary_Department__c> departments;

        departments = [SELECT Lead_Region__c FROM AECOM_Primary_Department__c WHERE Name = 'test Lead Region' LIMIT 1];
        if(departments.size() == 0){
            primaryDept = new AECOM_Primary_Department__c(Lead_Region__c = 'test Lead Region');
            insert primaryDept;
        }
        else{
            primaryDept = departments[0];
        }
		
		Account masterAcct = new Account(Name='test');
		insert masterAcct;
		
		Account childAcct = new Account();
		childAcct.Name= 'test1';
		childAcct.ParentID = masterAcct.Id; 
		insert childAcct;

		Opportunity testOpp = new Opportunity();
		testOpp.Name = 'testOpp';
		testOpp.CloseDate= Date.Today();
		testOpp.StageName = 'Closed Won'; 
		testOpp.OwnerId= UserInfo.getUserId();
		testOpp.AccountId = masterAcct.id;
		testOpp.Amount = 2;
        testOpp.Subs_Other_Revenue__c = 5.5;
        testOpp.Estimated_work_start_date__c = Date.today().addDays(90);
        testOpp.TO_Procurement_Method__c = 'Competitive Task Orders';
        testOpp.Enterprise_Service__c = 'Engineering';
        testOpp.AECOM_Primary_Dept_Lookup__c = primaryDept.Id;
        testOpp.WinDate__c = Date.today().addDays(-90);
		insert testOpp;

		Opportunity testOpp2 = new Opportunity();
		testOpp2.Name = 'testOpp2';
		testOpp2.CloseDate= Date.Today();
		testOpp2.StageName = 'Closed Won';
		testOpp2.AccountId = childAcct.id;
		testOpp2.OwnerId= UserInfo.getUserId();
		testOpp2.Amount = 3;
        testOpp2.Subs_Other_Revenue__c = 5.5;
        testOpp2.Estimated_work_start_date__c = Date.today().addDays(90);
        testOpp2.TO_Procurement_Method__c = 'Competitive Task Orders';
        testOpp2.Enterprise_Service__c = 'Engineering';
        testOpp2.AECOM_Primary_Dept_Lookup__c = primaryDept.Id;
        testOpp2.WinDate__c = Date.today().addDays(-90);
		insert testOpp2;		
		
		CustomHelper th = new CustomHelper(testOpp);
		System.assert(th.oppName == 'testOpp');
		
			/*pageReference p = Page.TaskCreatorCon;
            p.getParameters().put('rec', testCon1.id );
           
            test.setCurrentPage( p );
           
            bulkTaskAddContacts controller = new bulkTaskAddContacts();
            controller.theTask[0].subject ='test';
            controller.theTask[0].OwnerId = UserInfo.getUserId();
            controller.theTask[0].WhoId = testCon1.Id;
            controller.theTask[0].ActivityDate = Date.Today();
            controller.theTask[0].Description = 'test';    
            controller.save();
            controller.cancel();*/
	}

}