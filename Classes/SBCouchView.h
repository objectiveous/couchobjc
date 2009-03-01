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

@class SBCouchDatabase;

@interface SBCouchView : SBOrderedDictionary{
    NSString        *name;
    SBCouchDatabase *couchDatabase;
    NSString        *identity;
}

@property (retain) NSString        *name;
@property (retain) SBCouchDatabase *couchDatabase;
@property (retain) NSString        *identity;

-(id)initWithName:(NSString*)viewName andMap:(NSString*)map andReduce:(NSString*)reduceOrNil;
-(id)initWithName:(NSString*)viewName andDictionary:(NSDictionary*)funtionDictionary;
-(NSString*)map;
-(void)setMap:(NSString*)map;
-(NSString*)reduce;
-(void)setReduce:(NSString*)reduce;


- (NSEnumerator*) getEnumerator;

@end
