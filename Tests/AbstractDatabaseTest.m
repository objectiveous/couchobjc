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

-(void) setUp{
    couchServer = [[SBCouchServer alloc] initWithHost:@"localhost" port:5984];
    srandom(time(NULL));
    NSString *name = [NSString stringWithFormat:@"int-couchobjc-%u", random()];

    if([couchServer createDatabase:name]){
        couchDatabase = [[couchServer database:name] retain];
    }else{
        STFail(@"Could not create database %@", name);
    }
}

-(SBCouchResponse*)provisionViews{
    SBCouchView *view = [[SBCouchView alloc] initWithName:@"totals" andMap:MAP_FUNCTION andReduce:REDUCE_FUNCTION];
    
    SBCouchDesignDocument *designDocument = [[SBCouchDesignDocument alloc] initWithDesignDomain:TEST_DESIGN_NAME couchDatabase:couchDatabase];
    [designDocument addView:view withName:TEST_VIEW_NAME_1];
    [designDocument addView:view withName:TEST_VIEW_NAME_2];
    [designDocument addView:view withName:TEST_VIEW_NAME_3];
    
    return [self.couchDatabase createDocument:designDocument];
}

- (void)provisionDocuments{
    int count = 100;
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
