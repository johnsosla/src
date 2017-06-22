public with sharing class AcctandResponseTree {

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
        private list<CFM_Survey_Response__c> responselist;
        public list <CustomHelper> customlist   {get; set;}
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
            this.responselist = a.NPS_Survey_Responses__r;
            //
            customlist = new list <CustomHelper>();
            for (CFM_Survey_Response__c r: this.responselist){
                customlist.add(new CustomHelper(r));
            }
            
            if(customlist.Size() > 0)
                hasStuff = true;
            else
                hasStuff = false;
        }
    }
    //change declared variables to what you wish to show in the second layer of the hierarchy
    public class CustomHelper{
        public String responseName      {get;set;}
        public String responseId            {get;set;}
        public String responseLikelihoodtoRecommend     {get; set;}
        public String responseClientComment         {get;set;}
        public String responseProject   {get;set;}
        public String responseSurveyReceivedDate        {get;set;}
        //public String responseProjectNumber       {get;set;}
        public String responseSatisfactionHealthSafety        {get;set;}
        public String responseRequestforcontact        {get;set;}
        public String responseAccount        {get;set;}
        
        public CustomHelper(CFM_Survey_response__c r){
    //set declared variables from above to corresponding values
            responseName = r.Name;
            responseId = r.Id;
            responseLikelihoodtoRecommend = String.valueOf(r.Likelihood_to_Recommend__c);
            responseClientComment = r.Client_Comment__c;
            responseProject = r.Project__r.Name;
            responseSurveyReceivedDate = String.valueOf(r.Survey_Received_Date__c);
           // responseProjectNumber = r.Project__r.Oracle_Project_Number__c;
            responseSatisfactionHealthSafety = String.valueOf(r.Satisfaction_Health_Safety__c);
            responseRequestforcontact = r.Request_for_Contact__c;
            responseAccount = r.Account__r.name;
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
                al = [SELECT Type, Site, ParentId, OwnerId, Name, Industry, Id, NPS_Score_NUM__c,
                (SELECT Name, ID, Likelihood_to_Recommend__c, Client_Comment__c, Project__r.Name, Survey_Received_Date__c, Project__r.Oracle_Project_Number__c, Satisfaction_Health_Safety__c, Request_for_Contact__c, Account__r.name  FROM NPS_Survey_Responses__r)
                FROM Account WHERE Id IN :CurrentParent ORDER BY Name];
                //
            }
            else {
                //
                // Change below
                //        
                al = [SELECT Type, Site, ParentId, OwnerId, Name, Industry, Id, NPS_Score_NUM__c,
                //Second Object to Show 
                (SELECT Name, ID, Likelihood_to_Recommend__c, Client_Comment__c, Project__r.Name, Survey_Received_Date__c, Project__r.Oracle_Project_Number__c, Satisfaction_Health_Safety__c, Request_for_Contact__c, Account__r.name FROM NPS_Survey_Responses__r)
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
            Account a = [Select a.id, a.ParentId, a.NPS_Score_NUM__c From Account a where a.id = :objId LIMIT 1];
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
    }