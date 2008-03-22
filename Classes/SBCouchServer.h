//
//  SBCouchServer.h
//  CouchObjC
//
//  Created by Stig Brautaset on 21/03/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SBCouchDatabase;

/// Interface to a CouchDB server
@interface SBCouchServer : NSObject {
@private
    NSString *_host;
    NSUInteger _port;
}


/// Initialise a server object with a host and port
- (id)initWithHost:(NSString*)h port:(NSUInteger)p;

/// The hostname of the server.
@property (readonly) NSString *host;

/// The port number of the server.
@property (readonly) NSUInteger port;

/// Returns the server version.
- (NSString*)version;

/// Returns a list of databases available.
- (NSArray*)listDatabases;

/// Creates a database.
- (BOOL)createDatabase:(NSString*)x;

/// Deletes a database.
- (BOOL)deleteDatabase:(NSString*)x;

/// Returns a database object for working with documents.
- (SBCouchDatabase*)database:(NSString*)x;

@end
