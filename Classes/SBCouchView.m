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

- (id)initWithName:(NSString*)viewName andQueryOptions:(SBCouchQueryOptions*)options{
    self = [super init];
    if(self){        
        self.queryOptions = options;
        self.name = viewName;
    }
    return self;    
}

- (id)initWithQueryOptions:(SBCouchQueryOptions*)someQueryOptions{
    self = [super init];
    if(self){        
        self.queryOptions = someQueryOptions;
    }
    return self;
}

-(id)initWithName:(NSString*)viewName andMap:(NSString*)map andReduce:(NSString*)reduceOrNil{    
    self = [super init];
    if(self){
        [self setObject:map forKey:@"map"];
        if(reduceOrNil != Nil)
            [self setObject:reduceOrNil forKey:@"reduce"];
        // The view name is not included in the dictionary as it's a propety of the 
        // design dictionary. 
        self.name = viewName;
    }
    return self;
}

-(id)initWithName:(NSString*)viewName andDictionary:(NSDictionary*)funtionDictionary{
    self = [super initWithDictionary:funtionDictionary];
    if(self){
        self.name = viewName;
    }
    return self;
}


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

    [self setObject:[reduce copy] forKey:COUCH_KEY_REDUCE];
}

-(NSString*)description{
    return [self JSONRepresentation];
}

- (NSEnumerator*) getEnumerator{
    return [[[SBCouchEnumerator alloc] initWithView:self] autorelease];
}

- (NSString*)urlString{
    NSString *queryString = [self.queryOptions queryString];
    if(queryString)
        return [NSString stringWithFormat:@"%@?%@", self.name, queryString];
    else
        return [NSString stringWithFormat:@"%@", self.name];

}
@end
