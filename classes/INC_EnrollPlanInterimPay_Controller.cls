public with sharing class INC_EnrollPlanInterimPay_Controller {

    public EnrollmentPlan__c oEnrollmentPlan {get;set;}
    public list<Interim_Payment_Schedule__c> listPayments {get;set;}
    public String partComments {get;set;}
    public Boolean editParticipants {get;set;}

    public INC_EnrollPlanInterimPay_Controller(ApexPages.StandardController stdController) {
        System.Debug(logginglevel.error,'Start Controller ' + System.Now());
        editParticipants = true;
        oEnrollmentPlan = (EnrollmentPlan__c)stdController.getRecord();
        oEnrollmentPlan = INC_Service_EnrollmentPlan.getEnrollmentPlan(new set<id>{oEnrollmentPlan.id})[0];
        System.Debug(logginglevel.error,'Start loadExistingSchedules ' + System.Now());
        loadExistingPayments();
        System.Debug(logginglevel.error,'Start addblankRows ' + System.Now());
        addblankRows();
        System.Debug(logginglevel.error,'End Controller ' + System.Now());
    }

    private void addblankRows(){
        Integer iSize = 0;
        if(oEnrollmentPlan.EnrollmentStatus__c != 'Enrolled'){
            if(listPayments != null && listPayments.size() > 0){
                iSize = listPayments.size();
            }else{
                listPayments = new list<Interim_Payment_Schedule__c>();
            }
            if(iSize > = 5){
                listPayments.add(new Interim_Payment_Schedule__c(EnrollmentApplication__c = oEnrollmentPlan.ID));
            }else{
                for(Integer i = iSize; i<5; i++){
                    listPayments.add(new Interim_Payment_Schedule__c(EnrollmentApplication__c = oEnrollmentPlan.ID));
                }
            }
        }
    }

    private void loadExistingPayments(){
        map<id,List<Interim_Payment_Schedule__c>> mapEnrollmentParticipants = INC_Service_EnrollmentPlan.getInterimPaymentSchedules(new set<id>{oEnrollmentPlan.id});

        listPayments = mapEnrollmentParticipants.get(oEnrollmentPlan.Id);
    }

    public void addBlankRow(){
        if(listPayments == null || listPayments.size() == 0){
            listPayments = new list<Interim_Payment_Schedule__c>();
        }
        listPayments.add(new Interim_Payment_Schedule__c(EnrollmentApplication__c = oEnrollmentPlan.ID));
    }

    public void addPaymentLine(){
        listPayments.add(new Interim_Payment_Schedule__c(EnrollmentApplication__c = oEnrollmentPlan.ID));
    }

    public pageReference Cancel(){
        return getReturnPage();
    }

    public pageReference SaveAndContinue(){
        save();
        return getReturnPage();

    }

    public void save(){
        list<Interim_Payment_Schedule__c> lSave = prepareForSave();
        System.savePoint sp = Database.setSavePoint();
        try{
            update oEnrollmentPlan;
            if(lSave != null && lSave.size() > 0){
                upsert lSave;
                loadExistingPayments();
                addblankRows();
                //DTWINCEPECSAVESUCCESS
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,LABEL.DTWINCEPECSAVESUCCESS));
            }
        }catch(Exception e){
            system.debug('Handling Exception:  '+e.getMessage());
            Database.rollBack(sp);
            ApexPages.addMessages(e);
        }
    }

  
    private pageReference getReturnPage(){
        PageReference Enroll = new pageReference('/apex/INC_EnrollmentApp?id=' + oEnrollmentPlan.id);
        Enroll.setRedirect(true);
        return Enroll;
    }

    private list<Interim_Payment_Schedule__c> prepareForSave(){
        list<Interim_Payment_Schedule__c> lReturn = new list<Interim_Payment_Schedule__c>();
        boolean bSave = true;
        for(Interim_Payment_Schedule__c oPay: listPayments){
            if(oPay.Description__c != null){  
                oPay.CurrencyISOCode = oEnrollmentPlan.CurrencyISOCode;  
                lReturn.add(oPay);
            }else{
                if(oPay.Milestone__c != null ||
                   oPay.PaymentDate__c != null){
                   bSave = false;
                   //DTWINCEPIPCEDERR
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,LABEL.DTWINCEPIPCEDERR));
                  break;
                }
            }
        }
        System.debug(logginglevel.error,'payments to save: ' + lReturn);
        if(!bSave) return null;

        return lReturn;
    }
}