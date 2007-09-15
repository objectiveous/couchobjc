//
//  Database.m
//  CouchObjC
//
//  Created by Stig Brautaset on 06/09/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import "Tests.h"

@implementation Database

- (void)setUp
{
    couch = [SBCouch new]; // Using CouchDB default: http://localhost:8888/
    
    srandom(time(NULL));   // seed the random number generator
    db = [[NSString alloc] initWithFormat:@"z%u", random()];
}

- (void)tearDown
{
    [db release];
    [couch release];
}

- (void)test01initWithoutEndpont
{
    STAssertThrows([SBCouch newWithEndpoint:nil], @"Must pass endpoint to init method" );
}

- (void)test01version
{
    STAssertEqualObjects([couch serverVersionString], @"0.6.4", @"Is a supported expected version");
}

- (void)test02basics
{
    STAssertFalse([couch isDatabaseAvailable:db], @"%@ is not available", db);
    STAssertNoThrow([couch createDatabase:db], @"Can create db %@", db);

    STAssertTrue([couch isDatabaseAvailable:db], @"%@ is available", db);
    STAssertThrows([couch createDatabase:db], @"Cannot create DB again");

    STAssertTrue([couch isDatabaseAvailable:db], @"%@ is still available", db);
    STAssertNoThrow([couch deleteDatabase:db], @"Can delete db %@", db);

    STAssertFalse([couch isDatabaseAvailable:db], @"%@ is not available", db);
    STAssertThrows([couch deleteDatabase:db], @"Cannot delete %@ again", db);

    STAssertFalse([couch isDatabaseAvailable:db], @"%@ is still not available", db);
}

- (void)test03select
{
    STAssertThrows([couch selectDatabase:db], @"Cannot select non-existing db %@", db);
    STAssertNoThrow([couch createDatabase:db], @"Can create db %@", db);
    STAssertNoThrow([couch selectDatabase:db], @"Can select %@ now", db);
    STAssertNoThrow([couch deleteDatabase:db], @"Can create db %@", db);
    STAssertThrows([couch selectDatabase:db], @"Cannot select non-existing db %@", db);
}

- (void)test04listDatabases
{
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
