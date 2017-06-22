global class rsUserSummaryFieldsBatchProcessor implements Database.Batchable<sObject> {

    private final String query;

    global rsUserSummaryFieldsBatchProcessor(String query) {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        if(!scope.isEmpty() && query.contains('rs_Profile_Part__c')) {
            // Map of profile parts that will be summarized in user, keys are user Ids
            Map<Id, List<rs_Profile_Part__c>> profileParts = new Map<Id, List<rs_Profile_Part__c>>();
            Set<Id> alreadyAddedPPIds = new Set<Id>();

            // Map of Record Types names and their information
            Map<String,Schema.RecordTypeInfo> mRtInfo = rs_Profile_Part__c.SObjectType.getDescribe().getRecordTypeInfosByName();

            //Map of Profile Parts fields, we'll use this for labeling the User summary
            Map<String, Schema.SObjectField> ppFields = Schema.SObjectType.rs_Profile_Part__c.fields.getMap();

            // We'll add the parts that triggered to the map if they are approved
            for(rs_Profile_Part__c pp : (List<rs_Profile_Part__c>) scope) {
                if(pp.Status__c == rsProfilePart.S_APPROVED) {
                    if(profileParts.containsKey(pp.User__c)) profileParts.get(pp.User__c).add(pp);
                    else profileParts.put(pp.User__c, new List<rs_Profile_Part__c>{pp});
                    alreadyAddedPPIds.add(pp.Id);
                }
            }

            List<User> users = [Select Award_Summary__c,Certification_Summary__c,Education_Summary__c,Languages_Summary__c,
                                       Professional_Affiliation_Summary__c,Publication_Summary__c,Registration_Summary__c,
                                       SF254_Summary__c,SF330_Summary__c,Skill_Index_Summary__c,Training_Summary__c,Translations_Summary__c,
                                       Work_History_Summary__c, Resume_Name__c
                                from User
                                where Id IN: profileParts.keySet() ];

            // get Max length of each of the profile part summary fields
            Integer awardLimit = User.Award_Summary__c.getDescribe().getLength();
            Integer certiLimit = User.Certification_Summary__c.getDescribe().getLength();
            Integer educaLimit = User.Education_Summary__c.getDescribe().getLength();
            Integer langsLimit = User.Languages_Summary__c.getDescribe().getLength();
            Integer assocLimit = User.Professional_Affiliation_Summary__c.getDescribe().getLength();
            Integer pubtnLimit = User.Publication_Summary__c.getDescribe().getLength();
            Integer regisLimit = User.Registration_Summary__c.getDescribe().getLength();
            Integer sf254Limit = User.SF254_Summary__c.getDescribe().getLength();
            Integer sf330Limit = User.SF330_Summary__c.getDescribe().getLength();
            Integer skillLimit = User.Skill_Index_Summary__c.getDescribe().getLength();
            Integer trainLimit = User.Training_Summary__c.getDescribe().getLength();
            Integer transLimit = User.Translations_Summary__c.getDescribe().getLength();
            Integer wrkhsLimit = User.Work_History_Summary__c.getDescribe().getLength();

            // For now only add required fields to the summary,
            for(User u : users) {

                // We'll first clear the fields of null
                if(String.isBlank(u.Award_Summary__c)) u.Award_Summary__c = '';
                if(String.isBlank(u.Certification_Summary__c)) u.Certification_Summary__c = '';
                if(String.isBlank(u.Education_Summary__c)) u.Education_Summary__c = '';
                if(String.isBlank(u.Languages_Summary__c)) u.Languages_Summary__c = '';
                if(String.isBlank(u.Professional_Affiliation_Summary__c)) u.Professional_Affiliation_Summary__c = '';
                if(String.isBlank(u.Publication_Summary__c)) u.Publication_Summary__c = '';
                if(String.isBlank(u.Registration_Summary__c)) u.Registration_Summary__c = '';
                if(String.isBlank(u.SF254_Summary__c)) u.SF254_Summary__c = '';
                if(String.isBlank(u.SF330_Summary__c)) u.SF330_Summary__c = '';
                if(String.isBlank(u.Skill_Index_Summary__c)) u.Skill_Index_Summary__c = '';
                if(String.isBlank(u.Training_Summary__c)) u.Training_Summary__c = '';
                if(String.isBlank(u.Translations_Summary__c)) u.Translations_Summary__c = '';
                if(String.isBlank(u.Work_History_Summary__c)) u.Work_History_Summary__c = '';

                Boolean awardLimitReached = false;
                Boolean certiLimitReached = false;
                Boolean educaLimitReached = false;
                Boolean langsLimitReached = false;
                Boolean assocLimitReached = false;
                Boolean pubtnLimitReached = false;
                Boolean regisLimitReached = false;
                Boolean sf254LimitReached = false;
                Boolean sf330LimitReached = false;
                Boolean skillLimitReached = false;
                Boolean trainLimitReached = false;
                Boolean transLimitReached = false;
                Boolean wrkhsLimitReached = false;

                for(rs_Profile_Part__c pp : profileParts.get(u.Id)) {

                    // We'll adding text to each field until we hit the limit, which point we'll add an ellipsis at the end
                    // to indicate more data exists than the field can hold

                    // Award Summary
                    if(pp.RecordTypeId == mRtInfo.get(rsProfilePart.RT_AWARD).getRecordTypeId() && !awardLimitReached) {
                        u.Award_Summary__c += '[' + ppFields.get('Award_Title__c').getDescribe().getLabel() + ']: ' + pp.Award_Title__c + '\r\n';
                        if(u.Award_Summary__c.length() >= awardLimit) {
                            awardLimitReached = true;
                            u.Award_Summary__c = u.Award_Summary__c.subString(0,awardLimit-3) + '...';
                        }
                    }

                    //Certification Summary
                    else if(pp.RecordTypeId == mRtInfo.get(rsProfilePart.RT_CERTIFICATION).getRecordTypeId() && !certiLimitReached) {
                        u.Certification_Summary__c += '[' + ppFields.get('Certification_Title__c').getDescribe().getLabel() + ']: ' + pp.Certification_Title__c + '\r\n';
                        if(u.Certification_Summary__c.length() >= certiLimit) {
                            certiLimitReached = true;
                            u.Certification_Summary__c = u.Certification_Summary__c.subString(0,certiLimit-3) + '...';
                        }
                    }

                    // Education Summary
                    else if(pp.RecordTypeId == mRtInfo.get(rsProfilePart.RT_EDUCATION).getRecordTypeId() && !educaLimitReached) {
                        u.Education_Summary__c += '[' + ppFields.get('Institution__c').getDescribe().getLabel() + ']: ' + pp.Institution__c + ', ' +
                                                  '[' + ppFields.get('Degree__c').getDescribe().getLabel() + ']: ' + pp.Degree__c + ', ' +
                                                  '[' + ppFields.get('Degree_Specialty__c').getDescribe().getLabel() + ']: ' + pp.Degree_Specialty__c + ', ' +
                                                  '[' + ppFields.get('Institution_Country__c').getDescribe().getLabel() + ']: ' + pp.Institution_Country__c + ', ' +
                                                  '[' + ppFields.get('Year_Obtained__c').getDescribe().getLabel() + ']: ' + String.valueOf((Integer)pp.Year_Obtained__c) + '\r\n';
                        if(u.Education_Summary__c.length() >= educaLimit) {
                            educaLimitReached = true;
                            u.Education_Summary__c = u.Education_Summary__c.subString(0,educaLimit-3) + '...';
                        }
                    }

                    // Languages Summary
                    else if(pp.RecordTypeId == mRtInfo.get(rsProfilePart.RT_LANGUAGES).getRecordTypeId() && !langsLimitReached) {
                        u.Languages_Summary__c += '[' + ppFields.get('Skill_Language__c').getDescribe().getLabel() + ']: ' + pp.Skill_Language__c + ', ' +
                                                  '[' + ppFields.get('Language_Level__c').getDescribe().getLabel() + ']: ' + pp.Language_Level__c + ', ' +
                                                  '[' + ppFields.get('Language_Skill__c').getDescribe().getLabel() + ']: ' + pp.Language_Skill__c + '\r\n';
                        if(u.Languages_Summary__c.length() >= langsLimit) {
                            langsLimitReached = true;
                            u.Languages_Summary__c = u.Languages_Summary__c.subString(0,langsLimit-3) + '...';
                        }
                    }

                    // Professional Affiliation Summary
                    else if(pp.RecordTypeId == mRtInfo.get(rsProfilePart.RT_PROF_AFFILIATION).getRecordTypeId() && !assocLimitReached) {
                        u.Professional_Affiliation_Summary__c += '[' + ppFields.get('Association_Name__c').getDescribe().getLabel() + ']: ' + pp.Association_Name__c + '\r\n';
                        if(u.Professional_Affiliation_Summary__c.length() >= assocLimit) {
                            assocLimitReached = true;
                            u.Professional_Affiliation_Summary__c = u.Professional_Affiliation_Summary__c.subString(0,assocLimit-3) + '...';
                        }
                    }

                    // Publication Summary
                    else if(pp.RecordTypeId == mRtInfo.get(rsProfilePart.RT_PUBLICATION).getRecordTypeId() && !assocLimitReached) {
                        u.Publication_Summary__c += '[' + ppFields.get('Publication_Title__c').getDescribe().getLabel() + ']: ' + pp.Publication_Title__c + '\r\n';
                        if(u.Publication_Summary__c.length() >= pubtnLimit) {
                            pubtnLimitReached = true;
                            u.Publication_Summary__c = u.Publication_Summary__c.subString(0,pubtnLimit-3) + '...';
                        }
                    }

                    // License/Registration Summary
                    else if(pp.RecordTypeId == mRtInfo.get(rsProfilePart.RT_REGISTRATION).getRecordTypeId() && !regisLimitReached) {
                        u.Registration_Summary__c += '[' + ppFields.get('License_Registration_Name__c').getDescribe().getLabel() + ']: ' + pp.License_Registration_Name__c + '\r\n';
                        if(u.Registration_Summary__c.length() >= regisLimit) {
                            regisLimitReached = true;
                            u.Registration_Summary__c = u.Registration_Summary__c.subString(0,regisLimit-3) + '...';
                        }
                    }

                    // SF254 Summary
                    else if(pp.RecordTypeId == mRtInfo.get(rsProfilePart.RT_SF254).getRecordTypeId() && !sf254LimitReached) {
                        u.SF254_Summary__c += '[' + ppFields.get('SF254_Discipline__c').getDescribe().getLabel() + ']: ' + pp.SF254_Discipline__c + '\r\n';
                        if(u.SF254_Summary__c.length() >= sf254Limit) {
                            sf254LimitReached = true;
                            u.SF254_Summary__c = u.SF254_Summary__c.subString(0,sf254Limit-3) + '...';
                        }
                    }

                    // SF330 Summary
                    else if(pp.RecordTypeId == mRtInfo.get(rsProfilePart.RT_SF330).getRecordTypeId() && !sf330LimitReached) {
                        u.SF330_Summary__c += '[' + ppFields.get('SF330_Discipline__c').getDescribe().getLabel() + ']: ' + pp.SF330_Discipline__c + '\r\n';
                        if(u.SF330_Summary__c.length() >= sf330Limit) {
                            sf330LimitReached = true;
                            u.SF330_Summary__c = u.SF330_Summary__c.subString(0,sf254Limit-3) + '...';
                        }
                    }

                    // Skill Index Summary
                    //else if(pp.RecordTypeId == mRtInfo.get(rsProfilePart.RT_SKILL_INDEX).getRecordTypeId() && !skillLimitReached) {

                    //  // The Skill component was hidden as of 9.30.2014, but just in case it ever isn't
                    //  u.Skill_Index_Summary__c += '[' + ppFields.get('Skill__c').getDescribe().getLabel() + ']: ' + pp.Skill__c + ', ' +
                    //                              '[' + ppFields.get('Skill_Area__c').getDescribe().getLabel() + ']: ' + pp.Skill_Area__c +
                    //                              '[' + ppFields.get('Skill_Level__c').getDescribe().getLabel() + ']: ' + pp.Skill_Level__c + '\r\n';
                    //  if(u.Skill_Index_Summary__c.length() >= skillLimit) {
                    //      skillLimitReached = true;
                    //      u.Skill_Index_Summary__c = u.Skill_Index_Summary__c.subString(0,skillLimit-3) + '...';
                    //  }
                    //}

                    // Training Summary
                    else if(pp.RecordTypeId == mRtInfo.get(rsProfilePart.RT_TRAINING).getRecordTypeId() && !trainLimitReached) {
                        u.Training_Summary__c += '[' + ppFields.get('Training_Name__c').getDescribe().getLabel() + ']: ' + pp.Training_Name__c + '\r\n';
                        if(u.Training_Summary__c.length() >= trainLimit) {
                            trainLimitReached = true;
                            u.Training_Summary__c = u.Training_Summary__c.subString(0,trainLimit-3) + '...';
                        }
                    }

                    // Translations Summary
                    else if(pp.RecordTypeId == mRtInfo.get(rsProfilePart.RT_TRANSLATIONS).getRecordTypeId() && !transLimitReached) {
                        u.Translations_Summary__c += '[' + ppFields.get('Translate_From__c').getDescribe().getLabel() + ']: ' + pp.Translate_From__c + ', ' +
                                                     '[' + ppFields.get('Translate_To__c').getDescribe().getLabel() + ']: ' + pp.Translate_To__c + '\r\n';
                        if(u.Translations_Summary__c.length() >= transLimit) {
                            transLimitReached = true;
                            u.Translations_Summary__c = u.Translations_Summary__c.subString(0,transLimit-3) + '...';
                        }
                    }

                    // Work History Summary
                    else if(pp.RecordTypeId == mRtInfo.get(rsProfilePart.RT_WORK_HISTORY).getRecordTypeId() && !wrkhsLimitReached) {
                        u.Work_History_Summary__c += '[' + ppFields.get('Company_Name__c').getDescribe().getLabel() + ']: ' + pp.Company_Name__c + ', ' +
                                                     '[' + ppFields.get('Job_Title__c').getDescribe().getLabel() + ']: ' + pp.Job_Title__c + ', ';
                        if(pp.Start_Date__c != null) {
                            u.Work_History_Summary__c += '[' + ppFields.get('Start_Date__c').getDescribe().getLabel() + ']: ' + pp.Start_Date__c.format() + ', ';
                        }
                        u.Work_History_Summary__c += '[' + ppFields.get('Work_History_Country__c').getDescribe().getLabel() + ']: ' + pp.Work_History_Country__c + ', ' +
                                                     '[' + ppFields.get('Work_History_State__c').getDescribe().getLabel() + ']: ' + pp.Work_History_State__c + ', ' +
                                                     '[' + ppFields.get('City__c').getDescribe().getLabel() + ']: ' + pp.City__c + '\r\n';
                        if(u.Work_History_Summary__c.length() >= wrkhsLimit) {
                            wrkhsLimitReached = true;
                            u.Work_History_Summary__c = u.Work_History_Summary__c.subString(0,wrkhsLimit-3) + '...';
                        }
                    } else if (pp.RecordTypeId == mRtInfo.get(rsProfilePart.RT_PERSONAL).getRecordTypeId()) {
                        u.Resume_Name__c = pp.Resume_Name__c;
                    }
                    // if Limit has been reached in all fields just break
                    if(awardLimitReached && certiLimitReached && educaLimitReached
                        && langsLimitReached && assocLimitReached && pubtnLimitReached
                        && regisLimitReached && sf254LimitReached && sf330LimitReached
                        && skillLimitReached && trainLimitReached && transLimitReached
                        && wrkhsLimitReached) {
                        break;
                    }
                }
            }
            update users;
        } else if(!scope.isEmpty() && query.contains('PR_Team_Employee__c')) {
            // Map of projectss that will be summarized in user, keys are user Ids
            Map<Id, List<PR_Team_Employee__c>> projects = new Map<Id, List<PR_Team_Employee__c>>();
            Set<Id> alreadyAddedPPIds = new Set<Id>();
            List<PR_Team_Employee__c> updateList = new List<PR_Team_Employee__c>();
            // Map of Record Types names and their information
            Map<String,Schema.RecordTypeInfo> mRtInfo = PR_Team_Employee__c.SObjectType.getDescribe().getRecordTypeInfosByName();

            //Map of Projects fields, we'll use this for labeling the User summary
            Map<String, Schema.SObjectField> projectFields = Schema.SObjectType.PR_Team_Employee__c.fields.getMap();

            // We'll add the parts that triggered to the map if they are approved
            for(PR_Team_Employee__c pp : (List<PR_Team_Employee__c>) scope) {
                if(projects.containsKey(pp.EmployeeUser__c)) projects.get(pp.EmployeeUser__c).add(pp);
                else projects.put(pp.EmployeeUser__c, new List<PR_Team_Employee__c>{pp});
                alreadyAddedPPIds.add(pp.Id);
            }

            List<User> users = [Select AECOM_Projects_Summary__c, Non_AECOM_Projects_Summary__c
                                from User
                                where Id IN: projects.keyset()];

            //For now we'll only add the required fields to the summary
            Integer aecomLimit = User.AECOM_Projects_Summary__c.getDescribe().getLength();
            Integer nonAecomLimit = User.Non_AECOM_Projects_Summary__c.getDescribe().getLength();
            for(User u : users) {

                // We'll clear the projects summary fields of null
                if(String.isBlank(u.AECOM_Projects_Summary__c)) u.AECOM_Projects_Summary__c = '';
                if(String.isBlank(u.Non_AECOM_Projects_Summary__c)) u.Non_AECOM_Projects_Summary__c = '';

                Boolean aecomLimitReached = u.AECOM_Projects_Summary__c.length() >= aecomLimit;
                Boolean nonAecomLimitReached = u.Non_AECOM_Projects_Summary__c.length() >= nonAecomLimit;


                for(PR_Team_Employee__c pp : projects.get(u.Id)) {
                    if(String.isBlank(pp.Location_Country_Text__c)) {
                        pp.Location_Country_Text__c = pp.Location_Country__c;
                    }
                    if(String.isBlank(pp.Location_State_Prov_Emirate_Text__c)) {
                        pp.Location_State_Prov_Emirate_Text__c = pp.Location_State_Prov_Emirate__c;
                    }
                    if(String.isBlank(pp.Location_City_Text__c)) {
                        pp.Location_City_Text__c = pp.Location_City__c;
                    }
                    // AECOM Projects Summary
                    if(pp.RecordTypeId == mRtInfo.get(rsPRTeamEmployee.RT_AECOMPROJECT).getRecordTypeId() && !aecomLimitReached) {
                        u.AECOM_Projects_Summary__c += String.isNotBlank(pp.Project_Name__c) ? '[' + projectFields.get('Project_ID__c').getDescribe().getLabel() + ']: ' + pp.Project_Name__c + ', ' : '';
                        u.AECOM_Projects_Summary__c += String.isNotBlank(pp.Project_Role__c) ? '[' + projectFields.get('Project_Role__c').getDescribe().getLabel() + ']: ' + pp.Project_Role__c + ', ' : '';
                        u.AECOM_Projects_Summary__c += String.isNotBlank(pp.Client__c) ? '[' + Label.Client_Name + ']: ' + pp.Client__c + ', ' : '';
                        u.AECOM_Projects_Summary__c += String.isNotBlank(pp.Project_Group_Editable__c) ? '[' + Label.Project_Group + ']: ' + pp.Project_Group_Editable__c + ', ' : '';
                        u.AECOM_Projects_Summary__c += String.isNotBlank(pp.Location_Country__c) ? '[' + Label.Location_Country + ']: ' + pp.Location_Country__c + ', ' : '';
                        if(pp.Date_Involvement_Started__c != null) {
                            u.AECOM_Projects_Summary__c += '[' + Label.Date_Involvement_Started + ']: ' + pp.Date_Involvement_Started__c.format() + ', ';
                        }
                        if(pp.Date_Involvement_Ended__c != null) {
                            u.AECOM_Projects_Summary__c += '[' + Label.Date_Involvement_Ended + ']: ' + pp.Date_Involvement_Ended__c.format() + ', ';
                        }
                        u.AECOM_Projects_Summary__c += String.isNotBlank(pp.Description__c) ? '[' + projectFields.get('Description__c').getDescribe().getLabel() + ']: ' + pp.Description__c : '';
                        u.AECOM_Projects_Summary__c += String.isNotBlank(u.AECOM_Projects_Summary__c) ? '\r\n' : '';

                        // set limit reached and add indicator that more data exists but field cannot hold any more
                        if(u.AECOM_Projects_Summary__c.length() >= aecomLimit) {
                            aecomLimitReached = true;
                            u.AECOM_Projects_Summary__c = u.AECOM_Projects_Summary__c.subString(0,aecomLimit-3) + '...';
                        }
                    }

                    // Non-AECOM Projects Summary
                    else if(pp.RecordTypeId == mRtInfo.get(rsPRTeamEmployee.RT_NONAECOMPROJECT).getRecordTypeId() && !aecomLimitReached) {
                        u.Non_AECOM_Projects_Summary__c += String.isNotBlank(pp.Project_Name__c) ? '[' + projectFields.get('Project_ID__c').getDescribe().getLabel() + ']: ' + pp.Project_Name__c + ', ' : '';
                        u.Non_AECOM_Projects_Summary__c += String.isNotBlank(pp.Project_Role__c) ? '[' + projectFields.get('Project_Role__c').getDescribe().getLabel() + ']: ' + pp.Project_Role__c + ', ' : '';
                        u.Non_AECOM_Projects_Summary__c += String.isNotBlank(pp.Client__c) ? '[' + Label.Client_Name + ']: ' + pp.Client__c + ', ' : '';
                        u.Non_AECOM_Projects_Summary__c += String.isNotBlank(pp.Project_Group_Editable__c) ? '[' + Label.Project_Group + ']: ' + pp.Project_Group_Editable__c + ', ' : '';
                        u.Non_AECOM_Projects_Summary__c += String.isNotBlank(pp.Location_Country__c) ? '[' + Label.Location_Country + ']: ' + pp.Location_Country__c + ', ' : '';
                        if(pp.Date_Involvement_Started__c != null) {
                            u.Non_AECOM_Projects_Summary__c += '[' + Label.Date_Involvement_Started + ']: ' + pp.Date_Involvement_Started__c.format() + ', ';
                        }
                        if(pp.Date_Involvement_Ended__c != null) {
                            u.Non_AECOM_Projects_Summary__c += '[' + Label.Date_Involvement_Ended + ']: ' + pp.Date_Involvement_Ended__c.format() + ', ';
                        }
                        u.Non_AECOM_Projects_Summary__c += String.isNotBlank(pp.Description__c) ? '[' + projectFields.get('Description__c').getDescribe().getLabel() + ']: ' + pp.Description__c : '';
                        u.Non_AECOM_Projects_Summary__c += String.isNotBlank(u.Non_AECOM_Projects_Summary__c) ? '\r\n' : '';

                        // set limit reached and add indicator that more data exists but field cannot hold any more
                        if(u.Non_AECOM_Projects_Summary__c.length() >= nonAecomLimit) {
                            nonAecomLimitReached = true;
                            u.Non_AECOM_Projects_Summary__c = u.Non_AECOM_Projects_Summary__c.subString(0,nonAecomLimit-3) + '...';
                        }
                    }
                }
                updateList.addAll(projects.get(u.Id));
            }
            update users;
            update updateList;
        }
    }

    global void finish(Database.BatchableContext BC) {

    }

}