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
//@public
    
    /*!
     totalRows is the number of items in a view. It does not account for start/end key "filters" 
     that get applied. This means, that you can have instance of SBCouchEnumerator with 10,000 totalRows
     but only 2 json objects in the rows array. 
     
     Using a reduce function may also complicate matters. 
     */
    NSInteger       totalRows; 
    NSInteger       offset;

//@protected
    SBCouchView     *couchView;    
    NSMutableArray  *rows;
    NSInteger        currentIndex;
    NSInteger        sizeOfLastFetch; 
    // These are used to create query params. Might be a good idea to 
    // to move them into a SBCouchQueryOptions. The rational is that the view name is the 
    // resource, not its p
    
    SBCouchQueryOptions *queryOptions; 
}

@property NSInteger                      totalRows;
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

-(id)initWithView:(SBCouchView*)couchView;

#pragma mark Abstract Methods from NSEnumerator
-(id)nextObject; 
-(NSArray *)allObjects;

#pragma mark -
-(id)itemAtIndex:(NSInteger)idx;
// Count returns the number of rows fetched so far.
-(NSInteger)count;

@end
