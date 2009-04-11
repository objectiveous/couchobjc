//
//  SBCouchDatabase.h
//  CouchObjC
//
//  Created by Stig Brautaset on 21/03/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SBCouchDocument.h"
#import "SBCouchDesignDocument.h"
#import "SBCouchDatabaseInfoDocument.h"
#import "SBCouchView.h"

@class SBCouchServer;
@class SBCouchResponse;

/// Interface to a CouchDB database.
@interface SBCouchDatabase : NSObject {
    SBCouchServer *couchServer;
    NSString      *name;
}

/// Initialise a database with a server and name.
- (id)initWithServer:(SBCouchServer*)server name:(NSString*)name;

/// The name of the database.
@property (readonly) NSString      *name;
@property (readonly) SBCouchServer *couchServer;

#pragma mark -
#pragma mark GET Calls
#pragma mark methods that return collections
- (SBCouchDatabaseInfoDocument*)databaseInfo;
- (NSEnumerator*)getViewEnumerator:(NSString*)viewName;
- (NSEnumerator*)viewEnumerator:(SBCouchView*)view;
- (NSEnumerator*)allDocsInBatchesOf:(NSInteger)count;
- (NSEnumerator*)allDocs;
- (NSEnumerator*)getDesignDocuments;
- (SBCouchView*)designDocumentsView;

#pragma mark single documents

- (SBCouchDesignDocument*)getDesignDocument:(NSString*)docId withRevisionCount:(BOOL)withCount andInfo:(BOOL)andInfo revision:(NSString*)revisionOrNil;
- (SBCouchDesignDocument*)getDesignDocument:(NSString*)docId;
- (SBCouchDocument*)getDocument:(NSString*)docId withRevisionCount:(BOOL)withCount andInfo:(BOOL)andInfo revision:(NSString*)revisionOrNil;

/// Query the database in various ways.
- (NSDictionary*)get:(NSString*)args;

#pragma mark -
#pragma mark PUT and POST Calls

- (NSEnumerator*)slowViewEnumerator:(SBCouchView*)view;
- (NSDictionary*)runSlowView:(SBCouchView*)view;



/// Post a document to the database.
- (SBCouchResponse*)postDocument:(NSDictionary*)doc;

- (SBCouchResponse*)createDocument:(SBCouchDesignDocument*)doc;
/// Put a document to the given name in the database.
- (SBCouchResponse*)putDocument:(NSDictionary*)doc named:(NSString*)x;
/// Put a document into the database. The value of _id will be used for its name. 
- (SBCouchResponse*)putDocument:(SBCouchDocument*)couchDocument;


#pragma mark -
#pragma mark DELETE Calls
// Delete this database
-(SBCouchResponse*)delete;
/// Delete a document.
- (SBCouchResponse*)deleteDocument:(NSDictionary*)doc;

#pragma mark -
-(NSString*)urlString;
-(NSString*)constructURL:(NSString*)docId withRevisionCount:(BOOL)withCount andInfo:(BOOL)andInfo revision:(NSString*)revisionOrNil;
@end