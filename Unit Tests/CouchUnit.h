//
//  CouchUnit.h
//  CouchObjC
//
//  Created by Stig Brautaset on 06/09/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class SBCouch;

@interface CouchUnit : SenTestCase {
    SBCouch *couch;
}

@end
