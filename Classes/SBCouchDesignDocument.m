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
//@synthesize designDomain;


+ (SBCouchDesignDocument*)designDocumentFromDocument:(SBCouchDocument*)aCouchDocument{
    SBCouchDesignDocument *designDoc = [[[SBCouchDesignDocument alloc] initWithDictionary:aCouchDocument 
                                                                            couchDatabase:aCouchDocument.couchDatabase] autorelease];
    return designDoc;
}
-(id)initWithName:(NSString*)domain couchDatabase:(SBCouchDatabase*)aCouchDatabaseOrNil{
    self = [super init];
    if(self != nil){
        self.couchDatabase = aCouchDatabaseOrNil;
        SBOrderedDictionary *views = [SBOrderedDictionary dictionaryWithCapacity:5];
        [self setObject:views forKey:@"views"];
        [self setObject:COUCH_KEY_LANGUAGE_DEFAULT forKey:COUCH_KEY_LANGUAGE];
        NSString *properID = [NSString stringWithFormat:@"%@%@", COUCH_KEY_DESIGN_PREFIX, domain];
        [self setObject:properID forKey:COUCH_KEY_ID];
        //self.identity = [NSString stringWithFormat:@"%@%@", COUCH_KEY_DESIGN_PREFIX, domain];
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
            
            [self setObject:[aDictionary objectForKey:key] forKey:key];
        }   
                        
        id doc = [aDictionary objectForKey:@"doc"];
        if(doc){        
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
            }
        }
    }
    return self;
}

-(void)dealloc{
    [super dealloc];
}

#pragma mark -
-(void) createAndAddView:(NSDictionary*)viewDictionary withName:(NSString*)viewName{
    SBCouchView *view = [[[SBCouchView alloc] initWithName:viewName couchDatabase:self.couchDatabase dictionary:viewDictionary ] autorelease];
   
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
    [views setObject:view forKey:viewName];
}

-(NSDictionary*)views{
    return [self objectForKey:COUCH_KEY_VIEWS];
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
