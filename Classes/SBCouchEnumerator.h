//
//  SBCouchEnumerator.h
//  CouchObjC
//
//  Created by Robert Evans on 1/10/09.
//  Copyright 2009 South And Valley. All rights reserved.
//



#import <Cocoa/Cocoa.h>
#import "SBCouchView.h"

@class SBCouchDatabase; 

@interface SBCouchEnumerator : NSEnumerator {    
    /*!
     totalRows is the number of items in a view. It does not account for start/end key "filters" 
     that get applied. This means, that you can have instance of SBCouchEnumerator with 10,000 totalRows
     but only 2 json objects in the rows array. 
     
     Using a reduce function may also complicate matters. 
     */
    NSInteger           totalRows; 
    NSInteger           pageNumber; // The pagination number representing the page number we are on. 
    NSInteger           offset;
    NSInteger           currentIndex;
    NSInteger           sizeOfLastFetch;
    
    BOOL                metadataLoaded;

    
    SBCouchView         *couchView;    
    NSMutableArray      *rows;
    SBCouchQueryOptions *queryOptions; 
}


@property NSInteger                      totalRows;
@property NSInteger                      pageNumber;
@property NSInteger                      offset;
@property (retain) SBCouchView          *couchView;
@property (retain) NSMutableArray       *rows;

/*! We take a copy of the views query options because we will be mutating 
    it as we paginate a view. In other words, we're going to be changing 
    the startkey and endkey. 
 */
@property (copy)   SBCouchQueryOptions  *queryOptions; 
@property          NSInteger             currentIndex;
@property          NSInteger             sizeOfLastFetch;
@property          BOOL                  metadataLoaded;

#pragma mark -
- (id)initWithView:(SBCouchView*)couchView;
- (id)itemAtIndex:(NSInteger)idx;

/*!
 * @method      itemAtIndex:ofPage
 * @discussion  Fetch an item at an index starting at pageNumber. 
 *              
 */
- (id)objectAtIndex:(NSInteger)index ofPage:(NSInteger)pageNumber;
- (NSInteger)count; // Count returns the number of rows fetched so far.

/*!
 * @method      
 * @discussion  
 *              
 */
- (void)fetchNextPage;

/*!
 * @method     fetchPreviousPage  
 * @discussion At the moment this method assumes that all previous rows are being 
 *   cached. 
 *              
 */
- (void)fetchPreviousPage;
- (BOOL)hasNextBatch;
- (BOOL)hasPreviousBatch;

-(NSInteger)startIndexOfPage:(NSInteger)aPageNumber;
-(NSInteger)endIndexOfPage:(NSInteger)aPageNumber;

-(NSInteger)numberOfRowsForPage:(NSInteger)aPageNumber;

-(void)resetLimit:(NSInteger)limit;

#pragma mark Abstract Methods from NSEnumerator
- (id)nextObject;

// Given the nature of couchDB views, the semantics of allObjects is slightly counter-intuitive. 
// Since a view can return a huge number of rows and we can't fetch them all *and* becuase we 
// don't know, a priori, how many rows will ultimately be returned, allObjects will only return 
// an NSArray of objects that have already been fetched. In other words, it only returns a list 
// of what has already been seen. 

- (NSArray *)allObjects;
@end
