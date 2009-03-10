//
//  AbstractDatabaseTest.m
//  CouchObjC
//
//  Created by Robert Evans on 1/24/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "AbstractDatabaseTest.h"


//static NSString *TEST_DESIGN_NAME = @"test-views";
static NSString *MAP_FUNCTION     = @"function(doc) { if(doc.name == 'Frank'){ emit('Number of Franks', 1);}}";
static NSString *REDUCE_FUNCTION  = @"function(k, v, rereduce) { return sum(v);}";
//static NSString *TEST_DESIGN_NAME = @"integration-test";
static NSString *TEST_VIEW_NAME_1 = @"frankCount";
static NSString *TEST_VIEW_NAME_2 = @"funnyMen";
static NSString *TEST_VIEW_NAME_3 = @"jazzMen";


@implementation AbstractDatabaseTest
@synthesize couchServer;
@synthesize couchDatabase;
@synthesize numberOfViewsToCreate;
@synthesize numberOfDocumentsToCreate;

-(void) setUp{
    self.numberOfViewsToCreate = 10;
    self.numberOfDocumentsToCreate = 10;    
    couchServer = [SBCouchServer new];
    srandom(time(NULL));
    NSString *name = [NSString stringWithFormat:@"int-couchobjc-%u", random()];

    if([couchServer createDatabase:name]){
        couchDatabase = [[couchServer database:name] retain];
    }else{
        STFail(@"Could not create database %@", name);
    }
}

// XXX Need to autorelease 
-(void)provisionViews{
        int count = self.numberOfViewsToCreate;
    int i;
    for (i = 0; i < count; i++) {
        SBCouchView *view = [[SBCouchView alloc] initWithName:@"totals" andMap:MAP_FUNCTION andReduce:REDUCE_FUNCTION];
        NSString *testDesignDocumentName = [NSString stringWithFormat:@"%@-%u", TEST_DESIGN_NAME, random()];
        SBCouchDesignDocument *designDocument = [[SBCouchDesignDocument alloc] initWithDesignDomain:testDesignDocumentName couchDatabase:couchDatabase];
        [designDocument addView:view withName:TEST_VIEW_NAME_1];
        [designDocument addView:view withName:TEST_VIEW_NAME_2];
        [designDocument addView:view withName:TEST_VIEW_NAME_3];
        
        [self.couchDatabase createDocument:designDocument];
    }
}

- (void)provisionDocuments{
    int count = self.numberOfDocumentsToCreate;
    int i;
    
    SBCouchDocument *couchDocument = [SBCouchDocument new];
    for (i = 0; i < count; i++) {
        couchDocument.couchDatabase = self.couchDatabase;    
        NSString *name = [NSString stringWithFormat:@"first-%u", random()];
        [couchDocument detach];
        [couchDocument setObject:name forKey:@"first"];        
        [couchDatabase postDocument:couchDocument];
    }
    [couchDocument release];    
}

- (void)tearDown {
    [couchServer deleteDatabase:couchDatabase.name];
    [couchServer release];
    [couchDatabase release];
}

@end
