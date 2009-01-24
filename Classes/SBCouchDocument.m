//
//  SBCouchDocument.m
//  CouchObjC
//
//  Created by Robert Evans on 1/24/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import "SBCouchDocument.h"


@implementation SBCouchDocument

@synthesize dictionaryDoc;
@synthesize serverName;
@synthesize databaseName;


-(SBCouchDocument*)initWithNSDictionary:(NSDictionary*)aDictionary{
    // XXX do we need to use autorelease here? 
    self = [super init];
    if(self){
        [self setDictionaryDoc:aDictionary];
    }
    return self;
}

-(id)objectForKey:(id)aKey{
    return [[self dictionaryDoc] objectForKey:aKey];
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
