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
}

@property (retain) NSString *name;

-(id)initWithName:(NSString*)viewName andMap:(NSString*)map andReduce:(NSString*)reduceOrNil;
-(NSString*)map;
-(NSString*)reduce;


@end
