//
//  Server.h
//  CouchObjC
//
//  Created by Stig Brautaset on 21/03/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class SBCouchServer;
@interface Server : SenTestCase {
    SBCouchServer *couch;
}

@end
