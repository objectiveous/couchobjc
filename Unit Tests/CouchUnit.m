//
//  CouchUnit.m
//  CouchObjC
//
//  Created by Stig Brautaset on 06/09/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import <Couch/SBCouch.h>

#import "CouchUnit.h"

@implementation CouchUnit

- (void)setUp
{
    couch = [SBCouch new]; // Using CouchDB default: http://localhost:8888/
}

- (void)tearDown
{
    [couch release];
}

- (void)test01initWithoutEndpont
{
    STAssertThrows([SBCouch newWithEndpoint:nil], @"Must pass endpoint to init method" );
}

- (void)test02basics
{
    NSString *db = [NSString stringWithFormat:@"z%u", random()]; // our sentinel
    NSArray *dbs = [couch listDatabases];
    unsigned cnt = [dbs count];

    STAssertFalse([dbs containsObject:db], @"%@ is not in %@", db, dbs);
    STAssertNoThrow([couch createDatabase:db], @"Can create db %@", db);

    dbs = [couch listDatabases];
    STAssertTrue([dbs containsObject:db], @"%@ is in %@", db, dbs);
    STAssertEquals([dbs count], cnt+1, @"Count has increased by one");
    STAssertThrows([couch createDatabase:db], @"Cannot create DB again");

    dbs = [couch listDatabases];
    STAssertTrue([dbs containsObject:db], @"%@ is in %@", db, dbs);
    STAssertEquals([dbs count], cnt+1, @"Didn't change number of dbs");

    STAssertNoThrow([couch deleteDatabase:db], @"Can delete db %@", db);

    dbs = [couch listDatabases];
    STAssertFalse([dbs containsObject:db], @"%@ is not in %@", db, dbs);
    STAssertEquals([dbs count], cnt, @"Back to original number of dbs");
    STAssertThrows([couch deleteDatabase:db], @"Cannot delete %@ again", db);
}

@end
