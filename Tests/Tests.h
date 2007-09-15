//
//  Tests.h
//  CouchObjC
//
//  Created by Stig Brautaset on 06/09/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import <Couch/Couch.h>

@interface CouchUnit : SenTestCase {
    SBCouch *couch;
    NSString *db;
}
@end

@interface CouchDocumentUnit : SenTestCase
@end
