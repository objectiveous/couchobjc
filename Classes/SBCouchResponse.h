//
//  SBCouchResponse.h
//  CouchObjC
//
//  Created by Stig Brautaset on 21/03/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SBCouchResponse : NSObject {
    BOOL ok;
    NSString *_id;
    NSString *rev;
}

@property (readonly) BOOL ok;
@property (readonly) NSString *id;
@property (readonly) NSString *rev;

@end
