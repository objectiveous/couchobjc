//
//  Document.m
//  CouchObjC
//
//  Created by Stig Brautaset on 06/09/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import "Tests.h"

@implementation Document

- (void)propertyHandlingInDocument:(SBCouchDocument *)doc
{
    STAssertNil([doc objectForProperty:@"Type"], @"No Type property set");
    [doc setObject:@"Person" forProperty:@"Type"];
    
    STAssertEqualObjects([doc objectForProperty:@"Type"], @"Person", @"Person type set");
    
    [doc removeProperty:@"Type"];
    STAssertNil([doc objectForProperty:@"Type"], @"No Type property set");
}

- (void)test01create
{
    SBCouchDocument *doc = [SBCouchDocument document];
    STAssertNotNil(doc, @"Can create document");

    STAssertNil([doc documentId], @"No name");
    STAssertNil([doc revisionId], @"No revision");
    STAssertEqualObjects([doc description], @"{}", nil);

    [self propertyHandlingInDocument:doc];
}

- (void)test01createNamed
{
    NSString *name = @"mydoc";
    SBCouchDocument *doc = [SBCouchDocument documentWithName:name];
    STAssertNotNil(doc, @"Can create named document");

    STAssertEqualObjects([doc documentId], name, @"Expected name");
    STAssertNil([doc revisionId], @"No revision");
    STAssertEqualObjects([doc description], @"{\"_id\" = mydoc; }", nil);

    [self propertyHandlingInDocument:doc];
}


@end
