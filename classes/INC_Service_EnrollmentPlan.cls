public without sharing class INC_Service_EnrollmentPlan {
    public enum requestType {CHANGE,PAYMENT}

    public static map<id,List<EnrollmentParticipant__c>> getPlanParticipants(set<Id> EnrollmentPlans){
        map<id,List<EnrollmentParticipant__c>> mapReturn = new map<id,list<EnrollmentParticipant__c>>();
        List<EnrollmentParticipant__c> listParticipants = new List<EnrollmentParticipant__c>();
 

        for(EnrollmentParticipant__c EnrollPart: [Select id
                                                           , EmployeeID__c
                                                           , EmployeeName__c
                                                           , EmployeeStatus__c
                                                           , EmployeeStatusNo__c
                                                           , EndDateonProject__c
                                                           , EnrollmentPlan__c
                                                           , ParticipantCategory__c
                                                           , IncentiveProjectName__c
                                                           , RoleTitle__c
                                                           , StartDateonProject__c
                                                           , TargetIncentivePoolAllocated__c
                                                           , EmployeeStatusAlert__c
                                                           , EstimatedPayout__c
                                                           , CalculatedIncentive__c
                                                           , PaymentAdjustments__c
                                                           , PaymentAdjReason__c
                                                           , PaymentAmount__c
                                                           , PaymentDate__c
                                                         , ParticipantType__c
                                                         , HRJobTitle__c
                                                         , ExistedAtEnrollment__c
                                                         , Baseline_Margin_Change__c
                                                         , CurrencyIsoCode
                                                  From EnrollmentParticipant__c
                                                  Where EnrollmentPlan__c =: EnrollmentPlans]){

            if(mapReturn.ContainsKey(EnrollPart.EnrollmentPlan__c)){
                listParticipants = mapReturn.get(EnrollPart.EnrollmentPlan__c);
            }else{
                listParticipants = new list<EnrollmentParticipant__c>();
            }
            listParticipants.add(EnrollPart);
            mapReturn.put(EnrollPart.EnrollmentPlan__c,listParticipants);
        }
  
        return mapReturn;
    } 

    public static string getUserDTWAppLevel(id UserID){
      User USR = [Select Id, DTWApplicationLevel__c from User where id =:UserID][0];
      return USR.DTWApplicationLevel__c;
    }

    public static map<id,list<Interim_Payment_Schedule__c>> getInterimPaymentSchedules(set<id> EnrollmentPlans){
      map<id,List<Interim_Payment_Schedule__c>> mapReturn = new map<id,list<Interim_Payment_Schedule__c>>();
        List<Interim_Payment_Schedule__c> listPayments = new List<Interim_Payment_Schedule__c>();
 

        for(Interim_Payment_Schedule__c EnrollPay: [Select id
                                                           , CurrencyIsoCode
                                                           , Description__c
                                                           , Milestone__c
                                                           , PaymentDate__c
                                                           , EnrollmentApplication__c
                                                           , DateofEval__c
                                                           , PaymentAwarded__c
                                                           , IPAmount__c
                                                  From Interim_Payment_Schedule__c
                                                  Where EnrollmentApplication__c =: EnrollmentPlans
                                                  order by PaymentDate__c]){

            if(mapReturn.ContainsKey(EnrollPay.EnrollmentApplication__c)){
                listPayments = mapReturn.get(EnrollPay.EnrollmentApplication__c);
            }else{
                listPayments = new list<Interim_Payment_Schedule__c>();
            }
            listPayments.add(EnrollPay);
            mapReturn.put(EnrollPay.EnrollmentApplication__c,listPayments);
        }
  
        return mapReturn;  
    }

    public static map<id,IncentiveProject__c> getIncentiveProject(set<id> setIncentiveID){
        System.Debug(logginglevel.error,'getting incentive project' + setIncentiveID);
       //  , AreaDescription__c
                                                      
        return new map<id,IncentiveProject__c>([Select Id
                                                        , Name
                                                        , ProjectManager__c
                                                        , OrgCarryingOutProject__c
                                                        , EnrollmentApprover1__c
                                                        , GeographyDescription__c
                                                        , DistrictDescription__c
                                                        , RegionDescription__c
                                                        , EndMarket__c
                                                        , LegalEntityDescription__c
                                                        , CurrencyIsoCode
                                                        , RoutingMemberRule__c
                                                        , DTWAdmin__c
                                                        , ProjectID__c
                                                        ,(Select ID, Name from Enrollment_Plans__r)
                                               From IncentiveProject__c 
                                               Where ID =: setIncentiveID ]);
    }


    public static list<EnrollmentPlan__c> getEnrollmentPlan(set<id> EnrollmentPlans){
        map<id,EnrollmentPlan__c> mapPlans = INC_Service_EnrollmentPlan.getEnrollmentPlanMap(EnrollmentPlans);
        return mapPlans.Values();
    }

    public static map<id,EnrollmentPlan__c> getEnrollmentPlanMap(set<id> EnrollmentPlans){
      map<id,EnrollmentPlan__c> mapReturn = new map<id,EnrollmentPlan__c>([Select ID
                          , Name
                          , RecordTypeId
                          , IncrementalGMvsBaseline__c
                          , ProjectStartDate__c
                          , ScheduledFinishDate__c
                          , MaxIncentivePool__c
                          , EstimatedIncentivePool__c
                          , NSRBudget__c
                          , Minparticipantpayout__c
                          , Approver1__c
                          , Approver2__c
                          , Approver3__c
                          , CustomerName__c
                          , ProjectGeography__c
                          , FPPOverallEligibility_c__c
                          , TMPlanOverallEligibility__c
                          , DPEAdjustment__c
                          , NSRAdjustment__c
                          , EnrollmentStatus__c
                          , IPProjectManager__c
                          , ContractType__c
                          , IPFreqofPayment__c   
                          , IPNumberofPayments__c
                          , FinalIncentivePoolITD__c
                          , IPYearsRemaining__c
                          , GMofNSRAdjustment__c
                          , GrossMarginAmountScopeChange__c
                          , GrossMarginAmountAdjustment__c
                          , IPComment__c
                          , IncentivePlan__c
                          , IncentivePlan__r.ContractType__c
                          , IncentiveProject__r.GeographyDescription__c
                          , EstimatedPoolBaseline__c
                          , EstimatedPoolBaseline10__c
                          , IncentiveProject__r.RegionDescription__c
                          , IncentiveProject__r.CustomerName__c
                          , IncentiveProject__r.CurrencyIsoCode
                          , MetricWarningActive__c
                          , IncentiveProject__r.ContractTypeShortName__c   
                          , IncentiveProject__r.ContractType__c                         
                          , IncentiveProject__r.Name
                          , IncentiveProject__r.SuperGeography__c
                          , ApprovedRevenueBudget__c
                          , ApprovalRecentlyProcessed__c
                          , UnallocatedAmount__c
                          , UnallocatedPercent__c
                          , EstimatedIncentivePoolEAC__c
                          , AppIicationIssues__c
                          , FinalIncentivePoolAdjusted__c
                          , TotalPaymentAmount__c
                          , BaselineNMofNSR__c
                          , ApplicationIssuesPay__c
                          , CurrencyIsoCode
                          , ApplicationExceptionsFP__c
                          , ApplicationExceptionsTM__c
                          , Application_Exceptions__c
                          , StatusNumber__c
                          , IncentiveProject__r.ProjectManager__c
                          , WizardStatus__c
                          , ApplicationIssues2__c
                          , InterimPaymentRequested__c
                          , ApplicationExceptionsPay__c
                          , IncentiveProject__r.DTWAdmin__c
                          , ForecastSubsandODCBudget__c
                          , IncentiveProject__r.RecordTypeId
                          , DSOTarget__c
                          , ApplicationType__c
                          , Forecast_Margin__c
                          , DTWAdmin__r.Email 
                          , IsInWorkflow__c
                From EnrollmentPlan__c
                where id =: EnrollmentPlans]);

      return mapReturn;
    }


    public static string cloneEnrollment(ID EnrollmentPlan,requestType RT){
      
      System.Debug(logginglevel.Error,'Clone Enrollment app');

      list<Schema.FieldSetMember> listFields;

      if(RT == requestType.CHANGE){
        listFields = SObjectType.EnrollmentPlan__c.FieldSets.ChangeRequestFields.getFields();
      }else{
        listFields = SObjectType.EnrollmentPlan__c.FieldSets.PaymentRequest.getFields();
      }

      String sQuery = 'Select ID, Name';
      
      for(FieldSetMember fsm: listFields){
        sQuery += ',' + fsm.getFieldPath();
      }
      sQuery += ',IncentiveProject__r.RoutingMemberRule__c,IncentiveProject__r.CurrencyIsoCode From EnrollmentPlan__c where ID =: EnrollmentPlan';

      EnrollmentPlan__c currentPlan = (EnrollmentPlan__c)database.Query(sQuery)[0];

      map<id,IncentiveProject__c> mapProjects = INC_Service_EnrollmentPlan.getIncentiveProject(new Set<id>{currentPlan.IncentiveProject__c});
      IncentiveProject__c INC_PROJ = mapProjects.get(currentPlan.IncentiveProject__c);
      EnrollmentPlan__c oEnroll = new EnrollmentPlan__c();
      

      Integer iCnt = 1;
      System.Debug(logginglevel.error,'currentPlan.name: ' + currentPlan.Name);
      If(currentPlan.Name.StartsWith('CCR')){
        String sx = currentPlan.Name.subString(currentPlan.Name.Indexof('-') + 1,currentPlan.Name.Indexof(':'));
        try{
          iCnt = Integer.ValueOf(sx);
          iCnt = iCnt + 1;
        } catch(exception e){
          System.Debug(logginglevel.error,'number not converted: ' + sx);
          iCnt = 1; 
        }
      }else{
        if(currentPlan.Name.StartsWith('PAY')){
            String sx = currentPlan.Name.subString(currentPlan.Name.Indexof('-') + 1,currentPlan.Name.Indexof(':'));
          try{
            iCnt = Integer.ValueOf(sx);
            iCnt = iCnt + 1;
          } catch(exception e){
            System.Debug(logginglevel.error,'number not converted: ' + sx);
            iCnt = 1; 
          }
        }
      }

      String sNumber;
      if(iCnt < 10){
        sNumber = '0' + iCnt;
      }


      if(RT == requestType.PAYMENT){
        oEnroll.RecordTypeID = ECO_Utils_sObject.getRecordTypeId(EnrollmentPlan__c.sObjectType,'Payment Request'); 
        if(oEnroll.RecordTypeID == null){
            oEnroll.RecordTypeID = INC_Service_EnrollmentPlan.getRecordTypeId('EnrollmentPlan__c', 'Payment Request');
        }
      } 
      

      String sName = RT == requestType.CHANGE?'CCR-':'PAY-';
      sName += sNumber + ': ' + mapProjects.get(INC_PROJ.ID).ProjectID__c + ':' + mapProjects.get(INC_PROJ.ID).Name;
      System.Debug(logginglevel.error,'plan name: ' + sName);
      oEnroll.Name = sName;
      oEnroll.IncentiveProject__c = currentPlan.IncentiveProject__c;
      oEnroll.IsChangeRequest__c = RT == requestType.CHANGE?'Yes':'No';
      oEnroll.ParentApplication__c = currentPlan.ID;
      oEnroll.ApplicationType__c = RT == requestType.CHANGE?'CCR':'PAY';
      oEnroll.CurrencyIsoCode = currentPlan.IncentiveProject__r.CurrencyIsoCode;


      oEnroll.DTWAdmin__c = mapProjects.get(currentPlan.IncentiveProject__c).DTWAdmin__c;
      if(RT == requestType.Change){
        oEnroll.WizardStatus__c = 'Step 3';
      }

      for(FieldSetMember fsm: listFields){
        if(currentPlan.get(fsm.getFieldPath()) != null){
          oEnroll.put(fsm.getFieldPath(), currentPlan.get(fsm.getFieldPath()));
        }
      }

      if(RT == requestType.Change || RT == requestType.PAYMENT){
        //go get new Approvers from routing members 
        ID RoutingMemberID = currentPlan.IncentiveProject__r.RoutingMemberRule__c;
        List<RoutingMember__c> lMembers = [Select Id
                        , Name
                        //, EndMarket__c
                        , GeographyDescription__c
                        , LegalEntityDescription__c
                        , RegionDescription__c
                        , DistrictDescription__c
                        , DTWAdmin__c
                        , Approver1__c
                        , Approver2__c
                        , Approver3__c
                        , GlobalDefault__c
                        , OwnerID
                    From RoutingMember__c where id =: RoutingMemberID];
        if(lMembers !=null && lMembers.size() > 0){
          oEnroll.Approver1__c = lMembers[0].Approver1__c;
          oEnroll.Approver2__c = lMembers[0].Approver2__c;
          oEnroll.Approver3__c = lMembers[0].Approver3__c;
          oEnroll.DTWAdmin__c = lMembers[0].DTWAdmin__c;
        }
      }
      /*if(RT == requestType.CHANGE && oEnroll.IncentivePlan__r.ContractType__c == 'Time & Material'){
        oEnroll.GrossRevenueAdjustment__c = null;
        oEnroll.GrossRevenueScopeChange__c = null;
        oEnroll.SubsODCsScopeChange__c = null;
        oEnroll.SubsODCsAdjustment__c = null;
        oEnroll.ContingencyScopeChange__c = null;
        oEnroll.ContingencyAdjustment__c = null;
      }*/

      System.savePoint sp = Database.setSavePoint();
      try{
          Insert oEnroll;
      }catch(Exception e){
          system.debug('Handling Exception:  '+e.getMessage() + ' ' + e.getStackTraceString());
          system.debug(logginglevel.error, 'enrollmentPlan creation error: ' + e);
          Database.rollBack(sp);
      }
      if(oEnroll.ID != null){
        INC_Service_EnrollmentPlan.createRelatedEnrollmentRecords(oEnroll,currentPlan);
        if(RT == requestType.CHANGE){
          INC_PROJ.ChangeRequest__c = oEnroll.ID;
        }else{
          INC_PROJ.PaymentRequest__c = oEnroll.ID;
        }
        sp = Database.setSavePoint();
        try{
          update INC_PROJ;
        }catch(Exception e){
          System.debug(logginglevel.Error,'Problem inserting INC_PROJ ' + e.getMessage());
          Database.rollBack(sp);
        }
      }
      return oEnroll.ID;
    }

    public static void createRelatedEnrollmentRecords(EnrollmentPlan__c NewPlan, EnrollmentPlan__c OriginalPlan){
      map<id,List<EnrollmentParticipant__c>> mapParticipants = INC_Service_EnrollmentPlan.getPlanParticipants(new set<id>{OriginalPlan.ID});
      map<id,List<Enrollment_Comments__c>> mapComments = INC_Service_EnrollmentPlan.getCommentsForClone(new set<id>{OriginalPlan.ID});
      map<id,List<Interim_Payment_Schedule__c>> mapPayments = INC_Service_EnrollmentPlan.getInterimPaymentSchedules(new set<id>{OriginalPlan.ID});
      System.Debug(logginglevel.error,'mapComments: ' + mapComments);
      List<EnrollmentParticipant__c> ListAddPart = new List<EnrollmentParticipant__c>();
      List<Enrollment_Comments__c> ListAddComment = new List<Enrollment_Comments__c>();
      List<Interim_Payment_Schedule__c> listAddPayments = new list<Interim_Payment_Schedule__c>();

      if(mapParticipants != null && mapParticipants.size() > 0){
        for(ID EnrollID : mapParticipants.keyset()){
          for(EnrollmentParticipant__c currentEP: mapParticipants.get(EnrollID)){
            EnrollmentParticipant__c ep = new EnrollmentParticipant__c(EmployeeName__c = currentEP.EmployeeName__c
                                                               , EndDateonProject__c = currentEP.EndDateonProject__c
                                                               , EnrollmentPlan__c = NewPlan.ID
                                                               , ParticipantCategory__c = currentEP.ParticipantCategory__c
                                                               , RoleTitle__c = currentEP.RoleTitle__c
                                                               , StartDateonProject__c = currentEP.StartDateonProject__c
                                                               , TargetIncentivePoolAllocated__c = currentEP.TargetIncentivePoolAllocated__c
                                                               , CurrencyIsoCode = currentEP.CurrencyIsoCode);
            ListAddPart.add(ep);
          }
        }
      }

      if(mapComments != null && mapComments.size() > 0){
        for(ID EnrollID : mapComments.keyset()){
          for(Enrollment_Comments__c currentEP: mapComments.get(EnrollID)){
              System.debug(logginglevel.error,'looping through comments: '+ currentEP);
              if(currentEP.Type__c == 'Management Adjustment' || currentEP.Type__c == 'Exception'){
                System.Debug(logginglevel.error,'Creating MA Comment');
                listAddComment.add(new Enrollment_Comments__c(EnrollmentApplication__c = NewPlan.ID
                                                             ,Comments__c = currentEP.Comments__c
                                                             ,Type__c = currentEP.Type__c
                                                             ,ApplicationType__c = currentEP.ApplicationType__c));
              }
          }
        }
      }

      if(mapPayments != null && mapPayments.size() > 0){
        for(ID EnrollID: mapPayments.keyset()){
          for(Interim_Payment_Schedule__c currentPay: mapPayments.get(EnrollID)){
            listAddPayments.add(new Interim_Payment_Schedule__c(EnrollmentApplication__c = NewPlan.ID
                                                                ,Description__c = currentPay.Description__c
                                                                ,Milestone__c = currentPay.Milestone__c
                                                                ,PaymentDate__c = currentPay.PaymentDate__c));
          }
        }
      }
      
      if(ListAddPart != null && ListAddPart.size() > 0){
        System.savePoint sp = Database.setSavePoint();
        try{
            System.Debug(logginglevel.error,'Inserting participants: ' + listAddPart);
            insert listAddPart;
          }catch(Exception e){
            System.Debug(logginglevel.error,'Problem saving participants: ' + e.getMessage());
            Database.rollBack(sp);
          }
      }
      if(listAddComment != null && listAddComment.size() >0){
         System.savePoint sp = Database.setSavePoint();
          try{
            System.debug(logginglevel.error,'Inserting Comments: ' + listAddComment);
            insert listAddComment;
          }catch(Exception e){
            System.Debug(logginglevel.error,'Problem saving comments: ' + e.getMessage());
            Database.rollBack(sp);
          }
      }

      if(listAddPayments != null && listAddPayments.size() > 0){
            System.savePoint sp = Database.setSavePoint();
        try{
            System.Debug(logginglevel.error,'Inserting payments: ' + listAddPart);
            insert listAddPayments;
          }catch(Exception e){
            System.Debug(logginglevel.error,'Problem saving payments: ' + e.getMessage());
            Database.rollBack(sp);
          } 
      }


    }

    public static boolean EnrollmentProcesses(set<id> setIncentives){
        return INC_Service_EnrollmentPlan.EnrollmentProcesses(setIncentives,false);
    }

    public static boolean EnrollmentProcesses(set<id> setIncentives, boolean bRevive){
      System.Debug(logginglevel.error,'starting EnrollmentProcesses');
        map<id,IncentiveProject__c> mapNew = INC_Service_EnrollmentPlan.getIncentiveProject(setIncentives);

        INC_Service_Matching matchingService = new INC_Service_Matching();
        map<Id,map<Integer,INC_Service_Matching.RoutingMember_Wrapper>> mapFoundMembers = matchingService.findAllApprovers(mapNew.Values());
        createEnrollmenApp(mapNew, mapFoundMembers,bRevive);

        return true;
    }

    public static map<id,INC_Service_Matching.RoutingMember_Wrapper> findApprover1(map<id,IncentiveProject__c> mapIncentiveProjects){
      List<IncentiveProject__c> listIncentives = new list<IncentiveProject__c>{mapIncentiveProjects.values()};
      INC_Service_Matching matchingService = new INC_Service_Matching();
      map<id,INC_Service_Matching.RoutingMember_Wrapper> mapFoundMembers = matchingService.findApprover1(listIncentives);
      return mapFoundMembers;

    }
    
    public static boolean createEnrollmenApp(map<id,IncentiveProject__c> mapIncentiveProjects, map<id,map<Integer,INC_Service_Matching.RoutingMember_Wrapper>> mapFoundApprovers,boolean bRevive){
        boolean bReturn = true;
     //   map<id,IncentiveProject__c> mapNew = mapIncentiveProjects;
        Set<Id> setIncentivesToProcess = mapIncentiveProjects.keySet();
        for(ID incentID : setIncentivesToProcess){
            System.Debug(logginglevel.error,'Setting incentive values');
            mapIncentiveProjects.get(incentID).OwnerID = mapIncentiveProjects.get(incentID).ProjectManager__c;
            mapIncentiveProjects.get(incentID).DTWAdminInitiated__c = System.Today(); 
            if(mapFoundApprovers.containsKey(incentID)){
              System.Debug(logginglevel.error,'Approvers :' + mapFoundApprovers);
              System.Debug(logginglevel.error, 'key ' + incentID);
              System.Debug(logginglevel.error, 'contains: ' + mapFoundApprovers.containsKey(incentID));
              mapIncentiveProjects.get(incentID).EnrollmentApprover1__c = mapFoundApprovers.get(incentID).get(1).oRoutingMember.Approver1__c;
            }
        }
  
        updateIncentiveProjects(mapIncentiveProjects.values());
        
        if(setIncentivesToProcess.size() > 0){
                INC_Service_EnrollmentPlan.createEnrollmentPlanfromIncentiveProject(mapIncentiveProjects,mapFoundApprovers,bRevive);
        }
        updateIncentiveProjects(mapIncentiveProjects.values());

        return bReturn;

    }
    
    public static void updateBaselineChangedFlagforParticipants(set<id> setEnrollmentplans){
        map<id,list<EnrollmentParticipant__c>> mapParts = INC_Service_EnrollmentPlan.getPlanParticipants(setEnrollmentplans);
        list<EnrollmentParticipant__c> lParts = new list<EnrollmentParticipant__c>();

        for(list<EnrollmentParticipant__c> lvalues : mapParts.Values()){
          for(EnrollmentParticipant__c part: lValues){
            part.Baseline_Margin_Change__c = true;
            lParts.add(part);
          }
        }

        try{
          System.Debug(logginglevel.error,'updateing baseline flag: ' + lparts);
          update lParts;
          }catch(Exception e){
            System.Debug(logginglevel.error,'Problem updateing participants baseline flag');
          }
    }

    public static boolean createEnrollmentPlanfromIncentiveProject(map<id,IncentiveProject__c> MapIncentiveProjects,map<id,map<Integer,INC_Service_Matching.RoutingMember_Wrapper>> mapFoundApprovers,boolean bRevive){
        boolean bReturn = true;
        map<id,IncentiveProject__c> mapProjects = mapIncentiveProjects; //getIncentiveProject(IncentiveProjectIDs);
        System.Debug(logginglevel.error,'mapProjects ' + mapProjects);
        list<EnrollmentPlan__c> lPlans = new list<EnrollmentPlan__c>();
        INC_Service_Matching ISM = new INC_Service_Matching();
        for(IncentiveProject__c oIncent: mapProjects.values()){
            EnrollmentPlan__c oEnroll = new EnrollmentPlan__c();
            System.Debug(logginglevel.error,'bRevive ' + bRevive);
            if(!bRevive){
              oEnroll.Name = 'ENR: ' + mapProjects.get(oIncent.ID).ProjectID__c + ':' + mapProjects.get(oIncent.ID).Name;
            }else{
              Integer iCnt = oIncent.Enrollment_Plans__r.size();
              if(iCnt == null || iCnt == 0){
                oEnroll.Name = 'ENR: ' + mapProjects.get(oIncent.ID).ProjectID__c + ':' + mapProjects.get(oIncent.ID).Name;
              }else{
                  String sNumber;
                  if(iCnt < 10){
                    sNumber = '0' + iCnt;
                  }else{
                    sNumber = String.ValueOf(iCnt);
                  }
                oEnroll.Name = 'ENR-' + sNumber + ':' + mapProjects.get(oIncent.ID).ProjectID__c + ':' + mapProjects.get(oIncent.ID).Name;
              }
            }
            oEnroll.IncentiveProject__c = oIncent.ID;
            oEnroll.CurrencyIsoCode = oIncent.CurrencyIsoCode;
            if(mapFoundApprovers != null && mapFoundApprovers.containsKey(oIncent.ID)){
              oEnroll.Approver1__c = mapFoundApprovers.get(oIncent.ID).get(1).oRoutingMember.Approver1__c;
              oEnroll.Approver2__c = mapFoundApprovers.get(oIncent.ID).get(2).oRoutingMember.Approver2__c;
              oEnroll.Approver3__c = mapFoundApprovers.get(oIncent.ID).get(3).oRoutingMember.Approver3__c;
              oEnroll.DTWAdmin__c = mapFoundApprovers.get(oIncent.ID).get(1).oRoutingMember.DtwAdmin__c;
            }
             // oEnroll.DTWAdmin__c = mapProjects.get(oIncent.ID).DTWAdmin__c;
            System.Debug(logginglevel.error,'oEnroll from create by project: ' + oEnroll.CurrencyIsoCode);
            System.Debug(logginglevel.error,'IncentiveProject__c CurrencyIsoCode' + oIncent.CurrencyIsoCode);
            lPlans.add(oEnroll);
        }

        System.savePoint sp = Database.setSavePoint();
        try{
            Insert lPlans;
            bReturn = true;
        }catch(Exception e){
            system.debug('Handling Exception:  '+e.getMessage() + ' ' + e.getStackTraceString());
            system.debug(logginglevel.error, 'enrollmentPlan creation error: ' + e);
            Database.rollBack(sp);
            bReturn = false;
        }
        map<id,id> mapOldEnrollmentByIP = new map<id,id>();
        for(EnrollmentPlan__c oEplan : lPlans){
          mapOldEnrollmentByIP.put(oEplan.IncentiveProject__c,mapIncentiveProjects.get(oEplan.IncentiveProject__c).EnrollmentPlan__c);
          mapIncentiveProjects.get(oEplan.IncentiveProject__c).EnrollmentPlan__c = oEplan.ID;
        }
        return bReturn;
    }
    
    public static boolean updateIncentiveProjects(list<IncentiveProject__c> lUpdates){
        boolean bReturn = true;
        System.debug(logginglevel.error,'lupdate: ' + lUpdates);
        System.savePoint sp = Database.setSavePoint();
        try{
            update lUpdates;
        }catch(Exception e){
           /* for(IncentiveProject__c ip: lUpdates){
              IP.AddError(e.getMessage());
            } */
            system.debug(logginglevel.error,'Handling Exception:  '+e.getMessage());
            Database.rollBack(sp);
            bReturn = false;
        }

        return bReturn;
    }
    
    public static boolean updateEnrollmentApplications(list<EnrollmentPlan__c> lupdates){
        boolean bReturn = true;
        System.debug(logginglevel.error,'lupdate: ' + lUpdates);
        System.savePoint sp = Database.setSavePoint();
        try{
            update lUpdates;
        }catch(Exception e){
            system.debug(logginglevel.error,'Handling Exception:  '+e.getMessage());
            Database.rollBack(sp);
            bReturn = false;
        }

        return bReturn;
    }

    public static set<id> checkMetricChanges(map<id,IncentiveProject__c> MapNew, map<id,IncentiveProject__c> mapOld ){

        set<id> setIncentivesChanged = new set<id>();
        String strSOQL = 'Select '; 
        Set<id> setIncentives = mapNew.keySet();
        IncentiveProject__c IncNew;
        IncentiveProject__c IncOld;
        list<Schema.FieldSetMember> listFields = SObjectType.IncentiveProject__c.FieldSets.KeyMetricChangesTrigger.getFields();
        for (Schema.FieldSetMember fsmField: listFields) {
           strSOQL += fsmField.getFieldPath() + ', ';
        }

        strSOQL += 'ID From IncentiveProject__c where Id =: setIncentives';
        System.Debug(logginglevel.error,'SQL: ' + strSOQL);
        list<IncentiveProject__c> lstIncSearchResults = (list<IncentiveProject__c>)Database.query(strSOQL);

        for(IncentiveProject__c IncProj: lstIncSearchResults){
          list<String> listFieldsChanged = new list<String>();
          IncNew = mapNew.get(IncProj.id);
          IncOld = mapOld.get(IncProj.id);
          for(FieldSetMember fsm: listFields){
            String sFieldNew = String.valueOf(IncNew.get(fsm.getFieldPath()));
            String sFieldOld = String.ValueOf(IncOld.get(fsm.getFieldPath()));
            if(sFieldNew == null){
              if(sFieldOld != null){
                setIncentivesChanged.add(IncProj.ID);
                break;
              }
            }else{
              if(sFieldOld == null){
                setIncentivesChanged.add(IncProj.ID);
                break;
              }else{
                if(sFieldNew != sFieldOld){
                  setIncentivesChanged.add(IncProj.ID);
                  break;
                }
              }
            }
          }//end fields loop
         
        }//end incentive loop

        

        return setIncentivesChanged;
    }

    public static void createEnrollmentcomment(List<EnrollmentPlan__c> listEnrollmentPlan){
        list<Enrollment_Comments__c> listNewComments = new list<Enrollment_Comments__c>();
        for(EnrollmentPlan__c ep: listEnrollmentPlan){
            System.Debug(logginglevel.error,'Comments: ' + ep.ExceptionComments__c + ' ma: ' + ep.MA_Comments__c);
            if(ep.ExceptionComments__c != null && ep.ExceptionComments__c.length() > 0){
              listNewComments.add(new Enrollment_Comments__c(EnrollmentApplication__c = ep.id,
                                                             Comments__c = ep.ExceptionComments__c,
                                                             Type__c = 'Exception',
                                                             CurrencyIsoCode = ep.CurrencyIsoCode));
              if(ep.isExceptionComments__c == null || ep.isExceptionComments__c == 'No'){
                ep.isExceptionComments__c = 'Yes';
              }
            }
            if(ep.MA_Comments__c !=null && ep.MA_Comments__c.length() > 0){
              listNewComments.add(new Enrollment_Comments__c(EnrollmentApplication__c = ep.id,
                                                             Comments__c = ep.MA_Comments__c,
                                                             Type__c = 'Management Adjustment',
                                                             CurrencyIsoCode = ep.CurrencyIsoCode));
              if(ep.isMAComments__c == null || ep.isMAComments__c == 'No'){
                ep.isMAComments__c = 'Yes';
              }
            }
        }

        if(listNewComments != null && listNewComments.size() > 0){
          System.savePoint sp = Database.setSavePoint();
          try{
              insert listNewComments;
          }catch(Exception e){
              system.debug(logginglevel.error,'Handling Exception:  '+e.getMessage());
              Database.rollBack(sp);
          }
        }

    }

    public static map<id,list<ProcessInstance>> getApprovalInfoByEnrollment(set<id> enrollmentPlans){
        map<id,list<ProcessInstance>> mapReturn = new map<id,list<ProcessInstance>>();
        list<ProcessInstance> listTemp;
        for(id enrollmentplanID: enrollmentplans){
          for(ProcessInstance PI: [SELECT Id, TargetObjectId,(SELECT Id, StepStatus, ActorID, Comments FROM Steps),(SELECT Id, ActorId, ProcessInstanceId FROM Workitems)
              FROM ProcessInstance where TargetObjectId =: enrollmentplanID]){

            if(mapReturn.ContainsKey(PI.TargetObjectId)){
              listTemp = mapReturn.get(PI.TargetObjectId);
            }else{
              listTemp = new list<ProcessInstance>();
            }

            listTemp.add(PI);
            mapReturn.put(PI.TargetObjectId,listTemp);
        }
      }
        return mapReturn;
    }

    public static void createEnrollmentCommentsFromApproval(set<id> enrollmentPlans){
        System.Debug(logginglevel.error,'Createing enrollment comments');
        list<Enrollment_Comments__c> listNewComments = new list<Enrollment_Comments__c>();
        list<Enrollment_Comments__c> listComments = new list<Enrollment_Comments__c>();
        map<id,EnrollmentPlan__c> mapPlans = INC_Service_EnrollmentPlan.getEnrollmentPlanMap(enrollmentplans);


        if(enrollmentPlans != null && enrollmentPlans.size() > 0){
          //first get all existing comments 
          map<id,list<Enrollment_Comments__c>> mapComments = getCommentsbyEnrollmentPlan(enrollmentPlans);
          System.Debug(logginglevel.error,'mapComments: ' + mapComments);
          map<id,List<ProcessInstance>> mapApprovalByEnrollment = getApprovalInfoByEnrollment(enrollmentPlans);
          System.debug(logginglevel.error,'mapApprovalByEnrollment ' + mapApprovalByEnrollment);
  
          //now loop through approval history to create comment records
          for(ID enrollmentplanID: mapApprovalByEnrollment.KeySet()){
            list<ProcessInstance> lProcessInstance = mapApprovalByEnrollment.get(enrollmentplanID);
            System.Debug(logginglevel.error,'lProcessInstance: ' + lProcessInstance);
            for(ProcessInstance oprocessInstance: lProcessInstance){
              if(mapComments.ContainsKey(enrollmentplanID)){
                for(ProcessInstanceStep processStep: oprocessInstance.Steps){
                  System.Debug(logginglevel.error,'Process steps: ' + ProcessStep);
                  if(processStep.StepStatus == 'Approved' || processStep.StepStatus == 'Rejected'){
                    listComments = mapComments.get(enrollmentplanID);
                    System.Debug(logginglevel.error,'Comments found: ' + listComments);
                    boolean bCommentFound = false;
                    for(Enrollment_Comments__c ec: listComments){
                        if(ec.ApprovalID__c == processStep.id){
                          System.Debug(logginglevel.error,'Comment already exists');
                          bCommentFound = true;
                          break;
                        }
                    }//end enrollment comment loop

                    if(!bCommentFound){
                           System.Debug('Creating new comment');
                           String sType = 'Approved';
                           String sFlag = 'No';
                          if(processStep.StepStatus == 'Rejected'){
                            sType = 'Rejection';
                            sFlag = 'Yes';
                          }else{
                            if(mapPlans.get(enrollmentPlanID).ApplicationType__c == 'OPT'){
                              sType = 'Rejection';
                              sFlag = 'Yes';
                            }
                          }
                          //DTWINCECCPECOM set please enter a comment 
                          String sMessage = processStep.Comments!=null?processStep.Comments:Label.DTWINCECCPECOM;
                          System.Debug(logginglevel.error,'ProcessStep ' + ProcessStep);
                          if(ProcessStep.StepStatus == 'Rejected' || (ProcessStep.StepStatus == 'Approved' && sMessage != Label.DTWINCECCPECOM)){
                            listNewComments.add(new Enrollment_Comments__c(EnrollmentApplication__c = enrollmentplanID,
                                                                   ApprovalID__c = processStep.id,
                                                                   Comments__c = sMessage,
                                                                   Type__c = sType,
                                                                   IsRejection__c = sFlag,
                                                                   Approver__c = processStep.ActorId));
                          }
                         
                    }
                  }//end process step loop
                }//end comment is approved or rejected
              }else{
                  //create comment record because no comments exist
                  for(ProcessInstanceStep processStep: oprocessInstance.Steps){
                  if(processStep.StepStatus == 'Approved' || processStep.StepStatus == 'Rejected'){
                      String sType = 'Approved';
                      String sFlag = 'No';
                    
                      if(processStep.StepStatus == 'Rejected'){
                        sType = 'Rejection';
                        sFlag='Yes';
                      }else{
                            if(mapPlans.get(enrollmentPlanID).ApplicationType__c == 'OPT'){
                              sType = 'Rejection';
                              sFlag = 'Yes';
                            }
                        }
                        //DTWINCECCPECOM
                      String sMessage = processStep.Comments !=null?processStep.Comments:Label.DTWINCECCPECOM;
                        System.Debug(logginglevel.error,'Creating comments');
                        if((sType=='Approved' && sMessage != Label.DTWINCECCPECOM) || 
                           sType=='Rejection'){
                          listNewComments.add(new Enrollment_Comments__c(EnrollmentApplication__c = enrollmentplanID,
                                                                   ApprovalID__c = processStep.id,
                                                                   Comments__c = sMessage,
                                                                   Type__c = sType,
                                                                   IsRejection__c = sFlag,
                                                                   Approver__c = processStep.ActorId));
                        }
                       
                    }
                  }
                }
            }//end process step loop
          }//end enrollmentplan loop
        }//end enrollment plans
        System.debug(logginglevel.error,'listNewComments: ' + listNewComments);
        if(listNewComments != null && listNewComments.size() > 0){
          System.savePoint sp = Database.setSavePoint();
          try{
              insert listNewComments;
          }catch(Exception e){
              system.debug(logginglevel.error,'Handling Exception:  '+e.getMessage());
              Database.rollBack(sp);
          }

        }
 
    }

    public static map<id,List<Enrollment_Comments__c>> getCommentsForClone(set<id> enrollmentPlans){
      map<id,list<Enrollment_Comments__c>> mapReturn = new map<id,list<Enrollment_Comments__c>>();
      list<Enrollment_Comments__c> listTemp;
      System.Debug(logginglevel.error,'EnrollPlans: ' + enrollmentPlans);
      if(enrollmentPlans != null && enrollmentPlans.size() > 0){
        for(Enrollment_Comments__c EC: [Select Id
                                              , EnrollmentApplication__c 
                                              , ApprovalID__c
                                              , Type__c
                                              , Comments__c
                                              , ApplicationType__c
                                      from Enrollment_Comments__c
                                      where EnrollmentApplication__c =: enrollmentPlans
                                      order by createdDate]){
          System.Debug(logginglevel.error,'ec.Type__c: ' + EC.Type__c);
          if(mapReturn.ContainsKey(EC.EnrollmentApplication__c)){
            listTemp.add(EC);
          }else{
            listTemp = new list<Enrollment_Comments__c>();
            listTemp.add(EC);
          }
          mapReturn.put(EC.EnrollmentApplication__c,listTemp);
        }
      }

      return mapReturn;

    }

    public static list<IncentiveProject__c> assignIneligibleQueue(list<IncentiveProject__c>lProjects){
      Group Ineligible  = [select Id from Group where Name = 'DTW Ineligible Queue' and Type = 'Queue'];

      for(IncentiveProject__c oIP: lProjects){
        if((oIP.FPPOverallEligibility__c == Null || oIP.FPPOverallEligibility__c == 'No') &&
           (oIP.TMPlanOverallEligibility__c == Null || oIP.TMPlanOverallEligibility__c == 'No')){
            oIp.OwnerID = Ineligible.Id;
          }
      }

      return lProjects;
    }
    public static map<id,List<Enrollment_Comments__c>> getCommentsbyEnrollmentPlan(set<id> enrollmentPlans){
      map<id,list<Enrollment_Comments__c>> mapReturn = new map<id,list<Enrollment_Comments__c>>();
      list<Enrollment_Comments__c> listTemp;
      System.Debug(logginglevel.error,'EnrollPlans: ' + enrollmentPlans);
      if(enrollmentPlans != null && enrollmentPlans.size() > 0){
        for(Enrollment_Comments__c EC: [Select Id
                                              , EnrollmentApplication__c 
                                              , ApprovalID__c
                                              , Type__c
                                              , Comments__c
                                              , ApplicationType__c
                                      from Enrollment_Comments__c
                                      where EnrollmentApplication__c =: enrollmentPlans
                                      and ApprovalID__c != null
                                      order by createdDate]){
          System.Debug(logginglevel.error,'ec.Type__c: ' + EC.Type__c);
          if(mapReturn.ContainsKey(EC.EnrollmentApplication__c)){
            listTemp.add(EC);
          }else{
            listTemp = new list<Enrollment_Comments__c>();
            listTemp.add(EC);
          }
          mapReturn.put(EC.EnrollmentApplication__c,listTemp);
        }
      }

      return mapReturn;

    }

    public static id getRecordTypeId(String sobjecttype, String recordTypeName){
      list<RecordType> lRecID = [Select Id From RecordType where sobjecttype =: sObjectType and name =: recordTypeName];

      return lRecID[0].ID;
    }
}