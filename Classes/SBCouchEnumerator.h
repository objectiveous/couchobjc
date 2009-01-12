//
//  SBCouchEnumerator.h
//  CouchObjC
//
//  Created by Robert Evans on 1/10/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "SBCouchDatabase.h"

@class SBCouchDatabase; 

@interface SBCouchEnumerator : NSEnumerator {
//@public
    NSInteger       totalRows;
    
//@protected
    NSInteger       batchSize;
    NSString        *startKey;
    SBCouchDatabase *db;
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
// Should copy the database but we're being cock-blocked by 
//  *** -[SBCouchDatabase copyWithZone:]: unrecognized selector sent to instance 0x1555d0
@property (retain)   SBCouchDatabase *db;
@property (retain) NSString        *viewPath;
@property (retain) NSMutableArray  *rows;
@property NSInteger                 currentIndex;
@property (copy) NSString          *viewName;
-(id)initWithBatchesOf:(NSInteger)count database:(SBCouchDatabase*)database view:(NSString*)view;


#pragma mark Abstract Methods from NSEnumerator
-(id)nextObject; 
-(NSArray *)allObjects;
-(void)fetchNextPage;
-(id)itemAtIndex:(NSInteger)idx;
@end
