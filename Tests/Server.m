//
//  Server.m
//  CouchObjC
//
//  Created by Stig Brautaset on 21/03/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <CouchObjC/CouchObjC.h>

@class SBCouchServer;

@interface Server : SenTestCase {
    SBCouchServer *couch;
}

@end

@implementation Server

- (void)setUp {
    couch = [SBCouchServer new];
    srandom(time(NULL));
}

- (void)tearDown {
    [couch release];
}

- (void)testSupportedVersion {
    id v = [couch version];
    STAssertTrue([v isGreaterThanOrEqualTo:@"0.8.1"], @"Version not supported: %@", v);
}

- (void)testDefaultHost {
    STAssertEqualObjects(couch.host, @"localhost", nil);
}

- (void)testDefaultPort {
    STAssertEquals(couch.port, (NSUInteger)5984, nil);
}

- (void)testBasics{
    NSString *databaseName = [NSString stringWithFormat:@"tmp%u", random()]; 
    STAssertTrue([couch createDatabase:databaseName], @"Call failed to create database. [%@]", databaseName);

    NSArray *list = [couch listDatabases];
    STAssertTrue([list containsObject:databaseName], nil);
    
    STAssertTrue([couch deleteDatabase:databaseName], nil);
    
    //list = [couch listDatabases];
    //STAssertFalse([list containsObject:name], nil);
}

@end
