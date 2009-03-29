//
//  SBCouchDocument.m
//  CouchObjC
//
//  Created by Robert Evans on 1/24/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import "AbstractDatabaseTest.h"
#import "SBCouchDesignDocument.h"
#import "SBCouchView.h"


static NSString *KEY              = @"artist";
static NSString *VALUE            = @"Frank Zappa"; 
static NSString *VALUE_2          = @"Miles Davis"; 


@interface SBCouchDocumentIntegrationTest: AbstractDatabaseTest{
}
-(void)assertTheDocIsComplete:(SBCouchDocument*)couchDocument;
@end

@implementation SBCouchDocumentIntegrationTest



-(void)testPostAndPutOfSBCouchDocument{

    NSDictionary *doc = [NSDictionary dictionaryWithObject:VALUE forKey:KEY];

    SBCouchResponse *response = [couchDatabase postDocument:doc];        
    SBCouchDocument *couchDocument = [couchDatabase getDocument:response.name withRevisionCount:YES andInfo:YES revision:nil];
    NSString *firstRevision = [couchDocument revision];
    NSArray *revisions = [couchDocument revisions];
    STAssertNotNil(revisions, nil);
    STAssertTrue([revisions count] == 1, nil);
    [couchDocument numberOfRevisions];
    STAssertTrue([couchDocument numberOfRevisions] == 1, nil);
    
    STAssertNotNil(firstRevision, nil);
    
    [self assertTheDocIsComplete:couchDocument];
    
    // PUT
    [couchDocument setObject:VALUE_2 forKey:KEY];
    response = [couchDatabase putDocument:couchDocument];
    
    couchDocument = [couchDatabase getDocument:response.name withRevisionCount:YES andInfo:YES revision:nil];
    STAssertTrue([couchDocument numberOfRevisions] == 2, @"Revision count : %i", [couchDocument numberOfRevisions]);
    
    STAssertTrue([VALUE_2 isEqualToString:[couchDocument objectForKey:KEY]], @"Did not update properly [%@]", [couchDocument objectForKey:KEY]);
    
    NSLog(@" previousRevision ----> [ %@ ] " , [couchDocument previousRevision]);
    
    STAssertTrue([[couchDocument previousRevision] isEqualToString:firstRevision], @"[%@] [%@]", firstRevision, [couchDocument previousRevision]);
}

-(void)assertTheDocIsComplete:(SBCouchDocument*)couchDocument{
    STAssertNotNil(couchDocument,nil);
    STIGDebug(@"couchDocument description [%@]", couchDocument);
    STAssertEqualObjects([couchDocument objectForKey:KEY], VALUE, nil);
    STAssertNotNil([couchDocument objectForKey:@"_id"], @"couchDocument is missing its _id");
    STAssertNotNil([couchDocument objectForKey:@"_rev"], @"couchDocument is missing its _rev");
    STAssertNotNil([couchDocument.couchDatabase.couchServer host], @"couchDocument is missing its serverName");
    
}

@end

