//
//  SBCouchDocument.m
//  CouchObjC
//
//  Created by Robert Evans on 1/24/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import "SBCouchDocument.h"
#import <JSON/JSON.h>


@interface SBCouchDocument (Private)
-(SBOrderedDictionary*) makeDictionaryOrderly:(NSDictionary*)aDictionary;
-(NSArray*) convertArrayContents:(NSArray*)anArray;
@end

@implementation SBCouchDocument

@synthesize dictionaryDoc;
@synthesize serverName;
@synthesize databaseName;


-(SBCouchDocument*)initWithNSDictionary:(NSMutableDictionary*)aDictionary{
    // XXX do we need to use autorelease here? 
    self = [super init];
    if(self){
        if(! [aDictionary isKindOfClass:[SBOrderedDictionary class]])
            aDictionary = [self makeDictionaryOrderly:aDictionary];
        [self setDictionaryDoc:(SBOrderedDictionary*)aDictionary];
    }
    return self;
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
    NSDictionary *revs = [[self dictionaryDoc] objectForKey:@"_revs"];
    return [revs count];
}


-(void)setObject:(id)anObject forKey:(id)aKey{
    [[self dictionaryDoc] setObject:anObject forKey:aKey];    
}

- (id)keyAtIndex:(NSUInteger)anIndex{
    return [[self dictionaryDoc] keyAtIndex:anIndex];
}

-(id)objectForKey:(id)aKey{
    return [[self dictionaryDoc] objectForKey:aKey];
}

- (NSString *)description{
    NSString *dictionaryDiscription = [self.dictionaryDoc description];
    NSMutableString *description = [NSMutableString stringWithString:dictionaryDiscription];
    [description appendFormat:@"\n serverName : %@", self.serverName];
    [description appendFormat:@"\n databaseName : %@", self.databaseName];
    return description;
}

#pragma mark - 
#pragma mark JSON Support 

-(NSString*)JSONRepresentation{
    return [self.dictionaryDoc JSONRepresentation];
}

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
@end
