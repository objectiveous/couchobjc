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
    NSInteger       totalRows;
    
//@protected
    NSInteger       batchSize;
    NSString        *startKey;
    SBCouchDatabase *couchDatabase;
    NSString        *viewPath;
    NSMutableArray  *rows;
    NSInteger       currentIndex;
    NSString        *viewName;

    // This array will need to be managed somehow in order to prevent it from
    // chewing up loads of memory when paginating through a huge database
}

@property NSInteger                 totalRows;
@property NSInteger                 batchSize;
@property (retain) NSString        *startKey;
@property (retain) SBCouchDatabase *couchDatabase;
@property (retain) NSString        *viewPath;
@property (retain) NSMutableArray  *rows;
@property NSInteger                 currentIndex;
@property (copy) NSString          *viewName;

-(id)initWithBatchesOf:(NSInteger)count database:(SBCouchDatabase*)database view:(NSString*)view;
-(id)initWithBatchesOf:(NSInteger)count database:(SBCouchDatabase*)database couchView:(SBCouchView*)couchView;

#pragma mark Abstract Methods from NSEnumerator
-(id)nextObject; 
-(NSArray *)allObjects;
-(void)fetchNextPage;
-(id)itemAtIndex:(NSInteger)idx;
@end
