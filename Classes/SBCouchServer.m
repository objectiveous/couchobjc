//
//  SBCouchServer.m
//  CouchObjC
//
//  Created by Stig Brautaset on 21/03/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import "SBCouchServer.h"
#import <JSON/JSON.h>

@implementation SBCouchServer

@synthesize host;
@synthesize port;

- (id)initWithHost:(NSString*)h port:(NSUInteger)p
{
    if (self = [super init]) {
        host = [h copy];
        port = p;
        
    }
    return self;
}

- (void)dealloc
{
    [host release];
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

@end
