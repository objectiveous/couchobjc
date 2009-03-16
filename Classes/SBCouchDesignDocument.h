//
//  SBCouchDesignDocument.h
//  CouchObjC
//
//  Created by Robert Evans on 2/5/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SBCouchDocument.h"
#import "SBCouchView.h"
#import <JSON/JSON.h>

/*!
 Couple a facts about couchDB are important to understand when working with this class. 
 
 1] Design documents currently get stored in database/_design.  
 2] Views get executed via HTTP GET calls to database/_view 
 
 Now, given that SBCouchDocument and SBCouchView are intend to be Resources in the REST sense 
 of the word both these types (SBCouchDocument and SBCouchView) have an identity property which 
 is used along with SBCouchDatabase to derive a Resources URL. This all works swimmingly until 
 we pluck an SBCouchView from a SBCouchDesignDocument that we have recieved via an HTTP GET. 
 
 Should the SBCouchView have an identity of /database/_design/view-name? If so, it will be 
 impossible to issue the following without swapping out the path element _design or _view: 
 
    [view viewEnumerator]
 
 Also, an SBCouchView plucked from a SBCouchDocument is not really Resource in the sense that 
 there's no referencable "things" at location /database/_design/*. In other words, the only 
 Resources at _design/ are design documents that just happen to hold/contain views. 
 
 So, what's a poor boy to do? I could be wrong but it seems like the natural thing to do is 
 to allow SBCouchViews to have their _view/ identities. This will never be an issue in term 
 of POSTs or PUTs of design documents as the identity information is never sent to the server. 
 
 It will also have the advantage of consistency in the sense that one can reason about the 
 state of things in terms of HTTP/REST which is part of the CouchDB way of seeing the world. 

 */
@interface SBCouchDesignDocument : SBCouchDocument {
    NSString *designDomain;
}

@property (retain) NSString *designDomain;

+ (SBCouchDesignDocument*)designDocumentFromDocument:(SBCouchDocument*)aCouchDocument;
- (id)initWithDesignDomain:(NSString*)domain couchDatabase:(SBCouchDatabase*)aCouchDatabaseOrNil;
- (id)initWithDictionary:(NSDictionary*)aDictionary couchDatabase:(SBCouchDatabase*)aCouchDatabaseOrNil;
- (void)addView:(SBCouchView*)view withName:(NSString*)viewName;
- (SBCouchView*)view:(NSString*)viewName;
- (NSString*)language;
- (NSDictionary*)views;
@end
