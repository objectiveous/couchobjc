//
//  SBCouchEnumerator.h
//  CouchObjC
//
//  Created by Robert Evans on 1/10/09.
//  Copyright 2009 South And Valley. All rights reserved.
//



#import <Cocoa/Cocoa.h>
//#import "SBCouchDatabase.h"

/*
 SBCouchEnumerator's only purpose in life is to convert _all_docs requests into 
 SBCouchDocuments. So how does it go about doing this you ask? 
 
 {"total_rows":7,"offset":3,"rows":[
 {"id":"_design/datacenter","key":"_design/datacenter","value":{"rev":"3651585651"}},
 {"id":"_design/tests","key":"_design/tests","value":{"rev":"1520032128"}},
 {"id":"_design/wank","key":"_design/wank","value":{"rev":"2607572312"}},
 {"id":"_design/willy","key":"_design/willy","value":{"rev":"4158571884"}}
 ]}
 
 */


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
