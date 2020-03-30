// this class represents Post, the type provided by the REST API server
public with sharing class Post {
    
    
    public integer userId {get;set;}
    public integer id {get;set;}
    public string title {get;set;}
    public string body {get;set;}
    
    // ========================================================================
    // constructor
    //public Post() {
    //}
    
}