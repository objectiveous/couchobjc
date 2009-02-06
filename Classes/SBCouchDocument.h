//
//  SBCouchDocument.h
//  CouchObjC
//
//  Created by Robert Evans on 1/24/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SBOrderedDictionary.h"

@interface SBCouchDocument : SBOrderedDictionary{
    NSString              *serverName;
    NSString              *databaseName;
}

@property (retain) NSString              *serverName;
@property (retain) NSString              *databaseName;

- (id)init;
- (SBCouchDocument *)initWithNSDictionary:(NSDictionary*)aDictionary;
//- (id)objectForKey:(id)aKey;
//- (void)setObject:(id)anObject forKey:(id)aKey;
- (NSInteger)numberOfRevisions;
//- (id)keyAtIndex:(NSUInteger)anIndex;
- (NSString *)previousRevision;
- (NSInteger)revisionIndex;


- (NSString *)identity;
- (NSString *)revision;
- (void)setIdentity:(NSString *)someId;
- (void)setRevision:(NSString *)aRevision;

@end
