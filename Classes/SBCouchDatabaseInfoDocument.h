//
//  SBCouchDatabaseInfoDocument.h
//  CouchObjC
//
//  Created by Robert Evans on 3/29/09.
//  Copyright 2009 South And Valley. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SBCouchDocument.h"


@interface SBCouchDatabaseInfoDocument : SBCouchDocument {

}

@property (readonly) NSString *db_name;
@property (readonly) NSString *doc_count;
@property (readonly) NSString *doc_del_count;
@property (readonly) NSString *update_seq;
@property (readonly) NSString *purge_seq;
@property (readonly) NSString *compact_running;
@property (readonly) NSString *disk_size;
@property (readonly) NSString *instance_start_time;

@end
