//
//  SBCouchDatabase.h
//  CouchObjC
//
//  Created by Stig Brautaset on 21/03/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SBCouchServer;
@class SBCouchResponse;

/// Interface to a CouchDB database.
@interface SBCouchDatabase : NSObject {
    SBCouchServer *server;
    NSString *name;
}

/// Initialise a database with a server and name.
- (id)initWithServer:(SBCouchServer*)server name:(NSString*)name;

/// The name of the database.
@property (readonly) NSString *name;

/// Query the database in various ways.
- (id)get:(NSString*)args;

/// Post a document to the database.
- (SBCouchResponse*)postDocument:(NSDictionary*)doc;

/// Put a document to the given name in the database.
- (SBCouchResponse*)putDocument:(NSDictionary*)doc named:(NSString*)x;

/// Delete a document.
- (SBCouchResponse*)deleteDocument:(NSDictionary*)doc;

@end
