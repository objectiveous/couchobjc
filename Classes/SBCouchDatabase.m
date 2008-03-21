//
//  SBCouchDatabase.m
//  CouchObjC
//
//  Created by Stig Brautaset on 21/03/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import "SBCouchDatabase.h"
#import "SBCouchServer.h"

@implementation SBCouchDatabase

@synthesize name;

- (id)initWithServer:(SBCouchServer*)s name:(NSString*)n
{
    if (self = [super init]) {
        server = [s retain];
        name = [n copy];
    }
    return self;
}

@end
