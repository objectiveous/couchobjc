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
    [dictionary release];
}

#pragma mark -
-(void)testDocumentKnowsWhereItCameFrom{
    SBCouchDocument *couchDocument = [[SBCouchDocument alloc] initWithNSDictionary:dictionary];
    STAssertNotNil(couchDocument, nil);

    [couchDocument setServerName:@"localhost"];
    [couchDocument setDatabaseName:@"test"];
    
    STAssertNotNil([couchDocument serverName], nil);
    STAssertNotNil([couchDocument databaseName], nil);
    
}

-(void)testDocumentCreation{
    SBCouchDocument *couchDocument = [[SBCouchDocument alloc] initWithNSDictionary:dictionary];
    STAssertNotNil(couchDocument, nil);
    STAssertTrue([DOC_ID isEqualToString:[couchDocument objectForKey:DOC_KEY_ID]], @"returned [%@]", 
                    [couchDocument objectForKey:DOC_KEY_ID]);
}

@end
