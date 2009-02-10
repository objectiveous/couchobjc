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

static NSString *DESIGN_NAME      = @"someDesignDoc";
static NSString *KEY              = @"artist";
static NSString *VALUE            = @"Frank Zappa"; 
static NSString *VALUE_2          = @"Miles Davis"; 
static NSString *MAP_FUNCTION     = @"function(doc) { if(doc.name == 'Frank'){ emit('Number of Franks', 1);}}";
static NSString *REDUCE_FUNCTION  = @"function(k, v, rereduce) { return sum(v);}";


@interface SBCouchDocumentIntegrationTest: AbstractDatabaseTest{
 
}
   -(void)assertTheDocIsComplete:(SBCouchDocument*)couchDocument;
@end

@implementation SBCouchDocumentIntegrationTest



- (void)testCreateView{
    // TODO DesignDomain needs to go away makes no real sense. 
    SBCouchDesignDocument *designDocument = [[SBCouchDesignDocument alloc] initWithDesignDomain:DESIGN_NAME];
    SBCouchView *view = [[SBCouchView alloc] initWithName:@"Franks" andMap:MAP_FUNCTION andReduce:REDUCE_FUNCTION]; 
    
    STAssertNotNil(designDocument, nil);
    STAssertNotNil(view, nil);
    STAssertTrue([view.map isEqualToString:MAP_FUNCTION], nil);
    
    [designDocument addView:view withName:@"franks"];
    [designDocument addView:view withName:@"summary"];
    
    SBCouchResponse *response = [couchDatabase createDocument:designDocument];
    if(! response.ok)
        STFail(@"Failed Response", nil);
    STAssertNotNil(response.name, @"response path is missing", response.name);
    
    SBCouchDesignDocument *newlyFetchedDesignDoc = [couchDatabase getDesignDocument:response.name];
    STAssertNotNil(newlyFetchedDesignDoc,nil);
    STAssertNotNil(newlyFetchedDesignDoc.identity,@"identity %@",newlyFetchedDesignDoc.identity );

        
    STAssertTrue([newlyFetchedDesignDoc.identity isEqualToString:designDocument.identity], @"design docs are not the same. %@, %@" , newlyFetchedDesignDoc.identity, designDocument.identity );

    NSEnumerator *designDocs = [couchDatabase getDesignDocuments];
    STAssertNotNil(designDocs, nil);
    
    id dict; 
    BOOL pass = NO;
    while(( dict = [designDocs nextObject] )){
        pass = YES;
    }
    
    STAssertTrue(pass, @"never got a design doc. ");
    [designDocument release];
    [view release];
}

-(void)testPostAndPutOfSBCouchDocument{

    NSDictionary *doc = [NSDictionary dictionaryWithObject:VALUE forKey:KEY];
    // POST
    SBCouchResponse *response = [couchDatabase postDocument:doc];
    STIGDebug(@"post response [%@]", response);
    STIGDebug(@"Calling PUT for [%@], with name [%@]", doc, response.name);
           
    SBCouchDocument *couchDocument = [couchDatabase getDocument:response.name withRevisionCount:YES andInfo:YES revision:nil];
    NSString *firstRevision = [couchDocument objectForKey:@"_rev"];
    STAssertNotNil(firstRevision, nil);
    
    [self assertTheDocIsComplete:couchDocument];
    
    // PUT
    [couchDocument setObject:VALUE_2 forKey:KEY];
    response = [couchDatabase putDocument:couchDocument];
    
    couchDocument = [couchDatabase getDocument:response.name withRevisionCount:YES andInfo:YES revision:nil];
    STAssertTrue([couchDocument numberOfRevisions] == 2, @"Revision count : %i", [couchDocument numberOfRevisions]);
    
    STAssertTrue([VALUE_2 isEqualToString:[couchDocument objectForKey:KEY]], @"Did not update properly [%@]", [couchDocument objectForKey:KEY]);
    
    STIGDebug(@"***** %@", [couchDocument objectForKey:KEY]);
    STIGDebug(@"***** %@", couchDocument);
    
    STAssertTrue([[couchDocument previousRevision] isEqualToString:firstRevision], @"revision [%@]", [couchDocument previousRevision]);
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

