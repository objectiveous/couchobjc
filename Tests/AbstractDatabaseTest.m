//
//  AbstractDatabaseTest.m
//  CouchObjC
//
//  Created by Robert Evans on 1/24/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "AbstractDatabaseTest.h"



static NSString *MAP_FUNCTION     = @"function(doc){emit(doc._id, doc);}";
static NSString *REDUCE_FUNCTION  = @"function(k,v,rereduce){return 1;}";

static NSString *TEST_DESIGN_NAME = @"test-design";
static NSString *TEST_VIEW_NAME_1 = @"view1";
static NSString *TEST_VIEW_NAME_2 = @"view2";
static NSString *TEST_VIEW_NAME_3 = @"view3";


@implementation AbstractDatabaseTest
@synthesize couchServer;
@synthesize couchDatabase;
@synthesize numberOfViewsToCreate;
@synthesize numberOfDocumentsToCreate;

-(void) setUp{
    self.numberOfViewsToCreate = 3;
    self.numberOfDocumentsToCreate = 2;    
    self.couchServer = [SBCouchServer new];
    NSString *testDatabaseName = [NSString stringWithFormat:@"test_database-%@", [[self newUUID] lowercaseString]];
    
    if([self.couchServer createDatabase:testDatabaseName]){
        self.couchDatabase = [self.couchServer database:testDatabaseName];
    }else{        
        STFail(@"Could not create database %@", testDatabaseName);
    }
    STAssertNotNil(self.couchDatabase, nil);
}


-(NSString*) newUUID {
    CFUUIDRef uuidObj = CFUUIDCreate(nil);//create a new UUID
    //get the string representation of the UUID
    NSString *uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return [uuidString autorelease];
}

- (void)tearDown {
    [couchServer deleteDatabase:couchDatabase.name];
    [couchServer release], couchServer = nil;
    [couchDatabase release], couchDatabase = nil;
    //self.couchServer = nil;
    //self.couchDatabase = nil;
}

-(void)provisionViews{
        int count = self.numberOfViewsToCreate;
    int i;
    for (i = 0; i < count; i++) {
        SBCouchView *view = [ [[SBCouchView alloc] initWithName:@"totals" couchDatabase:self.couchDatabase] autorelease];
        [view setMap:MAP_FUNCTION];
        [view setReduce:REDUCE_FUNCTION];
        
        NSString *testDesignDocumentName = [NSString stringWithFormat:@"%@-%u", TEST_DESIGN_NAME, random()];
        SBCouchDesignDocument *designDocument = [[SBCouchDesignDocument alloc] initWithName:testDesignDocumentName couchDatabase:couchDatabase];
        [designDocument addView:view withName:TEST_VIEW_NAME_1];
        [designDocument addView:view withName:TEST_VIEW_NAME_2];
        [designDocument addView:view withName:TEST_VIEW_NAME_3];
        
        [self.couchDatabase createDocument:designDocument];
        [designDocument release], designDocument = nil;
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



@end
