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

- (void)testSaveEmpty
{
    NSDictionary *doc = [couch saveDocument:[NSDictionary dictionary]];
    eq([doc count], (unsigned)2);
    STAssertTrue([[doc objectForKey:@"_id"] isKindOfClass:[NSString class]], nil);
    STAssertTrue([[doc objectForKey:@"_rev"] isKindOfClass:[NSNumber class]], nil);
}

- (void)testSaveNamed
{
    NSDictionary *doc = [NSDictionary dictionaryWithObject:@"Stig" forKey:@"_id"];
    doc = [couch saveDocument:doc];
    eq([doc count], (unsigned)2);
    eqo([doc objectForKey:@"_id"], @"Stig");
    STAssertTrue([[doc objectForKey:@"_rev"] isKindOfClass:[NSNumber class]], nil);
}

- (void)testSaveFilled
{
    NSDictionary *doc = [NSDictionary dictionaryWithObject:@"Stig" forKey:@"Awesome"];
    doc = [couch saveDocument:doc];
    eq([doc count], (unsigned)3);
    eqo([doc objectForKey:@"Awesome"], @"Stig");
    STAssertTrue([[doc objectForKey:@"_id"] isKindOfClass:[NSString class]], nil);
    STAssertTrue([[doc objectForKey:@"_rev"] isKindOfClass:[NSNumber class]], nil);
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

- (void)testListEmpty
{
    NSDictionary *docs = [couch listDocuments];
    eq([docs count], (unsigned)2);
    eqo([docs objectForKey:@"view"], @"_all_docs");
    eqo([docs objectForKey:@"rows"], [NSArray array]);
}

- (void)testListMany
{
    for (unsigned i = 1; i < 10; i++) {
        [couch saveDocument:[NSDictionary dictionary]];

        NSDictionary *docs = [couch listDocuments];
        eq([docs count], (unsigned)2);
        eqo([docs objectForKey:@"view"], @"_all_docs");
        
        NSArray *arr = [docs objectForKey:@"rows"];
        eq([arr count], i);
    }
}

- (void)testUpdateUnchanged
{
    NSDictionary *doc1 = [couch saveDocument:[NSDictionary dictionary]];
    NSDictionary *doc2 = [couch saveDocument:doc1];
    eq([doc1 count], (unsigned)2);
    eq([doc2 count], (unsigned)2);
    eqo([doc2 objectForKey:@"_id"], [doc1 objectForKey:@"_id"]);
    neqo([doc2 objectForKey:@"_rev"], [doc1 objectForKey:@"_rev"]);
}

- (void)testUpdateChanged
{
    NSDictionary *doc1 = [couch saveDocument:[NSDictionary dictionary]];
    id doc2 = [NSMutableDictionary dictionaryWithDictionary:doc1];
    [doc2 setObject:@"bar" forKey:@"foo"];
    doc2 = [couch saveDocument:doc2];

    STAssertFalse([[doc2 objectForKey:@"_rev"] isEqual:[doc1 objectForKey:@"_rev"]], nil);
    eqo([doc2 objectForKey:@"_id"], [doc1 objectForKey:@"_id"]);
    eqo([doc2 objectForKey:@"foo"], @"bar");
}

- (void)TODOtestRename
{
    NSDictionary *doc1 = [couch saveDocument:[NSDictionary dictionary]];
    id doc2 = [NSMutableDictionary dictionaryWithDictionary:doc1];
    [doc2 setObject:@"bar" forKey:@"_id"];
    STAssertNoThrow([couch saveDocument:doc2], nil);

    NSDictionary *docs = [couch listDocuments];
    docs = [docs objectForKey:@"rows"];
    eq([docs count], (unsigned)1);
    STAssertNoThrow([couch retrieveDocument:@"bar"], nil);
    tn([couch retrieveDocument:[doc1 objectForKey:@"_id"]], @"enoducument");
}

@end
