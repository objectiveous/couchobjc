//
//  SBCouchDesignDocument.m
//  CouchObjC
//
//  Created by Robert Evans on 2/5/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import "SBCouchDesignDocument.h"
#import "CouchObjC.h"
#import "SBOrderedDictionary.h"
@implementation SBCouchDesignDocument
@synthesize designDomain;

-(id)initWithDesignDomain:(NSString*)domain{
    self = [super init];
    if(self != nil){
        SBOrderedDictionary *views = [SBOrderedDictionary dictionaryWithCapacity:5];
        [self setObject:views forKey:@"views"];
        [self setObject:COUCH_KEY_LANGUAGE_DEFAULT forKey:COUCH_KEY_LANGUAGE];
        self.designDomain = [NSString stringWithFormat:@"%@%@", COUCH_KEY_DESIGN_PREFIX, domain];
    }
    return self;
}


-(SBCouchDocument*)initWithNSDictionary:(NSMutableDictionary*)aDictionary{
    self = [super init];
    if(self){
        [self addEntriesFromDictionary:aDictionary];
        self.designDomain = [self objectForKey:@"_id"];
        //self.designDomain = @"adsfadf";
        
    }
    return self;
}

-(void)addView:(SBCouchView*)view withName:(NSString*)viewName{
    if(viewName == Nil)
        return;
        
    NSMutableDictionary *views = [self objectForKey:COUCH_KEY_VIEWS];      
    [views setObject:view forKey:viewName];
}

-(NSDictionary*)views{
    return [self objectForKey:COUCH_KEY_VIEWS];
}

-(NSString*)identity{
    return self.designDomain;
}

-(NSString*)description{
    return [super description];
}
-(NSString*)language{
    return [self objectForKey:COUCH_KEY_LANGUAGE];
}
@end
