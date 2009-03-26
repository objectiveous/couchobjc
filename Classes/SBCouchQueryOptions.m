//
//  SBCouchQueryOptions.m
//  CouchObjC
//
//  Created by Robert Evans on 3/5/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import "SBCouchQueryOptions.h"

// XXX Perhapse these should be global and have a prefix 
//     like COUCH_QUERY_OPTIONS_
static NSString const *INCLUDE_DOCS   = @"include_docs";
static NSString const *KEY            = @"key";
static NSString const *STARTKEY       = @"startkey";
static NSString const *STARTKEY_DOCID = @"startkey_docid";
static NSString const *ENDKEY         = @"endkey";
static NSString const *ENDKEY_DOCID   = @"endkey_docid";
static NSString const *LIMIT          = @"limit";
static NSString const *STALE          = @"stale";
static NSString const *DESCENDING     = @"descending";
static NSString const *SKIP           = @"skip";
static NSString const *GROUP          = @"group";
static NSString const *GROUP_LEVEL    = @"group_level";
static NSString const *REDUCE         = @"reduce";
static NSString const *REVS_INFO      = @"revs_info";

@implementation SBCouchQueryOptions

@synthesize key;
@synthesize startkey;
@synthesize startkey_docid;
@synthesize endkey;
@synthesize endkey_docid;
@synthesize limit;
@synthesize stale;
@synthesize descending;
@synthesize skip;
@synthesize group;
@synthesize group_level;
@synthesize reduce;
@synthesize include_docs;
@synthesize revs_info; 

-(void)dealloc{
    self.key = nil;
    self.startkey = nil;
    self.startkey_docid = nil;
    self.endkey = nil;
    self.endkey_docid = nil;
    [super dealloc];
}

- (NSString*)description{
    return [self queryString];
}

// XXX BOOL values should probably not default to true. We are assuming to much. 
- (NSString*) queryString{
    NSMutableString *queryString = [NSMutableString new];
    NSString *stringFormat = @"&%@=\"%@\"";
    NSString *intFormat = @"&%@=%i";
    NSString *boolFormat = @"&%@=true";

    if(self.key)
        [queryString appendFormat:stringFormat, KEY, self.key];
    
    if(self.startkey)
        [queryString appendFormat:stringFormat, STARTKEY, self.startkey];

    if(self.startkey_docid)
        [queryString appendFormat:stringFormat, STARTKEY_DOCID, self.startkey_docid];

    if(self.endkey)
        [queryString appendFormat:stringFormat, ENDKEY, self.endkey];

    if(self.endkey_docid)
        [queryString appendFormat:stringFormat, ENDKEY_DOCID, self.endkey_docid];
    
    if(self.limit)
        [queryString appendFormat:intFormat, LIMIT, self.limit];
    
    if(self.stale)
        [queryString appendFormat:boolFormat, STALE];  
    
    if(self.descending)
        [queryString appendFormat:boolFormat, DESCENDING];
    
    if(self.skip)
        [queryString appendFormat:intFormat, SKIP, self.skip];
    
    if(self.group)
        [queryString appendFormat:boolFormat, GROUP];
    
    if(self.group_level)
        [queryString appendFormat:intFormat, GROUP_LEVEL, self.group_level];
    
    if(self.reduce)
        [queryString appendFormat:boolFormat, REDUCE];
    
    if(self.include_docs)
        [queryString appendFormat:boolFormat, INCLUDE_DOCS];

    if(self.revs_info)
        [queryString appendFormat:boolFormat, REVS_INFO];
    
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"&"];
    return [queryString stringByTrimmingCharactersInSet:characterSet];
}
// XXX Is there a better way?
- (id)copyWithZone:(NSZone *)zone{
    SBCouchQueryOptions *clone =
    [[[self class] allocWithZone:zone] init];
    
    clone.key            = self.key;
    clone.startkey       = self.startkey;
    clone.startkey_docid = self.startkey_docid;
    clone.endkey         = self.endkey;
    clone.endkey_docid   = self.endkey_docid;
    clone.limit          = self.limit;
    clone.stale          = self.stale;
    clone.descending     = self.descending;
    clone.skip           = self.skip;
    clone.group          = self.group;
    clone.group_level    = self.group_level;
    clone.reduce         = self.reduce;
    clone.include_docs   = self.include_docs;
    clone.revs_info      = self.revs_info;
    
    return  clone;
}
@end
