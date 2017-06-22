Public without sharing class ECO_ProjectCloningService {

	private final String UNAPPROVED_PROJECT_RECORDTYPENAME = 'Customer Project (Unapproved)';
	@TestVisible
	private Map<String, Set<String>> hardcodedFieldMembersForObject = new Map<String, Set<String>>();
	private Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    private Map<Id,Id> mapOrigToNewIds;	//this map associates source to target ids

	public String newProjectName {get;set;}
	public Id newProjectOwner {get;set;}
	public Id newProjectOpportunity {get;set;}
	public Id newProjectId {get; set;}

	public static Boolean isProjectInExecution {get;set;}
    
	public ECO_ProjectCloningService(){
		newProjectName = '';
		newProjectOwner = null;
		newProjectOpportunity = null;
		newProjectId = null;
		mapOrigToNewIds = new Map<Id,Id>();
	}

	

	public void cloneProject(Id sourceProjectId, Map<String, Set<String>> hardcodedFieldSets){
		//hardcodedFieldMembersForObject = new Map<String, Set<String>>();



		hardcodedFieldMembersForObject = hardcodedFieldSets;
		cloneProject(sourceProjectId);
	}


	public void cloneProjectTasks(Id sourceProjectId){


		List<ECO_Project_Cloning__c> cloneProjTaskSettings = [SELECT Object_API_Name__c, Processing_Order__c, Fieldset_API_Name__c, Parent_Object_API_Name__c, 
															Additional_SOQL_Where_Filter__c, Parent_Processing_Level__c, Active__c, Use_Batch_Apex__c
															FROM ECO_Project_Cloning__c
															WHERE (Object_API_Name__c = 'pse__Proj__c' AND Parent_Processing_Level__c = 0)
															OR Object_API_Name__c = 'pse__Project_Task__c'  
															OR Object_API_Name__c = 'pse__Milestone__c' 
															OR Object_API_Name__c = 'pse__Project_Task_Dependency__c'
															ORDER BY Processing_Order__c ASC];

		if(cloneProjTaskSettings.isEmpty()){
			throw new ECO_Util_Project_Exception('Error: No clone custom settings were found for project cloning!');					
		}

		//reset processing order 
		Map<Decimal, Decimal> mapOldNewProcessingOrder = new Map<Decimal, Decimal>();
		Decimal newProcessingOrder = 1;
		for(ECO_Project_Cloning__c epc : cloneProjTaskSettings){
			mapOldNewProcessingOrder.put(epc.Processing_Order__c, newProcessingOrder);
			epc.Processing_Order__c = newProcessingOrder;
			if(epc.Parent_Processing_Level__c > 0){
				epc.Parent_Processing_Level__c = mapOldNewProcessingOrder.get(epc.Parent_Processing_Level__c);
			}
			newProcessingOrder ++;
		}
		cloneProjectObjects(cloneProjTaskSettings, sourceProjectId);
	}

	
	public void cloneProjectRisks(Id sourceProjectId){


		List<ECO_Project_Cloning__c> cloneProjRiskSettings = [SELECT Object_API_Name__c, Processing_Order__c, Fieldset_API_Name__c, Parent_Object_API_Name__c, 
															Additional_SOQL_Where_Filter__c, Parent_Processing_Level__c, Active__c, Use_Batch_Apex__c
															FROM ECO_Project_Cloning__c
															WHERE (Object_API_Name__c = 'pse__Proj__c' AND Parent_Processing_Level__c = 0)
															OR Object_API_Name__c = 'Risk__c'  
															ORDER BY Processing_Order__c ASC];

		if(cloneProjRiskSettings.isEmpty()){
			throw new ECO_Util_Project_Exception('Error: No clone custom settings were found for project cloning!');					
		}

		//reset processing order 
		Map<Decimal, Decimal> mapOldNewProcessingOrder = new Map<Decimal, Decimal>();
		Decimal newProcessingOrder = 1;
		for(ECO_Project_Cloning__c epc : cloneProjRiskSettings){
			mapOldNewProcessingOrder.put(epc.Processing_Order__c, newProcessingOrder);
			epc.Processing_Order__c = newProcessingOrder;
			if(epc.Parent_Processing_Level__c > 0){
				epc.Parent_Processing_Level__c = mapOldNewProcessingOrder.get(epc.Parent_Processing_Level__c);
			}
			newProcessingOrder ++;
		}
		cloneProjectObjects(cloneProjRiskSettings, sourceProjectId);

	}

	public List<Risk__c> cloneProjectRisksAndReturnRisks(Id sourceProjectId){

		Id targetProjectId = newProjectId;

		Set<Id> existingRiskIds = new Set<Id>();
		List<Risk__c> existingRisks = [SELECT Id FROM Risk__c WHERE Project__c = :targetProjectId];
		if(existingRisks.isEmpty()){
			for(Risk__c risk : existingRisks){
				existingRiskIds.add(risk.Id);
			}
		}

		cloneProjectRisks(sourceProjectId);

		List<Risk__c> newRisks = [SELECT Id, Answer__c, PlanElement__c, PotentialCosts__c, Project__c, Questionnaire__c,
									RiskConsequence__c, RiskMitigation__c, RiskOwner__c, RiskProbability__c,
									CreatedById, CurrencyIsoCode, LastModifiedById, Name
										, Answer__r.TemplateQuestion__c
		        						, Answer__r.DoATrigger__c
		        						, Answer__r.IsRisk__c
		  							FROM Risk__c 
		  							WHERE Project__c = :targetProjectId AND Id NOT IN :existingRiskIds];

		return newRisks;
	}

	/**
	* Iterates through the Custom Settings config data, copying project data from one project into another.
	* @date 4/22/2016 Updated to work with the BudgetHeader__c cloning
	*/
	public void cloneProject(Id sourceProjectId){

		ECO_Service_RecordAccess.ignoreRestOfSecurity = true;
		isProjectInExecution = false;

		List<ECO_Project_Cloning__c> cloneEntireProjSettings = [SELECT Object_API_Name__c, Processing_Order__c, Fieldset_API_Name__c, Parent_Object_API_Name__c, 
															Additional_SOQL_Where_Filter__c, Parent_Processing_Level__c, Active__c, Use_Batch_Apex__c
															FROM ECO_Project_Cloning__c 
															WHERE Active__c = true
															ORDER BY Processing_Order__c ASC];

		if(cloneEntireProjSettings.isEmpty()){
			throw new ECO_Util_Project_Exception('Error: No clone custom settings were found for project cloning!');					
		}

		cloneProjectObjects(cloneEntireProjSettings, sourceProjectId);
	}

	private void cloneProjectObjects(List<ECO_Project_Cloning__c> cloningSettings, Id sourceProjectId){

		ECO_Service_RecordAccess.ignoreRestOfSecurity = true;

		system.debug('sourceProjectId = ' + sourceProjectId);
		system.debug('mergeProjectId = ' + newProjectId);

		Savepoint sp = Database.setSavepoint();
		Boolean doBatchApexProcessing = false;
		Set<Integer> processingIdsDependentOnBatch = new Set<Integer>();
		Id batchProcessingSettingsId = null;
		Integer mapIndex = 1;
		List<pse__Proj__c> mergeProjects;
		pse__Proj__c projectToUpdate;
		Boolean projectHasBeenUpdated = false;
		



		try{
			system.debug('mapOrigToNewIds size at begining = ' + mapOrigToNewIds.size());

			Id targetProjectId = null;
			Id sourceObjectId = null;

			Map<Integer,List<Id>> mapSourceIdsAtProcessingLevel = new Map<Integer,List<Id>>();	//this map is used to establish what parent ids get used in soql call
			
			//processing level, associated object field name, List<SObject> objects to associate and insert
			Map<Integer, ClonedObjectsAtLevel> mapObjectsAtLevelToClone = new Map<Integer, ClonedObjectsAtLevel>();

			Set<Integer> inactiveObjects = new Set<Integer>();
			Map<Integer, Set<String>> mapLevelLookupFieldApiNames = new Map<Integer, Set<String>>();

			//loop thru each level, retrieve source objects that need to be cloned, create new target objects but don't perform dml insert yet
			for(ECO_Project_Cloning__c cpf : cloningSettings){
				//system.debug('DebugMe ---------------------------------------' + cpf.Object_API_Name__c);

				Integer processingOrder = Integer.valueOf(cpf.Processing_Order__c);
				ClonedObjectsAtLevel clonesAtLevel = new ClonedObjectsAtLevel();

				if(cpf.Active__c && !inactiveObjects.contains(Integer.valueOf(cpf.Parent_Processing_Level__c))){					

					//get field set
					Set<String> fieldSetMembers = new Set<String>();
					if(!hardcodedFieldMembersForObject.isEmpty()){	//hardcoded values
						fieldSetMembers = getFieldSetMembersFromMap(hardcodedFieldMembersForObject, cpf.Fieldset_API_Name__c);
					}else{	//field names come from object fieldsets
						fieldSetMembers = getFieldSetMembers(cpf.Fieldset_API_Name__c, cpf.Object_API_Name__c);
					}
					
					if(fieldSetMembers.isEmpty()){
						throw new ECO_Util_Project_Exception('Error: Fieldset ' + cpf.Fieldset_API_Name__c + ' is null or does not contain any fields');
					}

					Map<String, Schema.SObjectField> mapObectFieldDescribe =  getObjectFieldDescribeMap(cpf.Object_API_Name__c);
					Set<String> lookupFieldsInFieldSet = getLookupFieldsForFieldset(cpf.Object_API_Name__c);
					mapLevelLookupFieldApiNames.put(mapIndex, lookupFieldsInFieldSet);

					system.debug('fieldSetMembers size for ' + cpf.Object_API_Name__c + ' = ' + fieldSetMembers.size());
					system.debug('lookupFieldsInFieldSet size for ' + cpf.Object_API_Name__c + ' = ' + lookupFieldsInFieldSet.size());
					//construct dynamic soql
					String soql = '';
					String fields = '';
					Set<String> fieldApiNames = new Set<String>();
					for(String fieldSetMember : fieldSetMembers){
						if(fieldSetMember.compareTo(cpf.Parent_Object_API_Name__c) != 0){
							fields += fieldSetMember + ',';
							fieldApiNames.add(fieldSetMember);
						}					
					}
					if(!String.isEmpty(fields)){
						//get rid of last ','
						fields = fields.substring(0, fields.length()-1);
					}
					if(cpf.Processing_Order__c == 1){	//top of hierarchy						

						sourceObjectId = sourceProjectId;	
						List<Id> ids = new List<Id>();
						ids.add(sourceObjectId);
						mapSourceIdsAtProcessingLevel.put(0, ids);
						mapSourceIdsAtProcessingLevel.put(1, ids);
					}

					if(!String.isEmpty(fields)){

						//retrieve source object						
						List<Id> parentIds = new List<Id>();

						if(mapSourceIdsAtProcessingLevel.containsKey(Integer.valueOf(cpf.Parent_Processing_Level__c))){
							parentIds = mapSourceIdsAtProcessingLevel.get(Integer.valueOf(cpf.Parent_Processing_Level__c));
						}else if(!mapOrigToNewIds.isEmpty()){
							//if we're hitting this from the batch util, the parentIds may not be in mapSourceIdsAtProcessingLevel 
							for(Id origId : mapOrigToNewIds.keySet()){
								parentIds.add(origId);
							}
						}
						soql = 'SELECT ' + cpf.Parent_Object_API_Name__c + ',' + fields + ' FROM ' + cpf.Object_API_Name__c + ' WHERE ' + cpf.Parent_Object_API_Name__c + ' IN :parentIds';
					    if(!String.isEmpty(cpf.Additional_SOQL_Where_Filter__c)){
					    	soql += ' AND ' + cpf.Additional_SOQL_Where_Filter__c;
					    }

					    //US-03890
					    if(cpf.Object_API_Name__c == 'BudgetHeader__c'){

					    	list<pse__Proj__c> lstProject = [SELECT Id, pse__Stage__c FROM pse__Proj__c WHERE Id = :sourceProjectId];

					    	if(lstProject[0].pse__Stage__c == 'Execution'){
					    		soql += ' AND Status__c = \'Approved\' ORDER BY LastModifiedDate ASC LIMIT 1';
					    	} else {
					    		soql += ' AND Status__c = \'Draft\' ORDER BY LastModifiedDate DESC LIMIT 1';
					    	}


					    	/*if(isProjectInExecution){
					    		soql += ' AND Status__c = \'Approved\' ORDER BY LastModifiedDate ASC LIMIT 1';
				    		}else{
					    		soql += ' AND Status__c = \'Draft\' ORDER BY LastModifiedDate DESC LIMIT 1';
				    		}*/
					    }


						system.debug('dynamic sql for processing level ' + cpf.Processing_Order__c + ' = ' + soql);
						
						List<SObject> sourceObjects = Database.query(soql);

						system.debug('sourceObjects size = ' + sourceObjects.size());

						Integer clonedObjIndex = 0;

						clonesAtLevel.parentObjectApiName = cpf.Parent_Object_API_Name__c;
						clonesAtLevel.objectApiName = cpf.Object_API_Name__c; 
						clonesAtLevel.sObjectsWithSourceIds = new List<ObjectWithSourceId>();	
						clonesAtLevel.useBatchApex = cpf.Use_Batch_Apex__c;
						clonesAtLevel.cloneCustomSettingId = cpf.Id;
						clonesAtLevel.soql = soql.replace(':parentIds', JSON.serialize(parentIds));
						clonesAtLevel.fields = JSON.serialize(fieldApiNames);

						if(sourceObjects.isEmpty()){
							mapSourceIdsAtProcessingLevel.put(processingOrder,  new List<Id>());
						}else{

							for(SObject sourceObject :sourceObjects){

								mapOrigToNewIds.put(sourceObject.Id, null);

								//set up map for querying at next level
								if(mapSourceIdsAtProcessingLevel.containsKey(processingOrder)){
									mapSourceIdsAtProcessingLevel.get(processingOrder).add(sourceObject.Id);
								}else{
									List<Id> idsAtLevel = new List<Id>();
									idsAtLevel.add(sourceObject.Id);
									mapSourceIdsAtProcessingLevel.put(processingOrder, idsAtLevel);
								}

								//create clones
								SObject targetObject = null;
								if(processingOrder == 1){
									targetObject = [SELECT Id, pse__Stage__c FROM pse__Proj__c WHERE Id = :newProjectId];
	                            	if(projectHasBeenUpdated == false){
								    	/*system.debug('----------------------------------------DebugMe: project target before update');
								    	system.debug('   ' + targetObject);
								    	if(targetObject.get('pse__Stage__c') == 'Execution'){
								    		isProjectInExecution = true;
								    	}*/
								    }
								}
								else{
									targetObject = sourceObject.clone();
									targetObject.clear();
								}
								String projLookupApiName = cpf.Parent_Object_API_Name__c;

								//add the cloning flag to the project
								if(cpf.Object_API_Name__c.toLowerCase() == 'pse__proj__c'){
									if(processingOrder == 1){
										targetObject.put('IsCloned__c', true);
									}
								}


								for(String fieldApiName : fieldApiNames){	//clone values for each field in fieldset
									if(fieldApiName.toLowerCase() != projLookupApiName.toLowerCase()){	//skip parent lookup field since we set it later
										system.debug('source object field ' + fieldApiName + ' = ' + sourceObject.get(fieldApiName));
										if(fieldApiName.toLowerCase() == 'name' && cpf.Object_API_Name__c.toLowerCase() == 'pse__proj__c'){
											if(processingOrder == 1){
												//top level - append the name with (clone) so user can find the clone later, 
												//and to accomodate workflow rule for project unique name
												if(!String.isEmpty(newProjectName)){
													targetObject.put(fieldApiName, newProjectName);
												}else{
													//project name not passed in, create a new one
												}	
											}else{
												//subproject - generate unique name to support workflow that copies name as external id
												//String subProjectName = 'sub project ' + NewGuid();
												String subProjectName = 'sub project ' + generateRandomString(18);
												targetObject.put(fieldApiName, subProjectName);
											}																		
										}else if(fieldApiName.toLowerCase() == 'pse__opportunity__c' && cpf.Object_API_Name__c.toLowerCase() == 'pse__proj__c' 
													&& processingOrder == 1 && newProjectOpportunity != null){
											//preselected opp for top level project
											targetObject.put(fieldApiName, newProjectOpportunity);
										}else if(fieldApiName.toLowerCase() == 'ownerid' && cpf.Object_API_Name__c.toLowerCase() == 'pse__proj__c' 
													&& processingOrder == 1 && newProjectOwner != null){
											//preselected record owner for top level project
											targetObject.put(fieldApiName, newProjectOwner);
										}else{
											//check that field isn't a formula field - will error if we try to set it
											if(!mapObectFieldDescribe.get(fieldApiName).getDescribe().isCalculated()){
												targetObject.put(fieldApiName, sourceObject.get(fieldApiName));
											}																				
										}
										 
									}							
								}						

								if(projLookupApiName.toLowerCase() != 'id'){
										targetObject.put(projLookupApiName, sourceObject.get(projLookupApiName));	
								}

								//create an object to help with mapping new cloned objects to source objects 
								ObjectWithSourceId owsId = new ObjectWithSourceId();
								owsId.sourceId = sourceObject.Id;
								owsId.obj = targetObject;
								owsId.index = clonedObjIndex;
								clonesAtLevel.sObjectsWithSourceIds.add(owsId);

								//for debugging
								//for(String fieldApiName : fieldApiNames){
								//	system.debug('target object field ' + fieldApiName + ' = ' + targetObject.get(fieldApiName));
								//}

								clonedObjIndex ++;

							}
						}
						
					}else{
						throw new ECO_Util_Project_Exception('Error: Fieldset ' + cpf.Fieldset_API_Name__c + ' is null or does not contain any fields');
					}

					

				}else{
					if(processingOrder == 1){
						throw new ECO_Util_Project_Exception('Error: The topmost object of the object processed is set it inactive. Cloning for all child objects is disabled as a result.');
					}
					inactiveObjects.add(processingOrder);
				}
				
				mapObjectsAtLevelToClone.put(mapIndex, clonesAtLevel);
				mapIndex++;
			}

			system.debug('mapObjectsAtLevelToClone size = ' + mapObjectsAtLevelToClone.size());
			system.debug('   ---------------------     DebugMe: object graph to clone');
			for(Integer i = 1; i < (mapObjectsAtLevelToClone.size() + 1); i++){
				ClonedObjectsAtLevel col = mapObjectsAtLevelToClone.get(i);
				if(col == null){
					system.debug('   ' + i  + ') null ClonedObjectsAtLevel' );
				}
				else{
					system.debug('   ' + i  + ') ' + col.objectApiName);
					system.debug('         soql: ' + col.soql);
					system.debug('         fields: ' + col.fields);
					for(ObjectWithSourceId ows : col.sObjectsWithSourceIds){
						if(ows.obj == null){
							system.debug('      ' + ows.index + ') null obj');
						}
						else{
							system.debug('      ' + ows.index + ') ' + ows.obj);
						}
					}
				}
			}
			system.debug('   ---------------------     --------------------------------');

						
			//do inserts at each level, update children objectes to point at new clone as we loop
			for(Integer i = 1; i < (mapObjectsAtLevelToClone.size() + 1); i++){
				//system.debug('DebugMe: mapObjectsAtLevelToClone.get(i).objectApiName - ' + mapObjectsAtLevelToClone.get(i).objectApiName);
				if(!inactiveObjects.contains(i)){
					//if(mapObjectsAtLevelToClone.get(i) == null){ break;} //don't clone master-child relationship
					String parentObjectApiName;	
					if(mapObjectsAtLevelToClone.get(i) != null){
						parentObjectApiName = mapObjectsAtLevelToClone.get(i).parentObjectApiName;	
					}

					List<ObjectWithSourceId> objectsWithSourceIds = new List<ObjectWithSourceId>();
					Boolean objectUsesBatchProcessing = false;
					Id objectCloneSettingId;

					if(mapObjectsAtLevelToClone.get(i) != null){
						String objectApiName = mapObjectsAtLevelToClone.get(i).objectApiName;
						objectUsesBatchProcessing =  mapObjectsAtLevelToClone.get(i).useBatchApex;
						objectCloneSettingId = mapObjectsAtLevelToClone.get(i).cloneCustomSettingId;

						objectsWithSourceIds = mapObjectsAtLevelToClone.get(i).sObjectsWithSourceIds;
					}
					system.debug('parentObjectApiName at level ' + i + ' = ' + parentObjectApiName);

	 				Map<Integer, Id> mapIndexSourceIds = new Map<Integer, Id>();
					List<SObject> objectsToInsert = new List<SObject>();
					List<SObject> objectsToUpdate = new List<SObject>();
					for(ObjectWithSourceId o : objectsWithSourceIds){
						system.debug('DebugMe: objectsToInsert - ' + o.obj.Id + ' - ' + o.obj);
						if(o.obj.Id != null && i != 1){
							o.obj.Id = null;
						}
						objectsToInsert.add(o.obj);
						mapIndexSourceIds.put(o.index, o.sourceId);
					}			

					if(i == 1){	//top of hierarchy
						Id topOfHierarchyId = mapSourceIdsAtProcessingLevel.get(i).get(0);

						if(newProjectId == null){
							//new project, set recordtype to unapproved
							system.debug('new project, set recordtype to unapproved');
							//Id unapprovedRecordTypeId = getRecordTypeId(pse__Proj__c.sObjectType, 'Customer Project (Unapproved)');
							Id unapprovedRecordTypeId = ECO_Utils_sObject.getRecordTypeId(pse__Proj__c.sObjectType, UNAPPROVED_PROJECT_RECORDTYPENAME);
							if(unapprovedRecordTypeId == null){
								throw new ECO_Util_Project_Exception('RecordType \'' + UNAPPROVED_PROJECT_RECORDTYPENAME + '\' was not found for SObjectType \'' + pse__Proj__c.sObjectType + '\'.');
							}

							objectsToInsert.get(0).put('RecordTypeId', unapprovedRecordTypeId);
							objectsToInsert.get(0).put('EcoRecordStatus__c', 'Locked');
							objectsToInsert.get(0).put('EcoLockedReason__c', 'Project copied from existing project/template with Id = ' + sourceProjectId);


					        try{
					            insert objectsToInsert;
					        } catch( Exception e){
					            ECO_Service_ErrorLog.logException(e);
					        }

							
							newProjectId = objectsToInsert.get(0).Id;
						}else{
							//verify project to merge into exists
							mergeProjects = [SELECT Id FROM pse__Proj__c WHERE Id = :newProjectId];
							if(mergeProjects.isEmpty()){
								throw new ECO_Util_Project_Exception('Cannot find project to merge into with id = ' + newProjectId);
							}
							//system.debug('DebugMe: update: ' + objectsToInsert[0]);
							//update objectsToInsert[0];
							projectToUpdate = (pse__Proj__c)objectsToInsert[0];

						}
						
						objectsToInsert.get(0).put('DateLastCompletedBudgetQuestionnaire__c', system.now());
						mapOrigToNewIds.put(topOfHierarchyId, newProjectId);
						system.debug('source top of hierarchy id = ' + topOfHierarchyId);
						system.debug('clone top of hierarchy id = ' + objectsToInsert.get(0).Id);





					}else{

						if(!objectUsesBatchProcessing){	
						
							//associate children to newly cloned parent
							Set<String> lookupFieldApiNames = new Set<String>();
							if(mapLevelLookupFieldApiNames != null){
								lookupFieldApiNames = mapLevelLookupFieldApiNames.get(i);
							}
                            
                            if(lookupFieldApiNames != null){
								system.debug('level ' + i + ' lookupFieldApiNames size = ' + lookupFieldApiNames.size());
								system.debug('level ' + i + ' objects to insert size = ' + objectsToInsert.size());
                            }
                            /*for( string s : lookupFieldApiNames )
                            {                                
                            	system.debug( '==' + s );
                            }*/
                            
							for(SObject sObj : objectsToInsert){
								Id origParentId = (Id)sObj.get(parentObjectApiName);
								//verify parent id exists for clone and is mapped to the source parent id
								if(mapOrigToNewIds.containsKey(origParentId)){
									Id clonedParentId = (Id)mapOrigToNewIds.get(origParentId);
									if(clonedParentId == null){
										throw new ECO_Util_Project_Exception('Cloned parent id is null for original id = ' + origParentId + ' for ' + mapObjectsAtLevelToClone.get(i).objectApiName);
									}else{
										sObj.put(parentObjectApiName, clonedParentId);	//point parent to clone							
									}
								}	
								//update lookup fields that need to point to new target objects							
								if(!lookupFieldApiNames.isEmpty()){
									for(String lookupApiName : lookupFieldApiNames){
										system.debug('level ' + i + ' lookup field = ' + lookupApiName);
										Id oldRefId = (Id)sObj.get(lookupApiName);
										if(mapOrigToNewIds.containsKey(oldRefId)){
											Id newRefId = mapOrigToNewIds.get(oldRefId);
											sObj.put(lookupApiName, newRefId);
										}
									}
								}
								if(sObj.getsObjectType() == BudgetHeader__c.sObjectType){
									sObj.put('Status__c', 'Draft');
								}
							}
						}

						system.debug('level ' + i + ' - dml call limit before insert = ' + Limits.getDMLStatements());
						system.debug('level ' + i + ' - dml record limit before insert = ' + Limits.getDMLRows());
						system.debug('level ' + i + ' - soql queries executed before insert = ' + Limits.getQueries());
                        
                        system.debug( 'objectsToInsert size : ' + objectsToInsert.size() );
						
						//special handling for tasks and dependent items - pse triggers not bulkified for subtasks				
						if(!doBatchApexProcessing && objectUsesBatchProcessing){
							doBatchApexProcessing = true;
							batchProcessingSettingsId = objectCloneSettingId;													
						}else if(!objectUsesBatchProcessing){
                            
                            if ( objectsToInsert.size() > 0 )
                            {
                            	if(projectHasBeenUpdated == false){
							    	system.debug('----------------------------------------DebugMe: updating project');
							    	system.debug(projectToUpdate);
                            	}
						    	system.debug('----------------------------------------DebugMe: inserting objectsToInsert (excluded batch cloning)');
						    	Integer j = 1;
								for(SObject o : objectsToInsert){
									system.debug('   ' + j + ') ' + o);
									j++;
								}
						    	system.debug('----------------------------------------    ----------------------------------------');

                            	if(projectHasBeenUpdated == false){

							        try{
							            update projectToUpdate;
							        } catch( Exception e){
							            ECO_Service_ErrorLog.logException(e);
							        }
							
							    	projectHasBeenUpdated = true;
							    }

						        try{
						            insert objectsToInsert;
						        } catch( Exception e){
						            ECO_Service_ErrorLog.logException(e);
						        }

                            }    
                            //update the source to target id mapping, objects just inserted should be in same order
							Integer index = 0;
							for(SObject objJustCreated : objectsToInsert){						
								mapOrigToNewIds.put(mapIndexSourceIds.get(index), objJustCreated.Id);
								index++;
							}	
						}
						
						system.debug('level ' + i + ' - dml limit after insert = ' + Limits.getDMLStatements());
						system.debug('level ' + i + ' - dml record after insert = ' + Limits.getDMLRows());
						system.debug('level ' + i + ' - soql queries executed after insert = ' + Limits.getSoslQueries());

											

					}
				}
				
			}

			if(doBatchApexProcessing){
				//kick off batch processing for project sub tasks			
				//Id cloneSubTaskSettingsId = [SELECT Id FROM ECO_Project_Cloning__c WHERE Object_API_Name__c = 'pse__Project_Task__c' AND Parent_Object_API_Name__c = 'pse__Project__c'].Id;
				
				Map<String, Id> mapTaskLookupFields = new Map<String, Id>();
				//filter out any null target ids to avoid getting duplicates in batch util
				Map<Id,Id> mapOrigToNewIdsNoNulls = new Map<Id,Id>();
				for(Id key : mapOrigToNewIds.keySet()){
					if(mapOrigToNewIds.get(key) != null){
						mapOrigToNewIdsNoNulls.put(key, mapOrigToNewIds.get(key));
					}
				}
				//mapTaskLookupFields.put('pse__Project__c', newProjectId);
				ECO_ProjectCloningBatchUtil batchUtil = new ECO_ProjectCloningBatchUtil(sourceProjectId, newProjectId, batchProcessingSettingsId, mapOrigToNewIdsNoNulls, hardcodedFieldMembersForObject, mapOrigToNewIdsNoNulls);
        		Id batchprocessid = Database.executeBatch(batchUtil, 50); 				
			}


		}catch (Exception e){
			//rollback on error
            Database.rollback(sp);
			
			throw new ECO_Util_Project_Exception('An error has occurred ' + e.getMessage() + ' - ' + e.getStackTraceString());
			
		}
		
	}
	
	public Set<String> getLookupFieldsForFieldset (String ObjectName){
		Set<String> results = new Set<String>();		
		Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();        
		for(String key : fieldMap.keySet()){
			//system.debug('field name = ' + key);
			//system.debug('field type = ' + String.valueOf(fieldMap.get(key).getDescribe().getType()));
			if(fieldMap.get(key).getDescribe().getType() == Schema.DisplayType.Reference){
				results.add(key);
			}				
		}
		return results;
	}

	private Map<String, Schema.SObjectField> getObjectFieldDescribeMap(String ObjectName){

		Map<String, Schema.SObjectField> results = new Map<String, Schema.SObjectField>();	  
	    results = schemaMap.get(objectName).getDescribe().fields.getMap(); 
		return results;
	}

	public Set<String> getFieldSetMembers(String fieldSetName, String ObjectName)
	{
		Set<String> results = new Set<String>();
	    Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
	    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
	    Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();


	    system.debug('fieldSetName:  ' + fieldSetName);
	    String[] fieldsets = fieldSetName.split(',');
	    for(String fieldset : fieldsets){
	    	system.debug('fieldset:  ' + fieldset);
		    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldset);

		    //This method can return a null pointer, please put in a detailed error catch.
		    try{
			    List<Schema.FieldSetMember> fieldSetMembers = fieldSetObj.getFields(); 

			    for(Schema.FieldSetMember fieldSetMember : fieldSetMembers){					
					results.add(fieldSetMember.getFieldPath());
				}
		    }
			catch (Exception e){

				throw new ECO_Util_Project_Exception('An error has occurred ' + e.getMessage() + ' - ' + e.getStackTraceString());
			}
	    }


		return results;
	} 

	public Set<String>  getFieldSetMembersFromMap(Map<String, Set<String>> mapFieldSetInfo, String fieldSetName)
	{
		Set<String> results = new Set<String>();
		
		system.debug('testFieldMembersForObject contains ' + fieldSetName + ' = ' + mapFieldSetInfo.containsKey(fieldSetName));
		if(mapFieldSetInfo.containsKey(fieldSetName)){
			results = mapFieldSetInfo.get(fieldSetName);
		}

		return results;
	}

	public class ObjectWithSourceId{
		Integer index {get;set;}
		Id sourceId {get;set;}
		SObject obj {get;set;}
	}


	private class ClonedObjectsAtLevel{
		String parentObjectApiName {get;set;}
		String objectApiName {get;set;}
		String soql {get; set;}
		String fields {get; set;}
		Boolean useBatchApex {get;set;}
		Id cloneCustomSettingId {get;set;}
		List<ObjectWithSourceId> sObjectsWithSourceIds {get;set;}
	}


	public class ECO_Util_Project_Exception extends Exception{}

    private String generateRandomString(Integer len) {
	    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
	    String randStr = '';
	    while (randStr.length() < len) {
	       Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), 62);
	       randStr += chars.substring(idx, idx+1);
	    }
	    return randStr; 
	}

/*
   	public class RecordTypeNotFoundException extends Exception {} 

    //FIND RECORD TYPE
    public static Id getRecordTypeId(SObjectType so, String recordTypeName) {
        
        Map<String,Map<String,Schema.RecordTypeInfo>> sObjectRecordTypes = new Map<String,Map<String,Schema.RecordTypeInfo>>();
        
        if (so != null && recordTypeName != null && recordTypeName != '') {
            Schema.DescribeSObjectResult r = so.getDescribe();
            if (r != null && !sObjectRecordTypes.containsKey(r.getName())) {
                sObjectRecordTypes.put(r.getName(), r.getRecordTypeInfosByName());
            }
                
            Map<String, Schema.RecordTypeInfo> recTypeInfos = sObjectRecordTypes.get(r.getName());
            Schema.RecordTypeInfo recTypeInfo = recTypeInfos.get(recordTypeName);
            //System.debug('recTypeInfo=' + recTypeInfo);
            if (recTypeInfo != null) {
                return recTypeInfo.getRecordTypeId();
            }
        }

        throw new RecordTypeNotFoundException('RecordType \'' + recordTypeName + '\' was not found for SObjectType \'' + so + '\'.');
    }
    */
}