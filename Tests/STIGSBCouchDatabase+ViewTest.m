//
//  STIGSBCouchDatabase+ViewTest.m
//  stigmergic
//
//  Created by Robert Evans on 1/9/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <CouchObjC/CouchObjC.h>
#import "SBCouchDatabase+View.h"
#import "SBCouchEnumerator.h"

@interface STIGSBCouchDatabase_ViewTest : SenTestCase{
    SBCouchServer *couchServer;
    SBCouchDatabase *dataBase;
}
@end

@implementation STIGSBCouchDatabase_ViewTest

-(void) setUp{
    couchServer = [[SBCouchServer alloc] initWithHost:@"localhost" port:5984];
    dataBase = [couchServer database:@"database-for-test"];
}

- (void)testInteratorWithoutCount {
    NSEnumerator *iter = [dataBase allDocs];
    STAssertNotNil(iter, nil);
    id value;
    
    while ((value = [iter nextObject])) {
        STAssertTrue([value isKindOfClass:[NSDictionary class]],nil);
    }    
}

-(void)testItemAtIndex{
    SBCouchEnumerator *resultSet = (SBCouchEnumerator*) [dataBase allDocsInBatchesOf:10];
    STAssertNotNil([resultSet itemAtIndex:0], nil);
    STAssertNotNil([resultSet itemAtIndex:10], nil);
    STAssertNotNil([resultSet itemAtIndex:203], nil);
    STAssertNil([resultSet itemAtIndex:1000], nil);
    
    id item = [resultSet itemAtIndex:0];            
}
- (void)testIteratorUsingCount {
    
    SBCouchEnumerator *iter = (SBCouchEnumerator*) [dataBase allDocsInBatchesOf:10];
    STAssertNotNil(iter, nil);
    
    STAssertTrue( [iter totalRows] > 10 ,@"Count was [%i]", [iter totalRows] );

    int i = 0;
    id value;
    while ((value = [iter nextObject])) {      
        STAssertTrue([value isKindOfClass:[NSDictionary class]],nil);
        i++;
    } 
    STAssertTrue(i == 205, @"Index is off for some reason. Got [%i]", i);
}

@end
