//
//  SBCouchDatabase.m
//  CouchObjC
//
//  Created by Stig Brautaset on 21/03/2008.
//  Copyright 2008 Stig Brautaset. All rights reserved.
//

#import "SBCouchDatabase.h"
#import "SBCouchServer.h"

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

@end
