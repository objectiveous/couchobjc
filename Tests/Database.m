//
//  Database.m
//  CouchObjC
//
//  Created by Stig Brautaset on 21/03/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import "Database.h"
#import <CouchObjC/CouchObjC.h>

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

- (void)testDeleteDocument {
    NSMutableDictionary *doc = [NSMutableDictionary dictionaryWithObject:@"Stig" forKey:@"coolest"];
    SBCouchResponse *meta = [db postDocument:doc];
    
    doc.id = meta.id;
    SBCouchResponse *meta2 = [db deleteDocument:doc];
    STAssertFalse(meta2.ok, nil);
    NSDictionary *list = [db get:@"_all_docs"];
    STAssertEquals([[list objectForKey:@"total_rows"] intValue], 1, nil);

    doc.rev = meta.rev;
    meta2 = [db deleteDocument:doc];
    STAssertTrue(meta2.ok, nil);
    
    list = [db get:@"_all_docs"];
    STAssertEquals([[list objectForKey:@"total_rows"] intValue], 0, nil);
}

- (void)testPutDocument {
    NSDictionary *doc = [NSDictionary dictionary];
    SBCouchResponse *meta = [db putDocument:doc withId:@"Stig"];
    STAssertTrue(meta.ok, nil);
    STAssertEqualObjects(meta.id, @"Stig", nil);
    STAssertNotNil(meta.rev, nil);
}

- (void)testUpdateDocument {
    id doc = [NSDictionary dictionary];
    SBCouchResponse *meta = [db postDocument:doc];
    doc = [db get:meta.id];
    STAssertNil([doc objectForKey:@"coolest"], nil);
    
    doc = [NSMutableDictionary dictionaryWithObject:@"Stig" forKey:@"coolest"];
    [doc setRev:meta.rev];
    
    meta = [db putDocument:doc withId:meta.id];
    STAssertTrue(meta.ok, nil);

    doc = [db get:meta.id];
    STAssertEqualObjects([doc objectForKey:@"coolest"], @"Stig", nil);

    NSDictionary *list = [db get:@"_all_docs"];
    STAssertEquals([[list objectForKey:@"total_rows"] intValue], 1, nil);
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
