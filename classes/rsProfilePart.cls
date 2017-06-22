/*************************************************************************
*
* PURPOSE: Decorator for profile part
*
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Jason M. Swenski
***************************************************************************/
public class rsProfilePart extends rsModel {

    public static Finder find = new Finder('rs_Profile_Part__c');
    private static final Integer SEARCH_RESULT_SIZE = 1000;
    private static final Integer LIST_SIZE_LIMIT = 10000;
    private static final Map<String, Schema.RecordTypeInfo> mRtInfo;
    static {
        mRtInfo = rs_Profile_Part__c.SObjectType.getDescribe().getRecordTypeInfosByName();
    }

    public rsProfilePart(Id userId, String type) {
        super(new rs_Profile_part__c(User__c = userId,
                                    RecordTypeId = mRtInfo.get(type).getRecordTypeId(), OwnerId = userId)
            );
    }

    public override Integer compareTo(Object compareTo) {
        rsProfilePart compareItem = (rsProfilePart)compareTo;

        if (compareItem.getPartSequence() != null && getPartSequence() != null) {
            if (compareItem.getPartSequence() > getPartSequence()) {
                return -1;
            } else {
                return 1;
            }
        } else {
            return 1;
        }
    }

    public rsProfilePart(rs_Profile_Part__c part) {
        super(part);
    }

    public String getStatus() {
        return (String)mObj.get('Status__c');
    }

    public void setStatus(String status) {
        mObj.put('Status__c', status);
    }

    public Decimal getPartSequence() {
        return (Decimal)mObj.get('Part_Sequence__c');
    }
    public void setPartSequence(Decimal PartSequence) {
        mObj.put('Part_Sequence__c', PartSequence);
    }

    //-- Publication Start --//
    public String getPublicationTitle() {
        return (String)mObj.get('Publication_Title__c');
    }

    public String getPublication() {
        return (String)mObj.get('Publication__c');
    }

    public String getPublicationDate() {
        return mObj.get('Publication_Date__c') != null ? DateTime.newInstance(Date.valueOf(this.mObj.get('Publication_Date__c')), Time.newInstance(0, 0, 0, 0)).format('MM/yyyy')
               : (String)mObj.get('Publication_Date__c');
    }

    public String getPublicationAuthor() {
        return (String)mObj.get('Publication_Author__c');
    }

    public void setPublicationTitle(String pubTitle) {
        mObj.put('Publication_Title__c', pubTitle);
    }

    public void setPublication(String pub) {
        mObj.put('Publication__c', pub);
    }

    public void setPublicationDate(String pubDate) {
        if (String.isNotBlank(pubDate)) {
            List<String> dates = pubDate.split('/');
            if(dates.size() == 2 ) {
                dates.add(1, '01');
                pubDate = String.join(dates, '/');
            }
            mObj.put('Publication_Date__c', Date.parse(pubDate));
        } else {
            mObj.put('Publication_Date__c', null);
        }
    }

    public void setPublicationAuthor(String author) {
        mObj.put('Publication_Author__c', author);
    }
    //-- Publication End --//
    public Boolean isType(String type) {
        return String.valueOf(mRtInfo.get(type).getRecordTypeId()).equals(String.valueOf(mObj.get('RecordTypeId')));
    }

    //-- Certification Start --//
    public String getCertificationTitle() {
        return (String)mObj.get('Certification_Title__c');
    }

    public String getCertificationDescription() {
        return (String)mObj.get('Certification_Description__c');
    }

    public String getDateCertified() {
        return mObj.get('Date_Certified__c') != null ? Date.valueOf(mObj.get('Date_Certified__c')).format()
               : (String) mObj.get('Date_Certified__c');
    }

    public void setCertificationTitle(String certTitle) {
        mObj.put('Certification_Title__c', certTitle);
    }

    public void setCertificationDescription(String certDes) {
        mObj.put('Certification_Description__c', certDes);
    }

    public void setDateCertified(String certDate) {
        if (String.isNotBlank(certDate)) {
            mObj.put('Date_Certified__c', Date.parse(certDate));
        } else {
            mObj.put('Date_Certified__c', null);
        }
    }
    //-- Certification End --//

    //-- Professional Affiliation Start --//
    public String getAssociationName() {
        return (String)mObj.get('Association_Name__c');
    }

    public String getMemberSince() {
        return mObj.get('Member_Since__c') != null ? DateTime.newInstance(Date.valueOf(this.mObj.get('Member_Since__c')), Time.newInstance(0, 0, 0, 0)).format('MM/yyyy') :
               (String) mObj.get('Member_Since__c');
    }

    public String getPosition() {
        return (String)mObj.get('Position__c');
    }

    public String getHeldFrom() {
        return mObj.get('Position_Held_From__c') != null ? DateTime.newInstance(Date.valueOf(this.mObj.get('Position_Held_From__c')), Time.newInstance(0, 0, 0, 0)).format('MM/yyyy') :
               (String) mObj.get('Position_Held_From__c');
    }

    public String getHeldTo() {
        return mObj.get('Position_Held_To__c') != null ? DateTime.newInstance(Date.valueOf(this.mObj.get('Position_Held_To__c')), Time.newInstance(0, 0, 0, 0)).format('MM/yyyy') :
               (String) mObj.get('Position_Held_To__c');
    }

    public void setAssociationName(String assocName) {
        mObj.put('Association_Name__c', assocName);
    }

    public void setMemberSince(String memSince) {
        if (String.isNotBlank(memSince)) {
            List<String> dates = memSince.split('/');
            if(dates.size() == 2) {
                dates.add(1, '01');
                memSince = String.join(dates, '/');
            }
            mObj.put('Member_Since__c', Date.parse(memSince));
        } else {
            mObj.put('Member_Since__c', null);
        }
    }

    public void setHeldTo(String heldTo) {
        if (String.isNotBlank(heldTo)) {
            List<String> dates = heldTo.split('/');
            if(dates.size() == 2) {
                dates.add(1, '01');
                heldTo = String.join(dates, '/');
            }
            mObj.put('Position_Held_To__c', Date.parse(heldTo));
        } else {
            mObj.put('Position_Held_To__c', null);
        }
    }

    public void setHeldFrom(String heldFrom) {
        if (String.isNotBlank(heldFrom)) {
            List<String> dates = heldFrom.split('/');
            if(dates.size() == 2) {
                dates.add(1, '01');
                heldFrom = String.join(dates, '/');
            }
            mObj.put('Position_Held_From__c', Date.parse(heldFrom));
        } else {
            mObj.put('Position_Held_From__c', null);
        }
    }

    public void setPosition(String pos) {
        mObj.put('Position__c', pos);
    }
    //-- Professional Affiliation End --//

    //-- License/Registration Start --//
    public String getLicenseRegistrationName() {
        return (String)mObj.get('License_Registration_Name__c');
    }

    public String getStateProvince() {
        return (String)mObj.get('State_Province__c');
    }

    public String getLicenseRegistrationCountry() {
        return (String)mObj.get('License_Registration_Country__c');
    }

    public void setLicenseRegistrationCountry(String lrCountry) {
        mObj.put('License_Registration_Country__c', lrCountry);
    }

    public String getCountry() {
        return (String)mObj.get('Country__c');
    }

    public String getRegistrationNumber() {
        return (String)mObj.get('Registration_Number__c');
    }

    public String getIssuedDate() {
        return mObj.get('Issued_Date__c') != null ? Date.valueOf(mObj.get('Issued_Date__c')).format()
               : (String)mObj.get('Issued_Date__c');
    }

    public String getExpirationDate() {
        return mObj.get('Expiration_Date__c') != null ? Date.valueOf(mObj.get('Expiration_Date__c')).format()
               : (String)mObj.get('Expiration_Date__c');
    }

    public void setLicenseRegistrationName(String regName) {
        mObj.put('License_Registration_Name__c', regName);
    }

    public void setStateProvince(String spStr) {
        mObj.put('State_Province__c', spStr);
    }

    public void setCountry(String cont) {
        mObj.put('Country__c', cont);
    }

    public void setRegistrationNumber(String regNum) {
        mObj.put('Registration_Number__c', regNum);
    }

    public void setIssuedDate(String issDate) {
        if (String.isNotBlank(issDate)) {
            mObj.put('Issued_Date__c', Date.parse(issDate));
        } else {
            mObj.put('Issued_Date__c', null);
        }
    }

    public void setExpirationDate(String expDate) {
        if (String.isNotBlank(expDate)) {
            mObj.put('Expiration_Date__c', Date.parse(expDate));
        } else {
            mObj.put('Expiration_Date__c', null);
        }
    }
    //-- License/Registration End --//

    //-- Skill Index Start --//
    public String getSkillArea() {
        return (String)this.mObj.get('Skill_Area__c');
    }

    public String getSkill() {
        return (String)this.mObj.get('Skill__c');
    }

    public String getSpecialty() {
        return (String)this.mObj.get('Specialty__c');
    }

    public String getSkillLevel() {
        return (String)this.mObj.get('Skill_Level__c');
    }

    public void setSkillArea(String skillArea) {
        this.mObj.put('Skill_Area__c', skillArea);
    }

    public void setSkill(String skill) {
        this.mObj.put('Skill__c', skill);
    }

    public void setSpecialty(String spec) {
        this.mObj.put('Specialty__c', spec);
    }

    public void setSkillLevel(String skillLvl) {
        this.mObj.put('Skill_Level__c', skillLvl);
    }
    //-- Skill Index End --//

    //-- Education Start --//
    public void setDegree(String degree) {
        this.mObj.put('Degree__c', degree);
    }

    public String getDegree() {
        return (String)this.mObj.get('Degree__c');
    }

    public void setDegreeSpecialty(String degreeSpecialty) {
        this.mObj.put('Degree_Specialty__c', degreeSpecialty);
    }

    public String getDegreeSpecialty() {
        return (String)this.mObj.get('Degree_Specialty__c');
    }

    public void setInstitution(String institution) {
        this.mObj.put('Institution__c', institution);
    }

    public String getInstitution() {
        return (String)this.mObj.get('Institution__c');
    }

    public void setInstitutionCountry(String institutionCountry) {
        this.mObj.put('Institution_Country__c', institutionCountry);
    }

    public String getInstitutionCountry() {
        return (String)this.mObj.get('Institution_Country__c');
    }

    public void setYearObtained(Integer yearObtained) {
        if (yearObtained <= 0) {
            this.mObj.put('Year_Obtained__c', null);
        } else {
            this.mObj.put('Year_Obtained__c', yearObtained);
        }
    }

    public Integer getYearObtained() {
        return Integer.valueOf(this.mObj.get('Year_Obtained__c'));
    }
    //-- Education End --//

    //-- Work History Start --//
    public void setCompanyName(String companyName) {
        this.mObj.put('Company_Name__c', companyName);
    }

    public String getCompanyName() {
        return (String)this.mObj.get('Company_Name__c');
    }

    public void setJobTitle(String JobTitle) {
        this.mObj.put('Job_Title__c', JobTitle);
    }

    public String getJobTitle() {
        return (String)this.mObj.get('Job_Title__c');
    }

    public void setStartDate(String startDate) {
        if (String.isNotBlank(startDate)) {
            List<String> dates = startDate.split('/');
            if(dates.size() == 2) {
                dates.add(1, '01');
                startDate = String.join(dates, '/');
            }
            mObj.put('Start_Date__c', Date.parse(startDate));
        } else {
            mObj.put('Start_Date__c', null);
        }
    }

    public String getStartDate() {
        return this.mObj.get('Start_Date__c') != null ? DateTime.newInstance(Date.valueOf(this.mObj.get('Start_Date__c')), Time.newInstance(0, 0, 0, 0)).format('MM/yyyy') : null;
    }

    public void setEndDate(String endDate) {
        if (String.isNotBlank(endDate)) {
            List<String> dates = endDate.split('/');
            if(dates.size() == 2) {
                dates.add(1, '01');
                endDate = String.join(dates, '/');
            }
            mObj.put('End_Date__c', Date.parse(endDate));
        } else {
            mObj.put('End_Date__c', null);
        }
    }

    public String getEndDate() {
        return this.mObj.get('End_Date__c') != null ? DateTime.newInstance(Date.valueOf(this.mObj.get('End_Date__c')), Time.newInstance(0, 0, 0, 0)).format('MM/yyyy') : null;
    }

    public void setCity(String City) {
        this.mObj.put('City__c', City);
    }

    public String getCity() {
        return (String)this.mObj.get('City__c');
    }

    public void setState(String State) {
        this.mObj.put('State__c', State);
    }

    public String getState() {
        return (String)this.mObj.get('State__c');
    }

    public void setWorkHistoryCountry(String workHistoryCountry) {
        this.mObj.put('Work_History_Country__c', workHistoryCountry);
    }

    public String getWorkHistoryCountry() {
        return (String)this.mObj.get('Work_History_Country__c');
    }

    public String getWorkHistoryState() {
        return (String)this.mObj.get('Work_History_State__c');
    }

    public void setWorkHistoryState(String workHistoryState) {
        this.mObj.put('Work_History_State__c', workHistoryState);
    }

    public void setCurrent(Boolean isCurrent) {
        this.mObj.put('Current__c', isCurrent);
    }
    public Boolean getCurrent() {
        return (Boolean)this.mObj.get('Current__c');
    }

    //-- Work History End --//

    //-- Award Start --//
    public String getAwardTitle() {
        return (String)this.mObj.get('Award_Title__c');
    }

    public String getAwardAgency() {
        return (String)this.mObj.get('Award_Agency__c');
    }

    public String getAwardDate() {
        return this.mObj.get('Award_Date__c') != null ? DateTime.newInstance(Date.valueOf(this.mObj.get('Award_Date__c')), Time.newInstance(0, 0, 0, 0)).format('MM/yyyy')
               : (String)mObj.get('Award_Date__c');
    }

    public void setAwardTitle(String awardTitle) {
        this.mObj.put('Award_Title__c', awardTitle);
    }

    public void setAwardAgency(String awardAgen) {
        this.mObj.put('Award_Agency__c', awardAgen);
    }

    public void setAwardDate(String awardDate) {
        if (awardDate != null && awardDate != '') {
            List<String> dates = awardDate.split('/');
            if(dates.size() == 2 ) {
                dates.add(1, '01');
                awardDate = String.join(dates, '/');
            }
            this.mObj.put('Award_Date__c', Date.parse(awardDate));
        } else {
            this.mObj.put('Award_Date__c', null);
        }
    }
    //-- Award End --//

    //-- Training Start --//
    public void setTrainingName(String trainingName) {
        this.mObj.put('Training_Name__c', trainingName);
    }

    public String getTrainingName() {
        return (String)this.mObj.get('Training_Name__c');
    }

    public void setTrainingDate(String trainingDate) {
        if (String.isNotBlank(trainingDate)) {
            this.mObj.put('Training_Date__c', Date.parse(trainingDate));
        } else {
            this.mObj.put('Training_Date__c', null);
        }
    }

    public String getTrainingDate() {
        String dateString = null;
        if (this.mObj.get('Training_Date__c') != null) {
            dateString = Date.valueOf(this.mObj.get('Training_Date__c')).format();
        }

        return dateString;
    }

    public void setVendor(String vendor) {
        this.mObj.put('Vendor__c', vendor);
    }

    public String getVendor() {
        return (String)this.mObj.get('Vendor__c');
    }
    //-- Training End --//

    public void setOutputOnResume(Boolean outputOnResume) {
        this.mObj.put('Output_on_Resume__c', outputOnResume);
    }

    public Boolean getOutputOnResume() {
        return (Boolean)this.mObj.get('Output_on_Resume__c');
    }

    //-- Language Start --//
    public void setLanguage(String language) {
        this.mObj.put('Skill_Language__c', language);
    }

    public String getLanguage() {
        return (String)this.mObj.get('Skill_Language__c');
    }

    public void setLanguageSkill(String languageSkill) {
        this.mObj.put('Language_Skill__c', languageSkill);
    }

    public String getLanguageSkill() {
        return (String)this.mObj.get('Language_Skill__c');
    }

    public void setLanguageLevel(String languageLevel) {
        this.mObj.put('Language_Level__c', languageLevel);
    }

    public String getLanguageLevel() {
        return (String)this.mObj.get('Language_Level__c');
    }
    //-- Language End --//

    //-- Translate Start --//
    public void setTranslateFrom(String translateFrom) {
        this.mObj.put('Translate_From__c', translateFrom);
    }

    public String getTranslateFrom() {
        return (String)this.mObj.get('Translate_From__c');
    }

    public void setTranslateTo(String translateTo) {
        this.mObj.put('Translate_To__c', translateTo);
    }

    public String getTranslateTo() {
        return (String)this.mObj.get('Translate_To__c');
    }
    //-- Translate End --//

    //--Start SF254 Discipline
    public void setSF254Discipline(String sf254Discipline) {
        this.mObj.put('SF254_Discipline__c', sf254Discipline);
    }

    public String getSF254Discipline() {
        return (String)this.mObj.get('SF254_Discipline__c');
    }

    public void setIsSF254Primary(Boolean isSF254Primary) {
        this.mObj.put('SF254_Is_Primary__c', isSF254Primary);
    }

    public Boolean getIsSF254Primary() {
        Boolean v = (Boolean)this.mObj.get('SF254_Is_Primary__c');
        if (v == null) {
            return false;
        }
        return v;
    }
    //--End SF254 Discipline

    //--Start SF330 Discipline
    public void setSF330Discipline(String sf330Discipline) {
        this.mObj.put('SF330_Discipline__c', sf330Discipline);
    }

    public String getSF330Discipline() {
        return (String)this.mObj.get('SF330_Discipline__c');
    }

    public void setIsSF330Primary(Boolean isSF330Primary) {
        this.mObj.put('SF330_Is_Primary__c', isSF330Primary);
    }

    public Boolean getIsSF330Primary() {
        Boolean v = (Boolean)this.mObj.get('SF330_Is_Primary__c');
        if (v == null) {
            return false;
        }
        return v;
    }
    //--End SF330 Discipline

    //--Start Reference Fields
    public String getReferenceCompanyName() {
        return (String)mObj.get('Reference_Company_Name__c');
    }

    public String getReferenceEmail() {
        return (String)mObj.get('Reference_Email__c');
    }

    public String getReferenceFirstName() {
        return (String)mObj.get('Reference_First_Name__c');
    }

    public String getReferenceLastName() {
        return (String)mObj.get('Reference_Last_Name__c');
    }

    public String getReferencePhone() {
        return (String)mObj.get('Reference_Phone__c');
    }

    public String getReferenceTitle() {
        return (String)mObj.get('Reference_Title__c');
    }

    public void setReferenceCompanyName(String companyName) {
        mObj.put('Reference_Company_Name__c', companyName);
    }

    public void setReferenceEmail(String email) {
        mObj.put('Reference_Email__c', email);
    }

    public void setReferenceFirstName(String firstName) {
        mObj.put('Reference_First_Name__c', firstName);
    }

    public void setReferenceLastName(String lastName) {
        mObj.put('Reference_Last_Name__c', lastName);
    }

    public void setReferencePhone(String phone) {
        mObj.put('Reference_Phone__c', phone);
    }

    public void setReferenceTitle(String title) {
        mObj.put('Reference_Title__c', title);
    }

    public void setReferenceDateLastChecked(String startDate) {
        if (String.isNotBlank(startDate)) {
            mObj.put('Reference_Date_Last_Checked__c', Date.parse(startDate));
        } else {
            mObj.put('Reference_Date_Last_Checked__c', null);
        }
    }

    public String getReferenceDateLastChecked() {
        return this.mObj.get('Reference_Date_Last_Checked__c') != null ? Date.valueOf(this.mObj.get('Reference_Date_Last_Checked__c')).format() : null;
    }
    //--End Reference Fields

    //--Attachment fields

    public String getAttachmentId() {
        return (String)this.mObj.get('Attachment_Id__c');
    }

    public void setAttachmentId(String id) {
        this.mObj.put('Attachment_Id__c', id);
    }

    public String getAttachmentName() {
        return (String)this.mObj.get('Attachment_Name__c');
    }

    public void setAttachmentName(String name) {
        this.mObj.put('Attachment_Name__c', name);
    }

    public Id getNextPart() {
        return (Id)this.mObj.get('Next_Part__c');
    }

    public void setNextPart(Id partId) {
        this.mObj.put('Next_Part__c', partId);
    }

    public Id getPreviousPart() {
        return (Id)this.mObj.get('Previous_Part__c');
    }

    public void setPreviousPart(Id partId) {
        this.mObj.put('Previous_Part__c', partId);
    }

    public String getInitialLocale() {
        return (String) mObj.get('Initial_Locale__c');
    }
    public void setInitialLocale(String locale) {
        mObj.put('Initial_Locale__c', locale);
    }
    public Datetime getDateTimeSentForReview() {
        return (Datetime)mObj.get('Date_Time_Sent_for_Review__c');
    }

    public void setDateTimeSentForReview(Datetime dateTimeSent) {
        mObj.put('Date_Time_Sent_for_Review__c', dateTimeSent);
    }

    public Boolean getIsPendingOrInReview() {
        return (getStatus() == rsProfilePart.S_PENDING) || (getStatus() == rsProfilePart.S_INREVIEW);
    }

    public String getResumeName() {
        return (String) mObj.get('Resume_Name__c');
    }
    public void setResumeName(String name) {
        mObj.put('Resume_Name__c', name);
    }
    public String getResumeTitle() {
        return (String) mObj.get('Resume_Title__c');
    }
    public void setResumeTitle(String title) {
        mObj.put('Resume_Title__c', title);
    }
    public Integer getYearsWithOtherFirms() {
        Integer retVal = 0;
        Decimal years = (Decimal) mObj.get('Years_with_Other_Firms__c');
        if (years != null) {
            retVal = Integer.valueOf(years);
        }
        return retVal;
    }
    public void setYearswithOtherFirms(Integer years) {
        mObj.put('Years_with_Other_Firms__c', years);
    }
    public String getBio() {
        return (String) mObj.get('Bio__c');
    }
    public void setBio(String bio) {
        mObj.put('Bio__c', bio);
    }

    public Id getOwnerId() {
        return (Id)mObj.get('OwnerId');
    }
    public void setOwnerId(Id OwnerId) {
        mObj.put('OwnerId', OwnerId);
    }


    public class Finder extends rsFinder {

        public Finder(String sObjectName) {
            super(sObjectName);
        }

        public List<rsProfilePart> byIdAsSelfOrProxyOrCM(Id userId) {
            List<rsProfilePart> parts = new List<rsProfilePart>();
            List<rs_Profile_Part__c> queryParts
                = (List<rs_Profile_Part__c>)byWhereStr('User__c = ' + rsStringUtil.quote(userId) + ' AND Next_Part__c = null AND Status__c != ' + rsStringUtil.quote(rsProfilePart.S_ARCHIVED) + ' order by Start_Date__c desc');
            for (rs_Profile_Part__c tempPart : queryParts) {
                parts.add(new rsProfilePart(tempPart));
            }
            return parts;
        }

        public List<rsProfilePart> byIdAsEmployee(Id userId) {
            List<rsProfilePart> parts = new List<rsProfilePart>();
            List<rs_Profile_Part__c> queryParts = (List<rs_Profile_Part__c>)byWhereStr('User__c = ' + rsStringUtil.quote(userId) + ' AND Status__c = ' + rsStringUtil.quote(rsProfilePart.S_APPROVED) + ' order by Start_Date__c desc' );
            for (rs_Profile_Part__c tempPart : queryParts) {
                parts.add(new rsProfilePart(tempPart));
            }
            return parts;
        }

        public List<rs_Profile_Part__c> byWhereStr(String whereStr) {
            System.debug('###whereStr: ' + whereStr);
            return (List<rs_Profile_Part__c>)Database.query(getSelect() + ' where ' + whereStr + ' LIMIT ' + SEARCH_RESULT_SIZE);
        }

        public List<rs_Profile_Part__c> byUsers(Set<Id> userIds) {
            return (List<rs_Profile_Part__c>)Database.query(getSelect() + 'where User__c IN: userIds LIMIT ' + SEARCH_RESULT_SIZE);
        }

        public List<rs_Profile_Part__c> byUsersWhereAndOrder(Set<Id> userIds, String whereStr, String sortVal, String sortDir) {
            String whereClause = String.isNotBlank(whereStr) ? '(' + whereStr + ') AND ' : '';
            return (List<rs_Profile_Part__c>)Database.query(getSelect() + 'where ' + whereClause + 'User__c IN: userIds ORDER BY ' + sortVal + ' ' + sortDir);
        }

        public Map<Id, List<rs_Profile_Part__c>> byUsersAsMap(Set<Id> userIds) {

            Map<Id, List<rs_Profile_Part__c>> ret = new Map<Id, List<rs_Profile_Part__c>>();
            for (Id uId : userIds) {
                ret.put(uId, new List<rs_Profile_Part__c>());
            }

            for (rs_Profile_Part__c p : (List<rs_Profile_Part__c>)Database.query(getSelect()
                    + 'where User__c IN: userIds AND Status__c =' + rsStringUtil.quote(rsProfilePart.S_APPROVED)
                    + ' AND Output_on_Resume__c = true and Next_Part__r.Status__c != ' + rsStringUtil.quote(rsProfilePart.S_APPROVED)
                    + ' order by Start_Date__c desc')) {

                ret.get(p.User__c).add(p);
            }
            return ret;
        }

        public List<rs_Profile_Part__c> byUsersAndWhere(String whereStr, Set<Id> userIds) {
            List<rs_Profile_Part__c> rsParts = (List<rs_Profile_Part__c>)Database.query(getSelect() + 'where (' + whereStr + ') AND User__c IN: userIds LIMIT ' + SEARCH_RESULT_SIZE);
            return rsParts;
        }

        public List<rs_Profile_Part__c> byIdList(List<Id> projIds) {
            return byWhereStr('Id IN (\'' + String.join(projIds, '\',\'') + '\')');
        }

        public List<rs_Profile_Part__c> byFindStr(String findStr) {
            String queryString = 'FIND ' + rsStringUtil.quote(findStr) + ' IN ALL FIELDS RETURNING rs_Profile_Part__c(' + getFields() + ')';
            List<List<SObject>> resultList = search.query(queryString);
            System.debug('#### queryString byFindStr rsProfilePart: ' + queryString);
            return (List<rs_Profile_Part__c>)resultList[0];
        }

        public List<rs_Profile_Part__c> getWorkHistoryLookupResults(Id userId) {
            Id workRTId = mRtInfo.get(rsProfilePart.RT_WORK_HISTORY).getRecordTypeId();
            return byWhereStr('User__c = ' + rsStringUtil.quote(userId) + ' AND RecordTypeId = ' + rsStringUtil.quote(workRTId) + ' AND ( (Status__c = ' + rsStringUtil.quote(rsProfilePart.S_APPROVED) + ' AND Next_Part__c = null) OR Status__c IN (' + rsStringUtil.quote(rsProfilePart.S_PENDING) + ',' + rsStringUtil.quote(rsProfilePart.S_INREVIEW) + ') )' );
        }

        // ---- The following 4 methods (and 1 util method) are used on profile reviews ---- //
        //All 4 methods check BOTH the profile part status and the User status
        public List<rs_Profile_Part__c> reviewUnassigned(DateTime searchDateTimeSentForReviewStart, DateTime searchDateTimeSentForReviewStop, String searchLastName, String searchFirstName, String searchGeography, String searchCountry, String searchAssignee, String superGeography, String sortDir) {
            String selectStr = 'SELECT Id, RecordTypeId, Date_Time_Sent_for_Review__c, Status__c, User__r.Profile_Reviewer__c, User__r.Profile_Reviewer__r.Name, User__r.FirstName, User__r.Name, User__r.LastName, User__r.Manager.Name, User__r.Geography__c, User__r.Region__c, User__r.Country, User__r.Office__c, User__r.Business_Line__c, Previous_Part__c, Resume_Name__c, Resume_Title__c, Years_with_Other_Firms__c, Bio__c from rs_Profile_Part__c';
            String whereStr = ' where User__r.Profile_Reviewer__c = null AND Next_Part__c = null AND ( (Status__c =' + rsStringUtil.quote(rsProfilePart.S_INREVIEW) + ' OR Status__c = ' + rsStringUtil.quote(rsProfilePart.S_PENDING) + ') AND (User__r.Status__c =' + rsStringUtil.quote(rsProfile.S_INREVIEW) + ' OR User__r.Status__c = ' + rsStringUtil.quote(rsProfile.S_PENDING) + ') )' ;
            if ( !String.isBlank(superGeography) ) {
                if (rs_Additional_Geography_Countries__c.getInstance(superGeography) != null) {
                    whereStr += ' AND (User__r.supergeography__c LIKE ' + rsStringUtil.quote(superGeography + '%') + ' OR User__r.Country IN ' + createStringInSet(rs_Additional_Geography_Countries__c.getInstance(superGeography).Countries__c) + ') ';
                } else {
                    whereStr += ' AND (User__r.supergeography__c LIKE ' + rsStringUtil.quote(superGeography + '%') + ')';
                }
            }
            whereStr += buildFilterStrForReview(searchDateTimeSentForReviewStart, searchDateTimeSentForReviewStop, searchLastName, searchFirstName, searchGeography, searchCountry, searchAssignee);
            whereStr += ' ORDER BY Date_Time_Sent_for_Review__c ' + sortDir;
            System.debug('###whereStr ' + whereStr);
            return (List<rs_Profile_Part__c>) ( Database.query(selectStr + whereStr));

        }

        public List<rs_Profile_Part__c> reviewAllPending(DateTime searchDateTimeSentForReviewStart, DateTime searchDateTimeSentForReviewStop, String searchLastName, String searchFirstName, String searchGeography, String searchCountry, String searchAssignee, String sortDir) {
            String selectStr = 'SELECT Id, RecordTypeId, Date_Time_Sent_for_Review__c, Status__c, User__r.Profile_Reviewer__c, User__r.Profile_Reviewer__r.Name, User__r.FirstName, User__r.Name, User__r.LastName, User__r.Manager.Name, User__r.Geography__c, User__r.Region__c, User__r.Country, User__r.Office__c, User__r.Business_Line__c, Previous_Part__c, Resume_Name__c, Resume_Title__c, Years_with_Other_Firms__c, Bio__c from rs_Profile_Part__c';
            String whereStr = ' where User__r.Profile_Reviewer__c = null AND Next_Part__c = null AND Status__c = ' + rsStringUtil.quote(rsProfilePart.S_PENDING);
            whereStr += buildFilterStrForReview(searchDateTimeSentForReviewStart, searchDateTimeSentForReviewStop, searchLastName, searchFirstName, searchGeography, searchCountry, searchAssignee);
            whereStr += ' ORDER BY Date_Time_Sent_for_Review__c ' + sortDir;
            System.debug('###whereStr ' + whereStr);
            return (List<rs_Profile_Part__c>) ( Database.query(selectStr + whereStr));

        }

        public List<rs_Profile_Part__c> reviewAssigned(DateTime searchDateTimeSentForReviewStart, DateTime searchDateTimeSentForReviewStop, String searchLastName, String searchFirstName, String searchGeography, String searchCountry, String searchAssignee, String sortDir) {
            String selectStr = 'SELECT Id, RecordTypeId, Date_Time_Sent_for_Review__c, Status__c, User__r.Profile_Reviewer__c, User__r.Profile_Reviewer__r.Name, User__r.FirstName, User__r.Name, User__r.LastName, User__r.Manager.Name, User__r.Geography__c, User__r.Region__c, User__r.Country, User__r.Office__c, User__r.Business_Line__c, Previous_Part__c, Resume_Name__c, Resume_Title__c, Years_with_Other_Firms__c, Bio__c from rs_Profile_Part__c';
            String whereStr = ' where User__r.Profile_Reviewer__c != null AND Next_Part__c = null AND ( (Status__c =' + rsStringUtil.quote(rsProfilePart.S_INREVIEW) + ' OR Status__c = ' + rsStringUtil.quote(rsProfilePart.S_PENDING) + ') AND (User__r.Status__c =' + rsStringUtil.quote(rsProfile.S_INREVIEW) + ' OR User__r.Status__c = ' + rsStringUtil.quote(rsProfile.S_PENDING) + ') )' ;
            whereStr += buildFilterStrForReview(searchDateTimeSentForReviewStart, searchDateTimeSentForReviewStop, searchLastName, searchFirstName, searchGeography, searchCountry, searchAssignee);
            whereStr += ' ORDER BY Date_Time_Sent_for_Review__c ' + sortDir;
            System.debug('###whereStr ' + whereStr);
            return (List<rs_Profile_Part__c>) ( Database.query(selectStr + whereStr));
        }

        public List<rs_Profile_Part__c> reviewAssignedToMe(String id, DateTime searchDateTimeSentForReviewStart, DateTime searchDateTimeSentForReviewStop, String searchLastName, String searchFirstName, String searchGeography, String searchCountry, String searchAssignee, String sortDir) {
            String selectStr = 'SELECT Id, RecordTypeId, Date_Time_Sent_for_Review__c, Status__c, User__r.Profile_Reviewer__c, User__r.Profile_Reviewer__r.Name, User__r.FirstName, User__r.Name, User__r.LastName, User__r.Manager.Name, User__r.Geography__c, User__r.Region__c, User__r.Country, User__r.Office__c, User__r.Business_Line__c, Previous_Part__c, Resume_Name__c, Resume_Title__c, Years_with_Other_Firms__c, Bio__c from rs_Profile_Part__c';
            String whereStr = ' where User__r.Profile_Reviewer__c = :id AND Next_Part__c = null AND ( (Status__c =' + rsStringUtil.quote(rsProfilePart.S_INREVIEW) + ' OR Status__c = ' + rsStringUtil.quote(rsProfilePart.S_PENDING) + ') AND (User__r.Status__c =' + rsStringUtil.quote(rsProfile.S_INREVIEW) + ' OR User__r.Status__c = ' + rsStringUtil.quote(rsProfile.S_PENDING) + ') )' ;
            whereStr += buildFilterStrForReview(searchDateTimeSentForReviewStart, searchDateTimeSentForReviewStop, searchLastName, searchFirstName, searchGeography, searchCountry, searchAssignee);
            whereStr += ' ORDER BY Date_Time_Sent_for_Review__c ' + sortDir;
            System.debug('###whereStr ' + whereStr);
            return (List<rs_Profile_Part__c>) ( Database.query(selectStr + whereStr));
        }

        public List<rs_Profile_Part__c> reviewCompleted(DateTime searchDateTimeSentForReviewStart, DateTime searchDateTimeSentForReviewStop, String searchLastName, String searchFirstName, String searchGeography, String searchCountry, String searchAssignee, String sortDir) {
            String selectStr = 'SELECT Id, RecordTypeId, Date_Time_Sent_for_Review__c, Status__c, User__r.Profile_Reviewer__c, User__r.Profile_Reviewer__r.Name, User__r.FirstName, User__r.Name, User__r.LastName, User__r.Manager.Name, User__r.Geography__c, User__r.Region__c, User__r.Country, User__r.Office__c, User__r.Business_Line__c, Previous_Part__c, Resume_Name__c, Resume_Title__c, Years_with_Other_Firms__c, Bio__c from rs_Profile_Part__c';
            String whereStr = ' where Status__c = ' + rsStringUtil.quote(rsProfilePart.S_APPROVED) + 'AND Next_Part__c = null AND Date_Time_Sent_for_Review__c != null AND User__r.Status__c = ' + rsStringUtil.quote(rsProfile.S_APPROVED);
            whereStr += buildFilterStrForReview(searchDateTimeSentForReviewStart, searchDateTimeSentForReviewStop, searchLastName, searchFirstName, searchGeography, searchCountry, searchAssignee);
            whereStr += ' ORDER BY Date_Time_Sent_for_Review__c ' + sortDir + ' LIMIT ' + LIST_SIZE_LIMIT;
            System.debug('###whereStr ' + whereStr);
            return (List<rs_Profile_Part__c>) ( Database.query(selectStr + whereStr));
        }

        private String buildFilterStrForReview(DateTime searchDateTimeSentForReviewStart, DateTime searchDateTimeSentForReviewStop, String searchLastName, String searchFirstName, String searchGeography, String searchCountry, String searchAssignee) {
            String filterStr = '';
            Boolean isAndAdded = false;
            if (searchDateTimeSentForReviewStart != null && searchDateTimeSentForReviewStop != null ) {
                if (!isAndAdded) {
                    isAndAdded = true;
                    filterStr += ' AND (';
                } else {
                    filterStr += ' AND';
                }
                filterStr += ' (User__r.Date_Time_Sent_for_Review__c >= ' + searchDateTimeSentForReviewStart.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') + ' AND User__r.Date_Time_Sent_for_Review__c <= ' + searchDateTimeSentForReviewStop.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') + ')';
            } else if (searchDateTimeSentForReviewStart != null ) {
                if (!isAndAdded) {
                    isAndAdded = true;
                    filterStr += ' AND (';
                } else {
                    filterStr += ' AND';
                }
                filterStr += ' User__r.Date_Time_Sent_for_Review__c >= ' + searchDateTimeSentForReviewStart.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            } else if (searchDateTimeSentForReviewStop != null ) {
                if (!isAndAdded) {
                    isAndAdded = true;
                    filterStr += ' AND (';
                } else {
                    filterStr += ' AND';
                }
                filterStr += ' User__r.Date_Time_Sent_for_Review__c <= ' + searchDateTimeSentForReviewStop.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            }

            if (String.isNotBlank(searchLastName) ) {
                if (!isAndAdded) {
                    isAndAdded = true;
                    filterStr += ' AND (';
                } else {
                    filterStr += ' AND';
                }
                filterStr += ' User__r.LastName LIKE ' + rsStringUtil.likeQueryQuote(searchLastName);
            }
            if (String.isNotBlank(searchFirstName) ) {
                if (!isAndAdded) {
                    isAndAdded = true;
                    filterStr += ' AND (';
                } else {
                    filterStr += ' AND';
                }
                filterStr += ' User__r.FirstName LIKE ' + rsStringUtil.likeQueryQuote(searchFirstName);
            }
            if (String.isNotBlank(searchGeography) ) {
                if (!isAndAdded) {
                    isAndAdded = true;
                    filterStr += ' AND (';
                } else {
                    filterStr += ' AND';
                }
                filterStr += ' User__r.Geography__c LIKE ' + rsStringUtil.likeQueryQuote(searchGeography);
            }
            if (String.isNotBlank(searchCountry) ) {
                if (!isAndAdded) {
                    isAndAdded = true;
                    filterStr += ' AND (';
                } else {
                    filterStr += ' AND';
                }
                filterStr += ' User__r.Country LIKE ' + rsStringUtil.likeQueryQuote(searchCountry);
            }
            if (String.isNotBlank(searchAssignee) ) {
                if (!isAndAdded) {
                    isAndAdded = true;
                    filterStr += ' AND (';
                } else {
                    filterStr += ' AND';
                }
                filterStr += ' ( User__r.Profile_Reviewer__r.FirstName LIKE ' + rsStringUtil.likeQueryQuote(searchAssignee) + 'OR User__r.Profile_Reviewer__r.LastName LIKE ' + rsStringUtil.likeQueryQuote(searchAssignee) + ')';
            }
            if (isAndAdded) {
                filterStr += ')';
            }
            return filterStr;
        }
        // ---- End Profile Reviews ---- //
    }

    //Record types to catogorize different 'types'
    //of resume parts
    public static final String RT_SF254 = 'SF254';
    public static final String RT_SF330 = 'SF330';
    public static final String RT_AWARD = 'Award';
    public static final String RT_CERTIFICATION = 'Certification';
    public static final String RT_EDUCATION = 'Education';
    public static final String RT_PROF_AFFILIATION = 'Professional Affiliation';
    public static final String RT_FILE = 'File';
    public static final String RT_LANGUAGES = 'Languages';
    public static final String RT_PUBLICATION = 'Publication';
    public static final String RT_REGISTRATION = 'Registration';
    public static final String RT_SKILL_INDEX = 'Skill Index';
    public static final String RT_TRAINING = 'Training';
    public static final String RT_TRANSLATIONS = 'Translations';
    public static final String RT_WORK_HISTORY = 'Work History';
    public static final String RT_PERSONAL = 'Personal';
    public static final String RT_REFERENCE = 'Reference';

    //Statuses for the Status__c field
    public static final String S_APPROVED = 'Approved';
    public static final String S_PENDING = 'Pending';
    public static final String S_INREVIEW = 'In Review';
    public static final String S_ARCHIVED = 'Archived';


}