//  BBDebug.h
//
//  Created by Matt Comi on 18/05/08.
//  Copyright 2008 Big Bucket Software. All rights reserved.

#define BBTrace NSLog(@"%s", __PRETTY_FUNCTION__);

#define BBTraceInfo(s,...) \
{ \
    NSString* info = BBInfoString(s, ##__VA_ARGS__); \
    NSLog(@"%s - %@", __PRETTY_FUNCTION__, info); \
    [info release]; \
}

NSString* BBInfoString(NSString* format, ...);