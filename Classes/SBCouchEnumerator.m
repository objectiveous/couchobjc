//
//  SBCouchEnumerator.m
//  CouchObjC
//
//  Created by Robert Evans on 1/10/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import "SBCouchEnumerator.h"
#import "SBCouchDatabase.h"

@implementation SBCouchEnumerator

@synthesize db;
@synthesize totalRows;
@synthesize batchSize;
@synthesize viewPath;
@synthesize rows;
@synthesize index;
@synthesize startKey;
@synthesize viewName;

-(id)initWithBatchesOf:(NSInteger)count database:(SBCouchDatabase*)database view:(NSString*)view{
    NSString *url = [NSString stringWithFormat:@"%@?count=%i&group=true", view, count];
    
    NSDictionary *etf = [database get:url];

    self = [super init];
    if(self != nil){
        [self setViewName:view];
        [self setIndex:0];
        [self setTotalRows:[[etf objectForKey:@"total_rows"] integerValue]];
        [self setBatchSize:count]; 
        [self setDb:database];
        [self setViewPath:view];
        [self setRows:[etf objectForKey:@"rows"]];
    }
    return self;    
}

-(void) dealloc{
    [startKey release], startKey = nil;
    [viewPath release], viewName = nil;
    [db release];
    [super dealloc];

}

- (id)nextObject{
    if( (index >= [rows count]) && [rows count] < totalRows){
    
        [self setStartKey:[[rows lastObject] objectForKey:@"id"]];
        NSLog(@"new startKey [%@]", [self startKey]);
        [self fetchNextPage];
    }
    
    if(index >= [rows count]){
        // free up the rows array
        [rows release], rows = nil;
        return nil;
    }
        
    
    id object = [rows objectAtIndex:index];
    [self setIndex:[self index] +1 ];
    return object;
} 
- (NSArray *)allObjects{
    return nil;
}

-(void)fetchNextPage{    
    NSMutableString *viewUrl = [NSMutableString stringWithFormat:@"%@?", [self viewName]];

    [viewUrl appendFormat:@"startkey=\"%@\"&", [self startKey]];
    [viewUrl appendFormat:@"startkey_docid=\"%@\"&", [self startKey]];
    [viewUrl appendString:@"skip=1&"];
    [viewUrl appendFormat:@"count=%i&",[self batchSize]];
    [viewUrl appendString:@"group=true"];
        
    NSDictionary *etf = [[self db] get:[viewUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [rows addObjectsFromArray:[etf objectForKey:@"rows"]];
}

@end
