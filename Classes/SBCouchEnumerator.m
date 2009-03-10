//
//  SBCouchEnumerator.m
//  CouchObjC
//
//  Created by Robert Evans on 1/10/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import "SBCouchEnumerator.h"
#import "SBCouchDatabase.h"
#import "CouchObjC.h"

@interface SBCouchEnumerator (Private)

-(BOOL)shouldFetchNextBatch;

@end


@implementation SBCouchEnumerator

@synthesize couchView;
@synthesize totalRows;
@synthesize offset;
@synthesize rows;
@synthesize currentIndex;
@synthesize queryOptions;
@synthesize sizeOfLastFetch;


-(id)initWithView:(SBCouchView*)aCouchView{    
    self = [super init];
    if(self != nil){
        // Setting the currentIndex to -1 is used to indicate that we don't have an index yet. 
        self.currentIndex = -1;
        self.couchView    = aCouchView;
        // take a copy of the queryOptions for purposes of pagination. 
        self.queryOptions = aCouchView.queryOptions;
        self.rows = [NSMutableArray arrayWithCapacity:10];
    }
    return self;  
}

-(void) dealloc{
    [self.rows release];
    [super dealloc];

}

-(id)itemAtIndex:(NSInteger)idx{
    if(self.currentIndex == -1)
        [self fetchNextPage];
    
    if([self.rows count] >= idx){        
        NSDictionary *row = [self.rows objectAtIndex:idx];
        return [[SBCouchDocument alloc] initWithNSDictionary:row couchDatabase:self.couchView.couchDatabase];
    }else{
        self.currentIndex = self.currentIndex + self.queryOptions.limit; 
    }
    
    // trying to access something that has not yet been fetched
    
    BOOL noMoreDataToFetch = self.sizeOfLastFetch < self.queryOptions.limit;
    BOOL needMoreData = idx > self.currentIndex;
    while(needMoreData && !noMoreDataToFetch ){
        [self logIndexes];
        [self fetchNextPage];
        self.currentIndex = self.currentIndex + self.queryOptions.limit;
        
        if(self.sizeOfLastFetch < self.queryOptions.limit)
            noMoreDataToFetch = TRUE;                
    }
    if(idx > self.currentIndex)
        return nil;
    
    // TODO Might want to autorelease this. 
    NSDictionary *row = [self.rows objectAtIndex:idx];
    SBCouchDocument *doc = [[SBCouchDocument alloc] initWithNSDictionary:row couchDatabase:self.couchView.couchDatabase];
    return doc;
}

-(void)logIndexes{
    NSLog(@"----------------------------------------------- \n");
    NSLog(@"sizeOfLastFetch = %i", self.sizeOfLastFetch);
    NSLog(@"limit           = %i", self.queryOptions.limit);
    NSLog(@"currentIndex    = %i", self.currentIndex);
    
}


-(BOOL)shouldFetchNextBatch{
    if(self.currentIndex == -1)
        return YES;
    
    // if the index is >= to the number of rows we can fetch more, 
    // but if the size of the last fetch was larger than the batch size (i.e limit)
    //
    // The default for limit is zero and sizeOfLastFetch is set to -1 when 
    if(currentIndex >= [rows count] && self.sizeOfLastFetch >= self.queryOptions.limit)
        return YES;
    
    return NO;
}
- (id)nextObject{
    // At some point lastObjectsID will 
    if([self shouldFetchNextBatch]){
        //[self setStartKey:[[rows lastObject] objectForKey:@"id"]];
        NSString *lastObjectsID = [[self.rows lastObject] objectForKey:@"id"];
        // The first time through, we won't have any rows
        if(lastObjectsID)
            self.queryOptions.startkey = lastObjectsID;
        
        [self fetchNextPage];
    }
    
    // If the call to fetchNextPage did not expand the number of rows to a number 
    // greater than currentIndex
    if(currentIndex >= [self.rows count]){
        //[rows release], rows = nil;
        return nil;
    }
        
    id object = [rows objectAtIndex:currentIndex];
    [self setCurrentIndex:[self currentIndex] +1 ];
    // TODO might want to autorelease this. 
    SBCouchDocument *doc = [[SBCouchDocument alloc] initWithNSDictionary:object couchDatabase:self.couchView.couchDatabase];
    // XXX Is this a proper identity? 
    doc.identity = [doc objectForKey:@"id"];
    return doc;
} 
- (NSArray *)allObjects{
    return nil;
}

-(void)fetchNextPage{   
    // contruct a new URL using our own copy of the query options
    NSString *contructedUrl = [NSString stringWithFormat:@"%@?%@", self.couchView.name, [self.queryOptions queryString]];
    NSLog(contructedUrl);
    //NSString *viewUrl = [self.couchView urlString];   
    NSDictionary *etf = [self.couchView.couchDatabase get:contructedUrl];

    // If this is our first attempt at a fetch, we need to initialize the currentIndex
    if(self.currentIndex == -1 ){
        self.totalRows    = [[etf objectForKey:@"total_rows"] integerValue]; 
        self.offset       = [[etf objectForKey:@"offset"] integerValue];
        self.currentIndex = 0;
        // Since this is our first fetch, set the skip value to 1 
        // XXX This should be moved someplace where its only ever called 
        //     once. No need to set this on every fetch. 
        self.queryOptions.skip=1;
    }

    NSArray *newRows = [etf objectForKey:@"rows"];
    [rows addObjectsFromArray:newRows];
    if([newRows count] <= 0){
        self.sizeOfLastFetch = -1;
    }else{
        self.sizeOfLastFetch = [newRows count];
         NSString *lastObjectsID = [[self.rows lastObject] objectForKey:@"id"];
         if(self.queryOptions.limit > 0)
             self.queryOptions.startkey = lastObjectsID;
    }
}

@end
