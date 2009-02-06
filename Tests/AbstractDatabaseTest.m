//
//  AbstractDatabaseTest.m
//  CouchObjC
//
//  Created by Robert Evans on 1/24/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "AbstractDatabaseTest.h"


@implementation AbstractDatabaseTest

-(void) setUp{
    couchServer = [[SBCouchServer alloc] initWithHost:@"localhost" port:5984];
    srandom(time(NULL));
    NSString *name = [NSString stringWithFormat:@"tmp%u", random()];

    if([couchServer createDatabase:name]){
        couchDatabase = [[couchServer database:name] retain];
    }else{
        STFail(@"Could not create database %@", name);
    }
}

- (void)tearDown {
    [couchServer deleteDatabase:couchDatabase.name];
    [couchServer release];
    [couchDatabase release];
}

@end
