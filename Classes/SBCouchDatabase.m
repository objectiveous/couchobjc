//
//  SBCouchDatabase.m
//  CouchObjC
//
//  Created by Stig Brautaset on 21/03/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import "SBCouchServer.h"
#import "SBCouchDatabase.h"
#import "SBCouchResponse.h"
#import "NSDictionary+CouchObjC.h"

#import <JSON/JSON.h>

@implementation SBCouchDatabase

@synthesize name;

- (id)initWithServer:(SBCouchServer*)s name:(NSString*)n
{
    if (self = [super init]) {
        server = [s retain];
        name = [n copy];
    }
    return self;
}

- (void)dealloc
{
    [server release];
    [name release];
    [super dealloc];
}

- (id)get:(NSString*)args
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@:%u/%@/%@", server.host, server.port, self.name, args];
    NSURL *url = [NSURL URLWithString:urlString];    
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

- (id)postDocument:(NSDictionary*)doc
{
    NSData *body = [[doc JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"http://%@:%u/%@/", server.host, server.port, self.name];
    NSURL *url = [NSURL URLWithString:urlString];    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];    
    [request setHTTPBody:body];
    [request setHTTPMethod:@"POST"];
    
    NSError *error;
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    
    if (201 == [response statusCode]) {
        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return [[SBCouchResponse alloc] initWithDictionary:[json JSONValue]];
    }
    
    return nil;    
}

- (id)putDocument:(NSDictionary*)doc withId:(NSString*)x
{
    NSData *body = [[doc JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"http://%@:%u/%@/%@", server.host, server.port, self.name, x];
    NSURL *url = [NSURL URLWithString:urlString];    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];    
    [request setHTTPBody:body];
    [request setHTTPMethod:@"PUT"];
    
    NSError *error;
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    
    if (201 == [response statusCode]) {
        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return [[SBCouchResponse alloc] initWithDictionary:[json JSONValue]];
    }
    
    return nil;    
}

- (id)deleteDocument:(NSDictionary*)doc
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@:%u/%@/%@?rev=%@", server.host, server.port, self.name, doc.id, doc.rev];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];    
    [request setHTTPMethod:@"DELETE"];
    
    NSError *error;
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    
    if (202 == [response statusCode]) {
        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return [[SBCouchResponse alloc] initWithDictionary:[json JSONValue]];
    }
    
    return nil;
}

@end
