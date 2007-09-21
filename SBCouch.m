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
    return [self initWithHost:@"localhost" port:8888];
}

- (id)initWithHost:(NSString *)newHost port:(unsigned)newPort
{
    if (!(newHost && newPort))
        [NSException raise:@"enoendpoint" format:@"Must pass host & port for endpoint"];

    if (self = [super init]) {
        host = [newHost retain];
        port = newPort;
    }
    return self;
}

+ (id)newWithHost:(NSString *)h port:(unsigned)p
{
    return [[self alloc] initWithHost:h port:p];
}

#pragma mark Private

- (NSString *)serverURL
{
    return [NSString stringWithFormat:@"http://%@:%u/", host, port];
}

- (NSString *)databaseURL:(NSString *)x
{
    return [[self serverURL] stringByAppendingFormat:@"%@/", x];
}

- (NSString *)curDbURL
{
    return [self databaseURL:currentDatabase];
}

- (NSString *)docURL:(NSString *)doc
{
    return [[self curDbURL] stringByAppendingString:doc];
}

- (NSMutableURLRequest *)requestWithURLString:(NSString *)urlstring
{
    NSString *escaped = [urlstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSMutableURLRequest requestWithURL:[NSURL URLWithString:escaped]];
}

- (id)performRequest:(NSMutableURLRequest *)request
              method:(NSString *)method
                body:(id)body
   returningResponse:(NSHTTPURLResponse **)response
{
    [request setHTTPMethod:method];
    if (body)
        [request setHTTPBody:body];
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:response
                                                     error:nil];
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [json objectFromJSON];
}

- (id)performRequest:(NSMutableURLRequest *)request
              method:(NSString *)method
   returningResponse:(NSHTTPURLResponse **)response
{
    return [self performRequest:request method:method body:nil returningResponse:response];
}

#pragma mark Server

- (NSString *)serverVersion
{
    NSMutableURLRequest *request = [self requestWithURLString:[self serverURL]];
    NSHTTPURLResponse *response;
    NSDictionary *dict = [self performRequest:request method:@"GET" returningResponse:&response];

    if (200 != [response statusCode]) {
            [NSException raise:@"unknown-error"
                        format:@"Server version query failed with code: %u",
                            [response statusCode]];
    }

    return [dict valueForKey:@"version"];
}

#pragma mark Database

- (void)createDatabase:(NSString *)x
{
    NSMutableURLRequest *request = [self requestWithURLString:[self databaseURL:x]];
    NSHTTPURLResponse *response;
    (void)[self performRequest:request method:@"PUT" returningResponse:&response];

    if (409 == [response statusCode]) {
        [NSException raise:@"edbexists"
                    format:@"The database '%@' already exist", x];

   } else if (201 != [response statusCode]) {
        [NSException raise:@"unknown-error"
                    format:@"Creating database '%@' failed with code: %u", x, [response statusCode]];
    }
}

- (void)deleteDatabase:(NSString *)x
{
    NSMutableURLRequest *request = [self requestWithURLString:[self databaseURL:x]];
    NSHTTPURLResponse *response;
    (void)[self performRequest:request method:@"DELETE" returningResponse:&response];

    if (404 == [response statusCode]) {
        [NSException raise:@"enodatabase"
                    format:@"The database '%@' doesn't exist", x];

    } else if (202 != [response statusCode]) {
        [NSException raise:@"unknown-error"
                    format:@"Deleting database '%@' failed with code: %u", x, [response statusCode]];
     }
}

- (NSArray *)listDatabases
{
    NSString *all_dbs = [[self serverURL] stringByAppendingString:@"_all_dbs"];
    NSMutableURLRequest *request = [self requestWithURLString:all_dbs];
    NSHTTPURLResponse *response;
    NSArray *dbs = [self performRequest:request method:@"DELETE" returningResponse:&response];

    if (200 != [response statusCode]) {
            [NSException raise:@"unknown-error"
                        format:@"Listing databases failed with code: %u",
                            [response statusCode]];
    }

    return dbs;
}

- (NSDictionary *)databaseMeta:(NSString *)x
{
    NSMutableURLRequest *request = [self requestWithURLString:[self databaseURL:x]];
    NSHTTPURLResponse *response;
    NSDictionary *ret = [self performRequest:request method:@"GET" returningResponse:&response];

    if (200 == [response statusCode])
        return ret;
    if (404 != [response statusCode])
        NSLog(@"Unexpected response code (%u) from server: %@", [response statusCode], request);

    return nil;
}

- (void)selectDatabase:(NSString *)x
{
    // It is possible to check if a DB exists with a GET call to the path of that DB.
    // I haven't implemented that yet. 
    if (![self databaseMeta:x])
        [NSException raise:@"enodatabase"
                    format:@"Cannot select '%@': database doesn't exist", x];
    
    if (currentDatabase != x) {
        [currentDatabase release];
        currentDatabase = [x retain];
    }
}


#pragma mark Document

- (NSDictionary *)saveDocument:(NSDictionary *)x
{
    NSMutableURLRequest *request = [self requestWithURLString:[self curDbURL]];
    NSHTTPURLResponse *response;
    NSDictionary *r = [self performRequest:request
                                    method:@"POST"
                                      body:[[x JSONString] dataUsingEncoding:NSUTF8StringEncoding]
                         returningResponse:&response];

    if (201 != [response statusCode]) {
            [NSException raise:@"unknown-error"
                        format:@"Saving document failed with code: %u", [response statusCode]];
    }

    NSMutableDictionary *y = [NSMutableDictionary dictionaryWithDictionary:x];
    [y setObject:[r objectForKey:@"_id"] forKey:@"_id"];
    [y setObject:[r objectForKey:@"_rev"] forKey:@"_rev"];
    return y;
}

- (NSDictionary *)retrieveDocument:(NSString *)x
{
    NSMutableURLRequest *request = [self requestWithURLString:[self docURL:x]];
    NSHTTPURLResponse *response;
    NSDictionary *dict = [self performRequest:request method:@"GET" returningResponse:&response];

    if (404 == [response statusCode]) {
        [NSException raise:@"notfound"
                    format:@"Document %@ not found", x];
    
    } else if (200 != [response statusCode]) {
            [NSException raise:@"unknown-error"
                       format:@"Retrieving document failed with code: %u",
                            [response statusCode]];
    }

    return dict;
}

- (NSDictionary *)listDocuments
{
    NSString *all_docs = [[self curDbURL] stringByAppendingString:@"_all_docs"];
    NSMutableURLRequest *request = [self requestWithURLString:all_docs];
    NSHTTPURLResponse *response;
    NSDictionary *dict = [self performRequest:request method:@"GET" returningResponse:&response];

    if (200 != [response statusCode]) {
            [NSException raise:@"unknown-error"
                        format:@"Listing documents failed with code: %u",
                            [response statusCode]];
    }

    return dict;
}

#pragma mark View

- (NSDictionary *)listDocumentsInView:(NSString *)x
{
    NSMutableURLRequest *request = [self requestWithURLString:[self docURL:x]];
    NSHTTPURLResponse *response;
    NSDictionary *dict = [self performRequest:request method:@"GET" returningResponse:&response];

    if (404 == [response statusCode]) {
        [NSException raise:@"notfound"
                    format:@"View %@ not found", x];
    
    } else if (200 != [response statusCode]) {
        [NSException raise:@"unknown-error"
                    format:@"Listing documents in view %@ failed with code: %u",
                        x, [response statusCode]];
    }

    return dict;
}

@end
