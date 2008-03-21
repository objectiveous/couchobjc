//
//  Database.m
//  CouchObjC
//
//  Created by Stig Brautaset on 21/03/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import "Database.h"
#import <CouchObjC/CouchDB.h>

@implementation Database

- (void)setUp {    
    couch = [SBCouchServer new];

    NSString *name = [NSString stringWithFormat:@"tmp%u", random()];
    [couch createDatabase:name];
    db = [[couch database:name] retain];
}

- (void)tearDown {
    [couch deleteDatabase:db.name];
    [couch release];
    [db release];
}

- (void)testDatabaseInfo {
    NSMutableDictionary *expected = [NSMutableDictionary dictionary];
    [expected setObject:[NSNumber numberWithInt:0] forKey:@"doc_count"];
    [expected setObject:[NSNumber numberWithInt:0] forKey:@"update_seq"];
    [expected setObject:db.name forKey:@"db_name"];
    STAssertEqualObjects([db get:@""], expected, nil);
}

- (void)testPostDocument {
    NSDictionary *doc = [NSDictionary dictionary];
    SBCouchResponse *meta = [db postDocument:doc];
    STAssertTrue(meta.ok, nil);
    STAssertNotNil(meta.id, nil);
    STAssertNotNil(meta.rev, nil);
}

- (void)testGetDocument {
    NSDictionary *doc = [NSDictionary dictionaryWithObject:@"Stig" forKey:@"coolest"];
    SBCouchResponse *meta = [db postDocument:doc];

    doc = [db get:meta.id];
    STAssertEqualObjects([doc objectForKey:@"coolest"], @"Stig", nil);
}

- (void)testPutDocument {
    NSDictionary *doc = [NSDictionary dictionary];
    SBCouchResponse *meta = [db putDocument:doc withId:@"Stig"];
    STAssertTrue(meta.ok, nil);
    STAssertEqualObjects(meta.id, @"Stig", nil);
    STAssertNotNil(meta.rev, nil);
}    

- (void)testListDocuments {
    NSArray *ducks = [@"hetti netti letti" componentsSeparatedByString:@" "];
    for (id duck in ducks) {
        NSDictionary *doc = [NSDictionary dictionaryWithObject:duck forKey:@"name"];
        [db postDocument:doc];
    }

    NSDictionary *list = [db get:@"_all_docs"];
    STAssertEquals([[list objectForKey:@"offset"] intValue], 0, nil);
    STAssertEquals([[list objectForKey:@"total_rows"] intValue], 3, nil);
}

@end
