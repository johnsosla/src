public with sharing class INC_EnrollmentLetterController {

	public EnrollmentParticipant__c oEP;
	public ParticipantAcknowledgement__c oPA {get;set;}
	public calcHolder oCH;
	public string epID {get;set;}



	public class calcHolder{
		public date letterDate{get;set;}
		public decimal V {get;set;}
		public decimal Y {get;set;}
		public decimal AF {get;set;}
		public decimal W {get;set;}
		public decimal Z {get;set;}
		public decimal AG {get;set;}
		public decimal X {get;set;}
		public decimal AA {get;set;}
		public decimal AH {get;set;}
		public decimal AC {get;set;}
		public decimal AD {get;set;}
		public decimal AE {get;set;}	
		public string gmnm {get;set;}	

		public decimal fixedAB {get;set;}
		public decimal fixedAF {get;set;}
		public decimal fixedAO {get;set;}
		public decimal fixedAC {get;set;}
		public decimal fixedAG {get;set;}
		public decimal fixedAP {get;set;}
		public decimal fixedZ {get;set;}
		public decimal fixedAD {get;set;}
		public decimal fixedAH {get;set;}
		public decimal fixedAI {get;set;}
		public decimal fixedAK {get;set;}
		public decimal fixedAL {get;set;}
		public decimal fixedAM {get;set;}

		public void calculate(EnrollmentParticipant__c ep){
			letterDate = date.today();

			if(ep.EnrollmentPlan__r.IncentivePlan__r.ContractSubType__c == 'Gross Margin'){
				gmnm = 'GM';
			} else {
				gmnm = 'NM';
			}


			fixedAB = (EP.EnrollmentPlan__r.BaselineGMofNSR__C/100 + 0.03)*EP.EnrollmentPlan__r.ForecastNSRBudget__c;
			fixedAF = (EP.EnrollmentPlan__r.BaselineGMofNSR__C/100 + 0.05)*EP.EnrollmentPlan__r.ForecastNSRBudget__c;
			fixedAO = (EP.EnrollmentPlan__r.BaselineGMofNSR__C/100 + 0.06)*EP.EnrollmentPlan__r.ForecastNSRBudget__c;

			fixedAC = fixedAB - EP.EnrollmentPlan__r.BaselineGMofNSR__C/100*EP.EnrollmentPlan__r.ForecastNSRBudget__c;
			fixedAG = fixedAF - EP.EnrollmentPlan__r.BaselineGMofNSR__C/100*EP.EnrollmentPlan__r.ForecastNSRBudget__c;
			fixedAP = fixedAO - EP.EnrollmentPlan__r.BaselineGMofNSR__C/100*EP.EnrollmentPlan__r.ForecastNSRBudget__c;

			fixedZ = 1 - EP.EnrollmentPlan__r.DTWComplete__c/100;

			fixedAD = fixedZ*fixedAC*0.5;
			fixedAH = fixedZ*fixedAG*0.5;
			fixedAI = fixedZ*fixedAP*0.5;


			if(EP.TargetIncentivePoolAllocated__c != null){
				fixedAK = fixedAD*EP.TargetIncentivePoolAllocated__c/100;
				fixedAL = fixedAH*EP.TargetIncentivePoolAllocated__c/100;
				fixedAM = fixedAI*EP.TargetIncentivePoolAllocated__c/100;
			}

			V = EP.EnrollmentPlan__r.BaselineGrossMargin__c * 1.1;
			Y = EP.EnrollmentPlan__r.BaselineGrossMargin__c * 1.25;
			AE = EP.EnrollmentPlan__r.BaselineGrossMargin__c * 1.5;
			AF = AE - EP.EnrollmentPlan__r.BaselineGrossMargin__c;
			W = V - EP.EnrollmentPlan__r.BaselineGrossMargin__c;
			Z = Y - EP.EnrollmentPlan__r.BaselineGrossMargin__c;
			System.debug(logginglevel.error,'EP.EnrollmentPlan__r.IncentivePlan__r' + EP.EnrollmentPlan__r.IncentivePlan__r.ProfitSharingPercent__c + ' af: ' + AF);
			AG = AF * EP.EnrollmentPlan__r.IncentivePlan__r.ProfitSharingPercent__c/100;
			X =  W * EP.EnrollmentPlan__r.IncentivePlan__r.ProfitSharingPercent__c/100;
			AA = Z * EP.EnrollmentPlan__r.IncentivePlan__r.ProfitSharingPercent__c/100;

			if(EP.TargetIncentivePoolAllocated__c != null){
				AH = AG * EP.TargetIncentivePoolAllocated__c/100;
				AC = X  * EP.TargetIncentivePoolAllocated__c/100;
				AD = AA * EP.TargetIncentivePoolAllocated__c/100;	
			}		
		}
	}


	private void getEP(){
		if(oEP == null){
			oEP  = [select id
								, name
								, CurrencyIsoCode
								, TargetIncentivePoolAllocated__c
								, EnrollmentPlan__r.Approver1__r.name
								, EmployeeName__r.name
								, EmployeeName__r.firstname
								, EnrollmentPlan__r.IncentiveProject__r.name
								, EnrollmentPlan__r.IncentiveProject__r.ProjectID__c
								, EnrollmentPlan__r.IncentivePlan__r.contracttype__c
								, EnrollmentPlan__r.IncentiveProject__r.contracttype__c
								, EnrollmentPlan__r.IncentivePlan__r.name
								, EnrollmentPlan__r.IncentivePlan__r.ProfitSharingPercent__c
								, EnrollmentPlan__r.IncentivePlan__r.ContractSubType__c
								, EnrollmentPlan__r.BaselineGrossMargin__c
								, EnrollmentPlan__r.BaselineGMofNSR__c	
								, EnrollmentPlan__r.ThresholdGM__c	
								, EnrollmentPlan__r.ThresholdGMatEAC__c	
								, EnrollmentPlan__r.DSOTarget__c	
								, EnrollmentPlan__r.ForecastNSRBudget__c	
								, EnrollmentPlan__r.DTWComplete__c	
								, EnrollmentPlan__r.MaxIncentivePool__c	

						from EnrollmentParticipant__c
						where id=:epID];
		}		
	}

	public EnrollmentParticipant__c getoEP(){
		getEP();
		return oEP;
	}

	public calcHolder getoCH(){
		getEP();

		if(oCH == null){
			oCH = new calcHolder();
			oCH.calculate(oEP);



		}

		return oCH;
	}



	public INC_EnrollmentLetterController() {

	}

}