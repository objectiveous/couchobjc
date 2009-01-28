//
//  CouchObjC.h
//  CouchObjC
//
//  Created by Stig Brautaset on 21/03/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import <CouchObjC/SBCouchServer.h>
#import <CouchObjC/SBCouchDatabase.h>
#import <CouchObjC/SBCouchResponse.h>
#import <CouchObjC/NSDictionary+CouchObjC.h>
#import <CouchObjC/SBCouchEnumerator.h>
#import <CouchObjC/SBCouchDatabase+View.h>
#import <CouchObjC/SBCouchDocument.h>
#import <CouchObjC/SBOrderedDictionary.h>

#include <asl.h>

/*
 Send logging information to syslog and use the console to filter out what you need. 
 Be sure to adjust the filters if you want DEBUG and INFO
 
    sudo syslog -c syslogd -d
    sudo syslog -c 0 -d
 
 You can test that DEBUG messages are being displayed in the console by issuing
 
    syslog -s -l 6 "WTF ***"
 
 You may need to bounce syslogd as it seems to get wedged

    sudo launchctl unload /System/Library/LaunchDaemons/com.apple.syslogd.plist
    sudo launchctl load /System/Library/LaunchDaemons/com.apple.syslogd.plist
 
 The DEBUG Flag
 --------------
 Add "DEBUG=1" to your "extra preprocessor defines" for your Debug target, so assertions are quiet in the Release target.
 In Xcode's "Debug" configuration, in the "Preprocessing" collection set the "Preprocessor Macros" value to "DEBUG=1"
 In your project or target build settings set "OTHER_CFLAGS" to "$(value) -DDEBUG=1" for the "Debug" configuration.
 http://developer.apple.com/qa/qa2006/qa1431.html
 */


#ifdef DEBUG

#define STIGLog(level, format, ...){ \
aslmsg m = asl_new(ASL_TYPE_MSG); \
asl_set(m, ASL_KEY_FACILITY, __PRETTY_FUNCTION__); \
asl_log(NULL, m, level, "%s", [[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String]); \
asl_log(NULL, m, level, "%s", [[NSString stringWithFormat:[NSString stringWithFormat:@"%s %@", __PRETTY_FUNCTION__, format], ##__VA_ARGS__] UTF8String]); \
}

#define STIGDebug(format, ...){ \
aslmsg msg = asl_new(ASL_TYPE_MSG); \
asl_set(msg, ASL_KEY_FACILITY, "CouchObjC"); \
asl_log(NULL, msg, ASL_LEVEL_DEBUG, "%s", [[NSString stringWithFormat:[NSString stringWithFormat:@"%s %@", __PRETTY_FUNCTION__,format], ##__VA_ARGS__] UTF8String]); \
}

#define STIGInfo(format, ...){ \
aslmsg msg = asl_new(ASL_TYPE_MSG); \
asl_set(msg, ASL_KEY_FACILITY, __PRETTY_FUNCTION__); \
asl_log(NULL, msg, ASL_LEVEL_INFO, "%s", [[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String]); \
asl_log(NULL, msg, ASL_LEVEL_INFO, "%s", [[NSString stringWithFormat:[NSString stringWithFormat:@"%s %@", __PRETTY_FUNCTION__, format], ##__VA_ARGS__] UTF8String]); \
}


#else

#define STIGDebug(format, ...){}
#define STIGInfo(format, ...){}
#define STIGLog(level, format, ...){}

#endif
