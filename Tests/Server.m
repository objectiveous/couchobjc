//
//  Server.m
//  CouchObjC
//
//  Created by Stig Brautaset on 21/03/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import "Server.h"
#import <CouchObjC/SBCouchServer.h>

@implementation Server

- (void)setUp {
    couch = [SBCouchServer new];
}

- (void)testSupportedVersion {
    id v = [couch version];
    STAssertTrue([v isGreaterThanOrEqualTo:@"0.7.2"], @"Version not supported: %@", v);
}

- (void)testDefaultHost {
    STAssertEqualObjects(couch.host, @"localhost", nil);
}

- (void)testDefaultPort {
    STAssertEquals(couch.port, (NSUInteger)5984, nil);
}

- (void)testBasics
{
    NSString *name = [NSString stringWithFormat:@"tmp%u", random()];
    STAssertTrue([couch createDatabase:name], nil);

    NSArray *list = [couch listDatabases];
    STAssertTrue([list containsObject:name], nil);

    STAssertTrue([couch deleteDatabase:name], nil);
    
    list = [couch listDatabases];
    STAssertFalse([list containsObject:name], nil);
}

@end
