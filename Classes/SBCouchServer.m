/*
Copyright (c) 2008, Stig Brautaset. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.

  * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

  * Neither the name of the author nor the names of its contributors may be
    used to endorse or promote products derived from this software without
    specific prior written permission.

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

#import "SBCouchServer.h"
#import "SBCouchDatabase.h"

#import <JSON/JSON.h>

@implementation SBCouchServer

@synthesize host = _host;
@synthesize port = _port;

- (id)initWithHost:(NSString*)h port:(NSUInteger)p
{
    if (self = [super init]) {
        _host = [h copy];
        _port = p;
        
    }
    return self;
}

- (void)dealloc
{
    [_host release];
    [super dealloc];
}

- (id)init
{
    return [self initWithHost:@"localhost" port:5984];
}

- (NSString*)version
{
    NSString *server = [NSString stringWithFormat:@"http://%@:%u", self.host, self.port];
    NSURL *url = [NSURL URLWithString:server];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    NSError *error;
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    
    if (data) {
        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *dict = [json JSONValue];
        return [dict valueForKey:@"version"];
    }
    
    NSLog(@"Error occured.\nError: %@\nResponse: %@", error, response);
    return nil;
}

- (BOOL)createDatabase:(NSString*)db
{
    NSString *escaped = [db stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *server = [NSString stringWithFormat:@"http://%@:%u/%@", self.host, self.port, escaped];
    NSURL *url = [NSURL URLWithString:server];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"PUT"];
    
    NSError *error;
    NSHTTPURLResponse *response;
    (void)[NSURLConnection sendSynchronousRequest:request
                                returningResponse:&response
                                            error:&error];

    return 201 == [response statusCode];
}

- (BOOL)deleteDatabase:(NSString*)db
{
    NSString *escaped = [db stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *server = [NSString stringWithFormat:@"http://%@:%u/%@", self.host, self.port, escaped];
    NSURL *url = [NSURL URLWithString:server];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"DELETE"];
    
    NSError *error;
    NSHTTPURLResponse *response;
    (void)[NSURLConnection sendSynchronousRequest:request
                                returningResponse:&response
                                            error:&error];
    
    return 202 == [response statusCode];
}

- (NSArray*)listDatabases
{
    NSString *server = [NSString stringWithFormat:@"http://%@:%u/_all_dbs", self.host, self.port];
    NSURL *url = [NSURL URLWithString:server];    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSError *error;
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    
    if (200 == [response statusCode]) {
        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return [json JSONValue];
    }
    
    return nil;    
}

- (SBCouchDatabase*)database:(NSString*)name
{
    return [[[SBCouchDatabase alloc] initWithServer:self name:name] autorelease];
}

@end
