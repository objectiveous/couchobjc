//
//  View.m
//  CouchObjC
//
//  Created by Stig Brautaset on 16/09/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import "Tests.h"


@implementation View

- (void)setUp
{
    [super setUp];
    id views = [NSDictionary dictionaryWithObjectsAndKeys:
        @"function (o) { if (o.Type == 'Cat') return o; }", @"_view_cats",
        @"views", @"_id",
        nil];
    [couch saveDocument:views];
    
    NSLog(@"%@", [couch retrieveDocument:@"views"]);
}

- (void)XXXtestListEmpty
{
    NSDictionary *docs = [couch listDocumentsInView:@"views:cats"];
    eq([docs count], (unsigned)2);
    eqo([docs objectForKey:@"view"], @"views:cats");
    eqo([docs objectForKey:@"rows"], [NSArray array]);
}

- (void)KKKtestListMany
{
    for (unsigned i = 0; i < 5; i++) {
        [couch saveDocument:[NSDictionary dictionaryWithObject:@"Cat" forKey:@"Type"]];
        [couch saveDocument:[NSDictionary dictionaryWithObject:@"Dog" forKey:@"Type"]];
    }
    
    NSLog(@"Retrieved: %@", [couch retrieveDocument:@"views"]);
    NSLog(@"Documents: %@", [couch listDocuments]);

    NSDictionary *docs = [couch listDocumentsInView:@"views:cats"];
    eq([docs count], (unsigned)2);
    eqo([docs objectForKey:@"view"], @"view:cats");
    
    NSArray *arr = [docs objectForKey:@"rows"];
    eq([arr count], 5);
}

@end
