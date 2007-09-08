//
//  CouchUnit.m
//  CouchObjC
//
//  Created by Stig Brautaset on 06/09/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import <Couch/SBCouch.h>

#import "CouchUnit.h"

@implementation CouchUnit

- (void)setUp
{
    couch = [SBCouch new]; // Using CouchDB default: http://localhost:8888/
    dbs = [[@"foo bar baz" componentsSeparatedByString:@" "]
            sortedArrayUsingSelector:@selector(compare:)];
}

- (void)tearDown
{
    [couch release];
}

- (void)test01initWithoutEndpont
{
    STAssertThrows([SBCouch newWithEndpoint:nil], @"Must pass endpoint to init method" );
}

- (void)test02create
{
    NSEnumerator *e = [dbs objectEnumerator];
    for (NSString *s; s = [e nextObject]; )
        [couch createDatabase:s];
}

- (void)test03delete
{
    NSEnumerator *e = [dbs objectEnumerator];
    for (NSString *s; s = [e nextObject]; )
        [couch deleteDatabase:s];
}

- (void)test04listEmpty
{
    STAssertEqualObjects([couch listDatabases], [NSArray array], nil);
}

- (void)test05listNotEmpty
{
    [self test02create];
    STAssertEqualObjects([couch listDatabases], dbs, nil);
}

- (void)test06listEmptyAfterDelete
{
    [self test05listNotEmpty];
    [self test03delete];
    [self test04listEmpty];
}

@end
