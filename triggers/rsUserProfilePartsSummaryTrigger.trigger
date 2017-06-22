/*************************************************************************
*
* PURPOSE: Trigger to update User profile parts summary fields
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
***************************************************************************/

trigger rsUserProfilePartsSummaryTrigger on rs_Profile_Part__c (after insert, after update, after delete) {

    // Map of profile parts that will be summarized in user, keys are user Ids
    Map<Id, List<rs_Profile_Part__c>> profileParts = new Map<Id, List<rs_Profile_Part__c>>();
    Set<Id> alreadyAddedPPIds = new Set<Id>();
    Set<Id> userIds = new Set<Id>();

    // Map of Record Types names and their information
    Map<String,Schema.RecordTypeInfo> mRtInfo = rs_Profile_Part__c.SObjectType.getDescribe().getRecordTypeInfosByName();

    //Map of Profile Parts fields, we'll use this for labeling the User summary
    Map<String, Schema.SObjectField> ppFields = Schema.SObjectType.rs_Profile_Part__c.fields.getMap();

    // We'll add the parts that triggered to the map if they are approved
    for(rs_Profile_Part__c pp : Trigger.isUpdate || Trigger.isInsert ? Trigger.new : Trigger.Old) {

        // Check if the profile part is approved and we're not deleting it, add it to the map
        // otherwise we'll add just the user id to grab their approved profile parts
        if(pp.Status__c == rsProfilePart.S_APPROVED && !Trigger.isDelete) {
            if(profileParts.containsKey(pp.User__c)) profileParts.get(pp.User__c).add(pp);
            else profileParts.put(pp.User__c, new List<rs_Profile_Part__c>{pp});
            alreadyAddedPPIds.add(pp.Id);
        }
        userIds.add(pp.User__c);
    }

    List<User> users = [Select Award_Summary__c,Certification_Summary__c,Education_Summary__c,Languages_Summary__c,
                               Professional_Affiliation_Summary__c,Publication_Summary__c,Registration_Summary__c,
                               SF254_Summary__c,SF330_Summary__c,Skill_Index_Summary__c,Training_Summary__c,Translations_Summary__c,
                               Work_History_Summary__c
                        from User
                        where Id IN: userIds ];

    // Set of user ids used in Dynamic SOQL, profileparts.keyset doesn't work requires setting the keyset to a set
    userIds.addAll(profileParts.keySet());

    // Query profile parts that are approved to recreate the the summary fields
    List<rs_Profile_Part__c> queryPP = (List<rs_Profile_Part__c>)Database.query('Select ' + String.join(new List<String>(ppFields.keySet()),',') +
                                                                                ' from rs_Profile_Part__c' +
                                                                                ' where Id NOT IN: alreadyAddedPPIds' +
                                                                                ' AND Status__c = ' + rsStringUtil.quote(rsProfilePart.S_APPROVED) +
                                                                                ' AND User__c IN: userIds');
    // Add the queried Profile Parts to the Map
    for(rs_Profile_Part__c pp : queryPP) {
        if(profileParts.containsKey(pp.User__c)) profileParts.get(pp.User__c).add(pp);
        else profileParts.put(pp.User__c,new List<rs_Profile_Part__c>{pp});
    }

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

        // We'll first clear the fields of old values
        u.Award_Summary__c = '';
        u.Certification_Summary__c = '';
        u.Education_Summary__c = '';
        u.Languages_Summary__c = '';
        u.Professional_Affiliation_Summary__c = '';
        u.Publication_Summary__c = '';
        u.Registration_Summary__c = '';
        u.SF254_Summary__c = '';
        u.SF330_Summary__c = '';
        u.Skill_Index_Summary__c = '';
        u.Training_Summary__c = '';
        u.Translations_Summary__c = '';
        u.Work_History_Summary__c = '';

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

        // Check if user has any previous approved profile parts
        List<rs_Profile_Part__c> userPP = profileParts.containsKey(u.Id) ? profileParts.get(u.Id) : new List<rs_Profile_Part__c>();
        for(rs_Profile_Part__c pp : userPP) {

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
}