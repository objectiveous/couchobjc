//
//  A.h
//  CouchObjC
//
//  Created by Robert Evans on 1/24/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SenTestingKit/SenTestingKit.h>
#import <CouchObjC/CouchObjC.h>

static NSString *TEST_DESIGN_NAME = @"test-views";

@interface AbstractDatabaseTest : SenTestCase{
    SBCouchServer   *couchServer;
    SBCouchDatabase *couchDatabase;
}

@property (nonatomic, retain) SBCouchServer *couchServer;
@property (nonatomic, retain) SBCouchDatabase *couchDatabase;

-(SBCouchResponse*)provisionViews;
- (void)provisionDocuments;
@end
