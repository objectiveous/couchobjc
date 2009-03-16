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


+ (SBCouchDesignDocument*)designDocumentFromDocument:(SBCouchDocument*)aCouchDocument{
    // XXX Not sure if this is proper way to create factory style methods. Could this introduce 
    //     memory leaks under some conditions? Does the caller need to be sure to 
    SBCouchDesignDocument *designDoc = [[[SBCouchDesignDocument alloc] initWithDictionary:aCouchDocument 
                                                                            couchDatabase:aCouchDocument.couchDatabase] autorelease];
    return designDoc;
}
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


-(id)initWithDictionary:(NSDictionary*)aDictionary couchDatabase:(SBCouchDatabase*)aCouchDatabaseOrNil{
    self = [super init];
    if(self){
        self.couchDatabase = aCouchDatabaseOrNil;
   

        // Copy all the keys from the NSDictionary *except* for doc. If doc is shows up
        // include_docs=true was used in the GET and we need to create proper SBCouchView 
        // documents. 
        for(id key in aDictionary){            
            if([@"doc" isEqualToString:key])
                continue;
            
            NSDictionary *valueObject = [aDictionary objectForKey:@"value"];
            if(valueObject){
                id rev = [valueObject objectForKey:@"rev"];
                [self setObject:rev forKey:@"_rev"];
            }
            
            // calls to _all_docs will place the revision number in "value": {"rev":"74EC24"}
            /*
            if(@"value" isEqualToString:key){
                NSDictionary *value = [aDictionary objectForKey:key];
                NSSTring *rev = [value objectForKey:@"rev"];
                if(rev)
                    [self setObject:rev forKey:@"_rev"];
                //continue;
            }
            */
            NSLog(@" %@ => %@", key, [aDictionary objectForKey:key]);
            [self setObject:[aDictionary objectForKey:key] forKey:key];
        }   
        
        NSLog(@"%@", [self identity] );
        //[self setObject:views forKey:COUCH_KEY_VIEWS];
        id doc = [aDictionary objectForKey:@"doc"];
        if(doc){
            NSLog(@"%@", doc);            
            //[self setObject:[aDictionary objectForKey:key] forKey:key];
            // XXX DONT MAKE ASSUMTIONS
            if([doc objectForKey:COUCH_KEY_LANGUAGE])
                [self setObject:[doc objectForKey:COUCH_KEY_LANGUAGE] forKey:COUCH_KEY_LANGUAGE];
            
            id views = [doc objectForKey:COUCH_KEY_VIEWS];
            if(views){
                NSMutableDictionary *v = [NSMutableDictionary dictionaryWithCapacity:2];
                [self setObject:v forKey:COUCH_KEY_VIEWS];
                
                for(id viewName in views){
                    SBCouchView *childView = [views objectForKey:viewName];
                    [self createAndAddView:childView withName:viewName];   
                }
                NSLog(@"%@", doc);
            }
        }
        
        
        /*
        [self setObject:[aDictionary objectForKey:COUCH_KEY_LANGUAGE] forKey:COUCH_KEY_LANGUAGE];
        [self setObject:[aDictionary objectForKey:@"_rev"] forKey:@"_rev"];
        [self setObject:[aDictionary objectForKey:@"_id"] forKey:@"_id"];
        NSDictionary *viewsDictionary = [aDictionary objectForKey:@"views"];         
        self.designDomain = [self objectForKey:@"_id"];
        
        for(NSString *viewName in viewsDictionary){
            [self createAndAddView:[viewsDictionary objectForKey:viewName] withName:viewName];
        }        
      */
    }
    return self;
}

-(void) createAndAddView:(NSDictionary*)viewDictionary withName:(NSString*)viewName{
    SBCouchView *view = [[SBCouchView alloc] initWithName:viewName couchDatabase:self.couchDatabase dictionary:viewDictionary ];
   
    // Once CouchDB 0.9 is released, _view will be something like _design/designName/_view/viewName
    NSString *viewIdentity = [NSString stringWithFormat:@"_view/%@/%@", [[self identity] lastPathComponent], view.name];
    view.identity = viewIdentity;
    [self addView:view withName:view.name];
}

-(void)addView:(SBCouchView*)view withName:(NSString*)viewName{
    if(viewName == Nil)
        return;
    view.couchDatabase = self.couchDatabase;
    NSMutableDictionary *views = [self objectForKey:COUCH_KEY_VIEWS];
    NSLog(@"%@", views);
    [views setObject:view forKey:viewName];
    NSLog(@"%@", [self objectForKey:COUCH_KEY_VIEWS]);
}

-(NSDictionary*)views{
    NSLog(@" Views ---> %@", [self objectForKey:COUCH_KEY_VIEWS]);
    return [self objectForKey:COUCH_KEY_VIEWS];
}

/*
-(NSString*)identity{
    return self.designDomain;
}
*/
 
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
