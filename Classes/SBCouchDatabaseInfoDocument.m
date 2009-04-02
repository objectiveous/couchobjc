//
//  SBCouchDatabaseInfoDocument.m
//  CouchObjC
//
//  Created by Robert Evans on 3/29/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import "SBCouchDatabaseInfoDocument.h"
//@class SBCouchDocument;


@implementation SBCouchDatabaseInfoDocument
@dynamic db_name;
@dynamic doc_count;
@dynamic doc_del_count;
@dynamic update_seq;
@dynamic purge_seq;
@dynamic compact_running;
@dynamic disk_size;
@dynamic instance_start_time;



#pragma mark -
#pragma mark Experimental support for dynamic properties. 
- (void) forwardInvocation: (NSInvocation*)invocation{
    NSString* selectorName = NSStringFromSelector([invocation selector]);
    [invocation setArgument: &selectorName atIndex: 2];
    [invocation setSelector: NSSelectorFromString(@"objectForKey:")];
    return [invocation invokeWithTarget:self];
    
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel{
    if([self objectForKey: NSStringFromSelector(sel)] != nil) {
        NSMethodSignature *sig = [[self class]  
               instanceMethodSignatureForSelector:
               NSSelectorFromString(@"objectForKey:") ];
        return sig;
    } else {
        return [super methodSignatureForSelector: sel];
    }
    
}

@end
