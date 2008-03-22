//
//  SBCouchDatabase.h
//  CouchObjC
//
//  Created by Stig Brautaset on 21/03/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SBCouchServer;

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
- (id)postDocument:(NSDictionary*)doc;

/// Put a document to the database.
- (id)putDocument:(NSDictionary*)doc named:(NSString*)x;

/// Delete a document.
- (id)deleteDocument:(NSDictionary*)doc;

@end
