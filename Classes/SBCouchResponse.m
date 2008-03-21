//
//  SBCouchResponse.m
//  CouchObjC
//
//  Created by Stig Brautaset on 21/03/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import "SBCouchResponse.h"


@implementation SBCouchResponse

@synthesize ok;
@synthesize rev;

- (id)initWithDictionary:(NSDictionary*)x
{
    if (self = [super init]) {
        ok = [[x objectForKey:@"ok"] boolValue];
        _id = [[x objectForKey:@"id"] copy];
        rev = [[x objectForKey:@"rev"] copy];
    }
    return self;
}

- (void)dealloc
{
    [_id release];
    [rev release];
    [super dealloc];
}

- (NSString*)id {
    return [[_id retain] autorelease];
}

@end
