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
#import "BBDebug.h"
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


- (void)estInteratorWithoutCount {
        
    // --- HERE WE GO
    NSEnumerator *iter = [dataBase allDocs];
    STAssertNotNil(iter, nil);
    BBTraceInfo(@"allDocs Enumerator [%@]", iter);
    id value;
    
    while ((value = [iter nextObject])) {
        /* code that acts on the dictionary’s values */
        STAssertTrue([value isKindOfClass:[NSDictionary class]],nil);
        //BBTraceInfo(@" [%@] ", value);
    }    
}

-(void)testItemAtIndex{
    SBCouchEnumerator *resultSet = (SBCouchEnumerator*) [dataBase allDocsInBatchesOf:10];
    //STAssertNotNil([resultSet itemAtIndex:0], nil);
    //STAssertNotNil([resultSet itemAtIndex:10], nil);
    STAssertNotNil([resultSet itemAtIndex:203], nil);
    //STAssertNil([resultSet itemAtIndex:1000], nil);
    
    id item = [resultSet itemAtIndex:0];
    BBTraceInfo(@"object at index 0 %@", [item valueForKey:@"id"]);
    
    /*
    id value;
    while ((value = [resultSet nextObject])) {      
        STAssertTrue([value isKindOfClass:[NSDictionary class]],nil);
        BBTraceInfo(@"%@", [value valueForKey:@"id"] );
    } 
     */
    
}
- (void)estInteratorUsingCount {
    
    SBCouchEnumerator *iter = (SBCouchEnumerator*) [dataBase allDocsInBatchesOf:10];
    STAssertNotNil(iter, nil);
    
    // Need a better way to control the number of items in the enumeration during test
    STAssertTrue( [iter totalRows] > 10 ,@"Count was [%i]", [iter totalRows] );

    int i = 0;
    id value;
    while ((value = [iter nextObject])) {      
        STAssertTrue([value isKindOfClass:[NSDictionary class]],nil);
        i++;
    } 
    STAssertTrue(i == 204, @"Index is off for some reason. Got [%i]", i);
}

@end
