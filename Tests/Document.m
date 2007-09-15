//
//  Document.m
//  CouchObjC
//
//  Created by Stig Brautaset on 15/09/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import "Tests.h"

@implementation Document

- (void)setUp
{
    couch = [SBCouch new];
    [couch createDatabase:@"foo"];
    [couch selectDatabase:@"foo"];
}

- (void)tearDown
{
    [couch deleteDatabase:@"foo"];
    [couch release];
}

- (void)testCreateEmpty
{
    NSDictionary *doc = [couch saveDocument:[NSDictionary dictionary]];
    eq([doc count], (unsigned)2);
    STAssertTrue([[doc objectForKey:@"_id"] isKindOfClass:[NSString class]], nil);
    STAssertTrue([[doc objectForKey:@"_rev"] isKindOfClass:[NSNumber class]], nil);
}

- (void)testCreateNamed
{
    NSDictionary *doc = [NSDictionary dictionaryWithObject:@"Stig" forKey:@"_id"];
    doc = [couch saveDocument:doc];
    eq([doc count], (unsigned)2);
    eqo([doc objectForKey:@"_id"], @"Stig");
    STAssertTrue([[doc objectForKey:@"_rev"] isKindOfClass:[NSNumber class]], nil);
}

- (void)testCreateFilled
{
    NSDictionary *doc = [NSDictionary dictionaryWithObject:@"Stig" forKey:@"Awesome"];
    doc = [couch saveDocument:doc];
    eq([doc count], (unsigned)3);
    eqo([doc objectForKey:@"Awesome"], @"Stig");
    STAssertTrue([[doc objectForKey:@"_id"] isKindOfClass:[NSString class]], nil);
    STAssertTrue([[doc objectForKey:@"_rev"] isKindOfClass:[NSNumber class]], nil);
}

- (void)testListEmpty
{
    NSDictionary *docs = [couch listDocuments];
    eq([docs count], (unsigned)2);
    eqo([docs objectForKey:@"view"], @"_all_docs");
    eqo([docs objectForKey:@"rows"], [NSArray array]);
}

- (void)testRetrieve
{
    NSDictionary *doc = [NSDictionary dictionaryWithObject:@"Stig" forKey:@"_id"];
    STAssertNotNil(doc = [couch saveDocument:doc], nil);
    eqo([couch retrieveDocument:@"Stig"], doc);
}

- (void)testRetrieveUnnamed
{
    NSDictionary *doc = [couch saveDocument:[NSDictionary dictionary]];
    eqo([couch retrieveDocument:[doc objectForKey:@"_id"]], doc);
}


@end
