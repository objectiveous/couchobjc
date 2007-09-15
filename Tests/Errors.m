//
//  Errors.m
//  CouchObjC
//
//  Created by Stig Brautaset on 15/09/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import "Tests.h"

@implementation Errors

- (void)setUp
{
    couch = [SBCouch new];
    [couch createDatabase:@"foo"];
    [couch selectDatabase:@"foo"];
}

- (void)tearDown
{
    if ([couch isDatabaseAvailable:@"foo"])
        [couch deleteDatabase:@"foo"];
    [couch release];
}

- (void)testInitNoEndpoint
{
    tn( [SBCouch newWithURLString:nil], @"enoendpoint" );
}

- (void)testCreateExistingDatabase
{
    tn( [couch createDatabase:@"foo"], @"edbexists");
}

- (void)testDeleteMissingDatabase
{
    tn( [couch deleteDatabase:@"bar"], @"enodatabase");
}

- (void)testSelectMissingDatabase
{
    tn( [couch selectDatabase:@"bar"], @"enodatabase");
}


@end
