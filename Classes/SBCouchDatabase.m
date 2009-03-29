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
#import "SBCouchResponse.h"
#import "NSDictionary+CouchObjC.h"
#import "SBCouchDocument.h"

#import <JSON/JSON.h>
#import "CouchObjC.h"

@interface SBCouchDatabase (Private)
   -(NSString*)contructURL:(NSString*)withRevisionCount:(BOOL)withCount andInfo:(BOOL)andInfo revision:(NSString*)revisionOrNil;
@end 

@implementation SBCouchDatabase

@synthesize name;
@synthesize couchServer;

- (id)initWithServer:(SBCouchServer*)s name:(NSString*)n
{
    if (self = [super init]) {
        couchServer = [s retain];
        name = [n copy];
    }
    return self;
}

- (void)dealloc
{
    [couchServer release];
    [name release];
    [super dealloc];
}


#pragma mark -
#pragma mark GET Document Calls
#pragma mark methods that return collections
-(NSEnumerator*) allDocs{
    NSDictionary *list = [self get:@"_all_docs"];
    
    return [[list objectForKey:@"rows"] objectEnumerator];
    //return [[[STIGCouchViewEnumerator alloc] init] autorelease];
}
- (NSEnumerator*)viewEnumerator:(SBCouchView*)view{
    return [[[SBCouchEnumerator alloc] initWithView:view] autorelease];
}

-(NSEnumerator*) getViewEnumerator:(NSString*)viewId{
    //NSString *url = [self constructURL:viewId withRevisionCount:NO andInfo:NO revision:nil];
    
    SBCouchView *view = [[SBCouchView alloc] initWithName:viewId];
    SBCouchEnumerator *enumerator = [[[SBCouchEnumerator alloc] initWithView:view] autorelease];
    return (NSEnumerator*)enumerator;    
}

-(NSEnumerator*)allDocsInBatchesOf:(NSInteger)count{
    SBCouchQueryOptions *queryOptions = [SBCouchQueryOptions new];
    queryOptions.limit = count;
    SBCouchView *view = [[SBCouchView alloc] initWithName:@"_all_docs" couchDatabase:self queryOptions:queryOptions ];
    SBCouchEnumerator *enumerator = [[[SBCouchEnumerator alloc] initWithView:view] autorelease];    
    return (NSEnumerator*)enumerator;
}
- (NSEnumerator*)getDesignDocuments{
    //NSString *url = @"_all_docs?group=true&startkey=\"_design\"&endkey=\"_design0\"";
    SBCouchQueryOptions *options = [SBCouchQueryOptions new];
    options.group = YES;
    options.startkey = @"_design";
    options.endkey = @"_design0";
    options.include_docs = YES;

    SBCouchView *view = [[SBCouchView alloc] initWithName:@"_all_docs" couchDatabase:self queryOptions:options ];
    
    SBCouchEnumerator *enumerator = [[[SBCouchEnumerator alloc] initWithView:view] autorelease];
    
    return (NSEnumerator*)enumerator;
}
- (SBCouchView*)designDocumentsView{
    SBCouchQueryOptions *queryOptions = [SBCouchQueryOptions new];
    queryOptions.startkey = @"_design";
    queryOptions.endkey = @"_design0";
    queryOptions.include_docs = YES;
    //queryOptions.revs_info = YES;

    return [[[SBCouchView alloc] initWithName:@"_all_docs" couchDatabase:self queryOptions:queryOptions] autorelease];
}


#pragma mark methods that return docs

/**
 You can use this to query database information by simply passing an empty string. You can also
 get documents, by passing the document names (ids).
 
 @code
 // retrieve a document
 NSDictionary *doc = [db get:@"document_name"];
 
 // get a list of all documents
 NSDictionary *list = [db get:@"_all_docs"];
 @endcode
 */
- (NSDictionary*)get:(NSString*)args
{
    //assert(self.name);
    NSString *urlString = [NSString stringWithFormat:@"http://%@:%u/%@/%@", couchServer.host, couchServer.port, self.name, args];

    NSString *encodedString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSURL *url = [NSURL URLWithString:encodedString];   
   
    STIGDebug(@"HTTP GET :  %@",  encodedString );
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSError *error;
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    
    SBDebug(@" URL Status Code %i", [response statusCode]);
    if (200 == [response statusCode]) {
        NSString *json = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        return [json JSONValue];
    }else{
        SBDebug(@"HTTP GET FAILED:  %@",  encodedString );
        SBDebug(@"        STATUS CODE %i",  [response statusCode]);
    }
    
    return nil;
}


- (SBCouchDesignDocument*)getDesignDocument:(NSString*)docId{
    return [self getDesignDocument:docId withRevisionCount:NO andInfo:NO revision:nil];
}


- (SBCouchDesignDocument*)getDesignDocument:(NSString*)docId withRevisionCount:(BOOL)withCount andInfo:(BOOL)andInfo revision:(NSString*)revisionOrNil{
    NSString *docWithRevArgument = [self constructURL:docId withRevisionCount:withCount andInfo:andInfo revision:revisionOrNil];
        
    NSDictionary *dict = [self get:docWithRevArgument];
    SBCouchDesignDocument *designDoc = [[[SBCouchDesignDocument  alloc] initWithNSDictionary:dict couchDatabase:self] autorelease];

    return designDoc;
}

/**
 ?revs=true but might want to use revs_info=true and peek into the 
 status field to figure out what to do. 
 */
- (SBCouchDocument*)getDocument:(NSString*)docId withRevisionCount:(BOOL)withCount andInfo:(BOOL)andInfo revision:(NSString*)revisionOrNil
{

    NSString *docWithRevArgument = [self constructURL:docId withRevisionCount:withCount andInfo:andInfo revision:revisionOrNil];
    
    STIGDebug(@"Document URL  %@", docWithRevArgument);
    
    NSMutableDictionary *mutable = [NSMutableDictionary dictionaryWithDictionary:[self get:docWithRevArgument]];
    
    SBCouchDocument *couchDocument = [[[SBCouchDocument alloc] initWithNSDictionary:mutable couchDatabase:self] autorelease];
    
    //XXX This was sorta dumb. Hold reference to the actual database costs less 
    //    than these two strings and since SBCouchDabase holds not real resources, 
    //    it's just dumb not to use it. 
    //[couchDocument setServerName:[couchServer serverURLAsString]];
    //[couchDocument setDatabaseName:[self name]];

    couchDocument.couchDatabase = self;
    return couchDocument;
}

#pragma mark -
#pragma mark PUT and POST Calls

- (NSEnumerator*)slowViewEnumerator:(SBCouchView*)view{
    SBCouchEnumerator *enumerator = [[[SBCouchEnumerator alloc] initWithView:view] autorelease];
    
    return (NSEnumerator*)enumerator;
}

- (NSDictionary*)runSlowView:(SBCouchView*)view{    
    //[NSString stringWithFormat:@"", COUCH_VIEW_SLOW, view]
    //return [self postDocument:view];
    NSString *tempView = [view JSONRepresentation];
    NSData *body = [tempView dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *urlString;
    if(view.queryOptions)
        urlString = [NSString stringWithFormat:@"http://%@:%u/%@/%@?%@", couchServer.host, couchServer.port, self.name, @"_temp_view", [view.queryOptions queryString]];
    else
        urlString = [NSString stringWithFormat:@"http://%@:%u/%@/%@", couchServer.host, couchServer.port, self.name, @"_temp_view"];

    
    NSString *encodedURL = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:encodedURL];
    SBDebug(@"Encoded URL : %@" , encodedURL);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url]; 
    
    [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:body];
    [request setHTTPMethod:@"POST"];
    
    NSError *error;
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    SBDebug(@"status code %i", [response statusCode]);
    SBDebug(@"headers %@", [[response allHeaderFields] JSONRepresentation]);
    
    if (200 == [response statusCode]) {
        NSString *json = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        // The following makes no sense in this context as there is no 'ok' value 
        // in the dictionary.
        //return [[SBCouchResponse alloc] initWithDictionary:[json JSONValue]];
        return [json JSONValue];
    }else{
        SBDebug(@"HTTP POST FAILED:  %@",  encodedURL  );
        SBDebug(@"        STATUS CODE %i",  [response statusCode]);
        
    }
    return nil;
}

- (SBCouchResponse*)createDocument:(SBCouchDesignDocument*)doc{
    return [self putDocument:doc named:doc.identity];
}

/**
 Use this method to create documents when you don't care what their names (ids) will be.
 */
- (SBCouchResponse*)postDocument:(NSDictionary*)doc
{
    NSData *body = [[doc JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"http://%@:%u/%@/", couchServer.host, couchServer.port, self.name];
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
        NSString *json = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        return [[[SBCouchResponse alloc] initWithDictionary:[json JSONValue]] autorelease];
    }else{
        SBDebug(@"HTTP POST FAILED:  %@",  urlString );
        SBDebug(@"        STATUS CODE %i",  [response statusCode]);
        
    }
    
    return nil;    
}

/**
 Use this method to create documents with a particular name, or updating documents.
 */
- (SBCouchResponse*)putDocument:(NSDictionary*)doc named:(NSString*)x
{
    NSData *body = [[doc JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"http://%@:%u/%@/%@", couchServer.host, couchServer.port, self.name, x];
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
        NSString *json = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        return [[[SBCouchResponse alloc] initWithDictionary:[json JSONValue]] autorelease];
    }else{
        SBDebug(@"HTTP PUT FAILED:  %@",  urlString);
        SBDebug(@"        STATUS CODE %i",  [response statusCode]);
        
    }
    
    return nil;    
}

- (SBCouchResponse*)putDocument:(SBCouchDocument*)couchDocument
{
    
    NSData *body = [[couchDocument JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"http://%@:%u/%@/%@", couchServer.host, couchServer.port, self.name, [couchDocument identity]];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];    
    SBDebug(@"%@", urlString);
    SBDebug(@"%@", [couchDocument JSONRepresentation]);
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];    
    [request setHTTPBody:body];
    [request setHTTPMethod:@"PUT"];
    
    NSError *error;
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    
    if (201 == [response statusCode]) {
        NSString *json = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        NSDictionary *jsonValue = [json JSONValue];
        [couchDocument setRevision:[jsonValue objectForKey:@"rev"]];
        return [[[SBCouchResponse alloc] initWithDictionary:jsonValue] autorelease];
    }else{
        SBDebug(@"HTTP PUT FAILED:  %@", urlString);
        SBDebug(@"        STATUS CODE %i",  [response statusCode]);

    }
    return nil;        
}


#pragma mark -
#pragma mark DELETE Calls

/**
 This method extracts the name and revision from the document and attempts to delete that.
 */
- (SBCouchResponse*)deleteDocument:(NSDictionary*)doc
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@:%u/%@/%@?rev=%@", couchServer.host, couchServer.port, self.name, doc.name, doc.rev];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];    
    [request setHTTPMethod:@"DELETE"];
    
    NSError *error;
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    // 412 == conflict
    // 200 == OK
    SBDebug(@"response code from the delete %i", [response statusCode]);
    if (200 == [response statusCode]) {
        NSString *json = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        return [[[SBCouchResponse alloc] initWithDictionary:[json JSONValue]] autorelease];
    }
    
    return nil;
}
#pragma mark -
-(NSString*)constructURL:(NSString*)docId withRevisionCount:(BOOL)withCount andInfo:(BOOL)andInfo revision:(NSString*)revisionOrNil {
    NSString *docWithRevArgument;
    if(andInfo)
    {
        docWithRevArgument = [NSString stringWithFormat:@"%@?revs=true&revs_info=true", docId];
    } else{
        docWithRevArgument = [NSString stringWithFormat:@"%@", docId];
    }
    
    if(revisionOrNil != nil){
        docWithRevArgument = [NSString stringWithFormat:@"%@&rev=%@",docWithRevArgument,revisionOrNil];
    }
    return docWithRevArgument;
}

-(NSString*)urlString{
    return [NSString stringWithFormat:@"http://%@:%u/%@", couchServer.host, couchServer.port, self.name];
}

-(NSString*)description{
    return [NSString stringWithFormat:@"http://%@:%u/%@", couchServer.host, couchServer.port, self.name];
}
@end
