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

@interface SBCouchView : SBOrderedDictionary{
    NSString *name;
    NSString *couchDatabase;
}

@property (retain) NSString *name;
@property (retain) NSString *couchDatabase;

-(id)initWithName:(NSString*)viewName andMap:(NSString*)map andReduce:(NSString*)reduceOrNil;
-(id)initWithName:(NSString*)viewName andDictionary:(NSDictionary*)funtionDictionary;
-(NSString*)map;
-(void)setMap:(NSString*)map;
-(NSString*)reduce;
-(void)setReduce:(NSString*)reduce;

@end
