//
//  SBCouchDesignDocument.h
//  CouchObjC
//
//  Created by Robert Evans on 2/5/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SBCouchDocument.h"
#import "SBCouchView.h"
#import <JSON/JSON.h>

@interface SBCouchDesignDocument : SBCouchDocument {
    NSString *designDomain;
}

@property (retain) NSString *designDomain;

-(id)initWithDesignDomain:(NSString*)domain;
-(void)addView:(SBCouchView*)view withName:(NSString*)viewName;
-(NSString*)language;
-(NSDictionary*)views;
@end
