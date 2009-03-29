//
//  SBCouchView.m
//  CouchObjC
//
//  Created by Robert Evans on 2/5/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import "SBCouchView.h"
#import "CouchObjC.h"
#import <JSON/JSON.h>

@implementation SBCouchView

@synthesize name;
@synthesize couchDatabase;
@synthesize identity;
@synthesize queryOptions;
@synthesize runAsSlowView;


- (id)initWithName:(NSString*)viewName couchDatabase:(SBCouchDatabase*)database dictionary:(NSDictionary*)viewDictionary{
    self = [super initWithDictionary:viewDictionary];
    if(self){
        self.name = viewName;
        self.couchDatabase = database;
    }
    return self;    
}
- (id)initWithName:(NSString*)viewName couchDatabase:(SBCouchDatabase*)database{
    self = [super init];
    if(self){        
        self.name = viewName;
        self.couchDatabase = database;
        self.identity = viewName;
    }
    return self;    
}

- (id)initWithName:(NSString*)viewName couchDatabase:(SBCouchDatabase*)database queryOptions:(SBCouchQueryOptions*)options {
    self = [self initWithName:viewName couchDatabase:database];
    if(self){        
        self.queryOptions = options;
    }
    return self;    
}

- (void)dealloc{
    self.name = nil;
    self.couchDatabase = nil;
    self.identity = nil;
    self.queryOptions = nil;
    [super dealloc];
}

-(id)copy{
    SBCouchView *view = [[[SBCouchView alloc] initWithName:self.name 
                                             couchDatabase:self.couchDatabase 
                                                dictionary:self] autorelease];
    if(self.queryOptions)
        view.queryOptions = [self.queryOptions copy];
    return view;
}

#pragma mark -


-(NSString*)map{
    return [self objectForKey:@"map"];
}

-(void)setMap:(NSString*)map{
    [self setObject:[map copy] forKey:COUCH_KEY_MAP];
}

-(NSString*)reduce{
    return [self objectForKey:@"reduce"];    
}
-(void)setReduce:(NSString*)reduce{
    // Give us an empty string and we'll remove the reduce key. If we don't do this 
    // and we PUT the view back, GETs will fail and life will suck. 
    if(reduce == nil || [reduce length] == 0){
        [self removeObjectForKey:COUCH_KEY_REDUCE];
        return;
    }            
    [self setObject:[reduce copy] forKey:COUCH_KEY_REDUCE];
}

-(NSString*)description{
    return [self JSONRepresentation];
}

- (NSEnumerator*) slowViewEnumerator{
    self.runAsSlowView = YES;
    return [[[SBCouchEnumerator alloc] initWithView:self] autorelease];
}

- (NSEnumerator*) viewEnumerator{
    return [[[SBCouchEnumerator alloc] initWithView:self] autorelease];
}

- (NSString*)urlString{
    NSString *queryString = [self.queryOptions queryString];
    if(queryString)
        return [NSString stringWithFormat:@"%@?%@", self.identity, queryString];
    else
        return [NSString stringWithFormat:@"%@", self.identity];

}
@end
