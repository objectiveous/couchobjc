//
//  SBCouchServer.h
//  CouchObjC
//
//  Created by Stig Brautaset on 21/03/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SBCouchServer : NSObject {
    NSString *host;
    NSUInteger port;
}

@property (readonly) NSString *host;
@property (readonly) NSUInteger port;

/// Initialise a server object with a host and port
- (id)initWithHost:(NSString*)h port:(NSUInteger)p;

/// The server version
- (NSString*)version;

- (NSArray*)listDatabases;

- (BOOL)createDatabase:(NSString*)n;
- (BOOL)deleteDatabase:(NSString*)n;

@end
