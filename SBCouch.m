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
        [NSException raise:@"no-endpoint" format:@"Must pass an endpoint"];

    if (self = [super init]) {
        // Make sure endpoint always ends in a slash.
        endpoint = [x hasSuffix:@"/"] ? x : [x stringByAppendingString:@"/"];
        [endpoint retain];
    }
    return self;
}

- (NSMutableURLRequest *)requestWithDatabase:(NSString *)database
{
    NSString *path = database
        ? [endpoint stringByAppendingFormat:@"%@/", database]
        : [endpoint stringByAppendingString:@"$all_dbs"];
    NSString *escaped = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:escaped];
    return [NSMutableURLRequest requestWithURL:url];
}

+ (id)newWithEndpoint:(NSString *)x
{
    return [[self alloc] initWithEndpoint:x];
}

- (void)createDatabase:(NSString *)x
{
    NSMutableURLRequest *request = [self requestWithDatabase:x];
    [request setHTTPMethod:@"PUT"];
    
    NSError *error;
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&response
                                      error:&error];

    switch ([response statusCode]) {
        case 201:   // Success.
            break;
        case 409:   // Already exists.
            [NSException raise:@"db-exists"
                        format:@"The database '%@' already exists", x];
            break;
        default:
            [NSException raise:@"unknown-error"
                        format:@"Creating database '%@' failed with code: %lu", x, [response statusCode]];
            break;
    }
}

- (void)deleteDatabase:(NSString *)x
{
    NSMutableURLRequest *request = [self requestWithDatabase:x];
    [request setHTTPMethod:@"DELETE"];

    NSError *error;
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&response
                                      error:&error];

    switch ([response statusCode]) {
        case 202:   // Success.
            break;
        case 404:   // Doesn't exists.
            [NSException raise:@"db-does-not-exist"
                        format:@"The database '%@' doesn't exist", x];
            break;
        default:
            [NSException raise:@"unknown-error"
                        format:@"Creating database '%@' failed with code: %u", x, [error code]];
            break;
    }
}

- (NSArray *)listDatabases
{
    NSMutableURLRequest *request = [self requestWithDatabase:nil];
    [request setHTTPMethod:@"GET"];

    NSError *error;
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];

    if (200 != [response statusCode]) 
            [NSException raise:@"unknown-error"
                        format:@"Listing databases failed with code: %u (%@)",
                            [response statusCode], error];

    NSMutableArray *dbs = [NSMutableArray array];

    // XXX - horrible hack right here.
    // XXX - It'll be gone when I get the more recent version with JSON support installed.
    NSString *xmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSScanner *scanner = [NSScanner scannerWithString:xmlString];
    do {
        // skip up to and including next <db> element.
        if ([scanner scanUpToString:@"<db>" intoString:nil])
            [scanner scanString:@"<db>" intoString:nil];
        // Grab the DB name.
        NSString *dbname;
        if ([scanner scanUpToString:@"/</db>" intoString:&dbname])
            [dbs addObject:dbname];
    } while (![scanner isAtEnd]);

    return dbs;
}

@end
