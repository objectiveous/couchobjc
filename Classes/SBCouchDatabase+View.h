//
//  SBCouchDatabase+View.h
//  stigmergic
//
//  Created by Robert Evans on 1/9/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CouchObjC/CouchObjC.h>


/* TODO it might be better to add this to the NSDictionary. Not sure. 
*/
@interface SBCouchDatabase (View) 


-(NSEnumerator*)view:(NSString*)viewName;
-(NSEnumerator*)allDocsInBatchesOf:(NSInteger)count;
-(NSEnumerator*)allDocs;

@end


@interface STIGCouchViewEnumerator : NSEnumerator{

} 

@end