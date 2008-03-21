//
//  NSMutableDictionary+CouchObjC.h
//  CouchObjC
//
//  Created by Stig Brautaset on 21/03/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSMutableDictionary (NSMutableDictionary_CouchObjC)

- (NSString*)id;
- (void)setId:(NSString*)id;

- (NSString*)rev;
- (void)setRev:(NSString*)rev;

- (NSDictionary*)attachments;
- (void)addAttachmentNamed:(NSString*)name ofType:(NSString*)type data:(id)data;

@end
