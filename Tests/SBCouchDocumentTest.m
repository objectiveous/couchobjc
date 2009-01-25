//
//  SBCouchDocument.m
//  CouchObjC
//
//  Created by Robert Evans on 1/24/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <CouchObjC/CouchObjC.h>

static NSString *DOC_KEY_ID  = @"_id";
static NSString *DOC_KEY_REV = @"_rev";

static NSString *DOC_ID      = @"777";
static NSString *DOC_REV     = @"1";

@interface SBCouchDocumentTest: SenTestCase{
    NSMutableDictionary *dictionary;
}

@end

@implementation SBCouchDocumentTest

-(void)setUp{
    dictionary = [NSMutableDictionary dictionaryWithObject:@"777" forKey:@"foo"];    
    [dictionary setObject:[NSArray arrayWithObjects:@"obj 1", @"obj 2" , nil] forKey:@"array"];
    [dictionary setObject:DOC_REV forKey:DOC_KEY_REV];
    [dictionary setObject:DOC_ID forKey:DOC_KEY_ID];
}

-(void)tearDown{

}

#pragma mark -

-(void)testOrderedDictionarySupport{
    SBCouchDocument *couchDocument = [[SBCouchDocument alloc] initWithNSDictionary:dictionary];
    id aKey = [couchDocument keyAtIndex:0];
    
    STAssertNotNil(aKey,nil);
    
    STAssertNotNil( [couchDocument objectForKey:aKey], nil);
    [couchDocument release];
}

-(void)testDocumentKnowsWhereItCameFrom{
    SBCouchDocument *couchDocument = [[SBCouchDocument alloc] initWithNSDictionary:dictionary];
    STAssertNotNil(couchDocument, nil);

    [couchDocument setServerName:@"localhost"];
    [couchDocument setDatabaseName:@"test"];
    
    STAssertNotNil([couchDocument serverName], nil);
    STAssertNotNil([couchDocument databaseName], nil);
    [couchDocument release];
}

-(void)testJSONCapabilities{
    SBCouchDocument *couchDocument = [[SBCouchDocument alloc] initWithNSDictionary:dictionary];
    NSString *json = [couchDocument JSONRepresentation];
    STAssertNotNil(json, @"CouchDocument not responding to request");
    // XXX This is terribly hard to read; all those damn escapes. Can we do better?
    STAssertTrue([json isEqualToString:@"{\"_id\":\"777\",\"_rev\":\"1\",\"array\":[\"obj 1\",\"obj 2\"],\"foo\":\"777\"}"], nil);
    [couchDocument release];
}

-(void)testDocumentCreation{
    SBCouchDocument *couchDocument = [[SBCouchDocument alloc] initWithNSDictionary:dictionary];
    STAssertNotNil(couchDocument, nil);
    STAssertTrue([DOC_ID isEqualToString:[couchDocument objectForKey:DOC_KEY_ID]], @"returned [%@]", 
                    [couchDocument objectForKey:DOC_KEY_ID]);
    [couchDocument release];
}

@end

