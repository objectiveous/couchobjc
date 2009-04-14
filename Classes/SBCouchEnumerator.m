//
//  SBCouchEnumerator.m
//  CouchObjC
//
//  Created by Robert Evans on 1/10/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import "SBCouchEnumerator.h"
#import "SBCouchDatabase.h"
#import "SBCouchDesignDocument.h"
#import "CouchObjC.h"

@interface SBCouchEnumerator (Private)


- (void)appendCouchDocuments:(NSArray*)listOfDictionaries;
- (void)logIndexes;

- (void)loadMetadata;
@end


@implementation SBCouchEnumerator

@synthesize couchView;
@synthesize totalRows;
@synthesize offset;
@synthesize rows;
@synthesize currentIndex;
@synthesize queryOptions;
@synthesize sizeOfLastFetch;
@synthesize metadataLoaded;
@synthesize pageNumber;

-(id)initWithView:(SBCouchView*)aCouchView{    
    self = [super init];
    if(self != nil){
        // Setting the currentIndex to -1 is used to indicate that we don't have an index yet. 
        self.currentIndex = -1;
        self.couchView    = aCouchView;
        self.pageNumber = 0;
        // take a copy of the queryOptions for purposes of pagination. 
        self.queryOptions = aCouchView.queryOptions;
        self.rows = [NSMutableArray arrayWithCapacity:10];
    }
    return self;  
}

-(void) dealloc{
    self.couchView = nil;
    self.rows = nil;
    self.queryOptions = nil;    
    [super dealloc];
}

#pragma mark -
- (id)objectAtIndex:(NSInteger)index ofPage:(NSInteger)aPageNumber{        
    aPageNumber--;
    if(index < 0 || index > self.queryOptions.limit && self.queryOptions.limit != 0)
        return nil;
    // decrement the index to account for the fact that rows are stored in an NSArray that is 0th based. 
    //index--;
    self.pageNumber = aPageNumber;
    NSInteger startIndex = self.queryOptions.limit * aPageNumber;
    NSInteger itemIndex = startIndex + index;
    return [self itemAtIndex:itemIndex];
}

-(id)itemAtIndex:(NSInteger)idx{
    if(self.currentIndex == -1)
        [self fetchNextPage];
    
    //NSLog(@"idx %i rows count %i", idx, [self.rows count]);
    //NSLog(@"    test %i >= %i ", ([self.rows count] -1), idx);
    if(([self.rows count] -1) >= idx){
        self.currentIndex = idx;
        return [self.rows objectAtIndex:idx];
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
        
        needMoreData = idx >= self.currentIndex;
        
        if(self.sizeOfLastFetch < self.queryOptions.limit)
            noMoreDataToFetch = TRUE;                
    }
    if(idx > self.currentIndex)
        return nil;
     
    SBCouchDocument *doc = [self.rows objectAtIndex:idx];
    return doc;
}

-(void)logIndexes{
    SBDebug(@"----------------------------------------------- \n");
    SBDebug(@"sizeOfLastFetch = %i", self.sizeOfLastFetch);
    SBDebug(@"limit           = %i", self.queryOptions.limit);
    SBDebug(@"currentIndex    = %i", self.currentIndex);
    
}



/// XXX This could probably use a rethink. 
-(BOOL)shouldFetchNextBatch{
    if(self.currentIndex == -1)
        return YES;
    
    // If there has been no limit set, then we are not paginating through a set of results. 
    // If currentIndex not zero, we've already performed a fetch
    // So, we're done. 
    if(self.queryOptions.limit == 0 && currentIndex != -1)
        return NO;
    
    if(self.totalRows == self.currentIndex && [rows count])
        return NO;
    
    // if the index is >= to the number of rows we can fetch more, 
    // but if the size of the last fetch was larger than the batch size (i.e limit)
    //
    // The default for limit is zero and sizeOfLastFetch is set to -1 when 
    if(currentIndex >= [rows count] && self.sizeOfLastFetch >= self.queryOptions.limit)
        return YES;
    
    // Since we don't need to load a new page of data (we did that already in order to get the metadata),
    // increment the page count, and return a NO. 
    if(self.metadataLoaded == YES && self.pageNumber == 0)
        self.pageNumber++;
    
    return NO;
}



- (id)nextObject{
    // At some point lastObjectsID will 
    if([self shouldFetchNextBatch]){
        //[self setStartKey:[[rows lastObject] objectForKey:@"id"]];
        NSString *lastObjectsID = [[self.rows lastObject] objectForKey:COUCH_KEY_ID];
        // The first time through, we won't have any rows
        if(lastObjectsID)
            self.queryOptions.startkey = lastObjectsID;
        
        [self fetchNextPage];
    }
    
    // If the call to fetchNextPage did not expand the number of rows to a number 
    // greater than currentIndex
    if(currentIndex >= [self.rows count]){
        return nil;
    }
    
    SBCouchDocument *object = [rows objectAtIndex:currentIndex];
    [self setCurrentIndex:[self currentIndex] +1 ];

    //object.identity = [object objectForKey:@"id"];
    return object;
} 
- (NSArray *)allObjects{
    if(self.currentIndex == -1)
        [self fetchNextPage];
    
    self.metadataLoaded = YES;
    return self.rows;
}

-(void)fetchPreviousPage{
        
}

-(void)fetchNextPage{
    if(self.pageNumber * self.queryOptions.limit > self.totalRows && self.metadataLoaded == YES)
        return;
    
    //if(! (self.totalRows >= self.queryOptions.limit && self.queryOptions.limit >= self.sizeOfLastFetch))
    //    return;
    
    // contruct a new URL using our own copy of the query options
    // View URLs are expected to have names like
    // _design/designdocName/_view/viewName?xx=xx  && _all_docs
    // This format will be changing in the 0.9 release of CouchDB
    NSDictionary *etf;
    NSString *contructedUrl;
    if(self.queryOptions){
        contructedUrl = [NSString stringWithFormat:@"%@?%@", [self.couchView identity], [self.queryOptions queryString]];        
    }else{
        contructedUrl = [NSString stringWithFormat:@"%@", [self.couchView identity]];
    }
        
    if(self.couchView.runAsSlowView){            
        self.couchView.queryOptions = self.queryOptions;
        etf = [self.couchView.couchDatabase runSlowView:self.couchView];        
    }else{
        etf = [self.couchView.couchDatabase get:contructedUrl];
    }
        

    // If this is our first attempt at a fetch, we need to initialize the currentIndex
    if(self.currentIndex == -1){
        self.currentIndex = 0;
        // Since this is our first fetch, set the skip value to 1 
        // XXX This should be moved someplace where its only ever called 
        //     once. No need to set this on every fetch. 
        self.queryOptions.skip=1;
    }
    // Add meta data. 
    self.totalRows    = [[etf objectForKey:@"total_rows"] integerValue]; 
    self.offset       = [[etf objectForKey:@"offset"] integerValue];

    NSArray *newRows = [etf objectForKey:@"rows"];
    [self appendCouchDocuments:newRows];
    if([newRows count] <= 0){
        self.sizeOfLastFetch = -1;
    }else{
        self.sizeOfLastFetch = [newRows count];
         NSString *lastObjectsID = [[self.rows lastObject] objectForKey:COUCH_KEY_ID];
         if(self.queryOptions.limit > 0)
             self.queryOptions.startkey = lastObjectsID;
    }
    self.pageNumber++;
}

-(void)appendCouchDocuments:(NSArray*)listOfDictionaries{
    id doc;
    for(NSDictionary *dict in listOfDictionaries){
        // if we see something starting w/ "_design", we can be sure its a design document and then go ahead 
        // and create one of those. Is there a way of know earlier or knowing faster? 
        NSString *documentType = [dict objectForKey:@"id"];
        NSString *designDocPath = [documentType stringByDeletingLastPathComponent];
        
        if(designDocPath != nil && [designDocPath isEqualToString:@"_design"] && [dict objectForKey:@"doc"]){
            // Snag the actual document out of the row and use that to instatiate a DesignDocument. 
            NSDictionary *documentDictionary = [dict objectForKey:@"doc"];
            doc = [[[SBCouchDesignDocument alloc] initWithDictionary:documentDictionary couchDatabase:self.couchView.couchDatabase] autorelease];  
            //doc = [[[SBCouchDesignDocument alloc] initWithDictionary:dict couchDatabase:self.couchView.couchDatabase] autorelease];  

        }else{            
            doc = [[[SBCouchDocument alloc] initWithNSDictionary:dict couchDatabase:self.couchView.couchDatabase] autorelease];
            // We are seeting the identity here because calls like _all_docs return identities using the key id and not _id
            // and it would be a mistake to assume that anytime we have an 'id' key in the dict that it is an actual identity. 
            // For example, someone could create a view that returns the keys: _id, id, and key. Then what would we do? 
            // CouchDB may move _id into the HTTP headers, so we won't get to worried just yet. 
            if(documentType != nil)
                [(SBCouchDocument*)doc setIdentity:documentType];
        }
        [self.rows addObject:doc];
    }    
}

-(NSInteger)count{
    if(self.currentIndex == -1 && self.queryOptions.limit <= 0){
        [self allObjects];
        return [self.rows count];
    }
    
    if(self.currentIndex == -1 && self.metadataLoaded == NO){
        [self fetchNextPage];
    }
    self.metadataLoaded = YES;
    return [self.rows count];
}

-(void) loadMetadata{
    [self fetchNextPage];
    // XXX This is a hack so that we can reuse fetchNext without it incementing the pagenation page number. 
    self.pageNumber--;
    
    self.metadataLoaded = YES;
}

// XXX Once this is working, we really need to clean things up. 
-(BOOL)hasNextBatch{
    if(metadataLoaded == NO)
        [self loadMetadata];
    // Remember that total rows can be greater than the number of rows returned when using filters. 
    // http://localhost:5984/twitter/_all_docs?startkey=%22_design%2F%22&endkey=%22_design0%22
    
    //if(self.pageNumber * self.queryOptions.limit > self.totalRows)
    //    return NO;
    
    //if([self.rows count] >= self.totalRows && ! self.currentIndex < [self.rows count])
    //    return NO;
    
    if(self.totalRows > self.queryOptions.limit && self.queryOptions.limit >= self.sizeOfLastFetch && self.totalRows != [self.rows count])
        return YES;

    if(self.currentIndex + self.queryOptions.limit + 1 < self.totalRows)
        return YES;
    
    return NO;
}

-(BOOL)hasPreviousBatch{
    if(metadataLoaded == NO)
        return NO;
    
    if(self.pageNumber > 1)
        return YES;
    
    return NO;
}


-(NSInteger)startIndexOfPage:(NSInteger)aPageNumber{
    if(! self.metadataLoaded)
        [self count];
    
    aPageNumber--;
    NSInteger startIndex =  self.queryOptions.limit * aPageNumber;
    // return startIndex but increment the value by one because these numbers are used 
    // to represent indexes in a human friendly way. In other words, they start at 1. 
    return ++startIndex;
}
-(NSInteger)endIndexOfPage:(NSInteger)aPageNumber{
    if(! self.metadataLoaded)
        [self count];
    
    NSInteger endIndex =  self.queryOptions.limit * aPageNumber;
    if(endIndex > self.totalRows)
        endIndex =  endIndex - (endIndex - self.totalRows);
    
    return endIndex;
}
-(NSInteger)numberOfRowsForPage:(NSInteger)aPageNumber{
    // If there's no limit, then we assume that the resultset is fully 
    // populated and we return the array count. 
    if(self.queryOptions.limit == 0)
        return [self.rows count];
    
    // Since we have a limit, we'll return the number of items 
    // that should be shown per view
    NSInteger endOfPage = [self endIndexOfPage:aPageNumber]+1;
    NSInteger startOfPage = [self startIndexOfPage:aPageNumber];
    return endOfPage - startOfPage;
}

-(void)resetLimit:(NSInteger)limit{
    self.queryOptions.limit = limit;
    self.queryOptions.startkey = nil;
    self.queryOptions.endkey = nil;
    self.queryOptions.skip = 0;
    self.currentIndex = -1;
    self.metadataLoaded = NO;
    //self.totalRows = -1;
    [self.rows removeAllObjects];
    //self.rows = [NSMutableArray arrayWithCapacity:limit];
    [self count];
}
@end
