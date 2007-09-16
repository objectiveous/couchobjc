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
    id view = [NSDictionary dictionaryWithObject:@"function (o) { if (o.Type == 'Cat') return o; }"
                                          forKey:@"cats"];
    id views = [NSDictionary dictionaryWithObjectsAndKeys:
        view, @"views",
        @"_design_views", @"_id",
        nil];
    [couch saveDocument:views];
}

- (void)testListEmpty
{
    NSDictionary *docs = [couch listDocumentsInView:@"_design_views:cats"];
    eq([docs count], (unsigned)3);
    eqo([docs objectForKey:@"view"], @"_design_views:cats");
    eqo([docs objectForKey:@"total_rows"], [NSNumber numberWithInt:0]);
    eqo([docs objectForKey:@"rows"], [NSArray array]);
}

- (void)testListMany
{
    for (unsigned i = 0; i < 5; i++) {
        [couch saveDocument:[NSDictionary dictionaryWithObject:@"Cat" forKey:@"Type"]];
        [couch saveDocument:[NSDictionary dictionaryWithObject:@"Dog" forKey:@"Type"]];
    }

    NSDictionary *docs = [couch listDocumentsInView:@"_design_views:cats"];
    eq([docs count], (unsigned)4);
    eqo([docs objectForKey:@"view"], @"_design_views:cats");
    eqo([docs objectForKey:@"offset"], [NSNumber numberWithInt:0]);
    eqo([docs objectForKey:@"total_rows"], [NSNumber numberWithInt:5]);
    NSArray *arr = [docs objectForKey:@"rows"];
    eq([arr count], (unsigned)5);
}

@end
