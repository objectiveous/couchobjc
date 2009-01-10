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

-(void)estLibrary{            
    NSDictionary *list = [dataBase get:@"_all_docs"];
    
    NSArray *keys = [list allKeys];
    NSArray *values = [list allValues];
    
    
    for(id o in list){
        BBTraceInfo(@" --> [%@]", [list objectForKey:o]); 
    }
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

- (void)testInteratorUsingCount {
    
    SBCouchEnumerator *iter = (SBCouchEnumerator*) [dataBase allDocsInBatchesOf:(NSInteger*)10];
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
