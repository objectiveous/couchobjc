//
//  SBCouchDatabase.h
//  CouchObjC
//
//  Created by Stig Brautaset on 21/03/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SBCouchServer;

@interface SBCouchDatabase : NSObject {
    SBCouchServer *server;
    NSString *name;
}

@property (readonly) NSString *name;

- (id)initWithServer:(SBCouchServer*)server name:(NSString*)name;

- (id)get:(NSString*)args;

@end
