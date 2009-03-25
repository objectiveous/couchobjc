//
//  SBCouchDocument.m
//  CouchObjC
//
//  Created by Robert Evans on 1/24/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import "SBCouchDocument.h"
#import <JSON/JSON.h>
#import "SBOrderedDictionary.h"
#import "SBCouchServer.h";
#import "SBCouchDatabase.h"
#import "CouchObjC.h"

@interface SBCouchDocument (Private)
-(SBOrderedDictionary*) makeDictionaryOrderly:(NSDictionary*)aDictionary;
-(NSArray*) convertArrayContents:(NSArray*)anArray;
-(NSArray*)revs;
@end

@implementation SBCouchDocument

@synthesize couchDatabase;

-(id)init{
    self = [super initWithCapacity:0];
    if(self){

    }
    return self;
}

-(SBCouchDocument*)initWithNSDictionary:(NSDictionary*)aDictionary couchDatabase:(SBCouchDatabase*)aCouchDatabaseOrNil{

    self = [super init];
    if(self){
        self.couchDatabase = aCouchDatabaseOrNil;
        if(! [aDictionary isKindOfClass:[SBOrderedDictionary class]])
            aDictionary = [self makeDictionaryOrderly:aDictionary];
        [self addEntriesFromDictionary:aDictionary];
    }
    return self;
}

-(void)dealloc{
    self.couchDatabase = nil;
    [super dealloc];
}


#pragma mark -
-(NSArray*)revs{
    id revisionDict = [self objectForKey:COUCH_KEY_REVISIONS];
    NSLog(@"%@", revisionDict);
    
    NSArray *ids = [revisionDict objectForKey:COUCH_KEY_IDS];    
    return ids;
}


-(SBOrderedDictionary*) makeDictionaryOrderly:(NSDictionary*)aDictionary{    
    if([aDictionary isKindOfClass:[SBOrderedDictionary class]])
        return (SBOrderedDictionary*) aDictionary;
    
    SBOrderedDictionary *orderedDocument = [[SBOrderedDictionary alloc] initWithCapacity:[[aDictionary allKeys] count]];
    // _id and _rev have special meaning in couchDB, do let's always make them display first.     
    if( [[aDictionary allKeys] containsObject:@"_id"]){
        [orderedDocument setObject:[aDictionary objectForKey:@"_id"] forKey:@"_id"];
    }
    
    if( [[aDictionary allKeys] containsObject:@"_rev"]){
        [orderedDocument setObject:[aDictionary objectForKey:@"_rev"] forKey:@"_rev"];
    }
            
    
    for(NSString *aDictionaryKey in aDictionary){
        if([aDictionaryKey isEqualToString:@"_id"] || [aDictionaryKey isEqualToString:@"_id"]){
            continue;
        }
        
        id aDictionaryValue = [aDictionary objectForKey:aDictionaryKey];
        
        // Conversion of NSDictionary
        if([aDictionaryValue isKindOfClass:[NSDictionary class]])
            aDictionaryValue = [self makeDictionaryOrderly:aDictionaryValue];
        
        // Conversion of NSArray
        if([aDictionaryValue isKindOfClass:[NSArray class]]){
            aDictionaryValue = [self convertArrayContents:aDictionaryValue];
        }
        
        [orderedDocument setObject:aDictionaryValue forKey:aDictionaryKey];
    }
    return orderedDocument;
}

/*
 Revisions are 0 based which means that revision the 0th index is the latest and 
 Nth is the oldest. 
 */

-(NSString*)previousRevision{           
    NSUInteger index = [self revisionIndex];
    if(index == NSNotFound || index == 0)
        return nil;
    
    id previousR = [[self revs] objectAtIndex:index-1];
    
    /*
     Old revision work 0.9
    if([[self revs] count] > index){
        return [[self revs] objectAtIndex:index+1];     
    }
        
    return nil;
     */
}

-(NSInteger)revisionIndex{
    NSArray *revArray = [self revs];
    if([revArray count] <= 0)
        return NSNotFound;
    
    NSString *thisRevision = [self objectForKey:COUCH_KEY_REV];
    // XXX 
    // strip leading x- value from _rev. Not sure how these work leading values work yet. 
    // the API just changed.
    NSArray *revisonParts = [thisRevision componentsSeparatedByString:@"-"];
    NSString *indexPart = [revisonParts objectAtIndex:0];
    NSString *versionPart = [revisonParts objectAtIndex:1];
    
    BOOL inThere = [revArray containsObject:versionPart];
    if(! inThere)
        return NSNotFound; 
        
    //NSUInteger index = [revArray indexOfObject:versionPart];
    //return index;
    
    NSInteger index = [indexPart integerValue];
    return index;

}


-(NSArray*) convertArrayContents:(NSArray*)anArray{
    NSMutableArray *convertedArray= [[[NSMutableArray alloc] init] autorelease];
    
    for(id arrayContent in anArray){
        if([arrayContent isKindOfClass:[NSDictionary class]]){ 
            SBOrderedDictionary *replacementDict = [self makeDictionaryOrderly:arrayContent];
            [convertedArray addObject:replacementDict];
        }else if([arrayContent isKindOfClass:[NSArray class]]){ 
            NSArray *replacementArray = [self convertArrayContents:arrayContent];
            [convertedArray addObject:replacementArray];
        }else{ 
            [convertedArray addObject:arrayContent];
        }          
    }
    return convertedArray;
}

-(NSInteger)numberOfRevisions{
    NSDictionary *revs = [self objectForKey:COUCH_KEY_REVISIONS];
    return [revs count];
}

- (NSString *)description{
    NSString *dictionaryDiscription = [self JSONRepresentation];
    NSMutableString *description = [NSMutableString stringWithString:dictionaryDiscription];
    SBCouchServer *server = [self.couchDatabase couchServer];
    
    [description appendFormat:@"\n serverName : %@", [server serverURLAsString]];
    [description appendFormat:@"\n databaseName : %@", [self.couchDatabase name]];
    return description;
}

#pragma mark -



- (NSString*)revision {
    // pre 0.9 code
    //return [self objectForKey:@"_rev"];
    
    NSString *thisRevision = [self objectForKey:COUCH_KEY_REV];
    // XXX 
    // strip leading x- value from _rev. Not sure how these work leading values work yet. 
    // the API just changed.
    NSArray *revisonParts = [thisRevision componentsSeparatedByString:@"-"];
    NSString *indexPart = [revisonParts objectAtIndex:0];
    NSString *versionPart = [revisonParts objectAtIndex:1];
    return versionPart;
    
}

- (NSString*)identity {
    NSString *docID = [self objectForKey:@"_id"];
    if(!docID)
        docID = [self objectForKey:@"id"];
    
    return docID;
}

- (void)setIdentity:(NSString*)someId {
    [self setObject:someId forKey:@"_id"];
}

// XXX This is a mess. Which is it _rev or rev?
- (void)setRevision:(NSString*)aRevision {
    [self setObject:aRevision forKey:@"_rev"];
    [self setObject:aRevision forKey:@"rev"];
}

- (void)detach{
    // XXX removing _id can, at times, cause a segfault. At the moment, I'm not sure why. 
    /*
    if([self objectForKey:@"id"]){
        id identity = [self objectForKey:@"id"];
        SBDebug(@"id value %@", identity);
        SBDebug(@"retain count %i", [identity retainCount] );
        //[self removeObjectForKey:@"id"];
    }
    */
    [self removeObjectForKey:@"_id"];        
    [self removeObjectForKey:@"key"];
    [self removeObjectForKey:@"_rev"];
}

#pragma mark -
#pragma mark REST Methods
- (SBCouchDocument*)getWithRevisionCount:(BOOL)withCount andInfo:(BOOL)andInfo revision:(NSString*)revisionOrNil{
    return [self.couchDatabase getDocument:self.identity withRevisionCount:withCount andInfo:andInfo revision:revisionOrNil];
}

- (SBCouchResponse*)put{
    return [self.couchDatabase putDocument:self];
}

- (SBCouchResponse*)putDocument:(SBCouchDocument*)couchDocument{
    return [self.couchDatabase putDocument:couchDocument];
}

- (SBCouchResponse*)post{
    //return [self.couchDatabase post:self];
}

@end
