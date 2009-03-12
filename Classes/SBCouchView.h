//
//  SBCouchView.h
//  CouchObjC
//
//  Created by Robert Evans on 2/5/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <JSON/JSON.h>
#import "SBOrderedDictionary.h"
#import "SBCouchQueryOptions.h"

@class SBCouchDatabase;

@interface SBCouchView : SBOrderedDictionary{
    NSString            *name;
    SBCouchDatabase     *couchDatabase;
    NSString            *identity;
    SBCouchQueryOptions *queryOptions;
}

@property (retain) NSString            *name;
@property (retain) SBCouchDatabase     *couchDatabase;
@property (retain) NSString            *identity;
@property (retain) SBCouchQueryOptions *queryOptions;


- (id)initWithName:(NSString*)viewName queryOptions:(SBCouchQueryOptions*)options couchDatabase:(SBCouchDatabase*)database;
- (id)initWithName:(NSString*)viewName dictionary:(NSDictionary*)viewDictionary couchDatabase:(SBCouchDatabase*)database;
// XXX Should this sort of thing be moved in SBCouchDesignDocument? Do we need a SBCouchViewDocument?
- (id)initWithName:(NSString*)viewName andMap:(NSString*)map andReduce:(NSString*)reduceOrNil;

- (NSString*)map;
- (void)setMap:(NSString*)map;
- (NSString*)reduce;
- (void)setReduce:(NSString*)reduce;

- (NSString*)urlString;
- (NSEnumerator*) getEnumerator;

@end
