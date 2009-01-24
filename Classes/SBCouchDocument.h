//
//  SBCouchDocument.h
//  CouchObjC
//
//  Created by Robert Evans on 1/24/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SBCouchDocument : NSObject{
    NSMutableDictionary *dictionaryDoc;
    NSString            *serverName;
    NSString            *databaseName;
}

@property (retain) NSMutableDictionary *dictionaryDoc;
@property (retain) NSString            *serverName;
@property (retain) NSString            *databaseName;


-(SBCouchDocument*)initWithNSDictionary:(NSMutableDictionary*)aDictionary;
-(id)objectForKey:(id)aKey;
-(void)setObject:(id)anObject forKey:(id)aKey;
-(NSInteger)numberOfRevisions;
-(NSString*)JSONRepresentation;
@end
