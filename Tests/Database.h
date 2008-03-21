//
//  Database.h
//  CouchObjC
//
//  Created by Stig Brautaset on 21/03/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class SBCouchServer;
@class SBCouchDatabase;
@interface Database : SenTestCase {
    SBCouchServer *couch;
    SBCouchDatabase *db;
}

@end
