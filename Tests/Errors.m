//
//  Errors.m
//  CouchObjC
//
//  Created by Stig Brautaset on 15/09/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import "Tests.h"

@implementation Errors

- (void)testInitNoEndpoint
{
    tn( [SBCouch newWithHost:nil port:8888], @"enoendpoint" );
    tn( [SBCouch newWithHost:@"localhost" port:0], @"enoendpoint" );
}

- (void)testCreateExistingDatabase
{
    tn( [couch createDatabase:@"foo"], @"edbexists");
}

- (void)testDeleteMissingDatabase
{
    tn( [couch deleteDatabase:@"bar"], @"enodatabase");
}

- (void)testSelectMissingDatabase
{
    tn( [couch selectDatabase:@"bar"], @"enodatabase");
}

- (void)testDocumentOutdated
{
    NSDictionary *d = [couch saveDocument:[NSDictionary dictionary]];
    [couch saveDocument:d];
    tn( [couch saveDocument:d], @"conflict" );
}

- (void)testViewNotFound
{
    tn( [couch listDocumentsInView:@"_design_views:cats"], @"notfound" );
}


@end
