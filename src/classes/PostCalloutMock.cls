/* mock class to emulate the response of the rest api call
 */ 
@isTest
global class PostCalloutMock implements HttpCalloutMock {
    
    // private static final String POST_DATA_SAMPLE_01_EMPTY = '';
    // private static final String POST_DATA_SAMPLE_02_DEFAULT = '{ "userId": 1,"id": 1, "title": "test 01"}, { "userId": 2,"id": 2, "title": "test 02"}';
    
    private String testData;
    
    // constructor with testData as parameter, use something like the POST_DATA_SAMPLE above
    public PostCalloutMock(String postDataSample ){
        testData = postDataSample;
    }
    
    
    // =======================================================================
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[' + testData + ']');
        response.setStatusCode(200);
        return response; 
    }
}