//
//  Document.m
//  CouchObjC
//
//  Created by Stig Brautaset on 21/03/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import "Document.h"
#import <CouchObjC/CouchObjC.h>

@implementation Document

- (void)setUp {
    doc = [NSMutableDictionary new];
}

- (void)tearDown {
    [doc release];
}

- (void)testId {
    STAssertNil([doc id], nil);
    [doc setId:@"testing 123"];
    STAssertNotNil([doc id], nil);
}

- (void)testRev {
    STAssertNil([doc rev], nil);
    [doc setRev:@"testing 123"];
    STAssertNotNil([doc rev], nil);
}

- (void)testAttachment {
    STAssertNil([doc attachments], nil);
    NSDictionary *attachments;
    
    [doc addAttachmentNamed:@"foo.txt" ofType:@"text/plain" data:@"foo bar quux"];
    attachments = [doc attachments];
    STAssertEquals([attachments count], (NSUInteger)1, nil);

    [doc addAttachmentNamed:@"bar.txt" ofType:@"text/plain" data:@"foo bar quux"];
    attachments = [doc attachments];
    STAssertEquals([attachments count], (NSUInteger)2, nil);

    [doc addAttachmentNamed:@"foo.txt" ofType:@"text/plain" data:@"quux quux"];
    attachments = [doc attachments];
    STAssertEquals([attachments count], (NSUInteger)2, @"overwrote the existing one");
}

@end
