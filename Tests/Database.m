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
    db = [couch database:name];
}

- (void)tearDown {
    [couch deleteDatabase:[db name]];
    [couch release];
}

- (void)testDatabaseInfo {
    NSMutableDictionary *expected = [NSMutableDictionary dictionary];
    [expected setObject:[NSNumber numberWithInt:0] forKey:@"doc_count"];
    [expected setObject:[NSNumber numberWithInt:0] forKey:@"update_seq"];
    [expected setObject:db.name forKey:@"db_name"];
    STAssertEqualObjects([db get:@""], expected, nil);
}

- (void)test {
    NSMutableDictionary *expected = [NSMutableDictionary dictionary];
    [expected setObject:[NSNumber numberWithInt:0] forKey:@"doc_count"];
    [expected setObject:[NSNumber numberWithInt:0] forKey:@"update_seq"];
    [expected setObject:db.name forKey:@"db_name"];
    STAssertEqualObjects([db get:@""], expected, nil);
}


@end
