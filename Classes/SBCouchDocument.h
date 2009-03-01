//
//  SBCouchDocument.h
//  CouchObjC
//
//  Created by Robert Evans on 1/24/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SBOrderedDictionary.h"

@class SBCouchDatabase;

@interface SBCouchDocument : SBOrderedDictionary{
    SBCouchDatabase       *couchDatabase;
}

@property (retain) SBCouchDatabase *couchDatabase;

- (SBCouchDocument*)initWithNSDictionary:(NSDictionary*)aDictionary couchDatabase:(SBCouchDatabase*)aCouchDatabaseOrNil;
- (NSInteger)numberOfRevisions;
- (NSString *)previousRevision;
- (NSInteger)revisionIndex;


- (NSString *)identity;
- (void)setIdentity:(NSString *)someId;
- (NSString *)revision;
- (void)setRevision:(NSString *)aRevision;
// removes _id, _rev and _revs from a document. 
- (void)detach;

@end
