public with sharing class INC_Service_Matching {
	
	public enum SearchType { DTWAdmin,Approver1,Approver2,Approver3,All }
	public INC_Service_Matching() {
	}

	List<RoutingMember_Wrapper> listRoutingMembers = new List<RoutingMember_Wrapper>();
	list<IncentiveProject__c> listIncentiveProjects = new List<IncentiveProject__c>();
	list<OrganizationString__c> lOrgString = new list<OrganizationString__c>();
	RoutingMember_Wrapper oGlobalDefaultMember;
	map<id,RoutingMember_Wrapper> mapRoutingMembers = new map<id,RoutingMember_Wrapper>();

	public list<RoutingMember_Wrapper> getRoutingMembers(boolean bDTWAdmin){
		list<Schema.FieldSetMember> listFieldSet = getFieldSet(bDTWAdmin);
		list<RoutingMember_Wrapper> listReturn = new list<RoutingMember_Wrapper>();
		For(RoutingMember__c oMember:  [Select Id
												, Name
												, EndMarket__c
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
										From RoutingMember__c]){

			listReturn.add(new RoutingMember_Wrapper(oMember,listFieldSet));
			mapRoutingMembers.put(oMember.ID,new RoutingMember_Wrapper(oMember,listFieldSet));
		}

		return listReturn;
	}
	
	public map<id,map<Integer,RoutingMember_Wrapper>> findAllApprovers(list<IncentiveProject__c> lIncentiveProjectID){
		map<id,map<Integer,RoutingMember_Wrapper>> mapReturn = new map<id,map<Integer,RoutingMember_Wrapper>>();
		map<Integer,RoutingMember_Wrapper> mapTemp = new map<Integer,RoutingMember_Wrapper>();
		map<Id,IncentiveProject__c> mapIncentives = new map<Id,IncentiveProject__c>();
		
		set<String> sOrgNames = new set<String>();

		listIncentiveProjects = lIncentiveProjectID;
		Id current1;
		Id current2;
		Id current3;

		
		listRoutingMembers = getRoutingMembers(false);
		System.Debug(logginglevel.error,'listRoutingMembers: ' + listRoutingMembers);
		System.Debug(logginglevel.error,'listIncentiveProjects: ' + listIncentiveProjects);
		//first loop through the Incentive Projects
		for(IncentiveProject__c IncProj : listIncentiveProjects){
			
			list<RoutingMember_Wrapper> ListRoutingMemberFound = findRoutingMember(IncProj,SearchType.All);
			System.Debug(logginglevel.error,'ListRoutingMemberFound: ' + listRoutingMemberFound);
			if(listRoutingMemberFound != null && listRoutingMemberFound.size() > 0){
				if(listRoutingMemberFound.size() > 1){
					Integer iPoints = 0;
					for(RoutingMember_Wrapper RW: listRoutingMemberFound){
						if(rw.iTotalPoints <= iPoints) continue;
						System.Debug(logginglevel.error,'Finding Routing Member ' + current1);
						System.Debug(logginglevel.error,RW.oRoutingMember.DTWAdmin__c + ' ' + RW.oRoutingMember.ID);
					
						if(current1 == null){
							current1 = RW.oRoutingMember.Approver1__c;
							current2 = RW.oRoutingMember.Approver2__c;
							current3 = RW.oRoutingMember.Approver3__c;
							mapTemp.put(1,RW);
							mapTemp.put(2,RW);
							mapTemp.put(3,RW);
							mapReturn.put(IncProj.id,mapTemp);
							iPoints = rw.iTotalPoints;
						}else{
							System.Debug(logginglevel.error,'first Else ');
						
							if(mapReturn.containsKey(IncProj.Id)){
								mapTemp = mapReturn.get(IncProj.Id);
								System.Debug(logginglevel.error,'before nulling out ' + mapTemp);
								/*if(mapTemp.get(1).oRoutingMember.Approver1__c != RW.oRoutingMember.Approver1__c){
									//if we find non-duplicates ie multiple records we want to null it out.
								   mapTemp.put(1,null);
								}
								if(mapTemp.get(2).oRoutingMember.Approver2__c != RW.oRoutingMember.Approver2__c){
									//if we find non-duplicates ie multiple records we want to null it out.
								   mapTemp.put(2,null);
								}
								if(mapTemp.get(3).oRoutingMember.Approver3__c != RW.oRoutingMember.Approver3__c){
									//if we find non-duplicates ie multiple records we want to null it out.
								   mapTemp.put(3,null);
								}*/
							}
							else{
								mapTemp = new map<Integer,RoutingMember_Wrapper>();
								mapTemp.put(1,RW);
								mapTemp.put(2,RW);
								mapTemp.put(3,RW);
							}

							mapReturn.put(IncProj.id,mapTemp);
						}
					    
					}
				}else{
					System.Debug(logginglevel.error,'Routing Member found only 1: ' + listRoutingMemberFound[0].oRoutingMember.ID);
					mapTemp.put(1,listRoutingMemberFound[0]);
					mapTemp.put(2,listRoutingMemberFound[0]);
					mapTemp.put(3,listRoutingMemberFound[0]);
					mapReturn.put(IncProj.id,MapTemp);
				}
			}			
		}
		
		return mapReturn;
	}

	public Map<id,RoutingMember_Wrapper> findApprover1(list<IncentiveProject__c> lIncentiveProjectID){
		map<id,RoutingMember_Wrapper> mapReturn = new map<id,RoutingMember_Wrapper>();
		listIncentiveProjects = lIncentiveProjectID;
		map<Id,IncentiveProject__c> mapIncentives = new map<Id,IncentiveProject__c>();
		set<String> sOrgNames = new set<String>();
		for(IncentiveProject__c inc: listIncentiveProjects){
			sOrgNames.add(inc.OrgCarryingOutProject__c);
		}

		listRoutingMembers = getRoutingMembers(false);
		//first loop through the Incentive Projects
		for(IncentiveProject__c IncProj : listIncentiveProjects){
			list<RoutingMember_Wrapper> ListRoutingMemberFound = findRoutingMember(IncProj,SearchType.Approver1);
			if(ListRoutingMemberFound != null && listRoutingMemberFound.size() > 0){
				mapReturn.put(IncProj.ID,ListRoutingMemberFound[0]);
			}
		}
		return mapReturn;
	}

	public list<IncentiveProject__c> findDTWAdmin(List<IncentiveProject__c> lIncentiveProjectID){
		//Load the data needed for looping
		list<IncentiveProject__c> lUpdates = new list<IncentiveProject__c>();
		//listIncentiveProjects = getIncentiveProjectsNotProcessed();
		listIncentiveProjects = lIncentiveProjectID; 
		listRoutingMembers = getRoutingMembers(true);
		Group DefaultDTWAdminQueue = [select Id from Group where Name = 'DTW Corp Admin' and Type = 'Queue'][0];
	
		//first loop through the Incentive Projects
		System.Debug(logginglevel.error,'FindDTWAdmin: ' + listIncentiveProjects);
		for(IncentiveProject__c IncProj : listIncentiveProjects){
			RoutingMember_Wrapper oRoutingMemberFound = findRoutingMember(IncProj,SearchType.DTWAdmin)[0];
			IncProj.DTWAdminAttempted__c = true;
			if(oRoutingMemberFound != null){
				System.Debug(logginglevel.error,'Setting Owner to: ' + oRoutingMemberFound.oRoutingMember.DTWAdmin__c);
				IncProj.OwnerID = oRoutingMemberFound.oRoutingMember.DTWAdmin__c;
				if(oRoutingMemberFound.oRoutingMember.GlobalDefault__c){
					IncProj.OwnerID = oRoutingMemberFound.oRoutingMember.OwnerID;
				}else{
					IncProj.DTWAdmin__c = oRoutingMemberFound.oRoutingMember.DTWAdmin__c;
				}
				IncProj.RoutingMemberRule__c = oRoutingMemberFound.oRoutingMember.ID;
			}else{
				IncProj.OwnerID = DefaultDTWAdminQueue.ID;
			}

			lUpdates.add(IncProj);
		
		}
		
		return lUpdates;
	}

	private List<RoutingMember_Wrapper> findRoutingMember(IncentiveProject__c oIncProj,SearchType iSearchType){
		List<RoutingMember_Wrapper> listRoutingMembersFound = new list<RoutingMember_Wrapper>();
		list<RoutingMember_Wrapper> listExactMatch = new list<RoutingMember_Wrapper>();
		Set<id> setAdded = new set<id>();
		for(RoutingMember_Wrapper oRoutingWrapper : listRoutingMembers){
			if(oRoutingWrapper.oRoutingMember.GlobalDefault__c){
				oGlobalDefaultMember = oRoutingWrapper;
			}
				if(oIncProj != Null){
                    if(oIncProj.RoutingMemberRule__c != null){
                        if(oIncProj.RoutingMemberRule__c == oRoutingWrapper.oRoutingMember.ID){
                        	System.debug(logginglevel.error,'oIncProj.Routing:' + oIncProj.RoutingMemberRule__c);
                        	System.debug(logginglevel.error,'set Add: ' + setAdded);
							if(!setAdded.contains(oRoutingWrapper.oRoutingMember.ID)){
								System.Debug(logginglevel.error,'Adding to listExactMatch:' + oIncProj.RoutingMemberRule__c);
        	                    listExactMatch.add(mapRoutingMembers.get(oIncProj.RoutingMemberRule__c));
								setAdded.add(oRoutingWrapper.oRoutingMember.ID);
							}
                        }
					}else{

						for(String sFieldName : oRoutingWrapper.setFieldsContained){
							String sIncProjVal = (String) oIncProj.get(sFieldName);
							String sRoutingValue = (String) oRoutingWrapper.oRoutingMember.get(sFieldName);
							if(sIncProjVal != null && sIncProjVal != ''){
								if(!sIncProjVal.toUpperCase().equals(sRoutingValue.toUpperCase())){
									oRoutingWrapper.bExactMatch = false;
									break; //no need to continue
								}
								else{
									oRoutingWrapper.bExactMatch = true;
								}
							}
						}
						if(oRoutingWrapper.bExactMatch){
							listExactMatch.add(oRoutingWrapper);
						}
					}
				}
		}//end routing member loop

			System.Debug(logginglevel.error,'listExactMatch: ' + listExactMatch);
			//for(RoutingMember_Wrapper oRoutingWrapper: listR)
			
			if(iSearchType == SearchType.DTWAdmin){
				if(listExactMatch != null && listExactMatch.size() > 0){
					if(listExactMatch.size() > 1){
						integer iFieldsMatched = 0;
						for(RoutingMember_Wrapper oRoutingWrapper : listExactMatch){
							if(oRoutingWrapper.setFieldsContained.size() > iFieldsMatched){
								iFieldsMatched = oRoutingWrapper.setFieldsContained.size();
								if(listRoutingMembersFound != null){
									listRoutingMembersFound.clear();
								}
								listRoutingMembersFound.add(oRoutingWrapper);
							}else if(oRoutingWrapper.setFieldsContained.size() == iFieldsMatched){
								//if number of fields matched is the same, use Totla points
								if(listRoutingMembers != null && listRoutingMembers.size() > 0){
									if(listRoutingMembersFound[0].iTotalPoints < oRoutingWrapper.iTotalPoints){
										listRoutingMembersFound[0] = oRoutingWrapper;
									}
								}
							}
						}
					}else{
						listRoutingMembersFound.add(listExactMatch[0]);
					}
				}else{
					//figure out what to do if no match is found
					listRoutingMembersFound.add(oGlobalDefaultMember);
				}
			}
			else{
				//searching for approvers so we have to determine if more than one match was found
				if(iSearchType == SearchType.Approver1){
					if(listExactMatch != null && listExactMatch.size() > 0){
				
						if(listExactMatch.size() > 1){
							//just need to determine if the multiple matches have the same approver
							//will need to mod for approve 2 and 3 later
							Id ApproverID;
							Boolean bChanged = false;
							for(RoutingMember_Wrapper oRoutingMember: listExactMatch){
								if(ApproverID == null){
									ApproverID = oRoutingMember.oRoutingMember.Approver1__c;
								}else{
									if(ApproverID != oRoutingMember.oRoutingMember.Approver1__c){
										bChanged = true;
									}
								}
							}
							if(bChanged){
								listRoutingMembersFound = null; //return null for multiple matches
							}else{
								listRoutingMembersFound.add(listExactMatch[0]); //doesn't matter which one we use
							}

						}else{
							listRoutingMembersFound.add(listExactMatch[0]); //no routing matches found for approver 1
						}
					}
				}else{
					if(listExactMatch != null && listExactMatch.size() > 0){
						if(listExactMatch.size() > 1){
							set<Id> setApprover2 = new set<id>();
							set<Id> setApprover3 = new set<id>();
							set<Id> setApprover1 = new set<id>();
							for(RoutingMember_Wrapper rw: listExactMatch){
								if(iSearchType == SearchType.Approver2){
									if(!setApprover2.Contains(rw.oRoutingMember.Approver2__c)){
										listRoutingMembersFound.add(rw);
										setApprover2.add(rw.oRoutingMember.Approver2__c);
									}
								}else{
								    if(iSearchType == SearchType.Approver3){
								    	if(!setApprover3.Contains(rw.oRoutingMember.Approver3__c)){
											listRoutingMembersFound.add(rw);
											setApprover3.add(rw.oRoutingMember.Approver3__c);
										}
									}else{
										if(!setApprover2.Contains(rw.oRoutingMember.Approver2__c) ||
										   !setApprover3.Contains(rw.oRoutingMember.Approver3__c) ||
										   !setApprover1.Contains(rw.oRoutingMember.Approver1__c)){
											listRoutingMembersFound.add(rw);
											setApprover1.add(rw.oRoutingMember.Approver1__c);
											setApprover2.add(rw.oRoutingMember.Approver2__c);
											setApprover3.add(rw.oRoutingMember.Approver3__c);
										}
									}
								}
							}
						}else{
							listRoutingMembersFound.add(listExactMatch[0]);
						}
					}else{
							listRoutingMembersFound.add(oGlobalDefaultMember);
					}

				}
			}
		return listRoutingMembersFound;
	}

	public list<Schema.FieldSetMember> getFieldSet(boolean bDTWAdmin){
		List<Schema.FieldSetMember> lFieldSet;
		if(bDTWAdmin){
			lFieldSet = SObjectType.RoutingMember__c.FieldSets.DTWAdminSearch.getFields();
		}else{
			lFieldSet = SObjectType.RoutingMember__c.FieldSets.ApproverSearch.getFields();
		}

        return lFieldSet;
	}

	public class RoutingMember_Wrapper{
		public boolean bExactMatch;
		public Integer iTotalPoints;
		public set<String> setFieldsContained = new set<String>();
		public RoutingMember__c oRoutingMember;
		public RoutingMember_Wrapper(RoutingMember__c member,List<Schema.FieldSetMember> lFieldSet){
			oRoutingMember = member;
			bExactMatch = false;
			buildMatchingMap(lFieldSet);
		}

		public void buildMatchingMap(List<Schema.FieldSetMember>lFieldSet){
			iTotalPoints = 0;
			Integer iPointCount = lFieldSet.Size();
			for(FieldSetMember FSM: lFieldSet){
				String sValue = (String) oRoutingMember.get(FSM.getFieldPath());
				if(sValue != null && sValue != ''){
					setFieldsContained.add(FSM.getFieldPath());
					iTotalPoints += iPointCount;
				}
				iPointCount --;
			}
		}

	}
  
}