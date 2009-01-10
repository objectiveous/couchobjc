//  BBDebug.m
//
//  Created by Matt Comi on 18/05/08.
//  Copyright 2008 Big Bucket Software. All rights reserved.

#import "BBDebug.h"

NSString* BBInfoString(NSString* format, ...)
{
    va_list args;
    
    va_start(args, format);
    
    NSString* info = 
        [[NSString alloc] initWithFormat:format arguments:args];
    
    va_end(args);
    
    return info;
}