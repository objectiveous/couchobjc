//
//  SBCouchQueryOptions.h
//  CouchObjC
//
//  Created by Robert Evans on 3/5/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SBCouchQueryOptions : NSObject <NSCopying> {
    // http://wiki.apache.org/couchdb/HTTP_view_API?action=show&redirect=HttpViewApi
    // GET
    NSString  *key;              //keyvalue
    NSString  *startkey;         //keyvalue
    NSString  *startkey_docid;   //docid
    NSString  *endkey;           //keyvalue
    NSString  *endkey_docid;     //docid
    NSInteger limit;             //max rows to return This used to be called "count" previous to Trunk SVN r731159
    BOOL      stale;             //ok
    BOOL      descending;        //true
    NSInteger skip;              //number of rows to skip
    BOOL      group;             //true Version 0.8.0 and forward
    NSInteger group_level;       //int
    BOOL      reduce;            //false Trunk only (0.9)
    BOOL      include_docs;      //true Trunk only (0.9)
    BOOL      revs_info;         //
    //POST
    //{"keys": ["key1", "key2", ...]} Trunk only (0.9)    
}

@property (retain) NSString  *key;
@property (retain) NSString  *startkey;
@property (retain) NSString  *startkey_docid;
@property (retain) NSString  *endkey;
@property (retain) NSString  *endkey_docid;
@property          NSInteger limit;
@property          BOOL      stale;
@property          BOOL      descending;
@property          NSInteger skip;
@property          BOOL      group;
@property          NSInteger group_level;
@property          BOOL      reduce;
@property          BOOL      include_docs;
@property          BOOL      revs_info;

-(NSString*) queryString;

@end
