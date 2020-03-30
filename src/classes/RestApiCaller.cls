public with sharing class RestApiCaller {

    public boolean hasError {get; private set;}
    public String errorMessage {get; private set;} 
    
    // error handling would be considered later, may be by adding other intent out parameter
    public List<Post> getData( String endPoint) {
        List<Post> results = null;
        errorMessage=null;
        
        hasError = true; 
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endPoint);
            request.setMethod('GET');
            
            HttpResponse response = http.send(request);
        
            if (response.getStatusCode() == 200) {
                // Deserialize the JSON string into collections Post.
                
                // blah xx = (blah) JSON.deserializeUntyped(response.getBody());
                results = (List<Post>) JSON.deserialize(response.getBody(), List<Post>.class);
                //system.debug( 'xxxxx results:' + results);
                hasError = false;
            
            } else {
                errorMessage = response.toString();
                System.debug( 'response error: ' + errorMessage);
            }
        } catch (Exception ex){
            System.debug( 'RestApiCaller exception: ' + ex);
            errorMessage = ex.getMessage(); 
        }
        return results;
    }



}