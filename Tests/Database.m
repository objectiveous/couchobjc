//
//  Database.m
//  CouchObjC
//
//  Created by Stig Brautaset on 06/09/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import "Tests.h"

@implementation Database

- (void)testServerVersion
{
    STAssertEqualObjects([couch serverVersion], @"0.6.4", @"Is a supported version");
}

- (void)testListDatabases
{
    srandom(time(NULL));   // seed the random number generator
    NSString *db = [NSString stringWithFormat:@"z%u", random()];

    NSArray *dbs = [couch listDatabases];
    unsigned cnt = [dbs count];

    STAssertFalse([dbs containsObject:db], @"%@ is not in %@", db, dbs);
    STAssertNoThrow([couch createDatabase:db], @"Can create db %@", db);

    dbs = [couch listDatabases];
    STAssertTrue([dbs containsObject:db], @"%@ is in %@", db, dbs);
    STAssertEquals([dbs count], cnt+1, @"Count has increased by one");

    STAssertNoThrow([couch deleteDatabase:db], @"Can delete db %@", db);
    STAssertFalse([couch isDatabaseAvailable:db], @"%@ is not available", db);

    dbs = [couch listDatabases];
    STAssertEquals([dbs count], cnt, @"Back to original number of dbs");
}

@end
