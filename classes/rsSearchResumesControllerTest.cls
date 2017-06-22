@isTest
private class rsSearchResumesControllerTest {

    @isTest static void testAddRow() {
        rsSearchResumesController cont = new rsSearchResumesController();

        Test.startTest();
        cont.setupAdvanced();
        cont.addRow();
        Test.stopTest();

        System.assertEquals(cont.getSearch().getConditions().size(), 6);
    }

    @isTest static void testAdvancedSearch() {
        rsTestUtil.createTestProfileParts(10, 5);
        rsSearchResumesController cont = new rsSearchResumesController();
        cont.setupAdvanced();
        List<rsSearch.Condition> advCond = cont.getSearch().getConditions();
        advCond.set(0,new rsSearch.Condition('Test','c','rs_Profile_Part__c|Training_Name__c'));
        advCond.set(1,new rsSearch.Condition('Test Training','e','rs_Profile_Part__c|Training_Name__c'));
        advCond.set(2,new rsSearch.Condition('rubbish','ne','User|Name'));
        advCond.set(3,new rsSearch.Condition('Test','sw','rs_Profile_Part__c|Training_Name__c'));
        advCond.set(4,new rsSearch.Condition('rubbish','dnc','rs_Profile_Part__c|Training_Name__c'));
        advCond.add(new rsSearch.Condition('az','lt','rs_Profile_Part__c|Training_Name__c'));
        advCond.add(new rsSearch.Condition('az','gt','rs_Profile_Part__c|Training_Name__c'));
        advCond.add(new rsSearch.Condition('az','loe','rs_Profile_Part__c|Training_Name__c'));
        advCond.add(new rsSearch.Condition('az','goe','rs_Profile_Part__c|Training_Name__c'));
        cont.getSearch().setConditions(advCond);
        cont.getSearch().setFilter('1 OR 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9');
        Test.startTest();
        cont.basicSearch();
        Test.stopTest();

        System.assertEquals(10, cont.getSearchResults().size());

    }

    @isTest static void testAdvancedSearchException() {
        rsTestUtil.createTestProfileParts(10, 5);
        rsSearchResumesController cont = new rsSearchResumesController();
        cont.setupAdvanced();
        List<rsSearch.Condition> advCond = cont.getSearch().getConditions();
        advCond.set(0,new rsSearch.Condition('','c','rs_Profile_Part__c|Training_Name__c'));
        cont.getSearch().setConditions(advCond);
        cont.getSearch().setFilter('1');
        Test.startTest();
        cont.basicSearch();
        Test.stopTest();

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean error = false;
        for(Apexpages.Message msg : msgs){
            if (msg.getDetail().contains('Training Name')) error = true;
        }

        System.assert(true, error);

    }

    @isTest static void testAdvancedSearchExceptionNoFilter() {
        rsTestUtil.createTestProfileParts(10, 5);
        rsSearchResumesController cont = new rsSearchResumesController();
        cont.setupAdvanced();
        List<rsSearch.Condition> advCond = cont.getSearch().getConditions();
        advCond.set(0,new rsSearch.Condition('','c','rs_Profile_Part__c|Training_Name__c'));
        cont.getSearch().setConditions(advCond);
        Test.startTest();
        cont.basicSearch();
        Test.stopTest();

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean error = false;
        for(Apexpages.Message msg : msgs){
            if (msg.getDetail().contains('Training Name')) error = true;
        }

        System.assert(true, error);

    }

    @isTest static void testAdvancedSearchNoFilter() {
        rsTestUtil.createTestProfileParts(10, 1, 1);
        rsSearchResumesController cont = new rsSearchResumesController();
        cont.setupAdvanced();
        List<rsSearch.Condition> advCond = cont.getSearch().getConditions();
        advCond.set(0,new rsSearch.Condition('Test','c','rs_Profile_Part__c|Training_Name__c'));
        advCond.set(1,new rsSearch.Condition('This is a test role','e','PR_Team_Employee__c|Project_Role__c'));
        advCond.set(2,new rsSearch.Condition('test','c','User|Name'));
        cont.getSearch().setConditions(advCond);
        Test.startTest();
        cont.basicSearch();
        Test.stopTest();

        System.assertEquals(10, cont.getSearchResults().size());

    }

    @isTest static void testAutomateFilterLogic() {
        rs_Search__c savedSearch = rsTestUtil.advancedSearch();
        rsSearchResumesController cont = new rsSearchResumesController();

        Test.startTest();
        cont.setSelectedSavedSearch(savedSearch.Id);
        cont.setSearch();
        cont.automateFilterLogic();
        Test.stopTest();

        System.assertEquals('1 AND 2 AND 3',cont.getSearch().getFilter().trim());
    }

    @isTest static void testClearDownload() {
        rsSearchResumesController cont = new rsSearchResumesController();

        Test.startTest();
        cont.clearDownload();
        Test.stopTest();

        System.assertEquals(false, cont.getShowDownloadLink());
    }

    @isTest static void testClearLogic() {
        rsSearchResumesController cont = new rsSearchResumesController();

        Test.startTest();
        cont.setupAdvanced();
        cont.addRow();
        cont.clearLogic();
        Test.stopTest();

        System.assertEquals(cont.getSearch().getConditions().size(), 5);
    }

    @isTest static void testGenerateExcel() {
        rsTestUtil.createTestProfileParts(200, 5);
        rsSearchResumesController cont = new rsSearchResumesController();
        cont.setupAdvanced();
        List<rsSearch.Condition> advCond = cont.getSearch().getConditions();
        advCond.set(0,new rsSearch.Condition('Test','c','rs_Profile_Part__c|Training_Name__c'));
        cont.getSearch().setConditions(advCond);
        cont.basicSearch();
        cont.getSearchResults().get(0).Selected = true;

        Test.startTest();
        PageReference pg = cont.generateExcel();
        Test.stopTest();

        rs_Search__c search = [Select id from rs_Search__c LIMIT 1];
        PageReference returnPG = new PageReference('/apex/rsSearchResultExcelExport?id='+search.Id);
        System.assertEquals(returnPG.getUrl(),pg.getUrl());

    }
    //TODO - test methods do not support Web service callouts
    @isTest static void testGenerateResumes() {

    }

    @isTest static void testGetAndSetDownloadMethods() {
        rsSearchResumesController cont = new rsSearchResumesController();

        Test.startTest();
        cont.setShowDownloadLink(true);
        Boolean dlLink = cont.getShowDownloadLink();
        cont.setTemplateName('Name');
        String templateName = cont.getTemplateName();
        cont.getDownloadLink();
        Test.stopTest();

        System.assertEquals(true, dlLink);
        System.assertEquals(templateName, 'Name');
    }

    @isTest static void testMoveFieldsDown() {
        rsSearchResumesController cont = new rsSearchResumesController();
        List<String> fieldsToMove = new List<String>();
        Integer i = 0;
        for(SelectOption op : cont.getSearch().getResultFieldOptions()) {
            if(i < 10) {
                fieldsToMove.add(op.getValue());
            }
            i++;
        }
        cont.getSearch().setResultFields(fieldsToMove);
        cont.moveFieldsRight();
        String valueAtTwo = cont.getSearch().getSelectedFieldOptions().get(2).getValue();
        String valueAtThree = cont.getSearch().getSelectedFieldOptions().get(3).getValue();
        fieldsToMove.clear();
        fieldsToMove.add(cont.getSearch().getSelectedFieldOptions().get(2).getValue());

        Test.startTest();
        cont.moveFieldsDown();
        Test.stopTest();

        System.assertEquals(valueAtThree, cont.getSearch().getSelectedFieldOptions().get(2).getValue());
        System.assertEquals(valueAtTwo, cont.getSearch().getSelectedFieldOptions().get(3).getValue());
    }

    @isTest static void testMoveFieldsLeft() {
        rsSearchResumesController cont = new rsSearchResumesController();
        List<String> fieldsToMove = new List<String>();
        Integer i = 0;
        for(SelectOption op : cont.getSearch().getResultFieldOptions()) {
            if(i < 10) {
                fieldsToMove.add(op.getValue());
            }
            i++;
        }
        cont.getSearch().setResultFields(fieldsToMove);
        cont.moveFieldsRight();
        cont.getSearch().setSelectedFields(fieldsToMove);

        Test.startTest();
        cont.moveFieldsLeft();
        Test.stopTest();

        System.assertNotEquals(0, cont.getSearch().getSelectedFieldOptions().size());
    }

    @isTest static void testMoveFieldsRight() {
        rsSearchResumesController cont = new rsSearchResumesController();
        List<String> fieldsToMove = new List<String>();
        Integer i = 0;
        for(SelectOption op : cont.getSearch().getResultFieldOptions()) {
            if(i < 10) {
                fieldsToMove.add(op.getValue());
                i++;
            }
        }
        cont.getSearch().setResultFields(fieldsToMove);
        Test.startTest();
        cont.moveFieldsRight();
        Test.stopTest();

        //Including the default fields plus some
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean maxColumns = false;
        for(Apexpages.Message msg : msgs){
            if (msg.getDetail().contains(Label.Maximum_Column_Error)) maxColumns = true;
        }
        //Should have 15 columns including the default and however many that can be put here
        System.assertEquals(15, cont.getSearch().getSelectedFieldOptions().size());
        System.assert(maxColumns);
    }

    @isTest static void testMoveFieldsUp() {
        rsSearchResumesController cont = new rsSearchResumesController();
        List<String> fieldsToMove = new List<String>();
        Integer i = 0;
        for(SelectOption op : cont.getSearch().getResultFieldOptions()) {
            if(i < 10) {
                fieldsToMove.add(op.getValue());
            }
            i++;
        }
        cont.getSearch().setResultFields(fieldsToMove);
        cont.moveFieldsRight();
        String valueAtTwo = cont.getSearch().getSelectedFieldOptions().get(2).getValue();
        String valueAtThree = cont.getSearch().getSelectedFieldOptions().get(3).getValue();
        fieldsToMove.clear();
        fieldsToMove.add(cont.getSearch().getSelectedFieldOptions().get(3).getValue());

        Test.startTest();
        cont.moveFieldsUp();
        Test.stopTest();

        System.assertEquals(valueAtThree, cont.getSearch().getSelectedFieldOptions().get(2).getValue());
        System.assertEquals(valueAtTwo, cont.getSearch().getSelectedFieldOptions().get(3).getValue());
    }

    @isTest static void testRemoveRow() {
        rsSearchResumesController cont = new rsSearchResumesController();

        Test.startTest();
        cont.setupAdvanced();
        cont.addRow();
        cont.addRow();
        cont.removeRow();
        Test.stopTest();

        System.assertEquals(cont.getSearch().getConditions().size(), 6);
    }

    @isTest static void testResetAdvanced() {
        rs_Search__c savedSearch = rsTestUtil.advancedSearch();
        rsSearchResumesController cont = new rsSearchResumesController();
        cont.setupAdvanced();

        Test.startTest();
        cont.reset();
        Test.stopTest();

        System.assertEquals(cont.getSearch().getId(), null);
        System.assertEquals(cont.getSearch().getSearchType(), rsSearch.ADVANCED_SEARCH);
    }

    @isTest static void testResetBasic() {
        rs_Search__c savedSearch = rsTestUtil.basicSearch();
        rsSearchResumesController cont = new rsSearchResumesController();
        cont.setupBasic();

        Test.startTest();
        cont.reset();
        Test.stopTest();

        System.assertEquals(cont.getSearch().getId(), null);
        System.assertEquals(cont.getSearch().getSearchType(), rsSearch.BASIC_SEARCH);
    }

    @isTest static void testSaveSearchView() {
        rsSearchResumesController cont = new rsSearchResumesController();

        Test.startTest();
        //Testing with no Search Name
        cont.saveSearchView();
        cont.getSearch().setName('TEST');
        cont.saveSearchView();
        Test.stopTest();

        Boolean errorMsg = false;
        for(ApexPages.Message msg : ApexPages.getMessages()) {
            if(msg.getSummary() == Label.No_Name_for_Saved_Search) {
                errorMsg = true;
                break;
            }
        }
        rs_Search__c search = [Select Id,Name from rs_Search__c LIMIT 1];
        System.assertEquals('TEST', search.Name);
        System.assertEquals(true, errorMsg);
    }

    @isTest static void testSetSearchException() {
        rs_Search__c savedSearch = rsTestUtil.basicSearch();
        rsSearchResumesController cont = new rsSearchResumesController();

        Test.startTest();
        cont.setSearch();
        Test.stopTest();

        Boolean errorMsg = false;
        for(ApexPages.Message msg : ApexPages.getMessages()) {
            if(msg.getSummary() == Label.Search_View_Not_Selected) {
                errorMsg = true;
                break;
            }
        }

        System.assert(errorMsg);
    }

    @isTest static void testSetupAdvanced() {
        rs_Search__c savedSearch = rsTestUtil.advancedSearch();
        rsSearchResumesController cont = new rsSearchResumesController();

        Test.startTest();
        cont.getSearch().setSearchType(rsSearch.ADVANCED_SEARCH);
        cont.basicSearch();
        cont.setupAdvanced();
        //Test the if conditions are larger than 5
        List<rsSearch.Condition> temp = cont.getSearch().getConditions();
        temp.add(new rsSearch.Condition('','',''));
        cont.getSearch().setConditions(temp);
        cont.setupAdvanced();
        Test.stopTest();

        System.assertEquals(cont.getSearch().getId(), null);
        System.assertEquals(cont.getSearchResults().size(), 0);
        System.assertEquals(cont.getSavedSearches().size(), 1);
        System.assertEquals(cont.getSearch().getSearchType(), rsSearch.ADVANCED_SEARCH);
        System.assertEquals(cont.getSearch().getConditions().size(), 5);
    }

    @isTest static void testSetupBasic() {
        rs_Search__c savedSearch = rsTestUtil.basicSearch();
        rsSearchResumesController cont = new rsSearchResumesController();

        Test.startTest();
        cont.setupBasic();
        cont.getSearch().setTextSearch('testasdfasdf');
        cont.basicSearch();
        Test.stopTest();

        System.assertEquals(cont.getSearch().getId(), null);
        System.assertEquals(cont.getSearchResults().size(), 0);
        System.assertEquals(cont.getSavedSearches().size(), 1);
        System.assertEquals(cont.getSearch().getSearchType(), rsSearch.BASIC_SEARCH);
    }

    @isTest static void testSetSearchBasic() {
        rs_Search__c savedSearch = rsTestUtil.basicSearch();
        rsSearchResumesController cont = new rsSearchResumesController();

        Test.startTest();
        cont.setSelectedSavedSearch(savedSearch.Id);
        cont.setSearch();
        Test.stopTest();

        System.assertEquals(cont.getSearch().getConditions().get(0).value, 'test%');
        System.assertEquals(cont.getSearch().getConditions().get(0).operator, 'LIKE');
        System.assertNotEquals(cont.getSearch().getConditions().get(0).field, '');
        System.assertEquals(cont.getSearch().getUserConditions().get('firstName').value, '%%');
        System.assertEquals(cont.getSearch().getUserConditions().get('firstName').operator, ' LIKE ');
        System.assertEquals(cont.getSearch().getUserConditions().get('firstName').field, 'FirstName');
    }

    @isTest static void testSetSearchBasicEdgeCase() {
        rs_Search__c savedSearch = rsTestUtil.basicSearch();
        rsSearchResumesController cont = new rsSearchResumesController();

        Test.startTest();
        cont.setSelectedSavedSearch(savedSearch.Id);
        cont.setSearch();
        cont.setupBasic();
        Test.stopTest();

        System.assertEquals(cont.getSearch().getConditions().size(),0);
        System.assertEquals(cont.getSearch().getSearchType(),rsSearch.BASIC_SEARCH);
    }

    @isTest static void testSetSearchAdvanced() {
        rs_Search__c savedSearch = rsTestUtil.advancedSearch();
        rsSearchResumesController cont = new rsSearchResumesController();

        Test.startTest();
        cont.setSelectedSavedSearch(savedSearch.Id);
        cont.setSearch();
        Test.stopTest();

        System.assertEquals(cont.getSearch().getConditions().size(), 5);
        System.assertEquals(cont.getSearch().getConditions().get(0).value, 'Sales');
        System.assertEquals(cont.getSearch().getConditions().get(0).operator, 'c');
        System.assertEquals(cont.getSearch().getConditions().get(0).field, 'rs_Profile_Part__c|Certification_Description__c');
        System.assertEquals(cont.getSearch().getUserConditions().get('firstName').value, '%%');
        System.assertEquals(cont.getSearch().getUserConditions().get('firstName').operator, ' LIKE ');
        System.assertEquals(cont.getSearch().getUserConditions().get('firstName').field, 'FirstName');
        System.assertEquals(cont.getSelectedSavedSearch(), savedSearch.Id);
    }

    @isTest static void testSetSearchAdvancedEdgeCase() {
        rs_Search__c savedSearch = rsTestUtil.advancedSearch();
        rsSearchResumesController cont = new rsSearchResumesController();

        Test.startTest();
        cont.setSelectedSavedSearch(savedSearch.Id);
        cont.setSearch();
        cont.setupAdvanced();
        Test.stopTest();

        System.assertEquals(cont.getSearch().getConditions().size(),5);
        System.assertEquals(cont.getSearch().getSearchType(),rsSearch.ADVANCED_SEARCH);
    }

    @isTest static void testPaginationMethods() {
        rsTestUtil.createTestProfileParts(20, 1);
        rsSearchResumesController cont = new rsSearchResumesController();
        cont.getSearch().setTextSearch('Test Training');

        List<String> fixedResults = new List<String>();
        for(rs_Profile_Part__c pp : [Select Id from rs_Profile_Part__c LIMIT 20]) {
            fixedResults.add(pp.Id);
        }
        Test.setFixedSearchResults(fixedResults);

        Test.startTest();
        cont.basicSearch();
        Boolean getDisabledPrev = cont.getDisabledPrevious();
        Boolean getDisabledNext = cont.getDisabledNext();
        Integer currentPage = cont.getPageNumber();
        Integer fromResult = cont.getFromResult();
        Integer toResult = cont.getToResult();
        Integer totalResults = cont.getTotalSearchResults();
        Integer totalPages = cont.getTotalPages();
        Test.stopTest();

        System.assertEquals(true, getDisabledPrev);
        System.assertEquals(false, getDisabledNext);
        System.assertEquals(1,currentPage);
        System.assertEquals(1,fromResult);
        System.assertEquals(10,toResult);
        System.assertEquals(20, totalResults);
        System.assertEquals(2,totalPages);
    }

    @isTest static void testNavigationPaginationMethods() {
        rsTestUtil.createTestProfileParts(30, 5);
        rsSearchResumesController cont = new rsSearchResumesController();
        cont.getSearch().setTextSearch('Test Training');

        List<String> fixedResults = new List<String>();
        for(rs_Profile_Part__c pp : [Select Id,User__c from rs_Profile_Part__c where Training_Name__c LIKE: '%Test Training%' LIMIT 160]) {
            fixedResults.add(pp.Id);
            fixedResults.add(pp.User__c);
        }
        Test.setFixedSearchResults(fixedResults);

        Test.startTest();
        cont.basicSearch();
        cont.end();
        Integer endCurrentPage = cont.getPageNumber();
        Integer endFromResult = cont.getFromResult();
        Integer endToResult = cont.getToResult();
        cont.beginning();
        Integer beginCurrentPage = cont.getPageNumber();
        Integer beginFromResult = cont.getFromResult();
        Integer beginToResult = cont.getToResult();
        cont.next();
        Integer nextCurrentPage = cont.getPageNumber();
        Integer nextFromResult = cont.getFromResult();
        Integer nextToResult = cont.getToResult();
        cont.end();
        cont.previous();
        Integer prevCurrentPage = cont.getPageNumber();
        Integer prevFromResult = cont.getFromResult();
        Integer prevToResult = cont.getToResult();
        Test.stopTest();

        System.assertEquals(3,endCurrentPage);
        System.assertEquals(21,endFromResult);
        System.assertEquals(30,endToResult);

        System.assertEquals(1,beginCurrentPage);
        System.assertEquals(1,beginFromResult);
        System.assertEquals(10,beginToResult);

        System.assertEquals(2,nextCurrentPage);
        System.assertEquals(11,nextFromResult);
        System.assertEquals(20,nextToResult);

        System.assertEquals(2,prevCurrentPage);
        System.assertEquals(11,prevFromResult);
        System.assertEquals(20,prevToResult);
    }

    @isTest static void testNavigationPaginationEdgeCases() {
        rsTestUtil.createTestProfileParts(13, 5);
        rsSearchResumesController cont = new rsSearchResumesController();
        cont.getSearch().setTextSearch('Test Training');

        List<String> fixedResults = new List<String>();
        for(rs_Profile_Part__c pp : [Select Id from rs_Profile_Part__c where Training_Name__c LIKE: '%Test Training%' LIMIT 75]) {
            fixedResults.add(pp.Id);
        }

        Test.setFixedSearchResults(fixedResults);
        Test.startTest();
        cont.basicSearch();
        cont.end();
        Integer endCurrentPage = cont.getPageNumber();
        Integer endFromResult = cont.getFromResult();
        Integer endToResult = cont.getToResult();
        cont.previous();
        cont.previous();
        Integer prevCurrentPage = cont.getPageNumber();
        Integer prevFromResult = cont.getFromResult();
        Integer prevToResult = cont.getToResult();
        cont.next();
        cont.next();
        Integer nextCurrentPage = cont.getPageNumber();
        Integer nextFromResult = cont.getFromResult();
        Integer nextToResult = cont.getToResult();
        Test.stopTest();

        System.assertEquals(2, endCurrentPage);
        System.assertEquals(13, endToResult);
        System.assertEquals(11, endFromResult);

        System.assertEquals(1, prevCurrentPage);
        System.assertEquals(1, prevFromResult);
        System.assertEquals(10, prevToResult);

        System.assertEquals(2, nextCurrentPage);
        System.assertEquals(11, nextFromResult);
        System.assertEquals(13, nextToResult);

        System.assertEquals(2, cont.getTotalPages());
    }

    @isTest static void testBasicSearch() {
        rsTestUtil.createTestProfileParts(20, 0);
        rsSearchResumesController cont = new rsSearchResumesController();
        List<String> fixedResults = new List<String>();
        for(User u : [Select Id from User where LastName LIKE: 'lastName%' LIMIT 1000]) {
            fixedResults.add(u.Id);
        }
        cont.setupBasic();
        cont.getSearch().setTextSearch('lastName');
        Test.setFixedSearchResults(fixedResults);
        Test.startTest();
        cont.basicSearch();
        Test.stopTest();

        System.assertEquals(20, cont.getTotalSearchResults());

    }

    @isTest static void testBasicSearchWithUserWhere() {
        rsTestUtil.createTestProfileParts(1, 0);
        rsSearchResumesController cont = new rsSearchResumesController();
        cont.getSearch().setFirstName('test');
        cont.getSearch().setLastName('lastName0');
        List<String> fixedResults = new List<String>();
        for(User u : [Select Id from User where LastName =: 'lastName0' LIMIT 1]) {
            fixedResults.add(u.Id);
        }
        cont.setupBasic();
        cont.getSearch().setTextSearch('test');
        Test.setFixedSearchResults(fixedResults);
        Test.startTest();
        cont.basicSearch();
        Test.stopTest();

        System.assertEquals(1, cont.getTotalSearchResults());

    }

    @isTest static void testLoadAction() {
        rsTestUtil.createTestProfileParts(30, 1);
        rsSearchResumesController cont = new rsSearchResumesController();
        Apexpages.currentPage().getParameters().put('query','Test Training');

        List<String> fixedResults = new List<String>();
        for(rs_Profile_Part__c pp : [Select Id from rs_Profile_Part__c where Training_Name__c LIKE: '%Test Training%' LIMIT 50]) {
            fixedResults.add(pp.Id);
        }
        Test.setFixedSearchResults(fixedResults);
        Test.startTest();
        cont.loadAction();
        Test.stopTest();

        System.assertEquals(30, cont.getTotalSearchResults());
    }

    @isTest static void testSaveAsSearchView() {
        rsSearchResumesController cont = new rsSearchResumesController();

        Test.startTest();
        //Testing with no Search Name
        cont.saveAsSearchView();
        cont.getSearch().setName('TEST');
        cont.getSearch().setTextSearch('TEST');
        cont.saveAsSearchView();
        Test.stopTest();

        Boolean errorMsg = false;
        for(ApexPages.Message msg : ApexPages.getMessages()) {
            if(msg.getSummary() == Label.No_Name_for_Saved_Search) {
                errorMsg = true;
                break;
            }
        }
        rs_Search__c search = [Select Id,Name from rs_Search__c LIMIT 1];
        System.assertEquals('TEST', search.Name);
        System.assertEquals(true, errorMsg);
    }

    @isTest static void testSelectAllSearchResults() {
        rsTestUtil.createTestProfileParts(10, 0);
        rsSearchResumesController cont = new rsSearchResumesController();
        cont.getSearch().setTextSearch('test');
        List<String> fixedResults = new List<String>();
        for(User u : [Select Id from User where FirstName LIKE: '%test%' LIMIT 10]) {
            fixedResults.add(u.Id);
        }
        cont.setupBasic();
        cont.getSearch().setTextSearch('test');
        Test.setFixedSearchResults(fixedResults);
        Test.startTest();
        cont.basicSearch();
        cont.setSelectAll(true);
        cont.selectAllSearchResults();
        Test.stopTest();

        Boolean selected = true;
        for(rsSearchResult result : cont.getSearchResults()) {
            if(result.Selected == false) {
                selected = false;
                break;
            }
        }

        System.assertEquals(cont.getSelectAll(),selected);
    }


}