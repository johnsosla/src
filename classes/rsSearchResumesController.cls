/*************************************************************************
*
* PURPOSE: Search Resumes Controller
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
***************************************************************************/
public with sharing class rsSearchResumesController {

    private rsSearch mSearch;
    private List<rsSearchResult> mSearchResults;
    private List<rsSearch> mSavedSearches;
    private String mSelectedSavedSearch;
    private Long mSearchDuration;

    private Integer counter; // current offset of the searchResults
    private static final Integer RESULT_SIZE = 10; //number of rows shown in the result table
    private static final Integer SEARCH_RESULTS_SIZE = 1000; //Maximum number of search results returned
    private static final Integer MAX_SEARCH_IDS_SIZE_SOSL = 2000; //Maximum number of rows, user ids, that are returned by sosl search
    private static final Integer MAX_SEARCH_IDS_SIZE_SOQL = 10000; //Maximum number of rows, user ids, that are returned by SOQL search
    public static final Integer MAX_LENGTH_OF_CHAR_RESULT = 32768;

    public Id userId {get; set;}

    private String mTemplateName;
    private String mDownloadLink;
    private Boolean mShowDownloadLink;
    private Boolean searchMade;
    private Boolean mSelectAll;

    private Map<Integer, Map<Id, Boolean>> resultsMap; // Map of the "Search Results", Integer is the order, Map of Id, Boolean is whether the user
    // has been selected for export

    public String oldSearchName {get; set;}

    public rsSearchResumesController() {
        mSearch = new rsSearch();
        mSearchResults = new List<rsSearchResult>();
        mSavedSearches = rsSearch.find.getSearchesByUser(UserInfo.getUserId());
        counter = 0;
        searchMade = false;
        mselectAll = false;
        mSearchDuration = 0;
        resultsMap = new Map<Integer, Map<Id, Boolean>>();
    }

    public PageReference loadAction() {
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('query'))) {
            String query = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('query'), 'UTF-8');
            mSearch.setTextSearch(query);
            basicSearch();
        }
        return null;
    }

    public String getSearchDuration() {
        return mSearchDuration > 0 ? Label.Search_Duration + ' ' + Decimal.valueOf(mSearchDuration) / 1000 + 's' : '';
    }

    public PageReference clearDownload() {
        mShowDownloadLink = false;
        return null;
    }

    public PageReference beginning() {
        setSelectedResults();
        counter = 0;
        return null;
    }

    public PageReference previous() {
        setSelectedResults();
        if ((counter - RESULT_SIZE) < 0) {
            counter = 0;
        } else {
            counter -= RESULT_SIZE;
        }
        return null;
    }

    public PageReference next() {
        setSelectedResults();
        if ((counter + RESULT_SIZE) > resultsMap.size()) {
            counter = resultsMap.size() - Math.mod(resultsMap.size(), RESULT_SIZE);
        } else {
            counter += RESULT_SIZE;
        }
        return null;
    }

    public PageReference end() {
        setSelectedResults();
        if (Math.mod(resultsMap.size(), RESULT_SIZE) == 0) {
            counter = resultsMap.size() - RESULT_SIZE;
        } else {
            counter = resultsMap.size() - Math.mod(resultsMap.size(), RESULT_SIZE);
        }
        return null;
    }

    // Method to update which users are selected in resultsMap
    private void setSelectedResults() {
        Integer i = 0;
        for (rsSearchResult result : mSearchResults) {
            resultsMap.get(i + counter).put(result.userId, result.Selected);
            i++;
        }
    }

    public Map<Integer, Map<Id, Boolean>> getResultsMap() {
        return resultsMap;
    }

    public void setResultsMap(Map<Integer, Map<Id, Boolean>> resMap) {
        resultsMap = resMap;
    }

    public Boolean getDisabledPrevious() {
        return !(counter > 0);
    }

    public Boolean getDisabledNext() {
        return !((counter + RESULT_SIZE) < resultsMap.size());
    }

    public Integer getPageNumber() {
        Integer retValue = 0;
        if (resultsMap.size() != 0) {
            retValue = counter / RESULT_SIZE + 1;
        }
        return retValue;
    }

    public Integer getFromResult() {
        Integer retVal = 0;
        if (resultsMap.size() != 0) {
            retVal = counter + 1;
        }
        return retVal;
    }

    public Integer getToResult() {
        Integer retVal = 0;
        if (resultsMap.size() != 0) {
            retVal = (counter + RESULT_SIZE) > resultsMap.size() ? resultsMap.size() : counter + RESULT_SIZE;
        }
        return retVal;
    }

    public Integer getTotalSearchResults() {
        return resultsMap.size();
    }

    public Integer getTotalPages() {
        Integer retValue = 0;
        if (Math.mod(resultsMap.size(), RESULT_SIZE) > 0) {
            retValue = resultsMap.size() / RESULT_SIZE + 1;
        } else {
            retValue = resultsMap.size() / RESULT_SIZE;
        }
        return retValue;
    }

    public PageReference addRow() {
        mSearch.getConditions().add(new rsSearch.Condition('', '', ''));
        return null;
    }

    public PageReference removeRow() {
        if (mSearch.getConditions().size() > 5) {
            mSearch.getConditions().remove(mSearch.getConditions().size() - 1);
        }
        return null;
    }

    public PageReference setupBasic() {
        resultsMap.clear();
        mSearch.setSearchType(rsSearch.BASIC_SEARCH);
        if (searchMade) {
            mSearch.setConditions(new List<rsSearch.Condition>());
        }
        //AECR-849 blau, Ran into a problem with saving a search and switching views
        //we'll make a new search if this particular situation happens so they don't
        //happen to turn a basic search to an advanced search and vice-versa
        if (String.isNotBlank(mSearch.getId())) {
            mSearch = new rsSearch();
        }
        getSavedSearches();
        searchMade = false;
        return null;
    }

    public PageReference setupAdvanced() {
        resultsMap.clear();
        mSearch.setSearchType(rsSearch.ADVANCED_SEARCH);
        List<rsSearch.Condition> mConditions = mSearch.getConditions();
        while (mConditions.size() < 5) {
            mConditions.add(new rsSearch.Condition('', '', ''));
        }
        //When switching between basic and advanced, default back to the list of 5 conditions
        // and clear basic search conditions if a search was made
        if (mConditions.size() > 5 && !searchMade) {
            mConditions = new List<rsSearch.Condition> {mConditions.get(0),
                    mConditions.get(1),
                    mConditions.get(2),
                    mConditions.get(3),
                    mConditions.get(4)
                                                       };
        } else if (searchMade) {
            mConditions = new List<rsSearch.Condition>();
            for (Integer i = 0; i < 5; i++) {
                mConditions.add(new rsSearch.Condition('', '', ''));
            }
        }
        //AECR-849 blau, Ran into a problem with saving a search and switching views
        //we'll make a new search if this particular situation happens so they don't
        //happen to turn a basic search to an advanced search and vice-versa
        if (String.isNotBlank(mSearch.getId())) {
            mSearch = new rsSearch();
            mSearch.setSearchType(rsSearch.ADVANCED_SEARCH);
            mConditions = new List<rsSearch.Condition>();
            for (Integer i = 0; i < 5; i++) {
                mConditions.add(new rsSearch.Condition('', '', ''));
            }
        }
        mSearch.setConditions(mConditions);
        getSavedSearches();
        searchMade = false;
        return null;
    }

    public PageReference clearLogic() {
        List<rsSearch.Condition> mConditions = mSearch.getConditions();
        mSearch.setFilter('');
        while (mConditions.size() > 5) {
            mConditions.remove(mConditions.size() - 1);
        }
        mSearch.setConditions(mConditions);
        return null;
    }

    public rsSearch getSearch() {
        return mSearch;
    }

    public PageReference setSearch() {
        for (rsSearch rss : mSavedSearches) {
            if (rss.getId() == mSelectedSavedSearch) {
                mSearch = rss;
                mSearch.setSearchType((String)rss.getObj().get('Search_Type__c'));
                mSearch.setFilter((String)rss.getObj().get('Filter_Logic__c'));
                break;
            }
        }
        if (!rsStringUtil.isNullOrEmpty(mSearch.getId())) {
            List<rsSearch.Condition> cond = (List<rsSearch.Condition>)JSON.deserialize((String)mSearch.getObj().get('Search_Fields__c'), List<rsSearch.Condition>.class);
            List<String> selectFields = (List<String>)JSON.deserialize((String)mSearch.getObj().get('Result_Fields__c'), List<String>.class);
            Map<String, rsSearch.Condition> userCond = (Map<String, rsSearch.Condition>)JSON.deserialize((String)mSearch.getObj().get('User_Fields__c'), Map<String, rsSearch.Condition>.class);
            List<rsSearch.Condition> mPRCond = (List<rsSearch.Condition>)JSON.deserialize((String)mSearch.getObj().get('PR_Team_Employee_Fields__c'), List<rsSearch.Condition>.class);
            mSearch.setConditions(cond);
            mSearch.setResultFields(selectFields);
            mSearch.setUserConditions(userCond);
            mSearch.setPRTeamEmployeeConditions(mPRCond);
            moveFieldsRight();
            basicSearch();
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Search_View_Not_Selected));
        }
        return null;
    }

    public List<rsSearchResult> getSearchResults() {
        List<rsSearchResult> results = new List<rsSearchResult>();
        Set<Id> userIds = new Set<Id>();

        // We'll run through and add the i + counter userIds upto i < RESULT_SIZE
        for (Integer i = 0; i < RESULT_SIZE; i++) {
            if (resultsMap.size() > 0 && resultsMap.containsKey(i + counter) && (i + counter) < resultsMap.size()) {
                List<Id> tempList = new List<Id>(resultsMap.get(i + counter).keySet());
                if (tempList.size() > 0) {
                    userIds.add(tempList.get(0));
                }
            } else {
                break;
            }
        }
        // This is where we'll build the results and set whether they are selected
        if (userIds.size() > 0) {
            results = buildResultWithColumns(userIds, true);
            for (rsSearchResult result : results) {
                for (Integer i = 0; i < RESULT_SIZE; i++) {
                    if (resultsMap.containsKey(i + counter) && (i + counter) < resultsMap.size()) {
                        List<Id> tempList = new List<Id>(resultsMap.get(i + counter).keySet());
                        if (result.userId == tempList.get(0)) {
                            result.Selected = resultsMap.get(i + counter).get(result.userId);
                        }
                    } else {
                        break;
                    }
                }
            }
        }
        results.sort();
        mSearchResults = results;  // Might not seem necessary but we'll need this to set selected users
        return results;
    }

    public Boolean getSelectAll() {
        return mSelectAll;
    }

    public void setSelectAll(Boolean selectAll) {
        mSelectAll = selectAll;
    }

    //Selects/Deselects all search results
    public PageReference selectAllSearchResults() {
        for (Integer i : resultsMap.keySet()) {
            Id userId = new List<Id>(resultsMap.get(i).keySet()).get(0);
            resultsMap.get(i).put(userId, mSelectAll);
        }
        return null;
    }

    public void setSelectedSavedSearch(String searchId) {
        mSelectedSavedSearch = searchId;
    }

    public String getSelectedSavedSearch() {
        return mSelectedSavedSearch;
    }

    public List<SelectOption> getSavedSearches() {
        List<SelectOption> options = new List<SelectOption>();
        for (rsSearch rss : mSavedSearches) {
            if (rss.getObj().get('Search_Type__c') == mSearch.getSearchType()) {
                options.add(new SelectOption((Id)rss.getObj().get('Id'), (String)rss.getObj().get('Name')));
            }
        }
        return options;
    }

    //---Basic search entry
    public PageReference basicSearch() {
        counter = 0;
        searchMade = true;
        mSelectAll = false;
        searchFast();
        return null;
    }


    //---The revised and streamlined fast Searching
    private List<rsSearchResult> searchFast() {
        mSearchDuration = 0;

        rsStopWatch swSearch = new rsStopWatch();
        swSearch.reset();
        swSearch.start();

        String searchText = getSearch().getTextSearch().trim();
        getSearch().setConditions(searchText);


        Boolean isBasicSearch = (mSearch.getSearchType() == rsSearch.BASIC_SEARCH);
        Boolean isAdvancedSearch = (mSearch.getSearchType() == rsSearch.ADVANCED_SEARCH);
        Boolean hasKeywordSearch = !(searchText == null || searchText == '');

        Set<Id> foundUserIds = new Set<Id>();

        if (isBasicSearch && hasKeywordSearch) {
            foundUserIds = searchFastKeyword();
        } else if (isBasicSearch && !hasKeywordSearch) {
            foundUserIds = searchFastNoKeyword();
        } else if (isAdvancedSearch) {
            foundUserIds = searchFastAdvanced();
        }

        List<rsSearchResult> results = buildResultWithColumns(foundUserIds, false);
        results.sort();

        resultsMap.clear();
        Integer i = 0;
        for (rsSearchResult result : results) {
            resultsMap.put(i, new Map<Id, Boolean> {result.userId => result.Selected});
            i++;
        }

        //---Sort and display


        //---Record total search time
        mSearchDuration = swSearch.getTime();
        System.debug('#### searchFast DUR:' + mSearchDuration + '  RECORDS: ' + results.size());

        return null;
    }

    //---Build the final list of Users
    private List<rsSearchResult> buildResultWithColumns(Set<Id> foundUserIds, Boolean needsAllData) {
        List<SelectOption> columnList =  getSearch().getSelectedFieldOptions();
        List<SelectOption> noSummaryColumnList = new List<SelectOption>();
        Set<String> userColumns = new Set<String>();
        userColumns.add( 'Id');
        userColumns.add( 'HR_Full_Name__c');
        userColumns.add( 'SmallPhotoUrl');
        userColumns.add( 'FirstName');
        userColumns.add( 'LastName');

        for (SelectOption row : columnList) {
            String cleanString = rsStringUtil.cleanFieldName(row.getValue(), '|');
            String objectName = row.getValue().substring(0, row.getValue().indexOf('|'));


            if (objectName == 'User') {
                if (needsAllData) {
                    userColumns.add(cleanString);
                } else if (!needsAllData && !cleanString.contains('Summary')) {
                    userColumns.add(cleanString);
                    noSummaryColumnList.add(row);
                }
            }
        }

        //---Search for the users to display (sorted)
        rsStopWatch sw = new rsStopWatch();
        sw.start();
        List<User> userList = getUsersWithColumns(foundUserIds, userColumns);
        Long userDur = sw.getTime();
        System.debug('#### searchFast QUERY: getUsersWithColumns');
        System.debug('#### searchFast DUR:' + userDur + '  RECORDS: ' + userList.size());

        //---Build the result list
        List<rsSearchResult> results = new List<rsSearchResult>();
        if (userList != null) {
            for (User row : userList)  {
                if (results.size() < SEARCH_RESULTS_SIZE) {
                    results.add(new rsSearchResult(new rs_Profile_Part__c(), row, (needsAllData ? columnList : noSummaryColumnList)));
                } else {
                    break;
                }
            }

            String searchTextSOQL = getSearch().getTextSearch().normalizeSpace().toLowerCase();
            List<String> searchTextSplit = searchTextSOQL.split(' ', 3);             // We'll split the string into three parts, e.g. Tim A Lewis, [0] = Tim, [1] = A, [2] = Lewis

            String matchWord1 = '';
            String matchWord2 = '';

            if (searchTextSplit.size() > 0) {
                matchWord1 = searchTextSplit[0];    //---Always first word
            }
            if (searchTextSplit.size() == 2) {
                matchWord2 = searchTextSplit[1];    //---If only two words, use the second
            }
            if (searchTextSplit.size() > 2) {
                matchWord2 = searchTextSplit[2];    //---If three or more, then skip a word
            }

            for (rsSearchResult row : results) {
                for (String str : userColumns) {
                    Integer setPoints = 0;

                    if (str.equals('LastName')) {
                        String fieldValue = String.valueOf(row.user.get(str)).toLowerCase();

                        // We'll do a Starts with Match first, checking if the fieldValue starts with either of the match words

                        if (fieldValue.startsWith(matchWord1)) {
                            setPoints = 11;
                        }
                        if (String.isNotBlank( matchWord2) && fieldValue.startsWith(matchWord2)) {
                            setPoints = 11;
                        }

                        // If neither starts with the match words, we'll do a contains match

                        if (setPoints == 0) {
                            if (fieldValue.contains(matchWord1)) {
                                setPoints = 9;
                            }
                            if (String.isNotBlank( matchWord2) && fieldValue.contains(matchWord2)) {
                                setPoints = 9;
                            }
                        }
                    } else if (str.equals('FirstName')) {
                        if (row.user.get(str) != null) {
                            String fieldValue = String.valueOf(row.user.get(str)).toLowerCase();

                            if (fieldValue.startsWith(matchWord1)) {
                                setPoints = 10;
                            }
                            if (String.isNotBlank( matchWord2) && fieldValue.startsWith(matchWord2)) {
                                setPoints = 10;
                            }

                            if (setPoints == 0) {
                                if (fieldValue.contains(matchWord1)) {
                                    setPoints = 8;
                                }
                                if (String.isNotBlank( matchWord2) && fieldValue.contains(matchWord2)) {
                                    setPoints = 8;
                                }
                            }
                        }
                    } else if (str.equals('Title')) {
                        if (row.user.get(str) != null) {
                            String fieldValue = String.valueOf(row.user.get(str)).toLowerCase();
                            if (fieldValue.contains(searchTextSOQL)) {
                                setPoints = 7;
                            }
                        }
                    } else if (str.equals('Business_Line__c')) {
                        if (row.user.get(str) != null) {
                            String fieldValue = String.valueOf(row.user.get(str)).toLowerCase();
                            if (fieldValue.contains(searchTextSOQL)) {
                                setPoints = 6;
                            }
                        }
                    } else if (str.equals('Region__c')) {
                        if (row.user.get(str) != null) {
                            String fieldValue = String.valueOf(row.user.get(str)).toLowerCase();
                            if (fieldValue.contains(searchTextSOQL)) {
                                setPoints = 5;
                            }
                        }
                    } else if (str.equals('Phone')) {
                        if (row.user.get(str) != null) {
                            String fieldValue = String.valueOf(row.user.get(str)).toLowerCase();
                            if (fieldValue.contains(searchTextSOQL)) {
                                setPoints = 4;
                            }
                        }
                    } else if (str.equals('Cisco_IP_Phone__c')) {
                        if (row.user.get(str) != null) {
                            String fieldValue = String.valueOf(row.user.get(str)).toLowerCase();
                            if (fieldValue.contains(searchTextSOQL)) {
                                setPoints = 3;
                            }
                        }
                    } else if (str.equals('Email')) {
                        if (row.user.get(str) != null) {
                            String fieldValue = String.valueOf(row.user.get(str)).toLowerCase();
                            if (fieldValue.contains(searchTextSOQL)) {
                                setPoints = 2;
                            }
                        }
                    } else if (str.equals('City')) {
                        if (row.user.get(str) != null) {
                            String fieldValue = String.valueOf(row.user.get(str)).toLowerCase();
                            if (fieldValue.contains(searchTextSOQL)) {
                                setPoints = 1;
                            }
                        }
                    }

                    row.totalSortPoints += setPoints;
                }
            }
        }

        return results;
    }

    //---Search Fast with Keyword
    private Set<Id> searchFastKeyword() {
        Set<Id> foundUserIds = new Set<Id>();

        String userCriteria = buildUserWhereCriteria('');
        String ppCriteria = buildPPWhereCriteria();
        String prtCriteria = buildPRTWhereCriteria();

        Boolean hasPPCriteria = shouldPPSearch();
        Boolean hasPRTCriteria = shouldPRTSearch();

        Set<Id> foundUsers = new Set<Id>();
        Set<Id> foundPPUsers = new Set<Id>();
        Set<Id> foundPRTUsers = new Set<Id>();

        Set<Id> foundUsersSOQL = new Set<Id>();
        String searchText = getSearch().getTextSearch().normalizeSpace().replaceAll('[|*|?]', '');
        String resultDesc = '';
        if (searchText.length() < 2) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.MIN2CHAR));
            return foundUserIds;
        }

        String queryString = 'FIND ' + rsStringUtil.quote(searchText + '*') + ' IN ALL FIELDS RETURNING ' +
                             'User(Id ' + (String.isNotBlank(userCriteria) ? 'WHERE ' + userCriteria : '') + ' LIMIT ' + MAX_SEARCH_IDS_SIZE_SOSL + '), ' +
                             'rs_Profile_Part__c(User__c WHERE ' + ppCriteria + ' LIMIT ' + MAX_SEARCH_IDS_SIZE_SOSL + '), ' +
                             'PR_Team_Employee__c(EmployeeUser__c WHERE ' + prtCriteria + ' LIMIT ' + MAX_SEARCH_IDS_SIZE_SOSL + ')';
        System.debug('#### searchFast QUERY:' + queryString);



        rsStopWatch sw = new rsStopWatch();
        sw.start();
        List<List<SObject>> soslResultList = search.query(queryString);
        Long soslDur = sw.getTime();

        if (soslResultList.size() > 0) { //---Process Users
            List<User> soslUsers = (List<User>)soslResultList[0];
            for ( User row : soslUsers) {
                foundUsers.add(row.Id);
            }
            resultDesc += ' Users ' + soslUsers.size();
        }
        if (soslResultList.size() > 1) { //---Process Profile Parts
            List<rs_Profile_Part__c> soslPP = (List<rs_Profile_Part__c>)soslResultList[1];
            for ( rs_Profile_Part__c row : soslPP) {
                foundPPUsers.add(row.User__c);
            }
            resultDesc += ' PP ' + soslPP.size();
        }
        if (soslResultList.size() > 2) { //---Process PR Team Employee
            List<PR_Team_Employee__c> soslPrt = (List<PR_Team_Employee__c>)soslResultList[2];
            for ( PR_Team_Employee__c row : soslPrt) {
                foundPRTUsers.add(row.EmployeeUser__c);
            }
            resultDesc += ' PRT ' + soslPrt.size();
        }

        System.debug('#### searchFast DUR:' + soslDur + ' RESULTS:' + resultDesc);

        String userSoqlTextSearch = userCriteria;
        if (String.isNotBlank(userSoqlTextSearch)) {
            userSoqlTextSearch += ' AND ';
        }
        userSoqlTextSearch += buildUserSOQLWhereCriteria();

        sw.reset();
        sw.start();
        System.debug('#### searchFast QUERY:' + userSoqlTextSearch);
        List<User> soqlUsers = (List<User>)Database.query('SELECT Id FROM User WHERE ' + userSoqlTextSearch + ' LIMIT ' + MAX_SEARCH_IDS_SIZE_SOQL);
        Long userDur = sw.getTime();
        for ( User row : soqlUsers) {
            foundUsersSOQL.add(row.Id);
        }
        System.debug('#### searchFast, User 2nd SOQL DUR:' + userDur + ' RESULTS:' + soqlUsers.size());


        //---Union all the Sets
        foundUserIds.addAll(foundUsers);
        foundUserIds.addAll(foundUsersSOQL);
        foundUserIds.addAll(foundPRTUsers);

        if (shouldPPSearch()) {
            //---Need to re-filter all results based on the PP criteria
            Set<Id> foundPPPart2Users = new Set<Id>();

            sw.reset();
            sw.start();
            List<rs_Profile_Part__c> soqlPP = (List<rs_Profile_Part__c>)Database.query('SELECT User__c FROM rs_Profile_Part__c WHERE ' + ppCriteria + ' AND User__c IN :foundUserIds LIMIT ' + MAX_SEARCH_IDS_SIZE_SOQL);
            Long ppDur = sw.getTime();
            for ( rs_Profile_Part__c row : soqlPP) {
                foundPPPart2Users.add(row.User__c);
            }
            System.debug('#### searchFast, non-keyword, PP2 SOQL DUR:' + ppDur + ' RESULTS:' + foundPPUsers.size());

            foundUserIds = foundPPPart2Users;
        }

        //---This appears to be strange here, but it is for performance.  These Users have aleady passed the PP filter, and therefore do not need to be passed into the Re-filter.
        //---This is cutting down on the IDs passed into the re-filter (for performance), but we need to Union them back into the results in case these keywords only existed in the PP parts.
        foundUserIds.addAll(foundPPUsers);

        return foundUserIds;
    }

    //---Search fast without keyword  (There are no PRT fields on the basic search, so without keyword, there is no searching that object)
    private Set<Id> searchFastNoKeyword() {
        Set<Id> foundUserIds = new Set<Id>();

        String userCriteria = buildUserWhereCriteria('');
        String ppCriteria = buildPPWhereCriteria();

        Boolean hasPPCriteria = shouldPPSearch();

        Set<Id> foundUsers = new Set<Id>();
        Set<Id> foundPPUsers = new Set<Id>();

        rsStopWatch sw = new rsStopWatch();

        if (hasPPCriteria) {               //---UserIds must reside in PP List
            sw.start();
            List<rs_Profile_Part__c> soqlPP = (List<rs_Profile_Part__c>)Database.query('SELECT User__c FROM rs_Profile_Part__c WHERE ' + ppCriteria + ' LIMIT ' + MAX_SEARCH_IDS_SIZE_SOQL);
            Long ppDur = sw.getTime();
            for ( rs_Profile_Part__c row : soqlPP) {
                foundPPUsers.add(row.User__c);
            }
            System.debug('#### searchFast, non-keyword, PP SOQL: ' + ppCriteria + ' DUR:' + ppDur + ' RESULTS:' + foundPPUsers.size());

            foundUserIds = foundPPUsers;
        } else {
            //---Get the User SOQL
            sw.start();
            List<User> soqlUsers = (List<User>)Database.query('SELECT Id FROM User WHERE ' + userCriteria + ' LIMIT ' + MAX_SEARCH_IDS_SIZE_SOQL);
            Long userDur = sw.getTime();
            for ( User row : soqlUsers) {
                foundUsers.add(row.Id);
            }
            System.debug('#### searchFast, non-keyword, User SOQL: ' + userCriteria + ' DUR:' + userDur + ' RESULTS:' + foundUsers.size());

            foundUserIds = foundUsers;
        }

        return foundUserIds;
    }

    //---Get the populated list of Users based on the Set
    private List<User> getUsersWithColumns(Set<Id> userIds, Set<String> fields) {
        return new List<User>((List<User>)Database.query('SELECT ' + String.join(new List<String>(fields), ',') + ' FROM User WHERE Id IN :userIds'));
    }

    //---Get PP Criteria String
    private String buildUserWhereCriteria(String userReference) {
        String whereStr = '';

        String firstName = mSearch.getFirstName();
        String lastName = mSearch.getLastName();
        String geography = mSearch.getGeography();
        String officeLocation = mSearch.getOfficeLocation();
        String businessLine = mSearch.getBusinessLine();
        String country = mSearch.getCountry();
        String certifiedPm = mSearch.getCertifiedPm();

        rsSearch.Condition activeCond = getSearch().getUserConditions().get('active');

        if (String.isNotBlank(firstName)) {
            if (String.isNotBlank(whereStr)) {
                whereStr += ' AND ';
            }
            whereStr += '(' + userReference + 'FirstName LIKE ' + rsStringUtil.quote(firstName + '%') +
                        ' OR ' + userReference + 'FirstName LIKE ' + rsStringUtil.quote('% ' + firstName + '%') + ')';
        }
        if (String.isNotBlank(lastName)) {
            if (String.isNotBlank(whereStr)) {
                whereStr += ' AND ';
            }
            whereStr += '(' + userReference + 'LastName LIKE ' + rsStringUtil.quote(lastName + '%') +
                        ' OR ' + userReference + 'LastName LIKE ' + rsStringUtil.quote('% ' + lastName + '%') + ')';
        }
        if (String.isNotBlank(geography)) {
            if (String.isNotBlank(whereStr)) {
                whereStr += ' AND ';
            }
            whereStr += userReference + 'Geography__c = ' + rsStringUtil.quote(geography);
        }
        if (String.isNotBlank(officeLocation)) {
            if (String.isNotBlank(whereStr)) {
                whereStr += ' AND ';
            }
            whereStr += userReference + 'Office__c = ' + rsStringUtil.quote(officeLocation);
        }
        if (String.isNotBlank(businessLine)) {
            if (String.isNotBlank(whereStr)) {
                whereStr += ' AND ';
            }
            whereStr += userReference + 'Business_Line__c = ' + rsStringUtil.quote(businessLine);
        }
        if (String.isNotBlank(country)) {
            if (String.isNotBlank(whereStr)) {
                whereStr += ' AND ';
            }
            whereStr += userReference + 'Country = ' + rsStringUtil.quote(country);
        }
        if (String.isNotBlank(certifiedPm)) {
            if (String.isNotBlank(whereStr)) {
                whereStr += ' AND ';
            }
            whereStr += 'Certified_PM__c = ' + rsStringUtil.quote(certifiedPm);
        }
        if (activeCond.value == 'false') {
            if (String.isNotBlank(whereStr)) {
                whereStr += ' AND ';
            }
            whereStr += userReference + 'IsActive = true';
        }
        

        // Remove test users from search results
        if (String.isNotBlank(whereStr)) {
            whereStr += ' AND ';
        }
        whereStr += userReference + 'Non_Employee__c = false';

        return whereStr;
    }

    // This builds the where String for our User SOQL search for fields left out by SOSL
    private String buildUserSOQLWhereCriteria() {
        //---Add the second User Search for standard fields that are not covered by SOSL
        String searchTextSOQL = getSearch().getTextSearch().normalizeSpace();
        List<String> searchTextSplit = searchTextSOQL.split(' ', 3);             // We'll split the string into three parts, e.g. Tim A Lewis, [0] = Tim, [1] = A, [2] = Lewis
        String searchPart = ' LIKE ' + rsStringUtil.quote(searchTextSOQL + '%'); // This will find phrases that start with the search text, e.g. if searchText = benefits, then Benefits Manager
        String searchPart2 = ' LIKE ' + rsStringUtil.quote('% ' + searchTextSOQL + '%'); // This will find phrases that contain the search text, but starting as a separate word,
        //e.g. if searchText = benefits then Vice President, Benefits.
        // This is to search for user names when people use the key word Search
        String searchUserName = '';

        // Creating the where part for user name
        // Pretty simple for 1, we'll just check first and last
        if (searchTextSplit.size() == 1) {
            searchUserName = 'OR (FirstName LIKE ' + rsStringUtil.quote(searchTextSplit[0] + '%') + ' OR LastName LIKE ' + rsStringUtil.quote(searchTextSplit[0] + '%') + ')';

            // We'll make a permutation for First and Last of [0] and [1] and vice versa
        } else if (searchTextSplit.size() == 2) {
            searchUserName = ' OR (FirstName LIKE ' + rsStringUtil.quote(searchTextSplit[0] + '%') + ' AND LastName LIKE ' + rsStringUtil.quote(searchTextSplit[1] + '%') +
                             ') OR (FirstName LIKE ' + rsStringUtil.quote(searchTextSplit[1] + '%') + ' AND LastName LIKE ' + rsStringUtil.quote(searchTextSplit[0] + '%') +
                             ')';

            // If they include a middle name or initial we'll do the same thing as if there's two but just for [0] and [2]
        } else if (searchTextSplit.size() == 3) {
            searchUserName = ' OR (FirstName LIKE ' + rsStringUtil.quote(searchTextSplit[0] + '%') + ' AND LastName LIKE ' + rsStringUtil.quote(searchTextSplit[2] + '%') +
                             ') OR (FirstName LIKE ' + rsStringUtil.quote(searchTextSplit[2] + '%') + ' AND LastName LIKE ' + rsStringUtil.quote(searchTextSplit[0] + '%') +
                             ')';
        }
        String userSoqlTextSearch = '';
        userSoqlTextSearch += '(MobilePhone' + searchPart + ' OR MobilePhone' + searchPart2 + ' OR Department' + searchPart + ' OR Department' + searchPart2 +
                              ' OR EmployeeNumber' + searchPart + ' OR EmployeeNumber' + searchPart2 + ' OR Extension' + searchPart + ' OR Extension' + searchPart2 + ' OR Fax' + searchPart +
                              ' OR Fax' + searchPart2 + ' OR Country ' + searchPart + ' OR Country ' + searchPart2 + ' OR Title' + searchPart + ' OR Title' + searchPart2 + ' OR City' + searchPart +
                              ' OR City' + searchPart2 + ' OR PostalCode' + searchPart + ' OR PostalCode' + searchPart2 + ' OR State' + searchPart + ' OR State' + searchPart2 +
                              ' OR Street' + searchPart + ' OR Street' + searchPart2  + searchUserName + ')';
        return userSoqlTextSearch;
    }

    //---Should it search on PP for the Search
    public Boolean shouldPPSearch() {
        String licRegName = mSearch.getLicenseRegistration();
        String licRegCountry = mSearch.getLicenseRegistrationCountry();

        return String.isNotBlank(licRegName) || String.isNotBlank(licRegCountry);
    }

    //---Get PP Criteria String
    private String buildPPWhereCriteria() {
        String whereStr = '';

        String licRegName = mSearch.getLicenseRegistration();
        String licRegCountry = mSearch.getLicenseRegistrationCountry();
        

        if (String.isNotBlank(licRegName)) {
            whereStr += 'License_Registration_Name__c = ' + rsStringUtil.quote(licRegName);
        }
        if (String.isNotBlank(licRegCountry)) {
            if (String.isNotBlank(whereStr)) {
                whereStr += ' AND ';
            }
            whereStr += 'License_Registration_Country__c = ' + rsStringUtil.quote(licRegCountry);
        }

        if (String.isNotBlank(whereStr)) {
            whereStr += ' AND ';
        }
        whereStr += 'User__c != null';

        String userWhere = buildUserWhereCriteria('User__r.');
        if (String.isNotBlank(userWhere)) {
            whereStr += ' AND ' + userWhere;
        }

        return whereStr;
    }

    public Boolean shouldPRTSearch() {
        Boolean shouldSearch = false;
        return shouldSearch;
    }

    //---Get PP Criteria String
    private String buildPRTWhereCriteria() {
        String whereStr = 'EmployeeUser__c != null';

        String userWhere = buildUserWhereCriteria('EmployeeUser__r.');
        if (String.isNotBlank(userWhere)) {
            whereStr += ' AND ' + userWhere;
        }

        return whereStr;
    }

    //---Search Fast, advanced criteria
    private Set<Id> searchFastAdvanced() {
        String filterLogic = mSearch.getFilter();

        Integer userCondSize = 0;
        Integer ppCondSize = 0;
        Integer prtCondSize = 0;
        List<String> userWhereParts = new List<String>();
        List<String> ppWhereParts = new List<String>();
        List<String> prtWhereParts = new List<String>();

        Integer totalValidWhere = 0;
        Integer maxValidWherePos = 0;
        Boolean hasBlankWhere = false;
        Boolean hasSkippedWhere = false;

        //---Build the lists of conditions
        try {
            for (rsSearch.Condition cond : mSearch.getConditions()) {
                if (String.isNotBlank( cond.field) && String.isNotBlank( cond.operator) && String.isNotBlank(cond.value)) {
                    String objectName = cond.field.substring(0, cond.field.indexOf('|'));
                    String fieldName = rsStringUtil.cleanFieldName(cond.field, '|');
                    Schema.DisplayType dispType = cond.getDisplayType(objectName, fieldName);
                    String wherePart = buildWherePart(fieldName, cond.operator, cond.value, dispType);

                    if (String.isNotBlank(wherePart)) {
                        if (objectName == 'User') {
                            userCondSize++;
                            userWhereParts.add( wherePart);

                            //---Add the User WHEREs to the tables with lookup relationships
                            ppWhereParts.add( 'User__r.' + wherePart);
                            prtWhereParts.add( 'EmployeeUser__r.' + wherePart);
                        }
                        if (objectName == 'rs_Profile_Part__c') {
                            ppCondSize++;
                            ppWhereParts.add( wherePart);
                        }
                        if (objectName == 'PR_Team_Employee__c') {
                            prtCondSize++;
                            prtWhereParts.add( wherePart);
                        }

                        totalValidWhere++;
                        if (hasBlankWhere) {
                            hasSkippedWhere = true;     //--Track if a valid where follows a non valid one
                        } else {
                            maxValidWherePos++;         //---Increment the counter of contiguous non blank wheres
                        }
                    } else {
                        hasBlankWhere = true;           //---Should only happen at the end of the valid list
                    }
                } else {
                    hasBlankWhere = true;               //---Should only happen at the end of the valid list
                }
            }
        } catch (rsStringUtil.InvalidDateFormatException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Invalid_Date_Error));
            return new Set<Id>();
        }

        if (totalValidWhere == 0) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.One_Valid_Criteria_Error));
            return new Set<Id>();
        }

        //---Build the WHERE string
        String userWhereStr = '';
        String ppWhereStr = '';
        String prtWhereStr = '';

        if (String.isNotBlank(filterLogic)) {
            if (totalValidWhere != maxValidWherePos) {
                System.debug('### TotalvalidWhere: ' + totalValidWhere + ' maxValidWherePos: ' + maxValidWherePos);
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Skipped_Criteria_Line));
                return new Set<Id>();
            }

            //---Special search filter logic, can only search one table (with lookup to user)
            if (ppCondSize > 0 && prtCondSize > 0) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Filter_On_Profile_Parts_And_Projects));
                return new Set<Id>();
            } else if (ppCondSize > 0 || prtCondSize > 0) {
                if (ppCondSize > 0) {
                    ppWhereStr = buildLogicSplitWhere(filterLogic, ppWhereParts, maxValidWherePos);
                }
                if (prtCondSize > 0) {
                    prtWhereStr = buildLogicSplitWhere(filterLogic, prtWhereParts, maxValidWherePos);
                }
            } else if (userCondSize > 0) {
                //---Only if no pp or prt should we search user only
                userWhereStr = buildLogicSplitWhere(filterLogic, userWhereParts, maxValidWherePos);
            } else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.No_Criteria));
                return new Set<Id>();
            }
        } else {
            //---No special filter logic, this means all ANDs, and can searh all tables
            if (ppCondSize > 0 || prtCondSize > 0) {
                if (ppCondSize > 0) {
                    //---Build the PP Where String
                    for (String row : ppWhereParts) {
                        if (String.isNotBlank(ppWhereStr)) {
                            ppWhereStr += ' AND ';
                        }
                        ppWhereStr += row;
                    }
                }
                if (prtCondSize > 0) {
                    //---Build the PP Where String
                    for (String row : prtWhereParts) {
                        if (String.isNotBlank(prtWhereStr)) {
                            prtWhereStr += ' AND ';
                        }
                        prtWhereStr += row;
                    }
                }
            } else if (userCondSize > 0) {
                //---Only if no pp or prt should we search user only
                for (String row : userWhereParts) {
                    if (String.isNotBlank(userWhereStr)) {
                        userWhereStr += ' AND ';
                    }
                    userWhereStr += row;
                }
            } else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.No_Criteria));
                return new Set<Id>();
            }
        }

        // We'll add the condition of whether to check all users or only inactive users here
        rsSearch.Condition activeCond = getSearch().getUserConditions().get('active');
        if (activeCond.value == 'false') {
            if (String.isNotBlank(userWhereStr)) {
                userWhereStr = '(' + userWhereStr + ') AND IsActive = true';
            }

            if (String.isNotBlank(ppWhereStr)) {
                ppWhereStr = '(' + ppWhereStr + ') AND User__r.IsActive = true';
            }

            if (String.isNotBlank(prtWhereStr)) {
                prtWhereStr = '(' + prtWhereStr + ') AND EmployeeUser__r.IsActive = true';
            }
        }
        // Remove test users from search results

        if (String.isNotBlank(userWhereStr)) {
            userWhereStr = '(' + userWhereStr + ') AND Non_Employee__c = false';
        }
        if (String.isNotBlank(ppWhereStr)) {
            ppWhereStr = '(' + ppWhereStr + ') AND User__r.Non_Employee__c = false';
        }
        if (String.isNotBlank(prtWhereStr)) {
            prtWhereStr = '(' + prtWhereStr + ') AND EmployeeUser__r.Non_Employee__c = false';
        }


        //---Run the search
        return runAdvancedSoql(userWhereStr, ppWhereStr, prtWhereStr);
    }

    //---Build the custom logic block
    private String buildLogicSplitWhere(String filterLogic, List<String> whereParts, Integer maxValidWherePos) {
        String outputString = '';
        String currString = filterLogic;

        while (String.isNotBlank(currString)) {
            if (currString.startsWith('(') || currString.startsWith(')') || currString.startsWith(' ')) {
                outputString += currString.substring(0, 1);                                     //---Transfer paren or space
                currString = (currString.length() > 1) ? currString.substring(1) : '';          //---Remove one character
            } else if (currString.toUpperCase().startsWith('AND')) {
                outputString += currString.substring(0, 3);                                     //---Transfer AND
                if (!outputString.endsWith(' ')) {
                    outputString += ' ';
                }
                currString = (currString.length() > 3) ? currString.substring(3) : '';          //---Remove 3 characters
            } else if (currString.toUpperCase().startsWith('OR')) {
                outputString += currString.substring(0, 2);                                     //---Transfer OR
                if (!outputString.endsWith(' ')) {
                    outputString += ' ';
                }
                currString = (currString.length() > 2) ? currString.substring(2) : '';          //---Remove 2 characters
            } else if (currString.length() > 2 && currString.substring(0, 3).isNumeric()) {                                //---Three digit numeric
                Integer wherePos = Integer.valueOf(currString.substring(0, 3));

                if (wherePos > maxValidWherePos || wherePos > whereParts.size() || wherePos <= 0) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Referenced_Number_Left + ' ' + wherePos + ' ' + Label.Referenced_Number_Right));
                    currString = '';
                    outputString = '';
                    break;
                }

                if (!outputString.endsWith(' ')) {
                    outputString += ' ';
                }
                outputString += whereParts[wherePos - 1];                                   //---Add the selected where
                currString = (currString.length() > 3) ? currString.substring(3) : '';      //---Remove 2 characters
            } else if (currString.length() > 1 && currString.substring(0, 2).isNumeric()) {                                //---Two digit numeric
                Integer wherePos = Integer.valueOf(currString.substring(0, 2));

                if (wherePos > maxValidWherePos || wherePos > whereParts.size() || wherePos <= 0) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Referenced_Number_Left + ' ' + wherePos + ' ' + Label.Referenced_Number_Right));
                    currString = '';
                    outputString = '';
                    break;
                }

                if (!outputString.endsWith(' ')) {
                    outputString += ' ';
                }
                outputString += whereParts[wherePos - 1];                                   //---Add the selected where
                currString = (currString.length() > 2) ? currString.substring(2) : '';      //---Remove 2 characters
            } else if (currString.length() > 0 && currString.substring(0, 1).isNumeric()) {                               //---One digit numeric
                Integer wherePos = Integer.valueOf(currString.substring(0, 1));

                if (wherePos > maxValidWherePos || wherePos > whereParts.size() || wherePos <= 0) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Referenced_Number_Left + ' ' + wherePos + ' ' + Label.Referenced_Number_Right));
                    currString = '';
                    outputString = '';
                    break;
                }

                if (!outputString.endsWith(' ')) {
                    outputString += ' ';
                }
                outputString += whereParts[wherePos - 1];                                   //---Add the selected where
                currString = (currString.length() > 1) ? currString.substring(1) : '';      //---Remove 1 characters
            } else {                                                                        //---Unknown character
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Invalid_Characters_Filter_Logic + ' ' + currString));
                currString = '';
                outputString = '';
                break;
            }
        }

        return outputString;
    }

    //---Build the WHERE part
    private String buildWherePart(String field, String operator, String value, Schema.DisplayType dispType) {
        String returnString = '';

        if (dispType == Schema.DisplayType.DateTime || dispType == Schema.DisplayType.Date) {
            if (dispType == Schema.DisplayType.DateTime) {
                field = 'day_only(' + field + ')';    // Only search on date portion for datetime fields
            }
            value = rsStringUtil.convertDateStringToSoqlFormat(value);

            // Soql date literals should not be quoted.
            if (operator == 'e') {
                returnString = field + ' = ' + value;
            } else if (operator == 'ne') {
                returnString = field + ' != ' + value;
            } else if (operator == 'lt') {
                returnString = field + ' < ' + value;
            } else if (operator == 'gt') {
                returnString = field + ' > ' + value;
            } else if (operator == 'loe') {
                returnString = field + ' <= ' + value;
            } else if (operator == 'goe') {
                returnString = field + ' >= ' + value;
            }

        } else if (dispType != Schema.DisplayType.TextArea) {


            if (operator == 'e') {
                returnString = field + ' = ' + rsStringUtil.quote(value);
            } else if (operator == 'ne') {
                returnString = field + ' != ' + rsStringUtil.quote(value);
            } else if (operator == 'c' || operator == 'i') {
                returnString = field + ' LIKE ' + rsStringUtil.quote('%' + value + '%');
            } else if (operator == 'sw') {
                returnString = field + ' LIKE ' + rsStringUtil.quote(value + '%');
            } else if (operator == 'dnc' || operator == 'x') {
                returnString = '(NOT (' + field + ' LIKE ' + rsStringUtil.quote('%' + value + '%') + '))';
            } else if (operator == 'lt') {
                returnString = field + ' < ' + rsStringUtil.quote(value);
            } else if (operator == 'gt') {
                returnString = field + ' > ' + rsStringUtil.quote(value);
            } else if (operator == 'loe') {
                returnString = field + ' <= ' + rsStringUtil.quote(value);
            } else if (operator == 'goe') {
                returnString = field + ' >= ' + rsStringUtil.quote(value);
            }
        } else {
            if (operator == 'c' || operator == 'i') {
                returnString = field + ' LIKE ' + rsStringUtil.quote('%' + value + '%');
            } else if (operator == 'dnc' || operator == 'x') {
                returnString = '(NOT (' + field + ' LIKE ' + rsStringUtil.quote('%' + value + '%') + '))';
            }
        }
        return returnString;
    }


    //---Receive the where criteria and run the appropriate SOQL
    private Set<Id> runAdvancedSoql(String userCriteria, String ppCriteria, String prtCriteria) {
        Boolean isUserSoql = String.isNotBlank(userCriteria);
        Boolean isPPSoql = String.isNotBlank(ppCriteria);
        Boolean isPRTSoql = String.isNotBlank(prtCriteria);

        rsStopWatch sw = new rsStopWatch();

        Set<Id> foundUserIds = new Set<Id>();

        Set<Id> foundUsers = new Set<Id>();
        Set<Id> foundPPUsers = new Set<Id>();
        Set<Id> foundPRTUsers = new Set<Id>();

        if (isUserSoql) { //---Run User
            sw.start();
            System.debug('#### searchFast, User SOQL ' + userCriteria);

            List<User> soqlUsers = (List<User>)Database.query('SELECT Id FROM User WHERE ' + userCriteria + ' LIMIT ' + MAX_SEARCH_IDS_SIZE_SOQL);
            Long userDur = sw.getTime();
            for ( User row : soqlUsers) {
                foundUsers.add(row.Id);
            }
            System.debug('#### searchFast, User SOQL DUR:' + userDur + ' RESULTS:' + foundUsers.size());
        }
        if (isPPSoql) { //---Run PP
            sw.reset();
            sw.start();
            System.debug('#### searchFast, User SOQL ' + ppCriteria);
            List<rs_Profile_Part__c> soqlPP = (List<rs_Profile_Part__c>)Database.query('SELECT User__c FROM rs_Profile_Part__c WHERE ' + ppCriteria + ' LIMIT ' + MAX_SEARCH_IDS_SIZE_SOQL);
            Long ppDur = sw.getTime();
            for ( rs_Profile_Part__c row : soqlPP) {
                foundPPUsers.add(row.User__c);
            }
            System.debug('#### searchFast, PP SOQL DUR:' + ppDur + ' RESULTS:' + foundPPUsers.size());
        }
        if (isPRTSoql) { //---Run PRT
            sw.reset();
            sw.start();
            System.debug('#### searchFast, User SOQL ' + prtCriteria);
            List<PR_Team_Employee__c> soqlPRT = (List<PR_Team_Employee__c>)Database.query('SELECT EmployeeUser__c FROM PR_Team_Employee__c WHERE ' + prtCriteria + ' LIMIT ' + MAX_SEARCH_IDS_SIZE_SOQL);
            Long prtDur = sw.getTime();
            for ( PR_Team_Employee__c row : soqlPRT) {
                foundPRTUsers.add(row.EmployeeUser__c);
            }
            System.debug('#### searchFast, PRT SOQL DUR:' + prtDur + ' RESULTS:' + foundPRTUsers.size());
        }

        if (isPPSoql && isPRTSoql) { //---If running two queries, then intersect for results.  This would be a full AND set of conditions, NO OR or custom logic allowed.
            foundUserIds = foundPPUsers;
            foundUserIds.retainAll(foundPRTUsers);
        } else if (isPPSoql) {      //---PP Only or joined with User conditions
            foundUserIds = foundPPUsers;
        } else if (isPRTSoql) {     //---PRT Only or joined with User conditions
            foundUserIds = foundPRTUsers;
        } else if (isUserSoql) {    //---User Only
            foundUserIds = foundUsers;
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.No_Criteria));
        }

        return foundUserIds;
    }

    // Checks if user's profile is a Content Manager
    public Boolean getIsContentManager() {
        return Profile_Info__c.getInstance().Is_Content_Manager__c;
    }

    //Adds columns to Result Table
    public PageReference moveFieldsRight() {
        List<String> resFields = getSearch().getResultFields();
        List<SelectOption> resOptions = getSearch().getResultFieldOptions();
        Boolean limitHit = false;
        for (String res : resFields) {
            for (Integer i = 0; i < resOptions.size(); i++) {
                if (res == resOptions[i].getValue()) {
                    if (getSearch().getSelectedFieldOptions().size() < 15) {
                        getSearch().getSelectedFieldOptions().add(resOptions[i]);
                        resOptions.remove(i);
                    } else {
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Maximum_Column_Error));
                        limitHit = true;
                        break;
                    }
                }
            }
            if (limitHit) {
                break;
            }
        }
        getSearch().setResultFieldOptions(resOptions);
        getSearch().setSelectedFields(resFields);
        return null;
    }

    //Removes columns from the Result Table
    public PageReference moveFieldsLeft() {
        List<String> selFields = getSearch().getSelectedFields();
        List<SelectOption> selOptions = getSearch().getSelectedFieldOptions();
        for (String sel : selFields) {
            for (Integer i = 0; i < selOptions.size(); i++) {
                if (sel == selOptions[i].getValue() && sel != 'User|Name' && sel != 'User|rs_Note_To_User__c') {
                    getSearch().getResultFieldOptions().add(selOptions[i]);
                    selOptions.remove(i);
                }
            }
        }
        getSearch().setSelectedFieldOptions(selOptions);
        getSearch().setResultFields(selFields);
        return null;
    }

    // Method to change the order of Selected Fields, moves fields up
    public PageReference moveFieldsUp() {
        List<String> selFields = getSearch().getSelectedFields();
        List<SelectOption> selOptions = getSearch().getSelectedFieldOptions();
        Boolean first = true; //checks if first match
        SelectOption firstOption; //temp selectoption for the the initial option before the selection
        Integer position = 0; // position where first option should be placed
        Boolean skip = false; // if we're selecting an item that's already at the top do nothing

        for (Integer i = 0; i < selOptions.size(); i++) {
            for (Integer j = 0; j < selFields.size(); j++) {
                if (selFields[j] == selOptions[i].getValue() && i > 0 && !skip) {
                    if (first) {
                        firstOption = selOptions[i - 1];
                        position = i;
                        first = false;
                    }
                    SelectOption temp = selOptions[i - 1];
                    selOptions.set(i - 1, selOptions[i]);
                    selOptions.set(i, temp);
                } else if (selFields[j] == selOptions[i].getValue() && i == 0) {
                    firstOption = selOptions[i];
                    skip = true;
                }
            }
        }
        if (position > 0) {
            getSearch().setSelectedFieldOptions(selOptions);
        }
        return null;
    }
    // Method to change the order of Selected Fields, moves fields down
    public PageReference moveFieldsDown() {
        List<String> selFields = getSearch().getSelectedFields();
        List<SelectOption> selOptions = getSearch().getSelectedFieldOptions();
        Boolean first = true;
        SelectOption firstOption;
        Integer position = -1;
        Boolean skip = false;
        // i > 0 to keep Full Name at the top
        for (Integer i = selOptions.size() - 1; i > -1; i--) {
            for (Integer j = selFields.size() - 1; j > -1; j--) {
                if (selFields[j] == selOptions[i].getValue() && i < selOptions.size() - 1 && !skip) {
                    if (first) {
                        firstOption = selOptions[i + 1];
                        first = false;
                    }
                    SelectOption temp = selOptions[i + 1];
                    selOptions.set(i + 1, selOptions[i]);
                    selOptions.set(i, temp);
                    position = i;
                } else if (selFields[j] == selOptions[i].getValue() && i == selOptions.size() - 1 ) {
                    skip = true;
                    firstOption = selOptions.get(i);
                    position = -1;
                }
            }
        }
        if (position > -1) {
            getSearch().setSelectedFieldOptions(selOptions);
        }
        return null;
    }

    public PageReference saveSearchView() {
        if (rsStringUtil.isNullOrEmpty(mSearch.getName())) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.No_Name_for_Saved_Search));
            return null;
        }
        getSearch().setConditions(getSearch().getTextSearch());
        if (mSearch.getId() == null) {
            mSavedSearches.add(mSearch);
        }
        getSearch().save();
        getSavedSearches();
        return null;
    }

    public PageReference saveAsSearchView() {
        if (rsStringUtil.isNullOrEmpty(mSearch.getName())) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.No_Name_for_Saved_Search));
            return null;
        }
        //Let's set the conditions for the current search so we
        //can repopulate the new one
        getSearch().setConditions(getSearch().getTextSearch());

        //Grab some of the necessities
        String searchType = mSearch.getSearchType();
        String searchString = mSearch.getTextSearch();
        String searchName = mSearch.getName();

        //Temp variables for the search fields we'll need
        List<rsSearch.Condition> cond = (List<rsSearch.Condition>)JSON.deserialize((String)mSearch.getObj().get('Search_Fields__c'), List<rsSearch.Condition>.class);
        List<String> selectFields = (List<String>)JSON.deserialize((String)mSearch.getObj().get('Result_Fields__c'), List<String>.class);
        Map<String, rsSearch.Condition> userCond = (Map<String, rsSearch.Condition>)JSON.deserialize((String)mSearch.getObj().get('User_Fields__c'), Map<String, rsSearch.Condition>.class);
        List<rsSearch.Condition> mPRCond = (List<rsSearch.Condition>)JSON.deserialize((String)mSearch.getObj().get('PR_Team_Employee_Fields__c'), List<rsSearch.Condition>.class);

        //Reset the name field for the old search, so we don't have "duplicates"
        // in the save list
        if (String.isNotBlank(oldSearchName)) {
            mSearch.setName(oldSearchName);
        }

        //Set up and save the new search
        mSearch = new rsSearch();
        mSearch.getObj().put('User__c', UserInfo.getUserId());
        mSearch.setSearchType(searchType);
        mSearch.setConditions(cond);
        mSearch.setResultFields(selectFields);
        mSearch.setUserConditions(userCond);
        mSearch.setPRTeamEmployeeConditions(mPRCond);
        moveFieldsRight();
        mSearch.setName(searchName);
        mSearch.setConditions(searchString);
        mSearch.save();

        //Add it to the search list, set it as the main search and
        //reload the list for the search type
        mSavedSearches.add(mSearch);
        setSelectedSavedSearch(mSearch.getId());
        getSavedSearches();
        return null;
    }

    public PageReference reset() {
        counter = 0;
        mSearchDuration = 0;
        getSearch().setTextSearch('');
        if (mSearch.getSearchType() == rsSearch.BASIC_SEARCH) {
            mSearch = new rsSearch();
            setupBasic();
        } else {
            mSearch = new rsSearch();
            mSearch.setSearchType(rsSearch.ADVANCED_SEARCH);
            setupAdvanced();
        }
        mSelectedSavedSearch = '';
        mSelectAll = false;
        mSearchResults = new List<rsSearchResult>();
        resultsMap.clear();
        return null;
    }

    public PageReference automateFilterLogic() {
        List<rsSearch.Condition> conditions = mSearch.getConditions();
        String filterString = '';
        for (Integer i = 0; i < conditions.size(); i++) {
            if (!rsStringUtil.isNullOrEmpty(conditions[i].field) &&
                    !rsStringUtil.isNullOrEmpty(conditions[i].operator)) {
                filterString += String.valueOf(i + 1) + ' AND ';
            }
        }
        if (!rsStringUtil.isNullOrEmpty(filterString)) {
            filterString = filterString.substring(0, filterString.lastIndexOf('AND'));
        }
        mSearch.setFilter(filterString);
        return null;
    }

    public PageReference generateExcel() {
        setSelectedResults();
        PageReference pg = null;

        // Booleans for whether or not fields are full
        Boolean list1Full = false;
        Boolean list2Full = false;
        Boolean list3Full = false;
        Boolean list4Full = false;
        Boolean list5Full = false;
        Boolean list6Full = false;
        Boolean list7Full = false;
        Boolean list8Full = false;
        Boolean list9Full = false;
        Boolean list10Full = false;
        Boolean list11Full = false;

        // Limit to each of these fields most like will be 131072 since Ethos owned object
        Integer fieldLimit = rs_Search__c.Result_Fields__c.getDescribe().getLength();

        List<String> headerLabels = new List<String>();
        for (SelectOption option : getSearch().getSelectedFieldOptions()) {
            headerLabels.add(option.getLabel());
        }

        List<rsSearchResult> selectedResults = new List<rsSearchResult>();

        rs_Search__c results = new rs_Search__c(Search_Fields__c = JSON.serialize(headerLabels));

        List<rsSearchResult> allSearchResults = new List<rsSearchResult>();
        Set<Id> userIds = new Set<Id>();
        Boolean remainders = true;
        for (Integer i : resultsMap.keySet()) {
            List<Id> tempList = new List<Id>(resultsMap.get(i).keySet());
            Boolean selected = resultsMap.get(i).get(tempList.get(0));

            // We'll chunk them by lists sizes of 100
            if (selected && userIds.size() < 99) {
                userIds.add(tempList.get(0));
                remainders = true;
            } else if (selected && userIds.size() >= 99) {
                userIds.add(tempList.get(0));
                allSearchResults.addAll(buildResultWithColumns(userIds, true));

                // We'll add a check here if heap size is > 5.9 MBs then we'll just give an error message
                if (Limits.getHeapSize() > 5900000) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Too_Much_Data_Selected));
                    return null;
                }
                userIds.clear();
                remainders = false;
            }
        }
        if (remainders) {
            if (Limits.getHeapSize() > 5900000) { // we'll do the same check here
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Too_Much_Data_Selected));
                return null;
            }
            allSearchResults.addAll(buildResultWithColumns(userIds, true));
        }
        allSearchResults.sort();

        // We'll check the serialized list every time an item is added, if the list is larger than the field can handle
        // the list to the field and reset the list for the next field, otherwise add the list to the field
        // we'll also remove the searchResults from allSearchResults as we add so we don't have two lists with identical data
        for (Integer i = 0; allSearchResults.size() > 0; i = 0) {
            rsSearchResult result = allSearchResults.get(i);
            if (!list1Full) {
                selectedResults.add(result);
                if (JSON.serialize(selectedResults).length() > fieldLimit) {
                    selectedResults.remove(selectedResults.size() - 1);
                    results.Result_Fields__c = JSON.serialize(selectedResults);
                    selectedResults.clear();
                    selectedResults.add(result);
                    list1Full = true;
                } else {
                    results.Result_Fields__c = JSON.serialize(selectedResults);
                }
            } else if (!list2Full) {
                selectedResults.add(result);
                if (JSON.serialize(selectedResults).length() > fieldLimit) {
                    selectedResults.remove(selectedResults.size() - 1);
                    results.User_Fields__c = JSON.serialize(selectedResults);
                    selectedResults.clear();
                    selectedResults.add(result);
                    list2Full = true;
                } else {
                    results.User_Fields__c = JSON.serialize(selectedResults);
                }
            } else if (!list3Full) {
                selectedResults.add(result);
                if (JSON.serialize(selectedResults).length() > fieldLimit) {
                    selectedResults.remove(selectedResults.size() - 1);
                    results.PR_Team_Employee_Fields__c = JSON.serialize(selectedResults);
                    selectedResults.clear();
                    selectedResults.add(result);
                    list3Full = true;
                } else {
                    results.PR_Team_Employee_Fields__c = JSON.serialize(selectedResults);
                }
            } else if (!list4Full) {
                selectedResults.add(result);
                if (JSON.serialize(selectedResults).length() > fieldLimit) {
                    selectedResults.remove(selectedResults.size() - 1);
                    results.Overflow_Fields__c = JSON.serialize(selectedResults);
                    selectedResults.clear();
                    selectedResults.add(result);
                    list4Full = true;
                } else {
                    results.Overflow_Fields__c = JSON.serialize(selectedResults);
                }
            } else if (!list5Full) {
                selectedResults.add(result);
                if (JSON.serialize(selectedResults).length() > fieldLimit) {
                    selectedResults.remove(selectedResults.size() - 1);
                    results.Overflow_Fields_2__c = JSON.serialize(selectedResults);
                    selectedResults.clear();
                    selectedResults.add(result);
                    list5Full = true;
                } else {
                    results.Overflow_Fields_2__c = JSON.serialize(selectedResults);
                }
            } else if (!list6Full) {
                selectedResults.add(result);
                if (JSON.serialize(selectedResults).length() > fieldLimit) {
                    selectedResults.remove(selectedResults.size() - 1);
                    results.Overflow_Fields_3__c = JSON.serialize(selectedResults);
                    selectedResults.clear();
                    selectedResults.add(result);
                    list6Full = true;
                } else {
                    results.Overflow_Fields_3__c = JSON.serialize(selectedResults);
                }
            } else if (!list7Full) {
                selectedResults.add(result);
                if (JSON.serialize(selectedResults).length() > fieldLimit) {
                    selectedResults.remove(selectedResults.size() - 1);
                    results.Overflow_Fields_4__c = JSON.serialize(selectedResults);
                    selectedResults.clear();
                    selectedResults.add(result);
                    list7Full = true;
                } else {
                    results.Overflow_Fields_4__c = JSON.serialize(selectedResults);
                }
            } else if (!list8Full) {
                selectedResults.add(result);
                if (JSON.serialize(selectedResults).length() > fieldLimit) {
                    selectedResults.remove(selectedResults.size() - 1);
                    results.Overflow_Fields_5__c = JSON.serialize(selectedResults);
                    selectedResults.clear();
                    selectedResults.add(result);
                    list8Full = true;
                } else {
                    results.Overflow_Fields_5__c = JSON.serialize(selectedResults);
                }
            } else if (!list9Full) {
                selectedResults.add(result);
                if (JSON.serialize(selectedResults).length() > fieldLimit) {
                    selectedResults.remove(selectedResults.size() - 1);
                    results.Overflow_Fields_6__c = JSON.serialize(selectedResults);
                    selectedResults.clear();
                    selectedResults.add(result);
                    list9Full = true;
                } else {
                    results.Overflow_Fields_6__c = JSON.serialize(selectedResults);
                }
            } else if (!list10Full) {
                selectedResults.add(result);
                if (JSON.serialize(selectedResults).length() > fieldLimit) {
                    selectedResults.remove(selectedResults.size() - 1);
                    results.Overflow_Fields_7__c = JSON.serialize(selectedResults);
                    selectedResults.clear();
                    selectedResults.add(result);
                    list10Full = true;
                } else {
                    results.Overflow_Fields_7__c = JSON.serialize(selectedResults);
                }
            } else if (!list11Full) {
                selectedResults.add(result);
                if (JSON.serialize(selectedResults).length() > fieldLimit) {
                    selectedResults.remove(selectedResults.size() - 1);
                    results.Overflow_Fields_8__c = JSON.serialize(selectedResults);
                    selectedResults.clear();
                    selectedResults.add(result);
                    list11Full = true;
                } else {
                    results.Overflow_Fields_8__c = JSON.serialize(selectedResults);
                }

            } else {
                selectedResults.add(result);
                if (JSON.serialize(selectedResults).length() > fieldLimit / 2) {
                    // probably sometime in the future, additioanl rs_Search records should be made instead of returning an
                    // error
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Too_Much_Data_Selected));
                    return null;
                } else {
                    results.Overflow_Fields_9__c = JSON.serialize(selectedResults);
                }
            }

            allSearchResults.remove(i);
        }


        if (selectedResults.isEmpty()) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Select_One_Result_for_Export));
            return pg;
        }

        insert results;

        pg = new PageReference('/apex/rsSearchResultExcelExport?id=' + results.Id);
        return pg;
    }

    public PageReference generateResumes() {
        setSelectedResults();
        Set<Id> userIds = new Set<Id>();
        for (Integer i : resultsMap.keySet()) {
            List<Id> tempList = new List<Id>(resultsMap.get(i).keySet());
            System.debug('UserId: ' + resultsMap.get(i).get(tempList.get(0)) + ' Int: ' + i);
            if (resultsMap.get(i).get(tempList.get(0))) {
                userIds.add(tempList.get(0));
            }
        }

        if (userIds.size() > 30) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Too_Many_Selected_For_Generation));
            return null;
        }

        if (userIds.isEmpty()) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Select_One_Result_for_Generation));
            return null;
        }

        rsGenerationClient client = new rsGenerationClient();

        //if we have a lot of resumes heroku can't complete generation on them all in
        //under 30 seconds, we can tell it to process them using a worker though
        //this allows heroku to respond right away with a UUID
        //the client then uses long polling to check if the generation is complete
        //using this UUID up to the maximum time salesforce can wait for a callout response
        //which is 120 seconds. We could enhance this further by making heroku email
        //the download link if it takes stupidly long which it shouldn't on the
        //more expensive hardware. Right now it is taking about 40 seconds to generate
        //and merge a complex document with 25 individuals.
        if (mTemplateName != rsGenerationClient.XML_OUTPUT) {
            if (userIds.size() > 5) {
                client.setAsync(true);
            }
            mDownloadLink = client.generate(rsResumeGenerationUtil.generateResumeJson(new List<Id>(userIds)), mTemplateName);
            mShowDownloadLink = true;
        } else {
            mDownloadLink = '/apex/rsResumeXMLDownload?userId=' + String.join(new List<Id>(userIds), ',');
            mShowDownloadLink = true;
        }

        return null;
    }

    public void setShowDownloadLink(Boolean val) {
        mShowDownloadLink = true;
    }

    public Boolean getShowDownloadLink() {
        return mShowDownloadLink;
    }

    public void setTemplateName(String value) {
        mTemplateName = value;
    }

    public String getTemplateName() {
        return mTemplateName;
    }

    public String getDownloadLink() {
        return mDownloadLink;
    }



}