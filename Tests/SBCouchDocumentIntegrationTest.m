//
//  SBCouchDocument.m
//  CouchObjC
//
//  Created by Robert Evans on 1/24/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import "AbstractDatabaseTest.h"

static NSString *KEY     = @"artist";
static NSString *VALUE   = @"Frank Zappa"; 
static NSString *VALUE_2 = @"Miles Davis"; 

@interface SBCouchDocumentIntegrationTest: AbstractDatabaseTest{
 
}
   -(void)assertTheDocIsComplete:(SBCouchDocument*)couchDocument;
@end

@implementation SBCouchDocumentIntegrationTest

-(void)testPostAndPutOfSBCouchDocument{

    NSDictionary *doc = [NSDictionary dictionaryWithObject:VALUE forKey:KEY];
    // POST
    SBCouchResponse *response = [couchDatabase postDocument:doc];
    STIGDebug(@"post response [%@]", response);
    STIGDebug(@"Calling PUT for [%@], with name [%@]", doc, response.name);
           
    SBCouchDocument *couchDocument = [couchDatabase getDocument:response.name withRevisionCount:YES];
    [self assertTheDocIsComplete:couchDocument];
    
    // PUT
    [couchDocument setObject:VALUE_2 forKey:KEY];
    response = [couchDatabase putDocument:couchDocument];
    
    couchDocument = [couchDatabase getDocument:response.name withRevisionCount:YES];
    STAssertTrue([couchDocument numberOfRevisions] == 2, @"Revision count : %i", [couchDocument numberOfRevisions]);
    
    STAssertTrue([VALUE_2 isEqualToString:[couchDocument objectForKey:KEY]], @"Did not update properly [%@]", [couchDocument objectForKey:KEY]);
    
    STIGDebug(@"***** %@", [couchDocument objectForKey:KEY]);
    STIGDebug(@"***** %@", couchDocument);
     
}

-(void)assertTheDocIsComplete:(SBCouchDocument*)couchDocument{
    STAssertNotNil(couchDocument,nil);
    STIGDebug(@"couchDocument description [%@]", couchDocument);
    STAssertEqualObjects([couchDocument objectForKey:KEY], VALUE, nil);
    STAssertNotNil([couchDocument objectForKey:@"_id"], @"couchDocument is missing its _id");
    STAssertNotNil([couchDocument objectForKey:@"_rev"], @"couchDocument is missing its _rev");
    STAssertNotNil([couchDocument serverName], @"couchDocument is missing its serverName");
    
}

@end

