//
//  Setup.m
//  CouchObjC
//
//  Created by Stig Brautaset on 16/09/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//
//  This test fixture exists simply to kill duplication. The setup and
//  teardown for all the tests turned out to be the same.
//

#import "Tests.h"

@implementation Tests

- (void)setUp
{
    couch = [SBCouch new];
    if (![couch isDatabaseAvailable:@"foo"])
        [couch createDatabase:@"foo"];
    [couch selectDatabase:@"foo"];
}

- (void)tearDown
{
    if ([couch isDatabaseAvailable:@"foo"])
        [couch deleteDatabase:@"foo"];
    [couch release];
}

@end
