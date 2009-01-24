//
//  SBCouchDocument.m
//  CouchObjC
//
//  Created by Robert Evans on 1/24/09.
//  Copyright 2009 South And Valley. All rights reserved.
//


#import "AbstractDatabaseTest.h"

@interface SBCouchDocumentIntegrationTest: AbstractDatabaseTest{

}

@end

@implementation SBCouchDocumentIntegrationTest

-(void)testSimple{

    NSDictionary *doc = [NSDictionary dictionaryWithObject:@"Your soul sucks" forKey:@"testMessage"];
    SBCouchResponse *response = [couchDatabase postDocument:doc];
    STIGDebug(@"response [%@]", response);
    SBCouchDocument *couchDocument = [couchDatabase getDocument:response.name withRevisionCount:YES];
    
    STAssertNotNil(couchDocument,nil);
    STIGDebug(@"doc [%@]", couchDocument);
    STAssertEqualObjects([couchDocument objectForKey:@"testMessage"], @"Your soul sucks", nil);
    
}

@end

