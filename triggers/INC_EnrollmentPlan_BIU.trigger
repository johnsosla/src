trigger INC_EnrollmentPlan_BIU on EnrollmentPlan__c (before insert, before update) {
	system.debug('Enrollment Plan Calculation');
    
    list<Id> lEnrollmentPlansToFetch = new list<Id>();
    
    for(EnrollmentPlan__c oEnrollmentPlan : trigger.new){
        lEnrollmentPlansToFetch.add(oEnrollmentPlan.Id);
    }

    list<EnrollmentPlan__c> lEnrollmentPlans = new list<EnrollmentPlan__c>([SELECT id
                                                                            , IncentiveProject__r.ForecastGrossMarginofNSR__c
                                                                            , ThresholdGM__c
                                                                            , ActualMarginITD__c
                                                                            , IncentiveProject__r.ForecastNSRBudget__c
                                                                            , IncentivePlan__r.ContractType__c
                                                                            , IncentivePlan__r.ContractSubType__c
                                                                            , IncentiveProject__r.ForecastNMofNSR__c
                                                                            , BaselineGMofNSR__c
                                                                            , ForecastGrossMarginBudget__c
                                                                            , BaselineGrossMargin__c
                                                                            , IncentivePlan__r.ProfitSharingPercent__c
                                                                            , MaxIncentivePool__c
                                                                            , MaximumIncentivePoolITD__c
                                                                            , AdjustedComplete__c
                                                                            , AcutalGMofNSRITD__c
                                                                            , IncentiveProject__r.ActualNSRITD__c
                                                                            , IncentiveProject__r.ActualGrossMarginITD__c
                                                                            , NSRBudget__c
                                                                            , BaselineNSR__c
                                                                            , ForecastNetMarginBudget__c
                                                                            FROM EnrollmentPlan__c
                                                                            WHERE Id in : lEnrollmentPlansToFetch]);
    
    for(EnrollmentPlan__c oEnrollmentPlan : lEnrollmentPlans){
        system.debug('Enrollment Plan Id : ' + oEnrollmentPlan.Id);
        system.debug('Contract Type : ' + oEnrollmentPlan.IncentivePlan__r.ContractType__c);
        
        decimal dEstimatedIncPoolEAC = 0;
        decimal dMarginToUse = 0;
        
        if(oEnrollmentPlan.IncentivePlan__r.ContractSubType__c == 'Gross Margin'){
            dMarginToUse = ECO_Utils_String.NullCheck(oEnrollmentPlan.IncentiveProject__r.ForecastGrossMarginofNSR__c);
        }else{
            dMarginToUse = ECO_Utils_String.NullCheck(oEnrollmentPlan.IncentiveProject__r.ForecastNMofNSR__c);
        }
        
        if(oEnrollmentPlan.IncentivePlan__r.ContractType__c == 'Fixed Price'){
            Decimal dThresholdGM = ECO_Utils_String.NullCheck(Trigger.newMap.get(oEnrollmentPlan.id).ThresholdGM__c);
            Decimal dProfitSharingPercent = ECO_Utils_String.NullCheck(oEnrollmentPlan.IncentivePlan__r.ProfitSharingPercent__c) / 100;
            if((dMarginToUse/100) > (dThresholdGM/100)){
                    decimal dCalculatedIncentivePool = ((ECO_Utils_String.NullCheck(oEnrollmentPlan.IncentiveProject__r.ForecastNSRBudget__c)) * ((dMarginToUse/100) - (ECO_Utils_String.NullCheck(trigger.newMap.get(oEnrollmentPlan.id).BaselineGMofNSR__c)/100))
                	* dProfitSharingPercent *(1- ECO_Utils_String.NullCheck(oEnrollmentPlan.AdjustedComplete__c)/100 ));
                    
                    if(dCalculatedIncentivePool > trigger.newMap.get(oEnrollmentPlan.id).MaxIncentivePool__c){
                        dEstimatedIncPoolEAC = trigger.newMap.get(oEnrollmentPlan.id).MaxIncentivePool__c;
                    }else{
                        dEstimatedIncPoolEAC = dCalculatedIncentivePool;
                    }
            }else{
    			dEstimatedIncPoolEAC = 0;
            }
        }else if(oEnrollmentPlan.IncentivePlan__r.ContractType__c == 'Time & Material'){
            //dEstimatedIncPoolEAC = ((dMarginToUse/100) - (oEnrollmentPlan.BaselineGMofNSR__c/100)) * oEnrollmentPlan.MaxIncentivePool__c;
            Decimal dForecastMarginBudget = ECO_Utils_String.NullCheck(trigger.newMap.get(oEnrollmentPlan.id).ForecastGrossMarginBudget__c);
            if(oEnrollmentPlan.IncentivePlan__r.ContractSubType__c == 'Net Margin'){
                dForecastMarginBudget = ECO_Utils_String.NullCheck(trigger.newMap.get(oEnrollmentPlan.id).ForecastNetMarginBudget__c);
            }

            Decimal dBaselineGrossMargin = ECO_Utils_String.NullCheck(trigger.newMap.get(oEnrollmentPlan.id).BaselineGrossMargin__c);
            Decimal dProfitSharingPercent = ECO_Utils_String.NullCheck(oEnrollmentPlan.IncentivePlan__r.ProfitSharingPercent__c) / 100;
           // dEstimatedIncPoolEAC = (oEnrollmentPlan.ForecastGrossMarginBudget__c - oEnrollmentPlan.BaselineGrossMargin__c) * (oEnrollmentPlan.IncentivePlan__r.ProfitSharingPercent__c/100);
            dEstimatedIncPoolEAC = (dForecastMarginBudget - dBaselineGrossMargin) * (dProfitSharingPercent);
            
            if(dEstimatedIncPoolEAC < 0){
                dEstimatedIncPoolEAC = 0;
            }

            if(dEstimatedIncPoolEAC > trigger.newMap.get(oEnrollmentPlan.id).MaxIncentivePool__c){
                dEstimatedIncPoolEAC = trigger.newMap.get(oEnrollmentPlan.id).MaxIncentivePool__c;
            }
            
            if(dBaselineGrossMargin > dForecastMarginBudget){
                dEstimatedIncPoolEAC = 0;
            }

        }
        
        system.debug(dEstimatedIncPoolEAC);
        
        EnrollmentPlan__c oEnrollmentPlanContext = trigger.newMap.get(oEnrollmentPlan.Id);
            
        oEnrollmentPlanContext.EstimatedIncPoolEAC__c = dEstimatedIncPoolEAC;

        //calculate BaselineMarginCalculated__c
        Decimal BaselineGrossMargin = ECO_Utils_String.NullCheck(trigger.newMap.get(oEnrollmentPlan.id).BaselineGrossMargin__c);
        Decimal BaselineNSR = ECO_Utils_String.NullCheck(trigger.newMap.get(oEnrollmentPlan.id).BaselineNSR__c);
        if(BaselineNSR > 0){
            oEnrollmentPlanContext.BaselineMarginCalculated__c = (BaselineGrossMargin / BaselineNSR) * 100;
        }

    }
    
    for(EnrollmentPlan__c oEnrollmentPlan : lEnrollmentPlans){
        decimal dCalculatedEstimatedIncPoolITD = 0;
        Decimal dProfitSharingPercent = (ECO_Utils_String.NullCheck(oEnrollmentPlan.IncentivePlan__r.ProfitSharingPercent__c)/100).setScale(4);
        decimal dMarginToUse = 0;
        
        if(oEnrollmentPlan.IncentivePlan__r.ContractSubType__c == 'Gross Margin'){
            dMarginToUse = ECO_Utils_String.NullCheck(trigger.newMap.get(oEnrollmentPlan.id).AcutalGMofNSRITD__c);
        }else{
            dMarginToUse = ECO_Utils_String.NullCheck(trigger.newMap.get(oEnrollmentPlan.id).ActualNMofNSRITD__c);
        }

        if(oEnrollmentPlan.IncentivePlan__r.ContractType__c =='Fixed Price'){
            if(oEnrollmentPlan.AcutalGMofNSRITD__c > oEnrollmentPlan.ThresholdGM__c){
                Decimal dAdjustComplete = (1-((ECO_Utils_String.NullCheck((trigger.newMap.get(oEnrollmentPlan.id).AdjustedComplete__c))/100).setScale(4)));
                Decimal dIPActualNSRITD = ECO_Utils_String.NullCheck(oEnrollmentPlan.IncentiveProject__r.ActualNSRITD__c); 
                Decimal dIPActualMarginIDT = (ECO_Utils_String.NullCheck(oEnrollmentPlan.AcutalGMofNSRITD__c)/100).setScale(4);

                Decimal dNSRBudget = ECO_Utils_String.NullCheck(trigger.newMap.get(oEnrollmentPlan.id).NSRBudget__c);
                Decimal dBaselineGMofNSR = ((ECO_Utils_String.NullCheck(trigger.newMap.get(oEnrollmentPlan.id).BaselineGMofNSR__c))/100).setScale(4);
                
                Decimal dCalculatedEstimatedPool = (dIPActualNSRITD * (dIPActualMarginIDT - dBaselineGMofNSR) * (dProfitSharingPercent) * (dAdjustComplete));

                System.Debug(logginglevel.error,' values ' + dAdjustComplete + ' ' + dIPActualNSRITD + ' ' + dIPActualMarginIDT + ' ' + dBaselineGMofNSR + ' ' + dProfitSharingPercent);
                System.debug(logginglevel.error,'dCalculatedEstimatedPool ' + dCalculatedEstimatedPool);
                if(dCalculatedEstimatedPool > trigger.newMap.get(oEnrollmentPlan.id).MaximumIncentivePoolITD__c){
                    dCalculatedEstimatedIncPoolITD = ECO_Utils_String.NullCheck(trigger.newMap.get(oEnrollmentPlan.id).MaximumIncentivePoolITD__c);
                }else{
                    dCalculatedEstimatedIncPoolITD = dCalculatedEstimatedPool;
                }
            }
           	else{
                dCalculatedEstimatedIncPoolITD = 0;   
            }
        }

        if(oEnrollmentPlan.IncentivePlan__r.ContractType__c == 'Time & Material'){
            /*
            MAX(((ActualMarginITD__c - BaselineGrossMargin__c) * IncentivePlan__r.ProfitSharingPercent__c) ,0)
            */
            Decimal dActualMaginITD = ECO_Utils_String.NullCheck(trigger.newMap.get(oEnrollmentPlan.id).ActualMarginITD__c);
            Decimal dBaselineGrossMargin = ECO_Utils_String.NullCheck(trigger.newMap.get(oEnrollmentPlan.id).BaselineGrossMargin__c);
            dProfitSharingPercent = ECO_Utils_String.NullCheck(oEnrollmentPlan.IncentivePlan__r.ProfitSharingPercent__c) / 100;

            System.Debug(logginglevel.error,'dActualMaginITD: ' + dActualMaginITD);
            System.Debug(logginglevel.error,'dBaselineGrossMargin: ' + dBaselineGrossMargin);
            System.Debug(logginglevel.error,'dProfitSharingPercent: ' + dProfitSharingPercent);            

            dCalculatedEstimatedIncPoolITD = (dActualMaginITD - dBaselineGrossMargin) * dProfitSharingPercent;
            System.Debug(logginglevel.error,'dCalculatedEstimatedIncPoolITD: ' + dCalculatedEstimatedIncPoolITD);
            System.Debug(logginglevel.error,'MaxIncentivePool__c: ' + trigger.newMap.get(oEnrollmentPlan.id).MaximumIncentivePoolITD__c);
            if(dCalculatedEstimatedIncPoolITD > trigger.newMap.get(oEnrollmentPlan.id).MaximumIncentivePoolITD__c){
                dCalculatedEstimatedIncPoolITD = trigger.newMap.get(oEnrollmentPlan.id).MaximumIncentivePoolITD__c;
            }else{
                if(dCalculatedEstimatedIncPoolITD < 0){
                    dCalculatedEstimatedIncPoolITD = 0;
                }
            }
        }
        System.Debug(logginglevel.error,'dCalculatedEstimatedIncPoolITD: ' + dCalculatedEstimatedIncPoolITD);
        EnrollmentPlan__c oEnrollmentPlanContext = trigger.newMap.get(oEnrollmentPlan.Id);
            
        oEnrollmentPlanContext.EstimatedIncPoolITD__c = dCalculatedEstimatedIncPoolITD;
    }
}

/*

*/