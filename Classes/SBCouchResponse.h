//
//  SBCouchResponse.h
//  CouchObjC
//
//  Created by Stig Brautaset on 21/03/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/// Encapsulates a response from SBCouchDatabase.
@interface SBCouchResponse : NSObject {
    BOOL ok;
    NSString *name;
    NSString *rev;
}

/// Whether the operation succeeded.
@property (readonly) BOOL ok;

/// The id of the new/updated document.
@property (readonly) NSString *name;

/// The new revision id.
@property (readonly) NSString *rev;

@end
