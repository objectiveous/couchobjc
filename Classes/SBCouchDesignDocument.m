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

@interface SBCouchDesignDocument (Private)
-(void) createAndAddView:(NSDictionary*)viewDictionary withName:(NSString*)viewName;
@end

@implementation SBCouchDesignDocument
@synthesize designDomain;

-(id)initWithDesignDomain:(NSString*)domain couchDatabase:(SBCouchDatabase*)aCouchDatabaseOrNil{
    self = [super init];
    if(self != nil){
        self.couchDatabase = aCouchDatabaseOrNil;
        SBOrderedDictionary *views = [SBOrderedDictionary dictionaryWithCapacity:5];
        [self setObject:views forKey:@"views"];
        [self setObject:COUCH_KEY_LANGUAGE_DEFAULT forKey:COUCH_KEY_LANGUAGE];
        self.designDomain = [NSString stringWithFormat:@"%@%@", COUCH_KEY_DESIGN_PREFIX, domain];
        self.identity = [NSString stringWithFormat:@"%@%@", COUCH_KEY_DESIGN_PREFIX, domain];
    }
    return self;
}


-(SBCouchDocument*)initWithNSDictionary:(NSDictionary*)aDictionary couchDatabase:(SBCouchDatabase*)aCouchDatabaseOrNil{
    self = [super init];
    if(self){
        self.couchDatabase = aCouchDatabaseOrNil;
        NSMutableDictionary *views = [NSMutableDictionary dictionaryWithCapacity:2];
        [self setObject:views forKey:COUCH_KEY_VIEWS];
        [self setObject:[aDictionary objectForKey:COUCH_KEY_LANGUAGE] forKey:COUCH_KEY_LANGUAGE];
        [self setObject:[aDictionary objectForKey:@"_rev"] forKey:@"_rev"];
        [self setObject:[aDictionary objectForKey:@"_id"] forKey:@"_id"];
        NSDictionary *viewsDictionary = [aDictionary objectForKey:@"views"];         
        self.designDomain = [self objectForKey:@"_id"];
        
        for(NSString *viewName in viewsDictionary){
            [self createAndAddView:[viewsDictionary objectForKey:viewName] withName:viewName];
        }        
      
    }
    return self;
}

-(void) createAndAddView:(NSDictionary*)viewDictionary withName:(NSString*)viewName{
    SBCouchView *view = [[SBCouchView alloc] initWithName:viewName  andDictionary:viewDictionary];
    view.couchDatabase = self.couchDatabase;
    NSString *viewIdentity = [NSString stringWithFormat:@"_view/%@/%@", [[self identity] lastPathComponent], view.name];
    view.identity = viewIdentity;
    [self addView:view withName:view.name];
}

-(void)addView:(SBCouchView*)view withName:(NSString*)viewName{
    if(viewName == Nil)
        return;
    view.couchDatabase = self.couchDatabase;
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
-(SBCouchView*)view:(NSString*)viewName{
    return [[self views] objectForKey:viewName]; 
}


@end
