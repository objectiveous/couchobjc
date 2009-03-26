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
-(void) reifyViews; // for example, if include docs is used when fetching all design docs, one wants to actually have real view objects. 
-(void) copyViews:(NSDictionary*)viewDictionary;
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
        SBOrderedDictionary *views = [SBOrderedDictionary dictionaryWithCapacity:5];
        [self setObject:views forKey:@"views"];
        self.couchDatabase = aCouchDatabaseOrNil;
        // We should ignore doc, value, rev, id         
        for(id key in aDictionary){            
            // When aDictionary is actually an instance of SBCouchDocument, we need to 
            // make copies of the SBCouchViews held in the views key. 
            if([key isEqualToString:@"views"]){
                [self copyViews:[aDictionary objectForKey:key]]; 
            }else{
                [self setObject:[aDictionary objectForKey:key] forKey:key];                                
            }            
        }
        
        [self reifyViews];
    }
    [self removeObjectForKey:@"doc"];
    //NSLog(@" --> %i ", [[self views] count]);
    return self;
}

-(void) copyViews:(NSDictionary*)viewDictionary{
    for(id viewName in viewDictionary){        
        SBCouchView *view = [viewDictionary objectForKey:viewName];
        //if(! [view isKindOfClass:[SBCouchView class]])
        //    continue;
        //XXX SBCouchView should really have a copy method.
        [self createAndAddView:view withName:viewName];
    }
}

-(void) reifyViews{
    id doc = [self objectForKey:@"doc"];
    if(doc){        
        if([doc objectForKey:COUCH_KEY_LANGUAGE])
            [self setObject:[doc objectForKey:COUCH_KEY_LANGUAGE] forKey:COUCH_KEY_LANGUAGE];
    
        if([doc objectForKey:@"_rev"]){
            [self setObject:[doc objectForKey:@"_rev"] forKey:@"_rev"];
            [self setObject:[doc objectForKey:@"_rev"] forKey:@"rev"];
        }
        
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
    
-(void)dealloc{
    [super dealloc];
}

#pragma mark -
-(void) createAndAddView:(NSDictionary*)viewDictionary withName:(NSString*)viewName{
    SBCouchView *view = [[[SBCouchView alloc] initWithName:viewName couchDatabase:self.couchDatabase dictionary:viewDictionary ] autorelease];
   
    // Once CouchDB 0.9 is released, _view will be something like _design/designName/_view/viewName
    NSString *viewIdentity = [NSString stringWithFormat:@"_design/%@/_view/%@", [[self identity] lastPathComponent], view.name];
    view.identity = viewIdentity;
    [self addView:view withName:view.name];
}

-(void)addView:(SBCouchView*)view withName:(NSString*)viewName{
    if(viewName == Nil)
        return;
    view.couchDatabase = self.couchDatabase;
    // Views have identities like: _design/designDoc/_view/viewName
    view.identity = [NSString stringWithFormat:@"%@/_view/%@", self.identity , view.name];
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

- (NSString*)designDocumentName{        
    if(self.identity)
        return [self.identity lastPathComponent];
    return nil;
}
#pragma mark -
- (id)copy{
    // I don't think this will work as it doesn't actually do a deep copy
    // and that's really what we want. 
    return [SBCouchDesignDocument designDocumentFromDocument:self];
}

@end
