//
//  SBCouchDocument.h
//  CouchObjC
//
//  Created by Robert Evans on 1/24/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OrderedDictionary.h"

@interface SBCouchDocument : NSObject{
    OrderedDictionary   *dictionaryDoc;
    NSString            *serverName;
    NSString            *databaseName;
}

@property (retain) OrderedDictionary   *dictionaryDoc;
@property (retain) NSString            *serverName;
@property (retain) NSString            *databaseName;


-(SBCouchDocument*)initWithNSDictionary:(NSMutableDictionary*)aDictionary;
-(id)objectForKey:(id)aKey;
-(void)setObject:(id)anObject forKey:(id)aKey;
-(NSInteger)numberOfRevisions;
-(NSString*)JSONRepresentation;
-(id)keyAtIndex:(NSUInteger)anIndex;
@end
