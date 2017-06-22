public with sharing class INC_EnrollmentParticipantEntryController {

    public EnrollmentPlan__c oEnrollmentPlan {get;set;}
    public ID enrollID {get;set;}
    public list<CommentWrapper> listParticipant {get;set;}
    public list<CommentWrapper> listParticipantDelete {get;set;}
    public String partComments {get;set;}
    public Boolean editParticipants {get;set;}
    public Boolean bChangeRequest{get;set;}
    public String fromWizard{get;set;}
    public Boolean bPaidAndEnrolled{get;set;}
    public Boolean bPaid{get;set;}
    public Boolean bTMorFixed{get;set;}
    public Boolean bFixed{get;set;}
    public Boolean bTM{get;set;}
    public Boolean bEnableCCR{get;set;}
    public String sIssues{get;set;}

    public integer rowNumber {get;set;}
    private Enrollment_Comments__c Enrollmentcomment;
    public INC_EnrollmentParticipantEntryController(){

        bFixed = false;
        bTM = false;

        enrollID = ApexPages.CurrentPage().getParameters().get('id');
        oEnrollmentPlan = INC_Service_EnrollmentPlan.getEnrollmentPlan(new set<id>{enrollID})[0];
        setUpPage();

        bEnableCCR = false;
        if(oEnrollmentPlan.ApplicationType__c == 'CCR'){
            bEnableCCR = true;
        }

        /*if(oEnrollmentPlan.ContractType__c == 'AMPS - Fixed Price'  || 
            oEnrollmentPlan.ContractType__c == 'CPFF - Hard Bid' || 
            oEnrollmentPlan.ContractType__c == 'CPFF - Negotiated' || 
            oEnrollmentPlan.ContractType__c == 'Unassigned'
            ){
            bTMorFixed = false;
        } else {
            bTMorFixed = true;
        }*/

        bTMorFixed = true;
        
        if(oEnrollmentPlan.IncentivePlan__r.ContractType__c == 'Fixed Price'){
            bFixed = true;
        } else if (oEnrollmentPlan.IncentivePlan__r.ContractType__c == 'Time & Material'){
            bTM = true;
        }            
        

        
    }

    public INC_EnrollmentParticipantEntryController(ApexPages.StandardController stdController) {
        System.Debug(logginglevel.error,'Start Controller ' + System.Now());
        oEnrollmentPlan = (EnrollmentPlan__c)stdController.getRecord();
        oEnrollmentPlan = INC_Service_EnrollmentPlan.getEnrollmentPlan(new set<id>{oEnrollmentPlan.id})[0];
        setUpPage();
    }


    private void setUpPage(){
        editParticipants = true;
        if(oEnrollmentPlan.EnrollmentStatus__c == 'Enrolled' ||
           oEnrollmentPlan.EnrollmentStatus__c == 'Archived'){
            editParticipants = false;
        }
        if(oEnrollmentPlan.Name.StartsWith('CCR')){
            bChangeRequest = true;
           // editParticipants = false;
        }else{
            bChangeRequest = false;
        }
        System.Debug(logginglevel.error,'Start loadExistingParticipants ' + System.Now());

        loadExistingParticipants();
        System.Debug(logginglevel.error,'Start addblankRows ' + System.Now());
        addblankRows();
        System.Debug(logginglevel.error,'End Controller ' + System.Now());

        if(oEnrollmentPlan.ApplicationType__c == 'PAY'){
            bPaid = true;
            if(oEnrollmentPlan.EnrollmentStatus__c == 'Enrolled'){
                bPaidAndEnrolled = true;
            } else {
                bPaidAndEnrolled = false;
            }
        } else {
            bPaid = false;
        }

        listParticipantDelete = new list<CommentWrapper>();
        setIssues();
    }
    private void setIssues(){

        System.Debug(logginglevel.error,'issues: ' + oEnrollmentPlan.AppIicationIssues__c);
        System.Debug(logginglevel.error,'issues2: ' + oEnrollmentPlan.ApplicationIssues2__c);
       sIssues ='';
       if(oEnrollmentPlan.AppIicationIssues__c != null){
          sIssues = oEnrollmentPlan.AppIicationIssues__c;
        } 
        if(oEnrollmentPlan.ApplicationIssues2__c != null){ 
          if(sIssues != null){
            sIssues += oEnrollmentPlan.ApplicationIssues2__c;
          }else{
            sIssues = oEnrollmentPlan.ApplicationIssues2__c;
          }
        }
        System.Debug(logginglevel.error,'sIssues: ' + sIssues);
    }
    private void addblankRows(){
        Integer iSize = 0;

        if(oEnrollmentPlan.ApplicationType__c == 'PAY'){
            if(listParticipant != null && listParticipant.size() > 0){
                iSize = listParticipant.size();
            }else{
                listParticipant = new list<CommentWrapper>();
            }

            //listParticipant.add(new EnrollmentParticipant__c(EnrollmentPlan__c = oEnrollmentPlan.ID, ParticipantType__c = 'Discretionary'));
            /*if(iSize > = 5){
                listParticipant.add(new EnrollmentParticipant__c(EnrollmentPlan__c = oEnrollmentPlan.ID, ParticipantType__c = 'Discretionary'));
            }else{
                for(Integer i = iSize; i<5; i++){
                    listParticipant.add(new EnrollmentParticipant__c(EnrollmentPlan__c = oEnrollmentPlan.ID, ParticipantType__c = 'Discretionary'));
                }
            }         */   
        }

        else if (oEnrollmentPlan.EnrollmentStatus__c != 'Enrolled'){
            if(listParticipant != null && listParticipant.size() > 0){
                iSize = listParticipant.size();
            }else{
                listParticipant = new list<CommentWrapper>();
            }
            if(iSize > = 5){
                if(oEnrollmentPlan.ApplicationType__c != 'CCR'){
                  listParticipant.add(new CommentWrapper(new EnrollmentParticipant__c(EnrollmentPlan__c = oEnrollmentPlan.ID,ExistedAtEnrollment__c='Yes', ParticipantType__c = oEnrollmentPlan.ApplicationType__c=='ENR'?'Incentive':'Discretionary'),oEnrollmentPlan));
                }else{
                    listParticipant.add(new CommentWrapper(new EnrollmentParticipant__c(EnrollmentPlan__c = oEnrollmentPlan.ID,ExistedAtEnrollment__c = 'No'),oEnrollmentPlan));
                }
            }else{
                for(Integer i = iSize; i<5; i++){
                    if(oEnrollmentPlan.ApplicationType__c != 'CCR'){
                        listParticipant.add(new CommentWrapper(new EnrollmentParticipant__c(EnrollmentPlan__c = oEnrollmentPlan.ID,ExistedAtEnrollment__c='Yes', ParticipantType__c = 'Incentive'),oEnrollmentPlan));
                    }else{
                        listParticipant.add(new CommentWrapper(new EnrollmentParticipant__c(EnrollmentPlan__c = oEnrollmentPlan.ID,ExistedAtEnrollment__c = 'No'),oEnrollmentPlan));
                    }
                }
            }
        } 
    }

    private void loadExistingParticipants(){
        System.Debug(logginglevel.error,'Particpants load: ' + oEnrollmentPlan.ID);
        listParticipant = new list<CommentWrapper>();
        map<id,List<EnrollmentParticipant__c>> mapEnrollmentParticipants = INC_Service_EnrollmentPlan.getPlanParticipants(new set<id>{oEnrollmentPlan.id});
        System.Debug(logginglevel.error,'parts: ' + mapEnrollmentParticipants);
        for(List<EnrollmentParticipant__c> lpart: mapEnrollmentParticipants.Values()){
            for(EnrollmentParticipant__c part: lpart){
                System.Debug(logginglevel.error,'part: ' + part + ' ' + oEnrollmentPlan);
                listParticipant.add(new CommentWrapper(part,oEnrollmentPlan));
            }
        }
        //listParticipant = mapEnrollmentParticipants.get(oEnrollmentPlan.Id);
    }

    public void addBlankRow(){
        System.Debug(logginglevel.error,'listParticipant.size '+ listParticipant.size());
        //if(listParticipant[listParticipant.size()-1].EmployeeName__c != null){
         if(oEnrollmentPlan.ApplicationType__c == 'PAY'){
            listParticipant.add(new CommentWrapper(new EnrollmentParticipant__c(EnrollmentPlan__c = oEnrollmentPlan.ID, ParticipantType__c = 'Discretionary',ExistedAtEnrollment__c='No'),oEnrollmentPlan));
         }
         else if(oEnrollmentPlan.ApplicationType__c == 'CCR'){
              listParticipant.add(new CommentWrapper(new EnrollmentParticipant__c(EnrollmentPlan__c = oEnrollmentPlan.ID, ExistedAtEnrollment__c='No'),oEnrollmentPlan));
            } else if (oEnrollmentPlan.EnrollmentStatus__c != 'Enrolled'){
            listParticipant.add(new CommentWrapper(new EnrollmentParticipant__c(EnrollmentPlan__c = oEnrollmentPlan.ID),oEnrollmentPlan));
         }
         
        //}
        System.Debug(logginglevel.error,'listParticipant.size after'+ listParticipant.size());
    }

    public void addParticipant(){
        listParticipant.add(new CommentWrapper(new EnrollmentParticipant__c(EnrollmentPlan__c = oEnrollmentPlan.ID),oEnrollmentPlan));
    }

    public pageReference Cancel(){
        return getReturnPage();
    }

    public pageReference SaveAndContinue(){


        if(!save()){
            return null;
        }
        

        if(partComments != null && partComments.length() > 0){
                createEnrollmentComments();
        }
          
        return getReturnPage();
    }

    public pageReference SaveandRecalc(){
        System.debug('save and recalc');
        save();

        if(partComments != null && partComments.length() > 0){
                createEnrollmentComments();
        }

        //return getReturnPage(); // Need to refresh page to fix issue I-1059. Temporary fix
        return null;
    }

    public boolean save(){
        list<EnrollmentParticipant__c> lSave = prepareForSave();

        if(!validate(lSave)){
            return false;
        }

        System.savePoint sp = Database.setSavePoint();
        try{
            upsert lSave;
            System.Debug(logginglevel.error,'Saved participant');
            if(listParticipantDelete.size() > 0){
                list<EnrollmentParticipant__c> lDelete = new list<EnrollmentParticipant__c>();
                for(CommentWrapper cm: listParticipantDelete){
                    lDelete.add(cm.participant);
                }
                delete lDelete;
                listParticipantDelete = new list<CommentWrapper>();
            }


            loadExistingParticipants();
            addblankRows();
            oEnrollmentPlan = INC_Service_EnrollmentPlan.getEnrollmentPlan(new set<id>{enrollID})[0];
            setIssues();
            //DTWINCEPECSAVESUCCESS
            if(oEnrollmentPlan.ApplicationType__c == 'ENR' && oEnrollmentPlan.UnallocatedPercent__c < 40){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,'You have allocated more than the recommended maximum 60% of the incentive pool, which will require exception approval.'));
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,LABEL.DTWINCEPECSAVESUCCESS));
        }catch(Exception e){
            system.debug('Handling Exception:  '+e.getMessage());
            Database.rollBack(sp);
            ApexPages.addMessages(e);
            return false;
        }

        return true;
    }

    public void createEnrollmentComments(){
       if(Enrollmentcomment == null){
            Enrollmentcomment = new Enrollment_Comments__c(EnrollmentApplication__c = oEnrollmentPlan.ID);
        }
        if(Enrollmentcomment.Comments__c != partComments){
            Enrollmentcomment.comments__c = partComments;
            Enrollmentcomment.Type__c = 'Participant';
            System.savePoint sp = Database.setSavePoint();
            try{

                upsert Enrollmentcomment;
            }catch(Exception e){
                system.debug('Handling Exception:  '+e.getMessage());
                Database.rollBack(sp);
                ApexPages.addMessages(e);
            }
        }
    }

    private boolean validate(list<EnrollmentParticipant__c>lSave){

        decimal pool = null;
        if(bTM){
            pool = oEnrollmentPlan.EstimatedPoolBaseline10__c;
        }
        if(bFixed){
            pool = oEnrollmentPlan.EstimatedPoolBaseline__c;
        }


        for(EnrollmentParticipant__c oEnrollmentParticipant: lSave){
            if(oEnrollmentParticipant.CurrencyIsoCode == null){
                oEnrollmentParticipant.CurrencyIsoCode = oEnrollmentParticipant.CurrencyIsoCode;
            }
            if(oEnrollmentParticipant.ParticipantCategory__c == null){
                //LABEL.DTWINCEPECALLPARTCATERR
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'All Participants must have a Participant Category assigned.'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,LABEL.DTWINCEPECALLPARTCATERR));
                return false;
            }
            if((oEnrollmentParticipant.TargetIncentivePoolAllocated__c == null || oEnrollmentParticipant.TargetIncentivePoolAllocated__c < 0) && (oEnrollmentParticipant.ParticipantType__c != 'Discretionary' && oEnrollmentPlan.ApplicationType__c == 'ENR')){
                //LABEL.DTWINCEPECALLPARTGTZERO
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'All Participants must have an allocation greater than 0'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,LABEL.DTWINCEPECALLPARTGTZERO));
                return false;
            }

            if(bTM || bFixed){
                if(oEnrollmentPlan.ApplicationType__c != 'Pay'){
                    System.Debug(logginglevel.error,'Pool: ' + pool + ' ' + oEnrollmentParticipant.TargetIncentivePoolAllocated__c);
                    System.Debug(logginglevel.error, 'value: ' + (oEnrollmentParticipant.TargetIncentivePoolAllocated__c * pool/100));
                    if((((oEnrollmentParticipant.TargetIncentivePoolAllocated__c * pool/100) < oEnrollmentPlan.MinParticipantPayout__c)) && oEnrollmentPlan.ApplicationType__c == 'ENR'){
                        //LABEL.DTWINCEPECALLPARGTMIN
                        //LABEL.DTWINCEPECALLPARGTMIN2
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'All Participants estimated payout must be >= $' + oEnrollmentPlan.MinParticipantPayout__c + ', Currently: $' + oEnrollmentParticipant.TargetIncentivePoolAllocated__c * pool/100));
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,LABEL.DTWINCEPECALLPARGTMIN + oEnrollmentPlan.MinParticipantPayout__c + ', ' + LABEL.DTWINCEPECALLPARGTMIN2 + oEnrollmentParticipant.TargetIncentivePoolAllocated__c * pool/100));
                        return false;
                    }
                    // Ram Kalagara 01/05/2017. Commented out code. I-1890
                    //if((0.6 * pool < oEnrollmentPlan.MinParticipantPayout__c) && oEnrollmentPlan.ApplicationType__c == 'ENR'){
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Current % complete on this project does not allow for a sample pool. Please reach out to your regional DTW admin ' + oEnrollmentPlan.IPDTWAdmin__c + ' for assistance in proposing enrollment.'));
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,LABEL.DTWINCEPECPCTCOMPPOOL + ' ' + oEnrollmentPlan.DTWAdmin__r.Email ));
                        //return false;
                    //}
                }
            }

            if(oEnrollmentParticipant.EmployeeName__c == null){
                //LABEL.DTWINCEPECALLPARTEMP
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'All Participants must have an employee name'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,LABEL.DTWINCEPECALLPARTEMP));
                return false;
            }

        }

        return true;
    }

    public PageReference RemoveEP(){
        CommentWrapper cw = listParticipant[rowNumber-1];

        if(cw.participant.id != null){
            listParticipantDelete.add(cw);
        }

        listParticipant.remove(rowNumber-1);

        return null;

    }

    private pageReference getReturnPage(){
        PageReference Enroll = new pageReference('/apex/INC_EnrollmentApp?id=' + oEnrollmentPlan.id);
        Enroll.setRedirect(true);
        return Enroll;
    }

    private list<EnrollmentParticipant__c> prepareForSave(){
        list<EnrollmentParticipant__c> lReturn = new list<EnrollmentParticipant__c>();
        for(CommentWrapper oWrapper: listParticipant){
            System.Debug(logginglevel.error,'Enrollment plan: ' + oWrapper.participant.EnrollmentPlan__c);
            System.Debug(logginglevel.error,'EmployeeName__c: ' + oWrapper.participant.EmployeeName__c);
            if(oWrapper.participant.EmployeeName__c != null){
                oWrapper.participant.CurrencyIsoCode = oEnrollmentPlan.CurrencyIsoCode;
                lReturn.add(oWrapper.participant);
            }
        }

        return lReturn;
    } 

    public class CommentWrapper{
        public boolean bEnableEmpName{get;set;}
        public boolean bCCREnabledField{get;set;}
        public boolean bPaymentEnabledField{get;set;}
        public boolean bStartDateEnabled{get;set;}
        public boolean bPaymentDateEnabled{get;set;}
        public boolean bEndDateEnabled{get;set;}
        public EnrollmentParticipant__c participant{get;set;}

        public CommentWrapper(EnrollmentParticipant__c oParticipant,EnrollmentPlan__c oEnrollmentPlan){
            participant = oParticipant;
            participant.CurrencyIsoCode = oEnrollmentPlan.CurrencyIsoCode;
            setfieldEnabled(oEnrollmentPlan);
        }

        private void setfieldEnabled(EnrollmentPlan__c oEnrollmentPlan){
             /*Employee name should be enabled in the following.
                1. Unenrolled ENR application
                2. Payment App wait Discrtionary payment type
                3. CCR App with ExistedAtEnrollment = 'NO'
            */
            bEnableEmpName = true;
            bCCREnabledField = true;
            bPaymentEnabledField = true;
            bStartDateEnabled = false;
            bPaymentDateEnabled = false;
            bEndDateEnabled = false;

      
            if(oEnrollmentPlan.ApplicationType__c == 'ENR'){
                if(oEnrollmentPlan.EnrollmentStatus__c == 'Enrolled'){
                    bEnableEmpName = false;
                    bCCREnabledField = false;
                    bPaymentEnabledField = false;
                }else{
                    bStartDateEnabled = true;
                    bPaymentDateEnabled = true;
                    bEndDateEnabled = true;
                }
            }else if(oEnrollmentPlan.ApplicationType__c=='PAY'){
                if(participant.ParticipantType__c == null || participant.ParticipantType__c != 'Discretionary'){
                    bEnableEmpName = false;
                    bCCREnabledField = false;
                    bPaymentEnabledField = true;
                    bPaymentDateEnabled = true;
                    bEndDateEnabled = true;
                }else{
                    bCCREnabledField = false;
                    bStartDateEnabled = true;
                    bPaymentDateEnabled = true;
                    bEndDateEnabled = false;
                }
            }else if(oEnrollmentPlan.ApplicationType__c =='CCR'){

                if(participant.ExistedAtEnrollment__c == null || participant.ExistedAtEnrollment__c == 'Yes'){
                    bEnableEmpName = false;
                    bCCREnabledField = true;
                    bPaymentEnabledField = true;
                    bEndDateEnabled = true;
                }else{
                    bStartDateEnabled = true;
                    bPaymentDateEnabled = true;
                    bEndDateEnabled = false;
                }
            }

        }
    }

}