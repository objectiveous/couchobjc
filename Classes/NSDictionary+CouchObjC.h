//
//  NSMutableDictionary+CouchObjC.h
//  CouchObjC
//
//  Created by Stig Brautaset on 21/03/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSDictionary (NSDictionary_CouchObjC)

- (NSString*)id;
- (NSString*)rev;
- (NSDictionary*)attachments;

@end

@interface NSMutableDictionary (NSMutableDictionary_CouchObjC)

- (void)setId:(NSString*)id;
- (void)setRev:(NSString*)rev;
- (void)addAttachmentNamed:(NSString*)name ofType:(NSString*)type data:(id)data;

@end
