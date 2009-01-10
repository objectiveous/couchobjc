//
//  SBCouchDatabase+View.m
//  stigmergic
//
//  Created by Robert Evans on 1/9/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import "SBCouchDatabase+View.h"
#import "SBCouchEnumerator.h"

@implementation SBCouchDatabase (View)

-(NSEnumerator*) view:(NSString*)viewName{
    return [[[STIGCouchViewEnumerator alloc] init] autorelease];
}

-(NSEnumerator*)allDocsInBatchesOf:(NSInteger*)count{
    //NSDictionary *entireResult = [self get:@"_all_docs"];
    //assert(entireResult);
    //NSLog(@"----------[%@]", entireResult);
    //NSLog(@"self ----->>>>  [%@]", self);
    SBCouchEnumerator *enumerator = [[SBCouchEnumerator alloc] initWithBatchesOf:count 
                                                                        database:self
                                                                            view:@"_all_docs"];
    return (NSEnumerator*)enumerator;
}
-(NSEnumerator*) allDocs{
    NSDictionary *list = [self get:@"_all_docs"];
    
    return [[list objectForKey:@"rows"] objectEnumerator];
    //return [[[STIGCouchViewEnumerator alloc] init] autorelease];
}
@end



@implementation STIGCouchViewEnumerator {
  
} 

-(NSArray *)allObjects{
    return [NSArray arrayWithObjects:@"1", @"2", nil];
}  
@end