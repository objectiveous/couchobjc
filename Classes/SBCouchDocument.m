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

@interface SBCouchDocument (Private)
-(SBOrderedDictionary*) makeDictionaryOrderly:(NSDictionary*)aDictionary;
-(NSArray*) convertArrayContents:(NSArray*)anArray;
-(NSArray*)revs;
@end

@implementation SBCouchDocument
@synthesize serverName;
@synthesize databaseName;

-(id)init{

    self = [super initWithCapacity:0];
    if(self){

    }
    return self;
}

-(SBCouchDocument*)initWithNSDictionary:(NSDictionary*)aDictionary{

    self = [super init];
    if(self){
        if(! [aDictionary isKindOfClass:[SBOrderedDictionary class]])
            aDictionary = [self makeDictionaryOrderly:aDictionary];
        [self addEntriesFromDictionary:aDictionary];
    }
    return self;
}

-(void)dealloc{
    [super dealloc];
}


#pragma mark -
-(NSArray*)revs{
    return [self objectForKey:@"_revs"];
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
    if(index == NSNotFound)
        return nil;
    
    if([[self revs] count] > index){
        return [[self revs] objectAtIndex:index+1];     
    }
        
    return nil;
}

-(NSInteger)revisionIndex{
    NSArray *revArray = [self revs];
    if([revArray count] <= 0)
        return NSNotFound;
    
    NSString *thisRevision = [self objectForKey:@"_rev"];
    
    BOOL inThere = [revArray containsObject:thisRevision];
    if(! inThere)
        return NSNotFound; 
    
    NSUInteger index = [revArray indexOfObject:thisRevision];
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
    NSDictionary *revs = [self objectForKey:@"_revs"];
    return [revs count];
}

- (NSString *)description{
    NSString *dictionaryDiscription = [self JSONRepresentation];
    NSMutableString *description = [NSMutableString stringWithString:dictionaryDiscription];
    [description appendFormat:@"\n serverName : %@", self.serverName];
    [description appendFormat:@"\n databaseName : %@", self.databaseName];
    return description;
}

/*
-(void)setObject:(id)anObject forKey:(id)aKey{
    [self setObject:anObject forKey:aKey];    
}

- (id)keyAtIndex:(NSUInteger)anIndex{
    return [self keyAtIndex:anIndex];
}

-(id)objectForKey:(id)aKey{
    return [self objectForKey:aKey];
}

- (NSString *)description{
    NSString *dictionaryDiscription = [self JSONRepresentation];
    NSMutableString *description = [NSMutableString stringWithString:dictionaryDiscription];
    [description appendFormat:@"\n serverName : %@", self.serverName];
    [description appendFormat:@"\n databaseName : %@", self.databaseName];
    return description;
}

 
#pragma mark - 
#pragma mark JSON Support 



#pragma mark - 
#pragma mark Forward Calls To NSDictionary
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector{
    // does the delegate respond to this selector?
    
    if ([[self dictionaryDoc] respondsToSelector:selector])
    {
        // yes, return the delegate's method signature
        return [[self dictionaryDoc] methodSignatureForSelector:selector];
    } else {
        // no, return whatever NSObject would return
        return [super methodSignatureForSelector: selector];
    }
}

- (void)forwardInvocation:(NSInvocation *)invocation{    
    [invocation invokeWithTarget:[self dictionaryDoc]];
}

 */

#pragma mark -

- (NSString*)identity {
    return [self objectForKey:@"_id"];
}

- (NSString*)revision {
    return [self objectForKey:@"_rev"];
}

- (void)setIdentity:(NSString*)someId {
    [self setObject:someId forKey:@"_id"];
}

- (void)setRevision:(NSString*)aRevision {
    [self setObject:aRevision forKey:@"_rev"];
}


@end
