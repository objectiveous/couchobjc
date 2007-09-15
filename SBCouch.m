/*
Copyright (c) 2007, Stig Brautaset. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

  Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

  Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

  Neither the name of the author nor the names of its contributors may be used
  to endorse or promote products derived from this software without specific
  prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "SBCouch.h"


@implementation SBCouch

- (id)init
{
    return [self initWithEndpoint:@"http://localhost:8888/"];
}

- (id)initWithEndpoint:(NSString *)x
{
    if (!x)
        [NSException raise:@"enoendpoint" format:@"Must pass an endpoint"];

    if (self = [super init]) {
        // Make sure endpoint always ends in a slash.
        endpoint = [x hasSuffix:@"/"] ? x : [x stringByAppendingString:@"/"];
        [endpoint retain];
    }
    return self;
}

- (NSMutableURLRequest *)mutableURLRequestWithURLString:(NSString *)urlstring
{
    NSString *escaped = [urlstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:escaped];
    return [NSMutableURLRequest requestWithURL:url];
}

- (NSMutableURLRequest *)mutableURLRequestWithDatabaseName:(NSString *)dbname
{
    NSString *dbpath = [endpoint stringByAppendingFormat:@"%@/", dbname];
    return [self mutableURLRequestWithURLString:dbpath];
}

+ (id)newWithEndpoint:(NSString *)x
{
    return [[self alloc] initWithEndpoint:x];
}

- (NSString *)serverVersionString
{
    NSMutableURLRequest *request = [self mutableURLRequestWithURLString:endpoint];
    [request setHTTPMethod:@"GET"];

    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:nil];

    if (200 != [response statusCode]) {
            [NSException raise:@"unknown-error"
                        format:@"Listing databases failed with code: %u",
                            [response statusCode]];
    }

    // XXX - such.. a.. hack..
    NSString *version;
    NSString *xmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSScanner *scanner = [NSScanner scannerWithString:xmlString];

    NSCharacterSet *vsSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    if ([scanner scanUpToCharactersFromSet:vsSet intoString:nil])
        if ([scanner scanCharactersFromSet:vsSet intoString:&version])
            return version;
    return @"unknown version";
}


- (void)createDatabase:(NSString *)x
{
    NSMutableURLRequest *request = [self mutableURLRequestWithDatabaseName:x];
    [request setHTTPMethod:@"PUT"];
    
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&response
                                      error:nil];

    if (409 == [response statusCode]) {
        [NSException raise:@"db-exist"
                    format:@"The database '%@' already exist", x];

   } else if (201 != [response statusCode]) {
        [NSException raise:@"unknown-error"
                    format:@"Creating database '%@' failed with code: %u", x, [response statusCode]];
    }
}

- (void)deleteDatabase:(NSString *)x
{
    NSMutableURLRequest *request = [self mutableURLRequestWithDatabaseName:x];
    [request setHTTPMethod:@"DELETE"];

    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&response
                                      error:nil];

    if (404 == [response statusCode]) {
        [NSException raise:@"db-does-not-exist"
                    format:@"The database '%@' doesn't exist", x];

    } else if (202 != [response statusCode]) {
        [NSException raise:@"unknown-error"
                    format:@"Deleting database '%@' failed with code: %u", x, [response statusCode]];
     }
}

- (NSArray *)listDatabases
{
    NSString *all_dbs = [endpoint stringByAppendingString:@"_all_dbs"];
    NSMutableURLRequest *request = [self mutableURLRequestWithURLString:all_dbs];
    [request setHTTPMethod:@"GET"];

    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:nil];

    if (200 != [response statusCode]) {
            [NSException raise:@"unknown-error"
                        format:@"Listing databases failed with code: %u",
                            [response statusCode]];
    }
    
    NSMutableArray *dbs = [NSMutableArray array];

    // XXX - horrible hack right here.
    // XXX - It'll be gone when I get the more recent version with JSON support installed.
    NSString *xmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSScanner *scanner = [NSScanner scannerWithString:xmlString];
    do {
        NSString *dbname;
        // skip up to and including next <db> element.
        NSCharacterSet *set = [NSCharacterSet alphanumericCharacterSet];

        // Skip surrounding crap.
        [scanner scanUpToCharactersFromSet:set intoString:nil];

        // Grab the DB name, if there is one.
        if ([scanner scanCharactersFromSet:set intoString:&dbname])
            [dbs addObject:dbname];

    } while (![scanner isAtEnd]);

    return dbs;
}

- (BOOL)isDatabaseAvailable:(NSString *)x
{
    NSMutableURLRequest *request = [self mutableURLRequestWithDatabaseName:x];
    [request setHTTPMethod:@"GET"];

    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:nil];

    unsigned status = [response statusCode];
    if (200 == status)
        return YES;
    if (404 != status)
        NSLog(@"Unexpected response code (%u) from server: %@", status, request);

    return NO;
}

- (void)selectDatabase:(NSString *)x
{
    // It is possible to check if a DB exists with a GET call to the path of that DB.
    // I haven't implemented that yet. 
    if (![self isDatabaseAvailable:x])
        [NSException raise:@"select-illegal-db"
                    format:@"Cannot select '%@': database doesn't exist", x];
    
    if (currentDatabase != x) {
        [currentDatabase release];
        currentDatabase = [x retain];
    }
}


@end
