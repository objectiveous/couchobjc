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

// The ST guys sure like typing. Personally, I don't.
#define tn(expr, name) \
    STAssertThrowsSpecificNamed(expr, NSException, name, nil)

@interface Tests : SenTestCase {
    SBCouch *couch;
}
@end

@interface Database : Tests
@end

@interface Document : Tests
@end

@interface View : Tests
@end

@interface Errors : Tests
@end

