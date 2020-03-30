/**
 * Test Class for PostDisplayController
 * implicitly, this test RestApiCaller as well.
 * 
 */
@isTest
private class PostDisplayControllerTest {
    
    private static final String POST_DATA_SAMPLE_03_BAD_FORMAT = '{ "badId:1"}';
    private static final String POST_DATA_SAMPLE_04_FIFTEEN = '{"userId": 1,"id": 1, "title": "test 01"}'
                                                                    + ', {"userId": 2,"id": 2, "title": "test 02"}'
                                                                    + ', {"userId": 3,"id": 3, "title": "test 03"}'
                                                                    + ', {"userId": 4,"id": 4, "title": "test 04"}'
                                                                    + ', {"userId": 5,"id": 5, "title": "test 05"}'
                                                                    + ', {"userId": 6,"id": 6, "title": "test 06"}'
                                                                    + ', {"userId": 7,"id": 7, "title": "test 07"}'
                                                                    + ', {"userId": 8,"id": 8, "title": "test 08"}'
                                                                    + ', {"userId": 9,"id": 9, "title": "test 09"}'
                                                                    + ', {"userId":10,"id":10, "title": "test 10"}'
                                                                    + ', {"userId":11,"id":11, "title": "test 11"}'
                                                                    + ', {"userId":12,"id":12, "title": "test 12"}'
                                                                    + ', {"userId":13,"id":13, "title": "test 13"}'
                                                                    + ', {"userId":14,"id":14, "title": "test 14"}'
                                                                    + ', {"userId":15,"id":15, "title": "test 15"}';
    
    private static final Integer TEST_PAGE_SIZE = 5;
    // ========================================================================
    // basic test, happy path
    static testMethod void test01_basicCall() {
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new PostCalloutMock(POST_DATA_SAMPLE_04_FIFTEEN)); 
        Test.startTest();
        
        PageReference pageRef = Page.PostDisplayPage;
        Test.setCurrentPage(pageRef);
        PostDisplayController pdc = new PostDisplayController();
        pdc.pageSize = 5;
        System.assertEquals( false, pdc.hasError, 'Error flag should be false.');
        pdc.getDataButton(); 
        
        Test.stopTest();
        
        List<Apexpages.Message> pageMessages = ApexPages.getMessages();
        System.debug( 'pageMessages:' + pageMessages);
        
        System.assertEquals( false, pdc.hasError, 'Error flag should be false.');
        System.assertEquals( 0, pageMessages.size(), 'Should have no error messages:' + pageMessages);
        
        System.assertNotEquals( null, pdc.allPostList, 'Post data list should not be null.');
        System.assertNotEquals( 0, pdc.allPostList.size(), 'Post list should have entries.');
        System.assertNotEquals( 0, pdc.displayedPostList.size(), 'Post list should have entries.');
        
        // this cover the Post class
        // the following should match the test data created, i only check if that is not null
        System.assertNotEquals( null, pdc.allPostList[0].userId, 'userId should exist');
        System.assertNotEquals( null, pdc.allPostList[0].id, 'id should exist');
        System.assertNotEquals( null, pdc.allPostList[0].title, 'title should exist');
        System.assertNotEquals( null, pdc.allPostList[0].body, 'body should exist');
    }
    
    // ========================================================================
    // test with undefined mock, i.e. representing no url access
    static testMethod void test02_badSiteTest(){
        // note that we intentionally not setting HttpCalloutMock
        Test.startTest();
        PostDisplayController pdc = new PostDisplayController();
        System.assertEquals( false, pdc.hasError, 'Error flag should be false as the beginning.');
        
        pdc.getDataButton(); 
        Test.stopTest();
        
        System.assertEquals( true, pdc.hasError, 'Error flag should be true.');
        System.assertEquals( null, pdc.allPostList, 'Post data list should be null.');
        
        List<Apexpages.Message> pageMessages = ApexPages.getMessages();
        System.debug( 'pageMessages:' + pageMessages);
        System.assertNotEquals( 0, pageMessages.size(), 'Should have no error messages:' + pageMessages);
        
    }
    
    // ========================================================================
    // test with incompatible data format
    static testMethod void test03_badReturnData(){
        
        Test.setMock(HttpCalloutMock.class, new PostCalloutMock(POST_DATA_SAMPLE_03_BAD_FORMAT)); 
        
        Test.startTest();
        PostDisplayController pdc = new PostDisplayController();
        System.assertEquals( false, pdc.hasError, 'Error flag should be false as the beginning.');
        pdc.getDataButton(); 
        Test.stopTest();
        
        System.assertEquals( true, pdc.hasError, 'Error flag should be true.');
        List<Apexpages.Message> pageMessages = ApexPages.getMessages();
        System.debug( 'pageMessages:' + pageMessages);
        System.assertNotEquals( 0, pageMessages.size(), 'Should have error message:' + pageMessages);
        
        System.assertEquals( null, pdc.displayedPostList, 'Post data list should be null.');
        
    }
    
    // ========================================================================
    // basic test, happy path
    static testMethod void test04_navigationCalls() {
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new PostCalloutMock(POST_DATA_SAMPLE_04_FIFTEEN)); 
        Test.startTest();
        PageReference pageRef = Page.PostDisplayPage;
        Test.setCurrentPage(pageRef);
        PostDisplayController pdc = new PostDisplayController();
        System.assertEquals( false, pdc.hasError, 'Error flag should be false as the beginning.');
        
        pdc.pageSize = TEST_PAGE_SIZE;
        
        pdc.getDataButton(); 
        Test.stopTest();
        List<Apexpages.Message> pageMessages = ApexPages.getMessages();
        
        // start at the very beginning, first page
        System.assert( pdc.allPostList.size() > pdc.pageSize, 'This test assumes that the total downloaded records is more than  displayed records per page, all:' +  pdc.allPostList.size() + '; displayed:' + pdc.pageSize);
        System.assertEquals( pdc.allPostList[0], pdc.displayedPostList[0], 'The first page should contain the first page' );
        System.assertEquals( pdc.getPageNumber(), 1, 'This is the first page' );


        System.assertEquals( false, pdc.getShowPrevious(), 'Cannot show previous page from the first page.');
        System.assertEquals( true, pdc.getShowNext(), 'Should be able to go to next page.');
        
        System.assertEquals( false, pdc.hasError, 'Error flag should be false.');
        System.assertEquals( 0, pageMessages.size(), 'Should have no error messages:' + pageMessages);
        
        // go to next page, 2nd page
        pdc.goToNextButton();
        System.assertEquals( pdc.allPostList[pdc.pageSize], pdc.displayedPostList[0], 'The second page should contain the following block ' + pdc.allPostList[pdc.pageSize].id + ' vs ' + pdc.displayedPostList[0].id );
        System.assertEquals( true, pdc.getShowPrevious(), 'Should show previous page from the first page.');
        
        // back to beginning
        pdc.goToBeginningButton();
        System.assertEquals( false, pdc.getShowPrevious(), 'Cannot show previous page from the first page.');
        System.assertEquals( true, pdc.getShowNext(), 'Should be able to go to next page.');
        
        // back to the end
        pdc.goToLastButton();
        System.assertEquals( true, pdc.getShowPrevious(), 'Should show previous page from the last page.');
        System.assertEquals( false, pdc.getShowNext(), 'Should not be able to next page.');
        System.assertEquals( pdc.getPageNumber(), pdc.getTotalPages(), 'This is the last page' );
        
        // one page from the end
        pdc.goToPreviousButton();
        System.assertEquals( true, pdc.getShowNext(), 'Should be able to go to next page.');
    }
    
    
}