//
//  Database.m
//  CouchObjC
//
//  Created by Stig Brautaset on 21/03/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import <CouchObjC/CouchObjC.h>
#import <SenTestingKit/SenTestingKit.h>


@class SBCouchServer;
@class SBCouchDatabase;
@interface Database : SenTestCase {
    SBCouchServer *couch;
    SBCouchDatabase *db;
}

@end

@implementation Database

- (void)setUp {    
    srandom(time(NULL));
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

#pragma mark -

-(void)testProvidesInformation{
    SBCouchDatabaseInfoDocument *databaseInformation = [db databaseInfo];

    STAssertNotNil(databaseInformation, nil);
    STAssertTrue([databaseInformation isKindOfClass:[SBCouchDatabaseInfoDocument class]], nil);
    STAssertNotNil(databaseInformation.db_name, nil);
    STAssertNotNil(databaseInformation.doc_count, nil);
    STAssertNotNil(databaseInformation.doc_del_count, nil);
    STAssertNotNil(databaseInformation.update_seq, nil);
    STAssertNotNil(databaseInformation.purge_seq, nil);
    STAssertNotNil(databaseInformation.compact_running, nil);
    STAssertNotNil(databaseInformation.disk_size, nil);
    STAssertNotNil(databaseInformation.instance_start_time, nil);
    
}

-(void)testProvidesProperDescription{
    NSString *description = [db description];
    NSString *properDescription = [NSString stringWithFormat:@"http://%@:%u/%@", couch.host, couch.port, db.name];
    
    STAssertTrue([description isEqualToString:properDescription], @"%@ vs. %@", description, properDescription);
}

- (void)testPostDocument {
    NSDictionary *doc = [NSDictionary dictionary];
    SBCouchResponse *meta = [db postDocument:doc];
    STAssertTrue(meta.ok, nil);
    STAssertNotNil(meta.name, nil);
    STAssertNotNil(meta.rev, nil);
}

- (void)testGetDocument {
    NSDictionary *doc = [NSDictionary dictionaryWithObject:@"Stig" forKey:@"coolest"];
    SBCouchResponse *meta = [db postDocument:doc];
    doc = [db get:meta.name];
    STAssertEqualObjects([doc objectForKey:@"coolest"], @"Stig", nil);
}

- (void)testDeleteDocument {
    NSMutableDictionary *doc = [NSMutableDictionary dictionaryWithObject:@"Stig" forKey:@"coolest"];
    SBCouchResponse *couchResponse = [db postDocument:doc];
    STAssertNotNil(couchResponse, @"Response was nil [%@]", couchResponse);
    doc.name = couchResponse.name;
    SBCouchResponse *couchReponse2= [db deleteDocument:doc];
    STAssertFalse(couchReponse2.ok, nil);
    
    NSDictionary *list = [db get:@"_all_docs"];
    STAssertEquals([[list objectForKey:@"total_rows"] intValue], 1, nil);

    doc.rev = couchResponse.rev;
    couchReponse2 = [db deleteDocument:doc];
    
    STAssertTrue(couchReponse2.ok, @"value was [%@]", couchReponse2);
    
    list = [db get:@"_all_docs"];
    STAssertEquals([[list objectForKey:@"total_rows"] intValue], 0, nil);
}

- (void)testPutDocument {
    NSDictionary *doc = [NSDictionary dictionary];
    SBCouchResponse *meta = [db putDocument:doc named:@"Stig"];
    STAssertTrue(meta.ok, nil);
    STAssertEqualObjects(meta.name, @"Stig", nil);
    STAssertNotNil(meta.rev, nil);
}

- (void)testUpdateDocument {
    id doc = [NSDictionary dictionary];
    SBCouchResponse *meta = [db postDocument:doc];
    doc = [db get:meta.name];
    STAssertNil([doc objectForKey:@"coolest"], nil);
    
    doc = [NSMutableDictionary dictionaryWithObject:@"Stig" forKey:@"coolest"];
    [doc setRev:meta.rev];
    
    meta = [db putDocument:doc named:meta.name];
    STAssertTrue(meta.ok, nil);

    doc = [db get:meta.name];
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
