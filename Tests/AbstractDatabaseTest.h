//
//  A.h
//  CouchObjC
//
//  Created by Robert Evans on 1/24/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SenTestingKit/SenTestingKit.h>
@class SBCouchServer;
@class SBCouchDatabase;

@interface AbstractDatabaseTest : SenTestCase{
    SBCouchServer   *couchServer;
    SBCouchDatabase *couchDatabase;
}

@end
