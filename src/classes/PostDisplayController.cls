/* Controller for PostDisplayPage (vfp)
 * 20200330-sl
 */

public with sharing class PostDisplayController {
    //@testVisible 
    private static final string CONFIG_NAME_REST_API = 'REST_API_Post_Endpoint';
    private static final string ERROR_CONFIG_NAME_REST_API = 'Custom metadata record not found:';
    private static final integer DEFAULT_PAGE_SIZE = 12;
    
    @testVisible
    private List<Post> allPostList {get; private set;} // complete list
    public List<Post> displayedPostList {get; private set;} 
    
    public boolean hasError {get; private set;}
    
    private RestApiCaller rac;
    private String restApiEndPoint;

    // navigation related
    public Integer pageSize {public get; public set;}
    
    private Integer startingRecord = 0; // first record to display
    private Integer numOfAllRecords; 
    
    // =======================================================================
    // controller 
    public PostDisplayController(){
        rac = new RestApiCaller();
        hasError = false;
        restApiEndPoint = getRestApiEndPoint();
        
        pageSize = DEFAULT_PAGE_SIZE;
        
        allPostList = null;  // assume that Post table only display when requested
        numOfAllRecords = 0;  
    }
    
    
    // =======================================================================
    // get all the Post data, update the displayed list
    public PageReference getDataButton() {
        allPostList = getPostRecords(restApiEndPoint);
        numOfAllRecords = (allPostList == null) ? 0 : allPostList.size();
        startingRecord = 0; // reset to first page
        updateDisplayedList(); 
        return null;
    }
    
    
    // =======================================================================
    // call the REST API method etc
    public List<Post> getPostRecords( String endPoint) {
        List<Post> postRecs = null;
        postRecs = rac.getData(endPoint);
        
        if (rac.hasError) {
            hasError = rac.hasError; 
            System.debug( 'getPostRecord has error:' + rac.errorMessage);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, rac.errorMessage));
        }
        return  postRecs;
    }
    
    
    // =======================================================================
    // get custom metadata
    private String getRestApiEndPoint(){
        List<Config__mdt> configList = [select Value__c 
            from Config__mdt
            where DeveloperName = : CONFIG_NAME_REST_API limit 1];
        if (configList.size() > 0) {
            return configList[0].Value__c;
        } else {
            hasError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error
                , ERROR_CONFIG_NAME_REST_API + CONFIG_NAME_REST_API));
            return null;
        }
    }
    
    
    // =======================================================================
    // additional page navigations
    public PageReference goToBeginningButton() {
        startingRecord = 0;
        updateDisplayedList();
        return null;
    }

    public PageReference goToPreviousButton() {
        startingRecord -= pageSize;
        updateDisplayedList();
        return null;
    }

    public PageReference goToNextButton() {
        startingRecord += pageSize;
        updateDisplayedList();
        return null;
    }

    public PageReference goToLastButton() {
        Integer lastLeftoverPageSize = math.mod(numOfAllRecords, pageSize);
        if (lastLeftoverPageSize > 0) {
            startingRecord = numOfAllRecords - lastLeftoverPageSize; 
        } else if (numOfAllRecords >= pageSize){
            startingRecord = numOfAllRecords - pageSize; 
        } else {
            startingRecord = 0;
        }
        updateDisplayedList();
        return null;
    }

    public Boolean getShowPrevious() { 
       return (startingRecord>0);
    }

    public Boolean getShowNext() {
        return ( startingRecord + pageSize < numOfAllRecords) ;
    }

    public Integer getPageNumber() {
        return startingRecord/pageSize + 1;
    }

    public Integer getTotalPages() {
       if (math.mod(numOfAllRecords, pageSize) > 0) {
          return numOfAllRecords/pageSize + 1;
       } else {
          return (numOfAllRecords/pageSize);
       }
    }    
    
    
    
    // =======================================================================
    // display data selection
    private void updateDisplayedList() {
        if (allPostList == null) { 
            displayedPostList = null; 
        } else {
            displayedPostList = new List<Post>();
            Integer endOfBlockIdx = math.min( numOfAllRecords, startingRecord+pageSize ); 
            for (Integer idx=startingRecord;idx<endOfBlockIdx;idx++) {
                displayedPostList.add(allPostList[idx]);
            }
        }
    }
    
}