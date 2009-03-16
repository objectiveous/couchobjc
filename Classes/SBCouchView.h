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
    
    @private
    BOOL                 runAsSlowView;
}

@property (retain) NSString            *name;
@property (retain) SBCouchDatabase     *couchDatabase;
@property (retain) NSString            *identity;
@property (retain) SBCouchQueryOptions *queryOptions;
@property          BOOL                 runAsSlowView; 

- (id)initWithName:(NSString*)viewName couchDatabase:(SBCouchDatabase*)database;
- (id)initWithName:(NSString*)viewName couchDatabase:(SBCouchDatabase*)database queryOptions:(SBCouchQueryOptions*)options;
- (id)initWithName:(NSString*)viewName couchDatabase:(SBCouchDatabase*)database dictionary:(NSDictionary*)viewDictionary ;

- (NSString*)map;
- (NSString*)reduce;

- (void)setMap:(NSString*)map;
- (void)setReduce:(NSString*)reduce;

- (NSString*)urlString;
- (NSEnumerator*)viewEnumerator;
- (NSEnumerator*)slowViewEnumerator;

@end
