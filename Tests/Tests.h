//
//  Tests.h
//  CouchObjC
//
//  Created by Stig Brautaset on 06/09/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <Couch/Couch.h>

#define eq(x, y) STAssertEquals(x, y, nil)
#define eqo(x, y) STAssertEqualObjects(x, y, nil)
#define neqo(x, y) STAssertFalse([x isEqual:y], nil)

@interface Database : SenTestCase {
    SBCouch *couch;
    NSString *db;
}
@end

@interface Document : SenTestCase {
    SBCouch *couch;
}
@end

@interface Errors : SenTestCase
@end
