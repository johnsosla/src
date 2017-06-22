public with sharing class rsSearchResult implements Comparable{
    transient public User user {get; set;}
    transient public rs_Profile_Part__c profilePart {get; set;}
    transient public PR_Team_Employee__c prTeamEmp {get; set;}
    public List<String> cells {get; set;}
    public Boolean Selected {get; set;}
    public String photoURL {get; set;}
    public String userName {get; set;}
    public String userId {get; set;}
    public Integer totalSortPoints {get; set;}

    public rsSearchResult() {
        Selected = false;
        totalSortPoints = 0;
    }

    public rsSearchResult(rs_Profile_Part__c pp, User user, List<SelectOption> data) {
        Selected = false;
        totalSortPoints = 0;
        profilePart = pp;
        this.user = user;
        photoURL = user.smallphotourl;
        userName = String.isNotBlank(user.HR_Full_Name__c) ? user.HR_Full_Name__c : user.LastName + (String.isNotBlank(user.FirstName) ? ', ' + user.FirstName : '');
        userId = user.Id;
        cells = new List<String>();
        for(SelectOption d : data) {
            String cleanString = rsStringUtil.cleanFieldName(d.getValue(),'|');
            String objectName = d.getValue().substring(0,d.getValue().indexOf('|'));
            //trys to getValue for Profile Part first, if exception finds the value from User
            if(objectName == 'rs_Profile_Part__c') {
                if(pp.get(cleanString) != null) {
                    String value = String.valueOf(pp.get(cleanString));
                    if(value.length() >= rsSearchResumesController.MAX_LENGTH_OF_CHAR_RESULT) {
                        this.cells.add(value.substring(0,rsSearchResumesController.MAX_LENGTH_OF_CHAR_RESULT-3) + '...');
                    } else {
                        this.cells.add(value);
                    }
                } else {
                    this.cells.add(' ');
                }
            } else if(objectName == 'User' && cleanString != 'Name') {
                if(user.get(cleanString) != null) {
                    String value = String.valueOf(user.get(cleanString));
                    if(value.length() >= rsSearchResumesController.MAX_LENGTH_OF_CHAR_RESULT) {
                        this.cells.add(value.substring(0,rsSearchResumesController.MAX_LENGTH_OF_CHAR_RESULT-3) + '...');
                    } else {
                        this.cells.add(value);
                    }
                }
                else {
                    this.cells.add(' ');
                }
            } else if(objectName == 'User' && cleanString == 'Name') {
                this.cells.add('DONTUSE');
            } else {
                this.cells.add(' ');
            }
        }
    }

    public rsSearchResult(PR_Team_Employee__c emp, User user, List<SelectOption> data) {
        Selected = false;
        totalSortPoints = 0;
        prTeamEmp = emp;
        this.user = user;
        photoURL = user.smallphotourl;
        userName = String.isNotBlank(user.HR_Full_Name__c) ? user.HR_Full_Name__c : user.LastName + (String.isNotBlank(user.FirstName) ? ', ' + user.FirstName : '');
        userId = user.Id;
        cells = new List<String>();
        for(SelectOption d : data) {
            String cleanString = rsStringUtil.cleanFieldName(d.getValue(),'|');
            String objectName = d.getValue().substring(0,d.getValue().indexOf('|'));
            if(objectName == 'PR_Team_Employee__c') {
                if(emp.get(cleanString) != null) {
                    String value = String.valueOf(emp.get(cleanString));
                    if(value.length() >= rsSearchResumesController.MAX_LENGTH_OF_CHAR_RESULT) {
                        this.cells.add(value.substring(0,rsSearchResumesController.MAX_LENGTH_OF_CHAR_RESULT-3) + '...');
                    } else {
                        this.cells.add(value);
                    }
                } else {
                    this.cells.add(' ');
                }
            } else if(objectName == 'User' && cleanString != 'Name') {
                if(user.get(cleanString) != null) {
                    String value = String.valueOf(user.get(cleanString));
                    if(value.length() >= rsSearchResumesController.MAX_LENGTH_OF_CHAR_RESULT) {
                        this.cells.add(value.substring(0,rsSearchResumesController.MAX_LENGTH_OF_CHAR_RESULT-3) + '...');
                    } else {
                        this.cells.add(value);
                    }
                } else {
                    this.cells.add(' ');
                }
            } else if(objectName == 'User' && cleanString == 'Name') {
                this.cells.add('DONTUSE');
            } else {
                this.cells.add(' ');
            }
        }
    }

    public Integer compareTo(Object compareObj) {
        rsSearchResult compareObject = (rsSearchResult)compareObj;
        if(totalSortPoints < compareObject.totalSortPoints) return 1;
        else if(totalSortPoints > compareObject.totalSortPoints) return -1;
        else return userName.toLowerCase().compareTo(compareObject.userName.toLowerCase());
    }

}